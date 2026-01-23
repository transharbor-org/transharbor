#!/bin/sh

set -e

echo "🚀 TransHarbor PocketBase Initialization"
echo "========================================"

# Create data directory
mkdir -p /pb_data

# Check if this is first run (no database file)
if [ ! -f "/pb_data/data.db" ]; then
    echo "📦 First run detected - initializing database..."
    
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
            # Import collections in batches to handle dependencies
            # Batch 1: Base collections without relations to other collections
            echo '{"collections":' > /tmp/batch1.json
            cat /app/pb_schema.json | grep -A 1000 '"name": "users"' | grep -B 1 '"name": "personals"' | head -n -1 >> /tmp/batch1.json
            echo ',"deleteMissing":false}' >> /tmp/batch1.json
            
            HTTP_CODE=$(curl -s -o /tmp/import_response.json -w "%{http_code}" -X PUT http://localhost:8080/api/collections/import \
                -H "Authorization: $TOKEN" \
                -H "Content-Type: application/json" \
                -d @/tmp/batch1.json)
            
            if [ "$HTTP_CODE" = "204" ]; then
                echo "✅ Batch 1 imported (users)"
                
                # Batch 2: All remaining collections (relations should now resolve)
                echo "{\"collections\":$(cat /app/pb_schema.json),\"deleteMissing\":false}" > /tmp/batch2.json
                
                HTTP_CODE=$(curl -s -o /tmp/import_response.json -w "%{http_code}" -X PUT http://localhost:8080/api/collections/import \
                    -H "Authorization: $TOKEN" \
                    -H "Content-Type: application/json" \
                    -d @/tmp/batch2.json)
                
                if [ "$HTTP_CODE" = "204" ]; then
                    echo "✅ All collections imported successfully"
                    rm -f /tmp/batch*.json /tmp/import_response.json
                else
                    echo "⚠️  Batch 2 import failed (HTTP $HTTP_CODE)"
                    cat /tmp/import_response.json
                    cp /app/pb_schema.json /pb_data/pb_schema.json
                    rm -f /tmp/batch*.json /tmp/import_response.json
                fi
            else
                echo "⚠️  Schema import failed (HTTP $HTTP_CODE), copying to /pb_data for manual import"
                cat /tmp/import_response.json
                cp /app/pb_schema.json /pb_data/pb_schema.json
                rm -f /tmp/batch*.json /tmp/import_response.json
            fi
        else
            echo "⚠️  Could not authenticate for schema import"
            cp /app/pb_schema.json /pb_data/pb_schema.json
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
