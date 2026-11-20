# Ilustrasi Moeslim PM

Ilustrasi aplikasi (masjid krem berkubah emas, Al-Qur'an di rehal, lentera, Ka'bah, perisai login,
pemandangan masjid untuk TV, ornamen lengkung & kisi) digambar ulang sebagai vektor mengikuti
**paket visualisasi UI** (komposisi, palet, gaya). Tidak ada foto/aset pihak ketiga dan tidak ada
wajah orang sungguhan (lencana qari bersifat generik).

```bash
python3 build.py      # tulis svg/*.svg
node render.js        # render PNG 2x (Chromium/Playwright) ke packages/moeslim_brand/assets/illustrations
python3 -I optimize.py  # ubah ke WebP (alfa dipertahankan), hapus PNG
```

Dipakai lewat `BrandArt(BrandIllustration.xxx)` dari paket `moeslim_brand`
(`packages/moeslim_brand/lib/src/illustration.dart`). Test `illustration_test.dart` memastikan
setiap ilustrasi punya aset dan sumber SVG.
