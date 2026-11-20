# Pewarnaan Tajwid pada Teks Al-Qur'an

Huruf hijaiyah diwarnai sesuai hukum tajwid (18 aturan: hamzah washal, lam syamsiyah, ghunnah,
idgham bighunnah/bilaghunnah/mutajanisain/mutaqaribain/mimi, ikhfa' haqiqi/syafawi, iqlab,
qalqalah, mad thabi'i/jaiz munfashil/wajib muttashil/lazim/'aridh lissukun, huruf tidak dibaca).
Pengguna dapat mematikan pewarnaan (ikon di halaman surah) dan membuka **Panduan Warna Tajwid**.

## Arsitektur: berbasis anotasi, bukan tebakan
Warna berasal dari **dataset anotasi** — daftar rentang `(awal, akhir, aturan)` per ayat — yang
diimpor bersama teks:

```bash
dart run tool/import_quran.dart <teks.txt> <output-dir> [terjemahan.txt] --tajweed anotasi.json
```

Format anotasi: `[{"surah": 1, "ayah": 1, "annotations": [{"rule": "ikhfa", "start": 10, "end": 14}]}]`
(nama aturan: `hamzat_wasl, lam_shamsiyyah, silent, ghunnah, idghaam_ghunnah, idghaam_no_ghunnah,
idghaam_mutajanisayn, idghaam_mutaqaribayn, idghaam_shafawi, ikhfa, ikhfa_shafawi, iqlab, qalqalah,
madd_2, madd_munfasil, madd_muttasil, madd_6, madd_246`).

Pengaman: aturan tak dikenal dilaporkan; impor **dibatalkan** bila ada posisi di luar panjang teks ayat
(tanda anotasi dibuat untuk edisi teks berbeda).

| Pendekatan | Pro | Kontra |
|---|---|---|
| Anotasi dataset (dipilih) | Akurat sesuai telaah, dapat diaudit, ringan di perangkat | Butuh dataset yang cocok dengan edisi teks |
| Mesin aturan di aplikasi | Tidak butuh dataset | Rasm Utsmani, waqaf, dan pengecualian membuat salah warna = salah ajar |

## Yang perlu ditetapkan penelaah
1. **Edisi teks**: anotasi harus dibuat untuk edisi yang sama. Mushaf Standar Indonesia (Kemenag) berbeda
   konvensi penulisan dengan mushaf Madinah/Tanzil, sehingga anotasi untuk Tanzil tidak otomatis cocok.
   Contoh dataset terbuka untuk teks Tanzil: proyek `quran-tajweed` (cpfair) — periksa lisensinya dan
   cocokkan edisinya. Karena Moeslim Personal non-komersial (ADR 0005), dataset berlisensi terbuka/
   non-komersial dapat dipakai dengan atribusi sesuai ketentuannya.
2. **Palet warna**: satu sumber di `packages/personal_core/lib/src/content/tajweed.dart`; selaraskan dengan
   konvensi mushaf tajwid yang dirujuk agar pengguna tidak bingung.
3. **Uji render** di perangkat: pastikan pewarnaan per huruf tidak memutus sambungan huruf Arab pada font
   mushaf yang dipilih.
