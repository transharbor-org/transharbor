#!/bin/bash
set -e

# PocketBase Restore Script from Hetzner Storage Box
# Downloads and restores a PocketBase backup

if [ -z "$1" ]; then
    echo "Usage: $0 <backup-filename>"
    echo ""
    echo "Available backups:"
    lftp -e "
        set sftp:auto-confirm yes;
        cd ${STORAGE_BOX_PATH:-/backups/pocketbase};
        cls -1 --sort=date;
        bye
    " sftp://${STORAGE_BOX_USER}@${STORAGE_BOX_HOST}
    exit 1
fi

BACKUP_FILE="$1"
RESTORE_DIR="/tmp/pocketbase-restore-$(date +%s)"
PB_DATA_DIR="${PB_DATA_DIR:-/pb_data}"

echo "[$(date)] Starting restore from backup: ${BACKUP_FILE}"
echo "[$(date)] WARNING: This will OVERWRITE current PocketBase data!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Create restore directory
mkdir -p "${RESTORE_DIR}"
cd "${RESTORE_DIR}"

# 1. Download backup from Hetzner Storage Box
echo "[$(date)] Downloading backup from Hetzner Storage Box..."
lftp -e "
    set sftp:auto-confirm yes;
    set net:timeout 30;
    cd ${STORAGE_BOX_PATH:-/backups/pocketbase};
    get ${BACKUP_FILE};
    bye
" sftp://${STORAGE_BOX_USER}@${STORAGE_BOX_HOST}

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "[$(date)] ERROR: Failed to download backup file"
    exit 1
fi

echo "[$(date)] Backup downloaded: $(du -h ${BACKUP_FILE} | cut -f1)"

# 2. Extract backup
echo "[$(date)] Extracting backup..."
tar xzf "${BACKUP_FILE}"
BACKUP_DIR=$(find . -maxdepth 1 -type d -name "pocketbase-backup-*" | head -1)

if [ -z "$BACKUP_DIR" ]; then
    echo "[$(date)] ERROR: Invalid backup format"
    exit 1
fi

# 3. Show manifest
if [ -f "${BACKUP_DIR}/manifest.json" ]; then
    echo ""
    echo "Backup Information:"
    cat "${BACKUP_DIR}/manifest.json" | jq .
    echo ""
fi

# 4. Stop PocketBase (if running in Kubernetes)
echo "[$(date)] Stopping PocketBase..."
kubectl scale deployment pocketbase-dev -n transharbor --replicas=0 2>/dev/null || true
sleep 5

# 5. Backup current data (just in case)
echo "[$(date)] Creating safety backup of current data..."
SAFETY_BACKUP="${PB_DATA_DIR}-backup-$(date +%s)"
if [ -d "${PB_DATA_DIR}" ]; then
    cp -r "${PB_DATA_DIR}" "${SAFETY_BACKUP}"
    echo "[$(date)] Current data backed up to: ${SAFETY_BACKUP}"
fi

# 6. Restore database
echo "[$(date)] Restoring database..."
if [ -f "${BACKUP_DIR}/data.db" ]; then
    cp "${BACKUP_DIR}/data.db" "${PB_DATA_DIR}/data.db"
    echo "[$(date)] Database restored"
else
    echo "[$(date)] WARNING: No database found in backup"
fi

# 7. Restore storage files
echo "[$(date)] Restoring storage files..."
if [ -d "${BACKUP_DIR}/storage" ]; then
    rm -rf "${PB_DATA_DIR}/storage"
    cp -r "${BACKUP_DIR}/storage" "${PB_DATA_DIR}/storage"
    echo "[$(date)] Storage files restored"
else
    echo "[$(date)] No storage files in backup"
fi

# 8. Restore hooks
echo "[$(date)] Restoring hooks..."
if [ -d "${BACKUP_DIR}/pb_hooks" ]; then
    rm -rf "${PB_DATA_DIR}/pb_hooks"
    cp -r "${BACKUP_DIR}/pb_hooks" "${PB_DATA_DIR}/pb_hooks"
    echo "[$(date)] Hooks restored"
else
    echo "[$(date)] No hooks in backup"
fi

# 9. Fix permissions
echo "[$(date)] Fixing permissions..."
chown -R 1000:1000 "${PB_DATA_DIR}" 2>/dev/null || true

# 10. Clean up
echo "[$(date)] Cleaning up..."
cd /
rm -rf "${RESTORE_DIR}"

# 11. Restart PocketBase
echo "[$(date)] Restarting PocketBase..."
kubectl scale deployment pocketbase-dev -n transharbor --replicas=1 2>/dev/null || true

echo ""
echo "[$(date)] ====================================="
echo "[$(date)] Restore completed successfully!"
echo "[$(date)] ====================================="
echo ""
echo "Safety backup of previous data: ${SAFETY_BACKUP}"
echo "You can delete it after verifying the restore:"
echo "  rm -rf ${SAFETY_BACKUP}"
