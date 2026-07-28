#!/bin/bash
set -e

echo "================================================"
echo "Backup to GitHub"
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

# Create backup first
echo "Creating backup..."
/app/scripts/backup.sh

BACKUP_FILE="/data/backup/wine-backup.tar.gz"
BACKUP_DIR="/tmp/github-backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Clone or update repository
if [ ! -d "$BACKUP_DIR/.git" ]; then
    echo "Cloning GitHub repository..."
    rm -rf "$BACKUP_DIR"
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" "$BACKUP_DIR" || {
        echo "Creating new repository directory..."
        mkdir -p "$BACKUP_DIR"
        cd "$BACKUP_DIR"
        git init
        git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git"
    }
else
    echo "Updating existing repository..."
    cd "$BACKUP_DIR"
    git pull origin main || git pull origin master || true
fi

cd "$BACKUP_DIR"

# Configure git
git config user.email "backup@railway.app"
git config user.name "Railway Backup Bot"

# Create backups directory
mkdir -p backups

# Copy backup file
echo "Copying backup file..."
cp "$BACKUP_FILE" "backups/backup-${TIMESTAMP}.tar.gz"
cp "$BACKUP_FILE" "backups/latest-backup.tar.gz"

# Create backup info
cat > "backups/backup-info.json" <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "date": "$(date)",
  "backup_file": "latest-backup.tar.gz",
  "size": "$(stat -f%z "$BACKUP_FILE" 2>/dev/null || stat -c%s "$BACKUP_FILE")"
}
EOF

# Commit and push
echo "Committing to GitHub..."
git add backups/
git commit -m "Backup: ${TIMESTAMP}" || echo "No changes to commit"

echo "Pushing to GitHub..."
git push -u origin main || git push -u origin master || {
    echo "Creating new branch and pushing..."
    git checkout -b main
    git push -u origin main
}

echo "================================================"
echo "Backup uploaded to GitHub successfully!"
echo "Repository: https://github.com/${GITHUB_REPO}"
echo "================================================"
