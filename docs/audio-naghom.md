# Audio Murottal dengan Pilihan 7 Irama (Naghom)

Saat memutar Al-Qur'an **per surah atau per ayat**, pengguna memilih satu dari 7 irama
(Bayyati, Hijaz, Shaba, Rast, Jiharkah, Sika, Nahawand). Irama yang belum memiliki rekaman
berlisensi untuk surah tersebut tampil nonaktif.

## Arsitektur
- **Satuan audio = satu berkas per ayat**: `<base_url>/<SSS><AAA>.mp3` (mis. `002255.mp3`).
  Putar ayat = 1 berkas; putar surah = playlist berkas ayat (bisa dimulai dari ayat mana pun).
- **Katalog (`manifest.json`)**: dibundel di `apps/mobile/assets/audio/manifest.json`, dapat diperbarui
  dari CDN via `--dart-define=AUDIO_MANIFEST_URL=…`. Versi tertinggi yang dipakai; disimpan lokal untuk offline.
- **Offline**: unduhan per surah disimpan di direktori aplikasi; pemutar memakai berkas lokal bila ada.
- **Ganti irama saat memutar**: pemutaran berlanjut dari ayat yang sama dengan irama baru.
- Preferensi irama & qari disimpan lokal (tanpa akun).

## Format katalog
```json
{
  "version": 3,
  "recitations": [
    {
      "id": "qari-fulan-bayyati",
      "qari": "Qari Fulan",
      "naghom": "bayyati",
      "base_url": "https://cdn.moeslim.id/audio/qari-fulan/bayyati",
      "license": "Perjanjian lisensi No. 12/2026 — distribusi & unduh offline diizinkan",
      "attribution": "Rekaman Qari Fulan",
      "surahs": [1, 36, 67, 112, 113, 114]
    }
  ]
}
```
- `naghom`: salah satu slug `bayyati|hijaz|shaba|rast|jiharkah|sika|nahawand`.
- `surahs`: daftar nomor surah, atau `"all"`. Setiap surah yang dicantumkan **wajib lengkap per ayat**.
- Entri tanpa `license` atau dengan `naghom` tidak dikenal **diabaikan** oleh aplikasi.

## Proses konten (telaah)
1. Qari/guru tilawah menelaah kurikulum 7 irama dan merekam, minimal Al-Fatihah per irama
   (dipakai sebagai contoh audio di modul Naghom).
2. Penelaah memeriksa ketepatan tajwid & makhraj tiap rekaman — irama tidak boleh mengorbankan tajwid.
3. Arsipkan perjanjian lisensi per qari (hak distribusi, unduh offline, atribusi).
4. Potong per ayat dengan penamaan `SSSAAA.mp3`, unggah ke CDN, tambahkan entri katalog, naikkan `version`.

## Pro & kontra desain
| Pilihan | Pro | Kontra |
|---|---|---|
| Berkas per ayat (dipilih) | Satu sumber untuk mode ayat & surah, ulang ayat presisi, unduhan bertahap | Banyak berkas kecil (6.236 per irama per qari penuh) |
| Berkas per surah + timestamp | Lebih sedikit berkas | Butuh data timing ayat yang akurat; seek kurang presisi |
| Katalog statis di CDN (dipilih) | Tanpa server, cache CDN, offline-first | Pembaruan perlu rilis katalog berversi |
| Katalog via API backend | Bisa dikelola dari dashboard | Menambah ketergantungan online bagi Personal |

## Target: 7 irama di setiap ayat seluruh mushaf

Total produksi per qari: **6.236 ayat × 7 irama = 43.652 berkas ayat**. Aplikasi sudah siap untuk
cakupan penuh; yang perlu disiapkan adalah rekaman. Alat yang tersedia (`packages/personal_core/tool/`):

| Alat | Fungsi |
|---|---|
| `split_surah_audio.dart <audio> <label.txt> <surah> <out>` | Potong rekaman satu surah menjadi `SSSAAA.mp3` (MP3 mono 96 kbps) dari label Audacity (`start⇥end⇥nomor ayat`). Validasi: jumlah label = jumlah ayat, nomor urut, waktu valid |
| `audio_coverage.dart <root> --base-url … --manifest … [--require-all]` | Laporan kelengkapan per qari × irama (x/6.236 ayat, x/114 surah), membuat `manifest.json` (hanya surah yang lengkap per ayat), gagal (exit 1) bila ada irama yang belum lengkap |

Struktur folder produksi:
```
produksi/
  qari-fulan/
    qari.json            {"qari": "Qari Fulan", "license": "…", "attribution": "…"}
    bayyati/001001.mp3 … 114006.mp3
    hijaz/…  shaba/…  rast/…  jiharkah/…  sika/…  nahawand/…
```

Alur per surah per irama: rekam surah utuh → editor menandai batas ayat di Audacity (Label Track,
ekspor `label.txt`) → `split_surah_audio` → telaah tajwid per ayat → `audio_coverage` → unggah ke CDN
→ terbitkan katalog dengan `version` baru. Aplikasi menampilkan cakupan per irama ("Audio: x/114 surah").

### Tahapan rilis yang disarankan
| Fase | Cakupan | Berkas (×7 irama) |
|---|---|---|
| 1 | Al-Fatihah + Juz 30 (surah 78–114) | 571 ayat → 3.997 |
| 2 | Yasin, Al-Kahf, Al-Mulk, Al-Waqi'ah, Ar-Rahman | 397 ayat → 2.779 |
| 3 | Seluruh mushaf (`--require-all` lulus) | 6.236 ayat → 43.652 |

Perkiraan kasar: murattal satu khatam ±20–25 jam; tilawah berirama lebih lambat (±1,5–2×), sehingga
7 irama ≈ 250–350 jam audio bersih per qari (±13 GB pada 96 kbps), belum termasuk waktu telaah.

### Catatan untuk penelaah
Dalam praktik tilawah, qari umumnya berpindah maqam di dalam satu surah. Membaca satu surah penuh
dengan satu irama adalah pendekatan **didaktik** (latihan). Penelaah perlu menyepakati pendekatan ini
dan memastikan irama tidak mengorbankan tajwid, makhraj, dan waqaf.
