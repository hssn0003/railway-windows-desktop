#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess, json, os
from urllib.parse import parse_qs, urlparse

PORT = 8888

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args): pass

    def send_json(self, data, code=200):
        body = json.dumps(data).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(self.html().encode('utf-8'))

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length).decode()
        params = parse_qs(body)
        action = params.get('action', [''])[0]

        scripts = {
            'backup_local':    '/app/scripts/backup.sh',
            'backup_github':   '/app/scripts/backup-to-github.sh',
            'backup_ftp':      '/app/scripts/backup-to-ftp.sh',
            'restore_local':   '/app/scripts/restore.sh',
            'restore_github':  '/app/scripts/restore-from-github.sh',
        }

        if action in scripts:
            try:
                result = subprocess.run(
                    scripts[action], shell=True,
                    capture_output=True, text=True, timeout=120
                )
                ok = result.returncode == 0
                msg = result.stdout if ok else result.stderr
                self.send_json({'success': ok, 'message': msg or ('Done!' if ok else 'Failed')})
            except Exception as e:
                self.send_json({'success': False, 'message': str(e)})
        else:
            self.send_json({'success': False, 'message': 'Unknown action'}, 400)

    def html(self):
        return '''<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>پنل Backup</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:Tahoma,Arial,sans-serif;background:#1a1a2e;color:#eee;min-height:100vh;padding:20px}
  .wrap{max-width:700px;margin:0 auto}
  h1{text-align:center;color:#e94560;margin:20px 0 10px;font-size:28px}
  .sub{text-align:center;color:#888;margin-bottom:30px;font-size:13px}
  .card{background:#16213e;border-radius:12px;padding:25px;margin-bottom:20px;border:1px solid #0f3460}
  .card h2{color:#e94560;margin-bottom:15px;font-size:18px}
  .btns{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px}
  button{padding:13px 20px;border:none;border-radius:8px;font-size:15px;cursor:pointer;font-family:inherit;transition:all .2s;color:#fff;font-weight:bold}
  .b-local{background:#27ae60}.b-local:hover{background:#2ecc71;transform:translateY(-2px)}
  .b-gh{background:#24292e}.b-gh:hover{background:#333;transform:translateY(-2px)}
  .b-ftp{background:#e67e22}.b-ftp:hover{background:#f39c12;transform:translateY(-2px)}
  .b-res{background:#2980b9}.b-res:hover{background:#3498db;transform:translateY(-2px)}
  button:disabled{opacity:.5;cursor:not-allowed;transform:none!important}
  #result{margin-top:20px;padding:15px;border-radius:8px;display:none;white-space:pre-wrap;font-size:13px;line-height:1.6}
  .ok{background:#1a4a2a;border:1px solid #27ae60;color:#2ecc71}
  .err{background:#4a1a1a;border:1px solid #e74c3c;color:#e74c3c}
  .loading{background:#2a2a1a;border:1px solid #f39c12;color:#f1c40f}
  .info{background:#0f2a3a;border:1px solid #2980b9;padding:15px;border-radius:8px;font-size:12px;color:#7fb3d3;line-height:1.8}
</style>
</head>
<body>
<div class="wrap">
  <h1>🔧 پنل مدیریت Backup</h1>
  <p class="sub">مدیریت پشتیبان‌گیری و بازیابی • Windows Desktop Environment</p>

  <div class="card">
    <h2>📦 ایجاد Backup</h2>
    <div class="btns">
      <button class="b-local" onclick="act('backup_local')">💾 Backup محلی</button>
      <button class="b-gh" onclick="act('backup_github')">🐙 Backup → GitHub</button>
      <button class="b-ftp" onclick="act('backup_ftp')">📤 Backup → FTP</button>
    </div>
  </div>

  <div class="card">
    <h2>♻️ بازیابی Backup</h2>
    <div class="btns">
      <button class="b-res" onclick="act('restore_local')">📥 بازیابی محلی</button>
      <button class="b-res b-gh" onclick="act('restore_github')" style="background:#6f42c1">📥 بازیابی از GitHub</button>
    </div>
  </div>

  <div id="result"></div>

  <div class="info">
    <strong>راهنما:</strong><br>
    • <b>Backup محلی</b>: ذخیره در <code>/data/backup</code><br>
    • <b>GitHub</b>: نیاز به متغیر <code>GITHUB_TOKEN</code> و <code>GITHUB_REPO</code> در Railway<br>
    • <b>FTP</b>: نیاز به <code>FTP_HOST</code>, <code>FTP_USER</code>, <code>FTP_PASS</code><br>
    • هنگام راه‌اندازی مجدد، backup از GitHub به صورت خودکار restore می‌شود
  </div>
</div>
<script>
async function act(a){
  const r=document.getElementById('result');
  const btns=document.querySelectorAll('button');
  btns.forEach(b=>b.disabled=true);
  r.className='loading'; r.style.display='block';
  r.textContent='در حال انجام... لطفاً صبر کنید ⏳';
  try{
    const res=await fetch('/',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action='+a});
    const d=await res.json();
    r.className=d.success?'ok':'err';
    r.textContent=(d.success?'✅ ':'❌ ')+(d.message||'');
  }catch(e){
    r.className='err'; r.textContent='❌ خطا: '+e.message;
  }finally{btns.forEach(b=>b.disabled=false);}
}
</script>
</body>
</html>'''

if __name__ == '__main__':
    print(f'Backup Panel running on port {PORT}')
    HTTPServer(('0.0.0.0', PORT), Handler).serve_forever()
