import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'quran_source.dart';
import 'surah_page.dart';

const Map<String, ({String title, String timingAndVirtue})> _routineShortcutsEn = {
  'al_kahfi': (
    title: 'Surah Al-Kahf',
    timingAndVirtue: 'Friday Night & Day Sunnah · A light shining between two Fridays (al-Hakim)',
  ),
  'al_mulk': (
    title: 'Surah Al-Mulk (Tabarak)',
    timingAndVirtue: 'Before Sleep Sunnah · Protector from the punishment of the grave (al-Tirmidhi)',
  ),
  'al_waqiah': (
    title: 'Surah Al-Waqi\'ah',
    timingAndVirtue: 'Reminder of the Last Day, gratitude & reliance on Allah for provision',
  ),
  'yasin': (
    title: 'Surah Yasin',
    timingAndVirtue: 'Affirmation of tawhid, prophethood & the resurrection of the Hereafter',
  ),
  'ar_rahman': (
    title: 'Surah Ar-Rahman',
    timingAndVirtue: 'Reflection on the countless blessings and favors of Allah',
  ),
  'ayat_kursi': (
    title: 'Ayat al-Kursi (Al-Baqarah 2:255)',
    timingAndVirtue: 'The greatest verse in the Qur\'an; recited morning, evening, after prayer & before sleep',
  ),
  'akhir_baqarah': (
    title: 'Last 2 Verses of Al-Baqarah (2:285–286)',
    timingAndVirtue: 'Whoever recites them at night, they will suffice them (al-Bukhari & Muslim)',
  ),
};

const Map<int, String> _sajdahExcerptsEn = {
  1: 'Indeed, those who are near your Lord are not prevented by arrogance from His worship, and to Him they prostrate.',
  2: 'And to Allah prostrates whoever is within the heavens and the earth.',
  3: 'They fear their Lord above them, and they do what they are commanded.',
  4: 'And they fall upon their faces weeping, and the Qur\'an increases them in humble submission.',
  5: 'When the verses of the Most Merciful were recited to them, they fell in prostration and weeping.',
  6: 'Do you not see that to Allah prostrates whoever is in the heavens and whoever is on the earth.',
  7: 'O you who have believed, bow and prostrate and worship your Lord.',
  8: 'And when it is said to them, "Prostrate to the Most Merciful," they say, "And what is the Most Merciful?"',
  9: 'Allah, there is no deity except Him, Lord of the Great Throne.',
  10: 'Only those believe in Our verses who, when reminded by them, fall down in prostration.',
  11: 'And David became certain that We had tried him, and he asked forgiveness of his Lord and fell down bowing.',
  12: 'If they are arrogant, those who are near your Lord exalt Him by night and by day.',
  13: 'So prostrate to Allah and worship Him.',
  14: 'And when the Qur\'an is recited to them, they do not prostrate.',
  15: 'No! Do not obey him. But prostrate and draw near to Allah.',
};

const Map<String, String> _vocabMeaningEn = {
  'بسم': 'In the name of',
  'الله': 'Allah (The One God)',
  'الرحمن': 'The Entirely Merciful',
  'الرحيم': 'The Especially Merciful',
  'الحمد': 'All praise',
  'لله': 'Belongs to Allah',
  'رب': 'Lord / Sustainer',
  'العالمين': 'All the worlds',
  'مالك': 'Master / Sovereign',
  'يوم': 'Day',
  'الدين': 'Recompense / Religion',
  'اياك': 'You alone',
  'نعبد': 'We worship',
  'نستعين': 'We seek help',
  'اهدنا': 'Guide us',
  'الصراط': 'The path',
  'المستقيم': 'The straight',
  'قل': 'Say',
  'هو': 'He',
  'احد': 'The One / Unique',
  'الصمد': 'The Eternal Refuge',
  'اعوذ': 'I seek refuge',
  'الفلق': 'The daybreak',
  'الناس': 'Mankind',
  'شر': 'Evil / Harm',
  'خلق': 'He created',
  'الحي': 'The Ever-Living',
  'القيوم': 'The Sustainer of all',
  'السماوات': 'The heavens',
  'الارض': 'The earth',
  'علم': 'Knowledge',
  'الصبر': 'Patience',
  'الصلاة': 'Prayer (Salah)',
  'القلوب': 'The hearts',
  'يسرا': 'Ease',
  'العسر': 'Hardship',
};

typedef _AsbabunNuzulEn = ({
  String title,
  String contextNarrative,
  String source,
  String hikmah,
});

