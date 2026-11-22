import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../ui/components.dart';
import 'tajweed_view.dart';

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
      appBar: AppBar(title: const Text('Belajar Tajwid & Makhraj'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Hukum Tajwid', 'Makharijul Huruf', 'Kuis Tajwid'],
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: tajweedLessonsCatalog.length,
      itemBuilder: (context, index) {
        final lesson = tajweedLessonsCatalog[index];
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
                        lesson.title,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Huruf Pemicu: ${lesson.triggerLetters}', style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(lesson.howToRead, style: t.bodyMedium),
                const Divider(height: 20),
                TajweedText(
                  ayah: sampleAyah,
                  colored: true,
                  style: const TextStyle(fontSize: 26, height: 1.9),
                ),
                const SizedBox(height: 6),
                Text(
                  '${lesson.exampleSurahRef} · ${lesson.exampleExplanation}',
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: makharijulHurufCatalog.length,
      itemBuilder: (context, index) {
        final m = makharijulHurufCatalog[index];
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
                      child: Text(m.name, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                    'Huruf: ${m.letters}',
                    style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(m.organDescription, style: t.bodyMedium),
                const SizedBox(height: 6),
                Text('Tips Latihan: ${m.practiceTip}', style: t.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    final q = tajweedQuizBank[_quizIndex % tajweedQuizBank.length];
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
                  'Skor Kuis Tajwid: $_quizScore / ${tajweedQuizBank.length} · Soal ${_quizIndex + 1}',
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
                  q.question,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
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
                  Expanded(child: Text(q.options[i], style: const TextStyle(fontWeight: FontWeight.w600))),
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
              child: Text(q.explanation, style: t.bodyMedium),
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
            label: const Text('Soal Berikutnya'),
          ),
        ],
      ],
    );
  }
}
