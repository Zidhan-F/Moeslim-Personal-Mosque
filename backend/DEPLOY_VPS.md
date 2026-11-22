# Panduan Deploy Produksi VPS (Docker + PostgreSQL + Redis + Caddy HTTPS)

Paket ini menjalankan backend **Moeslim Mosque** (Laravel 13, PHP 8.3) di VPS Linux Ubuntu/Debian menggunakan Docker Engine dan Docker Compose yang 100% gratis dan open source.

## Spesifikasi VPS yang Disarankan
- Minimal: **2 vCPU, 2-4 GB RAM, 40 GB SSD**, OS **Ubuntu 24.04 LTS**, lokasi **Singapore** atau **Jakarta**.
- 1 domain/subdomain (misalnya `api.namadomain.id`) dengan DNS **A Record** mengarah ke IP publik VPS.

## 1. Siapkan VPS & Install Docker (Gratis)
Login SSH ke VPS lalu jalankan:

```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"
newgrp docker

# Buka port SSH, HTTP (challenge SSL), dan HTTPS saja
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp
sudo ufw enable
```

## 2. Clone Repositori & Siapkan `.env.production`
```bash
git clone <URL_REPO_ANDA> /opt/moeslim-pm
cd /opt/moeslim-pm/backend
cp .env.production.example .env.production
```

Generate `APP_KEY` acak:
```bash
echo "base64:$(openssl rand -base64 32)"
```

Edit `.env.production` (`nano .env.production`) dan isi minimal nilai berikut:
- `API_DOMAIN=api.namadomain.id`
- `APP_URL=https://api.namadomain.id`
- `APP_KEY=base64:...` (hasil perintah di atas)
- `DB_PASSWORD=...` (password kuat acak, minimal 24 karakter)
- `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_FROM_ADDRESS` (agar kode OTP 6 digit masuk ke email pengguna; sementara bisa `MAIL_MAILER=log` lalu baca kode dari `docker compose logs app`).

## 3. Jalankan Stack Produksi
```bash
cd /opt/moeslim-pm/backend
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```

Yang terjadi otomatis:
- PostgreSQL 16 dan Redis 7 menyala di jaringan internal (tidak terbuka ke internet).
- Container `app` menjalankan `php artisan migrate --force` dan caching konfigurasi/rute.
- Container `worker` memproses antrean email dan job di latar belakang.
- **Caddy** menerbitkan sertifikat SSL Let's Encrypt otomatis untuk `API_DOMAIN`.

Verifikasi server aktif:
```bash
curl -i https://api.namadomain.id/up
docker compose -f docker-compose.prod.yml ps
```

## 4. Aktifkan Backup Harian PostgreSQL
```bash
chmod +x /opt/moeslim-pm/backend/docker/backup-db.sh
crontab -e
```
Tambahkan baris berikut (backup otomatis tiap pukul 02.00 UTC / 09.00 WIB, menyimpan 14 hari terakhir):
```cron
0 2 * * * /opt/moeslim-pm/backend/docker/backup-db.sh >> /var/log/moeslim-backup.log 2>&1
```
Untuk salinan backup di luar VPS, pasang `rclone` dan arahkan ke **Cloudflare R2** (gratis 10 GB/bulan, tanpa biaya bandwidth keluar).

## 5. Build APK Rilis Flutter yang Terhubung ke VPS
Di PC pengembangan (folder `apps/mobile`):
```powershell
flutter build apk --release --split-per-abi --target-platform android-arm64 --dart-define=API_BASE_URL=https://api.namadomain.id/api
```

## 6. Update Rutin di Masa Depan
Setiap kali ada pembaruan kode di GitHub:
```bash
cd /opt/moeslim-pm
git pull
cd backend
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```
Migrasi baru akan otomatis dijalankan tanpa menghapus data database maupun file lampiran (disimpan di volume `pg_data` dan `app_storage`).
