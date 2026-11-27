import 'package:material_ui/material_ui.dart';

import '../../ui/components.dart';
import '../prayer/prayer_page.dart';
import '../quran/naghom_pages.dart';
import 'doa_pages.dart';
import 'hijri_page.dart';
import '../nearby/nearby_page.dart';
import 'qibla_page.dart';
import 'tasbih_page.dart';
import 'tracker_page.dart';

class IbadahPage extends StatelessWidget {
  const IbadahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String, Widget Function())>[
      (Icons.volunteer_activism, 'Doa & Dzikir', 'Doa dalam Al-Qur\'an', () => const DoaListPage()),
      (Icons.touch_app, 'Dzikir & Tasbih', 'Tasbih digital & target', () => const TasbihPage()),
      (Icons.fact_check, 'Catatan Ibadah', 'Checklist, streak & grafik', () => const TrackerPage()),
      (Icons.calendar_month, 'Jadwal Salat', 'Akurat sesuai lokasi', () => const PrayerPage()),
      (Icons.explore, 'Arah Kiblat', 'Kompas & derajat kiblat', () => const QiblaPage()),
      (Icons.near_me_outlined, 'Masjid Terdekat', 'Masjid & musala di sekitar Anda', () => const NearbyMosquesPage()),
      (Icons.event_note, 'Kalender Hijriah', 'Tanggal Islam & hari penting', () => const HijriPage()),
      (Icons.graphic_eq, '7 Irama Naghom', 'Fitur andalan tilawah', () => const NaghomCatalogPage()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah Harian'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PatternBanner(
            child: Text(
              'Amalkan doa, perbanyak dzikir, dan catat ibadah harian — semua tersimpan di perangkat Anda.',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
          for (final (icon, title, sub, page) in items)
            Card(
              child: ListTile(
                minVerticalPadding: 14,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
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
