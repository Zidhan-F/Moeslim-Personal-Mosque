import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

/// Moeslim Journal + Muhasabah (100% lokal dan privat):
/// - Entri teks bebas, refleksi ayat, hadis, kajian, dan muhasabah malam.
/// - Referensi sumber asli tampil terpisah dari refleksi pribadi (JRN-02 / JRN-AC04).
/// - Autosave draft offline, pencarian lokal, tag, arsip, hapus dengan pemulihan lokal.
/// - Kunci PIN lokal ber-hash SHA-256 bersalt + auto-kunci saat kembali dari background (JRN-AC05).
/// - Ekspor & impor terenkripsi lokal ber-password (JRN-07). Tidak pernah dikirim ke Family/Mosque.
class MuhasabahJournalPage extends ConsumerStatefulWidget {
  final JournalEntryKind? initialKind;
  final String? initialSourceRef;
  final String? initialSourceExcerpt;
  final String? initialTitle;

  const MuhasabahJournalPage({
    super.key,
    this.initialKind,
    this.initialSourceRef,
    this.initialSourceExcerpt,
    this.initialTitle,
  });

  @override
  ConsumerState<MuhasabahJournalPage> createState() => _MuhasabahJournalPageState();
}

class _MuhasabahJournalPageState extends ConsumerState<MuhasabahJournalPage> with WidgetsBindingObserver {
  int _tab = 0; // 0 = Jurnal Pribadi, 1 = Muhasabah Malam

  // Journal controllers
  final _jTitleCtrl = TextEditingController();
  final _jBodyCtrl = TextEditingController();
  final _jTagsCtrl = TextEditingController();
  final _jSourceRefCtrl = TextEditingController();
  final _jSourceExcerptCtrl = TextEditingController();
  final _jSearchCtrl = TextEditingController();
  JournalEntryKind _jKind = JournalEntryKind.free;
  String _jSearch = '';
  bool _showPrompt = true;
  bool _showArchived = false;
  bool _showTrash = false;
  List<JournalEntry> _journalEntries = const [];

  // Legacy Muhasabah controllers (dipertahankan penuh agar kompatibel dengan data & test lama)
  final _gratitudeCtrl = TextEditingController();
  final _evalCtrl = TextEditingController();
  final _hopeCtrl = TextEditingController();
  final _pinInputCtrl = TextEditingController();
  String _selectedMood = 'Tenang & Bersyukur';
  List<MuhasabahEntry> _muhasabahEntries = const [];

  bool _hasPin = false;
  bool _unlocked = false;
  bool _pinInvalid = false;
  bool _loading = true;

  static const _moods = [
    'Tenang & Bersyukur',
    'Bersemangat Taat',
    'Perlu Muhasabah',
    'Memohon Kekuatan',
  ];

