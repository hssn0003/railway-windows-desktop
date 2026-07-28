# 🖥️ محیط دسکتاپ ویندوز با Kiro و Chrome روی Railway

یک محیط دسکتاپ ویندوز کامل با **File Manager**، **Chrome**، **Kiro IDE** و **پنل Backup هوشمند** که از طریق مرورگر قابل دسترسی است!

## ✨ امکانات

- 🌐 **دسترسی از مرورگر**: به محیط دسکتاپ از هر مرورگری متصل شوید
- 💻 **Kiro IDE**: محیط توسعه AI از kiro.dev
- 🌐 **Google Chrome**: مرورگر کروم نصب شده
- 📁 **File Manager**: مدیریت فایل‌ها با PCManFM
- 🔥 **Firefox**: مرورگر پیش‌فرض لینوکس
- 📝 **Text Editor**: Gedit برای ویرایش فایل‌ها
- 💾 **پنل Backup**: رابط وب فارسی برای مدیریت backup
- 🔄 **GitHub Integration**: backup/restore خودکار از GitHub
- 📤 **FTP Upload**: آپلود backup به سرور FTP
- 🚀 **Auto Restore**: بازیابی خودکار از GitHub هنگام راه‌اندازی

---

## 🚀 راهنمای سریع (3 دقیقه!)

### 1️⃣ آپلود به GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

### 2️⃣ دیپلوی روی Railway

