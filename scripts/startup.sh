#!/bin/bash
export DISPLAY=:99
export HOME=/root
export WINEPREFIX=/data/wine
export WINEARCH=win64

echo "=============================="
echo " Startup Script v2"
echo "=============================="

# Wait for Xvfb
echo "[1] Waiting for X server..."
for i in $(seq 1 30); do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "    X server ready after ${i}s"
        break
    fi
    sleep 1
done

# Restore from GitHub backup if available
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "[2] Checking GitHub for backup..."
    /app/scripts/restore-from-github.sh 2>/dev/null && \
        echo "    Backup restored!" || \
        echo "    No backup found"
fi

# Create wine prefix dir
mkdir -p "$WINEPREFIX"

# Init Wine prefix if needed
if [ ! -f "$WINEPREFIX/system.reg" ]; then
    echo "[3] Initializing Wine prefix (may take 2-3 min)..."
    WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init 2>/dev/null
    sleep 10
    echo "    Wine initialized"
else
    echo "[3] Wine prefix exists, skipping init"
fi

# Install Chrome if missing
CHROME_EXE="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
if [ ! -f "$CHROME_EXE" ]; then
    echo "[4] Downloading Chrome..."
    wget -q -O /tmp/ChromeSetup.exe \
        "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    if [ -s /tmp/ChromeSetup.exe ]; then
        echo "    Installing Chrome..."
        wine /tmp/ChromeSetup.exe /silent /install 2>/dev/null
        sleep 15
        rm -f /tmp/ChromeSetup.exe
        echo "    Chrome installed"
    else
        echo "    Chrome download failed"
    fi
else
    echo "[4] Chrome already installed"
fi

# Install Kiro if missing
KIRO_EXE=$(find "$WINEPREFIX/drive_c/" -iname "kiro.exe" 2>/dev/null | head -1)
if [ -z "$KIRO_EXE" ]; then
    echo "[5] Downloading Kiro..."
    # Try to get download URL from kiro.dev
    KIRO_URL=$(curl -sL "https://kiro.dev/downloads/" | grep -o 'https://[^"]*\.exe' | head -1)
    if [ -n "$KIRO_URL" ]; then
        wget -q -O /tmp/KiroSetup.exe "$KIRO_URL"
    else
        wget -q -O /tmp/KiroSetup.exe "https://download.kiro.dev/latest/windows/KiroSetup.exe" 2>/dev/null || true
    fi
    if [ -s /tmp/KiroSetup.exe ]; then
        echo "    Installing Kiro..."
        wine /tmp/KiroSetup.exe /S 2>/dev/null || wine /tmp/KiroSetup.exe /silent 2>/dev/null || true
        sleep 15
        rm -f /tmp/KiroSetup.exe
        echo "    Kiro install done"
    else
        echo "    WARNING: Kiro download failed - download manually from kiro.dev"
    fi
else
    echo "[5] Kiro already installed at: $KIRO_EXE"
fi

# Create desktop shortcuts
echo "[6] Creating desktop shortcuts..."
mkdir -p /root/Desktop

cat > /root/Desktop/chrome.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Google Chrome
Exec=bash -c "DISPLAY=:99 WINEPREFIX=/data/wine wine '/data/wine/drive_c/Program Files/Google/Chrome/Application/chrome.exe' 2>/dev/null"
Icon=chromium-browser
Terminal=false
EOF

cat > /root/Desktop/kiro.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Kiro IDE
Exec=bash -c "DISPLAY=:99 WINEPREFIX=/data/wine wine \$(find /data/wine/drive_c -iname 'kiro.exe' 2>/dev/null | head -1) 2>/dev/null"
Icon=applications-development
Terminal=false
EOF

cat > /root/Desktop/filemanager.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=File Manager
Exec=pcmanfm /root/workspace
Icon=system-file-manager
Terminal=false
EOF

cat > /root/Desktop/backup.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Backup Panel
Exec=bash -c "DISPLAY=:99 xdg-open http://localhost:8888 2>/dev/null || xterm -e 'echo Backup Panel at http://localhost:8888' &"
Icon=document-save
Terminal=false
EOF

chmod +x /root/Desktop/*.desktop 2>/dev/null || true

# Launch File Manager
echo "[7] Starting File Manager..."
DISPLAY=:99 pcmanfm /root/workspace 2>/dev/null &
sleep 2

# Launch Chrome
CHROME_EXE="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
if [ -f "$CHROME_EXE" ]; then
    echo "[8] Starting Chrome..."
    DISPLAY=:99 WINEPREFIX=/data/wine wine "$CHROME_EXE" --no-sandbox --disable-gpu 2>/dev/null &
    sleep 3
else
    echo "[8] Chrome not found - opening xterm instead..."
    DISPLAY=:99 xterm -title "Install Apps" -e "bash -c 'echo Chrome not installed. Run install script.; bash'" &
fi

# Launch Kiro
KIRO_EXE=$(find "$WINEPREFIX/drive_c/" -iname "kiro.exe" 2>/dev/null | head -1)
if [ -n "$KIRO_EXE" ]; then
    echo "[9] Starting Kiro from: $KIRO_EXE"
    DISPLAY=:99 WINEPREFIX=/data/wine wine "$KIRO_EXE" 2>/dev/null &
else
    echo "[9] Kiro not found - showing terminal..."
    DISPLAY=:99 xterm -title "Kiro - Not Installed" -geometry 80x20+50+50 -e "bash -c 'echo \"Kiro not installed yet.\"; echo \"Visit kiro.dev/downloads\"; bash'" &
fi

echo "=============================="
echo " Startup Complete!"
echo "=============================="
echo " Chrome: $CHROME_EXE"
echo " Kiro: $KIRO_EXE"
echo "=============================="