const Map<(int, String), _AsbabunNuzulEn> _asbabunNuzulEn = {
  (2, '144'): (
    title: 'Changing the Qiblah toward Al-Masjid al-Haram',
    contextNarrative:
        'In Madinah, the Prophet (peace be upon him) prayed facing Jerusalem for 16 or 17 months while frequently turning his face toward the sky, hoping for the qiblah to turn toward the Ka\'bah (the qiblah of Prophet Ibrahim). Allah then revealed Al-Baqarah 2:144 commanding him to face Al-Masjid al-Haram.',
    source: 'Sahih al-Bukhari no. 40 & Sahih Muslim no. 525 (Narrated by al-Bara\' ibn \'Azib)',
    hikmah: 'The immediate obedience of the Companions who turned their prayer rows the moment revelation arrived.',
  ),
  (2, '186'): (
    title: 'Allah\'s Nearness in Answering Supplications',
    contextNarrative:
        'A Companion asked the Prophet (peace be upon him): "O Messenger of Allah, is our Lord near so we should whisper our prayers, or far so we should call out loudly?" Allah then revealed: "And when My servants ask you concerning Me, indeed I am near..."',
    source: 'Ibn Jarir al-Tabari & Ibn Abi Hatim · Lubab al-Nuqul by al-Suyuti',
    hikmah: 'Supplicate with a gentle voice, humility, and certainty that Allah hears every call.',
  ),
  (18, '1–26'): (
    title: 'Questions about the Youths of the Cave',
    contextNarrative:
        'The Quraysh sent al-Nadr ibn al-Harith and \'Uqbah ibn Abi Mu\'ayt to the scholars in Madinah, who suggested asking the Prophet three questions: the youths of the past (Ashab al-Kahf), the traveler who reached east and west (Dhul-Qarnayn), and the nature of the soul. After a pause before saying "Insha Allah", Surah Al-Kahf was revealed.',
    source: 'Tafsir Ibn Kathir & Sirah Ibn Hisham',
    hikmah: 'The etiquette of saying "Insha Allah" for future plans and the firm faith of the youths of the Cave.',
  ),
  (49, '6'): (
    title: 'The Command of Tabayyun (Verifying News)',
    contextNarrative:
        'This verse was revealed regarding a zakat envoy who mistakenly assumed Banu al-Mustaliq intended to attack, when they had actually come out to welcome the Prophet\'s messenger. Khalid ibn al-Walid later checked at night and heard them calling the adhan and praying.',
    source: 'Musnad Ahmad IV/279 · Lubab al-Nuqul by al-Suyuti',
    hikmah: 'Always verify facts before acting so you never wrong others and fall into regret.',
  ),
  (80, '1–10'): (
    title: 'Gentle Reminder Regarding Abdullah ibn Umm Maktum',
    contextNarrative:
        'While the Prophet (peace be upon him) was earnestly calling the Quraysh leaders to Islam, the blind Companion Abdullah ibn Umm Maktum came asking to be taught the Qur\'an. The opening of Surah \'Abasa was revealed, honoring sincere seekers of knowledge who come in awe of Allah.',
    source: 'Jami\' al-Tirmidhi no. 3331 & Al-Muwatta\' of Imam Malik',
    hikmah: 'Islam honors every sincere seeker of knowledge regardless of social rank or physical ability.',
  ),
  (93, '1–3'): (
    title: 'Allah\'s Comfort in Surah Ad-Duha',
    contextNarrative:
        'When the Prophet (peace be upon him) fell ill and could not stand for night prayer for two or three nights while revelation paused briefly, some disbelievers taunted that his Lord had forsaken him. Allah revealed Surah Ad-Duha: "Your Lord has not taken leave of you, nor has He detested you."',
    source: 'Sahih al-Bukhari no. 4950 & Sahih Muslim no. 1797 (Narrated by Jundub ibn Sufyan)',
    hikmah: 'During quiet and trying seasons, Allah\'s care and mercy never abandon His servant.',
  ),
  (108, '1–3'): (
    title: 'The Gift of Al-Kawthar',
    contextNarrative:
        'When the Prophet\'s young son passed away, al-\'As ibn Wa\'il mockingly called him "abtar" (cut off with no legacy). Allah revealed Surah Al-Kawthar, granting abundant good in both worlds and declaring that his detractor is the one truly cut off.',
    source: 'Sahih Muslim no. 400 & Ibn Jarir al-Tabari',
    hikmah: 'Respond to mockery with deeper gratitude, sincere prayer to Allah, and sacrifice.',
  ),
  (112, '1–4'): (
    title: 'Pure Monotheism in Surah Al-Ikhlas',
    contextNarrative:
        'The polytheists asked the Prophet (peace be upon him): "O Muhammad, describe the lineage and attributes of your Lord to us!" Allah revealed Surah Al-Ikhlas: "Say, He is Allah, Who is One. Allah, the Eternal Refuge. He neither begets nor is born..."',
    source: 'Jami\' al-Tirmidhi no. 3364 & Musnad Ahmad V/133 (Narrated by Ubayy ibn Ka\'b)',
    hikmah: 'Surah Al-Ikhlas equals one third of the Qur\'an because it distills the pure attributes of Allah.',
  ),
};

