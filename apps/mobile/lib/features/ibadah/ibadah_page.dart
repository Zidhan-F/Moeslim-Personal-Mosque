import 'package:material_ui/material_ui.dart';

import 'hijri_page.dart';
import 'qibla_page.dart';
import 'tasbih_page.dart';
import 'tracker_page.dart';

class IbadahPage extends StatelessWidget {
  const IbadahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String, Widget Function())>[
      (Icons.touch_app, 'Dzikir & Tasbih', 'Penghitung 33/99/100 dan target kustom', () => const TasbihPage()),
      (Icons.checklist, 'Tracker Ibadah', 'Checklist sholat, tilawah, dan dzikir harian', () => const TrackerPage()),
      (Icons.explore, 'Arah Kiblat', 'Kompas dan sudut kiblat dari lokasi Anda', () => const QiblaPage()),
      (Icons.calendar_month, 'Kalender Hijriah', 'Tanggal Hijriah dengan koreksi lokal', () => const HijriPage()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (icon, title, sub, page) in items)
            Card(
              child: ListTile(
                leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
                title: Text(title),
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
