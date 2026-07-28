FROM ubuntu:22.04
ARG CACHEBUST=2026072802

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    VNC_PASSWORD=railway123 \
    WINEPREFIX=/data/wine \
    WINEARCH=win64 \
    HOME=/root

# Step 1: Base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl ca-certificates gnupg2 \
    xvfb x11vnc fluxbox xterm \
    supervisor net-tools \
    python3 python3-pip \
    git lftp nginx \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Install websockify and noVNC manually (not from apt - apt version is broken)
RUN pip3 install websockify \
    && mkdir -p /opt/novnc \
    && wget -qO /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz \
    && tar -xzf /tmp/novnc.tar.gz -C /opt/novnc --strip-components=1 \
    && rm /tmp/novnc.tar.gz \
    && ls /opt/novnc/

# Step 3: Wine
RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -qNP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && rm -rf /var/lib/apt/lists/*

# Step 4: Desktop tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    pcmanfm gedit \
    && rm -rf /var/lib/apt/lists/*

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

EXPOSE 8080
CMD ["/entrypoint.sh"]
