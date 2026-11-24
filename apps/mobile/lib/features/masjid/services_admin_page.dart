import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../ui/components.dart';
import '../services/personal_services_page.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

/// Moeslim Services sisi Pengurus Masjid (SVC-01..SVC-08):
/// - RBAC ketat: hanya peran dengan izin `services.view` / `services.manage` (Admin & Pengurus; Bendahara tidak otomatis).
/// - Tab 1: Kotak Masuk Permohonan dengan filter status dan state-machine server-side + catatan klarifikasi.
/// - Tab 2: Katalog Layanan Masjid dengan preset siap pakai (TPQ, Kegiatan, Aspirasi, Fasilitas, Konsultasi, Sosial, Ramadan).
class MosqueServicesAdminPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const MosqueServicesAdminPage({super.key, required this.ctx});

  @override
  ConsumerState<MosqueServicesAdminPage> createState() => _MosqueServicesAdminPageState();
}

class _MosqueServicesAdminPageState extends ConsumerState<MosqueServicesAdminPage> {
  int _tab = 0;
  String? _statusFilter;

  static const _filterStatuses = <String?>[
    null,
    'submitted',
    'under_review',
    'need_revision',
    'resubmitted',
    'approved',
    'completed',
    'rejected',
  ];

  static const _staffTransitions = <String, List<String>>{
    'submitted': ['under_review', 'cancelled'],
    'under_review': ['need_revision', 'approved', 'rejected'],
    'resubmitted': ['under_review', 'need_revision', 'approved', 'rejected'],
    'approved': ['completed', 'cancelled'],
    'rejected': ['closed'],
    'completed': ['closed'],
  };

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
        final ctx = widget.ctx;
        final canManage = ctx.can('services.manage');
        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('Layanan Masjid', 'Mosque Services')),
            centerTitle: true,
          ),
          floatingActionButton: _tab == 1 && canManage
              ? FloatingActionButton.extended(
                  heroTag: null,
                  key: const Key('add-service-def'),
                  icon: const Icon(MoeslimIcons.tambah),
                  label: Text(context.tr('Buat Layanan', 'New Service')),
                  onPressed: () async {
                    final created = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => _ServiceDefinitionFormPage(ctx: ctx)),
                    );
                    if (created == true) {
                      ref.invalidate(mosqueServicesProvider(ctx.id));
                    }
                  },
                )
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: PillTabs(
                  labels: [
                    context.tr('Kotak Masuk', 'Inbox'),
                    context.tr('Katalog Layanan', 'Service Catalog'),
                  ],
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
              Expanded(
                child: _tab == 0 ? _buildInboxTab(context, canManage) : _buildCatalogTab(context, canManage),
              ),
            ],
          ),
        );
      });

  Widget _buildInboxTab(BuildContext context, bool canManage) {
    final ctx = widget.ctx;
    final key = (ctx.id, _statusFilter);
    final reqs = ref.watch(mosqueServiceRequestsProvider(key));
    final t = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(mosqueServiceRequestsProvider(key).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final st in _filterStatuses)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        st == null
                            ? context.tr('Semua', 'All')
                            : PersonalServicesPage.requestStatusBadge(context, st).$1,
                      ),
                      selected: _statusFilter == st,
                      onSelected: (_) => setState(() => _statusFilter = st),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AsyncBody(
            value: reqs,
            onRetry: () => ref.invalidate(mosqueServiceRequestsProvider(key)),
            data: (list) {
              if (list.isEmpty) {
                return EmptyState(
                  MoeslimIcons.laporan,
                  context.tr('Belum ada permohonan layanan', 'No service requests yet'),
                  art: BrandEmptyArt.tidakAdaHasil,
                  message: context.tr(
                    'Permohonan jamaah yang masuk akan muncul di sini sesuai filter status.',
                    'Incoming congregation requests will appear here based on the status filter.',
                  ),
                );
              }
              return Column(
                children: [
                  for (final r in list) _buildInboxCard(context, t, r, canManage),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInboxCard(BuildContext context, TextTheme t, Map<String, dynamic> r, bool canManage) {
    final status = '${r['status'] ?? 'submitted'}';
    final badge = PersonalServicesPage.requestStatusBadge(context, status);
    final def = r['definition'] is Map ? Map<String, dynamic>.from(r['definition'] as Map) : const <String, dynamic>{};
    final user = r['user'] is Map ? Map<String, dynamic>.from(r['user'] as Map) : const <String, dynamic>{};
    final created = DateTime.tryParse('${r['created_at'] ?? ''}')?.toLocal();

    return Card(
      key: Key('admin-svc-req-${r['id']}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Row(
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r['reference_no'] ?? r['id']} · ${user['name'] ?? '-'}'),
              if (created != null)
                Text(
                  '${context.shortDateText(created)} ${hhmm(created)}',
                  style: t.labelSmall,
                ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final changed = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => _RequestDetailSheet(
              ctx: widget.ctx,
              request: r,
              canManage: canManage,
              nextStatuses: _staffTransitions[status] ?? const [],
            ),
          );
          if (changed == true) {
            ref.invalidate(mosqueServiceRequestsProvider((widget.ctx.id, _statusFilter)));
            ref.invalidate(mosqueServiceRequestsProvider((widget.ctx.id, null)));
            ref.invalidate(mosqueServicesProvider(widget.ctx.id));
          }
        },
      ),
    );
  }

  Widget _buildCatalogTab(BuildContext context, bool canManage) {
    final ctx = widget.ctx;
    final defs = ref.watch(mosqueServicesProvider(ctx.id));
    final t = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(mosqueServicesProvider(ctx.id).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          AsyncBody(
            value: defs,
            onRetry: () => ref.invalidate(mosqueServicesProvider(ctx.id)),
            data: (list) {
              if (list.isEmpty) {
                return EmptyState(
                  MoeslimIcons.kegiatan,
                  context.tr('Belum ada layanan masjid aktif', 'No mosque services configured'),
                  art: BrandEmptyArt.agenda,
                  message: context.tr(
                    'Buat layanan TPQ, pendaftaran kegiatan, peminjaman fasilitas, atau aspirasi jamaah.',
                    'Create TPQ enrollment, event registration, facility booking, or feedback services.',
                  ),
                );
              }
              return Column(
                children: [
                  for (final d in list)
                    Card(
                      key: Key('admin-svc-def-${d['id']}'),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('${d['title']}', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                ),
                                StatusBadge(PersonalServicesPage.serviceTypeLabel(context, '${d['type'] ?? 'kegiatan'}')),
                              ],
                            ),
                            if (d['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text('${d['description']}', style: t.bodySmall),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              context.tr(
                                'Total permohonan: ${d['total_requests_count'] ?? 0} · Menunggu: ${d['pending_requests_count'] ?? 0} · Retensi: ${d['retention_days'] ?? 365} hari',
                                'Total requests: ${d['total_requests_count'] ?? 0} · Pending: ${d['pending_requests_count'] ?? 0} · Retention: ${d['retention_days'] ?? 365} days',
                              ),
                              style: t.labelSmall,
                            ),
                            if (canManage)
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(context.tr('Layanan Aktif untuk Jamaah', 'Active for Congregation')),
                                value: d['active'] == true,
                                onChanged: (v) async {
                                  try {
                                    await ref.read(masjidApiProvider).updateMosqueService(ctx.id, '${d['id']}', {'active': v});
                                    ref.invalidate(mosqueServicesProvider(ctx.id));
                                  } on ApiException catch (e) {
                                    if (context.mounted) showSnack(context, e.message);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestDetailSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> request;
  final bool canManage;
  final List<String> nextStatuses;

  const _RequestDetailSheet({
    required this.ctx,
    required this.request,
    required this.canManage,
    required this.nextStatuses,
  });

  @override
  ConsumerState<_RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends ConsumerState<_RequestDetailSheet> {
  final _noteCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _transition(String nextStatus) async {
    final msg = _noteCtrl.text.trim();
    if ((nextStatus == 'need_revision' || nextStatus == 'rejected') && msg.isEmpty) {
      setState(() {
        _error = context.tr(
          'Catatan klarifikasi atau alasan wajib diisi untuk status ini.',
          'A clarification note or reason is required for this status.',
        );
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(masjidApiProvider).updateMosqueServiceRequestStatus(
            widget.ctx.id,
            '${widget.request['id']}',
            nextStatus,
            message: msg,
          );
      if (!mounted) return;
      showSnack(context, context.tr('Status permohonan diperbarui.', 'Request status updated.'));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
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
        final r = widget.request;
        final def = r['definition'] is Map ? Map<String, dynamic>.from(r['definition'] as Map) : const <String, dynamic>{};
        final user = r['user'] is Map ? Map<String, dynamic>.from(r['user'] as Map) : const <String, dynamic>{};
        final answers = r['answers'] is Map ? Map<String, dynamic>.from(r['answers'] as Map) : const <String, dynamic>{};
        final history = [
          for (final h in (r['history'] as List? ?? const []))
            if (h is Map) Map<String, dynamic>.from(h),
        ];
        final bottom = MediaQuery.viewInsetsOf(context).bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${def['title'] ?? ''}', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Text('${r['reference_no'] ?? r['id']} · ${user['name'] ?? '-'}', style: t.bodySmall),
                const SizedBox(height: 12),
                Text(context.tr('Isian Formulir', 'Submitted Answers'), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final e in answers.entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('${e.key}: ${e.value}'),
                          ),
                      ],
                    ),
                  ),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(context.tr('Riwayat Status', 'Status History'), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  for (final h in history)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${PersonalServicesPage.requestStatusBadge(context, '${h['status']}').$1}${h['message'] != null ? ': ${h['message']}' : ''}',
                        style: t.bodySmall,
                      ),
                    ),
                ],
                if (widget.canManage && widget.nextStatuses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('admin-svc-note'),
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: context.tr('Catatan pengurus (wajib jika revisi/tolak)', 'Committee note (required for revision/rejection)'),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_error!, style: TextStyle(color: scheme.error)),
                    ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final st in widget.nextStatuses)
                        FilledButton(
                          key: Key('admin-svc-action-$st'),
                          onPressed: _busy ? null : () => _transition(st),
                          child: Text(PersonalServicesPage.requestStatusBadge(context, st).$1),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      });
}

class _ServiceDefinitionFormPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const _ServiceDefinitionFormPage({required this.ctx});

  @override
  ConsumerState<_ServiceDefinitionFormPage> createState() => _ServiceDefinitionFormPageState();
}

class _ServiceDefinitionFormPageState extends ConsumerState<_ServiceDefinitionFormPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _privacyCtrl = TextEditingController(
    text: 'Data yang dikirim hanya digunakan oleh pengurus masjid terkait untuk memproses permohonan layanan ini.',
  );
  final _capacityCtrl = TextEditingController();
  String _type = 'tpq';
  bool _active = true;
  bool _busy = false;
  String? _error;

  List<Map<String, dynamic>> _fields = [
    {'key': 'nama_peserta', 'label': 'Nama Peserta / Santri', 'type': 'text', 'required': true},
    {'key': 'kontak_wali', 'label': 'Nomor Kontak / WhatsApp', 'type': 'text', 'required': true},
    {'key': 'catatan', 'label': 'Catatan Tambahan', 'type': 'textarea', 'required': false},
  ];

  static const _serviceTypes = ['tpq', 'kegiatan', 'aspirasi', 'fasilitas', 'konsultasi', 'sosial', 'ramadan'];

  void _applyPreset(String type) {
    setState(() {
      _type = type;
      switch (type) {
        case 'tpq':
          _titleCtrl.text = 'Pendaftaran TPQ / Kelas Tahsin';
          _descCtrl.text = 'Pendaftaran santri baru TPQ atau kelas baca Al-Qur\'an di masjid.';
          _fields = [
            {'key': 'nama_santri', 'label': 'Nama Santri', 'type': 'text', 'required': true},
            {'key': 'usia', 'label': 'Usia', 'type': 'number', 'required': true},
            {'key': 'kontak_wali', 'label': 'No. HP Orang Tua / Wali', 'type': 'text', 'required': true},
          ];
        case 'fasilitas':
          _titleCtrl.text = 'Peminjaman Ruang / Fasilitas Masjid';
          _descCtrl.text = 'Permohonan peminjaman aula, ruang rapat, atau perlengkapan masjid.';
          _fields = [
            {'key': 'keperluan', 'label': 'Keperluan Kegiatan', 'type': 'text', 'required': true},
            {'key': 'tanggal_pakai', 'label': 'Tanggal Pemakaian', 'type': 'date', 'required': true},
            {'key': 'penanggung_jawab', 'label': 'Nama & No. HP Penanggung Jawab', 'type': 'text', 'required': true},
          ];
        case 'aspirasi':
          _titleCtrl.text = 'Aspirasi & Masukan Jamaah';
          _descCtrl.text = 'Sampaikan saran, masukan fasilitas, atau usulan kajian untuk pengurus masjid.';
          _fields = [
            {'key': 'topik', 'label': 'Topik Masukan', 'type': 'text', 'required': true},
            {'key': 'pesan', 'label': 'Isi Masukan', 'type': 'textarea', 'required': true},
          ];
        case 'konsultasi':
          _titleCtrl.text = 'Jadwal Konsultasi Pengurus / Ustadz';
          _descCtrl.text = 'Pengajuan janji temu konsultasi keagamaan atau keluarga secara tertib.';
          _fields = [
            {'key': 'topik_konsultasi', 'label': 'Topik Ringkas', 'type': 'text', 'required': true},
            {'key': 'waktu_pilihan', 'label': 'Pilihan Waktu', 'type': 'text', 'required': true},
          ];
        case 'sosial':
          _titleCtrl.text = 'Program Bantuan & Layanan Sosial';
          _descCtrl.text = 'Pengajuan layanan sosial, bantuan dhuafa, atau koordinasi kemasyarakatan.';
          _fields = [
            {'key': 'nama_penerima', 'label': 'Nama Penerima Manfaat', 'type': 'text', 'required': true},
            {'key': 'keterangan', 'label': 'Keterangan Kebutuhan', 'type': 'textarea', 'required': true},
          ];
        case 'ramadan':
          _titleCtrl.text = 'Pendaftaran Program Ramadan Masjid';
          _descCtrl.text = 'Pendaftaran buka bersama, i\'tikaf, atau panitia Ramadan masjid.';
          _fields = [
            {'key': 'nama_jamaah', 'label': 'Nama Jamaah', 'type': 'text', 'required': true},
            {'key': 'jumlah_orang', 'label': 'Jumlah Orang', 'type': 'number', 'required': true},
          ];
        default:
          _titleCtrl.text = 'Pendaftaran Kegiatan Masjid';
          _descCtrl.text = 'Pendaftaran jamaah untuk kegiatan khusus masjid.';
          _fields = [
            {'key': 'nama_peserta', 'label': 'Nama Peserta', 'type': 'text', 'required': true},
            {'key': 'kontak', 'label': 'No. Kontak', 'type': 'text', 'required': true},
          ];
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _privacyCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final cap = int.tryParse(_capacityCtrl.text.trim());
      await ref.read(masjidApiProvider).createMosqueService(widget.ctx.id, {
        'title': _titleCtrl.text.trim(),
        'type': _type,
        'description': _descCtrl.text.trim(),
        'privacy_notice': _privacyCtrl.text.trim(),
        'fields': _fields,
        if (cap != null && cap > 0) 'capacity': cap,
        'active': _active,
        'retention_days': 365,
      });
      if (!mounted) return;
      showSnack(context, context.tr('Layanan masjid berhasil dibuat.', 'Mosque service created.'));
      Navigator.pop(context, true);
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
        return Scaffold(
          appBar: AppBar(title: Text(context.tr('Buat Layanan Masjid', 'Create Mosque Service')), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(context.tr('Preset Cepat Jenis Layanan', 'Quick Service Type Preset'), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final st in _serviceTypes)
                    ChoiceChip(
                      key: Key('preset-svc-$st'),
                      label: Text(PersonalServicesPage.serviceTypeLabel(context, st)),
                      selected: _type == st,
                      onSelected: (_) => _applyPreset(st),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('admin-svc-title'),
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: context.tr('Nama layanan *', 'Service title *')),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('admin-svc-desc'),
                controller: _descCtrl,
                maxLines: 2,
                decoration: InputDecoration(labelText: context.tr('Deskripsi layanan *', 'Service description *')),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('admin-svc-privacy'),
                controller: _privacyCtrl,
                maxLines: 2,
                decoration: InputDecoration(labelText: context.tr('Pemberitahuan privasi *', 'Privacy notice *')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr('Kuota maksimal (opsional)', 'Max capacity (optional)'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('Langsung aktifkan untuk jamaah', 'Activate immediately for congregation')),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(height: 8),
              Text(context.tr('Kolom Formulir (${_fields.length})', 'Form Fields (${_fields.length})'), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              for (final f in _fields)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${f['label']}'),
                  subtitle: Text('${f['key']} · ${f['type']}${f['required'] == true ? ' · wajib' : ''}'),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('save-service-def'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
                onPressed: _busy ? null : _save,
                icon: const Icon(MoeslimIcons.check),
                label: Text(context.tr('Simpan Layanan', 'Save Service')),
              ),
            ],
          ),
        );
      });
}
