import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class FastingTrackerPage extends ConsumerStatefulWidget {
  const FastingTrackerPage({super.key});

  @override
  ConsumerState<FastingTrackerPage> createState() => _FastingTrackerPageState();
}

class _FastingTrackerPageState extends ConsumerState<FastingTrackerPage> {
  int _tab = 0;
  List<FastingLogEntry> _logs = const [];
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
    final repo = ref.read(fastingRepoProvider);
    final logs = await repo.allLogs();
    final qadha = await repo.qadhaSummary();
    if (mounted) {
      setState(() {
        _logs = logs;
        _qadha = qadha;
        _loading = false;
      });
    }
  }

  Future<void> _logToday(FastingType? type) async {
    await ref.read(fastingRepoProvider).setFastingForDate(_today, type);
    await _load();
  }

  Future<void> _updateQadha({int? total, int? completed, int? fidyah}) async {
    await ref.read(fastingRepoProvider).saveQadhaSummary(
          totalDebtDays: total ?? _qadha.totalDebtDays,
          completedQadhaDays: completed ?? _qadha.completedQadhaDays,
          fidyahDaysPaid: fidyah ?? _qadha.fidyahDaysPaid,
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacak Puasa & Qadha'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Hari Ini & Jadwal', 'Utang Qadha', 'Riwayat & Doa'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : switch (_tab) {
                    0 => _buildTodayTab(context),
                    1 => _buildQadhaTab(context),
                    _ => _buildHistoryAndDuaTab(context),
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    final prayerStatus = ref.watch(prayerStatusProvider).value;
    final offset = settings?.hijriOffset ?? 0;
    final todayStatus = evaluateFastingDate(_today, hijriOffset: offset);
    final todayKey = TrackerRepository.dayKey(_today);
    final todayLog = _logs.where((e) => e.dateKey == todayKey).firstOrNull;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Next 14 days fasting recommendations
    final upcoming = <FastingDayStatus>[
      for (var i = 1; i <= 14; i++)
        evaluateFastingDate(_today.add(Duration(days: i)), hijriOffset: offset),
    ].where((d) => d.recommended.isNotEmpty || d.isForbidden).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ArchHeader(
          child: Column(
            children: [
              Text(longDate(_today), style: t.titleMedium),
              Text(todayStatus.hijri.toString(), style: t.bodyMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
              if (prayerStatus != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Batas Sahur (Subuh): ${hhmm(prayerStatus.today.fajr)} · Berbuka (Maghrib): ${hhmm(prayerStatus.today.maghrib)}',
                  textAlign: TextAlign.center,
                  style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (todayStatus.isForbidden)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(MoeslimIcons.peringatan, color: scheme.error),
                  const SizedBox(width: 12),
                  Expanded(child: Text(todayStatus.forbiddenReason ?? 'Hari terlarang berpuasa.')),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todayLog != null
                        ? 'Hari Ini Tercatat: ${todayLog.type.label}'
                        : 'Catat Ibadah Puasa Hari Ini',
                    key: const Key('fasting-today-status'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayStatus.recommended.isNotEmpty
                        ? 'Rekomendasi hari ini: ${todayStatus.recommended.map((e) => e.label).join(', ')}'
                        : 'Anda dapat mencatat Puasa Qadha Ramadan atau Puasa Sunnah hari ini.',
                    style: t.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in FastingType.values)
                        ChoiceChip(
                          key: Key('fasting-chip-${type.name}'),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          label: Text(type.label),
                          selected: todayLog?.type == type,
                          onSelected: (selected) => _logToday(selected ? type : null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SectionHeader('Jadwal Puasa Sunnah 14 Hari ke Depan'),
        if (upcoming.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada jadwal khusus dalam 14 hari ke depan.'),
            ),
          )
        else
          for (final d in upcoming)
            Card(
              child: ListTile(
                leading: Icon(
                  d.isForbidden ? MoeslimIcons.peringatan : MoeslimIcons.bulan,
                  color: d.isForbidden ? scheme.error : scheme.primary,
                ),
                title: Text('${shortDate(d.gregorian)} · ${d.hijri}'),
                subtitle: Text(
                  d.isForbidden
                      ? (d.forbiddenReason ?? '')
                      : d.recommended.map((r) => r.label).join(', '),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildQadhaTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final total = _qadha.totalDebtDays;
    final ratio = total <= 0 ? 1.0 : ((_qadha.completedQadhaDays + _qadha.fidyahDaysPaid) / total).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Utang Puasa (Qadha Ramadan)', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Sisa Utang: ${_qadha.remainingDays} hari',
                  key: const Key('qadha-remaining-days'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const Divider(height: 24),
                _qadhaCounterRow(
                  context,
                  label: 'Total Hari Utang Puasa Ramadan',
                  value: _qadha.totalDebtDays,
                  plusKey: const Key('qadha-add-debt'),
                  onChanged: (v) => _updateQadha(total: v),
                ),
                _qadhaCounterRow(
                  context,
                  label: 'Sudah Di-Qadha (Diganti Puasa)',
                  value: _qadha.completedQadhaDays,
                  plusKey: const Key('qadha-add-completed'),
                  onChanged: (v) => _updateQadha(completed: v),
                ),
                _qadhaCounterRow(
                  context,
                  label: 'Ditunaikan via Fidyah (Uzur Syar\'i)',
                  value: _qadha.fidyahDaysPaid,
                  onChanged: (v) => _updateQadha(fidyah: v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _qadhaCounterRow(
    BuildContext context, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    Key? plusKey,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: 'Kurangi $label',
            onPressed: value <= 0 ? null : () => onChanged(value - 1),
            icon: const Icon(MoeslimIcons.minusLingkar),
          ),
          Text('$value hari', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            key: plusKey,
            tooltip: 'Tambah $label',
            onPressed: () => onChanged(value + 1),
            icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryAndDuaTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Doa Berbuka Puasa Shahih', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(
                  'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dzahabazh-zhama\'u wabtallatil-\'uruqu wa tsabatal-ajru insya Allah.',
                  style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  'Artinya: "Telah hilang rasa haus, telah basah kerongkongan, dan telah tetap pahala insya Allah." (HR. Abu Dawud no. 2357 · Hasan)',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionHeader('Riwayat Puasa Tercatat (${_logs.length})'),
        if (_logs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada riwayat puasa yang dicatat. Pilih jenis puasa di tab Hari Ini untuk mulai mencatat.'),
            ),
          )
        else
          for (final entry in _logs)
            Card(
              child: ListTile(
                leading: const Icon(MoeslimIcons.berhasil, color: BrandColors.emerald),
                title: Text(entry.type.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Tanggal: ${entry.dateKey} · ${entry.type.description}'),
              ),
            ),
      ],
    );
  }
}
