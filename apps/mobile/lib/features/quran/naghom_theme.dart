import 'package:material_ui/material_ui.dart';

/// Warna identitas tiap irama (dipakai konsisten di Beranda, katalog, detail, dan pemutar).
const naghomColors = <String, Color>{
  'bayyati': Color(0xFF0B6E4F),
  'hijaz': Color(0xFFB23A48),
  'shaba': Color(0xFF6D4C9F),
  'rast': Color(0xFF1F6FB2),
  'jiharkah': Color(0xFFC77D18),
  'sika': Color(0xFF2E8B8B),
  'nahawand': Color(0xFF4A5A7A),
};

Color naghomColor(String slug) => naghomColors[slug] ?? const Color(0xFF0B6E4F);

/// Visual tingkat nada: batang naik sebanyak jumlah tingkat (Hijaz: pola zig-zag tajam).
class ToneLevels extends StatelessWidget {
  final int? levels;
  final Color color;
  final double height;
  const ToneLevels({super.key, required this.levels, required this.color, this.height = 36});

  @override
  Widget build(BuildContext context) {
    final bars = levels == null
        ? const [0.5, 1.0, 0.35, 0.9, 0.45, 1.0]
        : [for (var i = 1; i <= levels!; i++) i / levels!];
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, h) in bars.indexed)
            Container(
              key: levels == null ? null : Key('tone-bar-${i + 1}'),
              width: 7,
              height: height * (0.25 + 0.75 * h),
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
        ],
      ),
    );
  }
}
