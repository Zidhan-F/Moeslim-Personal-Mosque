# Audio Murottal

Pemutar Al-Qur'an **per surah atau per ayat** dengan pilihan **qari murattal** (bacaan tartil).
Fitur 7 Irama (Naghom) sudah dihapus; lihat ADR 0006.

## Arsitektur
- **Satuan audio = satu berkas per ayat**: `<base_url>/<SSS><AAA>.mp3` (mis. `002255.mp3`).
  Putar ayat = 1 berkas; putar surah = playlist berkas ayat (bisa dimulai dari ayat mana pun).
- **Katalog (`manifest.json`)**: dibundel di `apps/mobile/assets/audio/manifest.json` (≈2 KB, audio
  tidak ikut dibundel), dapat diperbarui dari CDN via `--dart-define=AUDIO_MANIFEST_URL=…`.
  Versi tertinggi yang dipakai; disimpan lokal untuk offline.
- **Offline**: unduhan per surah disimpan di direktori aplikasi; pemutar memakai berkas lokal bila ada.
- **Ganti qari saat memutar**: pemutaran berlanjut dari ayat yang sama dengan qari baru.
- Qari terakhir disimpan lokal (tanpa akun). Bila qari itu tidak mencakup surah, qari pertama yang ada dipakai.

## Format katalog
```json
{
  "version": 3,
  "recitations": [
    {
      "id": "qari-fulan-murattal",
      "qari": "Qari Fulan",
      "kind": "murattal",
      "base_url": "https://cdn.moeslim.id/audio/qari-fulan/murattal",
      "license": "Perjanjian lisensi No. 12/2026: distribusi & unduh offline diizinkan",
      "attribution": "Rekaman Qari Fulan",
      "surahs": "all"
    }
  ]
}
```
- `kind` wajib `"murattal"`; entri lain (termasuk entri irama dari katalog lama) dan entri tanpa `license` **diabaikan**.
- `surahs`: daftar nomor surah, atau `"all"`. Setiap surah yang dicantumkan **wajib lengkap per ayat**.
- Folder produksi: `<root>/<id-qari>/murattal/SSSAAA.mp3`, dicek & dibuat katalognya oleh
  `packages/personal_core/tool/audio_coverage.dart`; rekaman satu surah dipotong per ayat dengan
  `tool/split_surah_audio.dart` (label Audacity).

## Sumber murattal
Katalog bawaan memakai koleksi publik EveryAyah (Alafasy, Al-Husary, Abdul Basit, Al-Minshawi) dengan
atribusi di halaman *Tentang & Lisensi*. Karena **Moeslim Personal non-komersial** (ADR 0005), rekaman
dengan izin non-komersial dipakai sesuai ketentuan sumbernya. Rekaman ini tidak boleh dipakai di fitur
berbayar Moeslim Mosque. Untuk keandalan offline, sebaiknya berkas di-mirror ke CDN Moeslim sesuai izin.
