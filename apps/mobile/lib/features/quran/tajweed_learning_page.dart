import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'tajweed_view.dart';

typedef _LessonEn = ({
  String title,
  String triggerLetters,
  String howToRead,
  String exampleSurahRef,
  String exampleExplanation,
});

const Map<TajweedRule, _LessonEn> _tajweedLessonsEn = {
  TajweedRule.ghunnah: (
    title: 'Ghunnah Mushaddadah (Doubled Noon & Meem)',
    triggerLetters: 'نّ ، مّ',
    howToRead: 'Hold a clear nasal resonance through the nasal passage (Al-Khayshum) for 2 counts.',
    exampleSurahRef: 'Surah Al-Kawthar (108:1)',
    exampleExplanation: 'The doubled Noon in إِنَّا must be held with nasal resonance for 2 counts.',
  ),
  TajweedRule.idghamBighunnah: (
    title: 'Idgham bi-Ghunnah (Merging with Nasalization)',
    triggerLetters: 'ي ن م و (Yanmu)',
    howToRead: 'Merge noon sakinah or tanween into any of ي ن م و with a 2-count nasal resonance.',
    exampleSurahRef: 'Surah Az-Zalzalah (99:7)',
    exampleExplanation: 'Noon sakinah in فَمَنْ before ي, and tanween in خَيْرًا before ي, merge smoothly with nasalization.',
  ),
  TajweedRule.idghamBilaghunnah: (
    title: 'Idgham bila-Ghunnah (Merging without Nasalization)',
    triggerLetters: 'ل ، ر',
    howToRead: 'Merge noon sakinah or tanween completely into Lam or Ra without holding any nasal sound.',
    exampleSurahRef: 'Surah Al-Humazah (104:1)',
    exampleExplanation: 'Tanween in وَيْلٌ before ل and هُمَزَةٍ before ل merge directly without nasalization.',
  ),
  TajweedRule.iqlab: (
    title: 'Iqlab (Changing Noon Sakinah / Tanween to Meem)',
    triggerLetters: 'ب',
    howToRead: 'Convert noon sakinah or tanween into a soft Meem sound before Ba, held with 2 counts of nasalization.',
    exampleSurahRef: 'Surah Al-Humazah (104:4)',
    exampleExplanation: 'Noon sakinah preceding ب in لَيُنْبَذَنَّ is pronounced as a nasalized Meem sound.',
  ),
  TajweedRule.ikhfa: (
    title: 'Ikhfa Haqiqi & Ikhfa Shafawi (Concealed Nasalization)',
    triggerLetters: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك (and مْ before ب)',
    howToRead: 'Recite softly between clear pronunciation (Izhar) and full merging (Idgham) with 2 counts of nasalization toward the next letter.',
    exampleSurahRef: 'Surah An-Nas (114:4)',
    exampleExplanation: 'Noon sakinah in مِنْ before ش is concealed with a 2-count nasal sound (Ikhfa Haqiqi).',
  ),
  TajweedRule.qalqalah: (
    title: 'Qalqalah (Echoing Bounce on Sukoon)',
    triggerLetters: 'ق ط ب ج د (Qutbu Jaddin)',
    howToRead: 'Produce an echoing bounce on these letters when carrying an original sukoon mid-word (Qalqalah Sughra) or when stopping at the end of a verse (Qalqalah Kubra).',
    exampleSurahRef: 'Surah Al-Ikhlas (112:1–3)',
    exampleExplanation: 'The letter د at the end of verses (أَحَدٌ، الصَّمَدُ، يُولَدْ) bounces strongly (Kubra), while يَلِدْ mid-recitation bounces lightly (Sughra).',
  ),
  TajweedRule.madWajibMuttashil: (
    title: 'Madd Rules (Elongation)',
    triggerLetters: 'ا ، و ، ي (before Hamzah, Shaddah, or Sukoon)',
    howToRead: 'Madd Tabi\'i is held for 2 counts; Madd Wajib Muttasil and Madd Ja\'iz Munfasil for 4 to 5 counts; Madd Lazim for 6 counts.',
    exampleSurahRef: 'Surah An-Nasr (110:1)',
    exampleExplanation: 'The word جَاءَ contains a madd letter followed by hamzah in the same word (Madd Wajib Muttasil, held 4 to 5 counts).',
  ),
};

typedef _MakhrajEn = ({
  String name,
  String letters,
  String organDescription,
  String practiceTip,
});

