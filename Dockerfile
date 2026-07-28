FROM ubuntu:22.04
# Cache bust: v6-fresh-build

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    VNC_PASSWORD=railway123 \
    WINEPREFIX=/data/wine \
    WINEARCH=win64 \
    HOME=/root

# Step 1: Core tools + noVNC setup
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl ca-certificates gnupg2 \
    xvfb x11vnc fluxbox xterm \
    supervisor net-tools \
    python3 python3-pip \
    git lftp \
    nginx \
    novnc \
    && pip3 install websockify \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Wine
RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -qNP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && rm -rf /var/lib/apt/lists/*

# Step 3: Extra desktop tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    pcmanfm gedit \
    && rm -rf /var/lib/apt/lists/*

# Step 4: Verify websockify works and find novnc path
RUN which websockify && python3 -m websockify --help 2>&1 | head -3 || true
RUN ls /usr/share/novnc/ 2>/dev/null && echo "novnc found" || echo "novnc not in /usr/share"
RUN find / -name "vnc.html" 2>/dev/null | head -5 || echo "vnc.html not found"

# Step 5: App files
RUN mkdir -p /app/scripts /data/backup /data/wine /root/workspace /root/Desktop /var/log/supervisor

WORKDIR /app
COPY scripts/ /app/scripts/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /app/scripts/*.sh /entrypoint.sh

# Step 6: Fluxbox config
RUN mkdir -p /root/.fluxbox \
    && printf '[begin] (Menu)\n[exec] (Terminal) {xterm}\n[exec] (File Manager) {pcmanfm}\n[end]\n' > /root/.fluxbox/menu \
    && echo "session.screen0.toolbar.visible: false" > /root/.fluxbox/init

# Build timestamp to bust cache
RUN echo "Build: 2026-07-28-v5" > /build-info.txt

EXPOSE 8080
CMD ["/entrypoint.sh"]
