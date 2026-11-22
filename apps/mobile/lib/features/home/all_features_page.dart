import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import '../../ui/hijab_art.dart';
import '../ibadah/asmaul_husna_page.dart';
import '../ibadah/astronomy_qibla_fiqih_page.dart';
import '../ibadah/doa_pages.dart';
import '../ibadah/family_education_page.dart';
import '../ibadah/fasting_tracker_page.dart';
import '../ibadah/fiqih_guide_page.dart';
import '../ibadah/guided_dzikir_page.dart';
import '../ibadah/hadith_page.dart';
import '../ibadah/hijri_page.dart';
import '../ibadah/manasik_page.dart';
import '../ibadah/muhasabah_journal_page.dart';
import '../ibadah/muslimah_mode_page.dart';
import '../ibadah/qibla_page.dart';
import '../ibadah/seasonal_ramadan_page.dart';
import '../ibadah/sedekah_tracker_page.dart';
import '../ibadah/share_card_page.dart';
import '../ibadah/sirah_page.dart';
import '../ibadah/spiritual_care_page.dart';
import '../ibadah/tasbih_page.dart';
import '../ibadah/tracker_page.dart';
import '../ibadah/utility_accessibility_page.dart';
import '../ibadah/zakat_faraid_page.dart';
import '../more/about_licenses_page.dart';
import '../more/backup_restore_page.dart';
import '../more/followed_mosques_page.dart';
import '../more/nearby_mosques_gps_page.dart';
import '../prayer/auto_dnd_page.dart';
import '../prayer/home_widget_page.dart';
import '../prayer/prayer_page.dart';
import '../quran/khatam_planner_page.dart';
import '../quran/murottal_page.dart';
import '../quran/quran_study_suite_page.dart';
import '../quran/tafsir_search_page.dart';
import '../quran/tahfidz_page.dart';
import '../quran/tajweed_learning_page.dart';
import '../quran/tajweed_view.dart';

class _FeatureEntry {
  final String id;
  final String labelId;
  final String labelEn;
  final String keywords;
  final BrandTile? tile;
  final IconData? icon;
  final Widget? art;
  final VoidCallback Function(BuildContext context) onOpen;

  const _FeatureEntry({
    required this.id,
    required this.labelId,
    required this.labelEn,
    required this.keywords,
    this.tile,
    this.icon,
    this.art,
    required this.onOpen,
  });

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : labelId;
}

class _FeatureGroup {
  final String titleId;
  final String titleEn;
  final List<_FeatureEntry> items;
  const _FeatureGroup(this.titleId, this.titleEn, this.items);

  String titleFor(AppLanguage lang) => lang == AppLanguage.en ? titleEn : titleId;
}

/// Halaman "Semua Fitur" yang dibuka dari ikon Lihat Semua pada Menu Cepat Beranda.
/// Menampilkan seluruh fitur Moeslim Personal yang tersedia dalam pengelompokan rapi.
class AllFeaturesPage extends StatefulWidget {
  final void Function(int tab) onNavigate;
  const AllFeaturesPage({super.key, required this.onNavigate});

  @override
  State<AllFeaturesPage> createState() => _AllFeaturesPageState();
}

class _AllFeaturesPageState extends State<AllFeaturesPage> {
  String _query = '';

