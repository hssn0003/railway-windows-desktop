#!/bin/bash
export DISPLAY=:99
export HOME=/root
export WINEPREFIX=/data/wine
export WINEARCH=win64

echo '====== Startup v5 ======'

# Wait for X
for i in $(seq 1 20); do
    xdpyinfo -display :99 >/dev/null 2>&1 && break
    sleep 1
done

xsetroot -solid '#1e1e2e' 2>/dev/null || true

# Create executable shell scripts on Desktop
mkdir -p /root/Desktop

cat > /root/Desktop/chrome.sh << 'EOF'
#!/bin/bash
export DISPLAY=:99
export WINEPREFIX=/data/wine
CHROME="/data/wine/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
if [ -f "$CHROME" ]; then
    wine "$CHROME" --no-sandbox --disable-gpu 2>/dev/null &
else
    xterm -e "echo Chrome not found; echo Run install-apps.sh first; sleep 5" &
fi
EOF
chmod +x /root/Desktop/chrome.sh

cat > /root/Desktop/kiro.sh << 'EOF'
#!/bin/bash
export DISPLAY=:99
export WINEPREFIX=/data/wine
KIRO=$(find /data/wine/drive_c/ -iname "kiro.exe" 2>/dev/null | head -1)
if [ -n "$KIRO" ]; then
    wine "$KIRO" 2>/dev/null &
else
    xterm -e "echo Kiro not installed; echo Open Chrome and go to kiro.dev/downloads; sleep 10" &
fi
EOF
chmod +x /root/Desktop/kiro.sh

cat > /root/Desktop/install.sh << 'EOF'
#!/bin/bash
export DISPLAY=:99
export WINEPREFIX=/data/wine
export HOME=/root
bash /app/scripts/install-apps.sh
EOF
chmod +x /root/Desktop/install.sh

# Open xterm
xterm -bg '#1e1e2e' -fg '#cdd6f4' -fa 'Monospace' -fs 12 \
    -title 'Terminal' -geometry 85x22+10+10 &

sleep 1

# Open file manager on desktop
pcmanfm /root/Desktop 2>/dev/null &

sleep 2

# Auto start Chrome if installed
CHROME="/data/wine/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
if [ -f "$CHROME" ]; then
    echo 'Chrome found, starting...'
    wine "$CHROME" --no-sandbox --disable-gpu 2>/dev/null &
    sleep 3
fi

# Auto start Kiro if installed
KIRO=$(find /data/wine/drive_c/ -iname "kiro.exe" 2>/dev/null | head -1)
if [ -n "$KIRO" ]; then
    echo "Kiro found at $KIRO, starting..."
    wine "$KIRO" 2>/dev/null &
fi

echo 'Startup v5 complete'
wait
