#!/bin/bash
set -e

echo "================================================"
echo "Backup to FTP Server"
echo "================================================"

# Check if FTP credentials are set
if [ -z "$FTP_HOST" ]; then
    echo "ERROR: FTP_HOST environment variable not set!"
    exit 1
fi

if [ -z "$FTP_USER" ]; then
    echo "ERROR: FTP_USER environment variable not set!"
    exit 1
fi

if [ -z "$FTP_PASS" ]; then
    echo "ERROR: FTP_PASS environment variable not set!"
    exit 1
fi

# Create backup first
echo "Creating backup..."
/app/scripts/backup.sh

BACKUP_FILE="/data/backup/wine-backup.tar.gz"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FTP_PATH="${FTP_PATH:-/backups}"

echo "Uploading to FTP server..."
echo "Host: $FTP_HOST"
echo "User: $FTP_USER"
echo "Path: $FTP_PATH"

# Upload using lftp
lftp -c "
set ftp:ssl-allow no;
open -u $FTP_USER,$FTP_PASS $FTP_HOST;
mkdir -p $FTP_PATH;
cd $FTP_PATH;
put $BACKUP_FILE -o backup-${TIMESTAMP}.tar.gz;
put $BACKUP_FILE -o latest-backup.tar.gz;
bye
"

if [ $? -eq 0 ]; then
    echo "================================================"
    echo "Backup uploaded to FTP successfully!"
    echo "================================================"
else
    echo "ERROR: Failed to upload to FTP"
    exit 1
fi
