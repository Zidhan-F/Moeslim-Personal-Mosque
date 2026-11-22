import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import '../../ui/hijab_art.dart';
import '../more/nearby_mosques_gps_page.dart';
import '../prayer/auto_dnd_page.dart';
import '../prayer/home_widget_page.dart';
import '../prayer/prayer_page.dart';
import 'asmaul_husna_page.dart';
import 'astronomy_qibla_fiqih_page.dart';
import 'doa_pages.dart';
import 'family_education_page.dart';
import 'fasting_tracker_page.dart';
import 'fiqih_guide_page.dart';
import 'guided_dzikir_page.dart';
import 'hadith_page.dart';
import 'hijri_page.dart';
import 'manasik_page.dart';
import 'muhasabah_journal_page.dart';
import 'muslimah_mode_page.dart';
import 'qibla_page.dart';
import 'seasonal_ramadan_page.dart';
import 'sedekah_tracker_page.dart';
import 'share_card_page.dart';
import 'sirah_page.dart';
import 'spiritual_care_page.dart';
import 'tasbih_page.dart';
import 'tracker_page.dart';
import 'utility_accessibility_page.dart';
import 'zakat_faraid_page.dart';

class IbadahPage extends StatelessWidget {
  const IbadahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(BrandTile, String, String, Widget Function(), bool)>[
      (
        BrandTile.doaDzikir,
        context.tr('Doa & Dzikir', 'Duas & Dhikr'),
        context.tr('Doa harian, aktivitas & Al-Qur\'an', 'Daily, activity & Quranic duas'),
        () => const DoaListPage(),
        false,
      ),
      (
        BrandTile.doaDzikir,
        context.tr('Dzikir Pagi, Petang & Ba\'da Salat', 'Morning, Evening & Post-Prayer Dhikr'),
        context.tr(
          'Al-Ma\'tsurat & wirid salat terpandu dengan hitungan',
          'Guided Al-Ma\'thurat & post-prayer dhikr with counter',
        ),
        () => const GuidedDzikirPage(),
        false,
      ),
      (
        BrandTile.tasbih,
        context.tr('Dzikir & Tasbih', 'Dhikr & Tasbih'),
        context.tr('Tasbih digital & target', 'Digital tasbih & target'),
        () => const TasbihPage(),
        false,
      ),
      (
        BrandTile.catatanIbadah,
        context.tr('Catatan Ibadah', 'Worship Tracker'),
        context.tr('Checklist, streak & grafik', 'Checklist, streak & chart'),
        () => const TrackerPage(),
        false,
      ),
      (
        BrandTile.kalenderHijriah,
        context.tr('Pelacak Puasa & Qadha', 'Fasting & Qadha Tracker'),
        context.tr(
          'Puasa sunnah, Ramadan, utang Qadha & fidyah',
          'Sunnah fasting, Ramadan, Qadha debt & fidyah',
        ),
        () => const FastingTrackerPage(),
        false,
      ),
      (
        BrandTile.doaDzikir,
        context.tr('Kitab Hadits Pilihan', 'Selected Hadith Collection'),
        context.tr(
          'Arba\'in Nawawi & Riyadus Shalihin offline',
          'Offline Nawawi\'s 40 Hadith & Riyad al-Salihin',
        ),
        () => const HadithPage(),
        false,
      ),
      (
        BrandTile.doaDzikir,
        context.tr('Panduan Ibadah & Fiqih', 'Worship & Fiqh Guide'),
        context.tr(
          'Wudhu, tayammum, salat fardhu, sunnah, safar & jenazah',
          'Wudu, tayammum, obligatory, sunnah, travel & funeral prayers',
        ),
        () => const FiqihGuidePage(),
        false,
      ),
      (
        BrandTile.catatanIbadah,
        context.tr('Kalkulator Zakat, Fidyah & Waris', 'Zakat, Fidyah & Inheritance Calculator'),
        context.tr(
          'Zakat maal, profesi, fitrah, fidyah & simulasi Faraid',
          'Wealth, income, fitrah zakat, fidyah & Faraid simulation',
        ),
        () => const ZakatFaraidPage(),
        false,
      ),
      (
        BrandTile.tasbih,
        context.tr('Asmaul Husna (99 Nama Allah)', 'Asmaul Husna (99 Names of Allah)'),
        context.tr(
          '99 nama Allah lengkap dengan makna & kuis hafalan',
          'All 99 Names of Allah with meanings & memorization quiz',
        ),
        () => const AsmaulHusnaPage(),
        false,
      ),
      (
        BrandTile.jadwalSholat,
        context.tr('Jadwal Salat', 'Prayer Times'),
        context.tr('Akurat sesuai lokasi', 'Accurate for your location'),
        () => const PrayerPage(),
        false,
      ),
      (
        BrandTile.jadwalSholat,
        context.tr('Widget Layar Utama Android', 'Android Home Screen Widget'),
        context.tr(
          'Atur & pratinjau widget jadwal salat di layar utama HP',
          'Configure & preview the prayer times home screen widget',
        ),
        () => const HomeWidgetPage(),
        false,
      ),
      (
        BrandTile.arahKiblat,
        context.tr('Arah Kiblat', 'Qibla Direction'),
        context.tr('Kompas & derajat kiblat', 'Qibla compass & bearing'),
        () => const QiblaPage(),
        false,
      ),
      (
        BrandTile.kalenderHijriah,
        context.tr('Kalender Hijriah', 'Hijri Calendar'),
        context.tr('Tanggal Islam & hari penting', 'Islamic dates & key observances'),
        () => const HijriPage(),
        false,
      ),
      (
        BrandTile.jadwalSholat,
        context.tr('Mode Hening Otomatis (Auto DND)', 'Auto Silent Mode (Auto DND)'),
        context.tr(
          'Senyapkan dering saat masuk waktu salat & Jumat',
          'Silence ringtone during prayer times & Jumu\'ah',
        ),
        () => const AutoDndPage(),
        false,
      ),
      (
        BrandTile.masjid,
        context.tr('Pencari Masjid Terdekat (GPS)', 'Nearby Mosques Finder (GPS)'),
        context.tr(
          'Jarak & arah kompas masjid/musholla dari posisi GPS',
          'Distance & compass direction to nearby mosques from GPS',
        ),
        () => const NearbyMosquesGpsPage(),
        false,
      ),
      (
        BrandTile.arahKiblat,
        context.tr('Manasik Haji & Umrah Interaktif', 'Interactive Hajj & Umrah Manasik'),
        context.tr(
          'Rukun, doa & counter 7 putaran Thawaf + Sa\'i',
          'Pillars, duas & 7-round Tawaf + Sa\'i counter',
        ),
        () => const ManasikPage(),
        false,
      ),
      (
        BrandTile.catatanIbadah,
        context.tr('Pelacak Sedekah & Kebaikan', 'Charity & Good Deeds Tracker'),
        context.tr(
          'Catat sedekah subuh, Jumat & target amal bulanan',
          'Log dawn & Friday charity and monthly giving goals',
        ),
        () => const SedekahTrackerPage(),
        false,
      ),
      (
        BrandTile.catatanIbadah,
        context.tr('Jurnal Muhasabah & Syukur', 'Muhasabah & Gratitude Journal'),
        context.tr(
          'Refleksi harian dengan opsi kunci PIN lokal',
          'Daily reflection with optional local PIN lock',
        ),
        () => const MuhasabahJournalPage(),
        false,
      ),
      (
        BrandTile.doaDzikir,
        context.tr('Sirah Nabawiyah, 25 Nabi & Sahabat', 'Seerah, 25 Prophets & Companions'),
        context.tr(
          'Kronologi Rasulullah, kisah 25 Nabi & teladan Sahabat',
          'Prophet\'s timeline, stories of 25 Prophets & Companions',
        ),
        () => const SirahPage(),
        false,
      ),
      (
        BrandTile.alquran,
        context.tr('Pembuat Kartu Bagikan Ayat & Doa', 'Verse & Dua Share Card Maker'),
        context.tr(
          'Desain kartu dakwah berornamen Moeslim PM siap bagikan',
          'Design ornate Moeslim PM verse & dua cards ready to share',
        ),
        () => const ShareCardPage(),
        false,
      ),
      (
        BrandTile.kalenderHijriah,
        context.tr('Mode Muslimah (Haid & Qadha)', 'Muslimah Mode (Cycle & Qadha)'),
        context.tr(
          'Jeda otomatis streak salat & hitung utang Qadha puasa',
          'Auto-pause prayer streaks & track Qadha fasting days',
        ),
        () => const MuslimahModePage(),
        true,
      ),
      (
        BrandTile.arahKiblat,
        context.tr(
          'Kiblat Matahari, Peta, Safar & Waktu Sunnah',
          'Solar Qibla, Map, Travel & Sunnah Times',
        ),
        context.tr(
          'Rashdul Qiblah, garis Ka\'bah, Jama\'/Qashar, Dhuha/Tahajud & Sunnah Jumat',
          'Rashdul Qiblah, Kaaba bearing line, Jama\'/Qasr, Duha/Tahajjud & Friday sunnahs',
        ),
        () => const AstronomyQiblaFiqihPage(),
        false,
      ),
      (
        BrandTile.kalenderHijriah,
        context.tr(
          'Dasbor Ramadan, Kurban/Aqiqah, Imsakiyah & Id',
          'Ramadan Dashboard, Qurban/Aqiqah, Imsakiyah & Eid',
        ),
        context.tr(
          'Pelacak 30 hari Ramadan, kurban 1/7, umur Hijriah, tabel Imsakiyah & takbiran Id',
          '30-day Ramadan tracker, 1/7 Qurban, Hijri age, Imsakiyah & Eid takbir',
        ),
        () => const SeasonalRamadanPage(),
        false,
      ),
      (
        BrandTile.doaDzikir,
        context.tr(
          'Doa Kondisi Hati, Ruqyah, Shalawat, Hajat & Rawatib',
          'Heart Duas, Ruqyah, Salawat, Hajat & Rawatib',
        ),
        context.tr(
          'Pencari doa suasana hati, ruqyah mandiri, counter shalawat, daftar hajat & 12 rawatib',
          'Mood dua finder, self-ruqyah, salawat counter, wish list & 12 rawatib',
        ),
        () => const SpiritualCarePage(),
        false,
      ),
      (
        BrandTile.doaDzikir,
        context.tr(
          'Keluarga, Nama Bayi, Hijaiyah, Kuis, Glosarium & Utang',
          'Family, Baby Names, Hijaiyah, Quiz, Glossary & Debts',
        ),
        context.tr(
          'Nama bayi Islami, 29 huruf Hijaiyah, kuis harian, kamus Islam & catatan utang piutang',
          'Islamic baby names, 29 Hijaiyah letters, daily quiz, glossary & debt log',
        ),
        () => const FamilyEducationPage(),
        false,
      ),
      (
        BrandTile.catatanIbadah,
        context.tr(
          'Mode Lansia, Timer Ibadah, Refleksi & Cek Kode Halal',
          'Senior Mode, Worship Timer, Reflection & Halal Checker',
        ),
        context.tr(
          'Aksesibilitas lansia, timer tilawah/i\'tikaf, rekap bulanan, E-Number Halal & sunnah waktu',
          'Senior accessibility, recitation/i\'tikaf timer, monthly recap, Halal E-Numbers & timed sunnahs',
        ),
        () => const UtilityAccessibilityPage(),
        false,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Ibadah Harian', 'Daily Worship')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PatternBanner(
            child: Text(
              context.tr(
                'Amalkan doa, perbanyak dzikir, dan catat ibadah harian. Semua tersimpan di perangkat Anda.',
                'Practice daily duas, increase your dhikr, and log your worship. Everything is saved on your device.',
              ),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
          for (final (tile, title, sub, page, isMuslimah) in items)
            Card(
              child: ListTile(
                minVerticalPadding: 14,
                leading: isMuslimah
                    ? const HijabWomanArt(size: 44)
                    : FeatureTileArt(tile, size: 44),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(sub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page())),
              ),
            ),
        ],
      ),
    );
  }
}
