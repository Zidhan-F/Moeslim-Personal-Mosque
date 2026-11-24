import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../masjid/masjid_api.dart';
import '../masjid/masjid_home_page.dart';
import '../masjid/mosque_providers.dart';
import '../masjid/session.dart';
import '../more/followed_mosques_page.dart';

/// Moeslim Services sisi Personal (SVC-01..SVC-06):
/// - Katalog layanan aktif dari masjid yang diikuti (TPQ, kegiatan, aspirasi, fasilitas, konsultasi, sosial).
/// - Menampilkan privacy notice jelas sebelum permohonan dikirim.
/// - Mendukung penyimpanan Draft Lokal saat offline (ditandai tegas sebagai belum terkirim).
/// - Pengiriman daring memakai `Idempotency-Key` anti-duplikasi.
/// - Pelacakan status, riwayat progres, kirim revisi saat `need_revision`, dan pembatalan oleh pemohon.
class PersonalServicesPage extends ConsumerStatefulWidget {
  final String? initialMosqueSlug;
  final String? initialMosqueName;
  final int initialTab;

  const PersonalServicesPage({
    super.key,
    this.initialMosqueSlug,
    this.initialMosqueName,
    this.initialTab = 0,
  });

  static String serviceTypeLabel(BuildContext context, String type) => switch (type) {
        'tpq' => context.tr('Pendaftaran TPQ / Kelas', 'TPQ / Class Enrollment'),
        'kegiatan' => context.tr('Pendaftaran Kegiatan', 'Event Registration'),
        'aspirasi' => context.tr('Aspirasi & Masukan', 'Feedback & Suggestions'),
        'fasilitas' => context.tr('Peminjaman Fasilitas', 'Facility Booking'),
        'konsultasi' => context.tr('Konsultasi Pengurus', 'Committee Consultation'),
        'sosial' => context.tr('Program Sosial', 'Social Program'),
        'ramadan' => context.tr('Program Ramadan', 'Ramadan Program'),
        _ => context.tr('Layanan Umum', 'General Service'),
      };

  static (String, Color) requestStatusBadge(BuildContext context, String status) => switch (status) {
        'submitted' => (context.tr('Terkirim', 'Submitted'), MosqueColors.info),
        'under_review' => (context.tr('Ditinjau', 'Under Review'), MosqueColors.info),
        'need_revision' => (context.tr('Perlu Revisi', 'Needs Revision'), MosqueColors.warning),
        'resubmitted' => (context.tr('Revisi Terkirim', 'Resubmitted'), MosqueColors.info),
        'approved' => (context.tr('Disetujui', 'Approved'), MosqueColors.income),
        'rejected' => (context.tr('Ditolak', 'Rejected'), MosqueColors.expense),
        'completed' => (context.tr('Selesai', 'Completed'), MosqueColors.income),
        'closed' => (context.tr('Ditutup', 'Closed'), BrandColors.emerald),
        'cancelled' => (context.tr('Dibatalkan', 'Cancelled'), MosqueColors.expense),
        _ => (status, MosqueColors.info),
      };

  @override
  ConsumerState<PersonalServicesPage> createState() => _PersonalServicesPageState();
}

class _PersonalServicesPageState extends ConsumerState<PersonalServicesPage> {
  late int _tab = widget.initialTab.clamp(0, 1);
  List<FollowedMosque> _followed = const [];
  String? _selectedSlug;
  String? _selectedName;

  List<Map<String, dynamic>> _catalog = const [];
  bool _loadingCatalog = true;
  String? _catalogError;

