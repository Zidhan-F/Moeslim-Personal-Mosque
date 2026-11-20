# ADR 0005 — Satu aplikasi: Moeslim Personal (gratis) + Moeslim Mosque (fitur tambahan berbayar)
Status: diterima (keputusan pemilik produk)

## Keputusan
**Satu aplikasi** dengan dua bagian:
1. **Moeslim Personal — aplikasi utama.** Gratis, mandiri, dan **non-komersial**: tanpa iklan, tanpa
   pembelian, tanpa fitur premium, tanpa akun, tanpa penjualan/pelacakan data. Semua fitur Personal
   (jadwal sholat, Al-Qur'an, 7 Irama Naghom, audio, tajwid, tasbih, tracker, kiblat, kalender, masjid
   yang diikuti) berfungsi penuh tanpa pernah menyentuh Mosque.
2. **Moeslim Mosque — fitur tambahan opsional** untuk pengurus masjid (kas, agenda, petugas, inventaris,
   TV Display). Berbayar Rp59.000/bulan per masjid **hanya bila dipakai**. Pengguna yang tidak
   memakainya tidak terdampak apa pun.

## Aturan produk (diuji otomatis)
- Layar fitur Personal (Beranda, Quran, Sholat, Ibadah) **tidak memuat** harga, ajakan berlangganan,
  premium, atau iklan (`test/personal_free_test.dart`).
- Pintu masuk Mosque **hanya** dua: menu *Profil → Fitur tambahan (opsional) → Moeslim Mosque*
  (dengan keterangan bahwa layanan ini tidak diperlukan untuk fitur Personal) dan pengalih core
  *Moeslim Personal ▾ / Moeslim Mosque ▾* di AppBar Beranda. Pengalih membuka halaman "Pilih Peran"
  yang menjelaskan Personal gratis tanpa akun; harga Mosque hanya tampil di halaman itu dan di
  tab Akun Mosque, tidak pernah di layar fitur Personal.
- Di dalam Mosque, navigasi bawah mengikuti izin peran dari server (Beranda, Keuangan, Kegiatan,
  Petugas, Akun); izin tetap diperiksa di backend.
- Fitur Personal tidak pernah mensyaratkan login.

## Konsekuensi teknis & legal
1. **Pembayaran.** Karena langganan Mosque dijual di dalam aplikasi Android, berlaku kebijakan Google Play
   Billing (atau program alternatif yang sah). Seluruh pembayaran hanya di alur Mosque.
2. **Lisensi konten non-komersial.** Konten berlisensi non-komersial (rekaman tilawah publik, dataset
   tajwid, teks/terjemahan) hanya dipakai di fitur Personal dengan atribusi (halaman *Tentang & Lisensi*)
   dan tidak dipakai di Mosque/TV Display. **Namun aplikasi yang sama juga memuat layanan berbayar**, dan
   sebagian pemberi lisensi menilai status komersial per aplikasi/penerbit. Untuk setiap sumber
   non-komersial, **minta konfirmasi tertulis** bahwa pemakaian di fitur gratis dalam aplikasi yang juga
   menyediakan layanan berbayar opsional diperbolehkan; utamakan sumber dengan izin eksplisit atau
   lisensi yang mengizinkan pemakaian komersial dengan atribusi.
3. **Tanpa SDK iklan/analytics pihak ketiga** di aplikasi.

## Alternatif yang ditolak
Memisah menjadi dua aplikasi — ditolak pemilik produk: Mosque adalah fitur tambahan di aplikasi utama.
