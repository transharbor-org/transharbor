#!/bin/bash
# API Integration Test Script for TransHarbor
# Tests all major API endpoints with authentication and filtering

set -e

API_URL="${API_URL:-https://dev.transharbor.org/api}"
TEST_EMAIL="${TEST_EMAIL:-alex@example.com}"
TEST_PASSWORD="${TEST_PASSWORD:-password123}"

PASSED=0
FAILED=0

test_endpoint() {
  local name="$1"
  local url="$2"
  local expected_count="$3"
  
  echo -n "  Testing $name... "
  RESPONSE=$(curl -s "$url" -H "Authorization: $TOKEN" 2>/dev/null)
  
  if echo "$RESPONSE" | jq -e '.items' > /dev/null 2>&1; then
    COUNT=$(echo "$RESPONSE" | jq -r '.items | length')
    if [ "$COUNT" -ge "$expected_count" ]; then
      echo "✅ ($COUNT items)"
      PASSED=$((PASSED + 1))
      return 0
    else
      echo "⚠️  ($COUNT items, expected >= $expected_count)"
      FAILED=$((FAILED + 1))
      return 1
    fi
  else
    echo "❌ (Invalid response)"
    echo "$RESPONSE" | jq . || echo "$RESPONSE"
    FAILED=$((FAILED + 1))
    return 1
  fi
}

echo "🧪 TransHarbor API Integration Tests"
echo "===================================="
echo "API URL: $API_URL"
echo ""

# Test 1: Authentication
echo "1️⃣  Authentication"
AUTH_RESPONSE=$(curl -s -X POST ${API_URL}/collections/users/auth-with-password \
  -H "Content-Type: application/json" \
  -d "{\"identity\": \"$TEST_EMAIL\", \"password\": \"$TEST_PASSWORD\"}")

TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.token // empty')
USER_ID=$(echo "$AUTH_RESPONSE" | jq -r '.record.id // empty')

if [ -z "$TOKEN" ]; then
  echo "  ❌ Authentication failed"
  echo "$AUTH_RESPONSE" | jq .
  exit 1
fi

echo "  ✅ Authenticated as: $(echo "$AUTH_RESPONSE" | jq -r '.record.email')"
echo "  User ID: $USER_ID"
PASSED=$((PASSED + 1))
echo ""

# Test 2: User Profile
echo "2️⃣  User Profile"
echo -n "  Testing profile fields... "
EMAIL=$(echo "$AUTH_RESPONSE" | jq -r '.record.email')
NAME=$(echo "$AUTH_RESPONSE" | jq -r '.record.name')
USERNAME=$(echo "$AUTH_RESPONSE" | jq -r '.record.username')

if [ -n "$EMAIL" ] && [ -n "$NAME" ] && [ -n "$USERNAME" ]; then
  echo "✅"
  echo "    Email: $EMAIL"
  echo "    Name: $NAME"
  echo "    Username: $USERNAME"
  PASSED=$((PASSED + 1))
else
  echo "❌ Missing profile fields"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 3: Personals
echo "3️⃣  Personals Collection"
test_endpoint "Personals (filtered)" \
  "${API_URL}/collections/personals/records?filter=user%3D%22${USER_ID}%22" \
  1
echo ""

# Test 4: Conversations
echo "4️⃣  Conversations Collection"
test_endpoint "Conversations (filtered)" \
  "${API_URL}/collections/conversations/records?filter=participants~%22${USER_ID}%22" \
  1

# Get first conversation for message testing
CONVERSATIONS=$(curl -s "${API_URL}/collections/conversations/records?filter=participants~%22${USER_ID}%22" \
  -H "Authorization: $TOKEN")
CONV_ID=$(echo "$CONVERSATIONS" | jq -r '.items[0].id // empty')
echo ""

# Test 5: Messages
echo "5️⃣  Messages Collection"
if [ -n "$CONV_ID" ]; then
  test_endpoint "Messages (filtered)" \
    "${API_URL}/collections/messages/records?filter=conversation%3D%22${CONV_ID}%22" \
    0
else
  echo "  ⚠️  Skipped (no conversations)"
fi
echo ""

# Test 6: Proposals
echo "6️⃣  Proposals Collection"
test_endpoint "Proposals (all)" \
  "${API_URL}/collections/proposals/records" \
  1
echo ""

# Test 7: Health endpoint
echo "7️⃣  Health Endpoint"
echo -n "  Testing /api/health... "
HEALTH=$(curl -s "${API_URL}/health")
if echo "$HEALTH" | jq -e '.code == 200' > /dev/null 2>&1; then
  echo "✅"
  PASSED=$((PASSED + 1))
else
  echo "❌"
  FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo "===================================="
echo "📊 Test Results"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "✅ All tests passed!"
  exit 0
else
  echo "❌ Some tests failed"
  exit 1
fi
