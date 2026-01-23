#!/bin/bash

# TransHarbor Complete Setup Script
# This script sets up everything you need to run TransHarbor

set -e

echo "🚀 TransHarbor Complete Setup"
echo "============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "   Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter is installed${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  Node.js is not installed${NC}"
    echo "   Node.js is optional but recommended for automated schema creation"
    echo "   Install from: https://nodejs.org/"
else
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js $NODE_VERSION is installed${NC}"
fi

echo ""
echo "📦 Step 1: Installing Flutter dependencies..."
flutter pub get

echo ""
echo "📦 Step 2: Setting up PocketBase..."
./setup_pocketbase.sh

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 Next Steps:"
echo ""
echo "1. Start PocketBase:"
echo "   ${GREEN}cd pocketbase && ./pocketbase serve${NC}"
echo ""
echo "2. In a new terminal, create admin account:"
echo "   ${GREEN}Open http://127.0.0.1:8090/_/${NC}"
echo ""
echo "3. Create database schema (choose one):"
echo ""
echo "   ${YELLOW}Option A${NC} - Automated (requires Node.js):"
echo "   ${GREEN}node scripts/create_pocketbase_schema.js${NC}"
echo ""
echo "   ${YELLOW}Option B${NC} - Manual import:"
echo "   - Go to http://127.0.0.1:8090/_/"
echo "   - Settings > Import collections"
echo "   - Upload pb_schema.json"
echo ""
echo "4. Run the Flutter app:"
echo "   ${GREEN}flutter run${NC}"
echo ""
echo "📚 Documentation:"
echo "   - Backend: POCKETBASE_AUTOMATION.md"
echo "   - Testing: test/README.md"
echo "   - CI/CD: .github/ACTIONS.md"
echo ""
echo "🎉 Happy coding!"
