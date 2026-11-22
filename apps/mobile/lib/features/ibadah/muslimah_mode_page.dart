import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class MuslimahModePage extends ConsumerStatefulWidget {
  const MuslimahModePage({super.key});

  @override
  ConsumerState<MuslimahModePage> createState() => _MuslimahModePageState();
}

class _MuslimahModePageState extends ConsumerState<MuslimahModePage> {
  Set<String> _uzurDays = {};
  List<HaidCycleRecord> _cycles = const [];
  QadhaSummary _qadha = const QadhaSummary(totalDebtDays: 0, completedQadhaDays: 0, fidyahDaysPaid: 0);
  bool _loading = true;

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
    final repo = ref.read(muslimahRepoProvider);
    final uzur = await repo.uzurDayKeys();
    final cycles = await repo.allCycles();
    final qadha = await ref.read(fastingRepoProvider).qadhaSummary();
    if (mounted) {
      setState(() {
        _uzurDays = uzur;
        _cycles = cycles;
        _qadha = qadha;
        _loading = false;
      });
    }
  }

  Future<void> _toggleTodayUzur() async {
    final offset = ref.read(settingsProvider).value?.hijriOffset ?? 0;
    await ref.read(muslimahRepoProvider).toggleUzurDay(
          _today,
          hijriOffset: offset,
          fastingRepo: ref.read(fastingRepoProvider),
        );
    await _load();
  }

  Future<void> _toggleCycle() async {
    final repo = ref.read(muslimahRepoProvider);
    final active = _cycles.where((c) => c.isActive).firstOrNull;
    if (active == null) {
      await repo.startCycle(_today);
    } else {
      await repo.endActiveCycle(_today);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = TrackerRepository.dayKey(_today);
    final isTodayUzur = _uzurDays.contains(todayKey);
    final activeCycle = _cycles.where((c) => c.isActive).firstOrNull;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Mode Muslimah (Haid & Qadha)', 'Muslimah Mode (Period & Qadha)')), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PatternBanner(
                  child: Text(
                    context.tr(
                      '100% tersimpan lokal di perangkat Anda. Saat hari ditandai sedang uzur haid, streak salat di Catatan Ibadah otomatis dijeda (tidak terputus) dan hari Ramadan otomatis masuk ke utang Qadha puasa.',
                      '100% stored locally on your device. When a day is marked as a menstrual exemption, your prayer streak in Worship Log is paused (not broken) and Ramadan days are automatically added to your Qadha fasting balance.',
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    key: const Key('muslimah-today-uzur-switch'),
                    secondary: Icon(MoeslimIcons.cinta, color: scheme.primary),
                    title: Text(
                      context.tr('Tandai Hari Ini Sedang Uzur Haid', 'Mark Today as Menstrual Exemption'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      isTodayUzur
                          ? context.tr(
                              'Aktif hari ini ($todayKey): Streak salat dijeda & dilindungi.',
                              'Active today ($todayKey): Prayer streak is paused & protected.',
                            )
                          : context.tr(
                              'Status hari ini: Suci (Wajib salat & puasa Ramadan).',
                              'Today\'s status: Pure (Regular prayers & Ramadan fasting apply).',
                            ),
                    ),
                    value: isTodayUzur,
                    onChanged: (_) => _toggleTodayUzur(),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('Pencatat Siklus & Utang Qadha Otomatis', 'Cycle Tracker & Automatic Qadha Debt'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeCycle != null
                              ? context.tr(
                                  'Siklus berjalan sejak ${activeCycle.startDateKey} (${activeCycle.durationDays} hari)',
                                  'Active cycle since ${activeCycle.startDateKey} (${activeCycle.durationDays} days)',
                                )
                              : context.tr(
                                  'Tidak ada siklus aktif yang sedang berlangsung.',
                                  'No active cycle currently in progress.',
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'Total Utang Qadha Puasa Tercatat: ${_qadha.remainingDays} hari',
                            'Recorded Qadha Fasting Days Remaining: ${_qadha.remainingDays} days',
                          ),
                          style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const Key('muslimah-cycle-btn'),
                          onPressed: _toggleCycle,
                          icon: Icon(activeCycle == null ? MoeslimIcons.kalender : MoeslimIcons.berhasil),
                          label: Text(
                            activeCycle == null
                                ? context.tr('Catat Mulai Siklus Haid Baru', 'Start New Menstrual Cycle')
                                : context.tr('Tandai Sudah Suci (Selesai Siklus)', 'Mark as Pure (End Cycle)'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SectionHeader(
                  context.tr(
                    'Amalan & Panduan Saat Haid & Setelah Suci',
                    'Worship & Guidance During Menstruation & Purification',
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      context.tr(
                        '• Ibadah yang Tetap Dianjurkan Saat Haid: Dzikir pagi & petang, istighfar, shalawat, doa harian, mendengarkan murottal, dan menyimak kajian ilmu.\n'
                        '• Qadha: Salat fardhu yang ditinggalkan saat haid TIDAK wajib di-qadha, sedangkan puasa Ramadan WAJIB di-qadha di hari lain (HR. Muslim no. 335).\n'
                        '• Tata Cara Mandi Wajib (Ghusl) Setelah Suci: Berniat mandi wajib untuk menghilangkan hadats besar, mencuci tangan, membersihkan kemaluan, berwudhu, menyiram kepala 3 kali hingga pangkal rambut, lalu mengguyur seluruh tubuh dari sisi kanan kemudian kiri.',
                        '• Recommended Acts During Menstruation: Morning and evening dhikr, istighfar, salawat, daily duas, listening to Quran recitation, and seeking beneficial knowledge.\n'
                        '• Qadha: Obligatory prayers missed during menstruation do NOT need to be made up, while missed Ramadan fasts MUST be made up on other days (Sahih Muslim no. 335).\n'
                        '• Ritual Bath (Ghusl) After Purification: Make the intention to remove major impurity, wash both hands, clean the private area, perform wudu, pour water over the head 3 times down to the roots of the hair, then wash the entire body starting from the right side followed by the left.',
                      ),
                      style: t.bodyMedium,
                    ),
                  ),
                ),
                SectionHeader(context.tr('Riwayat Siklus (${_cycles.length})', 'Cycle History (${_cycles.length})')),
                for (final c in _cycles)
                  Card(
                    child: ListTile(
                      leading: Icon(MoeslimIcons.kalender, color: scheme.primary),
                      title: Text(
                        c.isActive
                            ? context.tr('Mulai: ${c.startDateKey} (Sedang Berjalan)', 'Started: ${c.startDateKey} (Ongoing)')
                            : context.tr('${c.startDateKey} s.d. ${c.endDateKey}', '${c.startDateKey} to ${c.endDateKey}'),
                      ),
                      subtitle: Text(context.tr('Durasi: ${c.durationDays} hari', 'Duration: ${c.durationDays} days')),
                    ),
                  ),
              ],
            ),
    );
  }
}
