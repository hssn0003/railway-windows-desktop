#!/bin/bash
set -e

# Railway sets PORT env variable
RAILWAY_PORT=${PORT:-8080}

echo "=============================="
echo " Windows Desktop on Railway"
echo " Port: $RAILWAY_PORT"
echo "=============================="

# Fix nginx port
sed -i "s/RAILWAY_PORT/${RAILWAY_PORT}/g" /etc/nginx/nginx.conf 2>/dev/null || true

# Install websockify and noVNC if not present
if ! python3 -m websockify --help >/dev/null 2>&1; then
    echo "Installing websockify..."
    pip3 install websockify -q
fi

if [ ! -d /opt/novnc ]; then
    echo "Installing noVNC..."
    mkdir -p /opt/novnc
    wget -qO /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz
    tar -xzf /tmp/novnc.tar.gz -C /opt/novnc --strip-components=1
    rm -f /tmp/novnc.tar.gz
    echo "noVNC installed at /opt/novnc"
fi

# Fix backup panel port
sed -i "s/PORT = 8080/PORT = 8888/g" /app/scripts/backup-panel-server.py 2>/dev/null || true

# Rewrite supervisord.conf with correct paths
cat > /etc/supervisor/conf.d/supervisord.conf << 'SUPEOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
user=root

[program:xvfb]
command=/usr/bin/Xvfb :99 -screen 0 1280x720x24 -nolisten tcp
autorestart=true
priority=100
stdout_logfile=/var/log/xvfb.log
stderr_logfile=/var/log/xvfb.log

[program:fluxbox]
command=/usr/bin/fluxbox -display :99
autorestart=true
priority=200
environment=DISPLAY=":99",HOME="/root"
stdout_logfile=/var/log/fluxbox.log
stderr_logfile=/var/log/fluxbox.log

[program:x11vnc]
command=/usr/bin/x11vnc -display :99 -forever -shared -rfbport 5900 -nopw -wait 50
autorestart=true
priority=300
stdout_logfile=/var/log/x11vnc.log
stderr_logfile=/var/log/x11vnc.log

[program:novnc]
command=/usr/bin/python3 -m websockify --web=/opt/novnc 6080 localhost:5900
autorestart=true
priority=400
stdout_logfile=/var/log/novnc.log
stderr_logfile=/var/log/novnc.log

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true
priority=450
stdout_logfile=/var/log/nginx_sup.log
stderr_logfile=/var/log/nginx_sup.log

[program:backup-panel]
command=/usr/bin/python3 /app/scripts/backup-panel-server.py
autorestart=true
priority=460
environment=HOME="/root"
stdout_logfile=/var/log/backup-panel.log
stderr_logfile=/var/log/backup-panel.log

[program:startup]
command=/app/scripts/startup.sh
autorestart=false
startsecs=0
priority=500
environment=DISPLAY=":99",HOME="/root"
stdout_logfile=/var/log/startup.log
stderr_logfile=/var/log/startup.log
SUPEOF

echo "supervisord.conf written with correct paths"

# Ensure log dirs
mkdir -p /var/log/supervisor /var/log/nginx

# Start everything
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
