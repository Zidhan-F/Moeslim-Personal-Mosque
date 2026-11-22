import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

String _khatamStatusLabel(BuildContext context, KhatamPlan plan, DateTime now) {
  if (!context.isEn) return plan.statusLabelAt(now);
  if (plan.completedPages >= KhatamPlan.totalMushafPages) {
    return 'Alhamdulillah, 604 Pages Completed!';
  }
  final delta = plan.deltaPagesAt(now);
  if (delta > 2) return '$delta pages ahead of schedule';
  if (delta < -2) return '${delta.abs()} pages behind schedule';
  return 'On track with your daily goal';
}

class KhatamPlannerPage extends ConsumerStatefulWidget {
  const KhatamPlannerPage({super.key});

  @override
  ConsumerState<KhatamPlannerPage> createState() => _KhatamPlannerPageState();
}

class _KhatamPlannerPageState extends ConsumerState<KhatamPlannerPage> {
  KhatamPlan? _plan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(khatamPlannerRepoProvider).load();
    if (mounted) setState(() => _plan = p);
  }

  Future<void> _setTargetDays(int days) async {
    final p = _plan ?? KhatamPlan(targetDays: days, startDate: DateTime.now());
    final next = await ref.read(khatamPlannerRepoProvider).save(p.copyWith(targetDays: days));
    if (mounted) setState(() => _plan = next);
  }

  Future<void> _addPages(int delta) async {
    final next = await ref.read(khatamPlannerRepoProvider).addPages(delta);
    if (delta > 0) {
      final now = DateTime.now();
      await ref.read(trackerRepoProvider).addTilawahPages(DateTime(now.year, now.month, now.day), delta);
    }
    if (mounted) setState(() => _plan = next);
  }

  Future<void> _resetPlan() async {
    final p = _plan ?? KhatamPlan(targetDays: 30, startDate: DateTime.now());
    final next = await ref.read(khatamPlannerRepoProvider).save(
          KhatamPlan(targetDays: p.targetDays, startDate: DateTime.now(), completedPages: 0),
        );
    if (mounted) setState(() => _plan = next);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Perencana Khatam Al-Qur\'an', 'Qur\'an Khatam Planner')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: context.tr('Mulai ulang khatam dari halaman 1', 'Restart khatam from page 1'),
            onPressed: _resetPlan,
            icon: const Icon(MoeslimIcons.ulang),
          ),
        ],
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ArchHeader(
                  child: Column(
                    children: [
                      Text(
                        context.tr(
                          '${plan.completedPages} / ${KhatamPlan.totalMushafPages} Halaman',
                          '${plan.completedPages} / ${KhatamPlan.totalMushafPages} Pages',
                        ),
                        key: const Key('khatam-progress-pages'),
                        style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          'Juz ${plan.currentJuz} · Halaman berikutnya: ${plan.currentPageToRead}',
                          'Juz ${plan.currentJuz} · Next page: ${plan.currentPageToRead}',
                        ),
                        style: t.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: plan.progressRatio,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _khatamStatusLabel(context, plan, now),
                        key: const Key('khatam-status-label'),
                        style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('Catat Kemajuan Bacaan Hari Ini', 'Log Today\'s Reading Progress'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              key: const Key('khatam-add-prayer-portion'),
                              onPressed: () => _addPages(plan.pagesPerPrayer),
                              icon: const Icon(MoeslimIcons.berhasil),
                              label: Text(
                                context.tr(
                                  '+${plan.pagesPerPrayer} Hal (1 Waktu Salat)',
                                  '+${plan.pagesPerPrayer} Pages (1 Prayer)',
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              key: const Key('khatam-add-one-page'),
                              onPressed: () => _addPages(1),
                              icon: const Icon(MoeslimIcons.tambahLingkar),
                              label: Text(context.tr('+1 Halaman', '+1 Page')),
                            ),
                            if (plan.completedPages > 0)
                              OutlinedButton.icon(
                                onPressed: () => _addPages(-1),
                                icon: const Icon(MoeslimIcons.minusLingkar),
                                label: Text(context.tr('-1 Halaman', '-1 Page')),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SectionHeader(context.tr('Target Durasi Khatam (604 Halaman)', 'Khatam Duration Goal (604 Pages)')),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final days in [15, 30, 60, 90, 180])
                      ChoiceChip(
                        key: Key('khatam-target-$days'),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(context.tr('$days Hari', '$days Days')),
                        selected: plan.targetDays == days,
                        onSelected: (_) => _setTargetDays(days),
                      ),
                  ],
                ),
                SectionHeader(context.tr('Pembagian Porsi per Waktu Salat', 'Pages per Prayer Time')),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            'Target Harian: ${plan.dailyTargetPages.toStringAsFixed(1)} halaman / hari',
                            'Daily Target: ${plan.dailyTargetPages.toStringAsFixed(1)} pages / day',
                          ),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        for (final p in const [
                          ('Subuh', 'Fajr'),
                          ('Dzuhur', 'Dhuhr'),
                          ('Ashar', 'Asr'),
                          ('Maghrib', 'Maghrib'),
                          ('Isya', 'Isha'),
                        ])
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
                            title: Text(context.tr("Ba'da Salat ${p.$1}", 'After ${p.$2} Prayer')),
                            trailing: Text(
                              context.tr('${plan.pagesPerPrayer} halaman', '${plan.pagesPerPrayer} pages'),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
