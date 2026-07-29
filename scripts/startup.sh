#!/bin/bash
export DISPLAY=:99
export HOME=/root
export WINEPREFIX=/data/wine
export WINEARCH=win64
export PATH=$PATH:/usr/bin:/bin

echo "====== Startup v4 ======"

# Wait for X
for i in $(seq 1 20); do
    xdpyinfo -display :99 >/dev/null 2>&1 && break
    sleep 1
done
echo "X ready"

# Dark background
xsetroot -solid '#1e1e2e' 2>/dev/null || true

# Open xterm right away
xterm -bg '#1e1e2e' -fg '#cdd6f4' -fa 'Monospace' -fs 11 \
    -title "Terminal" -geometry 90x25+20+20 &

# Open file manager
pcmanfm /root/workspace 2>/dev/null &

# Setup Wine and apps in background xterm so user can see progress
xterm -bg '#1e1e2e' -fg '#a6e3a1' -fa 'Monospace' -fs 10 \
    -title "Setup - Wine & Apps" -geometry 90x20+20+400 \
    -e bash -c '
        export DISPLAY=:99
        export WINEPREFIX=/data/wine
        export WINEARCH=win64
        export HOME=/root

        echo "=== Setting up Wine and Apps ==="
        echo ""

        # Init Wine
        if [ ! -f "$WINEPREFIX/system.reg" ]; then
            echo ">> Initializing Wine prefix..."
            WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init 2>&1 | grep -v "^0009:" | head -5
            sleep 5
            echo ">> Wine ready!"
        else
            echo ">> Wine prefix exists"
        fi

        # Check Chrome
        CHROME="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
        if [ ! -f "$CHROME" ]; then
            echo ">> Downloading Chrome..."
            wget -q --show-progress -O /tmp/ChromeSetup.exe \
                "https://dl.google.com/chrome/install/latest/chrome_installer.exe" 2>&1
            echo ">> Installing Chrome..."
            wine /tmp/ChromeSetup.exe /silent /install 2>&1 | grep -v "^0009:" | head -10
            sleep 10
            rm -f /tmp/ChromeSetup.exe
            echo ">> Chrome done!"
        else
            echo ">> Chrome already installed"
            echo ">> Starting Chrome..."
            wine "$CHROME" --no-sandbox --disable-gpu 2>/dev/null &
        fi

        # Check Kiro
        KIRO=$(find $WINEPREFIX/drive_c/ -iname "kiro.exe" 2>/dev/null | head -1)
        if [ -z "$KIRO" ]; then
            echo ""
            echo ">> Kiro not found."
            echo ">> Please download Kiro from: https://kiro.dev/downloads/"
            echo ">> Then open Chrome and download the Windows installer"
            echo ">> Save to Desktop and double-click to install via Wine"
        else
            echo ">> Starting Kiro: $KIRO"
            wine "$KIRO" 2>/dev/null &
        fi

        echo ""
        echo "=== Setup Complete ==="
        echo "Press Enter to close this window..."
        read
    ' &

# Create right-click menu for fluxbox
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/menu << 'MENU'
[begin] (Desktop Menu)
[exec] (Terminal) {xterm -bg '#1e1e2e' -fg '#cdd6f4' -fa Monospace -fs 11}
[exec] (File Manager) {pcmanfm /root/workspace}
[exec] (Run Setup) {xterm -e /app/scripts/install-apps.sh}
[exec] (Backup Panel) {xterm -e "xdg-open http://localhost:8888 || echo Open: http://localhost:8888; read"}
[separator]
[exec] (Install Chrome) {xterm -e "wget -O /tmp/c.exe https://dl.google.com/chrome/install/latest/chrome_installer.exe && wine /tmp/c.exe /silent /install; read"}
[exec] (Open Chrome) {wine '/data/wine/drive_c/Program Files/Google/Chrome/Application/chrome.exe' --no-sandbox}
[end]
MENU

echo "Startup v4 done"
# Keep alive
wait
