#!/bin/bash
set -e

# Railway sets PORT env variable
RAILWAY_PORT=${PORT:-8080}

echo "=============================="
echo " Windows Desktop on Railway"
echo " Port: $RAILWAY_PORT"
echo "=============================="

# Fix nginx port
sed -i "s/RAILWAY_PORT/${RAILWAY_PORT}/g" /etc/nginx/nginx.conf

# Fix backup panel internal port
sed -i "s/PORT = 8080/PORT = 8888/g" /app/scripts/backup-panel-server.py 2>/dev/null || true

# Ensure log dir
mkdir -p /var/log/supervisor /var/log/nginx

# Start everything via supervisor
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
