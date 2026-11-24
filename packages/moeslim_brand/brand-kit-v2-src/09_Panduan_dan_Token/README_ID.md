# Moeslim PM — Paket Logo & Brand V2

## Konsep yang disetujui
Logo terbaru berisi **satu figur manusia berwarna putih di sebelah kiri**, **masjid emas di sebelah kanan**, **lengkungan putih**, dan **sapu garis emas/putih**, pada ikon kotak hijau emerald.

Ini adalah **rekonstruksi vektor bersih berdasarkan visual konsep yang disetujui**, bukan hasil tracing piksel sempurna. SVG bersifat vektor editable. PNG diekspor dari SVG sehingga tampak konsisten.

## Struktur
- `01_SVG_Editable`: logo master SVG, logo simbol transparan, lockup vertikal/horizontal, versi outlined (teks jadi path) dan editable text.
- `02_PNG_Icon`: ikon beragam ukuran (16 sampai 2048 px), simbol transparan, mono, flat.
- `03_Logotype_Wordmark`: PNG logo + nama aplikasi.
- `04_Favicon_Web`: favicon.ico, favicon.svg, PNG, webmanifest PWA, contoh HTML.
- `05_Android`: launcher icons density Android, Play Store icon, template Adaptive Icon.
- `06_iOS_App_Icons`: PNG AppIcon iOS ukuran umum.
- `07_Media_Social`: banner Open Graph, avatar.
- `08_Splash_Screen`: splash smartphone dan tablet.
- `09_Panduan_dan_Token`: palet warna dan petunjuk integrasi.
- `10_Referensi_Visual`: konsep asli yang dipilih untuk membandingkan kesetiaan desain.

## Warna utama
- Emerald `#065F46`
- Deep Green `#043F32`
- Gold `#F59E0B`
- Mint `#ECFDF5`
- Cream `#F8F6EE`

## Penggunaan prioritas
1. **Google Play Store**: `05_Android/Play_Store/moeslim_pm_play_store_512.png`.
2. **Android launcher**: gunakan aset dalam `mipmap-*`; untuk adaptive icon gunakan file `05_Android/Adaptive/` dengan konfigurasi native yang sesuai.
3. **Website**: salin folder `04_Favicon_Web` ke direktori aset publik, lalu sesuaikan URL pada `copy_to_html_head.html` dan `site.webmanifest`.
4. **Flutter**: gunakan `02_PNG_Icon/Color/moeslim_pm_icon_512.png` untuk logo umum, SVG melalui `flutter_svg` jika telah tersedia, atau PNG jika proyek offline belum mempunyai dependensi tersebut.
5. **Splash**: gunakan aset di `08_Splash_Screen`; sesuaikan safe area per perangkat.

## Perhatian
- **Jangan** memakai logo lama (masjid + Al-Qur'an terbuka) dalam build terbaru.
- File asli presentasi konsep turut disertakan hanya sebagai **referensi visual**, bukan file logo transparan.
- Simbol logo adalah ilustrasi merek; tetap lakukan penelusuran merek dan periksa kemiripan sebelum publikasi komersial.
- SVG lockup `editable_text` menggunakan teks sistem (`Inter`); versi `outlined` mengubah teks menjadi lintasan vektor agar tidak bergantung font eksternal.
- Tidak ada font berlisensi yang dibagikan dalam paket.
