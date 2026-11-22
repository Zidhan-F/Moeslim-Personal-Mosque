import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../ui/components.dart';
import '../ibadah/doa_pages.dart';
import '../quran/audio/audio_providers.dart';

const appVersion = '0.1.0';

/// Seluruh referensi sumber konten, perhitungan, font, ikon, dan aset aplikasi.
/// Semua informasi referensi & lisensi dipusatkan di halaman Tentang ini.
const contentSources = <(String, String)>[
  (
    'Teks Al-Qur\'an: Tanzil Quran Text (Uthmani)',
    'Hak cipta © Tanzil Project (tanzil.net). Disalin apa adanya (verbatim); basmalah ditampilkan sebagai '
        'pembuka surah, bukan bagian ayat 1.',
  ),
  (
    'Terjemahan: Al-Qur\'an dan Terjemahannya (Kementerian Agama RI)',
    'Teks terjemahan id.indonesian melalui tanzil.net (pembaruan 4 Juni 2010).',
  ),
  (
    'Anotasi tajwid: pengklasifikasi Moeslim PM',
    'Ditandai otomatis atas teks Tanzil untuk 6.236 ayat (18 hukum tajwid; aturan disamakan dengan '
        'cpfair/quran-tajweed). Alat bantu belajar; tetap pelajari dan tashih bacaan bersama guru tajwid.',
  ),
  (
    'Doa harian & aktivitas (229 doa)',
    'Merujuk kitab Hisnul Muslim (Syaikh Sa\'id bin Ali bin Wahf Al-Qahthani) dan EQuran.id Doa & Dzikir API '
        '(equran.id/api/doa).',
  ),
  (
    'Perhitungan waktu salat & kalender Hijriah',
    'Dihitung secara lokal (offline) menggunakan algoritma astronomi dengan pilihan parameter Kemenag RI, '
        'MWL, ISNA, Umm Al-Qura, Mesir, dan Karachi. Tanggal Hijriah dihitung secara aritmetika dan dapat berbeda '
        'dengan penetapan sidang isbat (koreksi hari tersedia di Pengaturan Jadwal).',
  ),
  (
    'Arah kiblat & deklinasi magnetik',
    'Perhitungan sudut dan jarak ke Ka\'bah menggunakan rumus geodetik elipsoid WGS84 serta koreksi deklinasi '
        'magnetik utara sejati.',
  ),
  ('Font mushaf: Amiri Quran', '© The Amiri Project Authors (SIL Open Font License 1.1).'),
  ('Font antarmuka: Inter', '© The Inter Project Authors (SIL Open Font License 1.1).'),
  (
    'Ikon antarmuka: Font Awesome 4',
    '© Dave Gandy (fontawesome.com), SIL Open Font License 1.1. Dikemas ulang sebagai font MoeslimIcons.',
  ),
  ('Ilustrasi, ikon Islami & aset visual', 'Moeslim PM Asset Kit, dibuat khusus untuk Moeslim PM.'),
];

/// Ringkasan ketentuan lisensi konten & aset aplikasi.
const contentLicenses = <(String, String)>[
  (
    'Teks Al-Qur\'an (Tanzil Project)',
    'Ketentuan distribusi Tanzil: teks disalin apa adanya dengan mencantumkan sumber Tanzil Project (tanzil.net).',
  ),
  (
    'Terjemahan Al-Qur\'an (Kemenag RI)',
    'Hak cipta Kemenag RI. Dipakai untuk fitur Moeslim Personal yang gratis dan non-komersial dengan atribusi.',
  ),
  (
    'Doa Harian (EQuran.id & Hisnul Muslim)',
    'Penggunaan gratis dan non-komersial dengan atribusi sumber.',
  ),
  (
    'Font & Ikon Antarmuka (SIL OFL 1.1)',
    'Amiri Quran, Inter, dan glyph UI Font Awesome 4 dalam MoeslimIcons berlisensi SIL Open Font License 1.1.',
  ),
  (
    'Anotasi Tajwid & Moeslim PM Asset Kit',
    'Dibuat dan dimiliki oleh proyek Moeslim PM.',
  ),
];

class AboutLicensesPage extends ConsumerStatefulWidget {
  const AboutLicensesPage({super.key});

  static const statement =
      'Moeslim Personal adalah aplikasi non-komersial: gratis selamanya, tanpa iklan, tanpa pembelian '
      'dalam aplikasi, tanpa fitur berbayar, dan tidak menjual atau melacak data pengguna. '
      'Data ibadah pribadi hanya tersimpan di perangkat Anda.';

  @override
  ConsumerState<AboutLicensesPage> createState() => _AboutLicensesPageState();
}

class _AboutLicensesPageState extends ConsumerState<AboutLicensesPage> {
  final _tocKey = GlobalKey();
  final _catalogKey = GlobalKey();
  final _referencesKey = GlobalKey();
  final _audioKey = GlobalKey();
  final _licensesKey = GlobalKey();

