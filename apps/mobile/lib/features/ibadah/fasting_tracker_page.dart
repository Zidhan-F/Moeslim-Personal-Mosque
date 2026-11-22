import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
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

  static String _fastingLabel(BuildContext context, FastingType type) => switch (type) {
        FastingType.ramadan => context.tr(type.label, 'Ramadan Fast'),
        FastingType.qadha => context.tr(type.label, 'Ramadan Qadha'),
        FastingType.seninKamis => context.tr(type.label, 'Monday & Thursday Fast'),
        FastingType.ayyamulBidh => context.tr(type.label, 'Ayyam al-Bidh Fast'),
        FastingType.arafah => context.tr(type.label, 'Arafah Fast (9 Dhu al-Hijjah)'),
        FastingType.asyura => context.tr(type.label, 'Tasu\'a & Ashura Fast'),
        FastingType.syawal => context.tr(type.label, '6 Days of Shawwal'),
        FastingType.daud => context.tr(type.label, 'Dawud / Voluntary Fast'),
      };

  static String _fastingDescription(BuildContext context, FastingType type) => switch (type) {
        FastingType.ramadan => context.tr(
            type.description,
            'Obligatory fast for every accountable Muslim during Ramadan.',
          ),
        FastingType.qadha => context.tr(
            type.description,
            'Making up missed obligatory Ramadan fasting days.',
          ),
        FastingType.seninKamis => context.tr(
            type.description,
            'Regular sunnah fast every Monday and Thursday.',
          ),
        FastingType.ayyamulBidh => context.tr(
            type.description,
            'Sunnah fast on the 13th, 14th, and 15th of each Hijri month.',
          ),
        FastingType.arafah => context.tr(
            type.description,
            'Expiates sins of the past year and the coming year (for non-pilgrims).',
          ),
        FastingType.asyura => context.tr(
            type.description,
            'Sunnah fast on 9th and 10th Muharram; expiates sins of the past year.',
          ),
        FastingType.syawal => context.tr(
            type.description,
            'Fasting Ramadan followed by 6 days in Shawwal equals fasting a full year.',
          ),
        FastingType.daud => context.tr(
            type.description,
            'Alternating sunnah fast (every other day) or general voluntary fast.',
          ),
      };

  static String _forbiddenReason(BuildContext context, FastingDayStatus status) {
    if (!context.isEn) return status.forbiddenReason ?? 'Hari terlarang berpuasa.';
    final h = status.hijri;
    if (h.month == 10 && h.day == 1) {
      return 'Eid al-Fitr (1 Shawwal): fasting is prohibited.';
    }
    if (h.month == 12 && h.day == 10) {
      return 'Eid al-Adha (10 Dhu al-Hijjah): fasting is prohibited.';
    }
    if (h.month == 12 && (h.day == 11 || h.day == 12 || h.day == 13)) {
      return 'Days of Tashriq (${h.day} Dhu al-Hijjah): days of eating, drinking, and remembering Allah.';
    }
    return 'Fasting is prohibited on this day.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Pelacak Puasa & Qadha', 'Fasting & Qadha Tracker')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Hari Ini & Jadwal', 'Today & Schedule'),
                context.tr('Utang Qadha', 'Qadha Debt'),
                context.tr('Riwayat & Doa', 'History & Dua'),
              ],
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
              Text(context.longDateText(_today), style: t.titleMedium),
              Text(
                context.hijriText(todayStatus.hijri),
                style: t.bodyMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
              ),
              if (prayerStatus != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Batas Sahur (Subuh): ${hhmm(prayerStatus.today.fajr)} · Berbuka (Maghrib): ${hhmm(prayerStatus.today.maghrib)}',
                    'Suhoor Cutoff (Fajr): ${hhmm(prayerStatus.today.fajr)} · Iftar (Maghrib): ${hhmm(prayerStatus.today.maghrib)}',
                  ),
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
                  Expanded(child: Text(_forbiddenReason(context, todayStatus))),
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
                        ? context.tr(
                            'Hari Ini Tercatat: ${todayLog.type.label}',
                            'Logged Today: ${_fastingLabel(context, todayLog.type)}',
                          )
                        : context.tr('Catat Ibadah Puasa Hari Ini', 'Log Today\'s Fast'),
                    key: const Key('fasting-today-status'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayStatus.recommended.isNotEmpty
                        ? context.tr(
                            'Rekomendasi hari ini: ${todayStatus.recommended.map((e) => e.label).join(', ')}',
                            'Recommended today: ${todayStatus.recommended.map((e) => _fastingLabel(context, e)).join(', ')}',
                          )
                        : context.tr(
                            'Anda dapat mencatat Puasa Qadha Ramadan atau Puasa Sunnah hari ini.',
                            'You can log a Ramadan Qadha fast or a Sunnah fast today.',
                          ),
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
                          label: Text(_fastingLabel(context, type)),
                          selected: todayLog?.type == type,
                          onSelected: (selected) => _logToday(selected ? type : null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        SectionHeader(
          context.tr('Jadwal Puasa Sunnah 14 Hari ke Depan', 'Upcoming 14-Day Sunnah Fasting Schedule'),
        ),
        if (upcoming.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr(
                  'Belum ada jadwal khusus dalam 14 hari ke depan.',
                  'No special fasting dates in the next 14 days.',
                ),
              ),
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
                title: Text('${context.shortDateText(d.gregorian)} · ${context.hijriText(d.hijri)}'),
                subtitle: Text(
                  d.isForbidden
                      ? _forbiddenReason(context, d)
                      : d.recommended.map((r) => _fastingLabel(context, r)).join(', '),
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
    final rem = _qadha.remainingDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Ringkasan Utang Puasa (Qadha Ramadan)', 'Missed Fasts Summary (Ramadan Qadha)'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Sisa Utang: $rem hari',
                    'Remaining Debt: $rem ${rem == 1 ? 'day' : 'days'}',
                  ),
                  key: const Key('qadha-remaining-days'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const Divider(height: 24),
                _qadhaCounterRow(
                  context,
                  label: context.tr('Total Hari Utang Puasa Ramadan', 'Total Missed Ramadan Days'),
                  value: _qadha.totalDebtDays,
                  plusKey: const Key('qadha-add-debt'),
                  onChanged: (v) => _updateQadha(total: v),
                ),
                _qadhaCounterRow(
                  context,
                  label: context.tr('Sudah Di-Qadha (Diganti Puasa)', 'Completed Qadha Fasts'),
                  value: _qadha.completedQadhaDays,
                  plusKey: const Key('qadha-add-completed'),
                  onChanged: (v) => _updateQadha(completed: v),
                ),
                _qadhaCounterRow(
                  context,
                  label: context.tr('Ditunaikan via Fidyah (Uzur Syar\'i)', 'Settled via Fidyah (Valid Excuse)'),
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
            tooltip: context.tr('Kurangi $label', 'Decrease $label'),
            onPressed: value <= 0 ? null : () => onChanged(value - 1),
            icon: const Icon(MoeslimIcons.minusLingkar),
          ),
          Text(
            context.tr('$value hari', '$value ${value == 1 ? 'day' : 'days'}'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          IconButton(
            key: plusKey,
            tooltip: context.tr('Tambah $label', 'Increase $label'),
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
                Text(
                  context.tr('Doa Berbuka Puasa Shahih', 'Authentic Breaking Fast Dua'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
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
                  context.tr(
                    'Artinya: "Telah hilang rasa haus, telah basah kerongkongan, dan telah tetap pahala insya Allah." (HR. Abu Dawud no. 2357 · Hasan)',
                    'Meaning: "Thirst has gone, the veins are moistened, and the reward is assured, if Allah wills." (Sunan Abi Dawud 2357 · Hasan)',
                  ),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr('Riwayat Puasa Tercatat (${_logs.length})', 'Logged Fasting History (${_logs.length})'),
        ),
        if (_logs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr(
                  'Belum ada riwayat puasa yang dicatat. Pilih jenis puasa di tab Hari Ini untuk mulai mencatat.',
                  'No fasting history logged yet. Choose a fasting type on the Today tab to start logging.',
                ),
              ),
            ),
          )
        else
          for (final entry in _logs)
            Card(
              child: ListTile(
                leading: const Icon(MoeslimIcons.berhasil, color: BrandColors.emerald),
                title: Text(_fastingLabel(context, entry.type), style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  context.tr(
                    'Tanggal: ${entry.dateKey} · ${entry.type.description}',
                    'Date: ${entry.dateKey} · ${_fastingDescription(context, entry.type)}',
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
