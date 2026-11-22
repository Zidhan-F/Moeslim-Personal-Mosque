import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/l10n.dart';
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
    'Terjemahan Inggris: Saheeh International',
    'Teks terjemahan bahasa Inggris en.sahih melalui tanzil.net (Al-Muntada Al-Islami / Abul-Qasim Publishing House).',
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

const contentSourcesEn = <(String, String)>[
  (
    "Qur'an Text: Tanzil Quran Text (Uthmani)",
    'Copyright © Tanzil Project (tanzil.net). Copied verbatim; the Basmalah is displayed as a surah header rather '
        'than part of verse 1.',
  ),
  (
    "Indonesian Translation: Al-Qur'an dan Terjemahannya (Kementerian Agama RI)",
    'Indonesian translation text id.indonesian via tanzil.net (updated June 4, 2010).',
  ),
  (
    'English Translation: Saheeh International',
    'English translation text en.sahih via tanzil.net (Al-Muntada Al-Islami / Abul-Qasim Publishing House).',
  ),
  (
    'Tajweed Annotations: Moeslim PM Classifier',
    'Automatically tagged over the Tanzil text for 6,236 verses (18 tajweed rules aligned with '
        'cpfair/quran-tajweed). Provided as a learning aid; continue verifying your recitation with a qualified teacher.',
  ),
  (
    'Daily Duas & Supplications (229 duas)',
    "Based on Hisnul Muslim (Shaykh Sa'id ibn Ali ibn Wahf Al-Qahtani) and the EQuran.id Doa & Dzikir API "
        '(equran.id/api/doa).',
  ),
  (
    'Prayer Times & Hijri Calendar',
    'Calculated locally (offline) using astronomical algorithms supporting Kemenag RI, MWL, ISNA, Umm al-Qura, '
        'Egyptian, and JAKIM methods. Hijri dates use tabular arithmetic and may differ from official moonsighting '
        '(day adjustment available in Prayer Settings).',
  ),
  (
    'Qibla Direction & Magnetic Declination',
    "Bearing and distance to the Ka'bah calculated on the WGS84 ellipsoid with true-north magnetic declination "
        'correction.',
  ),
  ('Mushaf Font: Amiri Quran', '© The Amiri Project Authors (SIL Open Font License 1.1).'),
  ('Interface Font: Inter', '© The Inter Project Authors (SIL Open Font License 1.1).'),
  (
    'Interface Icons: Font Awesome 4',
    '© Dave Gandy (fontawesome.com), SIL Open Font License 1.1. Repackaged as the MoeslimIcons font.',
  ),
  ('Illustrations, Islamic Icons & Visual Assets', 'Moeslim PM Asset Kit, crafted specifically for Moeslim PM.'),
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
    'Terjemahan Al-Qur\'an Bahasa Inggris (Saheeh International)',
    'Teks en.sahih melalui tanzil.net. Dipakai untuk fitur Moeslim Personal yang gratis dan non-komersial dengan atribusi.',
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

const contentLicensesEn = <(String, String)>[
  (
    "Qur'an Text (Tanzil Project)",
    'Tanzil distribution terms: text is copied verbatim with attribution to Tanzil Project (tanzil.net).',
  ),
  (
    "Indonesian Qur'an Translation (Kemenag RI)",
    'Copyright Kementerian Agama RI. Used for free, non-commercial Moeslim Personal features with attribution.',
  ),
  (
    "English Qur'an Translation (Saheeh International)",
    'en.sahih text via tanzil.net. Used for free, non-commercial Moeslim Personal features with attribution.',
  ),
  (
    'Daily Duas (EQuran.id & Hisnul Muslim)',
    'Free, non-commercial use with source attribution.',
  ),
  (
    'Fonts & Interface Icons (SIL OFL 1.1)',
    'Amiri Quran, Inter, and Font Awesome 4 UI glyphs in MoeslimIcons are licensed under SIL Open Font License 1.1.',
  ),
  (
    'Tajweed Annotations & Moeslim PM Asset Kit',
    'Created and owned by the Moeslim PM project.',
  ),
];

class AboutLicensesPage extends ConsumerStatefulWidget {
  const AboutLicensesPage({super.key});

  static const statement =
      'Moeslim Personal adalah aplikasi non-komersial: gratis selamanya, tanpa iklan, tanpa pembelian '
      'dalam aplikasi, tanpa fitur berbayar, dan tidak menjual atau melacak data pengguna. '
      'Data ibadah pribadi hanya tersimpan di perangkat Anda.';

  static const statementEn =
      'Moeslim Personal is a non-commercial app: free forever, with no ads, no in-app purchases, '
      'no paid features, and no selling or tracking of user data. '
      'Personal worship records stay solely on your device.';

  static String statementFor(AppLanguage lang) => lang == AppLanguage.en ? statementEn : statement;

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
    final lang = context.lang;
    final manifestAsync = ref.watch(audioManifestProvider);
    final manifest = manifestAsync.value ?? AudioManifest.empty;
    final dailyDuaCount = ref.watch(dailyDuasProvider).value?.length ?? 229;
    final totalAyahs = surahs.fold<int>(0, (sum, s) => sum + s.ayahCount);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final sources = lang == AppLanguage.en ? contentSourcesEn : contentSources;
    final licenses = lang == AppLanguage.en ? contentLicensesEn : contentLicenses;

    final tocEntries = <(String, String, GlobalKey)>[
      ('1', context.tr('Daftar Isi Konten', 'Feature Directory'), _catalogKey),
      ('2', context.tr('Referensi & Sumber', 'References & Sources'), _referencesKey),
      ('3', context.tr('Audio Murottal & Adzan', 'Recitation & Adhan Audio'), _audioKey),
      ('4', context.tr('Lisensi & Ketentuan', 'Licenses & Terms'), _licensesKey),
    ];

    final contentCatalog = <(IconData, String, String)>[
      (
        MoeslimIcons.quranTerbuka,
        context.tr("Al-Qur'an & Tajwid", "Qur'an & Tajweed"),
        context.tr(
          '${surahs.length} surah, $totalAyahs ayat teks Arab Utsmani, terjemahan Indonesia, '
              '${TajweedRule.values.length} hukum tajwid warna, penanda ayat, dan pemutar murottal.',
          '${surahs.length} surahs, $totalAyahs verses in Uthmani Arabic script, Indonesian & English translations, '
              '${TajweedRule.values.length} color-coded tajweed rules, verse bookmarks, and recitation player.',
        ),
      ),
      (
        MoeslimIcons.zikr,
        context.tr('Doa & Dzikir', 'Duas & Dhikr'),
        context.tr(
          '$dailyDuaCount doa harian & aktivitas, ${quranicDuaRanges.length} doa dalam Al-Qur\'an, '
              'serta ${dzikirList.length} bacaan dzikir dengan tasbih digital.',
          "$dailyDuaCount daily duas, ${quranicDuaRanges.length} Qur'anic supplications, "
              'and ${dzikirList.length} dhikr phrases with a digital tasbih.',
        ),
      ),
      (
        MoeslimIcons.waktuSholat,
        context.tr('Jadwal Salat & Alarm Adzan', 'Prayer Times & Adhan Alerts'),
        context.tr(
          'Jadwal 5 waktu dan syuruq berbasis GPS atau ${indonesianCities.length} kota Indonesia, '
              '${CalculationMethod.values.length} metode perhitungan, serta ${adzanMuadzins.length} pilihan suara adzan offline.',
          'Five daily prayers and sunrise via GPS or ${indonesianCities.length} Indonesian cities, '
              '${CalculationMethod.values.length} calculation methods, and ${adzanMuadzins.length} offline adhan voices.',
        ),
      ),
      (
        MoeslimIcons.kiblat,
        context.tr('Arah Kiblat & Kalender Hijriah', 'Qibla Direction & Hijri Calendar'),
        context.tr(
          'Kompas arah kiblat berbasis GPS serta kalender Hijriah beserta daftar hari besar Islam.',
          'GPS-based Qibla compass and Hijri calendar with major Islamic dates.',
        ),
      ),
      (
        MoeslimIcons.centangKotak,
        context.tr('Catatan Ibadah & Masjid Diikuti', 'Worship Tracker & Followed Mosques'),
        context.tr(
          'Checklist salat 5 waktu, target tilawah, streak, grafik mingguan, serta agenda dan pengumuman masjid publik.',
          'Five daily prayer checklist, recitation targets, streaks, weekly charts, and public mosque schedules and announcements.',
        ),
      ),
      (
        MoeslimIcons.masjid,
        context.tr('Moeslim Mosque (Opsional)', 'Moeslim Mosque (Optional)'),
        context.tr(
          'Modul terpisah untuk pengurus masjid: kas, agenda kegiatan, jadwal petugas, inventaris, pengurus, dan TV Display.',
          'Separate module for mosque managers: treasury, event calendar, staff schedules, inventory, committee directory, and TV Display.',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Tentang', 'About')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: BrandLogo(variant: BrandLogoVariant.stacked, height: 128)),
            const SizedBox(height: 8),
            Text(
              context.tr('Moeslim PM • Versi $appVersion', 'Moeslim PM • Version $appVersion'),
              textAlign: TextAlign.center,
              style: t.titleSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            OrnamentCard(
              child: Text(AboutLicensesPage.statementFor(lang), style: t.bodyMedium?.copyWith(height: 1.45)),
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
                        Text(
                          context.tr('Daftar Isi', 'Table of Contents'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
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
            SectionHeader(context.tr('1. Daftar Isi Konten', '1. Feature Directory'), key: _catalogKey),
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
            SectionHeader(context.tr('2. Referensi & Sumber', '2. References & Sources'), key: _referencesKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < sources.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16),
                    ListTile(
                      title: Text(sources[i].$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(sources[i].$2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader(context.tr('3. Audio Murottal & Adzan', '3. Recitation & Adhan Audio'), key: _audioKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      context.tr('Rekaman Murottal', 'Recitation Recordings'),
                      style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (manifestAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (manifestAsync.hasError)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text(
                        context.tr(
                          'Gagal memuat daftar rekaman: ${manifestAsync.error}',
                          'Failed to load recitation list: ${manifestAsync.error}',
                        ),
                      ),
                    )
                  else if (manifest.recitations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text(
                        context.tr('Belum ada rekaman murottal terpasang.', 'No recitation recordings installed yet.'),
                      ),
                    )
                  else
                    for (final r in manifest.recitations)
                      ListTile(
                        leading: Icon(MoeslimIcons.audio, color: scheme.primary),
                        title: Text(r.attribution.isNotEmpty ? r.attribution : r.qari),
                        subtitle: Text(
                          context.tr(
                            'Murattal • ${r.qari}\nLisensi: ${r.license}',
                            'Recitation • ${r.qari}\nLicense: ${r.license}',
                          ),
                        ),
                        isThreeLine: true,
                      ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      context.tr('Audio Adzan Bawaan', 'Built-in Adhan Audio'),
                      style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final m in adzanMuadzins)
                    ListTile(
                      dense: true,
                      leading: Icon(MoeslimIcons.adzan, color: scheme.primary),
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${m.originFor(lang)} • ${m.styleFor(lang)}'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader(context.tr('4. Lisensi & Ketentuan', '4. Licenses & Terms'), key: _licensesKey),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < licenses.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16),
                    ListTile(
                      title: Text(licenses[i].$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(licenses[i].$2),
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    key: const Key('open-oss-licenses'),
                    leading: Icon(MoeslimIcons.laporan, color: scheme.primary),
                    title: Text(
                      context.tr('Lisensi Pustaka Sumber Terbuka', 'Open-Source Library Licenses'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      context.tr(
                        'Daftar lisensi paket Flutter dan Dart yang digunakan aplikasi',
                        'Licenses for Flutter and Dart packages used by this app',
                      ),
                    ),
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
              context.tr(
                'Moeslim Mosque adalah fitur tambahan opsional untuk pengurus masjid yang berbayar per masjid. '
                    'Fitur ini terpisah dari fitur Personal, tidak memakai konten berlisensi non-komersial, dan '
                    'tidak diperlukan untuk memakai Moeslim Personal.',
                'Moeslim Mosque is an optional add-on for mosque managers billed per mosque. '
                    'It is separate from Personal features, does not use non-commercially licensed content, and '
                    'is never required to use Moeslim Personal.',
              ),
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
