import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class MuhasabahJournalPage extends ConsumerStatefulWidget {
  const MuhasabahJournalPage({super.key});

  @override
  ConsumerState<MuhasabahJournalPage> createState() => _MuhasabahJournalPageState();
}

class _MuhasabahJournalPageState extends ConsumerState<MuhasabahJournalPage> {
  final _gratitudeCtrl = TextEditingController();
  final _evalCtrl = TextEditingController();
  final _hopeCtrl = TextEditingController();
  final _pinInputCtrl = TextEditingController();

  String _selectedMood = 'Tenang & Bersyukur';
  List<MuhasabahEntry> _entries = const [];
  String? _savedPin;
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
    _load();
  }

  @override
  void dispose() {
    _gratitudeCtrl.dispose();
    _evalCtrl.dispose();
    _hopeCtrl.dispose();
    _pinInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(muhasabahRepoProvider);
    final pin = await repo.savedPin();
    final entries = await repo.allEntries();
    if (mounted) {
      setState(() {
        _savedPin = pin;
        _unlocked = pin == null ? true : _unlocked;
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _saveJournal() async {
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
    final ctrl = TextEditingController(text: _savedPin ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(dialogCtx.tr('Kunci PIN Jurnal Muhasabah', 'Muhasabah Journal PIN Lock')),
        content: TextField(
          key: const Key('muhasabah-set-pin-field'),
          controller: ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: InputDecoration(
            labelText: dialogCtx.tr('PIN Baru (kosongkan untuk matikan kunci)', 'New PIN (leave blank to disable lock)'),
          ),
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
      await ref.read(muhasabahRepoProvider).setPin(result.isEmpty ? null : result);
      setState(() => _unlocked = true);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Jurnal Muhasabah & Syukur', 'Muhasabah & Gratitude Journal')),
        centerTitle: true,
        actions: [
          if (_unlocked)
            IconButton(
              key: const Key('muhasabah-pin-config-btn'),
              tooltip: _savedPin == null
                  ? context.tr('Pasang kunci PIN lokal', 'Set local PIN lock')
                  : context.tr('Ubah / hapus kunci PIN', 'Change or remove PIN lock'),
              onPressed: _configurePinDialog,
              icon: Icon(_savedPin == null ? MoeslimIcons.bukaKunci : Icons.lock_outline),
            ),
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
                                final ok = await ref.read(muhasabahRepoProvider).verifyPin(_pinInputCtrl.text);
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
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PatternBanner(
                      child: Text(
                        context.tr(
                          '"Hisablah (evaluasilah) diri kalian sebelum kalian dihisab." Ruang refleksi malam ini tersimpan 100% lokal di perangkat Anda.',
                          '"Hold yourselves to account before you are held to account." This nightly reflection space is stored 100% locally on your device.',
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                              onPressed: _saveJournal,
                              icon: const Icon(MoeslimIcons.berhasil),
                              label: Text(context.tr('Simpan Jurnal Muhasabah', 'Save Muhasabah Entry')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SectionHeader(
                      context.tr(
                        'Arsip Muhasabah (${_entries.length})',
                        'Muhasabah Archive (${_entries.length})',
                      ),
                    ),
                    if (_entries.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            context.tr(
                              'Belum ada catatan muhasabah. Luangkan 2 menit sebelum tidur untuk mencatat syukur dan evaluasi diri.',
                              'No reflection entries yet. Take 2 minutes before sleep to record your gratitude and self-evaluation.',
                            ),
                          ),
                        ),
                      )
                    else
                      for (final e in _entries)
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
                                if (e.gratitude.isNotEmpty)
                                  Text(context.tr('Syukur: ${e.gratitude}', 'Gratitude: ${e.gratitude}'), style: t.bodyMedium),
                                if (e.evaluation.isNotEmpty)
                                  Text(context.tr('Muhasabah: ${e.evaluation}', 'Reflection: ${e.evaluation}'), style: t.bodyMedium),
                                if (e.hopeAndPrayer.isNotEmpty)
                                  Text(context.tr('Doa & Tekad: ${e.hopeAndPrayer}', 'Prayer & Resolve: ${e.hopeAndPrayer}'), style: t.bodySmall),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
    );
  }
}
