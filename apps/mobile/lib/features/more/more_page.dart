import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../masjid/masjid_home_page.dart';
import 'about_licenses_page.dart';
import 'followed_mosques_page.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider).value;
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: const Text('Lainnya')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Masjid yang saya ikuti'),
            subtitle: const Text('Agenda & pengumuman publik, tanpa akun'),
            onTap: () => push(const FollowedMosquesPage()),
          ),
          ListTile(
            key: const Key('masjid-entry'),
            leading: const Icon(Icons.mosque),
            title: const Text('Moeslim Masjid (pengurus)'),
            subtitle: const Text('Login pengurus untuk kas, agenda, dan TV Display'),
            onTap: () => push(const MasjidHomePage()),
          ),
          const Divider(),
          if (s != null) ...[
            const ListTile(title: Text('Tampilan')),
            RadioGroup<AppThemeMode>(
              groupValue: s.themeMode,
              onChanged: (v) => ref.read(settingsProvider.notifier).save(s.copyWith(themeMode: v)),
              child: const Column(
                children: [
                  RadioListTile(value: AppThemeMode.system, title: Text('Ikuti sistem')),
                  RadioListTile(value: AppThemeMode.light, title: Text('Terang')),
                  RadioListTile(value: AppThemeMode.dark, title: Text('Gelap')),
                ],
              ),
            ),
            ListTile(
              title: const Text('Ukuran huruf'),
              subtitle: Slider(
                min: 0.85,
                max: 1.6,
                divisions: 15,
                value: s.fontScale,
                label: '${(s.fontScale * 100).round()}%',
                onChanged: (v) => ref.read(settingsProvider.notifier).save(s.copyWith(fontScale: v)),
              ),
            ),
          ],
          const Divider(),
          ListTile(
            key: const Key('about-licenses'),
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('Tentang & Lisensi'),
            subtitle: const Text('Gratis, non-komersial, tanpa iklan • atribusi sumber konten'),
            onTap: () => push(const AboutLicensesPage()),
          ),
          const AboutListTile(applicationName: 'Moeslim', applicationVersion: '0.1.0', icon: Icon(Icons.info_outline)),
        ],
      ),
    );
  }
}
