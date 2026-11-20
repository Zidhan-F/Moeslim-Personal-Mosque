import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'finance_pages.dart' show monthLabel;
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const eventCategories = {
  'kajian': 'Kajian',
  'jumat': 'Jumat',
  'ramadan': 'Ramadan',
  'sosial': 'Sosial',
  'pendidikan': 'Pendidikan',
  'lainnya': 'Lainnya',
};
String categoryLabel(String? c) => eventCategories[c] ?? (c ?? '-');

const _dayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahd'];
const _monthShort = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// Lencana tanggal (hari / tanggal / bulan) untuk daftar agenda & petugas.
class DateBadge extends StatelessWidget {
  final DateTime date;
  final bool highlighted;
  const DateBadge(this.date, {super.key, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primary : scheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: highlighted ? scheme.onPrimary : scheme.onSurface, height: 1.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_dayShort[date.weekday - 1], style: const TextStyle(fontSize: 11)),
            Text('${date.day}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(_monthShort[date.month - 1], style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// Agenda / Kegiatan: tab Kalender (grid bulan bertitik) dan Daftar, tombol Tambah Kegiatan.
class AgendaPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final bool embedded;
  const AgendaPage({super.key, required this.ctx, this.embedded = false});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  int _tab = 0;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final events = ref.watch(eventsProvider(ctx.id));
    final body = RefreshIndicator(
      onRefresh: () => ref.refresh(eventsProvider(ctx.id).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          PillTabs(labels: const ['Kalender', 'Daftar'], index: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: 12),
          AsyncBody(
            value: events,
            onRetry: () => ref.invalidate(eventsProvider(ctx.id)),
            data: (list) {
              final parsed = [for (final e in list) (DateTime.parse(e['starts_at'] as String).toLocal(), e)]
                ..sort((a, b) => a.$1.compareTo(b.$1));
              if (_tab == 1) return _list(parsed);
              final shown = _selected == null
                  ? parsed
                        .where((p) => !p.$1.isBefore(DateTime.now().subtract(const Duration(hours: 12))))
                        .take(5)
                        .toList()
                  : parsed.where((p) => DateUtils.isSameDay(p.$1, _selected)).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _MonthGrid(
                        month: _month,
                        selected: _selected,
                        eventDays: {for (final p in parsed) DateUtils.dateOnly(p.$1)},
                        onMonth: (m) => setState(() => _month = m),
                        onDay: (d) => setState(() => _selected = DateUtils.isSameDay(d, _selected) ? null : d),
                      ),
                    ),
                  ),
                  SectionHeader(_selected == null ? 'Agenda Terdekat' : 'Agenda ${shortDate(_selected!)}'),
                  if (shown.isEmpty) const EmptyState(Icons.event_busy_outlined, 'Tidak ada agenda'),
                  for (final p in shown) _EventCard(ctx: ctx, event: p.$2, start: p.$1),
                ],
              );
            },
          ),
        ],
      ),
    );
    final fab = ctx.can('events.write')
        ? FloatingActionButton.extended(
            heroTag: null,
            key: const Key('add-event'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kegiatan'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventFormPage(ctx: ctx))),
          )
        : null;
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: const Text('Agenda / Kegiatan'), centerTitle: true),
      floatingActionButton: fab,
      body: body,
    );
  }

  Widget _list(List<(DateTime, Map<String, dynamic>)> parsed) {
    if (parsed.isEmpty) return const EmptyState(Icons.event_note_outlined, 'Belum ada agenda aktif');
    return Column(
      children: [for (final p in parsed) _EventCard(ctx: widget.ctx, event: p.$2, start: p.$1)],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selected;
  final Set<DateTime> eventDays;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<DateTime> onDay;
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.eventDays,
    required this.onMonth,
    required this.onDay,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final first = DateTime(month.year, month.month);
    final start = first.subtract(Duration(days: first.weekday - 1));
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Bulan sebelumnya',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onMonth(DateTime(month.year, month.month - 1)),
            ),
            Expanded(
              child: Text(
                monthLabel(month),
                key: const Key('calendar-month'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Bulan berikutnya',
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onMonth(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        Row(
          children: [
            for (final d in _dayShort)
              Expanded(
                child: Center(
                  child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var w = 0; w < 6; w++)
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final day = DateTime(start.year, start.month, start.day + w * 7 + i);
                      final inMonth = day.month == month.month;
                      final isSel = selected != null && DateUtils.isSameDay(day, selected);
                      final isToday = day == today;
                      final hasEvent = eventDays.contains(day);
                      return InkWell(
                        key: inMonth ? Key('day-${day.day}') : null,
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onDay(day),
                        child: Container(
                          height: 42,
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: isSel ? scheme.primary : (isToday ? scheme.primary.withValues(alpha: .12) : null),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontWeight: isToday || isSel ? FontWeight.w800 : FontWeight.w500,
                                  color: isSel ? scheme.onPrimary : (inMonth ? scheme.onSurface : scheme.outline),
                                ),
                              ),
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasEvent
                                      ? (isSel ? BrandColors.gold : BrandColors.emerald)
                                      : Colors.transparent,
                                ),
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
      ],
    );
  }
}

class _EventCard extends ConsumerWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> event;
  final DateTime start;
  const _EventCard({required this.ctx, required this.event, required this.start});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = event;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        key: Key('event-${e['id']}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: DateBadge(start),
        title: Text('${e['title']}', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${hhmm(start)}${e['location'] != null ? ' • ${e['location']}' : ''}'),
            if (e['speaker'] != null) Text('${e['speaker']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusBadge(categoryLabel(e['category'] as String?)),
            const SizedBox(height: 4),
            Icon(
              e['visibility'] == 'public' ? Icons.public : Icons.lock_outline,
              size: 16,
              semanticLabel: e['visibility'] == 'public' ? 'Publik' : 'Internal',
            ),
          ],
        ),
      ),
    );
  }
}

