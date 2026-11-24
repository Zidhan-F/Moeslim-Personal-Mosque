import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'finance_pages.dart' show monthLabel;
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'poster_share_sheet.dart';
import 'session.dart';

const eventCategories = {
  'kajian': 'Kajian',
  'jumat': 'Jumat',
  'ramadan': 'Ramadan',
  'sosial': 'Sosial',
  'pendidikan': 'Pendidikan',
  'lainnya': 'Lainnya',
};
const eventCategoriesEn = {
  'kajian': 'Lecture',
  'jumat': 'Friday',
  'ramadan': 'Ramadan',
  'sosial': 'Social',
  'pendidikan': 'Education',
  'lainnya': 'Other',
};
String categoryLabel(String? c, {AppLanguage lang = AppLanguage.id}) =>
    (lang == AppLanguage.en ? eventCategoriesEn[c] : eventCategories[c]) ?? (c ?? '-');

const _dayShortId = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahd'];
const _dayShortEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthShortId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const _monthShortEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Lencana tanggal (hari / tanggal / bulan) untuk daftar agenda & petugas.
class DateBadge extends StatelessWidget {
  final DateTime date;
  final bool highlighted;
  const DateBadge(this.date, {super.key, this.highlighted = false});

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final scheme = Theme.of(context).colorScheme;
    final days = context.isEn ? _dayShortEn : _dayShortId;
    final months = context.isEn ? _monthShortEn : _monthShortId;
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
            Text(days[date.weekday - 1], style: const TextStyle(fontSize: 11)),
            Text('${date.day}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(months[date.month - 1], style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  });
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
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final ctx = widget.ctx;
    final events = ref.watch(eventsProvider(ctx.id));
    final body = RefreshIndicator(
      onRefresh: () => ref.refresh(eventsProvider(ctx.id).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          PillTabs(
            labels: [context.tr('Kalender', 'Calendar'), context.tr('Daftar', 'List')],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 12),
          AsyncBody(
            value: events,
            onRetry: () => ref.invalidate(eventsProvider(ctx.id)),
            data: (list) {
              final parsed = [for (final e in list) (DateTime.parse(e['starts_at'] as String).toLocal(), e)]
                ..sort((a, b) => a.$1.compareTo(b.$1));
              if (_tab == 1) return _list(context, parsed);
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
                  SectionHeader(
                    _selected == null
                        ? context.tr('Agenda Terdekat', 'Upcoming Events')
                        : context.tr(
                            'Agenda ${context.shortDateText(_selected!)}',
                            'Events on ${context.shortDateText(_selected!)}',
                          ),
                  ),
                  if (shown.isEmpty)
                    EmptyState(
                      MoeslimIcons.kalender,
                      context.tr('Tidak ada agenda', 'No events'),
                      art: BrandEmptyArt.tidakAdaHasil,
                      message: context.tr('Coba filter atau minggu lain.', 'Try another filter or week.'),
                    ),
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
            icon: const Icon(MoeslimIcons.tambah),
            label: Text(context.tr('Tambah Kegiatan', 'Add Event')),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventFormPage(ctx: ctx))),
          )
        : null;
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: Text(context.tr('Agenda / Kegiatan', 'Schedule / Events')), centerTitle: true),
      floatingActionButton: fab,
      body: body,
    );
  });

  Widget _list(BuildContext context, List<(DateTime, Map<String, dynamic>)> parsed) {
    if (parsed.isEmpty) {
      return EmptyState(
        MoeslimIcons.kegiatan,
        context.tr('Belum ada agenda aktif', 'No active events yet'),
        art: BrandEmptyArt.agenda,
        message: context.tr(
          'Tambahkan kajian, pengajian, atau kegiatan masjid.',
          'Add lectures, study circles, or mosque activities.',
        ),
      );
    }
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
    final days = context.isEn ? _dayShortEn : _dayShortId;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: context.tr('Bulan sebelumnya', 'Previous month'),
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onMonth(DateTime(month.year, month.month - 1)),
            ),
            Expanded(
              child: Text(
                monthLabel(month, lang: context.lang),
                key: const Key('calendar-month'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: context.tr('Bulan berikutnya', 'Next month'),
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onMonth(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        Row(
          children: [
            for (final d in days)
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
    final lang = context.lang;
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(categoryLabel(e['category'] as String?, lang: lang)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (e['publication_status'] != null && e['publication_status'] != 'published') ...[
                      Text(
                        '${e['publication_status']}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: e['publication_status'] == 'cancelled' ? MosqueColors.expense : MosqueColors.warning,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Icon(
                      e['visibility'] == 'public' ? MoeslimIcons.web : MoeslimIcons.kunci,
                      size: 16,
                      semanticLabel: e['visibility'] == 'public'
                          ? context.tr('Publik', 'Public')
                          : context.tr('Internal', 'Internal'),
                    ),
                  ],
                ),
              ],
            ),
            if (e['registration_enabled'] == true)
              IconButton(
                key: Key('event-registrations-${e['id']}'),
                tooltip: context.tr('Daftar Peserta', 'Participants'),
                icon: const Icon(MoeslimIcons.jamaah, size: 20),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => _EventRegistrationsSheet(ctx: ctx, event: e),
                ),
              ),
            IconButton(
              key: Key('share-event-${e['id']}'),
              tooltip: context.tr('Bagikan Poster & WA', 'Share Poster & WhatsApp'),
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => PosterShareSheet(data: WaTextBuilder.forEvent(ctx.name, e, lang: lang)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRegistrationsSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> event;
  const _EventRegistrationsSheet({required this.ctx, required this.event});

  @override
  ConsumerState<_EventRegistrationsSheet> createState() => _EventRegistrationsSheetState();
}

class _EventRegistrationsSheetState extends ConsumerState<_EventRegistrationsSheet> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ref.read(masjidApiProvider).mosqueEventRegistrations(
            widget.ctx.id,
            (widget.event['id'] as num).toInt(),
          );
      if (mounted) setState(() => _data = res);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(String regId, String status) async {
    try {
      await ref.read(masjidApiProvider).updateMosqueEventRegistration(
            widget.ctx.id,
            (widget.event['id'] as num).toInt(),
            regId,
            status,
          );
      await _load();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
        final t = Theme.of(context).textTheme;
        final list = [
          for (final r in (_data?['data'] as List? ?? const []))
            if (r is Map) Map<String, dynamic>.from(r),
        ];
        final ev = _data?['event'] is Map ? Map<String, dynamic>.from(_data!['event'] as Map) : widget.event;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            height: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${ev['title'] ?? ''}', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Terkonfirmasi: ${ev['confirmed_count'] ?? 0}${ev['capacity'] != null ? ' / ${ev['capacity']}' : ''} · Daftar tunggu: ${ev['waitlisted_count'] ?? 0}',
                    'Confirmed: ${ev['confirmed_count'] ?? 0}${ev['capacity'] != null ? ' / ${ev['capacity']}' : ''} · Waitlisted: ${ev['waitlisted_count'] ?? 0}',
                  ),
                  style: t.bodySmall,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!))
                          : list.isEmpty
                              ? Center(child: Text(context.tr('Belum ada peserta terdaftar.', 'No registered participants yet.')))
                              : ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (_, i) {
                                    final r = list[i];
                                    final st = '${r['status'] ?? 'confirmed'}';
                                    return Card(
                                      child: ListTile(
                                        title: Text('${r['participant_name'] ?? (r['user'] is Map ? (r['user'] as Map)['name'] : '-') ?? '-'}'),
                                        subtitle: Text(
                                          [
                                            st,
                                            if (r['contact_phone'] != null) '${r['contact_phone']}',
                                            if (r['notes'] != null) '${r['notes']}',
                                          ].join(' · '),
                                        ),
                                        trailing: widget.ctx.can('events.write')
                                            ? PopupMenuButton<String>(
                                                onSelected: (s) => _setStatus('${r['id']}', s),
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(value: 'confirmed', child: Text(context.tr('Konfirmasi', 'Confirm'))),
                                                  PopupMenuItem(value: 'waitlisted', child: Text(context.tr('Daftar Tunggu', 'Waitlist'))),
                                                  PopupMenuItem(value: 'cancelled', child: Text(context.tr('Batalkan', 'Cancel'))),
                                                ],
                                              )
                                            : StatusBadge(st),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        );
      });
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
  final _hijriYear = TextEditingController(text: '1447');
  final _capacity = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 30);
  String _category = 'kajian';
  String _publicationStatus = 'published';
  String? _learningPath;
  bool _public = true;
  bool _display = true;
  bool _registrationEnabled = false;
  bool _waitlistEnabled = false;
  bool _busy = false;
  String? _error;

  static const _learningPaths = {
    'bahasa_arab': 'Bahasa Arab',
    'quran_tajwid': "Al-Qur'an & Tajwid",
    'fikih_ibadah': 'Fikih Ibadah',
    'hadis_tafsir': 'Hadis & Tafsir',
    'sejarah_islam': 'Sejarah Islam',
    'akhlak_adab': 'Akhlak & Adab',
  };

  @override
  void dispose() {
    _title.dispose();
    _speaker.dispose();
    _location.dispose();
    _desc.dispose();
    _hijriYear.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    try {
      final start = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
      final parsedCap = int.tryParse(_capacity.text.trim());
      final parsedHijri = int.tryParse(_hijriYear.text.trim());
      await ref.read(masjidApiProvider).createEvent(widget.ctx.id, {
        'title': _title.text.trim(),
        'speaker': opt(_speaker),
        'location': opt(_location),
        'description': opt(_desc),
        'category': _category,
        'starts_at': start.toUtc().toIso8601String(),
        'visibility': _public ? 'public' : 'internal',
        'show_on_display': _public && _display,
        'publication_status': _publicationStatus,
        if (_category == 'ramadan' && parsedHijri != null) 'hijri_year': parsedHijri,
        if (_category == 'pendidikan' && _learningPath != null) 'learning_path': _learningPath,
        'registration_enabled': _registrationEnabled,
        if (_registrationEnabled && parsedCap != null && parsedCap > 0) 'capacity': parsedCap,
        if (_registrationEnabled) 'waitlist_enabled': _waitlistEnabled,
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
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Tambah Kegiatan', 'Add Event')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('event-title'),
            controller: _title,
            decoration: InputDecoration(
              labelText: context.tr('Nama kegiatan *', 'Event title *'),
              prefixIcon: const Icon(MoeslimIcons.kegiatan),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(
              labelText: context.tr('Kategori', 'Category'),
              prefixIcon: const Icon(MoeslimIcons.kategori),
            ),
            items: [
              for (final c in eventCategories.entries)
                DropdownMenuItem(value: c.key, child: Text(categoryLabel(c.key, lang: lang))),
            ],
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
                    decoration: InputDecoration(
                      labelText: context.tr('Tanggal', 'Date'),
                      prefixIcon: const Icon(MoeslimIcons.kalender),
                    ),
                    child: Text(context.shortDateText(_date)),
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
                    decoration: InputDecoration(
                      labelText: context.tr('Jam', 'Time'),
                      prefixIcon: const Icon(MoeslimIcons.jam),
                    ),
                    child: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: InputDecoration(
              labelText: context.tr('Lokasi', 'Location'),
              hintText: context.tr('Contoh: Aula Masjid', 'Example: Main Hall'),
              prefixIcon: const Icon(MoeslimIcons.lokasi),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _speaker,
            decoration: InputDecoration(
              labelText: context.tr('Pemateri / penanggung jawab', 'Speaker / person in charge'),
              prefixIcon: const Icon(MoeslimIcons.profil),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: InputDecoration(labelText: context.tr('Deskripsi', 'Description'), alignLabelWithHint: true),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('Publik (tampil untuk jamaah)', 'Public (visible to congregation)')),
            value: _public,
            onChanged: (v) => setState(() => _public = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('Tayangkan di TV Display', 'Show on TV Display')),
            value: _public && _display,
            onChanged: _public ? (v) => setState(() => _display = v) : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _publicationStatus,
            decoration: InputDecoration(
              labelText: context.tr('Status Publikasi', 'Publication Status'),
              prefixIcon: const Icon(MoeslimIcons.info),
            ),
            items: [
              DropdownMenuItem(value: 'published', child: Text(context.tr('Terpublikasi', 'Published'))),
              DropdownMenuItem(value: 'draft', child: Text(context.tr('Draft (Belum tampil di jamaah)', 'Draft (Hidden from public)'))),
            ],
            onChanged: (v) => setState(() => _publicationStatus = v ?? 'published'),
          ),
          if (_category == 'ramadan') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _hijriYear,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('Tahun Hijriah Ramadan', 'Ramadan Hijri Year'),
                prefixIcon: const Icon(MoeslimIcons.bulan),
              ),
            ),
          ],
          if (_category == 'pendidikan') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _learningPath,
              decoration: InputDecoration(
                labelText: context.tr('Tautkan ke Jalur Belajar (opsional)', 'Link to Learning Path (optional)'),
                prefixIcon: const Icon(MoeslimIcons.buku),
              ),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(context.tr('Umum / Tidak ditautkan', 'General / Unlinked'))),
                for (final lp in _learningPaths.entries) DropdownMenuItem<String?>(value: lp.key, child: Text(lp.value)),
              ],
              onChanged: (v) => setState(() => _learningPath = v),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('Buka Pendaftaran Jamaah', 'Enable Congregation Registration')),
            subtitle: Text(context.tr('Untuk kajian berkuota, buka bersama, atau kelas masjid', 'For capped lectures, iftar, or mosque classes')),
            value: _registrationEnabled,
            onChanged: (v) => setState(() => _registrationEnabled = v),
          ),
          if (_registrationEnabled) ...[
            TextField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('Kuota peserta (kosongkan jika tanpa batas)', 'Participant capacity (blank for unlimited)'),
                prefixIcon: const Icon(MoeslimIcons.jamaah),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Aktifkan Daftar Tunggu (Waitlist)', 'Enable Waitlist')),
              value: _waitlistEnabled,
              onChanged: (v) => setState(() => _waitlistEnabled = v),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          FilledButton.icon(
            key: const Key('save-event'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
            onPressed: _busy ? null : _save,
            icon: const Icon(MoeslimIcons.check),
            label: Text(context.tr('Simpan Kegiatan', 'Save Event')),
          ),
        ],
      ),
    );
  });
}
