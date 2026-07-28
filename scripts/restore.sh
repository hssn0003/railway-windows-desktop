#!/bin/bash
set -e

echo "================================================"
echo "Restoring from Backup..."
echo "================================================"

BACKUP_DIR="/data/backup"
BACKUP_FILE="$BACKUP_DIR/wine-backup.tar.gz"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found at $BACKUP_FILE"
    echo "Available backups:"
    ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

echo "Restoring from: $BACKUP_FILE"
echo "Backup size: $(du -h $BACKUP_FILE | cut -f1)"

# Extract backup
tar -xzf "$BACKUP_FILE" -C /root

echo "================================================"
echo "Restore completed successfully!"
echo "================================================"