  String _moodLabel(BuildContext context, String mood) => switch (mood) {
        'Tenang & Bersyukur' => context.tr('Tenang & Bersyukur', 'Calm & Grateful'),
        'Bersemangat Taat' => context.tr('Bersemangat Taat', 'Motivated in Worship'),
        'Perlu Muhasabah' => context.tr('Perlu Muhasabah', 'Need Reflection'),
        'Memohon Kekuatan' => context.tr('Memohon Kekuatan', 'Seeking Strength'),
        _ => mood,
      };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialKind != null) _jKind = widget.initialKind!;
    if (widget.initialTitle != null) _jTitleCtrl.text = widget.initialTitle!;
    if (widget.initialSourceRef != null) _jSourceRefCtrl.text = widget.initialSourceRef!;
    if (widget.initialSourceExcerpt != null) _jSourceExcerptCtrl.text = widget.initialSourceExcerpt!;
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // JRN-AC05: Kunci jurnal aktif otomatis saat aplikasi berpindah ke background
    if (_hasPin && (state == AppLifecycleState.paused || state == AppLifecycleState.hidden)) {
      if (mounted) {
        setState(() {
          _unlocked = false;
          _pinInputCtrl.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _jTitleCtrl.dispose();
    _jBodyCtrl.dispose();
    _jTagsCtrl.dispose();
    _jSourceRefCtrl.dispose();
    _jSourceExcerptCtrl.dispose();
    _jSearchCtrl.dispose();
    _gratitudeCtrl.dispose();
    _evalCtrl.dispose();
    _hopeCtrl.dispose();
    _pinInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final jRepo = ref.read(journalRepoProvider);
    final mRepo = ref.read(muhasabahRepoProvider);
    final hasPin = await jRepo.hasPin();
    final draft = await jRepo.loadDraft();
    final jEntries = _showTrash
        ? await jRepo.deletedEntries()
        : await jRepo.search(query: _jSearch, archived: _showArchived);
    final mEntries = await mRepo.allEntries();

    if (draft != null && _jBodyCtrl.text.isEmpty && widget.initialSourceRef == null) {
      _jKind = draft.kind;
      _jTitleCtrl.text = draft.title;
      _jBodyCtrl.text = draft.body;
      _jTagsCtrl.text = draft.tagsText;
      _jSourceRefCtrl.text = draft.sourceRef;
      _jSourceExcerptCtrl.text = draft.sourceExcerpt;
    }

    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _unlocked = hasPin ? _unlocked : true;
        _journalEntries = jEntries;
        _muhasabahEntries = mEntries;
        _loading = false;
      });
    }
  }

  void _autosaveDraft() {
    ref.read(journalRepoProvider).saveDraft(JournalDraft(
      kind: _jKind,
      title: _jTitleCtrl.text,
      body: _jBodyCtrl.text,
      tagsText: _jTagsCtrl.text,
      sourceRef: _jSourceRefCtrl.text,
      sourceExcerpt: _jSourceExcerptCtrl.text,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _saveJournalEntry() async {
    if (_jBodyCtrl.text.trim().isEmpty && _jTitleCtrl.text.trim().isEmpty) return;
    final tags = _jTagsCtrl.text.split(RegExp(r'[,\s]+')).where((s) => s.trim().isNotEmpty).toList();
    await ref.read(journalRepoProvider).saveEntry(
      kind: _jKind,
      title: _jTitleCtrl.text,
      body: _jBodyCtrl.text,
      tags: tags,
      sourceRef: _jSourceRefCtrl.text,
      sourceExcerpt: _jSourceExcerptCtrl.text,
    );
    await ref.read(journalRepoProvider).clearDraft();
    _jTitleCtrl.clear();
    _jBodyCtrl.clear();
    _jTagsCtrl.clear();
    _jSourceRefCtrl.clear();
    _jSourceExcerptCtrl.clear();
    await _load();
  }

  Future<void> _saveMuhasabah() async {
    if (_gratitudeCtrl.text.trim().isEmpty && _evalCtrl.text.trim().isEmpty && _hopeCtrl.text.trim().isEmpty) {
      return;
    }
    await ref.read(muhasabahRepoProvider).saveEntry(
      date: DateTime.now(),
      mood: _selectedMood,
      gratitude: _gratitudeCtrl.text,
      evaluation: _evalCtrl.text,
      hopeAndPrayer: _hopeCtrl.text,
    );
    _gratitudeCtrl.clear();
    _evalCtrl.clear();
    _hopeCtrl.clear();
    await _load();
  }

  Future<void> _configurePinDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(dialogCtx.tr('Kunci PIN Jurnal Lokal', 'Local Journal PIN Lock')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dialogCtx.tr(
                'PIN disimpan sebagai hash acak di perangkat (bukan teks biasa). Kosongkan untuk mematikan kunci.',
                'PIN is stored as a salted hash on this device (never plaintext). Leave blank to disable lock.',
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('muhasabah-set-pin-field'),
              controller: ctrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: dialogCtx.tr('PIN Baru (kosongkan untuk matikan)', 'New PIN (leave blank to disable)'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(dialogCtx.tr('Batal', 'Cancel'))),
          FilledButton(
            key: const Key('muhasabah-save-pin-btn'),
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: Text(dialogCtx.tr('Simpan', 'Save')),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref.read(journalRepoProvider).setPin(result.isEmpty ? null : result);
      setState(() => _unlocked = true);
      await _load();
    }
  }

  Future<void> _exportImportEncryptedDialog() async {
    final passCtrl = TextEditingController();
    final importCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(d.tr('Ekspor & Pulihkan Terenkripsi', 'Encrypted Local Export & Restore')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                d.tr(
                  'Peringatan privasi: simpan sandi secara aman dan berhati-hatilah saat membagikan berkas ekspor keluar aplikasi.',
                  'Privacy notice: keep your passphrase safe and be cautious when sharing exported data outside the app.',
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('journal-enc-pass'),
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: d.tr('Kata sandi enkripsi (min. 4 karakter)', 'Encryption passphrase (min 4 chars)')),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('journal-enc-export-btn'),
                onPressed: () async {
                  try {
                    final encrypted = await ref.read(journalRepoProvider).exportEncrypted(passCtrl.text);
                    await Clipboard.setData(ClipboardData(text: encrypted));
                    if (d.mounted) Navigator.pop(d);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('Cadangan jurnal terenkripsi disalin ke clipboard.', 'Encrypted journal backup copied to clipboard.'))),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
                icon: const Icon(Icons.enhanced_encryption_outlined),
                label: Text(d.tr('Salin Ekspor Terenkripsi', 'Copy Encrypted Export')),
              ),
              const Divider(height: 20),
              TextField(
                key: const Key('journal-enc-import-field'),
                controller: importCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: d.tr('Tempel teks ekspor terenkripsi untuk pulihkan', 'Paste encrypted export JSON to restore')),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('journal-enc-import-btn'),
                onPressed: () async {
                  try {
                    final n = await ref.read(journalRepoProvider).importEncrypted(importCtrl.text.trim(), passCtrl.text);
                    await _load();
                    if (d.mounted) Navigator.pop(d);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('$n entri jurnal berhasil dipulihkan.', '$n journal entries restored.'))),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
                icon: const Icon(Icons.restore_rounded),
                label: Text(d.tr('Pulihkan dari Ekspor', 'Restore from Export')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(d.tr('Tutup', 'Close'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Jurnal Muhasabah & Syukur', 'Moeslim Journal & Muhasabah')),
        centerTitle: true,
        actions: [
          if (_unlocked) ...[
            IconButton(
              key: const Key('journal-export-btn'),
              tooltip: context.tr('Ekspor / pulihkan terenkripsi', 'Encrypted export / restore'),
              onPressed: _exportImportEncryptedDialog,
              icon: const Icon(Icons.enhanced_encryption_outlined),
            ),
            IconButton(
              key: const Key('muhasabah-pin-config-btn'),
              tooltip: !_hasPin
                  ? context.tr('Pasang kunci PIN lokal', 'Set local PIN lock')
                  : context.tr('Ubah / hapus kunci PIN', 'Change or remove PIN lock'),
              onPressed: _configurePinDialog,
              icon: Icon(!_hasPin ? MoeslimIcons.bukaKunci : Icons.lock_outline),
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_unlocked
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, size: 36, color: scheme.primary),
                            const SizedBox(height: 10),
                            Text(
                              context.tr('Jurnal Terkunci PIN Lokal', 'Journal Locked with Local PIN'),
                              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              key: const Key('muhasabah-unlock-pin-field'),
                              controller: _pinInputCtrl,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: context.tr('Masukkan PIN Jurnal', 'Enter Journal PIN'),
                                errorText: _pinInvalid ? context.tr('PIN tidak sesuai.', 'Incorrect PIN.') : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              key: const Key('muhasabah-unlock-btn'),
                              onPressed: () async {
                                final ok = await ref.read(journalRepoProvider).verifyPin(_pinInputCtrl.text);
                                setState(() {
                                  if (ok) {
                                    _unlocked = true;
                                    _pinInvalid = false;
                                  } else {
                                    _pinInvalid = true;
                                  }
                                });
                              },
                              icon: const Icon(MoeslimIcons.bukaKunci),
                              label: Text(context.tr('Buka Jurnal', 'Unlock Journal')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: PillTabs(
                        labels: [
                          context.tr('Jurnal Pribadi', 'Private Journal'),
                          context.tr('Muhasabah Malam', 'Nightly Muhasabah'),
                        ],
                        index: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ),
                    Expanded(
                      child: _tab == 0 ? _buildJournalTab(context) : _buildMuhasabahTab(context),
                    ),
                  ],
                ),
    );
  }

  Widget _buildJournalTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final prompt = journalReflectionPrompts[DateTime.now().day % journalReflectionPrompts.length];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        PatternBanner(
          child: Text(
            context.tr(
              'Ruang refleksi 100% lokal dan privat di perangkat Anda. Tidak pernah dibagikan ke ruang Family maupun server Mosque.',
              '100% local and private reflection space on your device. Never shared to Family or Mosque servers.',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ),
        const SizedBox(height: 10),
        if (_showPrompt)
          Card(
            child: ListTile(
              leading: Icon(MoeslimIcons.edit, color: scheme.primary),
              title: Text(context.tr('Prompt Refleksi (Opsional)', 'Optional Reflection Prompt'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              subtitle: Text(context.isEn ? prompt.textEn : prompt.textId),
              trailing: IconButton(
                tooltip: context.tr('Tutup prompt', 'Dismiss prompt'),
                icon: const Icon(MoeslimIcons.tutup, size: 18),
                onPressed: () => setState(() => _showPrompt = false),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final k in const [
                      JournalEntryKind.free,
                      JournalEntryKind.ayah,
                      JournalEntryKind.hadith,
                      JournalEntryKind.kajian,
                    ])
                      ChoiceChip(
                        label: Text(context.isEn ? k.labelEn : k.labelId),
                        selected: _jKind == k,
                        onSelected: (_) {
                          setState(() => _jKind = k);
                          _autosaveDraft();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('journal-title-field'),
                  controller: _jTitleCtrl,
                  onChanged: (_) => _autosaveDraft(),
                  decoration: InputDecoration(
                    labelText: context.tr('Judul (opsional)', 'Title (optional)'),
                  ),
                ),
                if (_jKind != JournalEntryKind.free) ...[
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('journal-source-ref-field'),
                    controller: _jSourceRefCtrl,
                    onChanged: (_) => _autosaveDraft(),
                    decoration: InputDecoration(
                      labelText: switch (_jKind) {
                        JournalEntryKind.ayah => context.tr('Referensi Surah & Ayat (mis. QS. Al-Insyirah: 5-6)', 'Surah & Ayah reference (e.g. QS. 94:5-6)'),
                        JournalEntryKind.hadith => context.tr('Referensi Hadis (mis. HR. Bukhari no. 1)', 'Hadith reference (e.g. Sahih al-Bukhari #1)'),
                        _ => context.tr('Judul Kajian / Masjid Penyelenggara', 'Lecture Title / Host Mosque'),
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _jSourceExcerptCtrl,
                    maxLines: 2,
                    onChanged: (_) => _autosaveDraft(),
                    decoration: InputDecoration(
                      labelText: context.tr('Kutipan teks sumber asli (terpisah dari refleksi)', 'Original source quote (kept separate from reflection)'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  key: const Key('journal-body-field'),
                  controller: _jBodyCtrl,
                  maxLines: 4,
                  onChanged: (_) => _autosaveDraft(),
                  decoration: InputDecoration(
                    labelText: context.tr('Refleksi pribadi Anda (autosave offline)', 'Your personal reflection (offline autosave)'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('journal-tags-field'),
                  controller: _jTagsCtrl,
                  onChanged: (_) => _autosaveDraft(),
                  decoration: InputDecoration(
                    labelText: context.tr('Tag (pisahkan spasi/koma, mis. sabar, kajian)', 'Tags (space/comma separated, e.g. patience, lecture)'),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('journal-save-btn'),
                  onPressed: _saveJournalEntry,
                  icon: const Icon(MoeslimIcons.simpan),
                  label: Text(context.tr('Simpan Catatan Lokal', 'Save Local Entry')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('journal-search-field'),
          controller: _jSearchCtrl,
          decoration: InputDecoration(
            prefixIcon: const Icon(MoeslimIcons.pencarian),
            hintText: context.tr('Cari catatan, tag, atau rujukan (lokal)...', 'Search notes, tags, or references (local)...'),
          ),
          onChanged: (v) {
            _jSearch = v;
            _load();
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(context.tr('Aktif', 'Active')),
              selected: !_showArchived && !_showTrash,
              onSelected: (_) {
                setState(() {
                  _showArchived = false;
                  _showTrash = false;
                });
                _load();
              },
            ),
            ChoiceChip(
              label: Text(context.tr('Arsip', 'Archive')),
              selected: _showArchived && !_showTrash,
              onSelected: (_) {
                setState(() {
                  _showArchived = true;
                  _showTrash = false;
                });
                _load();
              },
            ),
            ChoiceChip(
              label: Text(context.tr('Baru Dihapus', 'Trash')),
              selected: _showTrash,
              onSelected: (_) {
                setState(() {
                  _showTrash = true;
                  _showArchived = false;
                });
                _load();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_journalEntries.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.tr('Belum ada catatan pada tampilan ini.', 'No journal entries in this view.')),
            ),
          )
        else
          for (final e in _journalEntries)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.title.isEmpty ? (context.isEn ? e.kind.labelEn : e.kind.labelId) : e.title,
                            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(context.shortDateText(e.updatedAt.toLocal()), style: t.bodySmall),
                      ],
                    ),
                    if (e.sourceRef != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('Rujukan Asli: ${e.sourceRef}', 'Original Reference: ${e.sourceRef}'),
                              style: t.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                            ),
                            if (e.sourceExcerpt != null) ...[
                              const SizedBox(height: 3),
                              Text(e.sourceExcerpt!, style: t.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(e.body, style: t.bodyMedium),
                    if (e.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [for (final tag in e.tags) Chip(label: Text('#$tag'), visualDensity: VisualDensity.compact)],
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_showTrash) ...[
                          TextButton(
                            onPressed: () async {
                              await ref.read(journalRepoProvider).restoreEntry(e.id);
                              await _load();
                            },
                            child: Text(context.tr('Pulihkan', 'Restore')),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref.read(journalRepoProvider).purgePermanent(e.id);
                              await _load();
                            },
                            child: Text(context.tr('Hapus Permanen', 'Delete Forever')),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () async {
                              await ref.read(journalRepoProvider).setArchived(e.id, !e.isArchived);
                              await _load();
                            },
                            child: Text(e.isArchived ? context.tr('Keluarkan Arsip', 'Unarchive') : context.tr('Arsipkan', 'Archive')),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref.read(journalRepoProvider).softDelete(e.id);
                              await _load();
                            },
                            child: Text(context.tr('Hapus', 'Delete')),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildMuhasabahTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
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
                  context.tr('Tulis Refleksi Hari Ini', 'Write Today\'s Reflection'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _moods)
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(_moodLabel(context, m)),
                        selected: _selectedMood == m,
                        onSelected: (_) => setState(() => _selectedMood = m),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('muhasabah-gratitude-field'),
                  controller: _gratitudeCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      '1. Nikmat Allah yang Disyukuri Hari Ini',
                      '1. Blessings from Allah I Am Grateful for Today',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('muhasabah-eval-field'),
                  controller: _evalCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      '2. Evaluasi Diri & Hal yang Perlu Diperbaiki',
                      '2. Self-Reflection & Areas to Improve',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('muhasabah-hope-field'),
                  controller: _hopeCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      '3. Doa & Tekad Kebaikan Esok Hari',
                      '3. Prayers & Good Intentions for Tomorrow',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('muhasabah-save-btn'),
                  onPressed: _saveMuhasabah,
                  icon: const Icon(MoeslimIcons.berhasil),
                  label: Text(context.tr('Simpan Jurnal Muhasabah', 'Save Muhasabah Entry')),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr('Arsip Muhasabah (${_muhasabahEntries.length})', 'Muhasabah Archive (${_muhasabahEntries.length})'),
        ),
        for (final e in _muhasabahEntries)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${e.dateKey} · ${_moodLabel(context, e.mood)}',
                        style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        tooltip: context.tr('Hapus entri', 'Delete entry'),
                        onPressed: () async {
                          await ref.read(muhasabahRepoProvider).deleteEntry(e.dateKey);
                          await _load();
                        },
                        icon: const Icon(MoeslimIcons.hapus, size: 18),
                      ),
                    ],
                  ),
                  if (e.gratitude.isNotEmpty) Text(context.tr('Syukur: ${e.gratitude}', 'Gratitude: ${e.gratitude}'), style: t.bodyMedium),
                  if (e.evaluation.isNotEmpty) Text(context.tr('Muhasabah: ${e.evaluation}', 'Reflection: ${e.evaluation}'), style: t.bodyMedium),
                  if (e.hopeAndPrayer.isNotEmpty) Text(context.tr('Doa & Tekad: ${e.hopeAndPrayer}', 'Prayer & Resolve: ${e.hopeAndPrayer}'), style: t.bodySmall),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
