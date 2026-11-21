# Register Lisensi Konten Moeslim PM

> Keputusan pemilik produk (20 Nov 2026): terjemahan dan audio publik dipasang langsung tanpa menunggu
> surat izin. Surat di folder ini tetap tersedia bila diperlukan di kemudian hari.

Prinsip (ADR 0005): fitur **Personal** gratis & non-komersial; **Mosque** fitur tambahan berbayar dalam
aplikasi yang sama. Konten pihak ketiga hanya dipakai di fitur Personal, selalu dengan atribusi
(halaman *Tentang & Lisensi*), dan tidak dipakai di Mosque/TV Display.

| Konten | Sumber | Lisensi / dasar izin | Butuh konfirmasi? | Status |
|---|---|---|---|---|
| Teks Al-Qur'an (Uthmani) | Tanzil Project (tanzil.net) | Ketentuan Tanzil: salin apa adanya, cantumkan sumber & tautan | Tidak (izin eksplisit untuk aplikasi apa pun). Verifikasi ulang teks ketentuan di tanzil.net/download | **Terpasang** (`apps/mobile/assets/quran/`, lihat SOURCE.md) |
| Font mushaf Amiri Quran | Amiri Project | SIL OFL 1.1 | Tidak | **Terpasang** |
| Font Inter | Inter Project | SIL OFL 1.1 | Tidak | **Terpasang** |
| Ikon UI (font `MoeslimIcons`) | Font Awesome 4 (Dave Gandy) | SIL OFL 1.1 — `packages/moeslim_brand/fonts/OFL-MoeslimIcons.txt` | Tidak | **Terpasang** |
| Ilustrasi, ikon Islami, pola, latar, elemen fitur | Moeslim PM Asset Kit (dibuat untuk proyek) | Milik proyek | Tidak | **Terpasang** (`packages/moeslim_brand/assets/`) |
| Anotasi tajwid | Pengklasifikasi Moeslim PM (semantik selaras cpfair/quran-tajweed; data & kode cpfair tidak disalin) | Milik proyek | Telaah guru tajwid disarankan | **Terpasang** — 6.236 ayat, lihat `docs/tajwid-warna.md` |
| Terjemahan Indonesia | Kementerian Agama RI ("Al-Qur'an dan Terjemahannya") | Hak cipta Kemenag; distribusi Tanzil umumnya untuk non-komersial | Keputusan pemilik produk: pasang langsung | **Terpasang** (Tanzil `id.indonesian`), atribusi tampil; izin tertulis belum ada |
| Doa harian & aktivitas (229 doa) | EQuran.id Doa & Dzikir API (`equran.id/api/doa`) + Hisnul Muslim (Bab 12–14) | Gratis & non-komersial dengan atribusi; tidak diperjualbelikan | Tidak (fitur Personal non-komersial) | **Terpasang** (`apps/mobile/assets/doa/daily_duas.json`) |
| Telaah/tashih mushaf | Lajnah Pentashihan Mushaf Al-Qur'an (LPMQ) | — | **Ya** (rekomendasi) | Draf permohonan di surat yang sama |
| Audio murattal per ayat | EveryAyah / QuranicAudio / qari terkait | Bervariasi per qari; umumnya non-komersial | Keputusan pemilik produk: pasang langsung | **Terpasang** di katalog: Alafasy, Al-Husary, Abdul Basit, Al-Minshawi (streaming dari everyayah.com), atribusi tampil; izin tertulis belum ada |
| Audio murattal produksi sendiri (opsional) | Qari mitra | Perjanjian lisensi | **Ya** (kontrak) | Templat — `perjanjian-lisensi-rekaman-qari.md` |

## Membuat ulang anotasi tajwid
```bash
cd packages/personal_core && dart run tool/annotate_tajweed.dart
```

## Atribusi wajib (sudah tampil di aplikasi)
- "Teks Al-Qur'an: Tanzil Quran Text (Uthmani), © Tanzil Project — tanzil.net"
- "Font: Amiri Quran & Inter — SIL Open Font License 1.1"
- "Ikon antarmuka: Font Awesome 4 © Dave Gandy — SIL Open Font License 1.1"
- "Anotasi tajwid: pengklasifikasi Moeslim PM — perlu telaah guru tajwid"
- Setiap rekaman audio: nama qari, sumber, dan lingkup izin (dibaca otomatis dari katalog audio).
