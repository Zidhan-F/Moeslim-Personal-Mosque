# ADR 0005 — Moeslim Personal sepenuhnya non-komersial
Status: diterima (keputusan pemilik produk)

## Keputusan
Moeslim Personal **bukan produk komersial**: gratis selamanya, tanpa iklan, tanpa pembelian dalam
aplikasi, tanpa fitur berbayar/premium, tanpa penjualan atau pelacakan data pengguna. Hanya
**Moeslim Masjid** yang berbayar (Rp59.000/bulan/masjid).

## Konsekuensi
1. **Lisensi konten.** Konten berlisensi non-komersial (mis. rekaman murattal/tilawah publik, dataset
   anotasi tajwid, teks/terjemahan dengan syarat non-komersial) boleh dipakai di Personal **dengan atribusi**
   dan sesuai ketentuan masing-masing. Konten ini **tidak boleh** dipakai di Moeslim Masjid atau TV Display.
2. **Atribusi wajib tampil** di aplikasi: halaman *Tentang & Lisensi* menampilkan pernyataan non-komersial
   dan atribusi tiap rekaman dari katalog; dataset teks mencantumkan `SOURCE.md`.
3. **Tanpa SDK iklan/analytics pihak ketiga** di aplikasi Personal.
4. **Pemisahan dari produk berbayar.** Alur langganan/pendaftaran Moeslim Masjid tidak semestinya berada
   di dalam aplikasi Personal (lihat bagian "Keputusan terbuka").

## Catatan risiko
Sebagian pemberi lisensi menilai "non-komersial" dari **entitas penerbit**, bukan hanya dari aplikasinya.
Karena pengembang yang sama juga menjual Moeslim Masjid, untuk sumber dengan syarat yang tidak jelas
tetap mintalah konfirmasi tertulis bahwa pemakaian di aplikasi gratis non-komersial diperbolehkan.

## Keputusan terbuka
Klien pengurus Moeslim Masjid saat ini masih menjadi menu di `apps/mobile`. Rekomendasi: pisahkan menjadi
aplikasi tersendiri (`apps/masjid_admin`), sehingga aplikasi Personal tidak memuat alur berbayar sama sekali.
