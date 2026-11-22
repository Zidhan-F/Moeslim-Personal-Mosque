import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';

const Map<TajweedRule, ({String label, String description})> _tajweedRuleEn = {
  TajweedRule.hamzatWasl: (
    label: 'Hamzatul Wasl',
    description: 'Connecting hamzah pronounced when starting, dropped when continuing.',
  ),
  TajweedRule.lamSyamsiyah: (
    label: 'Lam Shamsiyyah',
    description: 'Silent definite article Lam assimilated into the following sun letter.',
  ),
  TajweedRule.silent: (
    label: 'Silent Letter',
    description: 'Letter written in the script but not pronounced.',
  ),
  TajweedRule.ghunnah: (
    label: 'Ghunnah',
    description: 'Nasal resonance on doubled Noon or Meem, held for 2 counts.',
  ),
  TajweedRule.idghamBighunnah: (
    label: 'Idgham bi-Ghunnah',
    description: 'Noon sakinah or tanween merges into ي ن م و with nasalization.',
  ),
  TajweedRule.idghamBilaghunnah: (
    label: 'Idgham bila-Ghunnah',
    description: 'Noon sakinah or tanween merges into ل ر without nasalization.',
  ),
  TajweedRule.idghamMutajanisain: (
    label: 'Idgham Mutajanisayn',
    description: 'Two letters sharing the same articulation point but different qualities; the first merges.',
  ),
  TajweedRule.idghamMutaqaribain: (
    label: 'Idgham Mutaqaribayn',
    description: 'Two letters with close articulation points and qualities; the first merges.',
  ),
  TajweedRule.idghamMimi: (
    label: 'Idgham Mimi',
    description: 'Meem sakinah followed by Meem, merged with nasalization.',
  ),
  TajweedRule.ikhfa: (
    label: 'Ikhfa Haqiqi',
    description: 'Noon sakinah or tanween concealed with a nasal sound.',
  ),
  TajweedRule.ikhfaSyafawi: (
    label: 'Ikhfa Shafawi',
    description: 'Meem sakinah followed by Ba, pronounced softly with nasalization.',
  ),
  TajweedRule.iqlab: (
    label: 'Iqlab',
    description: 'Noon sakinah or tanween before Ba turns into a soft nasalized Meem.',
  ),
  TajweedRule.qalqalah: (
    label: 'Qalqalah',
    description: 'Echoing bounce on the letters ق ط ب ج د when carrying sukoon.',
  ),
  TajweedRule.madThabii: (
    label: 'Madd Tabi\'i',
    description: 'Natural elongation of 2 counts.',
  ),
  TajweedRule.madJaizMunfashil: (
    label: 'Madd Ja\'iz Munfasil',
    description: 'Elongation before hamzah in the next word, 2 to 5 counts.',
  ),
  TajweedRule.madWajibMuttashil: (
    label: 'Madd Wajib Muttasil',
    description: 'Elongation before hamzah in the same word, 4 to 5 counts.',
  ),
  TajweedRule.madLazim: (
    label: 'Madd Lazim',
    description: 'Required elongation of 6 counts.',
  ),
  TajweedRule.madAridLissukun: (
    label: 'Madd \'Arid lis-Sukoon',
    description: 'Elongation before a letter made silent at a pause, 2, 4, or 6 counts.',
  ),
};

/// Teks ayat (RTL) dengan pewarnaan tajwid dari anotasi dataset.
class TajweedText extends StatelessWidget {
  final Ayah ayah;
  final bool colored;
  final TextStyle style;
  final TextAlign textAlign;
  const TajweedText({
    super.key,
    required this.ayah,
    required this.colored,
    required this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final segments = colored && ayah.tajweed.isNotEmpty
        ? segmentTajweed(ayah.text, ayah.tajweed)
        : [TajweedSegment(ayah.text, null)];
    final dark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      textScaler: MediaQuery.textScalerOf(context),
      text: TextSpan(
        // Warna dasar dari tema agar terbaca di mode terang & gelap.
        style: DefaultTextStyle.of(context).style.merge(quranTextStyle()).merge(style),
        children: [
          for (final s in segments)
            TextSpan(
              text: s.text,
              style: s.rule == null ? null : TextStyle(color: Color(s.rule!.colorFor(dark: dark))),
            ),
        ],
      ),
    );
  }
}

class TajweedLegendPage extends StatelessWidget {
  const TajweedLegendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isEn = context.isEn;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Panduan Warna Tajwid', 'Tajweed Color Guide'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                context.tr(
                  'Warna tajwid ditandai otomatis untuk seluruh 114 surah. Huruf tanpa warna dibaca seperti biasa. '
                  'Panduan ini alat bantu belajar; tetap pelajari dan tashih bacaan bersama guru.',
                  'Tajweed colors are marked automatically across all 114 surahs. Uncolored letters are recited normally. '
                  'Use this guide as a learning aid, and verify your recitation with a qualified teacher.',
                ),
              ),
            ),
          ),
          for (final r in TajweedRule.values)
            ListTile(
              leading: CircleAvatar(backgroundColor: Color(r.colorFor(dark: dark)), radius: 12),
              title: Text(
                isEn ? (_tajweedRuleEn[r]?.label ?? r.label) : r.label,
                style: TextStyle(
                  color: Color(r.colorFor(dark: dark)),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(isEn ? (_tajweedRuleEn[r]?.description ?? r.description) : r.description),
            ),
        ],
      ),
    );
  }
}
