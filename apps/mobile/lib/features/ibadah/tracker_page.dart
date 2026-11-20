import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class _TrackerData {
  final List<TrackerDay> week;
  final int streak;
  final int best;
  const _TrackerData(this.week, this.streak, this.best);
  TrackerDay get today => week.last;
  double get weekProgress => week.fold<double>(0, (s, d) => s + d.progress) / week.length;
}

/// Catatan Ibadah: ringkasan mingguan, checklist salat, tilawah, streak, dan grafik 7 hari.
class TrackerPage extends ConsumerStatefulWidget {
  const TrackerPage({super.key});

  @override
  ConsumerState<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends ConsumerState<TrackerPage> {
  int _tab = 0;
  _TrackerData? _data;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(trackerRepoProvider);
    final week = await repo.week(_today);
    final streak = await repo.prayerStreak(_today);
    final best = await repo.bestPrayerStreak(_today);
    if (mounted) setState(() => _data = _TrackerData(week, streak, best));
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(settingsProvider).value?.tilawahTargetPages ?? 20;
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Ibadah'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: PillTabs(
              labels: const ['Ringkasan', 'Riwayat'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: d == null
                ? const Center(child: CircularProgressIndicator())
                : (_tab == 0 ? _summary(context, d, target) : _history(context, d)),
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, _TrackerData d, int target) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(trackerRepoProvider);
    final pages = d.today.tilawahPages;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: BrandColors.goldText),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Progres Mingguan', style: t.titleMedium)),
                    Text(
                      '${(d.weekProgress * 100).round()}%',
                      key: const Key('week-progress'),
                      style: t.titleLarge?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
                Text('${shortDate(d.week.first.day)} – ${shortDate(d.week.last.day)}', style: t.bodySmall),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: d.weekProgress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.mosque, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Checklist Salat', style: t.titleMedium)),
                    Text('Hari ini, ${shortDate(d.today.day)}', style: t.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final p in TrackerItem.prayers)
                      Expanded(
                        child: InkWell(
                          key: Key('check-${p.name}'),
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            await repo.toggle(d.today.day, p);
                            _load();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                Text(p.label, style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 6),
                                Icon(
                                  d.today.items.contains(p) ? Icons.check_circle : Icons.circle_outlined,
                                  color: d.today.items.contains(p) ? scheme.primary : scheme.outline,
                                  size: 30,
                                  semanticLabel: d.today.items.contains(p) ? '${p.label} sudah' : '${p.label} belum',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Tilawah Al-Qur\'an', style: t.titleMedium)),
                    IconButton(
                      tooltip: 'Kurangi halaman',
                      onPressed: pages == 0
                          ? null
                          : () async {
                              await repo.addTilawahPages(d.today.day, -1);
                              _load();
                            },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      key: const Key('add-page'),
                      tooltip: 'Tambah halaman',
                      onPressed: () async {
                        await repo.addTilawahPages(d.today.day, 1);
                        _load();
                      },
                      icon: Icon(Icons.add_circle, color: scheme.primary),
                    ),
                  ],
                ),
                Text('$pages / $target halaman', key: const Key('tilawah-pages'), style: t.titleLarge),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (pages / target).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
                label: 'Streak Salat',
                value: '${d.streak} hari',
                valueKey: 'streak',
              ),
            ),
            Expanded(
              child: _StatCard(
                icon: Icons.workspace_premium,
                color: BrandColors.goldText,
                label: 'Terbaik',
                value: '${d.best} hari',
              ),
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grafik Ibadah Mingguan', style: t.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final day in d.week)
                        Expanded(
                          child: Semantics(
                            label: '${_dayShort(day.day)} ${(day.progress * 100).round()} persen',
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${(day.progress * 100).round()}%',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 22,
                                  height: 4 + 104 * day.progress,
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(alpha: day.day == d.today.day ? 1 : .55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(_dayShort(day.day), style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _history(BuildContext context, _TrackerData d) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    children: [
      for (final day in d.week.reversed)
        Card(
          child: ListTile(
            title: Text(longDate(day.day)),
            subtitle: Text(
              day.items.isEmpty ? 'Belum ada catatan' : day.items.map((e) => e.label).join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text('${(day.progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
    ],
  );

  static String _dayShort(DateTime d) => const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][d.weekday - 1];
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? valueKey;
  const _StatCard({required this.icon, required this.color, required this.label, required this.value, this.valueKey});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                value,
                key: valueKey == null ? null : Key(valueKey!),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