  VoidCallback _pushPage(BuildContext context, Widget Function() builder) =>
      () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder()));

  VoidCallback _switchTab(BuildContext context, int tab) => () {
    Navigator.of(context).pop();
    widget.onNavigate(tab);
  };

  List<_FeatureGroup> _buildGroups() => [
    _FeatureGroup("Al-Qur'an & Studi", "Qur'an & Study", [
      _FeatureEntry(
        id: 'alquran',
        labelId: "Al-Qur'an",
        labelEn: "Qur'an",
        keywords: 'mushaf surah juz baca quran read recitation',
        tile: BrandTile.alquran,
        onOpen: (c) => _switchTab(c, 1),
      ),
      _FeatureEntry(
        id: 'murottal',
        labelId: "Murottal Al-Qur'an",
        labelEn: "Qur'an Audio",
        keywords: 'audio qari dengarkan tilawah murottal reciter listen recitation',
        icon: MoeslimIcons.audio,
        onOpen: (c) => _pushPage(c, () => const MurottalPage()),
      ),
      _FeatureEntry(
        id: 'tafsir-search',
        labelId: 'Tafsir & Cari Ayat',
        labelEn: 'Tafsir & Verse Search',
        keywords: 'pencarian tematik tadabbur catatan commentary search verse notes',
        icon: MoeslimIcons.pencarian,
        onOpen: (c) => _pushPage(c, () => const TafsirSearchPage()),
      ),
      _FeatureEntry(
        id: 'tahfidz',
        labelId: "Tahfidz & Muraja'ah",
        labelEn: 'Memorization',
        keywords: 'hafalan uji sambung ayat quran tahfidz hifz memorize review',
        icon: MoeslimIcons.target,
        onOpen: (c) => _pushPage(c, () => const TahfidzPage()),
      ),
      _FeatureEntry(
        id: 'khatam',
        labelId: 'Perencana Khatam',
        labelEn: 'Khatam Planner',
        keywords: 'target halaman khatam quran reading plan daily pages completion',
        icon: MoeslimIcons.kalender,
        onOpen: (c) => _pushPage(c, () => const KhatamPlannerPage()),
      ),
      _FeatureEntry(
        id: 'tajwid-belajar',
        labelId: 'Belajar Tajwid',
        labelEn: 'Learn Tajweed',
        keywords: 'makharijul huruf hukum kuis tajwid tajweed articulation rules quiz',
        icon: MoeslimIcons.alquran,
        onOpen: (c) => _pushPage(c, () => const TajweedLearningPage()),
      ),
      _FeatureEntry(
        id: 'tajwid-warna',
        labelId: 'Warna Tajwid',
        labelEn: 'Tajweed Colors',
        keywords: 'panduan legenda warna tajwid tajweed color legend guide',
        icon: MoeslimIcons.keterangan,
        onOpen: (c) => _pushPage(c, () => const TajweedLegendPage()),
      ),
      _FeatureEntry(
        id: 'quran-study',
        labelId: "Pendalaman Qur'an",
        labelEn: "Qur'an Study",
        keywords: 'kata per kata asbabun nuzul flashcard sajdah word by word vocabulary',
        icon: MoeslimIcons.quranTerbuka,
        onOpen: (c) => _pushPage(c, () => const QuranStudySuitePage()),
      ),
      _FeatureEntry(
        id: 'fokus-tilawah',
        labelId: 'Fokus Tilawah',
        labelEn: 'Focus Reading',
        keywords: 'baca otomatis autoscroll tenang distraction free focus reading',
        icon: MoeslimIcons.alquran,
        onOpen: (c) => _pushPage(c, () => const FocusTilawahPage()),
      ),
    ]),
    _FeatureGroup('Salat, Kiblat & Waktu', 'Prayer, Qibla & Time', [
      _FeatureEntry(
        id: 'jadwal-salat',
        labelId: 'Jadwal Salat',
        labelEn: 'Prayer Times',
        keywords: 'waktu sholat subuh dzuhur ashar maghrib isya adzan prayer fajr dhuhr asr isha athan adhan',
        tile: BrandTile.jadwalSholat,
        onOpen: (c) => _pushPage(c, () => const PrayerPage()),
      ),
      _FeatureEntry(
        id: 'arah-kiblat',
        labelId: 'Arah Kiblat',
        labelEn: 'Qibla Direction',
        keywords: 'kompas derajat kabah mekah qibla compass kaaba makkah',
        tile: BrandTile.arahKiblat,
        onOpen: (c) => _pushPage(c, () => const QiblaPage()),
      ),
      _FeatureEntry(
        id: 'astronomi-kiblat',
        labelId: 'Kiblat Matahari & Safar',
        labelEn: 'Solar Qibla & Travel',
        keywords: 'rashdul qiblah peta jama qashar dhuha tahajud solar qibla travel prayer map',
        icon: MoeslimIcons.kompas,
        onOpen: (c) => _pushPage(c, () => const AstronomyQiblaFiqihPage()),
      ),
      _FeatureEntry(
        id: 'auto-dnd',
        labelId: 'Mode Hening (DND)',
        labelEn: 'Silent Mode (DND)',
        keywords: 'senyap otomatis dering jumat salat silent mute auto dnd do not disturb friday',
        icon: MoeslimIcons.bisukan,
        onOpen: (c) => _pushPage(c, () => const AutoDndPage()),
      ),
      _FeatureEntry(
        id: 'home-widget',
        labelId: 'Widget Layar Utama',
        labelEn: 'Home Widget',
        keywords: 'android homescreen jadwal salat home screen widget prayer',
        icon: MoeslimIcons.ponsel,
        onOpen: (c) => _pushPage(c, () => const HomeWidgetPage()),
      ),
      _FeatureEntry(
        id: 'pengaturan-jadwal',
        labelId: 'Lokasi & Metode',
        labelEn: 'Location & Method',
        keywords: 'gps kota kemenag pengaturan salat location city method settings calculation',
        icon: MoeslimIcons.pengaturan,
        onOpen: (c) => _pushPage(c, () => const PrayerSettingsPage()),
      ),
    ]),
    _FeatureGroup('Doa, Dzikir & Hati', 'Duas, Dhikr & Heart', [
      _FeatureEntry(
        id: 'doa-dzikir',
        labelId: 'Doa & Dzikir',
        labelEn: 'Duas & Dhikr',
        keywords: 'doa harian aktivitas hisnul muslim daily supplication prayers fortress',
        tile: BrandTile.doaDzikir,
        onOpen: (c) => _pushPage(c, () => const DoaListPage()),
      ),
      _FeatureEntry(
        id: 'dzikir-terpandu',
        labelId: 'Dzikir Pagi & Petang',
        labelEn: 'Morning & Evening Dhikr',
        keywords: 'al matsurat wirid bada salat terpandu morning evening adhkar guided remembrance',
        icon: MoeslimIcons.matahari,
        onOpen: (c) => _pushPage(c, () => const GuidedDzikirPage()),
      ),
      _FeatureEntry(
        id: 'tasbih',
        labelId: 'Tasbih Digital',
        labelEn: 'Digital Tasbih',
        keywords: 'hitung dzikir target subhanallah counter beads tally dhikr',
        tile: BrandTile.tasbih,
        onOpen: (c) => _pushPage(c, () => const TasbihPage()),
      ),
      _FeatureEntry(
        id: 'asmaul-husna',
        labelId: 'Asmaul Husna',
        labelEn: '99 Names of Allah',
        keywords: '99 nama allah makna kuis asmaul husna names attributes meaning quiz',
        icon: MoeslimIcons.bintang,
        onOpen: (c) => _pushPage(c, () => const AsmaulHusnaPage()),
      ),
      _FeatureEntry(
        id: 'spiritual-care',
        labelId: 'Doa Hati & Ruqyah',
        labelEn: 'Heart Duas & Ruqyah',
        keywords: 'suasana hati shalawat hajat rawatib mood comfort salawat ruqyah protection',
        icon: MoeslimIcons.cinta,
        onOpen: (c) => _pushPage(c, () => const SpiritualCarePage()),
      ),
      _FeatureEntry(
        id: 'share-card',
        labelId: 'Kartu Bagikan Ayat',
        labelEn: 'Verse Share Cards',
        keywords: 'desain poster kutipan dakwah doa share quote card poster image',
        icon: MoeslimIcons.bagikan,
        onOpen: (c) => _pushPage(c, () => const ShareCardPage()),
      ),
    ]),
    _FeatureGroup('Catatan & Ibadah Harian', 'Daily Worship & Logs', [
      _FeatureEntry(
        id: 'catatan-ibadah',
        labelId: 'Catatan Ibadah',
        labelEn: 'Worship Tracker',
        keywords: 'checklist mutabaah streak grafik worship tracker log habits chart',
        tile: BrandTile.catatanIbadah,
        onOpen: (c) => _pushPage(c, () => const TrackerPage()),
      ),
      _FeatureEntry(
        id: 'kalender-hijriah',
        labelId: 'Kalender Hijriah',
        labelEn: 'Hijri Calendar',
        keywords: 'tanggal islam hari besar hijri islamic calendar dates holidays',
        tile: BrandTile.kalenderHijriah,
        onOpen: (c) => _pushPage(c, () => const HijriPage()),
      ),
      _FeatureEntry(
        id: 'puasa-qadha',
        labelId: 'Puasa & Qadha',
        labelEn: 'Fasting & Qadha',
        keywords: 'senin kamis ayyamul bidh utang fidyah fasting monday thursday white days makeup',
        icon: MoeslimIcons.bulan,
        onOpen: (c) => _pushPage(c, () => const FastingTrackerPage()),
      ),
      _FeatureEntry(
        id: 'ramadan',
        labelId: 'Ramadan & Hari Besar',
        labelEn: 'Ramadan & Eid',
        keywords: 'imsakiyah kurban aqiqah idul fitri adha ramadan eid qurbani aqiqah',
        tile: BrandTile.ramadan,
        onOpen: (c) => _pushPage(c, () => const SeasonalRamadanPage()),
      ),
      _FeatureEntry(
        id: 'muslimah',
        labelId: 'Mode Muslimah',
        labelEn: 'Muslimah Mode',
        keywords: 'haid uzur qadha puasa wanita period cycle women fasting tracker',
        art: const HijabWomanArt(size: 40),
        onOpen: (c) => _pushPage(c, () => const MuslimahModePage()),
      ),
      _FeatureEntry(
        id: 'sedekah',
        labelId: 'Pelacak Sedekah',
        labelEn: 'Charity Tracker',
        keywords: 'infaq kebaikan subuh jumat amal sadaqah charity donation giving',
        icon: MoeslimIcons.donasi,
        onOpen: (c) => _pushPage(c, () => const SedekahTrackerPage()),
      ),
      _FeatureEntry(
        id: 'muhasabah',
        labelId: 'Jurnal Muhasabah',
        labelEn: 'Reflection Journal',
        keywords: 'refleksi syukur harian catatan pin muhasabah gratitude diary journal',
        icon: MoeslimIcons.edit,
        onOpen: (c) => _pushPage(c, () => const MuhasabahJournalPage()),
      ),
    ]),
    _FeatureGroup('Ilmu, Fiqih & Keluarga', 'Knowledge, Fiqh & Family', [
      _FeatureEntry(
        id: 'hadits',
        labelId: 'Kitab Hadits',
        labelEn: 'Hadith Library',
        keywords: 'arbain nawawi riyadus shalihin shahih hadith collection authentic sunnah',
        icon: MoeslimIcons.buku,
        onOpen: (c) => _pushPage(c, () => const HadithPage()),
      ),
      _FeatureEntry(
        id: 'fiqih',
        labelId: 'Panduan Fiqih',
        labelEn: 'Fiqh Guide',
        keywords: 'wudhu tayammum salat fardhu sunnah jenazah fiqh wudu prayer funeral guide',
        tile: BrandTile.sajadah,
        onOpen: (c) => _pushPage(c, () => const FiqihGuidePage()),
      ),
      _FeatureEntry(
        id: 'zakat-faraid',
        labelId: 'Zakat & Waris',
        labelEn: 'Zakat & Inheritance',
        keywords: 'kalkulator maal profesi fitrah fidyah faraid zakat calculator wealth inheritance',
        tile: BrandTile.keuangan,
        onOpen: (c) => _pushPage(c, () => const ZakatFaraidPage()),
      ),
      _FeatureEntry(
        id: 'manasik',
        labelId: 'Manasik Haji & Umrah',
        labelEn: 'Hajj & Umrah Guide',
        keywords: 'rukun thawaf sai kaabah umroh hajj umrah pilgrimage tawaf sai rituals',
        icon: MoeslimIcons.kubah,
        onOpen: (c) => _pushPage(c, () => const ManasikPage()),
      ),
      _FeatureEntry(
        id: 'sirah',
        labelId: 'Sirah & 25 Nabi',
        labelEn: 'Seerah & Prophets',
        keywords: 'nabawiyah rasulullah kisah sahabat sejarah seerah prophet stories companions history',
        icon: MoeslimIcons.histori,
        onOpen: (c) => _pushPage(c, () => const SirahPage()),
      ),
      _FeatureEntry(
        id: 'keluarga-edukasi',
        labelId: 'Keluarga & Edukasi',
        labelEn: 'Family & Learning',
        keywords: 'nama bayi hijaiyah kuis glosarium utang baby names arabic alphabet quiz glossary debt',
        icon: MoeslimIcons.jamaah,
        onOpen: (c) => _pushPage(c, () => const FamilyEducationPage()),
      ),
    ]),
    _FeatureGroup('Masjid, Utilitas & Lainnya', 'Mosques, Utilities & More', [
      _FeatureEntry(
        id: 'masjid-diikuti',
        labelId: 'Masjid Diikuti',
        labelEn: 'Followed Mosques',
        keywords: 'agenda pengumuman jamaah masjid followed mosque events announcements',
        tile: BrandTile.masjid,
        onOpen: (c) => _pushPage(c, () => const FollowedMosquesPage()),
      ),
      _FeatureEntry(
        id: 'masjid-gps',
        labelId: 'Masjid Terdekat',
        labelEn: 'Nearby Mosques',
        keywords: 'gps musholla jarak lokasi sekitar nearby mosque prayer room distance map',
        icon: MoeslimIcons.lokasi,
        onOpen: (c) => _pushPage(c, () => const NearbyMosquesGpsPage()),
      ),
      _FeatureEntry(
        id: 'utilitas-halal',
        labelId: 'Lansia, Timer & Halal',
        labelEn: 'Senior, Timer & Halal',
        keywords: 'aksesibilitas itikaf refleksi e-number kode halal accessibility senior focus timer halal additives',
        icon: MoeslimIcons.shield,
        onOpen: (c) => _pushPage(c, () => const UtilityAccessibilityPage()),
      ),
      _FeatureEntry(
        id: 'backup-restore',
        labelId: 'Cadangkan Data',
        labelEn: 'Backup & Restore',
        keywords: 'pulihkan ekspor impor backup lokal restore export import json local',
        icon: MoeslimIcons.database,
        onOpen: (c) => _pushPage(c, () => const BackupRestorePage()),
      ),
      _FeatureEntry(
        id: 'profil',
        labelId: 'Profil & Tampilan',
        labelEn: 'Profile & Display',
        keywords: 'tema gelap terang ukuran huruf nama bahasa profile theme dark light font language',
        icon: MoeslimIcons.profil,
        onOpen: (c) => _switchTab(c, 4),
      ),
      _FeatureEntry(
        id: 'tentang',
        labelId: 'Tentang',
        labelEn: 'About',
        keywords: 'daftar isi referensi lisensi versi about contents references licenses version',
        icon: MoeslimIcons.info,
        onOpen: (c) => _pushPage(c, () => const AboutLicensesPage()),
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final q = _query.trim().toLowerCase();
    final allGroups = _buildGroups();
    final filteredGroups = <_FeatureGroup>[
      for (final g in allGroups)
        if (q.isEmpty)
          g
        else
          () {
            final matches = g.items
                .where(
                  (item) =>
                      item.labelId.toLowerCase().contains(q) ||
                      item.labelEn.toLowerCase().contains(q) ||
                      item.keywords.toLowerCase().contains(q) ||
                      g.titleId.toLowerCase().contains(q) ||
                      g.titleEn.toLowerCase().contains(q),
                )
                .toList();
            return _FeatureGroup(g.titleId, g.titleEn, matches);
          }(),
    ].where((g) => g.items.isNotEmpty).toList();

    final totalCount = allGroups.fold<int>(0, (sum, g) => sum + g.items.length);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Semua Fitur', 'All Features')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('all-features-search'),
              decoration: InputDecoration(
                hintText: context.tr(
                  'Cari dari $totalCount fitur tersedia...',
                  'Search across $totalCount features...',
                ),
                prefixIcon: const Icon(MoeslimIcons.pencarian, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: context.tr('Hapus pencarian', 'Clear search'),
                        icon: const Icon(MoeslimIcons.tutup, size: 18),
                        onPressed: () => setState(() => _query = ''),
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: filteredGroups.isEmpty
                ? BrandEmptyState(
                    art: BrandEmptyArt.tidakAdaHasil,
                    title: context.tr('Fitur tidak ditemukan', 'No features found'),
                    message: context.tr(
                      'Coba kata kunci lain untuk menemukan fitur yang Anda cari.',
                      'Try a different keyword to find the feature you are looking for.',
                    ),
                  )
                : ListView(
                    key: const Key('all-features-list'),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [
                      for (final group in filteredGroups) ...[
                        SectionHeader(group.titleFor(lang)),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final scale = MediaQuery.textScalerOf(context).scale(1);
                            final cols = (constraints.maxWidth / (80 * scale)).floor().clamp(2, 4);
                            return GridView.count(
                              crossAxisCount: cols,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 112 * scale,
                              children: [
                                for (final item in group.items)
                                  MenuTile(
                                    key: Key('feature-${item.id}'),
                                    tile: item.tile,
                                    icon: item.icon,
                                    art: item.art,
                                    label: item.labelFor(lang),
                                    onTap: item.onOpen(context),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
