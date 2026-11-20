import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';

class PrayerPage extends ConsumerWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final status = ref.watch(prayerStatusProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Sholat')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          final today = status?.now ?? wallClock(DateTime.now(), s.location.utcOffset);
          final days = [for (var i = 0; i < 7; i++) DateTime(today.year, today.month, today.day + i)];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text('${s.location.name} (${s.location.zone})'),
                  subtitle: Text('Metode: ${s.method.label}'),
                  trailing: const Icon(Icons.tune),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Subuh')),
                      DataColumn(label: Text('Dzuhur')),
                      DataColumn(label: Text('Ashar')),
                      DataColumn(label: Text('Maghrib')),
                      DataColumn(label: Text('Isya')),
                    ],
                    rows: [
                      for (final d in days)
                        DataRow(
                          cells: [
                            DataCell(Text(shortDate(d))),
                            for (final p in Prayer.values) DataCell(Text(hhmm(s.timesFor(d).timeOf(p)))),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Jadwal dihitung secara lokal (offline). Sesuaikan menit bila berbeda dengan jadwal resmi atau masjid setempat.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PrayerSettingsPage extends ConsumerWidget {
  const PrayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Jadwal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: s.location.name,
            decoration: const InputDecoration(labelText: 'Kota'),
            items: [
              for (final c in indonesianCities) DropdownMenuItem(value: c.name, child: Text('${c.name} (${c.zone})')),
            ],
            onChanged: (v) => notifier.save(s.copyWith(location: indonesianCities.firstWhere((c) => c.name == v))),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CalculationMethod>(
            initialValue: s.method,
            decoration: const InputDecoration(labelText: 'Metode perhitungan'),
            items: [for (final m in CalculationMethod.values) DropdownMenuItem(value: m, child: Text(m.label))],
            onChanged: (v) => notifier.save(s.copyWith(method: v)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AsrMadhab>(
            initialValue: s.madhab,
            decoration: const InputDecoration(labelText: 'Waktu Ashar'),
            items: const [
              DropdownMenuItem(value: AsrMadhab.shafii, child: Text("Syafi'i, Maliki, Hanbali")),
              DropdownMenuItem(value: AsrMadhab.hanafi, child: Text('Hanafi')),
            ],
            onChanged: (v) => notifier.save(s.copyWith(madhab: v)),
          ),
          const SizedBox(height: 16),
          Text('Penyesuaian menit', style: Theme.of(context).textTheme.titleMedium),
          for (final p in Prayer.values)
            Row(
              children: [
                Expanded(child: Text(p.label)),
                IconButton(
                  tooltip: 'Kurangi ${p.label}',
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      notifier.save(s.copyWith(adjustments: {...s.adjustments, p: (s.adjustments[p] ?? 0) - 1})),
                ),
                SizedBox(width: 40, child: Text('${s.adjustments[p] ?? 0}', textAlign: TextAlign.center)),
                IconButton(
                  tooltip: 'Tambah ${p.label}',
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      notifier.save(s.copyWith(adjustments: {...s.adjustments, p: (s.adjustments[p] ?? 0) + 1})),
                ),
              ],
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: Text('Koreksi tanggal Hijriah (hari)')),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => notifier.save(s.copyWith(hijriOffset: (s.hijriOffset - 1).clamp(-2, 2))),
              ),
              Text('${s.hijriOffset}'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => notifier.save(s.copyWith(hijriOffset: (s.hijriOffset + 1).clamp(-2, 2))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
