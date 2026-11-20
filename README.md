# Moeslim — Personal & Masjid

Monorepo ekosistem Moeslim:

| Path | Isi |
|---|---|
| `backend/` | API Laravel untuk Moeslim Masjid (multi-tenant, PostgreSQL) |
| `packages/shared_prayer/` | Dart murni: jadwal sholat, kiblat, kalender Hijriah |
| `packages/personal_core/` | Model, penyimpanan lokal, dan konten Moeslim Personal |
| `apps/mobile/` | Aplikasi Flutter: Personal + klien Moeslim Masjid |
| `apps/masjid_display/` | Aplikasi Flutter TV Display masjid |
| `docs/` | Blueprint, ADR, rencana implementasi |

Lihat `docs/blueprint.md` untuk spesifikasi dan `docs/adr/` untuk keputusan arsitektur.
