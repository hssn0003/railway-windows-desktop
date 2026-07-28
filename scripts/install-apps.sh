#!/bin/bash
export DISPLAY=:99
export WINEPREFIX=/data/wine
export WINEARCH=win64
export HOME=/root

echo "=============================="
echo " Installing Apps via Wine"
echo "=============================="

# Install winetricks if missing
if ! command -v winetricks &>/dev/null; then
    wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        -O /usr/local/bin/winetricks
    chmod +x /usr/local/bin/winetricks
fi

# Install basic components
echo "Installing Wine components..."
winetricks -q corefonts 2>/dev/null || true

# Install Chrome
CHROME_EXE="$WINEPREFIX/drive_c/Program Files/Google/Chrome/Application/chrome.exe"
if [ ! -f "$CHROME_EXE" ]; then
    echo "Downloading Chrome..."
    wget -q -O /tmp/chrome_setup.exe \
        "https://dl.google.com/chrome/install/latest/chrome_installer.exe" || \
    wget -q -O /tmp/chrome_setup.exe \
        "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B6CD901F4-A884-3DE7-1E36-0E4D0C0BD3CF%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"

    echo "Installing Chrome..."
    wine /tmp/chrome_setup.exe /silent /install 2>/dev/null &
    sleep 20
    rm -f /tmp/chrome_setup.exe
fi

# Install Kiro
KIRO_EXE=$(find $WINEPREFIX/drive_c/ -iname "kiro.exe" 2>/dev/null | head -1)
if [ -z "$KIRO_EXE" ]; then
    echo "Downloading Kiro..."
    # Try multiple download URLs
    KIRO_URLS=(
        "https://download.kiro.dev/latest/KiroSetup.exe"
        "https://kiro.dev/downloads/windows/latest"
        "https://releases.kiro.dev/latest/KiroSetup.exe"
    )
    DOWNLOADED=false
    for url in "${KIRO_URLS[@]}"; do
        if wget -q --timeout=60 -O /tmp/KiroSetup.exe "$url" 2>/dev/null; then
            if [ -s /tmp/KiroSetup.exe ]; then
                DOWNLOADED=true
                break
            fi
        fi
    done

    if [ "$DOWNLOADED" = true ]; then
        echo "Installing Kiro..."
        wine /tmp/KiroSetup.exe /S 2>/dev/null &
        sleep 20
        rm -f /tmp/KiroSetup.exe
    else
        echo "WARNING: Could not download Kiro. Please install manually."
        echo "Download from: https://kiro.dev/downloads/"
    fi
fi

echo "=============================="
echo " Installation Done!"
echo "=============================="
ls "$WINEPREFIX/drive_c/Program Files/" 2>/dev/null || echo "Wine dir empty"
