import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../masjid/masjid_api.dart';
import '../masjid/masjid_home_page.dart';
import '../masjid/mosque_providers.dart';
import '../masjid/session.dart';

/// Moeslim Family:
/// - Mode lokal 100% offline tanpa login untuk 1 perangkat (agenda, target belajar, profil anak lokal).
/// - Opt-in Family Cloud saat pengguna memilih kolaborasi lintas HP (undangan QR/kode, sinkronisasi & resolusi konflik).
/// - Menjaga batas privasi: tidak menampilkan ranking kesalehan, tracker salat pribadi, atau Journal.
class FamilySpacePage extends ConsumerStatefulWidget {
  const FamilySpacePage({super.key});

  @override
  ConsumerState<FamilySpacePage> createState() => _FamilySpacePageState();
}

class _FamilySpacePageState extends ConsumerState<FamilySpacePage> {
  int _tab = 0;
  bool _loading = true;
  bool _syncing = false;
  LocalFamilySpace? _space;
  List<FamilyAgendaItem> _events = const [];
  List<FamilyLearningGoal> _goals = const [];
  List<LocalChildProfile> _children = const [];
  List<Map<String, dynamic>> _cloudMembers = const [];
  String? _activeInviteToken;
  String? _statusMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(familySpaceRepoProvider);
    final space = await repo.loadSpace();
    final events = await repo.loadEvents();
    final goals = await repo.loadGoals();
    final children = await repo.loadLocalChildren();
    if (mounted) {
      setState(() {
        _space = space;
        _events = events;
        _goals = goals;
        _children = children;
        _loading = false;
      });
    }
    if (space != null && space.isCloudLinked && ref.read(sessionProvider).value != null) {
      await _syncCloud(silent: true);
    }
  }

  Future<void> _createLocalSpaceDialog() async {
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(d.tr('Buat Ruang Keluarga (Lokal)', 'Create Family Space (Local)')),
        content: TextField(
          key: const Key('family-name-field'),
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: d.tr('Nama ruang keluarga', 'Family space name'),
            hintText: d.tr('Contoh: Keluarga Ahmad', 'Example: Ahmad Family'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(d.tr('Batal', 'Cancel'))),
          FilledButton(
            key: const Key('family-create-confirm'),
            onPressed: () => Navigator.pop(d, true),
            child: Text(d.tr('Buat Ruang', 'Create Space')),
          ),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    final repo = ref.read(familySpaceRepoProvider);
    await repo.saveSpace(LocalFamilySpace(
      id: FamilySpaceRepository.newUuidV4(),
      name: nameCtrl.text.trim(),
    ));
    await _load();
  }

  Future<void> _connectCloudFamily() async {
    final session = ref.read(sessionProvider).value;
    if (session == null) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    final space = _space;
    if (space == null) return;
    setState(() {
      _syncing = true;
      _statusMsg = null;
    });
    try {
      final api = ref.read(masjidApiProvider);
      final created = await api.createFamily(space.name, timezone: space.timezone);
      final cloudId = '${created['id']}';
      final linked = LocalFamilySpace(
        id: space.id,
        name: space.name,
        timezone: space.timezone,
        cloudFamilyId: cloudId,
        role: 'admin',
      );
      await ref.read(familySpaceRepoProvider).saveSpace(linked);
      // Tandai agenda lokal lama sebagai pendingSync agar ikut tersinkron
      for (final e in _events) {
        if (e.syncState == FamilySyncState.localOnly) {
          await ref.read(familySpaceRepoProvider).upsertEvent(e.copyWith(syncState: FamilySyncState.pendingSync));
        }
      }
      await _load();
      await _syncCloud();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _syncCloud({bool silent = false}) async {
    final space = _space;
    if (space == null || !space.isCloudLinked) return;
    if (ref.read(sessionProvider).value == null) return;
    setState(() {
      _syncing = true;
      _statusMsg = null;
    });
    try {
      final repo = ref.read(familySpaceRepoProvider);
      final api = ref.read(masjidApiProvider);
      final pending = await repo.pendingSyncEvents();
      for (final ev in pending) {
        try {
          final saved = await api.saveFamilyEvent(space.cloudFamilyId!, ev.id, {
            'title': ev.title,
            'starts_at': ev.startsAt.toUtc().toIso8601String(),
            if (ev.location.isNotEmpty) 'location': ev.location,
            'recurrence': ev.recurrence,
            if (ev.learningPath != null) 'learning_path': ev.learningPath,
            'version': ev.version,
            if (ev.deleted) 'deleted': true,
          });
          await repo.upsertEvent(ev.copyWith(
            version: (saved['version'] as num?)?.toInt() ?? ev.version + 1,
            syncState: FamilySyncState.synced,
          ));
        } on ApiException catch (e) {
          if (e.status == 409) {
            await repo.upsertEvent(ev.copyWith(syncState: FamilySyncState.conflict));
          }
        }
      }
      final detail = await api.familyDetail(space.cloudFamilyId!);
      final serverEvents = List<Map<String, dynamic>>.from(
        (detail['events'] as List? ?? const []).map((x) => Map<String, dynamic>.from(x as Map)),
      );
      await repo.replaceFromCloudEvents(serverEvents);
      final members = List<Map<String, dynamic>>.from(
        (detail['members'] as List? ?? const []).map((x) => Map<String, dynamic>.from(x as Map)),
      );
      final events = await repo.loadEvents();
      if (mounted) {
        setState(() {
          _cloudMembers = members;
          _events = events;
          _statusMsg = silent ? null : context.tr('Sinkronisasi keluarga selesai.', 'Family sync completed.');
        });
      }
    } on ApiException catch (e) {
      if (!silent && mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _joinByInviteDialog() async {
    if (ref.read(sessionProvider).value == null) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    final tokenCtrl = TextEditingController();
    final submitted = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(d.tr('Gabung Ruang Keluarga', 'Join Family Space')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              d.tr(
                'Masukkan token undangan atau pindai QR dari admin keluarga. Data Journal dan ibadah pribadi Anda tetap privat.',
                'Enter the invite token or scan QR from the family admin. Your personal Journal and worship tracker remain private.',
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('family-join-token-field'),
              controller: tokenCtrl,
              decoration: InputDecoration(labelText: d.tr('Token undangan', 'Invite token')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final scanned = await Navigator.of(d).push<String>(
                  MaterialPageRoute(builder: (_) => const _FamilyQrScanPage()),
                );
                if (scanned != null && scanned.trim().isNotEmpty) {
                  tokenCtrl.text = scanned.trim().replaceFirst('MOESLIMFAM:', '');
                }
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(d.tr('Pindai QR Undangan', 'Scan Invite QR')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(d.tr('Batal', 'Cancel'))),
          FilledButton(
            key: const Key('family-join-confirm'),
            onPressed: () => Navigator.pop(d, tokenCtrl.text.trim()),
            child: Text(d.tr('Setujui & Gabung', 'Approve & Join')),
          ),
        ],
      ),
    );
    if (submitted == null || submitted.isEmpty) return;
    try {
      final api = ref.read(masjidApiProvider);
      final res = await api.acceptFamilyInvite(submitted);
      final famId = '${res['family_id']}';
      final detail = await api.familyDetail(famId);
      final fam = Map<String, dynamic>.from(detail['family'] as Map);
      await ref.read(familySpaceRepoProvider).saveSpace(LocalFamilySpace(
        id: famId,
        name: '${fam['name'] ?? 'Keluarga'}',
        timezone: '${fam['timezone'] ?? 'Asia/Jakarta'}',
        cloudFamilyId: famId,
        role: '${detail['role'] ?? 'member'}',
      ));
      await _load();
      if (mounted) showSnack(context, context.tr('Berhasil bergabung ke ruang keluarga.', 'Joined family space.'));
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  Future<void> _addAgendaDialog() async {
    final titleCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String recurrence = 'weekly';
    String pathId = 'quran';
    DateTime pickedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay pickedTime = const TimeOfDay(hour: 18, minute: 30);

    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setD) => AlertDialog(
          title: Text(d.tr('Tambah Agenda Belajar Keluarga', 'Add Family Study Event')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('family-event-title'),
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: d.tr('Judul agenda *', 'Event title *'),
                    hintText: d.tr('Contoh: Tadarus Ba\'da Maghrib', 'Example: Family Quran Reading'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locCtrl,
                  decoration: InputDecoration(
                    labelText: d.tr('Tempat (opsional)', 'Location (optional)'),
                    hintText: d.tr('Ruang Keluarga', 'Living Room'),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: recurrence,
                  decoration: InputDecoration(labelText: d.tr('Pengulangan', 'Recurrence')),
                  items: [
                    DropdownMenuItem(value: 'none', child: Text(d.tr('Sekali', 'Once'))),
                    DropdownMenuItem(value: 'daily', child: Text(d.tr('Harian', 'Daily'))),
                    DropdownMenuItem(value: 'weekly', child: Text(d.tr('Pekanan', 'Weekly'))),
                  ],
                  onChanged: (v) => setD(() => recurrence = v ?? 'weekly'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: pathId,
                  decoration: InputDecoration(labelText: d.tr('Terkait Jalur Belajar', 'Related Learning Path')),
                  items: [
                    for (final t in learningPathCatalog)
                      DropdownMenuItem(value: t.id, child: Text(t.titleFor(context.lang))),
                  ],
                  onChanged: (v) => setD(() => pathId = v ?? 'quran'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(d.tr('Batal', 'Cancel'))),
            FilledButton(
              key: const Key('family-event-save'),
              onPressed: () => Navigator.pop(d, true),
              child: Text(d.tr('Simpan', 'Save')),
            ),
          ],
        ),
      ),
    );
    if (ok != true || titleCtrl.text.trim().isEmpty) return;
    final startsAt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
    final linked = _space?.isCloudLinked == true;
    await ref.read(familySpaceRepoProvider).upsertEvent(FamilyAgendaItem(
      id: FamilySpaceRepository.newUuidV4(),
      title: titleCtrl.text.trim(),
      startsAt: startsAt.toUtc(),
      location: locCtrl.text.trim(),
      recurrence: recurrence,
      learningPath: pathId,
      version: 0,
      syncState: linked ? FamilySyncState.pendingSync : FamilySyncState.localOnly,
    ));
    await _load();
  }

  Future<void> _addGoalDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String pathId = 'arabic';
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setD) => AlertDialog(
          title: Text(d.tr('Target Belajar Bersama', 'Shared Learning Goal')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: pathId,
                decoration: InputDecoration(labelText: d.tr('Jalur Learning Path', 'Learning Path')),
                items: [
                  for (final t in learningPathCatalog)
                    DropdownMenuItem(value: t.id, child: Text(t.titleFor(context.lang))),
                ],
                onChanged: (v) => setD(() => pathId = v ?? 'arabic'),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('family-goal-title'),
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: d.tr('Target belajar *', 'Learning goal *'),
                  hintText: d.tr('Contoh: Selesaikan Bahasa Arab L1 & L2', 'Example: Complete Arabic L1 & L2'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: d.tr('Catatan rencana (opsional)', 'Plan notes (optional)'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(d.tr('Batal', 'Cancel'))),
            FilledButton(
              key: const Key('family-goal-save'),
              onPressed: () => Navigator.pop(d, true),
              child: Text(d.tr('Simpan', 'Save')),
            ),
          ],
        ),
      ),
    );
    if (ok != true || titleCtrl.text.trim().isEmpty) return;
    final goal = FamilyLearningGoal(
      id: FamilySpaceRepository.newUuidV4(),
      learningPath: pathId,
      title: titleCtrl.text.trim(),
      targetDescription: descCtrl.text.trim(),
      deadlineIso: DateTime.now().add(const Duration(days: 30)).toIso8601String().substring(0, 10),
    );
    await ref.read(familySpaceRepoProvider).saveGoal(goal);
    if (_space?.isCloudLinked == true && ref.read(sessionProvider).value != null) {
      try {
        await ref.read(masjidApiProvider).saveFamilyGoal(_space!.cloudFamilyId!, {
          'id': goal.id,
          'learning_path': goal.learningPath,
          'title': goal.title,
          'target_description': goal.targetDescription,
          'deadline': goal.deadlineIso,
        });
      } catch (_) {}
    }
    await _load();
  }

  Future<void> _addChildDialog() async {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String ageGroup = '7-9 tahun';
    String level = 'L1 Huruf & Dasar';

    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setD) => AlertDialog(
          title: Text(d.tr('Tambah Profil Anak (Lokal)', 'Add Child Profile (Local)')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                d.tr(
                  'Profil ini hanya tersimpan di perangkat wali dan tidak dipublikasikan ke cloud.',
                  'This profile stays strictly on the guardian device and is never published to the cloud.',
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('family-child-name'),
                controller: nameCtrl,
                decoration: InputDecoration(labelText: d.tr('Nama panggilan anak *', 'Child nickname *')),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: ageGroup,
                decoration: InputDecoration(labelText: d.tr('Kelompok usia', 'Age group')),
                items: const [
                  DropdownMenuItem(value: '4-6 tahun', child: Text('4-6 tahun')),
                  DropdownMenuItem(value: '7-9 tahun', child: Text('7-9 tahun')),
                  DropdownMenuItem(value: '10-12 tahun', child: Text('10-12 tahun')),
                  DropdownMenuItem(value: '13+ tahun', child: Text('13+ tahun')),
                ],
                onChanged: (v) => setD(() => ageGroup = v ?? ageGroup),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: level,
                decoration: InputDecoration(labelText: d.tr('Level belajar', 'Learning level')),
                items: const [
                  DropdownMenuItem(value: 'L1 Huruf & Dasar', child: Text('L1 Huruf & Dasar')),
                  DropdownMenuItem(value: 'L2 Kosakata & Dialog', child: Text('L2 Kosakata & Dialog')),
                  DropdownMenuItem(value: 'Tajwid & Hafalan Juz 30', child: Text('Tajwid & Hafalan Juz 30')),
                ],
                onChanged: (v) => setD(() => level = v ?? level),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(labelText: d.tr('Catatan belajar wali', 'Guardian study notes')),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(d.tr('Batal', 'Cancel'))),
            FilledButton(
              key: const Key('family-child-save'),
              onPressed: () => Navigator.pop(d, true),
              child: Text(d.tr('Simpan Lokal', 'Save Locally')),
            ),
          ],
        ),
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    await ref.read(familySpaceRepoProvider).saveLocalChild(LocalChildProfile(
      id: FamilySpaceRepository.newUuidV4(),
      nickname: nameCtrl.text.trim(),
      ageGroup: ageGroup,
      learningLevel: level,
      notes: notesCtrl.text.trim(),
    ));
    await _load();
  }

  Future<void> _dissolveSpaceDialog() async {
    final space = _space;
    if (space == null) return;
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(d.tr('Bubarkan Ruang Keluarga?', 'Dissolve Family Space?')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d.tr(
                'Konfirmasi dua langkah: ketik nama ruang "${space.name}" secara persis untuk membubarkan.',
                'Two-step confirmation: type "${space.name}" exactly to dissolve this space.',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(labelText: space.name),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(d.tr('Batal', 'Cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MosqueColors.expense),
            onPressed: () => Navigator.pop(d, ctrl.text.trim() == space.name),
            child: Text(d.tr('Bubarkan', 'Dissolve')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (space.isCloudLinked && ref.read(sessionProvider).value != null) {
      try {
        await ref.read(masjidApiProvider).dissolveFamily(space.cloudFamilyId!, space.name);
      } on ApiException catch (e) {
        if (mounted) showSnack(context, e.message);
        return;
      }
    }
    await ref.read(familySpaceRepoProvider).clearSpace();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final space = _space;

    return Scaffold(
      appBar: AppBar(
        title: Text(space?.name ?? context.tr('Moeslim Family', 'Moeslim Family')),
        centerTitle: true,
        actions: [
          if (space != null && space.isCloudLinked)
            IconButton(
              tooltip: context.tr('Sinkronkan sekarang', 'Sync now'),
              onPressed: _syncing ? null : () => _syncCloud(),
              icon: _syncing
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(MoeslimIcons.sinkronisasi),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : space == null
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PatternBanner(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('Belajar Islam Bersama Keluarga', 'Learn Islam Together as a Family'),
                            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr(
                              'Agenda mengaji, target belajar bersama, dan profil anak lokal di perangkat wali. Tanpa peringkat kesalehan dan tidak pernah membuka Journal pribadi.',
                              'Shared study schedules, learning goals, and local guardian-managed child profiles. No piety rankings and your private Journal is never shared.',
                            ),
                            style: const TextStyle(color: BrandColors.cream, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const Key('family-create-local-btn'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
                      onPressed: _createLocalSpaceDialog,
                      icon: const Icon(MoeslimIcons.tambah),
                      label: Text(context.tr('Buat Ruang Keluarga (Gratis, Offline)', 'Create Family Space (Free, Offline)')),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      key: const Key('family-join-btn'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
                      onPressed: _joinByInviteDialog,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: Text(context.tr('Gabung Keluarga via Kode / QR', 'Join Family via Code / QR')),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: PillTabs(
                        labels: [
                          context.tr('Agenda', 'Agenda'),
                          context.tr('Target Belajar', 'Goals'),
                          context.tr('Profil Anak', 'Kids'),
                          context.tr('Ruang', 'Space'),
                        ],
                        index: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ),
                    if (_statusMsg != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        child: Text(_statusMsg!, style: t.bodySmall?.copyWith(color: scheme.primary)),
                      ),
                    Expanded(
                      child: switch (_tab) {
                        0 => _buildAgendaTab(context),
                        1 => _buildGoalsTab(context),
                        2 => _buildChildrenTab(context),
                        _ => _buildSpaceTab(context, space),
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildAgendaTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        FilledButton.icon(
          key: const Key('family-add-event-btn'),
          onPressed: _addAgendaDialog,
          icon: const Icon(MoeslimIcons.tambah),
          label: Text(context.tr('Tambah Agenda Belajar Keluarga', 'Add Family Study Agenda')),
        ),
        const SizedBox(height: 10),
        if (_events.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr(
                  'Belum ada agenda bersama. Buat jadwal mengaji atau belajar keluarga; tersimpan lokal meski offline.',
                  'No shared events yet. Create a study schedule; saved locally even when offline.',
                ),
              ),
            ),
          )
        else
          for (final ev in _events)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: const Icon(MoeslimIcons.kalender, color: BrandColors.emerald),
                title: Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${context.shortDateText(ev.startsAt.toLocal())} ${hhmm(ev.startsAt.toLocal())}${ev.location.isNotEmpty ? ' • ${ev.location}' : ''}'),
                    const SizedBox(height: 4),
                    StatusBadge(
                      switch (ev.syncState) {
                        FamilySyncState.localOnly => context.tr('Lokal (Offline)', 'Local (Offline)'),
                        FamilySyncState.pendingSync => context.tr('Menunggu sinkronisasi', 'Pending sync'),
                        FamilySyncState.synced => context.tr('Tersinkron Cloud', 'Cloud synced'),
                        FamilySyncState.conflict => context.tr('Konflik versi: perlu ditinjau', 'Version conflict: review'),
                      },
                      color: ev.syncState == FamilySyncState.conflict
                          ? MosqueColors.expense
                          : ev.syncState == FamilySyncState.pendingSync
                              ? MosqueColors.warning
                              : BrandColors.emerald,
                    ),
                    if (ev.syncState == FamilySyncState.conflict && ev.conflictServerTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          context.tr('Versi server: ${ev.conflictServerTitle}', 'Server version: ${ev.conflictServerTitle}'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildGoalsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              context.tr(
                'Target bersama hanya berfokus pada modul Learning Path. Aplikasi tidak menampilkan ranking kesalehan atau tracker salat individu.',
                'Shared goals focus strictly on Learning Path modules. No piety rankings or individual prayer trackers are shown.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('family-add-goal-btn'),
          onPressed: _addGoalDialog,
          icon: const Icon(MoeslimIcons.target),
          label: Text(context.tr('Buat Target Belajar Bersama', 'Create Shared Learning Goal')),
        ),
        const SizedBox(height: 10),
        for (final g in _goals)
          Card(
            child: CheckboxListTile(
              value: g.completed,
              title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${g.learningPath.toUpperCase()}${g.deadlineIso != null ? ' • ${g.deadlineIso}' : ''}${g.targetDescription.isNotEmpty ? '\n${g.targetDescription}' : ''}'),
              onChanged: (v) async {
                await ref.read(familySpaceRepoProvider).saveGoal(g.copyWith(completed: v ?? false));
                await _load();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildChildrenTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(MoeslimIcons.pengaman, color: BrandColors.emerald),
            title: Text(context.tr('Profil Anak Lokal (Privasi Wali)', 'Local Child Profiles (Guardian Privacy)')),
            subtitle: Text(
              context.tr(
                'Disimpan hanya di perangkat wali untuk memandu level belajar dan materi aman sesuai usia.',
                'Stored strictly on the guardian device to guide age-appropriate study levels.',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const Key('family-add-child-btn'),
          onPressed: _addChildDialog,
          icon: const Icon(MoeslimIcons.tambah),
          label: Text(context.tr('Tambah Profil Anak', 'Add Child Profile')),
        ),
        const SizedBox(height: 10),
        for (final c in _children)
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: BrandColors.emerald,
                foregroundColor: Colors.white,
                child: Icon(MoeslimIcons.profil),
              ),
              title: Text(c.nickname, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${c.ageGroup} • ${c.learningLevel}${c.notes.isNotEmpty ? '\n${c.notes}' : ''}'),
              trailing: IconButton(
                tooltip: context.tr('Hapus profil lokal', 'Delete local profile'),
                icon: const Icon(MoeslimIcons.hapus),
                onPressed: () async {
                  await ref.read(familySpaceRepoProvider).deleteLocalChild(c.id);
                  await _load();
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpaceTab(BuildContext context, LocalFamilySpace space) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(MoeslimIcons.jamaah, color: BrandColors.emerald),
            title: Text(space.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
              space.isCloudLinked
                  ? context.tr('Terhubung ke Family Cloud (maks. 8 anggota)', 'Connected to Family Cloud (max 8 members)')
                  : context.tr('Mode Lokal (hanya di HP ini)', 'Local Mode (this device only)'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (!space.isCloudLinked) ...[
          FilledButton.icon(
            key: const Key('family-connect-cloud-btn'),
            onPressed: _syncing ? null : _connectCloudFamily,
            icon: const Icon(MoeslimIcons.sinkronisasi),
            label: Text(context.tr('Hubungkan ke Family Cloud (Lintas HP)', 'Connect to Family Cloud (Multi-Device)')),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _joinByInviteDialog,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(context.tr('Atau Gabung Ruang Keluarga Lain', 'Or Join Another Family Space')),
          ),
        ] else ...[
          if (space.role == 'admin')
            FilledButton.icon(
              key: const Key('family-create-invite-btn'),
              onPressed: () async {
                try {
                  final inv = await ref.read(masjidApiProvider).createFamilyInvite(space.cloudFamilyId!);
                  setState(() => _activeInviteToken = '${inv['token']}');
                } on ApiException catch (e) {
                  if (context.mounted) showSnack(context, e.message);
                }
              },
              icon: const Icon(Icons.qr_code_2_rounded),
              label: Text(context.tr('Buat Undangan QR / Kode (48 Jam)', 'Create QR / Code Invite (48h)')),
            ),
          if (_activeInviteToken != null) ...[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    QrImageView(data: 'MOESLIMFAM:$_activeInviteToken', size: 170),
                    const SizedBox(height: 8),
                    SelectableText(_activeInviteToken!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _activeInviteToken!));
                        if (context.mounted) showSnack(context, context.tr('Token undangan disalin.', 'Invite token copied.'));
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(context.tr('Salin Token Undangan', 'Copy Invite Token')),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_cloudMembers.isNotEmpty) ...[
            SectionHeader(context.tr('Anggota (${_cloudMembers.length}/8)', 'Members (${_cloudMembers.length}/8)')),
            for (final m in _cloudMembers)
              Card(
                child: ListTile(
                  leading: const Icon(MoeslimIcons.profil),
                  title: Text('${m['name']}'),
                  subtitle: Text('${m['role']}'),
                ),
              ),
          ],
        ],
        const SizedBox(height: 16),
        if (space.role == 'member' && space.isCloudLinked)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: MosqueColors.expense),
            onPressed: () async {
              try {
                await ref.read(masjidApiProvider).leaveFamily(space.cloudFamilyId!);
                await ref.read(familySpaceRepoProvider).clearSpace();
                await _load();
              } on ApiException catch (e) {
                if (context.mounted) showSnack(context, e.message);
              }
            },
            icon: const Icon(MoeslimIcons.logout),
            label: Text(context.tr('Keluar dari Ruang Keluarga', 'Leave Family Space')),
          )
        else
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: MosqueColors.expense),
            onPressed: _dissolveSpaceDialog,
            icon: const Icon(MoeslimIcons.hapus),
            label: Text(context.tr('Bubarkan Ruang Keluarga', 'Dissolve Family Space')),
          ),
      ],
    );
  }
}

class _FamilyQrScanPage extends StatefulWidget {
  const _FamilyQrScanPage();

  @override
  State<_FamilyQrScanPage> createState() => _FamilyQrScanPageState();
}

class _FamilyQrScanPageState extends State<_FamilyQrScanPage> {
  bool _popped = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('Pindai QR Keluarga', 'Scan Family QR')), centerTitle: true),
    body: MobileScanner(
      onDetect: (cap) {
        if (_popped) return;
        final raw = cap.barcodes.firstOrNull?.rawValue;
        if (raw != null && raw.trim().isNotEmpty) {
          _popped = true;
          Navigator.of(context).pop(raw.trim());
        }
      },
    ),
  );
}
