# ADR 0002 — Multi-tenant shared database dengan `mosque_id`
Status: diterima

**Keputusan**: satu database PostgreSQL, setiap tabel operasional membawa `mosque_id`.
Tenant di-resolve dari route `{mosque}` lalu divalidasi terhadap keanggotaan aktif;
`mosque_id` dari body klien tidak pernah dipercaya. Query lewat relasi tenant.

**Pro**: operasional murah, migrasi tunggal, cocok untuk ribuan masjid kecil.
**Kontra**: bug query berpotensi bocor lintas tenant → dimitigasi dengan test akses silang
untuk setiap modul. PostgreSQL RLS dicatat sebagai pertahanan lapis kedua (fase berikut).
