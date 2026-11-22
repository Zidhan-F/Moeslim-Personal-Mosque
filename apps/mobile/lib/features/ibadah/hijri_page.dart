import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';

class HijriPage extends ConsumerStatefulWidget {
  const HijriPage({super.key});

  @override
  ConsumerState<HijriPage> createState() => _HijriPageState();
}

class _HijriPageState extends ConsumerState<HijriPage> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  static const _important = {
    (1, 1): 'Tahun Baru Hijriah',
    (1, 10): "'Asyura",
    (3, 12): 'Maulid Nabi',
    (7, 27): "Isra' Mi'raj",
    (9, 1): 'Awal Ramadan',
    (10, 1): 'Idul Fitri',
    (12, 9): 'Hari Arafah',
    (12, 10): 'Idul Adha',
  };

  @override
  Widget build(BuildContext context) {
    final offset = ref.watch(settingsProvider).value?.hijriOffset ?? 0;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final first = HijriDate.fromGregorian(_month, offsetDays: offset);
    final ramadan = [
      for (var d = 1; d <= days; d++)
        HijriDate.fromGregorian(DateTime(_month.year, _month.month, d), offsetDays: offset),
    ].where((h) => h.month == 9).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Hijriah')),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      longDate(_month).split(', ').last.replaceFirst(RegExp(r'^\d+ '), ''),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('${first.monthName} ${first.year} H'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
              ),
            ],
          ),
          if (ramadan != null)
            Card(
              key: const Key('ramadan-banner'),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ramadan ${ramadan.year} H',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Text('Bulan ini memuat hari-hari Ramadan. Semoga ibadah kita diterima.'),
                        ],
                      ),
                    ),
                    const BrandArt(BrandIllustration.ramadanMalam4, width: 120, height: 80),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: days,
              itemBuilder: (_, i) {
                final g = DateTime(_month.year, _month.month, i + 1);
                final h = HijriDate.fromGregorian(g, offsetDays: offset);
                final event = _important[(h.month, h.day)];
                return ListTile(
                  dense: true,
                  leading: Text('${g.day}', style: Theme.of(context).textTheme.titleMedium),
                  title: Text(h.toString()),
                  subtitle: event != null
                      ? Text(event, style: TextStyle(color: Theme.of(context).colorScheme.secondary))
                      : null,
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Koreksi tanggal Hijriah dapat diatur di Pengaturan Jadwal.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
