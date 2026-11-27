# Operasional direktori Masjid Terdekat

Lihat keputusan desain di `docs/adr/0006-masjid-terdekat.md`.

## Impor OpenStreetMap
```bash
cd backend
php artisan migrate
# Seluruh Indonesia, ubin 2°, jeda 5 detik antar unduhan (sopan terhadap server Overpass publik)
php artisan directory:import-osm --region=indonesia --prune
# Satu kota / uji coba
php artisan directory:import-osm --bbox=-6.40,106.65,-6.05,107.05 --prune
# Dari berkas JSON Overpass yang sudah diunduh (mis. instance Overpass sendiri)
php artisan directory:import-osm storage/app/osm-jakarta.json --bbox=-6.40,106.65,-6.05,107.05 --prune
```
- `--prune` menyembunyikan (tidak menghapus) entri OSM di kotak itu yang sudah tidak ada di peta;
  entri terkunci (hasil moderasi) dan entri yang tertaut masjid terdaftar tidak ikut disembunyikan.
- Jadwal mingguan otomatis: set `OVERPASS_SCHEDULE=true` lalu jalankan scheduler Laravel.
- Untuk volume besar, gunakan instance Overpass sendiri (`OVERPASS_URL`) sesuai kebijakan pemakaian Overpass.
- Wajib menampilkan atribusi "© OpenStreetMap contributors" (aplikasi menampilkannya di daftar & halaman
  Tentang & Lisensi).

## Impor SIMAS / CSV
```bash
php artisan directory:import-csv data/simas.csv --source=simas
```
Kolom wajib: `id,name,latitude,longitude`; opsional: `kind,address,city,province,simas_id`.
Gunakan hanya data yang diperoleh secara resmi.

## Moderasi laporan jamaah
```bash
php artisan directory:reports              # daftar laporan menunggu
php artisan directory:reports --accept=12  # terapkan (koreksi lokasi/nama, sembunyikan, atau tambah masjid)
php artisan directory:reports --reject=13
```

## API publik
- `GET /api/public/directory/cells/{geohash4}` — isi satu sel (ETag + cache 1 jam), tanpa autentikasi.
- `POST /api/public/directory/reports` — laporan koreksi (maks. 10 per jam per IP).