  List<ServiceRequestDraft> _drafts = const [];
  List<Map<String, dynamic>> _requests = const [];
  bool _loadingRequests = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final followed = await ref.read(favoriteMosqueRepoProvider).all();
    final drafts = await ref.read(communityCacheRepoProvider).loadServiceDrafts();
    String? slug = widget.initialMosqueSlug;
    String? name = widget.initialMosqueName;
    if (slug == null && followed.isNotEmpty) {
      slug = followed.first.slug;
      name = followed.first.name;
    }
    if (!mounted) return;
    setState(() {
      _followed = followed;
      _drafts = drafts;
      _selectedSlug = slug;
      _selectedName = name;
    });
    if (slug != null) {
      await _loadCatalog(slug);
    } else if (mounted) {
      setState(() => _loadingCatalog = false);
    }
    await _loadRequests();
  }

  Future<void> _loadCatalog(String slug) async {
    setState(() {
      _loadingCatalog = true;
      _catalogError = null;
    });
    try {
      final res = await ref.read(masjidApiProvider).publicMosqueServices(slug);
      final list = [
        for (final s in (res['data'] as List? ?? const []))
          if (s is Map) Map<String, dynamic>.from(s),
      ];
      if (mounted) {
        setState(() {
          _catalog = list;
          _loadingCatalog = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _catalogError = '$e';
          _loadingCatalog = false;
        });
      }
    }
  }

  Future<void> _loadRequests() async {
    final drafts = await ref.read(communityCacheRepoProvider).loadServiceDrafts();
    if (mounted) setState(() => _drafts = drafts);
    if (ref.read(sessionProvider).value == null) {
      if (mounted) setState(() => _requests = const []);
      return;
    }
    setState(() => _loadingRequests = true);
    try {
      final list = await ref.read(masjidApiProvider).myServiceRequests();
      if (mounted) {
        setState(() {
          _requests = list;
          _loadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRequests = false);
    }
  }

  Future<void> _openServiceForm(Map<String, dynamic> def, {ServiceRequestDraft? draft}) async {
    final slug = draft?.mosqueSlug ?? _selectedSlug;
    final mosqueName = draft?.mosqueName ?? _selectedName ?? slug ?? '';
    if (slug == null) return;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ServiceFormSheet(
        slug: slug,
        mosqueName: mosqueName,
        definition: def,
        draft: draft,
      ),
    );
    await _loadRequests();
    if (result == 'submitted') {
      setState(() => _tab = 1);
      if (_selectedSlug != null) await _loadCatalog(_selectedSlug!);
    } else if (result == 'draft') {
      setState(() => _tab = 1);
    }
  }

  Future<void> _resumeDraft(ServiceRequestDraft draft) async {
    Map<String, dynamic>? def = _catalog.where((d) => '${d['id']}' == draft.definitionId).firstOrNull;
    if (def == null) {
      try {
        final res = await ref.read(masjidApiProvider).publicMosqueServices(draft.mosqueSlug);
        final list = [
          for (final s in (res['data'] as List? ?? const []))
            if (s is Map) Map<String, dynamic>.from(s),
        ];
        def = list.where((d) => '${d['id']}' == draft.definitionId).firstOrNull;
      } catch (_) {
        // Fallback skema dari kunci jawaban draft agar tetap bisa disunting saat offline.
      }
    }
    if (!mounted) return;
    def ??= {
      'id': draft.definitionId,
      'title': draft.serviceTitle,
      'type': 'kegiatan',
      'description': '',
      'privacy_notice': context.tr(
        'Data permohonan akan dikirimkan ke pengurus masjid terkait saat Anda menekan Kirim Permohonan.',
        'Application data will be sent to the respective mosque committee when you tap Submit Request.',
      ),
      'fields': [
        for (final k in draft.answers.keys) {'key': k, 'label': k, 'type': 'text', 'required': false},
      ],
    };
    await _openServiceForm(def, draft: draft);
  }

  Future<void> _openResubmit(Map<String, dynamic> req) async {
    final defMap = req['definition'] is Map ? Map<String, dynamic>.from(req['definition'] as Map) : <String, dynamic>{};
    final existingAnswers = req['answers'] is Map
        ? (req['answers'] as Map).map((k, v) => MapEntry('$k', '$v'))
        : <String, String>{};
    final fields = (defMap['fields'] as List? ?? const [])
        .whereType<Map>()
        .map((f) => Map<String, dynamic>.from(f))
        .toList();
    final controllers = <String, TextEditingController>{
      for (final f in fields) '${f['key']}': TextEditingController(text: existingAnswers['${f['key']}'] ?? ''),
    };
    if (controllers.isEmpty) {
      for (final e in existingAnswers.entries) {
        controllers[e.key] = TextEditingController(text: e.value);
      }
    }
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Kirim Ulang Revisi', 'Submit Revision')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in controllers.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: fields.where((f) => '${f['key']}' == entry.key).firstOrNull?['label'] as String? ??
                          entry.key,
                    ),
                  ),
                ),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('Catatan perbaikan untuk pengurus', 'Revision note for committee'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('Batal', 'Cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr('Kirim Revisi', 'Resubmit'))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final answers = {for (final e in controllers.entries) e.key: e.value.text.trim()};
      await ref.read(masjidApiProvider).resubmitServiceRequest(
            '${req['id']}',
            answers,
            message: noteCtrl.text.trim(),
          );
      await _loadRequests();
      if (mounted) showSnack(context, context.tr('Revisi berhasil dikirim.', 'Revision submitted.'));
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await ref.read(masjidApiProvider).cancelServiceRequest(requestId);
      await _loadRequests();
      if (mounted) showSnack(context, context.tr('Permohonan dibatalkan.', 'Request cancelled.'));
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('Layanan Masjid', 'Mosque Services')),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: PillTabs(
                  labels: [
                    context.tr('Katalog Layanan', 'Service Catalog'),
                    context.tr(
                      'Permohonan & Draft (${_drafts.length + _requests.length})',
                      'Requests & Drafts (${_drafts.length + _requests.length})',
                    ),
                  ],
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
              Expanded(
                child: _tab == 0 ? _buildCatalogTab(context) : _buildRequestsTab(context),
              ),
            ],
          ),
        );
      });

  Widget _buildCatalogTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final choices = <FollowedMosque>[
      ..._followed,
      if (_selectedSlug != null && !_followed.any((m) => m.slug == _selectedSlug))
        FollowedMosque(slug: _selectedSlug!, name: _selectedName ?? _selectedSlug!),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedSlug != null) await _loadCatalog(_selectedSlug!);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          PatternBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Moeslim Services', 'Moeslim Services'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Ajukan pendaftaran TPQ, kegiatan, peminjaman fasilitas, atau aspirasi jamaah langsung ke pengurus masjid.',
                    'Submit TPQ enrollment, event registration, facility bookings, or feedback directly to the mosque committee.',
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
                      context.tr('Pilih masjid terlebih dahulu', 'Follow a mosque first'),
                      style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(
                        'Ikuti masjid yang ingin Anda akses layanannya.',
                        'Follow a mosque to browse its active community services.',
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
              key: const Key('svc-mosque-dropdown'),
              initialValue: _selectedSlug,
              decoration: InputDecoration(
                labelText: context.tr('Masjid Tujuan', 'Target Mosque'),
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
                _loadCatalog(slug);
              },
            ),
            const SizedBox(height: 12),
            if (_loadingCatalog)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_catalogError != null)
              BrandEmptyState(
                art: BrandEmptyArt.tanpaInternet,
                title: context.tr('Layanan belum dapat dimuat', 'Unable to load services'),
                message: _catalogError!,
                action: TextButton.icon(
                  onPressed: () => _loadCatalog(_selectedSlug!),
                  icon: const Icon(MoeslimIcons.refresh),
                  label: Text(context.tr('Coba lagi', 'Try again')),
                ),
              )
            else if (_catalog.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.tr(
                      'Masjid ini belum mengaktifkan layanan daring.',
                      'This mosque has not enabled online services yet.',
                    ),
                  ),
                ),
              )
            else
              for (final s in _catalog)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${s['title']}', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            ),
                            StatusBadge(PersonalServicesPage.serviceTypeLabel(context, '${s['type'] ?? 'kegiatan'}')),
                          ],
                        ),
                        if (s['description'] != null && '${s['description']}'.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('${s['description']}', style: t.bodyMedium),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (s['capacity'] != null)
                              Text(
                                context.tr(
                                  'Sisa kuota: ${s['remaining_capacity'] ?? 0} / ${s['capacity']}',
                                  'Remaining slots: ${s['remaining_capacity'] ?? 0} / ${s['capacity']}',
                                ),
                                style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            Text(
                              context.tr(
                                'Retensi data: ${s['retention_days'] ?? 365} hari',
                                'Data retention: ${s['retention_days'] ?? 365} days',
                              ),
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          key: Key('svc-open-${s['id']}'),
                          onPressed: () => _openServiceForm(s),
                          icon: const Icon(MoeslimIcons.edit, size: 18),
                          label: Text(context.tr('Ajukan Permohonan', 'Apply / Submit')),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestsTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final loggedIn = ref.watch(sessionProvider).value != null;

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (_drafts.isNotEmpty) ...[
            SectionHeader(context.tr('Draft Lokal (Belum Terkirim)', 'Local Drafts (Not Sent)')),
            for (final d in _drafts)
              Card(
                key: Key('svc-draft-${d.id}'),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(d.serviceTitle, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                          StatusBadge(
                            context.tr('Draft Lokal, Belum Terkirim', 'Local Draft, Not Sent'),
                            key: const Key('svc-draft-badge'),
                            color: MosqueColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.mosqueName} · ${context.shortDateText(d.updatedAt.toLocal())} ${hhmm(d.updatedAt.toLocal())}',
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () => _resumeDraft(d),
                            child: Text(context.tr('Lanjutkan / Kirim', 'Continue / Submit')),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              await ref.read(communityCacheRepoProvider).deleteServiceDraft(d.id);
                              await _loadRequests();
                            },
                            child: Text(context.tr('Hapus Draft', 'Delete Draft')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
          SectionHeader(context.tr('Permohonan Terkirim', 'Submitted Requests')),
          if (!loggedIn)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr(
                        'Masuk akun untuk mengirim permohonan dan melacak status pemrosesan dari pengurus masjid.',
                        'Sign in to submit requests and track status updates from the mosque committee.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MasjidHomePage()));
                        await _loadRequests();
                      },
                      child: Text(context.tr('Masuk Akun', 'Sign In')),
                    ),
                  ],
                ),
              ),
            )
          else if (_loadingRequests && _requests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_requests.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.tr(
                    'Belum ada permohonan layanan yang dikirim.',
                    'No service requests submitted yet.',
                  ),
                ),
              ),
            )
          else
            for (final r in _requests) _buildRequestCard(context, r),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> r) {
    final t = Theme.of(context).textTheme;
    final status = '${r['status'] ?? 'submitted'}';
    final badge = PersonalServicesPage.requestStatusBadge(context, status);
    final def = r['definition'] is Map ? Map<String, dynamic>.from(r['definition'] as Map) : const <String, dynamic>{};
    final mosque = def['mosque'] is Map ? Map<String, dynamic>.from(def['mosque'] as Map) : const <String, dynamic>{};
    final history = [
      for (final h in (r['history'] as List? ?? const []))
        if (h is Map) Map<String, dynamic>.from(h),
    ];

    return Card(
      key: Key('svc-req-${r['id']}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${def['title'] ?? context.tr('Layanan', 'Service')}',
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                StatusBadge(badge.$1, color: badge.$2),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${r['reference_no'] ?? r['id']}${mosque['name'] != null ? ' · ${mosque['name']}' : ''}',
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final h in history.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${PersonalServicesPage.requestStatusBadge(context, '${h['status']}').$1}${h['message'] != null ? ': ${h['message']}' : ''}',
                    style: t.bodySmall,
                  ),
                ),
            ],
            if (status == 'need_revision' || status == 'submitted') ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (status == 'need_revision')
                    FilledButton(
                      onPressed: () => _openResubmit(r),
                      child: Text(context.tr('Kirim Revisi', 'Submit Revision')),
                    ),
                  OutlinedButton(
                    onPressed: () => _cancelRequest('${r['id']}'),
                    child: Text(context.tr('Batalkan', 'Cancel')),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServiceFormSheet extends ConsumerStatefulWidget {
  final String slug;
  final String mosqueName;
  final Map<String, dynamic> definition;
  final ServiceRequestDraft? draft;

  const _ServiceFormSheet({
    required this.slug,
    required this.mosqueName,
    required this.definition,
    this.draft,
  });

  @override
  ConsumerState<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  late final List<Map<String, dynamic>> _fields;
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String?> _selectValues;
  late final String _idempotencyKey;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = widget.draft?.idempotencyKey ?? FamilySpaceRepository.newUuidV4();
    _fields = [
      for (final f in (widget.definition['fields'] as List? ?? const []))
        if (f is Map) Map<String, dynamic>.from(f),
    ];
    _controllers = {};
    _selectValues = {};
    for (final f in _fields) {
      final key = '${f['key']}';
      final initial = widget.draft?.answers[key] ?? '';
      if (f['type'] == 'select') {
        final opts = (f['options'] as List? ?? const []).map((e) => '$e').toList();
        _selectValues[key] = opts.contains(initial) ? initial : (opts.isNotEmpty ? opts.first : null);
      } else {
        _controllers[key] = TextEditingController(text: initial);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _collectAnswers() {
    final map = <String, String>{};
    for (final f in _fields) {
      final key = '${f['key']}';
      if (f['type'] == 'select') {
        if (_selectValues[key] != null) map[key] = _selectValues[key]!;
      } else {
        map[key] = _controllers[key]?.text.trim() ?? '';
      }
    }
    return map;
  }

  Future<void> _saveDraft() async {
    final draft = ServiceRequestDraft(
      id: widget.draft?.id ?? FamilySpaceRepository.newUuidV4(),
      mosqueSlug: widget.slug,
      mosqueName: widget.mosqueName,
      definitionId: '${widget.definition['id']}',
      serviceTitle: '${widget.definition['title']}',
      idempotencyKey: _idempotencyKey,
      answers: _collectAnswers(),
      updatedAt: DateTime.now().toUtc(),
    );
    await ref.read(communityCacheRepoProvider).saveServiceDraft(draft);
    if (!mounted) return;
    showSnack(
      context,
      context.tr(
        'Tersimpan sebagai Draft Lokal (belum terkirim ke masjid).',
        'Saved as Local Draft (not yet sent to the mosque).',
      ),
    );
    Navigator.pop(context, 'draft');
  }

  Future<void> _submit() async {
    if (ref.read(sessionProvider).value == null) {
      setState(() {
        _error = context.tr(
          'Masuk akun terlebih dahulu untuk mengirim permohonan. Anda tetap dapat menyimpannya sebagai Draft Lokal.',
          'Sign in first to submit online. You can still save it as a Local Draft.',
        );
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(masjidApiProvider).submitServiceRequest(
            widget.slug,
            definitionId: '${widget.definition['id']}',
            answers: _collectAnswers(),
            idempotencyKey: _idempotencyKey,
          );
      if (widget.draft != null) {
        await ref.read(communityCacheRepoProvider).deleteServiceDraft(widget.draft!.id);
      }
      if (!mounted) return;
      showSnack(context, context.tr('Permohonan berhasil dikirim ke masjid.', 'Request submitted to the mosque.'));
      Navigator.pop(context, 'submitted');
    } on ApiException catch (e) {
      setState(() {
        _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
        final t = Theme.of(context).textTheme;
        final scheme = Theme.of(context).colorScheme;
        final bottom = MediaQuery.viewInsetsOf(context).bottom;
        final notice = '${widget.definition['privacy_notice'] ?? ''}'.trim();

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.definition['title']}', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Text(widget.mosqueName, style: t.bodySmall),
                const SizedBox(height: 12),
                Card(
                  key: const Key('svc-privacy-notice'),
                  color: scheme.secondaryContainer.withValues(alpha: .55),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(MoeslimIcons.shield, size: 20, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('Pemberitahuan Privasi Data', 'Data Privacy Notice'),
                                style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                notice.isNotEmpty
                                    ? notice
                                    : context.tr(
                                        'Data formulir ini akan dikirimkan langsung kepada pengurus masjid terkait untuk memproses permohonan Anda.',
                                        'This form data will be sent directly to the respective mosque committee to process your request.',
                                      ),
                                style: t.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final f in _fields) ...[
                  _buildField(context, f),
                  const SizedBox(height: 10),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_error!, style: TextStyle(color: scheme.error)),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('svc-save-draft-btn'),
                        onPressed: _busy ? null : _saveDraft,
                        icon: const Icon(MoeslimIcons.database, size: 18),
                        label: Text(context.tr('Simpan Draft Lokal', 'Save Local Draft')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('svc-submit-btn'),
                        onPressed: _busy ? null : _submit,
                        icon: const Icon(MoeslimIcons.check, size: 18),
                        label: Text(context.tr('Kirim Permohonan', 'Submit Request')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });

  Widget _buildField(BuildContext context, Map<String, dynamic> f) {
    final key = '${f['key']}';
    final label = '${f['label'] ?? key}${f['required'] == true ? ' *' : ''}';
    final type = '${f['type'] ?? 'text'}';
    if (type == 'select') {
      final opts = (f['options'] as List? ?? const []).map((e) => '$e').toList();
      return DropdownButtonFormField<String>(
        key: Key('svc-field-$key'),
        initialValue: _selectValues[key],
        decoration: InputDecoration(labelText: label),
        items: [for (final o in opts) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) => setState(() => _selectValues[key] = v),
      );
    }
    return TextField(
      key: Key('svc-field-$key'),
      controller: _controllers[key],
      keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
      maxLines: type == 'textarea' ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: type == 'date' ? 'YYYY-MM-DD' : null,
      ),
    );
  }
}