List<AnalyzedAyahWord> _analyzeWordsForLang(Ayah ayah, AppLanguage lang) {
  if (lang != AppLanguage.en) return analyzeAyahWordByWord(ayah);

  final rawWords = ayah.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !RegExp(r'^[۝۞۩]+$').hasMatch(w))
      .toList();
  final translationTokens = (ayah.translationFor(AppLanguage.en) ?? '')
      .split(RegExp(r'[,.;]\s*|\s+'))
      .where((t) => t.trim().isNotEmpty)
      .toList();

  final out = <AnalyzedAyahWord>[];
  for (var i = 0; i < rawWords.length; i++) {
    final w = rawWords[i];
    final norm = normalizeArabicWord(w);
    final match = coreQuranVocabulary
        .where((e) => e.normalized == norm || (norm.length >= 3 && norm.contains(e.normalized)))
        .firstOrNull;
    if (match != null) {
      out.add(
        AnalyzedAyahWord(
          position: i + 1,
          arabicWord: w,
          latin: match.latin,
          meaning: _vocabMeaningEn[match.normalized] ?? match.meaning,
          root: match.root,
        ),
      );
    } else {
      final approxMeaning = translationTokens.isEmpty
          ? 'Word in verse ${ayah.number}'
          : translationTokens[(i * translationTokens.length ~/ rawWords.length).clamp(0, translationTokens.length - 1)];
      final rootChars = norm.replaceAll(RegExp(r'^ال|^و|^ف|^ب|^ل'), '').split('').take(3).join(' ');
      out.add(
        AnalyzedAyahWord(
          position: i + 1,
          arabicWord: w,
          latin: 'Word ${i + 1}',
          meaning: approxMeaning,
          root: rootChars.isEmpty ? '-' : rootChars,
        ),
      );
    }
  }
  return out;
}

