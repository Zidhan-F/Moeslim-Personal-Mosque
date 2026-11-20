import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../quran/naghom_hero.dart';

class HomePage extends ConsumerWidget {
  final void Function(int tab) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(prayerStatusProvider);
    final settings = ref.watch(settingsProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Moeslim')),
      body: status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat jadwal: $e')),
        data: (s) {
          final hijri = HijriDate.fromGregorian(s.now, offsetDays: settings?.hijriOffset ?? 0);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const NaghomHero(),
              const SizedBox(height: 16),
              _NextPrayerCard(status: s, city: settings?.location.name ?? '', hijri: hijri.toString()),
              const SizedBox(height: 16),
              _TodayTimes(status: s),
              const SizedBox(height: 16),
              Text('Akses cepat', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _Quick(icon: Icons.menu_book, label: 'Quran', onTap: () => onNavigate(1)),
                  _Quick(icon: Icons.schedule, label: 'Sholat', onTap: () => onNavigate(2)),
                  _Quick(icon: Icons.explore, label: 'Kiblat', onTap: () => onNavigate(3)),
                  _Quick(icon: Icons.touch_app, label: 'Tasbih', onTap: () => onNavigate(3)),
                  _Quick(icon: Icons.checklist, label: 'Tracker', onTap: () => onNavigate(3)),
                  _Quick(icon: Icons.calendar_month, label: 'Hijriah', onTap: () => onNavigate(3)),
                  _Quick(icon: Icons.graphic_eq, label: 'Naghom', onTap: () => onNavigate(1)),
                  _Quick(icon: Icons.mosque, label: 'Masjid', onTap: () => onNavigate(4)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  final PrayerStatus status;
  final String city;
  final String hijri;
  const _NextPrayerCard({required this.status, required this.city, required this.hijri});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [MoeslimColors.emerald, MoeslimColors.emeraldDark]),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$city • ${longDate(status.now)}', style: const TextStyle(color: Colors.white70)),
            Text(hijri, style: const TextStyle(color: MoeslimColors.gold)),
            const SizedBox(height: 12),
            Text('Menuju ${status.nextPrayer.label}', style: t.titleMedium?.copyWith(color: Colors.white)),
            Text(
              countdown(status.remaining),
              key: const Key('countdown'),
              style: t.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              '${status.nextPrayer.label} pukul ${hhmm(status.nextTime)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTimes extends StatelessWidget {
  final PrayerStatus status;
  const _TodayTimes({required this.status});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, DateTime, bool)>[
      ('Imsak', status.today.imsak, false),
      for (final p in Prayer.values) (p.label, status.today.timeOf(p), p == status.nextPrayer),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (final (label, time, highlight) in rows)
              ListTile(
                dense: true,
                title: Text(label, style: TextStyle(fontWeight: highlight ? FontWeight.bold : null)),
                trailing: Text(hhmm(time), style: TextStyle(fontWeight: highlight ? FontWeight.bold : null)),
                tileColor: highlight ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .4) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Quick({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
