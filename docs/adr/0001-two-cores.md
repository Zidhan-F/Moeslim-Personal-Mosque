# ADR 0001 — Dua core independen dalam satu monorepo
Status: diterima

**Keputusan**: Personal (offline, tanpa akun) dan Masjid (cloud, multi-tenant) adalah
dua core terpisah. Kode bersama hanya lewat paket (`shared_prayer`).

**Pro**: Personal tetap ringan; risiko keamanan cloud tidak menyentuh pengguna Personal.
**Kontra**: dua model data dan dua alur UX yang harus dipelihara.
