import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

/// Teks ayat (RTL) dengan pewarnaan tajwid dari anotasi dataset.
class TajweedText extends StatelessWidget {
  final Ayah ayah;
  final bool colored;
  final TextStyle style;
  const TajweedText({super.key, required this.ayah, required this.colored, required this.style});

  @override
  Widget build(BuildContext context) {
    final segments = colored && ayah.tajweed.isNotEmpty
        ? segmentTajweed(ayah.text, ayah.tajweed)
        : [TajweedSegment(ayah.text, null)];
    return RichText(
      textDirection: TextDirection.rtl,
      textScaler: MediaQuery.textScalerOf(context),
      text: TextSpan(
        // Warna dasar dari tema agar terbaca di mode terang & gelap.
        style: DefaultTextStyle.of(context).style.merge(quranTextStyle()).merge(style),
        children: [
          for (final s in segments)
            TextSpan(
              text: s.text,
              style: s.rule == null ? null : TextStyle(color: Color(s.rule!.color)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Warna Tajwid')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Warna mengikuti anotasi tajwid pada dataset mushaf yang dipakai. Huruf tanpa warna dibaca '
                'seperti biasa. Panduan ini alat bantu belajar — tetap belajar tajwid bersama guru.',
              ),
            ),
          ),
          for (final r in TajweedRule.values)
            ListTile(
              leading: CircleAvatar(backgroundColor: Color(r.color), radius: 12),
              title: Text(
                r.label,
                style: TextStyle(color: Color(r.color), fontWeight: FontWeight.w600),
              ),
              subtitle: Text(r.description),
            ),
        ],
      ),
    );
  }
}
