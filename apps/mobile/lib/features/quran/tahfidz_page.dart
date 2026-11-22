import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'quran_source.dart';

String _maskLabel(BuildContext context, TahfidzMaskMode mode) {
  if (!context.isEn) return mode.label;
  return switch (mode) {
    TahfidzMaskMode.fullVisible => 'Full Text',
    TahfidzMaskMode.firstWordsOnly => 'First Words',
    TahfidzMaskMode.hideAlternate => 'Hide Alternate',
    TahfidzMaskMode.blind => 'Fully Hidden',
  };
}

String _maskDescription(BuildContext context, TahfidzMaskMode mode) {
  if (!context.isEn) return mode.description;
  return switch (mode) {
    TahfidzMaskMode.fullVisible => 'All Arabic words are shown to start memorizing.',
    TahfidzMaskMode.firstWordsOnly => 'Only the first 2 words are shown as a memory cue.',
    TahfidzMaskMode.hideAlternate => 'Hides every other word to practice verse recall.',
    TahfidzMaskMode.blind => 'All Arabic text is hidden; tap a card to peek at the verse.',
  };
}

String _hafalanStatusLabel(BuildContext context, SurahHafalanStatus status) {
  if (!context.isEn) return status.label;
  return switch (status) {
    SurahHafalanStatus.belum => 'Not Started',
    SurahHafalanStatus.menghafal => 'In Progress',
    SurahHafalanStatus.lancar => 'Memorized',
    SurahHafalanStatus.murajaah => 'Needs Review',
  };
}

class TahfidzPage extends ConsumerStatefulWidget {
  final int initialSurah;
  const TahfidzPage({super.key, this.initialSurah = 112});

  @override
  ConsumerState<TahfidzPage> createState() => _TahfidzPageState();
}

