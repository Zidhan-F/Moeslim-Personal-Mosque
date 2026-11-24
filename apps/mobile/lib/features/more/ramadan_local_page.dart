import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../ibadah/muhasabah_journal_page.dart';
import '../masjid/masjid_api.dart';
import '../masjid/masjid_home_page.dart';
import '../masjid/mosque_providers.dart';
import '../masjid/session.dart';
import 'followed_mosques_page.dart';

/// Ramadan Local di sisi Personal (RAM-01..RAM-08):
/// - Jadwal Ramadan resmi yang dikelola masjid (tarawih, kajian, buka bersama, i'tikaf).
/// - Cache offline lokal menampilkan waktu sinkron terakhir & waktu pembaruan jadwal.
/// - Menampilkan status publikasi (`published`, `updated`, `cancelled`, `completed`).
/// - Pendaftaran atomik dengan kuota & waitlist, pengingat lokal, serta catatan cepat ke Jurnal privat.
class RamadanLocalPage extends ConsumerStatefulWidget {
  final String? initialMosqueSlug;
  final String? initialMosqueName;

  const RamadanLocalPage({super.key, this.initialMosqueSlug, this.initialMosqueName});

  @override
  ConsumerState<RamadanLocalPage> createState() => _RamadanLocalPageState();
}

class _RamadanLocalPageState extends ConsumerState<RamadanLocalPage> {
  List<FollowedMosque> _followed = const [];
  String? _selectedSlug;
  String? _selectedName;
  int? _hijriYear = 1447;

  List<Map<String, dynamic>> _events = const [];
  DateTime? _syncedAt;
  bool _offline = false;
  bool _loading = true;
  String? _error;

  Set<int> _reminderIds = {};
  Map<int, Map<String, dynamic>> _myRegsByEventId = const {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final followed = await ref.read(favoriteMosqueRepoProvider).all();
    final reminders = await ref.read(communityCacheRepoProvider).savedReminderEventIds();
    String? slug = widget.initialMosqueSlug;
    String? name = widget.initialMosqueName;
    if (slug == null && followed.isNotEmpty) {
      slug = followed.first.slug;
      name = followed.first.name;
    }
    if (!mounted) return;
    setState(() {
      _followed = followed;
      _selectedSlug = slug;
      _selectedName = name;
      _reminderIds = reminders;
    });
    if (slug != null) {
      await _loadEvents(slug);
    } else if (mounted) {
      setState(() => _loading = false);
    }
    await _loadMyRegistrations();
  }

