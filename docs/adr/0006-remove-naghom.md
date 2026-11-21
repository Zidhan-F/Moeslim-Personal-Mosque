# ADR 0006 — Menghapus fitur 7 Irama (Naghom)

**Status:** Diterima — 2026-11-21

## Konteks
7 Irama (Bayyati, Hijaz, Shaba, Rast, Jiharkah, Sika, Nahawand) sempat menjadi fitur andalan: modul
belajar irama dan pemutar dengan pilihan irama untuk setiap surah dan ayat. Dalam praktik:
- Rekaman berlisensi untuk **7 irama × 6.236 ayat** praktis tidak tersedia; sebagian besar pilihan
  selalu nonaktif dan katalog tidak pernah lengkap.
- Produksi sendiri (qari mitra, telaah tajwid, pemotongan per ayat) berat dan mahal; aset, halaman,
  dan logika tambahan menambah ukuran serta kerumitan aplikasi.

## Keputusan
Fitur 7 Irama dihapus seluruhnya. Audio Al-Qur'an cukup **murattal** per ayat/per surah dengan pilihan
qari (EveryAyah), unduh offline, ulang ayat, dan kecepatan.

Yang dihapus: halaman katalog & detail irama, hero Beranda, pilihan irama di pemutar, konten `naghom.dart`,
progres belajar irama, ilustrasi lentera, ubin & ikon naghom, motif gelombang, dan entri irama di katalog
audio (entri lama diabaikan saat dibaca).

## Konsekuensi
- Aplikasi lebih ringan dan realistis: setiap tombol putar selalu punya rekaman.
- Data lokal lama (`naghom.*`, `audio.naghom`) dibiarkan tak terpakai; tidak berpengaruh.
- Dokumen historis (blueprint, rencana MVP) masih menyebut 7 Irama; ADR ini yang berlaku.
