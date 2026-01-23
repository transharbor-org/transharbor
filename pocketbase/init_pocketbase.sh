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
            # Create batches using Python script
            python3 /app/batch_import.py /app/pb_schema.json
            
            # Import each batch
            BATCH_NUM=1
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
                rm -f /tmp/batch*.json /tmp/import_response.json
            else
                echo "⚠️  Import failed, copying schema to /pb_data for manual import"
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
