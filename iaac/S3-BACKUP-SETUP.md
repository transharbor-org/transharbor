# S3 Encrypted Backup Setup

## Overview
PocketBase backups are encrypted with GPG (AES256) and stored in S3-compatible storage (Civo Object Storage or Cloudflare R2).

**Features:**
- Daily automated backups at 3 AM UTC
- AES256 encryption with GPG
- 30-day retention (automatic cleanup)
- Runs as Kubernetes CronJob (no OS dependencies)

## Quick Setup

### 1. Create S3 Bucket

**Civo:**
```bash
# Via Civo CLI
civo objectstore create transharbor-backups --region LON1

# Get credentials from Civo dashboard or CLI
civo objectstore credential list
```

**Cloudflare R2:**
```bash
# Via Cloudflare dashboard:
# 1. Go to R2 Object Storage
# 2. Create bucket: transharbor-backups
# 3. Create API token with R2 permissions
```

### 2. Configure Backup

Run the setup script:
```bash
./iaac/setup-s3-backup.sh
```

This will:
- Prompt for S3 credentials
- Create Kubernetes secret
- Deploy backup CronJob

### 3. Test Backup

```bash
# Trigger manual backup
kubectl create job --from=cronjob/pocketbase-s3-backup pocketbase-s3-backup-test -n transharbor

# Check logs
kubectl logs -n transharbor job/pocketbase-s3-backup-test
```

## Restore Backup

Run the restore script:
```bash
./iaac/restore-s3-backup.sh
```

This will:
1. List available backups
2. Download and decrypt selected backup
3. Optionally restore to running pod

## Manual Operations

### List Backups
```bash
aws s3 ls s3://transharbor-backups/pocketbase/ \
  --endpoint-url=https://objectstore.lon1.civo.com
```

### Download Backup
```bash
aws s3 cp s3://transharbor-backups/pocketbase/backup-20260123-030000.db.gpg \
  ./backup.db.gpg \
  --endpoint-url=https://objectstore.lon1.civo.com
```

### Decrypt Backup
```bash
gpg --decrypt -o restored.db backup.db.gpg
# Enter encryption password when prompted
```

### Restore to Pod
```bash
POCKETBASE_POD=$(kubectl get pods -n transharbor -l app=pocketbase -o jsonpath='{.items[0].metadata.name}')

# Stop PocketBase
kubectl scale deployment pocketbase-dev -n transharbor --replicas=0

# Copy backup
kubectl cp restored.db transharbor/$POCKETBASE_POD:/pb_data/data.db

# Restart PocketBase
kubectl scale deployment pocketbase-dev -n transharbor --replicas=1
```

## Production Setup (Civo Kubernetes)

For production on Civo managed k8s:

1. **Create bucket in production region:**
   ```bash
   civo objectstore create transharbor-backups-prod --region NYC1
   ```

2. **Copy manifests to prod:**
   ```bash
   cp iaac/dev/pocketbase-s3-backup.yaml iaac/prod/
   ```

3. **Run setup script on prod cluster:**
   ```bash
   # Point kubectl to prod cluster
   export KUBECONFIG=~/.kube/civo-prod-config
   
   # Run setup
   ./iaac/setup-s3-backup.sh
   # Select environment: prod
   ```

## Security Notes

- **Encryption password:** Store securely (password manager, vault)
- **S3 credentials:** Rotate regularly
- **Bucket access:** Restrict to backup jobs only
- **Retention:** 30 days default (adjust in CronJob)

## Costs

**Civo Object Storage:**
- $0.01/GB/month storage
- $0.01/GB egress
- Example: 100MB daily backup = ~3GB/month = $0.03/month

**Cloudflare R2:**
- $0.015/GB/month storage
- Free egress
- No transaction fees

## Troubleshooting

**Backup fails to upload:**
- Check S3 credentials in secret
- Verify bucket exists
- Test aws-cli access

**Can't decrypt backup:**
- Verify encryption password
- Check GPG is installed: `gpg --version`

**Restore fails:**
- Check PVC is mounted at `/pb_data`
- Verify database file permissions
- Check pod logs for errors