const Map<String, _MakhrajEn> _makhrajEn = {
  'al_jauf': (
    name: '1. Al-Jawf (Oral & Throat Cavity)',
    letters: 'ا و ي (Madd Letters)',
    organDescription:
        'Origin of the three madd (elongation) letters: Alif after fathah, Waw sukoon after dammah, and Ya sukoon after kasrah.',
    practiceTip: 'Let the sound flow freely from the throat through the mouth without tongue or lip obstruction.',
  ),
  'al_halq': (
    name: '2. Al-Halq (The Throat)',
    letters: 'ء هـ · ع ح · غ خ',
    organDescription:
        'Divided into three points: deepest throat (ء، هـ), middle throat (ع، ح), and upper throat near the mouth (غ، خ).',
    practiceTip: 'These are the letters of Izhar Halqi; when noon sakinah or tanween meets one, recite it clearly without nasalization.',
  ),
  'al_lisan': (
    name: '3. Al-Lisan (The Tongue)',
    letters: 'ق ك · ج ش ي · ض · ل ن ر · ط د ت · ص ز س · ظ ذ ث',
    organDescription:
        'Covers 10 articulation points for 18 letters: back of the tongue (ق، ك), middle (ج، ش، ي), edge against the molars (ض), and tip of the tongue.',
    practiceTip: 'Notice the fine distinction between tongue-tip letters against upper teeth (ظ، ذ، ث) and whistling letters (ص، ز، س).',
  ),
  'asy_syafatain': (
    name: '4. Ash-Shafatan (Both Lips)',
    letters: 'ف · و ب م',
    organDescription:
        'Inner lower lip meeting the upper front teeth (ف), and the closing or rounding of both lips (ب، م، و).',
    practiceTip: 'The letters ب and م directly govern Ikhfa Shafawi, Idgham Mimi, and Iqlab.',
  ),
  'al_khaisyum': (
    name: '5. Al-Khayshum (Nasal Passage)',
    letters: 'نّ مّ (Ghunnah / Nasalization)',
    organDescription:
        'Origin of the nasal sound (ghunnah) accompanying doubled Noon and Meem, Idgham bi-Ghunnah, Iqlab, and Ikhfa.',
    practiceTip: 'Hold the nasal resonance for 2 full counts; gently pinching the nose will stop the ghunnah sound.',
  ),
};

typedef _QuizEn = ({
  String question,
  List<String> options,
  String explanation,
});

const List<_QuizEn> _tajweedQuizEn = [
  (
    question: 'Which tajweed rule applies when noon sakinah meets Sheen (ش) in this verse excerpt?',
    options: ['Izhar Halqi', 'Ikhfa Haqiqi', 'Idgham bi-Ghunnah', 'Iqlab'],
    explanation: 'Noon sakinah followed by ش is one of the 15 letters of Ikhfa Haqiqi, recited softly with a 2-count nasalization.',
  ),
  (
    question: 'The letter Dal (د) with sukoon in this excerpt bounces because it follows the rule of...',
    options: ['Qalqalah', 'Ghunnah', 'Idgham bila-Ghunnah', 'Madd Wajib Muttasil'],
    explanation: 'The letter د belongs to the five Qalqalah letters (ق ط ب ج د) that echo when carrying sukoon.',
  ),
  (
    question: 'Noon sakinah followed by Ba (ب) in this verse carries the rule of...',
    options: ['Ikhfa Shafawi', 'Izhar Shafawi', 'Iqlab', 'Idgham bila-Ghunnah'],
    explanation: 'Noon sakinah before ب is Iqlab: the noon sound transforms into a soft Meem with nasal resonance.',
  ),
  (
    question: 'Where does the nasal sound (ghunnah) on نّ and مّ originate (makhraj)?',
    options: ['Al-Jawf (Oral Cavity)', 'Al-Halq (The Throat)', 'Al-Khayshum (Nasal Passage)', 'Ash-Shafatan (Both Lips)'],
    explanation: 'The nasal sound (ghunnah) comes from Al-Khayshum (the nasal passage).',
  ),
  (
    question: 'Tanween followed by Lam (ل) in this excerpt is recited as...',
    options: ['Idgham bila-Ghunnah (Merge without Nasalization)', 'Idgham bi-Ghunnah', 'Izhar Halqi', 'Ikhfa Haqiqi'],
    explanation: 'Tanween before ل or ر is Idgham bila-Ghunnah: it merges completely without holding a nasal sound.',
  ),
];

