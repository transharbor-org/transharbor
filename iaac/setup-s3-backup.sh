#!/bin/bash
# Setup S3 encrypted backups for PocketBase
# Run this script to configure S3 backup credentials

set -e

echo "PocketBase S3 Encrypted Backup Setup"
echo "====================================="
echo

# Check if we're in the right directory
if [ ! -f "iaac/dev/pocketbase-s3-backup.yaml" ]; then
    echo "Error: Run this script from the repository root"
    exit 1
fi

# Prompt for S3 provider
echo "Select S3 provider:"
echo "1) Civo S3"
echo "2) Cloudflare R2"
read -p "Choice (1 or 2): " PROVIDER

if [ "$PROVIDER" = "1" ]; then
    S3_ENDPOINT="https://objectstore.lon1.civo.com"
    echo "Using Civo S3 (London region)"
elif [ "$PROVIDER" = "2" ]; then
    read -p "Cloudflare Account ID: " CF_ACCOUNT_ID
    S3_ENDPOINT="https://${CF_ACCOUNT_ID}.r2.cloudflarestorage.com"
    echo "Using Cloudflare R2"
else
    echo "Invalid choice"
    exit 1
fi

# Prompt for credentials
read -p "S3 Bucket Name: " S3_BUCKET
read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -sp "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo
read -sp "Encryption Password (strong!): " ENCRYPTION_PASSWORD
echo
read -sp "Confirm Encryption Password: " ENCRYPTION_PASSWORD_CONFIRM
echo

if [ "$ENCRYPTION_PASSWORD" != "$ENCRYPTION_PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords don't match"
    exit 1
fi

# Prompt for environment
echo
read -p "Environment (dev/staging/prod): " ENVIRONMENT
NAMESPACE="transharbor"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "Error: Invalid environment"
    exit 1
fi

echo
echo "Creating Kubernetes secret..."

kubectl create secret generic pocketbase-s3-backup -n $NAMESPACE \
  --from-literal=S3_ENDPOINT="$S3_ENDPOINT" \
  --from-literal=S3_BUCKET="$S3_BUCKET" \
  --from-literal=AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --from-literal=AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --from-literal=ENCRYPTION_PASSWORD="$ENCRYPTION_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo
echo "Applying S3 backup CronJob..."
kubectl apply -f iaac/${ENVIRONMENT}/pocketbase-s3-backup.yaml

echo
echo "✅ S3 encrypted backup configured!"
echo
echo "Backup schedule: Daily at 3 AM UTC"
echo "Retention: 30 days"
echo "Encryption: AES256 with GPG"
echo
echo "To test backup now:"
echo "  kubectl create job --from=cronjob/pocketbase-s3-backup pocketbase-s3-backup-test -n $NAMESPACE"
echo
echo "To restore a backup:"
echo "  ./iaac/restore-s3-backup.sh"
echo

# Save restore info
cat > /tmp/restore-info.txt << EOF
S3_ENDPOINT=$S3_ENDPOINT
S3_BUCKET=$S3_BUCKET
NAMESPACE=$NAMESPACE
ENVIRONMENT=$ENVIRONMENT
EOF

echo "Restore info saved to /tmp/restore-info.txt"
