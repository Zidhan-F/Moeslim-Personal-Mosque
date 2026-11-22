# ADR 0004: Billing provider-agnostic
Status: diterima (jalur final belum ditetapkan)

**Keputusan**: entitlement disimpan di `subscriptions` dengan `provider`
(`manual` | `google_play`). Server adalah sumber kebenaran status. Verifikasi
Google Play diimplementasikan sebagai antarmuka; integrasi nyata menunggu akun Play Console.

**Pro**: keputusan Play Billing vs web billing tidak memblokir pengembangan.
**Kontra**: Play Billing memotong 15% untuk langganan; perlu dihitung ulang sebelum rilis.
