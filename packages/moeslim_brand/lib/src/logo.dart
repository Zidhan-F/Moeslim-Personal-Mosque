import 'package:material_ui/material_ui.dart';

enum BrandLogoVariant { horizontal, stacked, symbol }

/// Logo resmi Moeslim PM. Varian terang/putih dipilih otomatis dari kecerahan tema
/// (atau dipaksa lewat [onDark]). Pertahankan proporsi — jangan dipipihkan.
class BrandLogo extends StatelessWidget {
  static const semanticLabel = 'Moeslim PM — Personal & Mosque';

  final BrandLogoVariant variant;
  final double height;

  /// null = ikuti tema; true = latar gelap (logo putih); false = latar terang.
  final bool? onDark;

  const BrandLogo({super.key, this.variant = BrandLogoVariant.horizontal, this.height = 32, this.onDark});

  String _asset(bool dark) => switch (variant) {
        BrandLogoVariant.horizontal => dark ? 'horizontal_white' : 'horizontal',
        // Varian stacked putih tidak tersedia di brand kit → pakai simbol putih di latar gelap.
        BrandLogoVariant.stacked => dark ? 'symbol_white' : 'stacked',
        BrandLogoVariant.symbol => dark ? 'symbol_white' : 'symbol',
      };

  @override
  Widget build(BuildContext context) {
    final dark = onDark ?? Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: Image.asset(
        'assets/logo/${_asset(dark)}.png',
        package: 'moeslim_brand',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
