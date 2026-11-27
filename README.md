# Moeslim PM — Personal & Mosque

Satu aplikasi dengan dua menu: **Moeslim Personal** (aplikasi utama — gratis, non-komersial, tanpa akun,
offline-first) dan **Moeslim Mosque** (fitur tambahan opsional untuk pengurus masjid — cloud, multi-tenant,
Rp59.000/bulan/masjid, maks. 5 pengurus & 5 TV Display). Lihat `docs/adr/0005-personal-non-commercial.md`.

**Fitur andalan: 7 Jenis Irama (Naghom) Al-Qur'an** — Bayyati, Hijaz, Shaba, Rast, Jiharkah, Sika, Nahawand.

| Path | Isi | Test |
|---|---|---|
| `backend/` | API Laravel 13 + PostgreSQL untuk Moeslim Mosque | `php artisan test` |
| `packages/shared_prayer/` | Dart murni: jadwal sholat (Kemenag, MWL, dll.), kiblat, Hijriah | `dart test` |
| `packages/moeslim_brand/` | Identitas visual: warna, tema, font Inter, logo (lihat `docs/brand/`) | `flutter test` |
| `packages/personal_core/` | Konten (114 surah, 7 Naghom, dzikir, kota) & penyimpanan lokal | `dart test` |
| `apps/mobile/` | Flutter: Moeslim Personal + fitur tambahan Moeslim Mosque | `flutter test` |
| `apps/masjid_display/` | Flutter (Android TV/box): TV Display masjid | `flutter test` |
| `docs/` | Blueprint v1.1, ADR, rencana implementasi, referensi API | |

## Menjalankan

```bash
# Backend
cd backend && composer install && cp .env.example .env && php artisan key:generate
php artisan migrate && php artisan serve

# Aplikasi (arahkan ke API)
cd apps/mobile && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
cd apps/masjid_display && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## Tampilan

Ilustrasi (masjid, Al-Qur'an di rehal, lentera, Ka'bah, perisai login, pemandangan masjid TV, ornamen)
digambar ulang sebagai vektor mengikuti paket visualisasi — sumber & cara render di `tools/illustrations/`.

Tangkapan layar hasil render (font & warna brand) ada di `docs/brand/screenshots/`:
`personal/` (Onboarding, Beranda, Al-Qur'an, Mushaf, Murottal, 7 Irama, Doa, Jadwal, Kiblat, Tasbih, Catatan Ibadah, Masjid Terdekat),
`mosque/` (Pilih Peran, Registrasi, Login/Aktivasi, Dashboard, Keuangan, Tambah/Riwayat Transaksi,
Laporan, Pengurus & Role, Agenda, Petugas, Inventaris, Konfigurasi TV, Konten, Akun) dan
`tv/` (Layar Utama, fase Iqamah, Informasi Jamaah, tema Terang & Gelap).

## Masjid Terdekat

Masjid & musala di sekitar pengguna dari GPS: data OpenStreetMap (ODbL) + masjid terdaftar Moeslim Mosque
(terverifikasi otomatis) + koreksi jamaah yang dimoderasi. Aplikasi mengunduh paket per wilayah dan menghitung
jarak di perangkat (privasi & offline). Operasional impor/moderasi: `docs/masjid-terdekat.md`;
keputusan desain: `docs/adr/0006-masjid-terdekat.md`.

## Teks Al-Qur'an

Aplikasi sudah memuat **teks Arab Al-Qur'an lengkap** (Tanzil Quran Text — Uthmani, 114 surah, 6.236 ayat)
dengan font mushaf **Amiri Quran**, di `apps/mobile/assets/quran/` (sumber & ketentuan: `SOURCE.md`).
Terjemahan Indonesia (Kemenag) ikut dimuat. Pewarnaan tajwid masih menunggu data anotasi yang
selaras dengan teks — lihat **`docs/licensing/`**.

## Audio murottal 7 irama

Pemutar per surah/ayat dengan pilihan 7 irama naghom. Repo tidak menyertakan audio; rekaman
berlisensi didaftarkan lewat katalog — lihat `docs/audio-naghom.md`.

## Pewarnaan tajwid

Teks Al-Qur'an diwarnai sesuai hukum tajwid dari dataset anotasi yang diimpor bersama teks
(`--tajweed`), dengan panduan warna & tombol on/off — lihat `docs/tajwid-warna.md`.

## Dokumen

- `docs/tajwid-warna.md` — pewarnaan tajwid & format anotasi
- `docs/licensing/` — register lisensi konten & surat permohonan izin

- `docs/audio-naghom.md` — pemutar audio & format katalog 7 irama

- `docs/blueprint.md` — spesifikasi (Blueprint v1.1)
- `docs/adr/` — keputusan arsitektur
- `docs/api.md` — referensi endpoint
- `docs/plans/2026-11-20-moeslim-mvp.md` — rencana implementasi MVP
