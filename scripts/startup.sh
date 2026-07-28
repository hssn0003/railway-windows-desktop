#!/bin/bash
export DISPLAY=:99
export HOME=/root
export WINEPREFIX=/data/wine
export WINEARCH=win64

echo "=============================="
echo " Startup Script"
echo "=============================="

# Wait for Xvfb
echo "Waiting for X server..."
for i in $(seq 1 30); do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "X server ready!"
        break
    fi
    sleep 1
done

# Restore from GitHub backup if available
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "Checking GitHub for backup..."
    /app/scripts/restore-from-github.sh 2>/dev/null || echo "No backup found, starting fresh"
fi

# Init Wine if needed
if [ ! -f "$WINEPREFIX/system.reg" ]; then
    echo "Initializing Wine prefix..."
    wineboot --init 2>/dev/null &
    sleep 15
fi

# Install apps if not already installed
CHROME_EXE="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
KIRO_EXE=$(find $WINEPREFIX/drive_c/ -name "kiro.exe" -o -name "Kiro.exe" 2>/dev/null | head -1)

if [ ! -f "$CHROME_EXE" ] || [ -z "$KIRO_EXE" ]; then
    echo "Installing apps..."
    /app/scripts/install-apps.sh 2>&1 | tail -20
fi

# Create desktop shortcuts
mkdir -p /root/Desktop

cat > /root/Desktop/chrome.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Google Chrome
Exec=bash -c "DISPLAY=:99 wine 'C:/Program Files/Google/Chrome/Application/chrome.exe'"
Terminal=false
EOF

cat > /root/Desktop/kiro.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Kiro IDE
Exec=bash -c "DISPLAY=:99 WINEPREFIX=/data/wine wine 'C:/Program Files/Kiro/Kiro.exe'"
Terminal=false
EOF

cat > /root/Desktop/filemanager.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=File Manager
Exec=pcmanfm /root/workspace
Terminal=false
EOF

cat > /root/Desktop/backup.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Backup Panel
Exec=bash -c "DISPLAY=:99 firefox http://localhost:8888"
Terminal=false
EOF

chmod +x /root/Desktop/*.desktop 2>/dev/null || true

# Launch Chrome
CHROME_EXE="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
if [ -f "$CHROME_EXE" ]; then
    echo "Starting Chrome..."
    DISPLAY=:99 wine "$CHROME_EXE" --no-sandbox 2>/dev/null &
    sleep 3
fi

# Launch Kiro
KIRO_EXE=$(find $WINEPREFIX/drive_c/ -iname "kiro.exe" 2>/dev/null | head -1)
if [ -n "$KIRO_EXE" ]; then
    echo "Starting Kiro from: $KIRO_EXE"
    DISPLAY=:99 wine "$KIRO_EXE" 2>/dev/null &
fi

# Launch File Manager
DISPLAY=:99 pcmanfm /root/workspace 2>/dev/null &

echo "=============================="
echo " Startup Complete!"
echo "=============================="
