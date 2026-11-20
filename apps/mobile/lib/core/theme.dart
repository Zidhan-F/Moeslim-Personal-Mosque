import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

/// Alias warna lama → token brand kit Moeslim PM (lihat packages/moeslim_brand).
class MoeslimColors {
  static const emerald = BrandColors.emerald;
  static const emeraldDark = BrandColors.deep;
  static const cream = BrandColors.cream;
  static const gold = BrandColors.gold;
}

ThemeData buildTheme(Brightness brightness) => brightness == Brightness.light ? BrandTheme.light() : BrandTheme.dark();
