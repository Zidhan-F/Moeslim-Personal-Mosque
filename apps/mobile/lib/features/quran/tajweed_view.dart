import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Warna Tajwid')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Warna tajwid ditandai otomatis untuk seluruh 114 surah. Huruf tanpa warna dibaca seperti biasa. '
                'Panduan ini alat bantu belajar; tetap pelajari dan tashih bacaan bersama guru.',
              ),
            ),
          ),
          for (final r in TajweedRule.values)
            ListTile(
              leading: CircleAvatar(backgroundColor: Color(r.colorFor(dark: dark)), radius: 12),
              title: Text(
                r.label,
                style: TextStyle(
                  color: Color(r.colorFor(dark: dark)),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(r.description),
            ),
        ],
      ),
    );
  }
}
