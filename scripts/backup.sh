#!/bin/bash
set -e

echo "================================================"
echo "Creating Backup..."
echo "================================================"

BACKUP_DIR="/data/backup"
BACKUP_FILE="$BACKUP_DIR/wine-backup.tar.gz"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE_DATED="$BACKUP_DIR/wine-backup-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Backing up Wine prefix and configurations..."

# Create backup archive
tar -czf "$BACKUP_FILE" \
    -C /root \
    .wine \
    .fluxbox \
    Desktop \
    2>/dev/null || true

# Also create a dated backup
cp "$BACKUP_FILE" "$BACKUP_FILE_DATED"

echo "================================================"
echo "Backup completed!"
echo "Main backup: $BACKUP_FILE"
echo "Dated backup: $BACKUP_FILE_DATED"
echo "Backup size: $(du -h $BACKUP_FILE | cut -f1)"
echo "================================================"

# List all backups
echo "Available backups:"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "No backups found"
