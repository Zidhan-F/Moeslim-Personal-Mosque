import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

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
    final items = <(BrandTile, String, String, Widget Function())>[
      (BrandTile.doaDzikir, 'Doa & Dzikir', 'Doa harian, aktivitas & Al-Qur\'an', () => const DoaListPage()),
      (
        BrandTile.doaDzikir,
        'Dzikir Pagi, Petang & Ba\'da Salat',
        'Al-Ma\'tsurat & wirid salat terpandu dengan hitungan',
        () => const GuidedDzikirPage(),
      ),
      (BrandTile.tasbih, 'Dzikir & Tasbih', 'Tasbih digital & target', () => const TasbihPage()),
      (BrandTile.catatanIbadah, 'Catatan Ibadah', 'Checklist, streak & grafik', () => const TrackerPage()),
      (
        BrandTile.kalenderHijriah,
        'Pelacak Puasa & Qadha',
        'Puasa sunnah, Ramadan, utang Qadha & fidyah',
        () => const FastingTrackerPage(),
      ),
      (
        BrandTile.doaDzikir,
        'Kitab Hadits Pilihan',
        'Arba\'in Nawawi & Riyadus Shalihin offline',
        () => const HadithPage(),
      ),
      (
        BrandTile.doaDzikir,
        'Panduan Ibadah & Fiqih',
        'Wudhu, tayammum, salat fardhu, sunnah, safar & jenazah',
        () => const FiqihGuidePage(),
      ),
      (
        BrandTile.catatanIbadah,
        'Kalkulator Zakat, Fidyah & Waris',
        'Zakat maal, profesi, fitrah, fidyah & simulasi Faraid',
        () => const ZakatFaraidPage(),
      ),
      (
        BrandTile.tasbih,
        'Asmaul Husna (99 Nama Allah)',
        '99 nama Allah lengkap dengan makna & kuis hafalan',
        () => const AsmaulHusnaPage(),
      ),
      (BrandTile.jadwalSholat, 'Jadwal Salat', 'Akurat sesuai lokasi', () => const PrayerPage()),
      (
        BrandTile.jadwalSholat,
        'Widget Layar Utama Android',
        'Atur & pratinjau widget jadwal salat di layar utama HP',
        () => const HomeWidgetPage(),
      ),
      (BrandTile.arahKiblat, 'Arah Kiblat', 'Kompas & derajat kiblat', () => const QiblaPage()),
      (BrandTile.kalenderHijriah, 'Kalender Hijriah', 'Tanggal Islam & hari penting', () => const HijriPage()),
      (
        BrandTile.jadwalSholat,
        'Mode Hening Otomatis (Auto DND)',
        'Senyapkan dering saat masuk waktu salat & Jumat',
        () => const AutoDndPage(),
      ),
      (
        BrandTile.masjid,
        'Pencari Masjid Terdekat (GPS)',
        'Jarak & arah kompas masjid/musholla dari posisi GPS',
        () => const NearbyMosquesGpsPage(),
      ),
      (
        BrandTile.arahKiblat,
        'Manasik Haji & Umrah Interaktif',
        'Rukun, doa & counter 7 putaran Thawaf + Sa\'i',
        () => const ManasikPage(),
      ),
      (
        BrandTile.catatanIbadah,
        'Pelacak Sedekah & Kebaikan',
        'Catat sedekah subuh, Jumat & target amal bulanan',
        () => const SedekahTrackerPage(),
      ),
      (
        BrandTile.catatanIbadah,
        'Jurnal Muhasabah & Syukur',
        'Refleksi harian dengan opsi kunci PIN lokal',
        () => const MuhasabahJournalPage(),
      ),
      (
        BrandTile.doaDzikir,
        'Sirah Nabawiyah, 25 Nabi & Sahabat',
        'Kronologi Rasulullah, kisah 25 Nabi & teladan Sahabat',
        () => const SirahPage(),
      ),
      (
        BrandTile.alquran,
        'Pembuat Kartu Bagikan Ayat & Doa',
        'Desain kartu dakwah berornamen Moeslim PM siap bagikan',
        () => const ShareCardPage(),
      ),
      (
        BrandTile.kalenderHijriah,
        'Mode Muslimah (Haid & Qadha)',
        'Jeda otomatis streak salat & hitung utang Qadha puasa',
        () => const MuslimahModePage(),
      ),
      (
        BrandTile.arahKiblat,
        'Kiblat Matahari, Peta, Safar & Waktu Sunnah',
        'Rashdul Qiblah, garis Ka\'bah, Jama\'/Qashar, Dhuha/Tahajud & Sunnah Jumat',
        () => const AstronomyQiblaFiqihPage(),
      ),
      (
        BrandTile.kalenderHijriah,
        'Dasbor Ramadan, Kurban/Aqiqah, Imsakiyah & Id',
        'Pelacak 30 hari Ramadan, kurban 1/7, umur Hijriah, tabel Imsakiyah & takbiran Id',
        () => const SeasonalRamadanPage(),
      ),
      (
        BrandTile.doaDzikir,
        'Doa Kondisi Hati, Ruqyah, Shalawat, Hajat & Rawatib',
        'Pencari doa suasana hati, ruqyah mandiri, counter shalawat, daftar hajat & 12 rawatib',
        () => const SpiritualCarePage(),
      ),
      (
        BrandTile.doaDzikir,
        'Keluarga, Nama Bayi, Hijaiyah, Kuis, Glosarium & Utang',
        'Nama bayi Islami, 29 huruf Hijaiyah, kuis harian, kamus Islam & catatan utang piutang',
        () => const FamilyEducationPage(),
      ),
      (
        BrandTile.catatanIbadah,
        'Mode Lansia, Timer Ibadah, Refleksi & Cek Kode Halal',
        'Aksesibilitas lansia, timer tilawah/i\'tikaf, rekap bulanan, E-Number Halal & sunnah waktu',
        () => const UtilityAccessibilityPage(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah Harian'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PatternBanner(
            child: Text(
              'Amalkan doa, perbanyak dzikir, dan catat ibadah harian. Semua tersimpan di perangkat Anda.',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
          for (final (tile, title, sub, page) in items)
            Card(
              child: ListTile(
                minVerticalPadding: 14,
                leading: title.startsWith('Mode Muslimah')
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
