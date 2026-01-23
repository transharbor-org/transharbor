#!/bin/bash
# Restore PocketBase backup from S3
# Downloads, decrypts, and restores encrypted S3 backup

set -e

echo "PocketBase S3 Backup Restore"
echo "============================="
echo

# Prompt for environment
read -p "Environment (dev/staging/prod): " ENVIRONMENT
NAMESPACE="transharbor"

echo
echo "Fetching S3 credentials from Kubernetes..."
S3_ENDPOINT=$(kubectl get secret pocketbase-s3-backup -n $NAMESPACE -o jsonpath='{.data.S3_ENDPOINT}' | base64 -d)
S3_BUCKET=$(kubectl get secret pocketbase-s3-backup -n $NAMESPACE -o jsonpath='{.data.S3_BUCKET}' | base64 -d)
AWS_ACCESS_KEY_ID=$(kubectl get secret pocketbase-s3-backup -n $NAMESPACE -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 -d)
AWS_SECRET_ACCESS_KEY=$(kubectl get secret pocketbase-s3-backup -n $NAMESPACE -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 -d)

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

echo "S3 Endpoint: $S3_ENDPOINT"
echo "S3 Bucket: $S3_BUCKET"
echo

echo "Available backups:"
aws s3 ls "s3://${S3_BUCKET}/pocketbase/" --endpoint-url="$S3_ENDPOINT" | tail -20

echo
read -p "Enter backup filename to restore: " BACKUP_FILE

if [ -z "$BACKUP_FILE" ]; then
    echo "Error: No filename provided"
    exit 1
fi

echo
echo "Downloading backup..."
TEMP_DIR=$(mktemp -d)
aws s3 cp "s3://${S3_BUCKET}/pocketbase/${BACKUP_FILE}" \
  "${TEMP_DIR}/${BACKUP_FILE}" \
  --endpoint-url="$S3_ENDPOINT"

echo
read -sp "Encryption Password: " ENCRYPTION_PASSWORD
echo

echo
echo "Decrypting backup..."
echo "$ENCRYPTION_PASSWORD" | gpg --batch --yes --passphrase-fd 0 \
  --decrypt -o "${TEMP_DIR}/restored.db" "${TEMP_DIR}/${BACKUP_FILE}"

rm "${TEMP_DIR}/${BACKUP_FILE}"

echo
echo "Backup decrypted successfully!"
echo "Size: $(du -h ${TEMP_DIR}/restored.db | cut -f1)"
echo

# Option 1: Copy to pod
read -p "Restore to pod now? This will stop PocketBase temporarily (y/N): " CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    echo
    echo "Scaling down PocketBase..."
    kubectl scale deployment pocketbase-${ENVIRONMENT} -n $NAMESPACE --replicas=0
    
    echo "Waiting for pod termination..."
    kubectl wait --for=delete pod -l app=pocketbase,env=${ENVIRONMENT} -n $NAMESPACE --timeout=60s || true
    
    echo "Creating restore job..."
    kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: pocketbase-restore-$(date +%s)
  namespace: $NAMESPACE
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: restore
        image: alpine:3.18
        command:
        - sh
        - -c
        - |
          echo "Backing up current database..."
          cp /pb_data/data.db /pb_data/data.db.before-restore || true
          echo "Restoring database..."
          cp /restore/restored.db /pb_data/data.db
          echo "Setting permissions..."
          chmod 644 /pb_data/data.db
          echo "Restore complete!"
        volumeMounts:
        - name: data
          mountPath: /pb_data
        - name: restore
          mountPath: /restore
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: pocketbase-data-${ENVIRONMENT}
      - name: restore
        configMap:
          name: pocketbase-restore-data
EOF
    
    echo "Creating ConfigMap with restore data..."
    kubectl create configmap pocketbase-restore-data -n $NAMESPACE \
      --from-file=restored.db="${TEMP_DIR}/restored.db" \
      --dry-run=client -o yaml | kubectl apply -f -
    
    echo "Waiting for restore job..."
    kubectl wait --for=condition=complete job -l job-name --timeout=120s -n $NAMESPACE || true
    
    echo "Scaling up PocketBase..."
    kubectl scale deployment pocketbase-${ENVIRONMENT} -n $NAMESPACE --replicas=1
    
    echo "Cleaning up..."
    kubectl delete configmap pocketbase-restore-data -n $NAMESPACE || true
    
    echo
    echo "✅ Database restored successfully!"
else
    echo
    echo "Decrypted backup saved to: ${TEMP_DIR}/restored.db"
    echo
    echo "To restore manually:"
    echo "  1. Copy to pod: kubectl cp ${TEMP_DIR}/restored.db transharbor/\$POCKETBASE_POD:/pb_data/data.db"
    echo "  2. Restart pod: kubectl rollout restart deployment/pocketbase-${ENVIRONMENT} -n $NAMESPACE"
fi

echo
echo "Done!"
