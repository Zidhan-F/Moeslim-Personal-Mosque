import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

import 'package:moeslim_brand/moeslim_brand.dart';

class PrayerPage extends ConsumerWidget {
  const PrayerPage({super.key});

  static const _icons = {
    'Subuh': Icons.wb_twilight,
    'Syuruq': Icons.wb_sunny_outlined,
    'Dzuhur': Icons.light_mode,
    'Ashar': Icons.wb_sunny,
    'Maghrib': Icons.nights_stay_outlined,
    'Isya': Icons.dark_mode_outlined,
  };

  void _weekly(BuildContext context, PersonalSettings s, DateTime today) {
    final days = [for (var i = 0; i < 7; i++) DateTime(today.year, today.month, today.day + i)];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final status = ref.watch(prayerStatusProvider).value;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Salat'),
        centerTitle: true,
        actions: [
          if (settings.value != null && status != null)
            IconButton(
              key: const Key('weekly-schedule'),
              tooltip: 'Jadwal 7 hari',
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _weekly(context, settings.value!, status.now),
            ),
        ],
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          if (status == null) return const Center(child: CircularProgressIndicator());
          final hijri = HijriDate.fromGregorian(status.now, offsetDays: s.hijriOffset);
          final rows = <(String, DateTime, Prayer?)>[
            ('Subuh', status.today.fajr, Prayer.fajr),
            ('Syuruq', status.today.sunrise, null),
            ('Dzuhur', status.today.dhuhr, Prayer.dhuhr),
            ('Ashar', status.today.asr, Prayer.asr),
            ('Maghrib', status.today.maghrib, Prayer.maghrib),
            ('Isya', status.today.isha, Prayer.isha),
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OrnamentCard(
                child: Column(
                  children: [
                    Text(longDate(status.now), style: t.titleMedium),
                    Text(hijri.toString(), style: t.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 16, color: scheme.primary),
                        Text(' ${s.location.name}, ${s.location.province}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.mosque, color: scheme.primary, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Menuju Salat'),
                            Text(
                              status.nextPrayer.label,
                              key: const Key('next-prayer'),
                              style: t.titleLarge?.copyWith(color: scheme.primary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: BrandColors.gold.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 18, color: BrandColors.goldText),
                            const SizedBox(width: 4),
                            Text(
                              countdown(status.remaining),
                              style: const TextStyle(
                                color: BrandColors.goldText,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SectionHeader('Jadwal Salat Hari Ini'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      for (final (label, time, p) in rows)
                        Container(
                          key: Key('row-$label'),
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: p != null && p == status.nextPrayer ? scheme.primary.withValues(alpha: .12) : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(_icons[label], color: BrandColors.goldText),
                            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(hhmm(time), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 24,
                                  child: !time.isAfter(status.now)
                                      ? Icon(Icons.check, color: scheme.primary, size: 20, semanticLabel: 'sudah lewat')
                                      : (p != null && p == status.nextPrayer
                                            ? Icon(
                                                Icons.play_arrow,
                                                color: scheme.primary,
                                                size: 20,
                                                semanticLabel: 'berikutnya',
                                              )
                                            : null),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calculate_outlined),
                      title: const Text('Metode Perhitungan'),
                      subtitle: Text(s.method.label),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Lokasi'),
                      subtitle: Text('${s.location.name}, ${s.location.province}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Jadwal dihitung secara lokal (offline). Sesuaikan menit di pengaturan bila berbeda dengan jadwal resmi atau masjid setempat.',
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