String _surfaceThemeLabel(BuildContext context, TilawahSurfaceTheme st) {
  if (!context.isEn) return st.label;
  return switch (st) {
    TilawahSurfaceTheme.standard => 'Standard Mushaf',
    TilawahSurfaceTheme.sepiaPaper => 'Warm Sepia Paper',
    TilawahSurfaceTheme.amoledBlack => 'Pure AMOLED Black',
  };
}

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
  int? _selectedWordPosition;

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
        title: Text(context.tr('Pendalaman Al-Qur\'an & Arab', 'Qur\'an & Arabic Study')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('open-focus-tilawah-action'),
            tooltip: context.tr(
              'Mode Fokus Tilawah (Layar Penuh & Sepia/AMOLED)',
              'Focus Reading Mode (Fullscreen & Sepia/AMOLED)',
            ),
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
              labels: [
                context.tr('Pintasan & Sajdah', 'Shortcuts & Sajdah'),
                context.tr('Kata per Kata', 'Word by Word'),
                'Asbabun Nuzul',
                context.tr('Kosakata', 'Vocabulary'),
              ],
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
    final isEn = context.isEn;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: ListTile(
            key: const Key('open-focus-tilawah-card'),
            leading: Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
            title: Text(
              context.tr(
                'Mode Fokus Tilawah (Sepia, AMOLED & Auto-Scroll)',
                'Focus Reading Mode (Sepia, AMOLED & Auto-Scroll)',
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              context.tr(
                'Baca mushaf bebas gangguan dengan tema kertas sepia/AMOLED dan gulir otomatis.',
                'Distraction-free mushaf reading with sepia or AMOLED themes and auto-scroll.',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FocusTilawahPage(initialSurah: _selectedSurah)),
            ),
          ),
        ),
        SectionHeader(context.tr('Pintasan Surah & Ayat Rutin Harian / Jumat', 'Daily & Friday Surah Shortcuts')),
        for (final sc in routineQuranShortcuts)
          Card(
            child: ListTile(
              key: Key('shortcut-${sc.id}'),
              leading: OctagonNumber(sc.surah),
              title: Text(
                isEn ? (_routineShortcutsEn[sc.id]?.title ?? sc.title) : sc.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                isEn ? (_routineShortcutsEn[sc.id]?.timingAndVirtue ?? sc.timingAndVirtue) : sc.timingAndVirtue,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SurahPage(surah: surahs[sc.surah - 1], initialAyah: sc.ayah),
                ),
              ),
            ),
          ),
        SectionHeader(context.tr('Doa Sujud Tilawah & 15 Ayat Sajdah', 'Sujud Tilawah Supplication & 15 Sajdah Verses')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('Bacaan Sujud Tilawah', 'Sujud Tilawah Supplication'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
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
                  context.tr(
                    'Artinya: "Wajahku bersujud kepada Dzat yang menciptakannya, membentuk rupanya, serta membuka pendengaran dan penglihatannya dengan daya dan kekuatan-Nya." (HR. Tirmidzi no. 580)',
                    'Meaning: "My face prostrates to the One who created it, shaped it, and opened its hearing and sight by His might and power." (Narrated by al-Tirmidhi, no. 580)',
                  ),
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
                context.tr(
                  'QS. ${surahs[sv.surah - 1].name} (${sv.surah}): Ayat ${sv.ayah}',
                  'Surah ${surahs[sv.surah - 1].name} (${sv.surah}:${sv.ayah})',
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isEn ? (_sajdahExcerptsEn[sv.number] ?? sv.excerptMeaning) : sv.excerptMeaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
      error: (e, _) => Center(child: Text(context.tr('Gagal memuat ayat: $e', 'Failed to load verse: $e'))),
      data: (ayatList) {
        final ayah = (ayatList != null && safeAyahNum <= ayatList.length)
            ? ayatList[safeAyahNum - 1]
            : const Ayah(
                1,
                1,
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                translation: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
                translationEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
              );
        final words = _analyzeWordsForLang(ayah, context.lang);
        final selectedWord = _selectedWordPosition == null
            ? null
            : words.where((w) => w.position == _selectedWordPosition).firstOrNull;
        final fullTranslation = ayah.translationFor(context.lang);

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
                            _selectedWordPosition = null;
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
                        decoration: InputDecoration(labelText: context.tr('Ayat', 'Verse')),
                        items: [
                          for (var a = 1; a <= maxAyah; a++)
                            DropdownMenuItem(value: a, child: Text(context.tr('Ayat $a', 'Verse $a'))),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedAyah = v;
                            _selectedWordPosition = null;
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
              context.tr(
                'Ketuk kata Arab di bawah untuk melihat arti per kata dan akar katanya:',
                'Tap any Arabic word below to view its word-by-word meaning and root:',
              ),
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
                      onTap: () => setState(() => _selectedWordPosition = w.position),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedWord?.position == w.position
                              ? scheme.primary.withValues(alpha: .16)
                              : scheme.surfaceContainerHighest.withValues(alpha: .4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedWord?.position == w.position ? scheme.primary : scheme.outlineVariant,
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
            if (selectedWord != null) ...[
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
                            context.tr(
                              'Kata ke-${selectedWord.position}: ${selectedWord.latin}',
                              'Word ${selectedWord.position}: ${selectedWord.latin}',
                            ),
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            selectedWord.arabicWord,
                            textDirection: TextDirection.rtl,
                            style: quranTextStyle(fontSize: 26, color: scheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('Arti Kata: ${selectedWord.meaning}', 'Meaning: ${selectedWord.meaning}'),
                        style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        context.tr('Akar Kata (Tsulatsi): ${selectedWord.root}', 'Root Letters: ${selectedWord.root}'),
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if ((fullTranslation ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'Terjemahan Utuh QS. ${surah.name}: $safeAyahNum',
                          'Full Translation of ${surah.name} (${surah.number}:$safeAyahNum)',
                        ),
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(fullTranslation!, style: t.bodyMedium),
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
    final isEn = context.isEn;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: asbabunNuzulCatalog.length,
      itemBuilder: (context, index) {
        final item = asbabunNuzulCatalog[index];
        final en = isEn ? _asbabunNuzulEn[(item.surah, item.ayahRange)] : null;
        final sName = surahs[item.surah - 1].name;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'QS. $sName (${item.surah}): Ayat ${item.ayahRange}',
                    'Surah $sName (${item.surah}:${item.ayahRange})',
                  ),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(en?.title ?? item.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(en?.contextNarrative ?? item.contextNarrative, style: t.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  context.tr('Hikmah: ${item.hikmah}', 'Lesson: ${en?.hikmah ?? item.hikmah}'),
                  style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('Riwayat: ${item.source}', 'Source: ${en?.source ?? item.source}'),
                  style: t.bodySmall,
                ),
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
    final cardMeaning = context.isEn ? (_vocabMeaningEn[card.normalized] ?? card.meaning) : card.meaning;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.tr(
            'Kosakata Dikuasai: ${_masteredWords.length} / ${coreQuranVocabulary.length} kata inti Al-Qur\'an',
            'Words Mastered: ${_masteredWords.length} / ${coreQuranVocabulary.length} core Qur\'an words',
          ),
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
                      cardMeaning,
                      key: const Key('vocab-card-meaning'),
                      textAlign: TextAlign.center,
                      style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(context.tr('Akar Kata: ${card.root}', 'Root: ${card.root}'), style: t.bodySmall),
                  ] else
                    Text(
                      context.tr('Ketuk kartu untuk melihat arti & akar kata', 'Tap card to reveal meaning & root'),
                      style: t.bodySmall,
                    ),
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
              label: Text(context.tr('Sebelumnya', 'Previous')),
            ),
            FilledButton.icon(
              key: const Key('vocab-toggle-mastered'),
              onPressed: () async {
                final next = await ref.read(quranVocabRepoProvider).toggleMastered(card.normalized);
                setState(() => _masteredWords = next);
              },
              icon: Icon(isMastered ? MoeslimIcons.berhasil : Icons.check_circle_outline),
              label: Text(
                isMastered
                    ? context.tr('Sudah Dikuasai', 'Mastered')
                    : context.tr('Tandai Dikuasai', 'Mark Mastered'),
              ),
            ),
            OutlinedButton.icon(
              key: const Key('vocab-next-card'),
              onPressed: () => setState(() {
                _cardIndex = (_cardIndex + 1) % coreQuranVocabulary.length;
                _showCardBack = false;
              }),
              icon: const Icon(Icons.chevron_right),
              label: Text(context.tr('Berikutnya', 'Next')),
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
  const FocusTilawahPage({super.key, this.initialSurah = 1});

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

  void _selectSurah(int number) {
    final target = number.clamp(1, 114);
    if (target == _surahNum) return;
    _timer?.cancel();
    setState(() {
      _surahNum = target;
      _autoScroll = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _openSurahPicker(Color bg, Color fg, Color subFg) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: bg,
      builder: (sheetCtx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final q = query.trim().toLowerCase();
            final filtered = [
              for (final s in surahs)
                if (q.isEmpty ||
                    s.name.toLowerCase().contains(q) ||
                    s.arabicName.contains(q) ||
                    '${s.number}'.contains(q))
                  s,
            ];
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              builder: (_, scrollController) => Column(
                key: const Key('focus-surah-sheet'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ctx.tr('Pilih Surah (114 Surah)', 'Choose Surah (114 Surahs)'),
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          key: const Key('focus-surah-search'),
                          style: TextStyle(color: fg),
                          decoration: InputDecoration(
                            isDense: true,
                            prefixIcon: Icon(MoeslimIcons.pencarian, color: subFg),
                            hintText: ctx.tr(
                              'Cari nama atau nomor surah (1-114)',
                              'Search surah name or number (1-114)',
                            ),
                            hintStyle: TextStyle(color: subFg),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: subFg.withValues(alpha: .4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: fg),
                            ),
                          ),
                          onChanged: (v) => setModalState(() => query = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              ctx.tr('Surah tidak ditemukan.', 'No matching surah found.'),
                              style: TextStyle(color: subFg),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final s = filtered[i];
                              final selected = s.number == _surahNum;
                              return ListTile(
                                key: Key('focus-surah-item-${s.number}'),
                                leading: OctagonNumber(s.number, size: 32),
                                title: Text(
                                  '${s.number}. ${s.name}',
                                  style: TextStyle(
                                    color: fg,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  ctx.tr('${s.ayahCount} ayat', '${s.ayahCount} verses'),
                                  style: TextStyle(color: subFg, fontSize: 12.5),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(s.arabicName, style: quranTextStyle(fontSize: 20, color: fg)),
                                    if (selected) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.check_circle_rounded, color: BrandColors.gold, size: 20),
                                    ],
                                  ],
                                ),
                                selected: selected,
                                selectedTileColor: fg.withValues(alpha: .08),
                                onTap: () {
                                  Navigator.of(sheetCtx).pop();
                                  _selectSurah(s.number);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        title: InkWell(
          key: const Key('focus-surah-picker'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openSurahPicker(bg, fg, subFg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${surah.number}. ${surah.name}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        context.tr(
                          'Fokus Tilawah · ${surah.ayahCount} ayat · 114 Surah',
                          'Focus Reading · ${surah.ayahCount} verses · 114 Surahs',
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: subFg, fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: fg),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            key: const Key('focus-tilawah-autoscroll'),
            tooltip: _autoScroll
                ? context.tr('Jeda gulir otomatis', 'Pause auto-scroll')
                : context.tr('Mulai gulir otomatis', 'Start auto-scroll'),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      key: const Key('focus-surah-chip'),
                      avatar: Icon(MoeslimIcons.daftar, size: 16, color: fg),
                      label: Text(
                        context.tr('Pilih Surah (${surah.number}/114)', 'Surah (${surah.number}/114)'),
                        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: fg.withValues(alpha: .08),
                      side: BorderSide(color: subFg.withValues(alpha: .35)),
                      onPressed: () => _openSurahPicker(bg, fg, subFg),
                    ),
                  ),
                  IconButton(
                    key: const Key('focus-surah-prev'),
                    tooltip: context.tr('Surah sebelumnya', 'Previous surah'),
                    onPressed: _surahNum > 1 ? () => _selectSurah(_surahNum - 1) : null,
                    icon: Icon(Icons.chevron_left_rounded, color: _surahNum > 1 ? fg : subFg.withValues(alpha: .35)),
                  ),
                  IconButton(
                    key: const Key('focus-surah-next'),
                    tooltip: context.tr('Surah berikutnya', 'Next surah'),
                    onPressed: _surahNum < 114 ? () => _selectSurah(_surahNum + 1) : null,
                    icon: Icon(Icons.chevron_right_rounded, color: _surahNum < 114 ? fg : subFg.withValues(alpha: .35)),
                  ),
                  for (final st in TilawahSurfaceTheme.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: Key('focus-theme-${st.name}'),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(_surfaceThemeLabel(context, st)),
                        selected: _surface == st,
                        onSelected: (_) => setState(() => _surface = st),
                      ),
                    ),
                  IconButton(
                    tooltip: context.tr('Perkecil huruf Arab', 'Decrease Arabic font size'),
                    onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(20, 44)),
                    icon: Icon(MoeslimIcons.minusLingkar, color: fg),
                  ),
                  IconButton(
                    key: const Key('focus-font-plus'),
                    tooltip: context.tr('Perbesar huruf Arab', 'Increase Arabic font size'),
                    onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20, 44)),
                    icon: Icon(MoeslimIcons.tambahLingkar, color: fg),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _speedLevel = (_speedLevel % 3) + 1),
                    child: Text(context.tr('Gulir ${_speedLevel}x', 'Scroll ${_speedLevel}x'), style: TextStyle(color: fg)),
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
                      context.tr(
                        'Teks surah belum tersedia di perangkat.',
                        'Surah text is not yet available on this device.',
                      ),
                      style: TextStyle(color: fg),
                    ),
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: ayat.length + 1,
                  separatorBuilder: (_, _) => Divider(color: subFg.withValues(alpha: .25), height: 28),
                  itemBuilder: (context, index) {
                    if (index == ayat.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _surahNum > 1 ? () => _selectSurah(_surahNum - 1) : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                                label: Text(
                                  _surahNum > 1
                                      ? surahs[_surahNum - 2].name
                                      : context.tr('Surah Pertama', 'First Surah'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _surahNum < 114 ? () => _selectSurah(_surahNum + 1) : null,
                                icon: const Icon(Icons.chevron_right_rounded),
                                label: Text(
                                  _surahNum < 114
                                      ? surahs[_surahNum].name
                                      : context.tr('Surah Terakhir', 'Last Surah'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final a = ayat[index];
                    final translation = a.translationFor(context.lang);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${a.text} ﴿${a.number}﴾',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: quranTextStyle(fontSize: _fontSize, color: fg),
                        ),
                        if ((translation ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${a.number}. ${translation!}',
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
