import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
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

  static String _itemLabel(BuildContext context, TrackerItem item) => switch (item) {
        TrackerItem.subuh => context.tr(item.label, 'Fajr'),
        TrackerItem.dzuhur => context.tr(item.label, 'Dhuhr'),
        TrackerItem.ashar => context.tr(item.label, 'Asr'),
        TrackerItem.maghrib => context.tr(item.label, 'Maghrib'),
        TrackerItem.isya => context.tr(item.label, 'Isha'),
        TrackerItem.tilawah => context.tr(item.label, 'Recitation'),
        TrackerItem.dzikir => context.tr(item.label, 'Morning/evening dhikr'),
      };

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(settingsProvider).value?.tilawahTargetPages ?? 20;
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Catatan Ibadah', 'Worship Tracker')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Ringkasan', 'Summary'),
                context.tr('Riwayat', 'History'),
              ],
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
    final lang = context.lang;
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
                    const Icon(MoeslimIcons.grafikGaris, color: BrandColors.goldText),
                    const SizedBox(width: 8),
                    Expanded(child: Text(context.tr('Progres Mingguan', 'Weekly Progress'), style: t.titleMedium)),
                    Text(
                      '${(d.weekProgress * 100).round()}%',
                      key: const Key('week-progress'),
                      style: t.titleLarge?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
                Text(
                  '${context.shortDateText(d.week.first.day)} – ${context.shortDateText(d.week.last.day)}',
                  style: t.bodySmall,
                ),
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
                    Icon(MoeslimIcons.centangKotak, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(context.tr('Checklist Salat', 'Prayer Checklist'), style: t.titleMedium)),
                    Text(
                      context.tr(
                        'Hari ini, ${context.shortDateText(d.today.day)}',
                        'Today, ${context.shortDateText(d.today.day)}',
                      ),
                      style: t.bodySmall,
                    ),
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
                                Text(_itemLabel(context, p), style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 6),
                                Icon(
                                  d.today.items.contains(p) ? MoeslimIcons.berhasil : Icons.circle_outlined,
                                  color: d.today.items.contains(p) ? scheme.primary : scheme.outline,
                                  size: 30,
                                  semanticLabel: d.today.items.contains(p)
                                      ? context.tr('${p.label} sudah', '${_itemLabel(context, p)} completed')
                                      : context.tr('${p.label} belum', '${_itemLabel(context, p)} not completed'),
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
                    Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(context.tr('Tilawah Al-Qur\'an', 'Quran Recitation'), style: t.titleMedium)),
                    IconButton(
                      tooltip: context.tr('Kurangi halaman', 'Decrease pages'),
                      onPressed: pages == 0
                          ? null
                          : () async {
                              await repo.addTilawahPages(d.today.day, -1);
                              _load();
                            },
                      icon: const Icon(MoeslimIcons.minusLingkar),
                    ),
                    IconButton(
                      key: const Key('add-page'),
                      tooltip: context.tr('Tambah halaman', 'Add page'),
                      onPressed: () async {
                        await repo.addTilawahPages(d.today.day, 1);
                        _load();
                      },
                      icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
                    ),
                  ],
                ),
                Text(
                  context.tr('$pages / $target halaman', '$pages / $target pages'),
                  key: const Key('tilawah-pages'),
                  style: t.titleLarge,
                ),
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
                label: context.tr('Streak Salat', 'Prayer Streak'),
                value: context.tr('${d.streak} hari', '${d.streak} ${d.streak == 1 ? 'day' : 'days'}'),
                valueKey: 'streak',
              ),
            ),
            Expanded(
              child: _StatCard(
                icon: MoeslimIcons.pencapaian,
                color: BrandColors.goldText,
                label: context.tr('Terbaik', 'Best'),
                value: context.tr('${d.best} hari', '${d.best} ${d.best == 1 ? 'day' : 'days'}'),
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
                Text(context.tr('Grafik Ibadah Mingguan', 'Weekly Worship Chart'), style: t.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final day in d.week)
                        Expanded(
                          child: Semantics(
                            label: context.tr(
                              '${_dayShort(day.day, lang)} ${(day.progress * 100).round()} persen',
                              '${_dayShort(day.day, lang)} ${(day.progress * 100).round()} percent',
                            ),
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
                                Text(_dayShort(day.day, lang), style: const TextStyle(fontSize: 11)),
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
            title: Text(context.longDateText(day.day)),
            subtitle: Text(
              day.items.isEmpty
                  ? context.tr('Belum ada catatan', 'No entries yet')
                  : day.items.map((e) => _itemLabel(context, e)).join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text('${(day.progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
    ],
  );

  static String _dayShort(DateTime d, AppLanguage lang) => lang == AppLanguage.en
      ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1]
      : const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][d.weekday - 1];
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
