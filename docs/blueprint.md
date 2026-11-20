# Moeslim Personal & Masjid — Blueprint v1.1 (ringkasan kerja)

Sumber: *Product Blueprint v1.0* (dokumen konsep) + revisi arsitek v1.1. Dokumen ini
adalah spesifikasi yang mengikat implementasi di repo ini.

## 1. Dua core
| Area | Moeslim Personal | Moeslim Masjid |
|---|---|---|
| Pengguna | Individu, tanpa akun | DKM/takmir, wajib registrasi |
| Koneksi | Offline-first | Cloud |
| Harga | Gratis | Rp59.000/bulan/masjid, semua fitur |
| Data | Lokal di perangkat | PostgreSQL, terisolasi per masjid |
| Akun | — | Maks. 5 pengurus aktif |
| Display | — | Maks. 5 TV Display |

## 2. Personal (MVP)

### Fitur andalan: 7 Jenis Irama (Naghom) Al-Qur'an
Tampil paling atas di Beranda dan menjadi pilihan utama pemutar (Murattal hanya cadangan):
- **Bayyati**: Memiliki 4 tingkat nada, berkarakter lembut, meliuk, dan sering digunakan pada awal atau akhir bacaan.
- **Hijaz**: Berkarakter cepat, lincah (allegro), dengan variasi nada yang tajam.
- **Shaba**: Berkarakter cepat, cenderung mendayu atau menggugah rasa haru, memiliki 4 tingkat nada.
- **Rast**: Memiliki 6 tingkat nada yang ringan dan cepat, sering dipakai untuk azan atau imam shalat.
- **Jiharkah**: Dimulai dengan suara lembut lalu meninggi (2 tingkat nada), sering dipakai saat takbiran.
- **Sika**: Berkarakter tenang, lembut, dan khusyuk dengan 4 jenis nada.
- **Nahawand**: Memiliki 5 tingkat nada yang cocok untuk ayat-ayat bernuansa sedih atau penuh perenungan.

Jadwal sholat (metode dapat disetel, default Kemenag), countdown, penyesuaian menit;
Al-Qur'an (dataset lokal hasil import sumber berlisensi — tidak ditulis tangan), bookmark,
lanjut baca; kiblat; dzikir & tasbih (33/99/100/kustom); kalender Hijriah + koreksi lokal;
tracker ibadah; modul edukasi 7 Naghom (Bayyati, Hijaz, Shaba, Rast, Jiharkah, Sika,
Nahawand) dengan label "perlu telaah qari"; audio murottal per surah/ayat dengan **pilihan 7 irama**
(rekaman berlisensi via katalog, unduh offline, ulang ayat — `docs/audio-naghom.md`); masjid favorit (lokal). Kota manual bila izin
lokasi ditolak.

## 3. Masjid (MVP)
Registrasi akun + masjid (trial 30 hari), deteksi duplikat → review; role
admin/bendahara/pengurus/operator (matriks §08 blueprint); keuangan; agenda,
pengumuman, petugas, inventaris; laporan + ekspor; TV Display; API publik dengan
allowlist; audit log; langganan.

### 3.1 Revisi v1.1 (keputusan arsitek)
1. **Dana terikat**: setiap transaksi wajib punya `fund` (operasional, zakat, infaq,
   wakaf, program). Dana terikat tidak boleh bersaldo negatif.
2. **Akun kas** majemuk (tunai, bank, kotak amal) + transaksi transfer antar-akun.
3. **Nominal integer rupiah**, ledger immutable, koreksi = entri pembalik.
4. **Anti-rotasi kuota pengurus**: maks. 3 aktivasi/reaktivasi per 30 hari.
5. **Verifikasi masjid**: kolom opsional `simas_id` (ID Masjid SIMAS Kemenag) untuk klaim.
6. **Jadwal di Display dihitung lokal** dari koordinat (paket `shared_prayer`), server
   mengirim `server_time` untuk koreksi jam.
7. **Billing provider-agnostic** (`manual`, `google_play`) — jalur final ditetapkan
   sebelum rilis.
8. Kepatuhan **UU PDP No. 27/2022**: data minimum, hapus akun, ekspor.

## 4. FUP
1 GB lampiran (peringatan 80%/95%, unggah berhenti di 100%, transaksi teks tetap jalan);
5 display; 10.000 transaksi/bulan (peringatan, tidak memblokir); 500 agenda+pengumuman
aktif; 5.000 inventaris.

## 5. Langganan
trialing → active → grace (7 hari) → expired. Saat expired: baca & ekspor tetap,
tulis diblokir.

## 6. Offline
Personal penuh offline. Masjid: edit butuh koneksi. Display: tampil dari cache dengan
label "terakhir sinkron".
