#!/bin/bash
export DISPLAY=:99
export HOME=/root
export WINEPREFIX=/data/wine
export WINEARCH=win64

echo "=============================="
echo " Startup Script v3"
echo "=============================="

# Wait for X server
echo "[1] Waiting for X server..."
for i in $(seq 1 30); do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "    X server ready after ${i}s"
        break
    fi
    sleep 1
done

# Set a background color so user can see desktop is working
DISPLAY=:99 xsetroot -solid '#2d2d2d' 2>/dev/null || true

# Open xterm immediately so user has something to work with
echo "[2] Opening terminal..."
DISPLAY=:99 xterm -bg '#1a1a1a' -fg '#00ff00' -fa 'Monospace' -fs 12 \
    -title "Windows Desktop - Terminal" \
    -geometry 100x30+10+10 \
    -e "bash --login" &

sleep 1

# Open file manager
echo "[3] Opening file manager..."
DISPLAY=:99 pcmanfm /root/workspace 2>/dev/null &

sleep 1

# Check Wine
echo "[4] Checking Wine..."
if wine --version 2>/dev/null; then
    echo "    Wine OK: $(wine --version)"
    
    # Init Wine prefix
    mkdir -p "$WINEPREFIX"
    if [ ! -f "$WINEPREFIX/system.reg" ]; then
        echo "    Initializing Wine prefix in background..."
        WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init 2>/dev/null &
        WINE_PID=$!
        
        # Show progress in xterm
        DISPLAY=:99 xterm -bg '#1a1a1a' -fg '#ffff00' \
            -title "Installing Wine Apps..." \
            -geometry 100x20+10+350 \
            -e "bash -c '
                echo \"Wine initializing... (this takes 2-3 min)\";
                wait $WINE_PID 2>/dev/null || true;
                echo \"Wine ready! Now downloading Chrome...\";
                wget -q -O /tmp/ChromeSetup.exe https://dl.google.com/chrome/install/latest/chrome_installer.exe;
                echo \"Installing Chrome...\";
                DISPLAY=:99 WINEPREFIX=/data/wine wine /tmp/ChromeSetup.exe /silent /install 2>&1 | head -20;
                echo \"Done! Chrome installed. Check desktop shortcuts.\";
                rm -f /tmp/ChromeSetup.exe;
                bash
            '" &
    else
        echo "    Wine prefix exists"
        
        # Launch Chrome if installed
        CHROME_EXE="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
        if [ -f "$CHROME_EXE" ]; then
            echo "[5] Starting Chrome..."
            DISPLAY=:99 wine "$CHROME_EXE" --no-sandbox --disable-gpu 2>/dev/null &
        else
            echo "[5] Chrome not installed - showing install terminal"
            DISPLAY=:99 xterm -bg '#1a1a1a' -fg '#ffff00' \
                -title "Install Chrome & Kiro" \
                -geometry 100x20+10+350 \
                -e "bash -c '
                    echo \"=== Install Apps ===\";
                    echo \"1. Click here and type: /app/scripts/install-apps.sh\";
                    echo \"   This will install Chrome and Kiro\";
                    echo \"\";
                    bash
                '" &
        fi
        
        # Launch Kiro if installed
        KIRO_EXE=$(find "$WINEPREFIX/drive_c/" -iname "kiro.exe" 2>/dev/null | head -1)
        if [ -n "$KIRO_EXE" ]; then
            echo "[6] Starting Kiro..."
            DISPLAY=:99 wine "$KIRO_EXE" 2>/dev/null &
        fi
    fi
else
    echo "    Wine not found!"
    DISPLAY=:99 xterm -bg '#1a1a1a' -fg '#ff0000' \
        -title "ERROR - Wine Not Found" \
        -geometry 80x10+10+350 \
        -e "bash -c 'echo Wine is not installed!; bash'" &
fi

# Create desktop shortcuts
mkdir -p /root/Desktop

# Install script shortcut
cat > /root/Desktop/install-apps.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Install Chrome & Kiro
Comment=Click to install Chrome and Kiro
Exec=xterm -e "/app/scripts/install-apps.sh; bash"
Icon=system-software-install
Terminal=false
EOF

cat > /root/Desktop/backup-panel.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Backup Panel
Exec=xdg-open http://localhost:8888
Icon=document-save
Terminal=false
EOF

chmod +x /root/Desktop/*.desktop 2>/dev/null || true

echo "=============================="
echo " Startup Complete v3!"
echo "=============================="

# Keep running to maintain process tree
wait
