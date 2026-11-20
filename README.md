# Moeslim — Personal & Masjid

Monorepo ekosistem Moeslim: **Moeslim Personal** (gratis, tanpa akun, offline-first) dan
**Moeslim Masjid** (cloud, multi-tenant, Rp59.000/bulan/masjid, maks. 5 pengurus & 5 TV Display).

| Path | Isi | Test |
|---|---|---|
| `backend/` | API Laravel 13 + PostgreSQL untuk Moeslim Masjid | `php artisan test` |
| `packages/shared_prayer/` | Dart murni: jadwal sholat (Kemenag, MWL, dll.), kiblat, Hijriah | `dart test` |
| `packages/personal_core/` | Konten (114 surah, 7 Naghom, dzikir, kota) & penyimpanan lokal | `dart test` |
| `apps/mobile/` | Flutter: Moeslim Personal + klien Moeslim Masjid | `flutter test` |
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

## Teks Al-Qur'an

Repo ini **tidak** menyertakan teks Al-Qur'an/terjemahan. Impor dari sumber berlisensi yang telah
ditashih (Lajnah Pentashihan Mushaf Al-Qur'an Kemenag), lalu salin hasilnya ke `apps/mobile/assets/quran/`
dan daftarkan folder itu di `pubspec.yaml`:

```bash
cd packages/personal_core
dart run tool/import_quran.dart <teks-tanzil.txt> ../../apps/mobile/assets/quran [terjemahan.txt]
```

## Dokumen

- `docs/blueprint.md` — spesifikasi (Blueprint v1.1)
- `docs/adr/` — keputusan arsitektur
- `docs/api.md` — referensi endpoint
- `docs/plans/2026-11-20-moeslim-mvp.md` — rencana implementasi MVP
