#!/bin/bash
set -e

# PocketBase Backup Script for Hetzner Storage Box
# Backs up database, files, and hooks to Hetzner Storage Box via SFTP

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="pocketbase-backup-${TIMESTAMP}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
PB_DATA_DIR="${PB_DATA_DIR:-/pb_data}"

# Hetzner Storage Box credentials (from secrets)
STORAGE_BOX_HOST="${STORAGE_BOX_HOST:-u123456.your-storagebox.de}"
STORAGE_BOX_USER="${STORAGE_BOX_USER:-u123456}"
STORAGE_BOX_PATH="${STORAGE_BOX_PATH:-/backups/pocketbase}"

# Retention settings
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=12

echo "[$(date)] Starting PocketBase backup: ${BACKUP_NAME}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# 1. Backup SQLite database
echo "[$(date)] Backing up database..."
if [ -f "${PB_DATA_DIR}/data.db" ]; then
    sqlite3 "${PB_DATA_DIR}/data.db" ".backup '${BACKUP_DIR}/data.db'"
    echo "[$(date)] Database backed up: $(du -h ${BACKUP_DIR}/data.db | cut -f1)"
else
    echo "[$(date)] WARNING: Database not found at ${PB_DATA_DIR}/data.db"
fi

# 2. Backup uploaded files
echo "[$(date)] Backing up storage files..."
if [ -d "${PB_DATA_DIR}/storage" ]; then
    cp -r "${PB_DATA_DIR}/storage" "${BACKUP_DIR}/storage"
    echo "[$(date)] Storage backed up: $(du -sh ${BACKUP_DIR}/storage | cut -f1)"
else
    echo "[$(date)] No storage directory found"
fi

# 3. Backup hooks
echo "[$(date)] Backing up hooks..."
if [ -d "${PB_DATA_DIR}/pb_hooks" ]; then
    cp -r "${PB_DATA_DIR}/pb_hooks" "${BACKUP_DIR}/pb_hooks"
    echo "[$(date)] Hooks backed up: $(du -sh ${BACKUP_DIR}/pb_hooks | cut -f1)"
else
    echo "[$(date)] No hooks directory found"
fi

# 4. Create manifest file
cat > "${BACKUP_DIR}/manifest.json" << EOF
{
  "timestamp": "${TIMESTAMP}",
  "date": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "pb_version": "$(cat ${PB_DATA_DIR}/VERSION 2>/dev/null || echo 'unknown')",
  "backup_size": "$(du -sh ${BACKUP_DIR} | cut -f1)"
}
EOF

# 5. Compress backup
echo "[$(date)] Compressing backup..."
cd /tmp
tar czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
echo "[$(date)] Backup compressed: ${BACKUP_SIZE}"

# 6. Upload to Hetzner Storage Box via SFTP
echo "[$(date)] Uploading to Hetzner Storage Box..."
if command -v lftp &> /dev/null; then
    # Using lftp (more reliable for large files)
    lftp -e "
        set sftp:auto-confirm yes;
        set net:timeout 30;
        set net:max-retries 3;
        mkdir -p ${STORAGE_BOX_PATH};
        cd ${STORAGE_BOX_PATH};
        put ${BACKUP_NAME}.tar.gz;
        bye
    " sftp://${STORAGE_BOX_USER}@${STORAGE_BOX_HOST}
else
    # Fallback to scp
    scp -o StrictHostKeyChecking=no \
        "${BACKUP_NAME}.tar.gz" \
        "${STORAGE_BOX_USER}@${STORAGE_BOX_HOST}:${STORAGE_BOX_PATH}/"
fi

echo "[$(date)] Backup uploaded successfully"

# 7. Clean up local files
rm -rf "${BACKUP_DIR}"
rm -f "${BACKUP_NAME}.tar.gz"
echo "[$(date)] Local backup files cleaned up"

# 8. Apply retention policy (cleanup old backups)
echo "[$(date)] Applying retention policy..."
lftp -e "
    set sftp:auto-confirm yes;
    cd ${STORAGE_BOX_PATH};
    cls -1 --sort=date | head -n -${KEEP_DAILY} | xargs -r rm;
    bye
" sftp://${STORAGE_BOX_USER}@${STORAGE_BOX_HOST} || echo "Retention cleanup skipped"

echo "[$(date)] Backup completed: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE})"
echo "[$(date)] Location: ${STORAGE_BOX_HOST}:${STORAGE_BOX_PATH}/${BACKUP_NAME}.tar.gz"