class TajweedLearningPage extends StatefulWidget {
  const TajweedLearningPage({super.key});

  @override
  State<TajweedLearningPage> createState() => _TajweedLearningPageState();
}

class _TajweedLearningPageState extends State<TajweedLearningPage> {
  int _tab = 0;
  int _quizIndex = 0;
  int _quizScore = 0;
  int? _pickedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Belajar Tajwid & Makhraj', 'Learn Tajweed & Makharij')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Hukum Tajwid', 'Tajweed Rules'),
                context.tr('Makharijul Huruf', 'Articulation'),
                context.tr('Kuis Tajwid', 'Tajweed Quiz'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildLessonsTab(context),
              1 => _buildMakhrajTab(context),
              _ => _buildQuizTab(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isEn = context.isEn;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: tajweedLessonsCatalog.length,
      itemBuilder: (context, index) {
        final lesson = tajweedLessonsCatalog[index];
        final en = isEn ? _tajweedLessonsEn[lesson.rule] : null;
        final ruleColor = Color(lesson.rule.colorFor(dark: dark));
        final sampleAyah = Ayah(
          1,
          index + 1,
          lesson.exampleArabic,
          tajweed: classifyTajweed(lesson.exampleArabic),
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: ruleColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        en?.title ?? lesson.title,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'Huruf Pemicu: ${lesson.triggerLetters}',
                    'Trigger Letters: ${en?.triggerLetters ?? lesson.triggerLetters}',
                  ),
                  style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(en?.howToRead ?? lesson.howToRead, style: t.bodyMedium),
                const Divider(height: 20),
                TajweedText(
                  ayah: sampleAyah,
                  colored: true,
                  style: const TextStyle(fontSize: 26, height: 1.9),
                ),
                const SizedBox(height: 6),
                Text(
                  '${en?.exampleSurahRef ?? lesson.exampleSurahRef} · ${en?.exampleExplanation ?? lesson.exampleExplanation}',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMakhrajTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isEn = context.isEn;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: makharijulHurufCatalog.length,
      itemBuilder: (context, index) {
        final m = makharijulHurufCatalog[index];
        final en = isEn ? _makhrajEn[m.id] : null;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(en?.name ?? m.name, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      m.arabicName,
                      textDirection: TextDirection.rtl,
                      style: quranTextStyle(fontSize: 22, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    context.tr('Huruf: ${m.letters}', 'Letters: ${en?.letters ?? m.letters}'),
                    style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(en?.organDescription ?? m.organDescription, style: t.bodyMedium),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'Tips Latihan: ${m.practiceTip}',
                    'Practice Tip: ${en?.practiceTip ?? m.practiceTip}',
                  ),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    final idx = _quizIndex % tajweedQuizBank.length;
    final q = tajweedQuizBank[idx];
    final en = context.isEn && idx < _tajweedQuizEn.length ? _tajweedQuizEn[idx] : null;
    final options = en?.options ?? q.options;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  context.tr(
                    'Skor Kuis Tajwid: $_quizScore / ${tajweedQuizBank.length} · Soal ${_quizIndex + 1}',
                    'Tajweed Quiz Score: $_quizScore / ${tajweedQuizBank.length} · Question ${_quizIndex + 1}',
                  ),
                  key: const Key('tajweed-quiz-score'),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  q.arabicSnippet,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: quranTextStyle(fontSize: 32, color: scheme.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  en?.question ?? q.question,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              key: Key('tajweed-quiz-opt-$i'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
              ),
              onPressed: _pickedOption != null
                  ? null
                  : () => setState(() {
                        _pickedOption = i;
                        if (i == q.correctIndex) _quizScore++;
                      }),
              child: Row(
                children: [
                  Expanded(child: Text(options[i], style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (_pickedOption != null && i == q.correctIndex)
                    Icon(MoeslimIcons.berhasil, color: scheme.primary),
                ],
              ),
            ),
          ),
        if (_pickedOption != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(en?.explanation ?? q.explanation, style: t.bodyMedium),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('tajweed-quiz-next'),
            onPressed: () => setState(() {
              _quizIndex = (_quizIndex + 1) % tajweedQuizBank.length;
              _pickedOption = null;
            }),
            icon: const Icon(Icons.arrow_forward),
            label: Text(context.tr('Soal Berikutnya', 'Next Question')),
          ),
        ],
      ],
    );
  }
}
