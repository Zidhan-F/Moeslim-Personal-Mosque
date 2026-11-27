# Referensi API Moeslim Masjid (v1)

Base URL: `/api`. Semua respons JSON. Autentikasi pengurus: `Authorization: Bearer <token Sanctum>`.
Autentikasi TV Display: `Authorization: Bearer <token perangkat>`.

Kode error bisnis dikembalikan sebagai `{"code": "...", "message": "..."}` (422 kecuali disebut lain).

## Autentikasi & akun
| Metode | Path | Keterangan |
|---|---|---|
| POST | `/auth/register` | name, email, password (+confirmation, min 10). Mengirim kode verifikasi email |
| POST | `/auth/login` | email, password → token |
| POST | `/auth/logout` | cabut token aktif |
| POST | `/auth/email/send-code` · `/auth/email/verify` | verifikasi email 6 digit (15 menit, maks 5 percobaan) |
| GET | `/me` | profil + keanggotaan aktif |
| DELETE | `/me` | hapus akun (anonimisasi; pemilik masjid wajib transfer kepemilikan) |

## Masjid (tenant)
Semua rute `/mosques/{mosque}/...` mensyaratkan anggota aktif (selain itu 404). Saat langganan
`expired`, metode tulis → 403 `subscription_inactive` (baca & ekspor tetap).

| Metode | Path | Izin |
|---|---|---|
| GET/POST | `/mosques` | daftar masjid saya / registrasi (email terverifikasi) |
| GET/PATCH | `/mosques/{m}` | anggota / `mosque.update` (admin) |
| GET | `/mosques/{m}/dashboard` | `dashboard.view` |
| GET | `/mosques/{m}/subscription` | status + pemakaian FUP |
| POST | `/mosques/{m}/subscription/verify` | `billing.manage` (Google Play; 503 bila belum dikonfigurasi) |
| GET | `/mosques/{m}/members` | `members.view` |
| POST | `/mosques/{m}/members/invite` | `members.manage` — `member_limit_reached` |
| PATCH | `/mosques/{m}/members/{id}` | ubah role — `last_admin` |
| POST | `/mosques/{m}/members/{id}/deactivate` · `/reactivate` | `rotation_limit_reached` (maks 3/30 hari) |
| DELETE | `/mosques/{m}/invitations/{id}` | cabut undangan |
| POST | `/mosques/{m}/transfer-ownership` | pemilik |
| POST | `/invitations/accept` | token undangan, email harus cocok |
| GET | `/mosques/{m}/audit-logs` | admin penuh; bendahara/pengurus terbatas modulnya |

## Keuangan
| Metode | Path | Izin |
|---|---|---|
| GET | `/finance/setup` | dana, akun kas, kategori |
| GET | `/finance/transactions?from&to&fund_id&cash_account_id&flow&q` | `finance.view` |
| POST | `/finance/transactions` | `finance.write`, header **Idempotency-Key** wajib (428). Key sama + data beda → 409 |
| POST | `/finance/transactions/{id}/reverse` | entri pembalik — `already_reversed` |
| POST | `/finance/transactions/{id}/attachments` | jpg/png/webp/pdf ≤5 MB — `storage_quota_exceeded` |
| GET | `/finance/summary?from&to` · `/finance/reports/monthly?year` | `finance.view` |
| GET | `/finance/export?from&to` | `finance.export` — CSV UTF-8 |
| POST | `/finance/accounts` · `/finance/funds` · `/finance/categories` | `finance.write` |

Transaksi: `flow` = in | out | transfer, `amount` integer rupiah > 0, `fund_id`, `cash_account_id`,
`to_cash_account_id` (transfer), `category_id`, `date`, `description`. Dana terikat tidak boleh
negatif (`restricted_fund_insufficient`).

## Agenda, pengumuman, petugas, inventaris
| Path | Izin baca / tulis |
|---|---|
| `/events`, `/events/{id}`, `/events/{id}/archive`, `/events/{id}/display` | `events.view` / `events.write`; toggle tayang `events.display` |
| `/announcements` (pola sama) | sama dengan agenda |
| `/staff-assignments?from&to` | `staff.view` / `staff.write` |
| `/inventory`, `/inventory/{id}/maintenance` | `inventory.view` / `inventory.write` |

Batas: 500 agenda+pengumuman aktif (`content_limit_reached`), 5.000 inventaris (`inventory_limit_reached`).

## TV Display
| Metode | Path | Keterangan |
|---|---|---|
| GET | `/mosques/{m}/displays` | `display.view` |
| POST | `/mosques/{m}/displays/pairing-codes` | `display.manage` → kode 6 digit, 10 menit, sekali pakai — `display_limit_reached` |
| PATCH/POST | `/mosques/{m}/displays/{id}` · `/revoke` | `display.manage` |
| POST | `/display/pair` | perangkat menukar kode → token (throttle 5/menit) |
| GET | `/display/content` | token perangkat; mendukung `If-None-Match` (304) |

## Publik (Moeslim Personal, tanpa akun)
| Metode | Path |
|---|---|
| GET | `/public/mosques?q&city` |
| GET | `/public/mosques/{slug}` · `/events` · `/announcements` |
| GET | `/public/directory/cells/{geohash4}` — direktori Masjid Terdekat per sel wilayah (ETag) |
| POST | `/public/directory/reports` — laporan koreksi/masjid baru (tanpa akun, 10/jam) |

Hanya field allowlist (tanpa kontak internal, keuangan, identitas pengurus). Rate limit 60/menit.