class _TahfidzPageState extends ConsumerState<TahfidzPage> {
  int _tab = 0;
  late int _selectedSurah;
  TahfidzMaskMode _maskMode = TahfidzMaskMode.firstWordsOnly;
  final Set<int> _revealedAyahs = {};
  final Map<int, int> _ayahRepeatCounter = {};
  Map<int, SurahTahfidzEntry> _entries = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedSurah = widget.initialSurah.clamp(1, 114);
    _load();
  }

  Future<void> _load() async {
    final entries = await ref.read(tahfidzRepoProvider).allEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _markAyahMemorized(int surah, int ayahNumber) async {
    final current = _entries[surah]?.memorizedAyahs ?? 0;
    final nextCount = ayahNumber > current ? ayahNumber : current;
    await ref.read(tahfidzRepoProvider).updateMemorized(surah: surah, memorizedAyahs: nextCount);
    await _load();
  }

  Future<void> _markSurahFull(int surah) async {
    final max = surahs[surah - 1].ayahCount;
    await ref.read(tahfidzRepoProvider).updateMemorized(
          surah: surah,
          memorizedAyahs: max,
          status: SurahHafalanStatus.lancar,
        );
    await _load();
  }

  Future<void> _markMurajaah(int surah) async {
    await ref.read(tahfidzRepoProvider).markMurajaahDone(surah);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Tahfidz & Muraja\'ah', 'Memorization & Review')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Latihan Hafalan', 'Practice'),
                context.tr('Progres Surah', 'Surah Progress'),
                context.tr('Muraja\'ah', 'Review'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : switch (_tab) {
                    0 => _buildPracticeTab(context),
                    1 => _buildProgressTab(context),
                    _ => _buildMurajaahTab(context),
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeTab(BuildContext context) {
    final surah = surahs[_selectedSurah - 1];
    final surahAsync = ref.watch(surahTextProvider(_selectedSurah));
    final entry = _entries[_selectedSurah] ?? SurahTahfidzEntry(surah: _selectedSurah);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          key: const Key('tahfidz-surah-dropdown'),
                          initialValue: _selectedSurah,
                          decoration: InputDecoration(
                            labelText: context.tr('Pilih Surah Latihan', 'Select Surah to Practice'),
                            isDense: true,
                          ),
                          items: [
                            for (final s in surahs)
                              DropdownMenuItem(
                                value: s.number,
                                child: Text(
                                  context.tr(
                                    '${s.number}. ${s.name} (${s.ayahCount} ayat)',
                                    '${s.number}. ${s.name} (${s.ayahCount} verses)',
                                  ),
                                ),
                              ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedSurah = v;
                              _revealedAyahs.clear();
                              _ayahRepeatCounter.clear();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        key: const Key('tahfidz-mark-surah-done'),
                        onPressed: () => _markSurahFull(_selectedSurah),
                        child: Text(context.tr('Hafal Penuh', 'Mark Full')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final mode in TahfidzMaskMode.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              key: Key('mask-${mode.name}'),
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              label: Text(_maskLabel(context, mode)),
                              selected: _maskMode == mode,
                              onSelected: (_) => setState(() {
                                _maskMode = mode;
                                _revealedAyahs.clear();
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr(
                      'Progres ${surah.name}: ${entry.memorizedAyahs} / ${surah.ayahCount} ayat dihafal · ${_maskMode.description}',
                      '${surah.name} progress: ${entry.memorizedAyahs} / ${surah.ayahCount} verses memorized · ${_maskDescription(context, _maskMode)}',
                    ),
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: surahAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(context.tr('Gagal memuat teks surah: $e', 'Failed to load surah text: $e')),
            ),
            data: (ayat) {
              if (ayat == null || ayat.isEmpty) {
                return Center(
                  child: Text(
                    context.tr(
                      'Teks surah belum tersedia di perangkat.',
                      'Surah text is not yet available on this device.',
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: ayat.length,
                itemBuilder: (context, index) {
                  final a = ayat[index];
                  final isRevealed = _revealedAyahs.contains(a.number);
                  final maskedText = maskArabicForTahfidz(a.text, _maskMode, revealed: isRevealed);
                  final repeats = _ayahRepeatCounter[a.number] ?? 0;
                  final isMemorized = a.number <= entry.memorizedAyahs;
                  final translation = a.translationFor(context.lang);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() {
                        if (isRevealed) {
                          _revealedAyahs.remove(a.number);
                        } else {
                          _revealedAyahs.add(a.number);
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                OctagonNumber(a.number),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isMemorized
                                        ? context.tr('Sudah dihafal', 'Memorized')
                                        : context.tr(
                                            'Ketuk kartu untuk buka/tutup ayat',
                                            'Tap card to show/hide verse',
                                          ),
                                    style: t.bodySmall?.copyWith(
                                      color: isMemorized ? scheme.primary : null,
                                      fontWeight: isMemorized ? FontWeight.w700 : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton.icon(
                                  key: Key('repeat-ayah-${a.number}'),
                                  onPressed: () => setState(() => _ayahRepeatCounter[a.number] = repeats + 1),
                                  icon: const Icon(MoeslimIcons.ulang, size: 16),
                                  label: Text(context.tr('Ulang ${repeats}x', 'Repeat ${repeats}x')),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  key: Key('memorize-ayah-${a.number}'),
                                  tooltip: context.tr(
                                    'Tandai hafal sampai ayat ${a.number}',
                                    'Mark memorized up to verse ${a.number}',
                                  ),
                                  onPressed: () => _markAyahMemorized(_selectedSurah, a.number),
                                  icon: Icon(
                                    isMemorized ? MoeslimIcons.berhasil : Icons.check_circle_outline,
                                    color: isMemorized ? scheme.primary : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              maskedText,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: quranTextStyle(fontSize: 26),
                            ),
                            if ((translation ?? '').isNotEmpty &&
                                (_maskMode == TahfidzMaskMode.fullVisible || isRevealed)) ...[
                              const SizedBox(height: 8),
                              Text(translation!, style: t.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTab(BuildContext context) {
    final totalMemorizedAyahs = _entries.values.fold<int>(0, (s, e) => s + e.memorizedAyahs);
    final completedSurahs = _entries.values.where((e) => e.memorizedAyahs >= e.surahMeta.ayahCount).length;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Show Juz 30 first (78..114) then the rest
    final orderedSurahs = [
      ...surahs.where((s) => s.number >= 78),
      ...surahs.where((s) => s.number < 78),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: orderedSurahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(MoeslimIcons.pencapaian, size: 36, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('Ringkasan Hafalan Al-Qur\'an', 'Qur\'an Memorization Summary'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          context.tr(
                            '$completedSurahs surah tuntas · $totalMemorizedAyahs / 6.236 ayat dihafal',
                            '$completedSurahs surahs completed · $totalMemorizedAyahs / 6,236 verses memorized',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final s = orderedSurahs[index - 1];
        final e = _entries[s.number] ?? SurahTahfidzEntry(surah: s.number);
        return Card(
          child: ListTile(
            leading: OctagonNumber(s.number),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    '${e.memorizedAyahs} / ${s.ayahCount} ayat · ${e.status.label}',
                    '${e.memorizedAyahs} / ${s.ayahCount} verses · ${_hafalanStatusLabel(context, e.status)}',
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: e.ratio, minHeight: 6, borderRadius: BorderRadius.circular(3)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() {
              _selectedSurah = s.number;
              _tab = 0;
            }),
          ),
        );
      },
    );
  }

  Widget _buildMurajaahTab(BuildContext context) {
    final now = DateTime.now();
    final memorizedList = _entries.values.where((e) => e.memorizedAyahs > 0).toList()
      ..sort((a, b) => a.surah.compareTo(b.surah));
    final t = Theme.of(context).textTheme;

    if (memorizedList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MoeslimIcons.quranTerbuka, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                context.tr('Belum ada jadwal muraja\'ah', 'No review schedule yet'),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  'Tandai minimal satu surah atau ayat yang sudah dihafal di tab Latihan Hafalan agar jadwal muraja\'ah berkala muncul di sini.',
                  'Mark at least one memorized surah or verse in the Practice tab so your periodic review schedule appears here.',
                ),
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _tab = 0),
                icon: const Icon(MoeslimIcons.play),
                label: Text(context.tr('Mulai Latihan Hafalan', 'Start Memorization Practice')),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: memorizedList.length,
      itemBuilder: (context, index) {
        final e = memorizedList[index];
        final due = e.isDueForMurajaah(now);
        return Card(
          child: ListTile(
            leading: OctagonNumber(e.surah),
            title: Text(e.surahMeta.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              due
                  ? context.tr(
                      'Waktunya muraja\'ah (${e.memorizedAyahs} ayat)',
                      'Due for review (${e.memorizedAyahs} verses)',
                    )
                  : context.tr(
                      'Sudah dimuraja\'ah (${e.memorizedAyahs} ayat)',
                      'Reviewed (${e.memorizedAyahs} verses)',
                    ),
            ),
            trailing: FilledButton.tonalIcon(
              key: Key('murajaah-done-${e.surah}'),
              onPressed: () => _markMurajaah(e.surah),
              icon: const Icon(MoeslimIcons.berhasil, size: 18),
              label: Text(context.tr('Selesai', 'Done')),
            ),
            onTap: () => setState(() {
              _selectedSurah = e.surah;
              _tab = 0;
            }),
          ),
        );
      },
    );
  }
}
