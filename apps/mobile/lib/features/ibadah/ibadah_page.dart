import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../ui/components.dart';
import '../prayer/prayer_page.dart';
import 'doa_pages.dart';
import 'hijri_page.dart';
import 'qibla_page.dart';
import 'tasbih_page.dart';
import 'tracker_page.dart';

class IbadahPage extends StatelessWidget {
  const IbadahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(BrandTile, String, String, Widget Function())>[
      (BrandTile.doaDzikir, 'Doa & Dzikir', 'Doa harian, aktivitas & Al-Qur\'an', () => const DoaListPage()),
      (BrandTile.tasbih, 'Dzikir & Tasbih', 'Tasbih digital & target', () => const TasbihPage()),
      (BrandTile.catatanIbadah, 'Catatan Ibadah', 'Checklist, streak & grafik', () => const TrackerPage()),
      (BrandTile.jadwalSholat, 'Jadwal Salat', 'Akurat sesuai lokasi', () => const PrayerPage()),
      (BrandTile.arahKiblat, 'Arah Kiblat', 'Kompas & derajat kiblat', () => const QiblaPage()),
      (BrandTile.kalenderHijriah, 'Kalender Hijriah', 'Tanggal Islam & hari penting', () => const HijriPage()),
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
                leading: FeatureTileArt(tile, size: 44),
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
