import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

/// Warna identitas tiap irama (dipakai konsisten di Beranda, katalog, detail, dan pemutar).
/// Semua memenuhi kontras ≥ 4.5:1 untuk teks putih; Bayyati memakai emerald brand.
const naghomColors = <String, Color>{
  'bayyati': BrandColors.emerald,
  'hijaz': Color(0xFFB23A48),
  'shaba': Color(0xFF6D4C9F),
  'rast': Color(0xFF1F6FB2),
  'jiharkah': Color(0xFF9A5B0E),
  'sika': Color(0xFF1F7272),
  'nahawand': Color(0xFF4A5A7A),
};

Color naghomColor(String slug) => naghomColors[slug] ?? BrandColors.emerald;

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
