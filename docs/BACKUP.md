# PocketBase Backup to Hetzner Storage Box

Automated daily backups of PocketBase to Hetzner Storage Box via SFTP.

## Setup

### 1. Get Hetzner Storage Box

Order a Storage Box from Hetzner:
- https://www.hetzner.com/storage/storage-box
- Recommended: BX11 (1TB for €3.81/month)

### 2. Generate SSH Key for Backup

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -f ~/.ssh/hetzner_backup -C "pocketbase-backup"

# Display public key
cat ~/.ssh/hetzner_backup.pub
```

### 3. Add SSH Key to Hetzner Storage Box

1. Go to https://robot.hetzner.com/storage
2. Click on your Storage Box (e.g., `u123456`)
3. Navigate to "SSH-Keys" tab
4. Add your public key

### 4. Create Kubernetes Secret

```bash
# Copy template
cp iaac/backups/backup-secrets-template.yaml iaac/backups/backup-secrets.yaml

# Edit with your details
nano iaac/backups/backup-secrets.yaml

# Update:
# - STORAGE_BOX_HOST: u123456.your-storagebox.de
# - STORAGE_BOX_USER: u123456
# - SSH_PRIVATE_KEY: paste contents of ~/.ssh/hetzner_backup
```

### 5. Create ConfigMap for Backup Script

```bash
kubectl create configmap pocketbase-backup-script \
  -n transharbor \
  --from-file=backup-pocketbase.sh=scripts/backup-pocketbase.sh
```

### 6. Deploy Backup Infrastructure

```bash
# Apply secrets and config
kubectl apply -f iaac/backups/backup-secrets.yaml

# Deploy CronJob
kubectl apply -f iaac/backups/pocketbase-backup-cronjob.yaml

# Verify deployment
kubectl get cronjob pocketbase-backup -n transharbor
```

## Usage

### Manual Backup

Trigger a backup manually:

```bash
kubectl create job --from=cronjob/pocketbase-backup \
  pocketbase-backup-manual-$(date +%s) \
  -n transharbor

# Watch progress
kubectl logs -f job/pocketbase-backup-manual-XXXXX -n transharbor
```

### View Backup History

```bash
# List recent backup jobs
kubectl get jobs -n transharbor -l app=pocketbase-backup

# View logs from last backup
kubectl logs -n transharbor \
  $(kubectl get pods -n transharbor -l app=pocketbase-backup --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
```

### List Available Backups

```bash
# Connect to Storage Box
sftp u123456@u123456.your-storagebox.de

# List backups
cd /backups/pocketbase
ls -lht
```

## Restore

### From Kubernetes

```bash
# 1. Copy restore script to a pod
kubectl cp scripts/restore-pocketbase.sh \
  transharbor/pocketbase-dev-XXXXX:/tmp/restore.sh

# 2. Execute restore
kubectl exec -it pocketbase-dev-XXXXX -n transharbor -- \
  bash /tmp/restore.sh pocketbase-backup-20260124_020000.tar.gz
```

### Local Restore

```bash
# Download backup
sftp u123456@u123456.your-storagebox.de:/backups/pocketbase/pocketbase-backup-20260124_020000.tar.gz .

# Extract
tar xzf pocketbase-backup-20260124_020000.tar.gz

# Restore to local PocketBase
cp pocketbase-backup-20260124_020000/data.db /path/to/pb_data/
cp -r pocketbase-backup-20260124_020000/storage /path/to/pb_data/
```

## Backup Contents

Each backup includes:

1. **Database** (`data.db`) - SQLite database with all data
2. **Storage** (`storage/`) - Uploaded files (avatars, images, etc.)
3. **Hooks** (`pb_hooks/`) - Server-side JavaScript hooks
4. **Manifest** (`manifest.json`) - Backup metadata

## Retention Policy

- **Daily**: Keep last 7 days
- **Weekly**: Keep last 4 weeks  
- **Monthly**: Keep last 12 months

Configure in `backup-secrets.yaml`:
```yaml
KEEP_DAILY: "7"
KEEP_WEEKLY: "4"
KEEP_MONTHLY: "12"
```

## Backup Schedule

Default: Daily at 2 AM UTC

Change in `pocketbase-backup-cronjob.yaml`:
```yaml
spec:
  schedule: "0 2 * * *"  # cron format
```

## Monitoring

### Check Backup Status

```bash
# View CronJob status
kubectl describe cronjob pocketbase-backup -n transharbor

# Check last run
kubectl get jobs -n transharbor -l app=pocketbase-backup --sort-by=.metadata.creationTimestamp

# View backup logs
kubectl logs -n transharbor -l app=pocketbase-backup --tail=100
```

### Alerts (Optional)

Add to Prometheus alerting rules:

```yaml
- alert: PocketBaseBackupFailed
  expr: kube_job_status_failed{job_name=~"pocketbase-backup.*"} > 0
  for: 1h
  annotations:
    summary: "PocketBase backup failed"
```

## Cost

**Hetzner Storage Box BX11:**
- 1TB storage
- Unlimited traffic
- SFTP/SSH access
- **€3.81/month** (~$4.15 USD)

Example costs for 1 year:
- 365 daily backups × 100MB = ~36GB
- 52 weekly backups × 100MB = ~5GB
- 12 monthly backups × 100MB = ~1GB
- **Total: ~42GB (well within 1TB limit)**

## Security

- ✅ Encrypted in transit (SFTP over SSH)
- ✅ SSH key authentication (no passwords)
- ✅ Read-only mount for PocketBase volume
- ✅ Secrets stored in Kubernetes Secrets
- ⚠️  Not encrypted at rest (add encryption if needed)

### Add Encryption at Rest (Optional)

```bash
# Encrypt before upload
gpg --symmetric --cipher-algo AES256 backup.tar.gz

# Decrypt for restore
gpg backup.tar.gz.gpg
```

## Troubleshooting

### Backup job fails with "Permission denied"

```bash
# Check SSH key is added to Storage Box
ssh u123456@u123456.your-storagebox.de

# Verify secret is correct
kubectl get secret pocketbase-backup-credentials -n transharbor -o yaml
```

### Out of disk space

```bash
# Check Storage Box usage
sftp u123456@u123456.your-storagebox.de
> quota

# Manually clean old backups
> cd /backups/pocketbase
> rm pocketbase-backup-old.tar.gz
```

### Restore fails

```bash
# Check backup integrity
tar tzf pocketbase-backup-20260124_020000.tar.gz

# Verify manifest
tar xzf pocketbase-backup-20260124_020000.tar.gz
cat pocketbase-backup-20260124_020000/manifest.json
```

## Alternative: Hetzner Object Storage

If you prefer S3-compatible storage:

1. Use Hetzner Object Storage (S3-compatible)
2. Replace SFTP code with `s3cmd` or `aws s3`
3. Similar pricing: €5/month for 250GB

See: https://docs.hetzner.com/storage/object-storage/