  Future<void> _jumpTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final manifestAsync = ref.watch(audioManifestProvider);
    final manifest = manifestAsync.value ?? AudioManifest.empty;
    final dailyDuaCount = ref.watch(dailyDuasProvider).value?.length ?? 229;
    final totalAyahs = surahs.fold<int>(0, (sum, s) => sum + s.ayahCount);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final tocEntries = <(String, String, GlobalKey)>[
      ('1', 'Daftar Isi Konten', _catalogKey),
      ('2', 'Referensi & Sumber', _referencesKey),
      ('3', 'Audio Murottal & Adzan', _audioKey),
      ('4', 'Lisensi & Ketentuan', _licensesKey),
    ];

    final contentCatalog = <(IconData, String, String)>[
      (
        MoeslimIcons.quranTerbuka,
        'Al-Qur\'an & Tajwid',
        '${surahs.length} surah, $totalAyahs ayat teks Arab Utsmani, terjemahan Indonesia, '
            '${TajweedRule.values.length} hukum tajwid warna, penanda ayat, dan pemutar murottal.',
      ),
      (
        MoeslimIcons.zikr,
        'Doa & Dzikir',
        '$dailyDuaCount doa harian & aktivitas, ${quranicDuaRanges.length} doa dalam Al-Qur\'an, '
            'serta ${dzikirList.length} bacaan dzikir dengan tasbih digital.',
      ),
      (
        MoeslimIcons.waktuSholat,
        'Jadwal Salat & Alarm Adzan',
        'Jadwal 5 waktu dan syuruq berbasis GPS atau ${indonesianCities.length} kota Indonesia, '
            '${CalculationMethod.values.length} metode perhitungan, serta ${adzanMuadzins.length} pilihan suara adzan offline.',
      ),
      (
        MoeslimIcons.kiblat,
        'Arah Kiblat & Kalender Hijriah',
        'Kompas arah kiblat berbasis GPS serta kalender Hijriah beserta daftar hari besar Islam.',
      ),
      (
        MoeslimIcons.centangKotak,
        'Catatan Ibadah & Masjid Diikuti',
        'Checklist salat 5 waktu, target tilawah, streak, grafik mingguan, serta agenda dan pengumuman masjid publik.',
      ),
      (
        MoeslimIcons.masjid,
        'Moeslim Mosque (Opsional)',
        'Modul terpisah untuk pengurus masjid: kas, agenda kegiatan, jadwal petugas, inventaris, pengurus, dan TV Display.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: BrandLogo(variant: BrandLogoVariant.stacked, height: 128)),
            const SizedBox(height: 8),
            Text(
              'Moeslim PM • Versi $appVersion',
              textAlign: TextAlign.center,
              style: t.titleSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            OrnamentCard(
              child: Text(AboutLicensesPage.statement, style: t.bodyMedium?.copyWith(height: 1.45)),
            ),
            const SizedBox(height: 16),
            Card(
              key: _tocKey,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(MoeslimIcons.daftar, size: 18, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text('Daftar Isi', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final (numLabel, title, targetKey) in tocEntries)
                      ListTile(
                        key: Key('toc-$numLabel'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: scheme.primary.withValues(alpha: .12),
                          child: Text(
                            numLabel,
                            style: TextStyle(color: scheme.primary, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
                        onTap: () => _jumpTo(targetKey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader('1. Daftar Isi Konten', key: _catalogKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < contentCatalog.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Icon(contentCatalog[i].$1, color: scheme.primary),
                      title: Text(contentCatalog[i].$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(contentCatalog[i].$3),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader('2. Referensi & Sumber', key: _referencesKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < contentSources.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16),
                    ListTile(
                      title: Text(contentSources[i].$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(contentSources[i].$2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader('3. Audio Murottal & Adzan', key: _audioKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text('Rekaman Murottal', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  if (manifestAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (manifestAsync.hasError)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text('Gagal memuat daftar rekaman: ${manifestAsync.error}'),
                    )
                  else if (manifest.recitations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text('Belum ada rekaman murottal terpasang.'),
                    )
                  else
                    for (final r in manifest.recitations)
                      ListTile(
                        leading: Icon(MoeslimIcons.audio, color: scheme.primary),
                        title: Text(r.attribution.isNotEmpty ? r.attribution : r.qari),
                        subtitle: Text('Murattal • ${r.qari}\nLisensi: ${r.license}'),
                        isThreeLine: true,
                      ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text('Audio Adzan Bawaan', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  for (final m in adzanMuadzins)
                    ListTile(
                      dense: true,
                      leading: Icon(MoeslimIcons.adzan, color: scheme.primary),
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${m.origin} • ${m.style}'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader('4. Lisensi & Ketentuan', key: _licensesKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < contentLicenses.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16),
                    ListTile(
                      title: Text(contentLicenses[i].$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(contentLicenses[i].$2),
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    key: const Key('open-oss-licenses'),
                    leading: Icon(MoeslimIcons.laporan, color: scheme.primary),
                    title: const Text('Lisensi Pustaka Sumber Terbuka', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Daftar lisensi paket Flutter dan Dart yang digunakan aplikasi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Moeslim PM',
                      applicationVersion: appVersion,
                      applicationLegalese: 'Moeslim Personal & Moeslim Mosque',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Moeslim Mosque adalah fitur tambahan opsional untuk pengurus masjid yang berbayar per masjid. '
              'Fitur ini terpisah dari fitur Personal, tidak memakai konten berlisensi non-komersial, dan '
              'tidak diperlukan untuk memakai Moeslim Personal.',
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
