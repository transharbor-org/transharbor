#!/bin/bash
set -e

echo "=== SMS Provider Credentials Setup ==="
echo ""
echo "This script will configure SMS provider credentials for phone verification."
echo ""

# Prompt for provider
echo "Select SMS Provider:"
echo "1) Twilio"
echo "2) AWS SNS"
echo "3) Custom"
read -p "Enter choice [1-3]: " PROVIDER_CHOICE

case $PROVIDER_CHOICE in
  1)
    echo ""
    echo "=== Twilio Configuration ==="
    read -p "Twilio Account SID: " TWILIO_ACCOUNT_SID
    read -sp "Twilio Auth Token: " TWILIO_AUTH_TOKEN
    echo ""
    read -p "Twilio Phone Number (e.g., +12125551234): " TWILIO_FROM_NUMBER
    
    # Encode credentials for Basic Auth
    CREDENTIALS=$(echo -n "${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}" | base64)
    API_URL="https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json"
    API_KEY="Basic ${CREDENTIALS}"
    ;;
    
  2)
    echo ""
    echo "=== AWS SNS Configuration ==="
    read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
    read -sp "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
    echo ""
    read -p "AWS Region (e.g., us-east-1): " AWS_REGION
    
    API_URL="https://sns.${AWS_REGION}.amazonaws.com"
    API_KEY="${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}"
    ;;
    
  3)
    echo ""
    echo "=== Custom Provider Configuration ==="
    read -p "API URL: " API_URL
    read -sp "API Key: " API_KEY
    echo ""
    ;;
    
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Prompt for namespace
read -p "Kubernetes namespace [transharbor]: " NAMESPACE
NAMESPACE=${NAMESPACE:-transharbor}

# Prompt for encryption password (for sensitive data at rest)
read -sp "Encryption password (for storing credentials): " ENCRYPTION_PASSWORD
echo ""

# Create or update Kubernetes secret
echo ""
echo "Creating Kubernetes secret..."

kubectl create secret generic sms-credentials \
  --from-literal=api-url="${API_URL}" \
  --from-literal=api-key="${API_KEY}" \
  --from-literal=encryption-password="${ENCRYPTION_PASSWORD}" \
  --namespace="${NAMESPACE}" \
  --dry-run=client -o yaml | kubectl apply -f -

if [ $? -eq 0 ]; then
  echo "✓ Secret 'sms-credentials' created/updated in namespace '${NAMESPACE}'"
else
  echo "✗ Failed to create secret"
  exit 1
fi

# Update web deployment to use the secret
echo ""
echo "Updating web deployment..."

# Check if deployment exists
if kubectl get deployment web-dev -n "${NAMESPACE}" &> /dev/null; then
  # Patch deployment to add environment variables
  kubectl patch deployment web-dev -n "${NAMESPACE}" --type='json' -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/env/-",
      "value": {
        "name": "SMS_API_URL",
        "valueFrom": {
          "secretKeyRef": {
            "name": "sms-credentials",
            "key": "api-url"
          }
        }
      }
    },
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/env/-",
      "value": {
        "name": "SMS_API_KEY",
        "valueFrom": {
          "secretKeyRef": {
            "name": "sms-credentials",
            "key": "api-key"
          }
        }
      }
    }
  ]' 2>/dev/null || echo "Note: Environment variables may already exist"
  
  echo "✓ Deployment updated"
else
  echo "⚠ Deployment 'web-dev' not found in namespace '${NAMESPACE}'"
  echo "  Secret created but not attached to deployment"
  echo "  Add environment variables manually to your deployment manifest"
fi

# Test SMS credentials (optional)
echo ""
read -p "Test SMS credentials? [y/N]: " TEST_CHOICE
if [[ $TEST_CHOICE =~ ^[Yy]$ ]]; then
  read -p "Test phone number (e.g., +12125551234): " TEST_PHONE
  
  echo "Testing SMS delivery..."
  
  case $PROVIDER_CHOICE in
    1)
      # Twilio test
      curl -X POST "${API_URL}" \
        --data-urlencode "To=${TEST_PHONE}" \
        --data-urlencode "From=${TWILIO_FROM_NUMBER}" \
        --data-urlencode "Body=TransHarbor test message" \
        -H "Authorization: ${API_KEY}"
      ;;
      
    2)
      # AWS SNS test (requires aws-cli)
      if command -v aws &> /dev/null; then
        IFS=':' read -r ACCESS_KEY SECRET_KEY <<< "$API_KEY"
        AWS_ACCESS_KEY_ID="$ACCESS_KEY" \
        AWS_SECRET_ACCESS_KEY="$SECRET_KEY" \
        aws sns publish \
          --region "${AWS_REGION}" \
          --phone-number "${TEST_PHONE}" \
          --message "TransHarbor test message"
      else
        echo "⚠ aws-cli not installed, skipping test"
      fi
      ;;
      
    *)
      echo "⚠ Custom provider test not implemented"
      ;;
  esac
  
  echo ""
  echo "Check your phone for test message"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Update PocketBase schema (see docs/PHONE_VERIFICATION.md)"
echo "2. Deploy phone verification hooks"
echo "3. Test registration flow"
echo ""
echo "To view the secret:"
echo "  kubectl get secret sms-credentials -n ${NAMESPACE} -o yaml"
echo ""
echo "To delete the secret:"
echo "  kubectl delete secret sms-credentials -n ${NAMESPACE}"
echo ""
