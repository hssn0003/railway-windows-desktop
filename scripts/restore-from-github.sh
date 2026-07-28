#!/bin/bash
set -e

echo "================================================"
echo "Restore from GitHub"
echo "================================================"

# Check if GitHub token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_TOKEN environment variable not set!"
    echo "Please set it in Railway Variables"
    exit 1
fi

if [ -z "$GITHUB_REPO" ]; then
    echo "ERROR: GITHUB_REPO environment variable not set!"
    echo "Example: username/repo-name"
    exit 1
fi

BACKUP_DIR="/tmp/github-backup"
RESTORE_FILE="/data/backup/wine-backup.tar.gz"

# Clone repository
echo "Cloning GitHub repository..."
rm -rf "$BACKUP_DIR"
git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" "$BACKUP_DIR" || {
    echo "ERROR: Failed to clone repository"
    exit 1
}

# Check if backup exists
if [ ! -f "$BACKUP_DIR/backups/latest-backup.tar.gz" ]; then
    echo "ERROR: No backup found in repository"
    echo "Available files:"
    ls -la "$BACKUP_DIR/backups/" || echo "Backups directory not found"
    exit 1
fi

# Copy backup file
echo "Copying backup from GitHub..."
mkdir -p /data/backup
cp "$BACKUP_DIR/backups/latest-backup.tar.gz" "$RESTORE_FILE"

echo "Backup info:"
cat "$BACKUP_DIR/backups/backup-info.json" 2>/dev/null || echo "No backup info available"

# Restore
echo "Restoring backup..."
/app/scripts/restore.sh

echo "================================================"
echo "Restore from GitHub completed successfully!"
echo "================================================"
