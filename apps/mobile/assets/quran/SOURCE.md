# Sumber Teks Al-Qur'an

**Tanzil Quran Text (Uthmani)**, Copyright (C) Tanzil Project, https://tanzil.net

- Diperoleh dari edisi `quran-uthmani` (distribusi Tanzil melalui api alquran.cloud) yang dikemas dalam
  paket npm `@faha1999/al-quran-database` (MIT), berkas `src/data/ayah-editions/quran-uthmani.json`.
- Diubah ke aset JSON per surah dengan `packages/personal_core/tool/import_quran.dart --strip-basmala`.
- **Satu-satunya perubahan struktur:** sumber menyisipkan basmalah di awal ayat 1 setiap surah; basmalah
  dilepas dari ayat 1 (kembali ke struktur teks asli Tanzil) dan ditampilkan sebagai pembuka surah oleh
  aplikasi. Huruf dan harakat ayat tidak diubah.
- Ketentuan Tanzil mensyaratkan teks disalin apa adanya, sumber (Tanzil Project) dicantumkan jelas, dan
  tautan ke tanzil.net disertakan. Atribusi tampil di halaman *Tentang & Lisensi*.

**Wajib sebelum rilis:** verifikasi ulang ketentuan resmi di https://tanzil.net/download dan telaah
kesesuaian dengan Mushaf Standar Indonesia oleh penelaah (lihat `docs/licensing/`).

## Terjemahan
- **Indonesia**: **Al-Qur'an dan Terjemahannya (Kementerian Agama RI)** (`id.indonesian`, Tanzil.net, pembaruan 4 Juni 2010), dari paket npm `tanzil` (`public/trans-id.txt`). Disertakan atas keputusan pemilik produk untuk fitur Personal yang gratis; izin tertulis Kemenag belum dikonfirmasi.
- **English**: **Saheeh International** (`en.sahih`, melalui alquran.cloud / Tanzil.net), bidang `en` untuk seluruh 6.236 ayat.

Anotasi tajwid (`tj`) untuk seluruh 6.236 ayat dibuat oleh pengklasifikasi tajwid Moeslim PM
(`packages/personal_core/tool/annotate_tajweed.dart`); teks & terjemahan tidak diubah. Lihat `docs/tajwid-warna.md`.
