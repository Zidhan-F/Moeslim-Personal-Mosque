# Moeslim MVP — Implementation Plan

Spec: `docs/blueprint.md` (ringkasan Product Blueprint v1.0 + revisi arsitek v1.1).

Goal: monorepo berisi backend Laravel (Moeslim Masjid, multi-tenant), paket Dart
`shared_prayer`, paket `personal_core`, aplikasi Flutter `apps/mobile`
(Personal + klien Masjid) dan `apps/masjid_display` (TV Display).

## Global Constraints

- Backend: Laravel 12, PHP 8.3, PostgreSQL 16 (test juga di PostgreSQL), Sanctum token.
- Nominal uang: integer rupiah (`bigInteger`). Transaksi keuangan immutable; koreksi = entri pembalik.
- Setiap endpoint tenant: `auth:sanctum` + middleware tenant (membership aktif) + permission check di server.
- Tidak ada teks Al-Qur'an/terjemahan/hadis yang ditulis tangan di repo; hanya metadata + importer.
- Flutter: diverifikasi dengan `flutter analyze` + `flutter test` (tidak ada Android SDK di lingkungan ini).
- Bahasa UI: Indonesia.

---

### Task 1: Fondasi repo
Files: `README.md`, `.gitignore`, `docs/blueprint.md`, `docs/adr/*.md`.
- ADR: dua core, multi-tenant shared-DB + `mosque_id`, ledger dana terikat, billing provider-agnostic.
Test: `test -f README.md && test -f docs/blueprint.md`
Expected: exit 0.

### Task 2: `packages/shared_prayer` (Dart murni)
- `PrayerCalculator` metode Kemenag (Subuh −20°, Isya −18°, Ashar Syafi'i, ihtiyat 2 menit), plus MWL/Umm al-Qura/ISNA; penyesuaian menit per waktu; imsak = subuh − 10.
- `qiblaBearing(lat,lng)`.
- `HijriDate.fromGregorian` (tabular) + offset koreksi lokal; `toGregorian`.
Tests: Jakarta 2025-01-01 dalam ±3 menit dari jadwal Kemenag (Subuh 04:19, Dzuhur 11:55, Ashar 15:20, Maghrib 18:13, Isya 19:28); kiblat Jakarta ≈ 295.1°±0.5; 1 Muharram 1446 = 2024-07-07 (±1 hari); round-trip hijri.
Test command: `dart test` in package. Expected: all pass.

### Task 3: Backend scaffold + auth + registrasi masjid
- Laravel + Sanctum; `.env.testing` pgsql `moeslim_test`.
- `POST /api/auth/register|login|logout`, `GET /api/me`.
- `POST /api/mosques` → mosque (slug unik), membership owner/admin, subscription trial 30 hari, dana & akun kas default.
- Deteksi duplikat (nama+kota mirip) → flag `needs_review`, tidak memblokir.
Tests: register/login/logout, token revoked, create mosque membuat owner + trial.

### Task 4: Tenancy, RBAC, pengurus
- Middleware `tenant` (route `{mosque}`) → 404 jika bukan anggota aktif.
- `config/permissions.php` matriks role admin/bendahara/pengurus/operator sesuai blueprint §08; `finance.view` untuk pengurus hanya jika `settings.pengurus_can_view_finance`.
- Members: invite (token), accept, update role, deactivate, reactivate. Maks 5 aktif; reaktivasi/aktivasi baru dibatasi 3 kali per 30 hari (anti rotasi). Admin terakhir tidak bisa dinonaktifkan/turun role.
- `audit_logs` untuk perubahan role/undangan.
Tests: cross-tenant 404, akun keenam ditolak 422, rotasi limit, last admin, permission matrix.

### Task 5: Keuangan
- `funds` (unrestricted/restricted: operasional, zakat, infaq, wakaf…), `cash_accounts` (tunai/bank/kotak amal), `finance_categories`.
- `finance_transactions`: flow in/out/transfer, amount bigint >0, fund_id, account_id, (to_account_id), reference_no unik per masjid, `idempotency_key` unik per masjid, `reversal_of_id`. Tidak ada update/delete; `POST …/reverse`.
- Saldo per akun & per dana; dana terikat tidak boleh negatif (pengeluaran ditolak).
- Laporan bulanan + ekspor CSV. Lampiran (disk `s3`/local) dengan kuota 1 GB: tolak upload di 100%, transaksi teks tetap jalan; peringatan 80/95 di dashboard.
- FUP 10.000 transaksi/bulan: tidak memblokir, set flag peringatan.
Tests: idempotensi, reversal, saldo, dana terikat negatif ditolak, kuota upload, tenant isolation, CSV.

### Task 6: Agenda, pengumuman, petugas, inventaris
- CRUD dengan permission; `visibility` public/internal; arsip. Limit 500 agenda+pengumuman aktif, 5.000 inventaris.
Tests: limit, permission operator, arsip membebaskan slot.

### Task 7: TV Display
- `POST /mosques/{m}/displays/pairing-codes` (6 digit, 10 menit, sekali pakai) → `POST /api/display/pair` tukar kode → device token (hash disimpan). Maks 5 aktif. Revoke.
- `GET /api/display/content` (auth device): profil, koordinat, metode, iqamah, agenda/pengumuman publik aktif, ringkasan kas jika `settings.display_show_finance`; update `last_seen`; `server_time`.
Tests: pairing sekali pakai, kedaluwarsa, limit 5, revoke → 401, tidak bocor data internal.

### Task 8: Publik, langganan, dashboard
- `GET /api/public/mosques/{slug}`, `/events`, `/announcements` — allowlist field, rate limit.
- Subscription state: trialing/active/grace(7 hari)/expired; middleware `entitled` memblokir write (403 `subscription_inactive`) saat expired, read + export tetap.
- Provider interface `BillingProvider` (manual, google_play stub) + `POST /mosques/{m}/subscription/verify`.
- `GET /mosques/{m}/dashboard`.
Tests: allowlist, expired memblokir write tapi tidak read, dashboard.

### Task 9: `packages/personal_core`
- Model & repositori lokal (antarmuka + implementasi in-memory & SharedPreferences-free JSON store): settings lokasi/metode/penyesuaian, tasbih, tracker ibadah, bookmark, progres Naghom, masjid favorit.
- Konten: 7 Naghom (sesuai blueprint, flag `needsExpertReview`), dzikir dasar, metadata 114 surah (nama, jumlah ayat, jenis), daftar kota Indonesia utama.
Tests: repositori, jumlah ayat total 6236, 7 naghom.

### Task 10: `apps/mobile`
- Tema hijau zamrud/krem/emas, dark mode, skala huruf. Navigasi 5 tab: Beranda, Quran, Sholat, Ibadah, Lainnya.
- Beranda: sholat berikutnya + countdown. Sholat: jadwal + pengaturan. Quran: daftar surah, bookmark, Naghom. Ibadah: tasbih, tracker, kiblat (bearing), kalender Hijriah. Lainnya: pengaturan, Moeslim Masjid (login, dashboard, transaksi, agenda).
Tests: widget test navigasi, countdown, tasbih, klien API (mock).

### Task 11: `apps/masjid_display`
- Layar pairing → layar display (jam, tanggal M/H, 5 waktu, countdown azan/iqamah, rotasi pengumuman), cache konten terakhir + label "terakhir sinkron".
Tests: widget test pairing, render dari cache, logika countdown iqamah.

### Task 12: CI + dokumentasi
- `.github/workflows/ci.yml`: backend (pgsql service) + dart/flutter tests. README cara menjalankan.
Test: backend & flutter suites hijau.
