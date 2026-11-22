import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

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
  String? _pinError;
  bool _loading = true;

  static const _moods = [
    'Tenang & Bersyukur',
    'Bersemangat Taat',
    'Perlu Muhasabah',
    'Memohon Kekuatan',
  ];

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
        title: const Text('Kunci PIN Jurnal Muhasabah'),
        content: TextField(
          key: const Key('muhasabah-set-pin-field'),
          controller: ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'PIN Baru (kosongkan untuk matikan kunci)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
          FilledButton(
            key: const Key('muhasabah-save-pin-btn'),
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: const Text('Simpan'),
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
        title: const Text('Jurnal Muhasabah & Syukur'),
        centerTitle: true,
        actions: [
          if (_unlocked)
            IconButton(
              key: const Key('muhasabah-pin-config-btn'),
              tooltip: _savedPin == null ? 'Pasang kunci PIN lokal' : 'Ubah / hapus kunci PIN',
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
                            Text('Jurnal Terkunci PIN Lokal', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TextField(
                              key: const Key('muhasabah-unlock-pin-field'),
                              controller: _pinInputCtrl,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Masukkan PIN Jurnal',
                                errorText: _pinError,
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
                                    _pinError = null;
                                  } else {
                                    _pinError = 'PIN tidak sesuai.';
                                  }
                                });
                              },
                              icon: const Icon(MoeslimIcons.bukaKunci),
                              label: const Text('Buka Jurnal'),
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
                    const PatternBanner(
                      child: Text(
                        '"Hisablah (evaluasilah) diri kalian sebelum kalian dihisab." Ruang refleksi malam ini tersimpan 100% lokal di perangkat Anda.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Tulis Refleksi Hari Ini', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final m in _moods)
                                  ChoiceChip(
                                    materialTapTargetSize: MaterialTapTargetSize.padded,
                                    label: Text(m),
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
                              decoration: const InputDecoration(
                                labelText: '1. Nikmat Allah yang Disyukuri Hari Ini',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              key: const Key('muhasabah-eval-field'),
                              controller: _evalCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: '2. Evaluasi Diri & Hal yang Perlu Diperbaiki',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              key: const Key('muhasabah-hope-field'),
                              controller: _hopeCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: '3. Doa & Tekad Kebaikan Esok Hari',
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              key: const Key('muhasabah-save-btn'),
                              onPressed: _saveJournal,
                              icon: const Icon(MoeslimIcons.berhasil),
                              label: const Text('Simpan Jurnal Muhasabah'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SectionHeader('Arsip Muhasabah (${_entries.length})'),
                    if (_entries.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Belum ada catatan muhasabah. Luangkan 2 menit sebelum tidur untuk mencatat syukur dan evaluasi diri.'),
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
                                    Text('${e.dateKey} · ${e.mood}', style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                                    IconButton(
                                      tooltip: 'Hapus entri',
                                      onPressed: () async {
                                        await ref.read(muhasabahRepoProvider).deleteEntry(e.dateKey);
                                        await _load();
                                      },
                                      icon: const Icon(MoeslimIcons.hapus, size: 18),
                                    ),
                                  ],
                                ),
                                if (e.gratitude.isNotEmpty) Text('Syukur: ${e.gratitude}', style: t.bodyMedium),
                                if (e.evaluation.isNotEmpty) Text('Muhasabah: ${e.evaluation}', style: t.bodyMedium),
                                if (e.hopeAndPrayer.isNotEmpty) Text('Doa & Tekad: ${e.hopeAndPrayer}', style: t.bodySmall),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
    );
  }
}