  Future<void> _loadEvents(String slug) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final cacheRepo = ref.read(communityCacheRepoProvider);
    final cached = await cacheRepo.loadRamadanCache(slug);
    if (cached != null && mounted) {
      setState(() {
        _events = _filterByYear(cached.events);
        _syncedAt = cached.syncedAt;
      });
    }
    try {
      final res = await ref.read(masjidApiProvider).publicRamadanEvents(slug, hijriYear: _hijriYear);
      final list = [
        for (final e in (res['data'] as List? ?? const []))
          if (e is Map) Map<String, dynamic>.from(e),
      ];
      final synced = DateTime.tryParse('${res['synced_at'] ?? ''}')?.toUtc() ?? DateTime.now().toUtc();
      await cacheRepo.saveRamadanCache(slug, list, synced);
      if (mounted) {
        setState(() {
          _events = list;
          _syncedAt = synced;
          _offline = false;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _offline = true;
          _loading = false;
          if (cached == null) _error = '$e';
        });
      }
    }
  }

  List<Map<String, dynamic>> _filterByYear(List<Map<String, dynamic>> raw) {
    if (_hijriYear == null) return raw;
    return raw.where((e) => e['hijri_year'] == null || e['hijri_year'] == _hijriYear).toList();
  }

  Future<void> _loadMyRegistrations() async {
    final session = ref.read(sessionProvider).value;
    if (session == null) {
      if (mounted) setState(() => _myRegsByEventId = const {});
      return;
    }
    try {
      final regs = await ref.read(masjidApiProvider).myEventRegistrations();
      final map = <int, Map<String, dynamic>>{};
      for (final r in regs) {
        final eid = (r['event_id'] as num?)?.toInt();
        if (eid != null && r['status'] != 'cancelled') {
          map[eid] = r;
        }
      }
      if (mounted) setState(() => _myRegsByEventId = map);
    } catch (_) {
      // Tetap gunakan tampilan jadwal meski registrasi tidak dapat disegarkan saat offline.
    }
  }

  Future<void> _toggleReminder(int eventId) async {
    final updated = await ref.read(communityCacheRepoProvider).toggleReminderEvent(eventId);
    if (!mounted) return;
    setState(() => _reminderIds = updated);
    final active = updated.contains(eventId);
    showSnack(
      context,
      active
          ? context.tr('Pengingat lokal diaktifkan untuk kegiatan ini.', 'Local reminder enabled for this event.')
          : context.tr('Pengingat lokal dinonaktifkan.', 'Local reminder turned off.'),
    );
  }

  Future<void> _registerEvent(Map<String, dynamic> event) async {
    final session = ref.read(sessionProvider).value;
    if (session == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Masuk akun terlebih dahulu untuk mendaftar kegiatan masjid.',
              'Sign in first to register for mosque events.',
            ),
          ),
          action: SnackBarAction(
            label: context.tr('Masuk', 'Sign In'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MasjidHomePage())),
          ),
        ),
      );
      return;
    }

    final nameCtrl = TextEditingController(text: '${session.user['name'] ?? ''}');
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Daftar Kegiatan Ramadan', 'Register Ramadan Event')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${event['title']}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: context.tr('Nama peserta', 'Participant name')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: context.tr('No. kontak (opsional)', 'Contact phone (optional)')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(labelText: context.tr('Catatan (opsional)', 'Notes (optional)')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('Batal', 'Cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr('Daftar', 'Register'))),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final eventId = (event['id'] as num).toInt();
      final reg = await ref.read(masjidApiProvider).registerEvent(
            eventId,
            participantName: nameCtrl.text.trim(),
            contactPhone: phoneCtrl.text.trim(),
            notes: notesCtrl.text.trim(),
          );
      await _loadMyRegistrations();
      if (_selectedSlug != null) await _loadEvents(_selectedSlug!);
      if (!mounted) return;
      final st = reg['status'] as String? ?? 'confirmed';
      showSnack(
        context,
        st == 'waitlisted'
            ? context.tr('Kuota penuh. Anda masuk daftar tunggu.', 'Quota is full. You joined the waitlist.')
            : context.tr('Pendaftaran berhasil dikonfirmasi.', 'Registration confirmed.'),
      );
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    }
  }

  Future<void> _cancelRegistration(int eventId) async {
    try {
      await ref.read(masjidApiProvider).cancelEventRegistration(eventId);
      await _loadMyRegistrations();
      if (_selectedSlug != null) await _loadEvents(_selectedSlug!);
      if (mounted) {
        showSnack(context, context.tr('Pendaftaran berhasil dibatalkan.', 'Registration cancelled.'));
      }
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    }
  }

  (String, Color) _pubBadge(BuildContext context, String status) => switch (status) {
        'updated' => (context.tr('Jadwal Diperbarui', 'Schedule Updated'), MosqueColors.warning),
        'cancelled' => (context.tr('Dibatalkan', 'Cancelled'), MosqueColors.expense),
        'completed' => (context.tr('Selesai', 'Completed'), MosqueColors.info),
        _ => (context.tr('Terpublikasi', 'Published'), MosqueColors.income),
      };

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
        final t = Theme.of(context).textTheme;
        final scheme = Theme.of(context).colorScheme;
        final choices = <FollowedMosque>[
          ..._followed,
          if (_selectedSlug != null && !_followed.any((m) => m.slug == _selectedSlug))
            FollowedMosque(slug: _selectedSlug!, name: _selectedName ?? _selectedSlug!),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('Ramadan Masjid Lokal', 'Local Mosque Ramadan')),
            centerTitle: true,
            actions: [
              if (_selectedSlug != null)
                IconButton(
                  tooltip: context.tr('Segarkan jadwal', 'Refresh schedule'),
                  icon: const Icon(MoeslimIcons.refresh),
                  onPressed: () => _loadEvents(_selectedSlug!),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (_selectedSlug != null) await _loadEvents(_selectedSlug!);
              await _loadMyRegistrations();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                PatternBanner(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('Jadwal Resmi Ramadan Masjid', 'Official Mosque Ramadan Schedule'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          'Tarawih, kajian, buka bersama, dan i\'tikaf dikelola resmi oleh pengurus masjid dengan cache offline.',
                          'Tarawih, lectures, iftar, and i\'tikaf managed officially by the mosque committee with offline cache.',
                        ),
                        style: const TextStyle(color: BrandColors.cream, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (choices.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.tr('Belum ada masjid yang diikuti', 'No followed mosque yet'),
                            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr(
                              'Ikuti masjid sekitar Anda terlebih dahulu untuk melihat jadwal Ramadan lokalnya secara offline.',
                              'Follow a mosque near you first to browse its local Ramadan schedule offline.',
                            ),
                            style: t.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const FollowedMosquesPage()),
                              );
                              await _init();
                            },
                            icon: const Icon(MoeslimIcons.pencarian),
                            label: Text(context.tr('Cari & Ikuti Masjid', 'Search & Follow Mosque')),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    key: const Key('ramadan-mosque-dropdown'),
                    initialValue: _selectedSlug,
                    decoration: InputDecoration(
                      labelText: context.tr('Pilih Masjid', 'Select Mosque'),
                      prefixIcon: const Icon(MoeslimIcons.masjid),
                    ),
                    items: [
                      for (final m in choices) DropdownMenuItem(value: m.slug, child: Text(m.name)),
                    ],
                    onChanged: (slug) {
                      if (slug == null) return;
                      final match = choices.firstWhere((m) => m.slug == slug);
                      setState(() {
                        _selectedSlug = slug;
                        _selectedName = match.name;
                      });
                      _loadEvents(slug);
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final y in <int?>[1447, 1448, 1446, null])
                        ChoiceChip(
                          label: Text(y == null ? context.tr('Semua Tahun', 'All Years') : '$y H'),
                          selected: _hijriYear == y,
                          onSelected: (_) {
                            setState(() => _hijriYear = y);
                            if (_selectedSlug != null) _loadEvents(_selectedSlug!);
                          },
                        ),
                    ],
                  ),
                  if (_syncedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _offline ? MoeslimIcons.peringatan : MoeslimIcons.check,
                          size: 16,
                          color: _offline ? MosqueColors.warning : MosqueColors.income,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr(
                              '${_offline ? 'Cache offline · ' : ''}Terakhir sinkron: ${context.shortDateText(_syncedAt!.toLocal())} ${hhmm(_syncedAt!.toLocal())}',
                              '${_offline ? 'Offline cache · ' : ''}Last synced: ${context.shortDateText(_syncedAt!.toLocal())} ${hhmm(_syncedAt!.toLocal())}',
                            ),
                            key: const Key('ramadan-sync-timestamp'),
                            style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (_loading && _events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null && _events.isEmpty)
                    BrandEmptyState(
                      art: BrandEmptyArt.tanpaInternet,
                      title: context.tr('Jadwal belum dapat dimuat', 'Unable to load schedule'),
                      message: _error!,
                      action: TextButton.icon(
                        onPressed: () => _loadEvents(_selectedSlug!),
                        icon: const Icon(MoeslimIcons.refresh),
                        label: Text(context.tr('Coba lagi', 'Try again')),
                      ),
                    )
                  else if (_events.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          context.tr(
                            'Belum ada kegiatan Ramadan terpublikasi untuk filter tahun ini dari ${_selectedName ?? _selectedSlug}.',
                            'No published Ramadan activities for this year from ${_selectedName ?? _selectedSlug}.',
                          ),
                        ),
                      ),
                    )
                  else
                    for (final e in _events) _buildEventCard(context, e),
                ],
              ],
            ),
          ),
        );
      });

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> e) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final id = (e['id'] as num?)?.toInt() ?? 0;
    final status = (e['publication_status'] as String?) ?? 'published';
    final badge = _pubBadge(context, status);
    final start = DateTime.tryParse('${e['starts_at'] ?? ''}')?.toLocal();
    final updatedAt = DateTime.tryParse('${e['updated_at'] ?? ''}')?.toLocal();
    final regEnabled = e['registration_enabled'] == true;
    final waitlistEnabled = e['waitlist_enabled'] == true;
    final capacity = (e['capacity'] as num?)?.toInt();
    final remaining = (e['remaining_seats'] as num?)?.toInt();
    final myReg = _myRegsByEventId[id];
    final hasReminder = _reminderIds.contains(id);
    final canRegister = regEnabled && (status == 'published' || status == 'updated');

    return Card(
      key: Key('ramadan-event-$id'),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${e['title'] ?? ''}',
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(badge.$1, color: badge.$2),
              ],
            ),
            const SizedBox(height: 6),
            if (start != null)
              Text(
                '${context.shortDateText(start)} · ${hhmm(start)}${e['location'] != null ? ' · ${e['location']}' : ''}',
                style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
              ),
            if (e['speaker'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  context.tr('Pemateri / Imam: ${e['speaker']}', 'Speaker / Imam: ${e['speaker']}'),
                  style: t.bodySmall,
                ),
              ),
            if (e['description'] != null && '${e['description']}'.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${e['description']}', style: t.bodyMedium),
              ),
            if (capacity != null) ...[
              const SizedBox(height: 6),
              Text(
                context.tr(
                  'Sisa kuota: ${remaining ?? 0} / $capacity${waitlistEnabled && (remaining ?? 0) == 0 ? ' (Daftar tunggu tersedia)' : ''}',
                  'Remaining seats: ${remaining ?? 0} / $capacity${waitlistEnabled && (remaining ?? 0) == 0 ? ' (Waitlist open)' : ''}',
                ),
                style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            if (updatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  context.tr(
                    'Diperbarui masjid: ${context.shortDateText(updatedAt)} ${hhmm(updatedAt)}',
                    'Updated by mosque: ${context.shortDateText(updatedAt)} ${hhmm(updatedAt)}',
                  ),
                  style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            if (myReg != null) ...[
              const SizedBox(height: 8),
              StatusBadge(
                myReg['status'] == 'waitlisted'
                    ? context.tr('Status Anda: Daftar Tunggu', 'Your Status: Waitlisted')
                    : context.tr('Status Anda: Terdaftar', 'Your Status: Confirmed'),
                color: myReg['status'] == 'waitlisted' ? MosqueColors.warning : MosqueColors.income,
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (canRegister && myReg == null)
                  FilledButton(
                    key: Key('ramadan-register-$id'),
                    onPressed: () => _registerEvent(e),
                    child: Text(
                      capacity != null && (remaining ?? 0) == 0 && waitlistEnabled
                          ? context.tr('Masuk Daftar Tunggu', 'Join Waitlist')
                          : context.tr('Daftar', 'Register'),
                    ),
                  ),
                if (myReg != null)
                  OutlinedButton(
                    key: Key('ramadan-cancel-reg-$id'),
                    onPressed: () => _cancelRegistration(id),
                    child: Text(context.tr('Batalkan Pendaftaran', 'Cancel Registration')),
                  ),
                FilterChip(
                  key: Key('ramadan-reminder-$id'),
                  selected: hasReminder,
                  avatar: Icon(
                    hasReminder ? Icons.notifications_active_outlined : Icons.notifications_none_outlined,
                    size: 16,
                  ),
                  label: Text(context.tr('Pengingat Lokal', 'Local Reminder')),
                  onSelected: (_) => _toggleReminder(id),
                ),
                OutlinedButton.icon(
                  key: Key('ramadan-journal-$id'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MuhasabahJournalPage(
                        initialKind: JournalEntryKind.kajian,
                        initialTitle: '${e['title'] ?? ''}',
                        initialSourceRef: '${e['title'] ?? ''} (${_selectedName ?? _selectedSlug ?? ''})',
                      ),
                    ),
                  ),
                  icon: const Icon(MoeslimIcons.edit, size: 16),
                  label: Text(context.tr('Catatan Jurnal Privat', 'Private Journal Note')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
