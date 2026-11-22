import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';

class GuidedDzikirPage extends ConsumerStatefulWidget {
  final GuidedDzikirTime initialTime;
  const GuidedDzikirPage({super.key, this.initialTime = GuidedDzikirTime.pagi});

  @override
  ConsumerState<GuidedDzikirPage> createState() => _GuidedDzikirPageState();
}

class _GuidedDzikirPageState extends ConsumerState<GuidedDzikirPage> {
  late int _tabIndex;
  Map<String, int> _counts = {};
  bool _loading = true;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  GuidedDzikirTime get _currentTime => GuidedDzikirTime.values[_tabIndex];

  @override
  void initState() {
    super.initState();
    _tabIndex = GuidedDzikirTime.values.indexOf(widget.initialTime);
    _load();
  }

  Future<void> _load() async {
    final counts = await ref.read(guidedDzikirRepoProvider).countsForDay(_today);
    if (mounted) {
      setState(() {
        _counts = counts;
        _loading = false;
      });
    }
  }

  Future<void> _tapItem(GuidedDzikirItem item) async {
    final repo = ref.read(guidedDzikirRepoProvider);
    final next = await repo.increment(_today, item);
    if (next >= item.targetCount) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    final updated = Map<String, int>.from(_counts)..[item.id] = next;
    setState(() => _counts = updated);
    await _syncTrackerIfCompleted(updated);
  }

  Future<void> _completeDirectly(GuidedDzikirItem item) async {
    final repo = ref.read(guidedDzikirRepoProvider);
    final next = await repo.setCount(_today, item, item.targetCount);
    HapticFeedback.mediumImpact();
    final updated = Map<String, int>.from(_counts)..[item.id] = next;
    setState(() => _counts = updated);
    await _syncTrackerIfCompleted(updated);
  }

  Future<void> _resetItem(GuidedDzikirItem item) async {
    await ref.read(guidedDzikirRepoProvider).setCount(_today, item, 0);
    setState(() => _counts = Map<String, int>.from(_counts)..[item.id] = 0);
  }

  Future<void> _resetSession() async {
    await ref.read(guidedDzikirRepoProvider).resetSession(_today, _currentTime);
    await _load();
  }

  Future<void> _syncTrackerIfCompleted(Map<String, int> counts) async {
    final items = guidedDzikirFor(_currentTime);
    final allDone = items.isNotEmpty && items.every((e) => (counts[e.id] ?? 0) >= e.targetCount);
    if (allDone) {
      final tracker = ref.read(trackerRepoProvider);
      final dayItems = await tracker.day(_today);
      if (!dayItems.contains(TrackerItem.dzikir)) {
        await tracker.toggle(_today, TrackerItem.dzikir);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = guidedDzikirFor(_currentTime);
    final completedCount = items.where((e) => (_counts[e.id] ?? 0) >= e.targetCount).length;
    final progress = items.isEmpty ? 0.0 : completedCount / items.length;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dzikir Terpandu'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('guided-dzikir-reset-session'),
            tooltip: 'Ulangi sesi ini',
            onPressed: _resetSession,
            icon: const Icon(MoeslimIcons.ulang),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Dzikir Pagi', 'Dzikir Petang', 'Ba\'da Salat'],
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _tabIndex == 0
                                          ? MoeslimIcons.matahari
                                          : (_tabIndex == 1 ? MoeslimIcons.bulan : MoeslimIcons.zikr),
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _currentTime.label,
                                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(
                                      '$completedCount / ${items.length} selesai',
                                      key: const Key('guided-dzikir-progress-text'),
                                      style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(_currentTime.timeHint, style: t.bodySmall),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final item = items[index - 1];
                      final count = _counts[item.id] ?? 0;
                      final done = count >= item.targetCount;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: done ? scheme.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  OctagonNumber(item.order),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Target: ${item.targetCount}x · ${item.source}',
                                          style: t.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (done)
                                    Icon(MoeslimIcons.berhasil, color: scheme.primary, semanticLabel: 'Selesai'),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                item.arabic,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: quranTextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.latin,
                                style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 6),
                              Text(item.translation, style: t.bodyMedium),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: .07),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Keutamaan: ${item.virtue}',
                                  style: t.bodySmall,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  FilledButton.icon(
                                    key: Key('tap-dzikir-${item.id}'),
                                    onPressed: done ? null : () => _tapItem(item),
                                    icon: Icon(done ? MoeslimIcons.berhasil : MoeslimIcons.tasbih),
                                    label: Text(
                                      done
                                          ? 'Selesai ($count/${item.targetCount})'
                                          : 'Hitung Bacaan ($count/${item.targetCount})',
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!done && item.targetCount > 1)
                                        OutlinedButton(
                                          key: Key('done-dzikir-${item.id}'),
                                          onPressed: () => _completeDirectly(item),
                                          child: const Text('Tandai Selesai'),
                                        ),
                                      if (count > 0) ...[
                                        const SizedBox(width: 6),
                                        IconButton(
                                          tooltip: 'Reset bacaan ini',
                                          onPressed: () => _resetItem(item),
                                          icon: const Icon(MoeslimIcons.ulang),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
