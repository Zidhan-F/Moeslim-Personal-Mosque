# Register Lisensi Konten Moeslim PM

Prinsip (ADR 0005): fitur **Personal** gratis & non-komersial; **Mosque** fitur tambahan berbayar dalam
aplikasi yang sama. Konten pihak ketiga hanya dipakai di fitur Personal, selalu dengan atribusi
(halaman *Tentang & Lisensi*), dan tidak dipakai di Mosque/TV Display.

| Konten | Sumber | Lisensi / dasar izin | Butuh konfirmasi? | Status |
|---|---|---|---|---|
| Teks Al-Qur'an (Uthmani) | Tanzil Project (tanzil.net) | Ketentuan Tanzil: salin apa adanya, cantumkan sumber & tautan | Tidak (izin eksplisit untuk aplikasi apa pun). Verifikasi ulang teks ketentuan di tanzil.net/download | **Terpasang** (`apps/mobile/assets/quran/`, lihat SOURCE.md) |
| Font mushaf Amiri Quran | Amiri Project | SIL OFL 1.1 | Tidak | **Terpasang** |
| Font Inter | Inter Project | SIL OFL 1.1 | Tidak | **Terpasang** |
| Anotasi tajwid | cpfair/quran-tajweed | CC BY 4.0 (komersial boleh dengan atribusi) | Tidak | **Tertunda teknis** — anotasi resmi dibuat untuk berkas teks Tanzil 2017; terhadap teks terpasang hanya 54% sejajar sehingga importer menolaknya. Perlu dibuat ulang dengan `tajweed_classifier.py` milik proyek tersebut dari teks terpasang (lihat bawah) |
| Terjemahan Indonesia | Kementerian Agama RI ("Al-Qur'an dan Terjemahannya") | Hak cipta Kemenag; distribusi Tanzil umumnya untuk non-komersial | **Ya** | Menunggu izin — `surat-kemenag-terjemahan.md` |
| Telaah/tashih mushaf | Lajnah Pentashihan Mushaf Al-Qur'an (LPMQ) | — | **Ya** (rekomendasi) | Draf permohonan di surat yang sama |
| Audio murattal per ayat | EveryAyah / QuranicAudio / qari terkait | Bervariasi per qari; umumnya non-komersial | **Ya** | Menunggu izin — `surat-izin-audio-murattal.md` |
| Audio 7 Irama (Naghom) | Qari mitra (produksi sendiri) | Perjanjian lisensi | **Ya** (kontrak) | Templat — `perjanjian-lisensi-rekaman-qari.md` |

## Membuat ulang anotasi tajwid (langkah teknis tertunda)
Skrip klasifikasi pihak ketiga belum dijalankan di lingkungan pengembangan ini (perlu persetujuan pemilik
repo untuk menjalankan kode unduhan). Langkah setelah disetujui, di mesin pengembang:

```bash
git clone https://github.com/cpfair/quran-tajweed && cd quran-tajweed
# teks Tanzil-format dari aset terpasang (6236 baris "surah|ayat|teks", basmalah ayat 1 sesuai sumber)
python3 tajweed_classifier.py < quran-text.txt > tajweed-regen.json
cd <repo>/packages/personal_core
dart run tool/import_quran.dart quran-text.txt ../../apps/mobile/assets/quran --strip-basmala --tajweed tajweed-regen.json
```
Importer akan menolak bila kesejajaran < 99,9%. Catatan: posisi anotasi harus dihitung pada teks
**sesudah** basmalah dilepas — jalankan klasifikasi pada teks yang sudah dilepas basmalahnya.

## Atribusi wajib (sudah tampil di aplikasi)
- "Teks Al-Qur'an: Tanzil Quran Text (Uthmani), © Tanzil Project — tanzil.net"
- "Font: Amiri Quran & Inter — SIL Open Font License 1.1"
- Bila anotasi tajwid dipasang: "Anotasi tajwid: cpfair/quran-tajweed, CC BY 4.0"
- Setiap rekaman audio: nama qari, sumber, dan lingkup izin (dibaca otomatis dari katalog audio).
