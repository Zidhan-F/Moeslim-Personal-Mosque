# ADR 0003: Ledger keuangan berbasis dana dan akun kas
Status: diterima

**Keputusan**: transaksi immutable dengan `fund_id` (dana) dan `cash_account_id`
(akun kas). Koreksi melalui entri pembalik (`reversal_of_id`). Idempotency key unik
per masjid. Nominal `bigint` rupiah.

**Pro**: auditabel, aman dari retry jaringan, memisahkan zakat/wakaf dari operasional.
**Kontra**: UI koreksi lebih panjang daripada "edit"; bendahara perlu memahami konsep dana.
