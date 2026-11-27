# ADR 0006 — Masjid Terdekat: direktori publik, paket wilayah offline, privasi lokasi

## Konteks
Fitur "Masjid Terdekat" di Moeslim Personal sebelumnya hanya mencari nama masjid yang sudah
mendaftar Moeslim Mosque dan memakai titik tengah kota pilihan, sehingga masjid sekitar tidak
benar-benar terdeteksi.

## Keputusan
1. **Lokasi**: GPS perangkat (`geolocator`), izin *saat aplikasi dipakai* saja. Akurasi ditampilkan;
   bila izin ditolak, pusat kota pilihan dipakai sebagai perkiraan.
2. **Sumber data** (tabel `mosque_directory`, terpisah dari tenant `mosques`):
   - **OpenStreetMap** (`amenity=place_of_worship` + `religion=muslim`) — data dasar, ODbL 1.0
     (atribusi "© OpenStreetMap contributors"; basis data turunan yang dipublikasikan juga ODbL).
     Diimpor berkala oleh job server per ubin, **bukan** dipanggil dari ponsel.
   - **Masjid terdaftar Moeslim Mosque** — otomatis ditautkan ke entri peta terdekat (≤ 75 m dan nama
     mirip, atau ≤ 25 m) dan diberi lencana *Terverifikasi*; bila tidak ada padanan, dibuat entri sendiri.
   - **SIMAS Kemenag** — importer CSV siap pakai (`directory:import-csv --source=simas`) setelah data
     diperoleh secara resmi. Tidak ada scraping.
   - **Laporan jamaah** (lokasi salah, nama salah, tidak ada, masjid baru) — tanpa akun, dibatasi laju,
     IP disimpan sebagai HMAC, dimoderasi (`directory:reports`). Entri yang dikoreksi `locked` sehingga
     impor berikutnya tidak menimpanya.
3. **Privasi & offline**: aplikasi mengunduh **sel wilayah** (geohash 4 ≈ 39×20 km) tanpa token akun,
   menyimpannya di perangkat (diperbarui tiap 7 hari), dan menghitung jarak/arah di perangkat. Server tidak
   menerima koordinat persis pengguna untuk pencarian; fitur tetap bekerja offline dengan data tersimpan.
4. **Tanpa PostGIS**: lintang/bujur + geohash berindeks + haversine. Portabel di Postgres biasa (termasuk
   CI); PostGIS dapat ditambahkan bila data jauh membesar.
5. **Google Places tidak dipakai**: berbayar per permintaan dan berbatasan penyimpanan — bertentangan dengan
   Personal yang gratis & non-komersial.

## Konsekuensi
- Kualitas di pedesaan bergantung kelengkapan OSM + laporan jamaah; kerja sama data SIMAS menaikkan cakupan.
- Pengurus yang mendaftarkan masjid sebaiknya memakai tombol "Gunakan lokasi saya" agar penautan tepat.
