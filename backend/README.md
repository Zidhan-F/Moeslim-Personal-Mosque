# Moeslim Masjid — Backend API

API Laravel 13 (PHP 8.3, PostgreSQL 16) untuk Moeslim Masjid: multi-tenant per masjid,
autentikasi token Sanctum, RBAC, keuangan berbasis dana, TV Display, dan API publik.

## Menjalankan lokal

```bash
composer install
cp .env.example .env && php artisan key:generate
# buat database & user sesuai .env (default: moeslim/moeslim)
php artisan migrate
php artisan serve
```

Test memakai database PostgreSQL `moeslim_test` (lihat `phpunit.xml`):

```bash
createdb -O moeslim moeslim_test
php artisan test
```

## Operasional

| Perintah | Fungsi |
|---|---|
| `php artisan moeslim:subscription:activate {slug} --months=1 --ref=INV-001` | Aktivasi/perpanjangan langganan manual oleh operator platform |

## Struktur

- `app/Http/Middleware/EnsureTenantMember.php` — resolve `{mosque}` + validasi keanggotaan aktif (non-anggota → 404).
- `config/permissions.php` + `app/Support/Permissions.php` — matriks izin per role.
- `app/Services/FinanceService.php` — ledger immutable, idempotensi, saldo dana & akun.
- `app/Services/SubscriptionService.php` — status trial/aktif/tenggang/berakhir.
- `routes/api.php`, `routes/tenant.php`, `routes/public.php` — rute API.

Referensi endpoint: `../docs/api.md`.
