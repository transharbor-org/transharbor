#!/bin/sh

set -e

echo "🚀 TransHarbor PocketBase Initialization"
echo "========================================"

# Create data directory and copy hooks
mkdir -p /pb_data/pb_hooks

# Copy hooks from app directory to pb_data (where PocketBase loads them)
echo "📋 Copying hooks..."
if [ -d "/app/pb_hooks" ]; then
    cp -r /app/pb_hooks/* /pb_data/pb_hooks/ 2>/dev/null || true
    echo "✅ Hooks copied to /pb_data/pb_hooks/"
fi

# Check if schema has changed by comparing checksums
SCHEMA_CHECKSUM=$(md5sum /app/pb_schema.json | cut -d' ' -f1)
NEED_IMPORT=false

if [ ! -f "/pb_data/.initialized" ]; then
    echo "📦 First run detected - initializing database..."
    NEED_IMPORT=true
elif [ ! -f "/pb_data/.schema_checksum" ] || [ "$(cat /pb_data/.schema_checksum)" != "$SCHEMA_CHECKSUM" ]; then
    echo "📦 Schema changed - reimporting collections..."
    NEED_IMPORT=true
    # Remove initialization marker to force reimport
    rm -f /pb_data/.initialized
fi

if [ "$NEED_IMPORT" = "true" ]; then
    
    # Start PocketBase in background to initialize DB
    /app/pocketbase serve --http=0.0.0.0:8080 --dir=/pb_data &
    PB_PID=$!
    
    echo "⏳ Waiting for PocketBase to start..."
    sleep 5
    
    # Wait for PocketBase to be ready
    max_attempts=30
    attempt=0
    while ! curl -s http://localhost:8080/api/health > /dev/null 2>&1; do
        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
            echo "❌ PocketBase failed to start"
            kill $PB_PID 2>/dev/null || true
            exit 1
        fi
        echo "   Attempt $attempt/$max_attempts..."
        sleep 2
    done
    
    echo "✅ PocketBase started"
    
    # Create superuser account if credentials are provided (v0.23+ uses superusers)
    if [ -n "$PB_ADMIN_EMAIL" ] && [ -n "$PB_ADMIN_PASSWORD" ]; then
        echo "👤 Creating superuser account..."
        
        # Use PocketBase CLI to create superuser
        /app/pocketbase --dir=/pb_data superuser upsert "$PB_ADMIN_EMAIL" "$PB_ADMIN_PASSWORD" > /dev/null 2>&1 || echo "   (Superuser may already exist)"
        
        echo "✅ Superuser account configured"
    fi
    
    # Import schema via API
    if [ -f "/app/pb_schema.json" ]; then
        echo "📋 Schema found - importing collections..."
        
        # Authenticate as superuser to get token (v0.23+ uses _superusers collection)
        AUTH_RESPONSE=$(curl -s -X POST http://localhost:8080/api/collections/_superusers/auth-with-password \
            -H "Content-Type: application/json" \
            -d "{\"identity\":\"$PB_ADMIN_EMAIL\",\"password\":\"$PB_ADMIN_PASSWORD\"}")
        
        TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$TOKEN" ]; then
            # Create batches using Python script (rules stripped to avoid circular deps)
            python3 /app/import_schema.py /app/pb_schema.json
            
            # PART 1: Import batches 1 and 2 (no complex dependencies)
            echo "📦 Part 1: Importing foundation collections..."
            for BATCH_NUM in 1 2; do
                if [ -f "/tmp/batch${BATCH_NUM}.json" ]; then
                    HTTP_CODE=$(curl -s -o /tmp/import_response.json -w "%{http_code}" -X PUT http://localhost:8080/api/collections/import \
                        -H "Authorization: $TOKEN" \
                        -H "Content-Type: application/json" \
                        -d @/tmp/batch${BATCH_NUM}.json)
                    
                    if [ "$HTTP_CODE" = "204" ]; then
                        echo "✅ Batch $BATCH_NUM imported successfully"
                    else
                        echo "⚠️  Batch $BATCH_NUM import failed (HTTP $HTTP_CODE)"
                        cat /tmp/import_response.json
                        cp /app/pb_schema.json /pb_data/pb_schema.json
                        exit 1
                    fi
                fi
            done
            
            # PART 2: Query API to get collection IDs and update remaining batches
            echo "🔍 Part 2: Resolving collection IDs..."
            python3 << PYTHON_SCRIPT
import json
import urllib.request

# Get all collections
req = urllib.request.Request('http://localhost:8080/api/collections?perPage=100',
                             headers={'Authorization': '$TOKEN'})
resp = urllib.request.urlopen(req)
collections = json.loads(resp.read())['items']

# Build name -> ID mapping
id_map = {c['name']: c['id'] for c in collections}
print(f"✅ Found {len(id_map)} collections")

# Update batch 3+ with actual collection IDs
for batch_num in range(3, 10):
    batch_file = f'/tmp/batch{batch_num}.json'
    try:
        with open(batch_file, 'r') as f:
            data = json.load(f)
        
        # Update collectionId fields in relations
        updated = False
        for coll in data['collections']:
            for field in coll.get('fields', []):
                if field.get('type') == 'relation':
                    coll_id = field.get('collectionId', '')
                    # Replace name with actual ID if we have it
                    if coll_id in id_map:
                        field['collectionId'] = id_map[coll_id]
                        updated = True
        
        if updated:
            with open(batch_file, 'w') as f:
                json.dump(data, f)
            print(f"✅ Updated batch {batch_num} with collection IDs")
    except FileNotFoundError:
        break
PYTHON_SCRIPT
            
            # Import remaining batches with resolved IDs
            echo "📦 Part 2: Importing remaining collections with resolved IDs..."
            BATCH_NUM=3
            SUCCESS=true
            
            while [ -f "/tmp/batch${BATCH_NUM}.json" ]; do
                HTTP_CODE=$(curl -s -o /tmp/import_response.json -w "%{http_code}" -X PUT http://localhost:8080/api/collections/import \
                    -H "Authorization: $TOKEN" \
                    -H "Content-Type: application/json" \
                    -d @/tmp/batch${BATCH_NUM}.json)
                
                if [ "$HTTP_CODE" = "204" ]; then
                    echo "✅ Batch $BATCH_NUM imported successfully"
                else
                    echo "⚠️  Batch $BATCH_NUM import failed (HTTP $HTTP_CODE)"
                    cat /tmp/import_response.json
                    SUCCESS=false
                    break
                fi
                
                BATCH_NUM=$((BATCH_NUM + 1))
            done
            
            if [ "$SUCCESS" = "true" ]; then
                echo "✅ All collections imported successfully"
                
                # Now apply rules from original schema
                echo "📝 Applying collection rules..."
                python3 - "$TOKEN" <<'PYEOF'
import sys
import json
import urllib.request

token = sys.argv[1]

# Read original schema to get rules
with open('/app/pb_schema.json', 'r') as f:
    schema = json.load(f)

# Apply rules for each collection
for collection in schema:
    name = collection.get('name')
    rules = {
        'listRule': collection.get('listRule'),
        'viewRule': collection.get('viewRule'),
        'createRule': collection.get('createRule'),
        'updateRule': collection.get('updateRule'),
        'deleteRule': collection.get('deleteRule'),
    }
    
    try:
        # Get collection ID
        req = urllib.request.Request(
            f'http://localhost:8080/api/collections/{name}',
            headers={'Authorization': token}
        )
        with urllib.request.urlopen(req) as response:
            coll_data = json.loads(response.read())
            coll_id = coll_data['id']
        
        # Update rules
        data = json.dumps(rules).encode('utf-8')
        req = urllib.request.Request(
            f'http://localhost:8080/api/collections/{coll_id}',
            data=data,
            method='PATCH',
            headers={
                'Authorization': token,
                'Content-Type': 'application/json'
            }
        )
        with urllib.request.urlopen(req) as response:
            print(f'  ✅ Applied rules for {name}')
    except Exception as e:
        print(f'  ⚠️  Failed to apply rules for {name}: {e}')

PYEOF
                
                rm -f /tmp/batch*.json /tmp/import_response.json /tmp/collections_with_rules.json
                touch /pb_data/.initialized
                echo "$SCHEMA_CHECKSUM" > /pb_data/.schema_checksum
            else
                echo "⚠️  Import failed, copying schema to /pb_data for manual import"
                cp /app/pb_schema.json /pb_data/pb_schema.json
                rm -f /tmp/batch*.json /tmp/import_response.json /tmp/collections_with_rules.json
                touch /pb_data/.initialized
            fi
        else
            echo "⚠️  Could not authenticate for schema import"
            cp /app/pb_schema.json /pb_data/pb_schema.json
            touch /pb_data/.initialized
            echo "$SCHEMA_CHECKSUM" > /pb_data/.schema_checksum
        fi
    fi
    
    # Stop temporary instance
    echo "🔄 Restarting PocketBase..."
    kill $PB_PID 2>/dev/null || true
    wait $PB_PID 2>/dev/null || true
    sleep 2
fi

echo "✅ Initialization complete"
echo "🌐 Starting PocketBase server..."
echo ""

# Start PocketBase normally
exec /app/pocketbase serve --http=0.0.0.0:8080 --dir=/pb_data
