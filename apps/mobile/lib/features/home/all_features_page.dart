import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../ui/components.dart';
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

import '../../ui/hijab_art.dart';

class _FeatureEntry {
  final String id;
  final String label;
  final String keywords;
  final BrandTile? tile;
  final IconData? icon;
  final Widget? art;
  final VoidCallback Function(BuildContext context) onOpen;

  const _FeatureEntry({
    required this.id,
    required this.label,
    required this.keywords,
    this.tile,
    this.icon,
    this.art,
    required this.onOpen,
  });
}

class _FeatureGroup {
  final String title;
  final List<_FeatureEntry> items;
  const _FeatureGroup(this.title, this.items);
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
    _FeatureGroup("Al-Qur'an & Studi", [
      _FeatureEntry(
        id: 'alquran',
        label: "Al-Qur'an",
        keywords: 'mushaf surah juz baca quran',
        tile: BrandTile.alquran,
        onOpen: (c) => _switchTab(c, 1),
      ),
      _FeatureEntry(
        id: 'murottal',
        label: "Murottal Al-Qur'an",
        keywords: 'audio qari dengarkan tilawah',
        icon: MoeslimIcons.audio,
        onOpen: (c) => _pushPage(c, () => const MurottalPage()),
      ),
      _FeatureEntry(
        id: 'tafsir-search',
        label: 'Tafsir & Cari Ayat',
        keywords: 'pencarian tematik tadabbur catatan',
        icon: MoeslimIcons.pencarian,
        onOpen: (c) => _pushPage(c, () => const TafsirSearchPage()),
      ),
      _FeatureEntry(
        id: 'tahfidz',
        label: "Tahfidz & Muraja'ah",
        keywords: 'hafalan uji sambung ayat quran',
        icon: MoeslimIcons.target,
        onOpen: (c) => _pushPage(c, () => const TahfidzPage()),
      ),
      _FeatureEntry(
        id: 'khatam',
        label: 'Perencana Khatam',
        keywords: 'target halaman khatam quran',
        icon: MoeslimIcons.kalender,
        onOpen: (c) => _pushPage(c, () => const KhatamPlannerPage()),
      ),
      _FeatureEntry(
        id: 'tajwid-belajar',
        label: 'Belajar Tajwid',
        keywords: 'makharijul huruf hukum kuis',
        icon: MoeslimIcons.alquran,
        onOpen: (c) => _pushPage(c, () => const TajweedLearningPage()),
      ),
      _FeatureEntry(
        id: 'tajwid-warna',
        label: 'Warna Tajwid',
        keywords: 'panduan legenda warna tajwid',
        icon: MoeslimIcons.keterangan,
        onOpen: (c) => _pushPage(c, () => const TajweedLegendPage()),
      ),
      _FeatureEntry(
        id: 'quran-study',
        label: "Pendalaman Qur'an",
        keywords: 'kata per kata asbabun nuzul flashcard sajdah',
        icon: MoeslimIcons.quranTerbuka,
        onOpen: (c) => _pushPage(c, () => const QuranStudySuitePage()),
      ),
      _FeatureEntry(
        id: 'fokus-tilawah',
        label: 'Fokus Tilawah',
        keywords: 'baca otomatis autoscroll tenang',
        icon: MoeslimIcons.alquran,
        onOpen: (c) => _pushPage(c, () => const FocusTilawahPage()),
      ),
    ]),
    _FeatureGroup('Salat, Kiblat & Waktu', [
      _FeatureEntry(
        id: 'jadwal-salat',
        label: 'Jadwal Salat',
        keywords: 'waktu sholat subuh dzuhur ashar maghrib isya adzan',
        tile: BrandTile.jadwalSholat,
        onOpen: (c) => _pushPage(c, () => const PrayerPage()),
      ),
      _FeatureEntry(
        id: 'arah-kiblat',
        label: 'Arah Kiblat',
        keywords: 'kompas derajat kabah mekah',
        tile: BrandTile.arahKiblat,
        onOpen: (c) => _pushPage(c, () => const QiblaPage()),
      ),
      _FeatureEntry(
        id: 'astronomi-kiblat',
        label: 'Kiblat Matahari & Safar',
        keywords: 'rashdul qiblah peta jama qashar dhuha tahajud',
        icon: MoeslimIcons.kompas,
        onOpen: (c) => _pushPage(c, () => const AstronomyQiblaFiqihPage()),
      ),
      _FeatureEntry(
        id: 'auto-dnd',
        label: 'Mode Hening (DND)',
        keywords: 'senyap otomatis dering jumat salat',
        icon: MoeslimIcons.bisukan,
        onOpen: (c) => _pushPage(c, () => const AutoDndPage()),
      ),
      _FeatureEntry(
        id: 'home-widget',
        label: 'Widget Layar Utama',
        keywords: 'android homescreen jadwal salat',
        icon: MoeslimIcons.ponsel,
        onOpen: (c) => _pushPage(c, () => const HomeWidgetPage()),
      ),
      _FeatureEntry(
        id: 'pengaturan-jadwal',
        label: 'Lokasi & Metode',
        keywords: 'gps kota kemenag pengaturan salat',
        icon: MoeslimIcons.pengaturan,
        onOpen: (c) => _pushPage(c, () => const PrayerSettingsPage()),
      ),
    ]),
    _FeatureGroup('Doa, Dzikir & Hati', [
      _FeatureEntry(
        id: 'doa-dzikir',
        label: 'Doa & Dzikir',
        keywords: 'doa harian aktivitas hisnul muslim',
        tile: BrandTile.doaDzikir,
        onOpen: (c) => _pushPage(c, () => const DoaListPage()),
      ),
      _FeatureEntry(
        id: 'dzikir-terpandu',
        label: 'Dzikir Pagi & Petang',
        keywords: 'al matsurat wirid bada salat terpandu',
        icon: MoeslimIcons.matahari,
        onOpen: (c) => _pushPage(c, () => const GuidedDzikirPage()),
      ),
      _FeatureEntry(
        id: 'tasbih',
        label: 'Tasbih Digital',
        keywords: 'hitung dzikir target subhanallah',
        tile: BrandTile.tasbih,
        onOpen: (c) => _pushPage(c, () => const TasbihPage()),
      ),
      _FeatureEntry(
        id: 'asmaul-husna',
        label: 'Asmaul Husna',
        keywords: '99 nama allah makna kuis',
        icon: MoeslimIcons.bintang,
        onOpen: (c) => _pushPage(c, () => const AsmaulHusnaPage()),
      ),
      _FeatureEntry(
        id: 'spiritual-care',
        label: 'Doa Hati & Ruqyah',
        keywords: 'suasana hati shalawat hajat rawatib',
        icon: MoeslimIcons.cinta,
        onOpen: (c) => _pushPage(c, () => const SpiritualCarePage()),
      ),
      _FeatureEntry(
        id: 'share-card',
        label: 'Kartu Bagikan Ayat',
        keywords: 'desain poster kutipan dakwah doa',
        icon: MoeslimIcons.bagikan,
        onOpen: (c) => _pushPage(c, () => const ShareCardPage()),
      ),
    ]),
    _FeatureGroup('Catatan & Ibadah Harian', [
      _FeatureEntry(
        id: 'catatan-ibadah',
        label: 'Catatan Ibadah',
        keywords: 'checklist mutabaah streak grafik',
        tile: BrandTile.catatanIbadah,
        onOpen: (c) => _pushPage(c, () => const TrackerPage()),
      ),
      _FeatureEntry(
        id: 'kalender-hijriah',
        label: 'Kalender Hijriah',
        keywords: 'tanggal islam hari besar hijri',
        tile: BrandTile.kalenderHijriah,
        onOpen: (c) => _pushPage(c, () => const HijriPage()),
      ),
      _FeatureEntry(
        id: 'puasa-qadha',
        label: 'Puasa & Qadha',
        keywords: 'senin kamis ayyamul bidh utang fidyah',
        icon: MoeslimIcons.bulan,
        onOpen: (c) => _pushPage(c, () => const FastingTrackerPage()),
      ),
      _FeatureEntry(
        id: 'ramadan',
        label: 'Ramadan & Hari Besar',
        keywords: 'imsakiyah kurban aqiqah idul fitri adha',
        tile: BrandTile.ramadan,
        onOpen: (c) => _pushPage(c, () => const SeasonalRamadanPage()),
      ),
      _FeatureEntry(
        id: 'muslimah',
        label: 'Mode Muslimah',
        keywords: 'haid uzur qadha puasa wanita',
        art: const HijabWomanArt(size: 40),
        onOpen: (c) => _pushPage(c, () => const MuslimahModePage()),
      ),
      _FeatureEntry(
        id: 'sedekah',
        label: 'Pelacak Sedekah',
        keywords: 'infaq kebaikan subuh jumat amal',
        icon: MoeslimIcons.donasi,
        onOpen: (c) => _pushPage(c, () => const SedekahTrackerPage()),
      ),
      _FeatureEntry(
        id: 'muhasabah',
        label: 'Jurnal Muhasabah',
        keywords: 'refleksi syukur harian catatan pin',
        icon: MoeslimIcons.edit,
        onOpen: (c) => _pushPage(c, () => const MuhasabahJournalPage()),
      ),
    ]),
    _FeatureGroup('Ilmu, Fiqih & Keluarga', [
      _FeatureEntry(
        id: 'hadits',
        label: 'Kitab Hadits',
        keywords: 'arbain nawawi riyadus shalihin shahih',
        icon: MoeslimIcons.buku,
        onOpen: (c) => _pushPage(c, () => const HadithPage()),
      ),
      _FeatureEntry(
        id: 'fiqih',
        label: 'Panduan Fiqih',
        keywords: 'wudhu tayammum salat fardhu sunnah jenazah',
        tile: BrandTile.sajadah,
        onOpen: (c) => _pushPage(c, () => const FiqihGuidePage()),
      ),
      _FeatureEntry(
        id: 'zakat-faraid',
        label: 'Zakat & Waris',
        keywords: 'kalkulator maal profesi fitrah fidyah faraid',
        tile: BrandTile.keuangan,
        onOpen: (c) => _pushPage(c, () => const ZakatFaraidPage()),
      ),
      _FeatureEntry(
        id: 'manasik',
        label: 'Manasik Haji & Umrah',
        keywords: 'rukun thawaf sai kaabah umroh',
        icon: MoeslimIcons.kubah,
        onOpen: (c) => _pushPage(c, () => const ManasikPage()),
      ),
      _FeatureEntry(
        id: 'sirah',
        label: 'Sirah & 25 Nabi',
        keywords: 'nabawiyah rasulullah kisah sahabat sejarah',
        icon: MoeslimIcons.histori,
        onOpen: (c) => _pushPage(c, () => const SirahPage()),
      ),
      _FeatureEntry(
        id: 'keluarga-edukasi',
        label: 'Keluarga & Edukasi',
        keywords: 'nama bayi hijaiyah kuis glosarium utang',
        icon: MoeslimIcons.jamaah,
        onOpen: (c) => _pushPage(c, () => const FamilyEducationPage()),
      ),
    ]),
    _FeatureGroup('Masjid, Utilitas & Lainnya', [
      _FeatureEntry(
        id: 'masjid-diikuti',
        label: 'Masjid Diikuti',
        keywords: 'agenda pengumuman jamaah masjid',
        tile: BrandTile.masjid,
        onOpen: (c) => _pushPage(c, () => const FollowedMosquesPage()),
      ),
      _FeatureEntry(
        id: 'masjid-gps',
        label: 'Masjid Terdekat',
        keywords: 'gps musholla jarak lokasi sekitar',
        icon: MoeslimIcons.lokasi,
        onOpen: (c) => _pushPage(c, () => const NearbyMosquesGpsPage()),
      ),
      _FeatureEntry(
        id: 'utilitas-halal',
        label: 'Lansia, Timer & Halal',
        keywords: 'aksesibilitas itikaf refleksi e-number kode halal',
        icon: MoeslimIcons.shield,
        onOpen: (c) => _pushPage(c, () => const UtilityAccessibilityPage()),
      ),
      _FeatureEntry(
        id: 'backup-restore',
        label: 'Cadangkan Data',
        keywords: 'pulihkan ekspor impor backup lokal',
        icon: MoeslimIcons.database,
        onOpen: (c) => _pushPage(c, () => const BackupRestorePage()),
      ),
      _FeatureEntry(
        id: 'profil',
        label: 'Profil & Tampilan',
        keywords: 'tema gelap terang ukuran huruf nama',
        icon: MoeslimIcons.profil,
        onOpen: (c) => _switchTab(c, 4),
      ),
      _FeatureEntry(
        id: 'tentang',
        label: 'Tentang',
        keywords: 'daftar isi referensi lisensi versi',
        icon: MoeslimIcons.info,
        onOpen: (c) => _pushPage(c, () => const AboutLicensesPage()),
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
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
                      item.label.toLowerCase().contains(q) ||
                      item.keywords.toLowerCase().contains(q) ||
                      g.title.toLowerCase().contains(q),
                )
                .toList();
            return _FeatureGroup(g.title, matches);
          }(),
    ].where((g) => g.items.isNotEmpty).toList();

    final totalCount = allGroups.fold<int>(0, (sum, g) => sum + g.items.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Semua Fitur'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('all-features-search'),
              decoration: InputDecoration(
                hintText: 'Cari dari $totalCount fitur tersedia...',
                prefixIcon: const Icon(MoeslimIcons.pencarian, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Hapus pencarian',
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
                ? const BrandEmptyState(
                    art: BrandEmptyArt.tidakAdaHasil,
                    title: 'Fitur tidak ditemukan',
                    message: 'Coba kata kunci lain untuk menemukan fitur yang Anda cari.',
                  )
                : ListView(
                    key: const Key('all-features-list'),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [
                      for (final group in filteredGroups) ...[
                        SectionHeader(group.title),
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
                                    label: item.label,
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
