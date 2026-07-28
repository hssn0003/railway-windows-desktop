#!/bin/bash
set -e

echo "================================================"
echo "Configuring noVNC..."
echo "================================================"

# Create custom noVNC landing page with auto-connect
cat > /usr/share/novnc/vnc.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Windows Desktop - Kiro & Chrome</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background: #1a1a1a;
            font-family: Arial, sans-serif;
        }
        #header {
            background: #2d2d2d;
            color: #fff;
            padding: 15px 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }
        #header h1 {
            margin: 0;
            font-size: 20px;
            font-weight: normal;
        }
        #header p {
            margin: 5px 0 0 0;
            font-size: 12px;
            color: #aaa;
        }
        #screen {
            width: 100%;
            height: calc(100vh - 80px);
        }
        #status {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(45, 45, 45, 0.95);
            padding: 30px 50px;
            border-radius: 10px;
            color: #fff;
            text-align: center;
            z-index: 1000;
        }
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid #fff;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div id="header">
        <h1>🖥️ Windows Desktop Environment</h1>
        <p>Running: Google Chrome + Kiro IDE via Wine</p>
    </div>
    
    <div id="status">
        <div class="spinner"></div>
        <p>Connecting to desktop...</p>
    </div>
    
    <div id="screen"></div>

    <script type="module">
        import RFB from './core/rfb.js';

        const status = document.getElementById('status');
        const screen = document.getElementById('screen');

        // Auto-connect configuration
        const host = window.location.hostname;
        const port = window.location.port || 6080;
        const path = 'websockify';
        const url = `ws://${host}:${port}/${path}`;

        console.log('Connecting to:', url);

        try {
            const rfb = new RFB(screen, url, {
                credentials: { 
                    password: 'railway123'  // Auto-fill password
                }
            });

            // Event handlers
            rfb.addEventListener("connect", () => {
                console.log('Connected to VNC server');
                status.classList.add('hidden');
                rfb.scaleViewport = true;
                rfb.resizeSession = true;
            });

            rfb.addEventListener("disconnect", (e) => {
                console.log('Disconnected:', e.detail);
                status.classList.remove('hidden');
                status.innerHTML = '<div class="spinner"></div><p>Connection lost. Reconnecting...</p>';
                
                // Auto-reconnect after 3 seconds
                setTimeout(() => {
                    window.location.reload();
                }, 3000);
            });

            rfb.addEventListener("credentialsrequired", () => {
                console.log('Credentials required');
                // Password is auto-filled, but if needed:
                rfb.sendCredentials({ password: 'railway123' });
            });

        } catch (err) {
            console.error('Failed to connect:', err);
            status.innerHTML = '<p>❌ Connection failed</p><p>Please refresh the page</p>';
        }
    </script>
</body>
</html>
EOF

echo "Custom noVNC page created at /usr/share/novnc/vnc.html"
echo "================================================"
echo "noVNC Configuration Complete!"
echo "================================================"
