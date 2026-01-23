#!/bin/bash
# PocketBase Performance Tuning
# Optimizes SQLite and connection settings for minimal resources

set -e

POCKETBASE_POD=$(kubectl get pods -n transharbor -l app=pocketbase -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POCKETBASE_POD" ]; then
    echo "Error: PocketBase pod not found"
    exit 1
fi

echo "Optimizing PocketBase in pod: ${POCKETBASE_POD}"

# Create optimization script
cat > /tmp/optimize-pocketbase.sh << 'SCRIPT'
#!/bin/sh
# SQLite performance optimizations for PocketBase
# Run inside PocketBase pod

DB_PATH="/app/pb_data/data.db"

if [ ! -f "$DB_PATH" ]; then
    echo "Database not found at $DB_PATH"
    exit 1
fi

echo "Applying SQLite optimizations..."

# Apply PRAGMAs for performance
sqlite3 "$DB_PATH" << 'SQL'
-- WAL mode for better concurrency
PRAGMA journal_mode=WAL;

-- Synchronous=NORMAL is safe with WAL and much faster
PRAGMA synchronous=NORMAL;

-- Increase cache size to 4MB (default is ~2MB)
PRAGMA cache_size=-4000;

-- Memory-mapped I/O for faster reads
PRAGMA mmap_size=268435456;

-- Optimize temp storage
PRAGMA temp_store=MEMORY;

-- Auto-vacuum to prevent fragmentation
PRAGMA auto_vacuum=INCREMENTAL;

-- Analyze for query optimization
ANALYZE;

-- Show current settings
PRAGMA journal_mode;
PRAGMA synchronous;
PRAGMA cache_size;
PRAGMA mmap_size;
PRAGMA temp_store;
PRAGMA auto_vacuum;
SQL

echo "SQLite optimizations applied!"
echo
echo "Current database stats:"
sqlite3 "$DB_PATH" "PRAGMA page_count; PRAGMA page_size; PRAGMA freelist_count;"
SCRIPT

# Copy script to pod
kubectl cp /tmp/optimize-pocketbase.sh transharbor/${POCKETBASE_POD}:/tmp/optimize.sh

# Make executable and run
kubectl exec -n transharbor "$POCKETBASE_POD" -- sh -c "chmod +x /tmp/optimize.sh && /tmp/optimize.sh"

# Clean up
rm /tmp/optimize-pocketbase.sh
kubectl exec -n transharbor "$POCKETBASE_POD" -- rm /tmp/optimize.sh

echo
echo "PocketBase optimization complete!"
echo
echo "Recommended: Restart PocketBase pod to apply all settings"
echo "  kubectl rollout restart deployment/pocketbase-dev -n transharbor"
