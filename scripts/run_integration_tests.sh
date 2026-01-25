#!/bin/bash
set -e

echo "======================================"
echo "Running Integration Tests with ChromeDriver"
echo "======================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if ChromeDriver is installed
if ! command -v chromedriver &> /dev/null; then
    echo -e "${RED}Error: ChromeDriver not found${NC}"
    echo "Please install ChromeDriver:"
    echo "  Ubuntu/Debian: sudo apt-get install chromium-chromedriver"
    echo "  macOS: brew install chromedriver"
    echo "  Or download from: https://chromedriver.chromium.org/"
    exit 1
fi

# Check if Chrome is installed
if ! command -v google-chrome &> /dev/null && ! command -v chromium-browser &> /dev/null; then
    echo -e "${YELLOW}Warning: Chrome/Chromium not found${NC}"
    echo "Tests may fail without a browser installed"
fi

# Kill any existing ChromeDriver instances
pkill -f chromedriver || true

# Start ChromeDriver in background
echo -e "${GREEN}Starting ChromeDriver...${NC}"
chromedriver --port=4444 --url-base=/wd/hub &
CHROMEDRIVER_PID=$!

# Wait for ChromeDriver to start
sleep 2

# Function to cleanup on exit
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    kill $CHROMEDRIVER_PID 2>/dev/null || true
    pkill -f chromedriver || true
}
trap cleanup EXIT

# Verify ChromeDriver is running
if ! curl -s http://localhost:4444/wd/hub/status > /dev/null; then
    echo -e "${RED}Error: ChromeDriver failed to start${NC}"
    exit 1
fi

echo -e "${GREEN}ChromeDriver running on port 4444${NC}"
echo ""

# Run integration tests
echo -e "${GREEN}Running integration tests...${NC}"
echo ""

# Test individual test files
TEST_FILES=(
    "integration_test/login_flow_test.dart"
    "integration_test/register_flow_test.dart"
    "integration_test/navigation_flow_test.dart"
)

FAILED_TESTS=()

for test_file in "${TEST_FILES[@]}"; do
    if [ -f "$test_file" ]; then
        echo -e "${YELLOW}Running: $test_file${NC}"
        
        if flutter drive \
            --driver=test_driver/integration_test.dart \
            --target="$test_file" \
            -d web-server \
            --web-port=8080 \
            --web-browser-flag="--disable-gpu" \
            --web-browser-flag="--disable-software-rasterizer" \
            --web-browser-flag="--disable-dev-shm-usage" \
            --web-browser-flag="--no-sandbox"; then
            echo -e "${GREEN}✓ Passed: $test_file${NC}"
        else
            echo -e "${RED}✗ Failed: $test_file${NC}"
            FAILED_TESTS+=("$test_file")
        fi
        echo ""
    else
        echo -e "${YELLOW}Skipping: $test_file (not found)${NC}"
    fi
done

# Summary
echo "======================================"
echo "Test Summary"
echo "======================================"

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}${#FAILED_TESTS[@]} test file(s) failed:${NC}"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗ $failed_test${NC}"
    done
    exit 1
fi
