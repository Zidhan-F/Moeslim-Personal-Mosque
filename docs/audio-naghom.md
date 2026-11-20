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