/// Formulir Tambah Kegiatan.
class EventFormPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const EventFormPage({super.key, required this.ctx});

  @override
  ConsumerState<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends ConsumerState<EventFormPage> {
  final _title = TextEditingController();
  final _speaker = TextEditingController();
  final _location = TextEditingController();
  final _desc = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 30);
  String _category = 'kajian';
  bool _public = true;
  bool _display = true;
  bool _busy = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    try {
      final start = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
      await ref.read(masjidApiProvider).createEvent(widget.ctx.id, {
        'title': _title.text.trim(),
        'speaker': opt(_speaker),
        'location': opt(_location),
        'description': opt(_desc),
        'category': _category,
        'starts_at': start.toUtc().toIso8601String(),
        'visibility': _public ? 'public' : 'internal',
        'show_on_display': _public && _display,
      });
      ref.invalidate(eventsProvider(widget.ctx.id));
      ref.invalidate(dashboardProvider(widget.ctx.id));
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kegiatan'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('event-title'),
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Nama kegiatan *',
              prefixIcon: Icon(Icons.event_note_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category_outlined)),
            items: [for (final c in eventCategories.entries) DropdownMenuItem(value: c.key, child: Text(c.value))],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: _date,
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(shortDate(_date)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _time);
                    if (t != null) setState(() => _time = t);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Jam', prefixIcon: Icon(Icons.schedule)),
                    child: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: const InputDecoration(
              labelText: 'Lokasi',
              hintText: 'Contoh: Aula Masjid',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _speaker,
            decoration: const InputDecoration(
              labelText: 'Pemateri / penanggung jawab',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Deskripsi', alignLabelWithHint: true),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Publik (tampil untuk jamaah)'),
            value: _public,
            onChanged: (v) => setState(() => _public = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tayangkan di TV Display'),
            value: _public && _display,
            onChanged: _public ? (v) => setState(() => _display = v) : null,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          FilledButton.icon(
            key: const Key('save-event'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
            onPressed: _busy ? null : _save,
            icon: const Icon(Icons.check),
            label: const Text('Simpan Kegiatan'),
          ),
        ],
      ),
    );
  }
}
