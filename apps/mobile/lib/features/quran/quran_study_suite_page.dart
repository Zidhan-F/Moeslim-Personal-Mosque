import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import 'quran_source.dart';
import 'surah_page.dart';

class QuranStudySuitePage extends ConsumerStatefulWidget {
  final int initialTab;
  final int initialSurah;
  final int initialAyah;

  const QuranStudySuitePage({
    super.key,
    this.initialTab = 0,
    this.initialSurah = 1,
    this.initialAyah = 1,
  });

  @override
  ConsumerState<QuranStudySuitePage> createState() => _QuranStudySuitePageState();
}

class _QuranStudySuitePageState extends ConsumerState<QuranStudySuitePage> {
  late int _tab;
  late int _selectedSurah;
  late int _selectedAyah;
  AnalyzedAyahWord? _selectedWord;

  // Flashcard state
  int _cardIndex = 0;
  bool _showCardBack = false;
  Set<String> _masteredWords = {};

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 3);
    _selectedSurah = widget.initialSurah.clamp(1, 114);
    _selectedAyah = widget.initialAyah;
    _loadVocab();
  }

  Future<void> _loadVocab() async {
    final m = await ref.read(quranVocabRepoProvider).masteredWords();
    if (mounted) setState(() => _masteredWords = m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendalaman Al-Qur\'an & Arab'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('open-focus-tilawah-action'),
            tooltip: 'Mode Fokus Tilawah (Layar Penuh & Sepia/AMOLED)',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FocusTilawahPage(initialSurah: _selectedSurah)),
            ),
            icon: const Icon(MoeslimIcons.quranTerbuka),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Pintasan & Sajdah', 'Kata per Kata', 'Asbabun Nuzul', 'Kosakata'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildShortcutsAndSajdahTab(context),
              1 => _buildWordByWordTab(context),
              2 => _buildAsbabunNuzulTab(context),
              _ => _buildFlashcardsTab(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsAndSajdahTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: ListTile(
            key: const Key('open-focus-tilawah-card'),
            leading: Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
            title: const Text('Mode Fokus Tilawah (Sepia, AMOLED & Auto-Scroll)', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Baca mushaf bebas gangguan dengan tema kertas sepia/AMOLED dan gulir otomatis.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FocusTilawahPage(initialSurah: _selectedSurah)),
            ),
          ),
        ),
        const SectionHeader('Pintasan Surah & Ayat Rutin Harian / Jumat'),
        for (final sc in routineQuranShortcuts)
          Card(
            child: ListTile(
              key: Key('shortcut-${sc.id}'),
              leading: OctagonNumber(sc.surah),
              title: Text(sc.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(sc.timingAndVirtue),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SurahPage(surah: surahs[sc.surah - 1], initialAyah: sc.ayah),
                ),
              ),
            ),
          ),
        const SectionHeader('Doa Sujud Tilawah & 15 Ayat Sajdah'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Bacaan Sujud Tilawah', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'سَجَدَ وَجْهِيَ لِلَّذِي خَلَقَهُ وَصَوَّرَهُ وَشَقَّ سَمْعَهُ وَبَصَرَهُ بِحَوْلِهِ وَقُوَّتِهِ',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sajada wajhiya lilladzi khalaqahu wa shawwarahu wa syaqqa sam\'ahu wa basharahu bihawlihi wa quwwatih.',
                  style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  'Artinya: "Wajahku bersujud kepada Dzat yang menciptakannya, membentuk rupanya, serta membuka pendengaran dan penglihatannya dengan daya dan kekuatan-Nya." (HR. Tirmidzi no. 580)',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        for (final sv in sajdahVersesCatalog)
          Card(
            child: ListTile(
              leading: OctagonNumber(sv.number),
              title: Text(
                'QS. ${surahs[sv.surah - 1].name} (${sv.surah}): Ayat ${sv.ayah}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(sv.excerptMeaning, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SurahPage(surah: surahs[sv.surah - 1], initialAyah: sv.ayah),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWordByWordTab(BuildContext context) {
    final surah = surahs[_selectedSurah - 1];
    final maxAyah = surah.ayahCount;
    final safeAyahNum = _selectedAyah.clamp(1, maxAyah);
    final surahAsync = ref.watch(surahTextProvider(_selectedSurah));
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return surahAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat ayat: $e')),
      data: (ayatList) {
        final ayah = (ayatList != null && safeAyahNum <= ayatList.length)
            ? ayatList[safeAyahNum - 1]
            : const Ayah(1, 1, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', translation: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.');
        final words = analyzeAyahWordByWord(ayah);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedSurah,
                        isDense: true,
                        decoration: const InputDecoration(labelText: 'Surah'),
                        items: [
                          for (final s in surahs)
                            DropdownMenuItem(value: s.number, child: Text('${s.number}. ${s.name}')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedSurah = v;
                            _selectedAyah = 1;
                            _selectedWord = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: safeAyahNum,
                        isDense: true,
                        decoration: const InputDecoration(labelText: 'Ayat'),
                        items: [
                          for (var a = 1; a <= maxAyah; a++)
                            DropdownMenuItem(value: a, child: Text('Ayat $a')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedAyah = v;
                            _selectedWord = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk kata Arab di bawah untuk melihat arti per kata dan akar katanya:',
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final w in words)
                    InkWell(
                      key: Key('wbw-word-${w.position}'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedWord = w),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedWord?.position == w.position
                              ? scheme.primary.withValues(alpha: .16)
                              : scheme.surfaceContainerHighest.withValues(alpha: .4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedWord?.position == w.position ? scheme.primary : scheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(w.arabicWord, style: quranTextStyle(fontSize: 24, color: scheme.primary)),
                            Text(
                              w.meaning,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedWord != null) ...[
              const SizedBox(height: 12),
              Card(
                key: const Key('wbw-selected-detail'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kata ke-${_selectedWord!.position}: ${_selectedWord!.latin}',
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _selectedWord!.arabicWord,
                            textDirection: TextDirection.rtl,
                            style: quranTextStyle(fontSize: 26, color: scheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Arti Kata: ${_selectedWord!.meaning}', style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      Text('Akar Kata (Tsulatsi): ${_selectedWord!.root}', style: t.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
            if ((ayah.translation ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Terjemahan Utuh QS. ${surah.name}: $safeAyahNum', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(ayah.translation!, style: t.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAsbabunNuzulTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: asbabunNuzulCatalog.length,
      itemBuilder: (context, index) {
        final item = asbabunNuzulCatalog[index];
        final sName = surahs[item.surah - 1].name;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QS. $sName (${item.surah}): Ayat ${item.ayahRange}',
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(item.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(item.contextNarrative, style: t.bodyMedium),
                const SizedBox(height: 8),
                Text('Hikmah: ${item.hikmah}', style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Riwayat: ${item.source}', style: t.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlashcardsTab(BuildContext context) {
    final card = coreQuranVocabulary[_cardIndex % coreQuranVocabulary.length];
    final isMastered = _masteredWords.contains(card.normalized);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Kosakata Dikuasai: ${_masteredWords.length} / ${coreQuranVocabulary.length} kata inti Al-Qur\'an',
          key: const Key('vocab-mastered-count'),
          textAlign: TextAlign.center,
          style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Card(
          child: InkWell(
            key: const Key('vocab-flashcard'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _showCardBack = !_showCardBack),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Text(
                    card.arabic,
                    textDirection: TextDirection.rtl,
                    style: quranTextStyle(fontSize: 44, color: scheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(card.latin, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (_showCardBack) ...[
                    const Divider(),
                    Text(
                      card.meaning,
                      key: const Key('vocab-card-meaning'),
                      textAlign: TextAlign.center,
                      style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text('Akar Kata: ${card.root}', style: t.bodySmall),
                  ] else
                    Text('Ketuk kartu untuk melihat arti & akar kata', style: t.bodySmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _cardIndex = (_cardIndex - 1 + coreQuranVocabulary.length) % coreQuranVocabulary.length;
                _showCardBack = false;
              }),
              icon: const Icon(Icons.chevron_left),
              label: const Text('Sebelumnya'),
            ),
            FilledButton.icon(
              key: const Key('vocab-toggle-mastered'),
              onPressed: () async {
                final next = await ref.read(quranVocabRepoProvider).toggleMastered(card.normalized);
                setState(() => _masteredWords = next);
              },
              icon: Icon(isMastered ? MoeslimIcons.berhasil : Icons.check_circle_outline),
              label: Text(isMastered ? 'Sudah Dikuasai' : 'Tandai Dikuasai'),
            ),
            OutlinedButton.icon(
              key: const Key('vocab-next-card'),
              onPressed: () => setState(() {
                _cardIndex = (_cardIndex + 1) % coreQuranVocabulary.length;
                _showCardBack = false;
              }),
              icon: const Icon(Icons.chevron_right),
              label: const Text('Berikutnya'),
            ),
          ],
        ),
      ],
    );
  }
}

// ================= 24. MODE FOKUS TILAWAH =================

class FocusTilawahPage extends ConsumerStatefulWidget {
  final int initialSurah;
  const FocusTilawahPage({super.key, this.initialSurah = 18});

  @override
  ConsumerState<FocusTilawahPage> createState() => _FocusTilawahPageState();
}

class _FocusTilawahPageState extends ConsumerState<FocusTilawahPage> {
  final _scrollController = ScrollController();
  late int _surahNum;
  TilawahSurfaceTheme _surface = TilawahSurfaceTheme.sepiaPaper;
  double _fontSize = 28;
  bool _autoScroll = false;
  int _speedLevel = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _surahNum = widget.initialSurah.clamp(1, 114);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    _timer?.cancel();
    if (_autoScroll) {
      _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!_scrollController.hasClients) return;
        final max = _scrollController.position.maxScrollExtent;
        final next = _scrollController.offset + (_speedLevel * 1.2);
        if (next >= max) {
          _timer?.cancel();
          if (mounted) setState(() => _autoScroll = false);
        } else {
          _scrollController.jumpTo(next);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final surah = surahs[_surahNum - 1];
    final textAsync = ref.watch(surahTextProvider(_surahNum));

    final (bg, fg, subFg) = switch (_surface) {
      TilawahSurfaceTheme.standard => (BrandColors.cream, BrandColors.deep, BrandColors.textMuted),
      TilawahSurfaceTheme.sepiaPaper => (const Color(0xFFF4ECD8), const Color(0xFF2C221E), const Color(0xFF5C4B43)),
      TilawahSurfaceTheme.amoledBlack => (Colors.black, const Color(0xFFE8E6DF), const Color(0xFFA5B5B0)),
    };

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        title: Text('Fokus Tilawah: ${surah.name}'),
        actions: [
          IconButton(
            key: const Key('focus-tilawah-autoscroll'),
            tooltip: _autoScroll ? 'Jeda gulir otomatis' : 'Mulai gulir otomatis',
            onPressed: _toggleAutoScroll,
            icon: Icon(_autoScroll ? Icons.pause_circle_filled : MoeslimIcons.play),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: bg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final st in TilawahSurfaceTheme.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: Key('focus-theme-${st.name}'),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(st.label),
                        selected: _surface == st,
                        onSelected: (_) => setState(() => _surface = st),
                      ),
                    ),
                  IconButton(
                    tooltip: 'Perkecil huruf Arab',
                    onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(20, 44)),
                    icon: Icon(MoeslimIcons.minusLingkar, color: fg),
                  ),
                  IconButton(
                    key: const Key('focus-font-plus'),
                    tooltip: 'Perbesar huruf Arab',
                    onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20, 44)),
                    icon: Icon(MoeslimIcons.tambahLingkar, color: fg),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _speedLevel = (_speedLevel % 3) + 1),
                    child: Text('Gulir ${_speedLevel}x', style: TextStyle(color: fg)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: textAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e', style: TextStyle(color: fg))),
              data: (ayat) {
                if (ayat == null || ayat.isEmpty) {
                  return Center(
                    child: Text(
                      'Teks surah belum tersedia di perangkat.',
                      style: TextStyle(color: fg),
                    ),
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: ayat.length,
                  separatorBuilder: (_, _) => Divider(color: subFg.withValues(alpha: .25), height: 28),
                  itemBuilder: (context, index) {
                    final a = ayat[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${a.text} ﴿${a.number}﴾',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: quranTextStyle(fontSize: _fontSize, color: fg),
                        ),
                        if ((a.translation ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${a.number}. ${a.translation!}',
                            style: TextStyle(color: subFg, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
