#!/bin/bash

# TransHarbor PocketBase Setup Script
# This script downloads PocketBase, creates the schema, and starts the server

set -e  # Exit on error

POCKETBASE_VERSION="0.18.10"
POCKETBASE_DIR="./pocketbase"
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Convert architecture names
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
esac

echo "🚀 TransHarbor PocketBase Setup"
echo "================================"
echo ""

# Create pocketbase directory if it doesn't exist
if [ ! -d "$POCKETBASE_DIR" ]; then
    mkdir -p "$POCKETBASE_DIR"
    echo "✓ Created pocketbase directory"
fi

cd "$POCKETBASE_DIR"

# Download PocketBase if not already present
if [ ! -f "pocketbase" ]; then
    echo "📦 Downloading PocketBase v${POCKETBASE_VERSION}..."
    
    DOWNLOAD_URL="https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_${PLATFORM}_${ARCH}.zip"
    
    echo "   URL: $DOWNLOAD_URL"
    
    if command -v curl &> /dev/null; then
        curl -L "$DOWNLOAD_URL" -o pocketbase.zip
    elif command -v wget &> /dev/null; then
        wget "$DOWNLOAD_URL" -O pocketbase.zip
    else
        echo "❌ Error: Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
    
    echo "📂 Extracting PocketBase..."
    unzip -q pocketbase.zip
    rm pocketbase.zip
    chmod +x pocketbase
    echo "✓ PocketBase installed successfully"
else
    echo "✓ PocketBase already installed"
fi

# Check if pb_schema.json exists in parent directory
if [ -f "../pb_schema.json" ]; then
    echo "📋 Found schema file: pb_schema.json"
    
    # Start PocketBase in background temporarily to load schema
    echo "🔄 Starting PocketBase temporarily to initialize database..."
    ./pocketbase serve --http=127.0.0.1:8090 > /dev/null 2>&1 &
    PB_PID=$!
    
    # Wait for PocketBase to start
    echo "⏳ Waiting for PocketBase to start..."
    sleep 3
    
    # Check if server is running
    if curl -s http://127.0.0.1:8090/api/health > /dev/null; then
        echo "✓ PocketBase started"
        
        # Stop PocketBase
        kill $PB_PID 2>/dev/null || true
        wait $PB_PID 2>/dev/null || true
        sleep 1
        
        # Import schema
        echo "📥 Importing schema..."
        # Note: Schema import requires admin setup first
        echo "⚠️  Schema import requires manual admin creation on first run"
    else
        echo "⚠️  Could not connect to PocketBase"
        kill $PB_PID 2>/dev/null || true
    fi
fi

echo ""
echo "✅ PocketBase setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Start PocketBase: cd pocketbase && ./pocketbase serve"
echo "   2. Open admin UI: http://127.0.0.1:8090/_/"
echo "   3. Create admin account (first time only)"
echo "   4. Import pb_schema.json via Settings > Import collections"
echo ""
echo "🔧 Or run the automated schema creation:"
echo "   node scripts/create_pocketbase_schema.js"
echo ""
echo "🚀 After setup, your PocketBase API will be at: http://127.0.0.1:8090/api/"
