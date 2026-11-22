import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import 'agenda_page.dart' show DateBadge;
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'poster_share_sheet.dart';
import 'session.dart';

const dutyLabels = {
  'imam': 'Imam',
  'muadzin': 'Muadzin',
  'khatib': 'Khatib',
  'bilal': 'Bilal',
  'operator': 'Operator',
  'lainnya': 'Lainnya',
};
const prayerLabels = {
  'fajr': 'Subuh',
  'dhuhr': 'Dzuhur',
  'asr': 'Ashar',
  'maghrib': 'Maghrib',
  'isha': 'Isya',
  'jumat': 'Jumat',
  'tarawih': 'Tarawih',
  'ied': 'Id',
};

IconData dutyIcon(String? duty) => switch (duty) {
  'imam' => MoeslimIcons.imam,
  'muadzin' => MoeslimIcons.adzan,
  'khatib' => Icons.record_voice_over_outlined,
  _ => MoeslimIcons.petugas,
};

String dutyLabel(String? duty, String? prayer) =>
    '${dutyLabels[duty] ?? duty ?? ''}${prayer != null ? ' • ${prayerLabels[prayer] ?? prayer}' : ''}';

/// Jadwal Petugas: filter tugas, navigasi minggu, daftar 7 hari, tambah/hapus penugasan.
class StaffPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final bool embedded;
  const StaffPage({super.key, required this.ctx, this.embedded = false});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage> {
  String? _duty;
  late DateTime _weekStart = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) => DateUtils.dateOnly(d).subtract(Duration(days: d.weekday - 1));

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final key = (ctx.id, isoDate(_weekStart), isoDate(weekEnd));
    final staff = ref.watch(staffProvider(key));
    final canWrite = ctx.can('staff.write');
    final today = DateUtils.dateOnly(DateTime.now());

    final body = RefreshIndicator(
      onRefresh: () => ref.refresh(staffProvider(key).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          Row(
            children: [
              for (final (v, l, i) in const [
                ('imam', 'Imam', MoeslimIcons.imam),
                ('muadzin', 'Muadzin', MoeslimIcons.adzan),
                ('khatib', 'Khatib', Icons.record_voice_over_outlined),
                (null, 'Semua', MoeslimIcons.grid),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _DutyFilter(
                      key: Key('duty-${v ?? 'all'}'),
                      icon: i,
                      label: l,
                      selected: _duty == v,
                      onTap: () => setState(() => _duty = v),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const MosqueBanner(
            title: 'Jadwal Petugas Masjid',
            subtitle: 'Atur jadwal imam, muadzin, dan khatib secara mingguan.',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: 'Minggu sebelumnya',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7))),
              ),
              Expanded(
                child: Text(
                  'Minggu, ${_weekStart.day} – ${shortDate(weekEnd)}',
                  key: const Key('week-label'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              IconButton(
                tooltip: 'Minggu berikutnya',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
              ),
            ],
          ),
          AsyncBody(
            value: staff,
            onRetry: () => ref.invalidate(staffProvider(key)),
            data: (list) {
              final friday = _weekStart.add(const Duration(days: 4));
              final fridayRows = list.where((a) => a['date'] == isoDate(friday)).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    key: const Key('share-friday-staff'),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => PosterShareSheet(
                        data: WaTextBuilder.forFridayStaff(ctx.name, friday, fridayRows),
                      ),
                    ),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Poster & WA Petugas Jumat'),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < 7; i++)
                  Builder(
                    builder: (_) {
                      final day = _weekStart.add(Duration(days: i));
                      final rows = list
                          .where((a) => a['date'] == isoDate(day) && (_duty == null || a['duty_type'] == _duty))
                          .toList();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              DateBadge(day, highlighted: day == today),
                              const SizedBox(width: 12),
                              Expanded(
                                child: rows.isEmpty
                                    ? const Text('Belum ada petugas', style: TextStyle(fontStyle: FontStyle.italic))
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (final a in rows)
                                            InkWell(
                                              onLongPress: canWrite ? () => _confirmDelete(a) : null,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      dutyIcon(a['duty_type'] as String?),
                                                      size: 16,
                                                      color: BrandColors.emerald,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    SizedBox(
                                                      width: 118,
                                                      child: Text(
                                                        dutyLabel(a['duty_type'] as String?, a['prayer'] as String?),
                                                        style: const TextStyle(fontSize: 12.5),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '${a['name']}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                              if (canWrite)
                                IconButton(
                                  key: Key('add-staff-${day.day}'),
                                  tooltip: 'Tambah petugas',
                                  icon: const Icon(MoeslimIcons.edit, color: BrandColors.emerald),
                                  onPressed: () => _openForm(day),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                if (canWrite)
                  const Text(
                    'Tekan lama nama petugas untuk menghapus.',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
              ],
            );
            },
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: const Text('Jadwal Petugas'), centerTitle: true),
      body: body,
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus penugasan?'),
        content: Text('${a['name']}: ${dutyLabel(a['duty_type'] as String?, a['prayer'] as String?)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(masjidApiProvider).deleteStaffAssignment(widget.ctx.id, a['id'] as int);
      ref.invalidate(staffProvider);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  Future<void> _openForm(DateTime day) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StaffForm(ctx: widget.ctx, date: day, duty: _duty ?? 'imam'),
  );
}

class _DutyFilter extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DutyFilter({super.key, required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? scheme.primary : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, color: selected ? scheme.onPrimary : scheme.primary),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffForm extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final DateTime date;
  final String duty;
  const _StaffForm({required this.ctx, required this.date, required this.duty});

  @override
  ConsumerState<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends ConsumerState<_StaffForm> {
  late String _duty = widget.duty;
  String? _prayer;
  int? _userId;
  final _external = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider(widget.ctx.id)).value;
    final active = ((members?['data'] as List?) ?? const []).cast<Map>().where((m) => m['status'] == 'active').toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Petugas ${longDate(widget.date)}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _duty,
            decoration: const InputDecoration(labelText: 'Tugas'),
            items: [for (final d in dutyLabels.entries) DropdownMenuItem(value: d.key, child: Text(d.value))],
            onChanged: (v) => setState(() => _duty = v ?? _duty),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _prayer,
            decoration: const InputDecoration(labelText: 'Waktu salat (opsional)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tidak ditentukan')),
              for (final p in prayerLabels.entries) DropdownMenuItem(value: p.key, child: Text(p.value)),
            ],
            onChanged: (v) => setState(() => _prayer = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _userId,
            decoration: const InputDecoration(labelText: 'Pengurus'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Petugas dari luar (isi nama)')),
              for (final m in active) DropdownMenuItem(value: m['user_id'] as int, child: Text('${m['name']}')),
            ],
            onChanged: (v) => setState(() => _userId = v),
          ),
          if (_userId == null) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('staff-name'),
              controller: _external,
              decoration: const InputDecoration(labelText: 'Nama petugas', hintText: 'Contoh: Ust. Ahmad'),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('save-staff'),
            onPressed: () async {
              try {
                await ref.read(masjidApiProvider).createStaffAssignment(widget.ctx.id, {
                  'duty_type': _duty,
                  'prayer': _prayer,
                  'date': isoDate(widget.date),
                  if (_userId != null) 'user_id': _userId else 'external_name': _external.text.trim(),
                });
                ref.invalidate(staffProvider);
                if (context.mounted) Navigator.pop(context);
              } on ApiException catch (e) {
                setState(
                  () =>
                      _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
