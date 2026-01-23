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
    
    # Create admin account if credentials are provided
    if [ -n "$PB_ADMIN_EMAIL" ] && [ -n "$PB_ADMIN_PASSWORD" ]; then
        echo "👤 Creating admin account..."
        
        # Use the PocketBase admin API to create admin
        # Note: This uses the undocumented endpoint, alternatively we could use pb_migrations
        curl -s -X POST http://localhost:8080/api/admins \
            -H "Content-Type: application/json" \
            -d "{\"email\":\"$PB_ADMIN_EMAIL\",\"password\":\"$PB_ADMIN_PASSWORD\",\"passwordConfirm\":\"$PB_ADMIN_PASSWORD\"}" \
            > /dev/null 2>&1 || echo "   (Admin may already exist)"
        
        echo "✅ Admin account configured"
    fi
    
    # Import schema via API
    if [ -f "/app/pb_schema.json" ]; then
        echo "📋 Schema found - importing collections..."
        
        # Authenticate as admin to get token
        AUTH_RESPONSE=$(curl -s -X POST http://localhost:8080/api/admins/auth-with-password \
            -H "Content-Type: application/json" \
            -d "{\"identity\":\"$PB_ADMIN_EMAIL\",\"password\":\"$PB_ADMIN_PASSWORD\"}")
        
        TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$TOKEN" ]; then
            # Wrap schema in collections object as required by the import API
            echo "{\"collections\":$(cat /app/pb_schema.json),\"deleteMissing\":false}" > /tmp/import_payload.json
            
            # Import collections using the API
            IMPORT_RESPONSE=$(curl -s -X PUT http://localhost:8080/api/collections/import \
                -H "Authorization: $TOKEN" \
                -H "Content-Type: application/json" \
                -d @/tmp/import_payload.json)
            
            # Check if import was successful (returns 204 No Content on success)
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT http://localhost:8080/api/collections/import \
                -H "Authorization: $TOKEN" \
                -H "Content-Type: application/json" \
                -d @/tmp/import_payload.json)
            
            if [ "$HTTP_CODE" = "204" ]; then
                echo "✅ Schema imported successfully"
                rm -f /tmp/import_payload.json
            else
                echo "⚠️  Schema import failed (HTTP $HTTP_CODE), copying to /pb_data for manual import"
                echo "   Error: $IMPORT_RESPONSE"
                cp /app/pb_schema.json /pb_data/pb_schema.json
                rm -f /tmp/import_payload.json
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