1. به [railway.app](https://railway.app) بروید
2. **New Project** → **Deploy from GitHub repo**
3. Repository خود را انتخاب کنید
4. منتظر build بمانید (5-10 دقیقه)

### 3️⃣ تنظیم متغیرهای محیطی

در داشبورد Railway، به **Variables** بروید و این متغیرها را اضافه کنید:

#### ✅ الزامی:
```
VNC_PASSWORD=railway123
```

#### 🔧 برای GitHub Backup (توصیه می‌شود):
```
GITHUB_TOKEN=ghp_your_token_here
GITHUB_REPO=username/repo-name
GIT_EMAIL=your@email.com
GIT_NAME=Your Name
```

**نحوه ساخت GitHub Token:**
1. به [github.com/settings/tokens](https://github.com/settings/tokens/new) بروید
2. **Generate new token (classic)** را کلیک کنید
3. نام بدهید و `repo` (full control) را انتخاب کنید
4. **Generate token** و کپی کنید

#### 📤 برای FTP Backup (اختیاری):
```
FTP_HOST=ftp.example.com
FTP_USER=username
FTP_PASS=password
FTP_PATH=/backups
```

### 4️⃣ فعال‌سازی Domain

1. در **Settings** → **Generate Domain**
2. URL شما: `https://your-app.railway.app`

---

## 🎯 دسترسی به محیط

پس از دیپلوی موفق، دو URL مهم دارید:

### 🖥️ دسکتاپ ویندوز:
```
https://your-app.railway.app/vnc.html
```
- رمز عبور: `railway123`
- دسترسی به Chrome، Kiro، File Manager

### 🛠️ پنل Backup (مهم!):
```
https://your-app.railway.app:8080
```
یا از داخل دسکتاپ، روی آیکون **Backup Panel** کلیک کنید

---

## 💾 سیستم Backup هوشمند

### پنل Backup
پنل وب فارسی با امکانات:

✅ **Backup محلی**: ذخیره در `/data/backup`  
✅ **Backup به GitHub**: آپلود خودکار به repository  
✅ **Backup به FTP**: آپلود به سرور FTP  
✅ **بازیابی محلی**: restore از فایل محلی  
✅ **بازیابی از GitHub**: pull آخرین backup

### نحوه استفاده:

1. **ایجاد Backup اول**:
   - به پنل Backup بروید (`https://your-app:8080`)
   - روی **"Backup به GitHub"** کلیک کنید
   - صبر کنید تا backup آپلود شود

2. **دیپلوی مجدد با Restore خودکار**:
   - پروژه جدید روی Railway بسازید
   - همان متغیرهای `GITHUB_TOKEN` و `GITHUB_REPO` را تنظیم کنید
   - کانتینر به طور خودکار آخرین backup را restore می‌کند! 🎉

3. **Backup دستی**:
```bash
railway run bash
/app/scripts/backup-to-github.sh
```

---

## 🔧 ساختار فایل‌ها در سیستم

```
/root/
├── .wine/              # محیط Wine (برنامه‌های ویندوز)
├── workspace/          # پوشه کاری شما (متصل به GitHub)
├── Desktop/            # دسکتاپ با shortcuts
└── .fluxbox/           # تنظیمات window manager

/data/backup/           # فایل‌های backup محلی
```

**نکته**: پوشه `/root/workspace` به طور خودکار با `GITHUB_REPO` شما sync می‌شود!

---

## 📋 Workflow توصیه شده

### برای توسعه روی Kiro:

1. **اولین بار**:
   - به دسکتاپ وصل شوید
   - Kiro و Chrome را باز کنید
   - از File Manager به `/root/workspace` بروید
   - کد خود را بنویسید

2. **ذخیره تغییرات**:
   - به پنل Backup بروید
   - **"Backup به GitHub"** را کلیک کنید
   - تمام تنظیمات و فایل‌ها backup می‌شوند

3. **استفاده در سیستم دیگر**:
   - یک Railway instance جدید بسازید
   - همان متغیرهای GitHub را تنظیم کنید
   - همه چیز بازیابی می‌شود!

---

## 🐛 عیب‌یابی

### کانتینر بالا نمی‌آید
```bash
railway logs
```

### Chrome یا Kiro اجرا نمی‌شود
```bash
railway run bash
/app/scripts/install-apps.sh
```

### Backup به GitHub کار نمی‌کند
- مطمئن شوید `GITHUB_TOKEN` معتبر است
- چک کنید که repository وجود دارد
- Token باید دسترسی `repo` داشته باشد

### دسترسی به File Manager
در دسکتاپ، روی آیکون **File Manager** کلیک کنید یا:
```bash
pcmanfm /root/workspace
```

---

## 📊 منابع مورد نیاز

- **RAM**: 2-4 GB
- **CPU**: 1-2 vCPU  
- **Storage**: 5-8 GB
- **Build Time**: 5-10 دقیقه
- **Startup Time**: 2-3 دقیقه

---

## 🔗 پورت‌ها

- **6080**: noVNC (دسکتاپ)
- **5900**: VNC مستقیم
- **8080**: پنل Backup

---

## 📝 دستورات مفید

### دسترسی به Terminal:
```bash
railway run bash
```

### مشاهده لاگ‌ها:
```bash
railway logs --follow
```

### Backup دستی:
```bash
railway run /app/scripts/backup-to-github.sh
```

### Restore دستی:
```bash
railway run /app/scripts/restore-from-github.sh
```

### لیست فایل‌های workspace:
```bash
railway run ls -la /root/workspace
```

---

## 🎯 نکات مهم

⚠️ **Backup منظم**: هر بار که کار مهمی انجام دادید، backup بگیرید!

⚠️ **GitHub Token**: هرگز token خود را share نکنید

⚠️ **Railway Free Tier**: محدودیت ساعت اجرا دارد

✅ **Auto Clone**: پروژه GitHub شما خودکار clone می‌شود

✅ **Auto Restore**: اولین باری که run می‌کنید، backup restore می‌شود

✅ **File Manager**: برای کپی/paste فایل‌ها استفاده کنید

---

## 🤝 ساختار پروژه

```
.
├── Dockerfile                      # Image اصلی
├── docker-compose.yml             # تست محلی
├── railway.json                   # کانفیگ Railway
├── supervisord.conf               # مدیریت سرویس‌ها
├── scripts/
│   ├── install-apps.sh           # نصب Chrome & Kiro
│   ├── startup.sh                # راه‌اندازی
│   ├── backup.sh                 # Backup محلی
│   ├── backup-to-github.sh       # Backup → GitHub
│   ├── backup-to-ftp.sh          # Backup → FTP
│   ├── restore.sh                # Restore محلی
│   ├── restore-from-github.sh    # Restore از GitHub
│   ├── backup-panel-server.py    # وب سرور پنل Backup
│   └── configure-novnc.sh        # تنظیمات noVNC
└── README.md                      # این فایل
```

---

## 🎉 خلاصه

1. ✅ Fork کنید یا Clone کنید
2. ✅ به Railway push کنید
3. ✅ Variables را تنظیم کنید
4. ✅ دسکتاپ آماده است!
5. ✅ از پنل Backup استفاده کنید
6. ✅ کد بنویسید و backup بگیرید!

---

## 💬 سوالات متداول

**Q: آیا می‌توانم برنامه‌های دیگر نصب کنم؟**  
A: بله! از Wine یا apt-get استفاده کنید.

**Q: چگونه فایل آپلود کنم؟**  
A: از File Manager یا این دستور:
```bash
railway run "cat > /root/workspace/file.txt" < local-file.txt
```

**Q: چند نفر همزمان می‌توانند استفاده کنند؟**  
A: بله، noVNC از چند کاربر پشتیبانی می‌کند.

**Q: Kiro نصب نمی‌شود؟**  
A: ممکن است لینک تغییر کرده باشد. دستی از [kiro.dev/downloads](https://kiro.dev/downloads) دانلود کنید.

---

## 📜 لایسنس

MIT License - استفاده آزاد!

---

**ساخته شده با ❤️ برای توسعه‌دهندگان ایرانی**

موفق باشید! 🚀
