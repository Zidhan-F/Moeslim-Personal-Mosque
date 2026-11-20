import 'package:material_ui/material_ui.dart';

import 'colors.dart';

const _font = 'Inter';
const _package = 'moeslim_brand';

/// Gaya teks Arab Al-Qur'an (font mushaf Amiri Quran, SIL OFL 1.1, dibundel).
TextStyle quranTextStyle({double fontSize = 26, Color? color}) =>
    TextStyle(fontFamily: 'AmiriQuran', package: _package, fontSize: fontSize, height: 2.0, color: color);

/// Tema Material 3 Moeslim PM (terang & gelap) dengan tipografi Inter yang dibundel (offline).
abstract final class BrandTheme {
  static ThemeData light() => _build(
        ColorScheme.fromSeed(
          seedColor: BrandColors.emerald,
          brightness: Brightness.light,
          primary: BrandColors.emerald,
          onPrimary: BrandColors.white,
          secondary: BrandColors.gold,
          onSecondary: BrandColors.deep,
          tertiary: BrandColors.dark,
          surface: BrandColors.cream,
          onSurface: BrandColors.deep,
        ),
        scaffold: BrandColors.cream,
        card: BrandColors.white,
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(
          seedColor: BrandColors.emerald,
          brightness: Brightness.dark,
          primary: BrandColors.emeraldLight,
          onPrimary: BrandColors.deep,
          secondary: BrandColors.gold,
          onSecondary: BrandColors.deep,
          tertiary: BrandColors.emeraldLight,
          surface: BrandColors.nightSurface,
          onSurface: BrandColors.cream,
        ),
        scaffold: BrandColors.nightSurface,
        card: BrandColors.nightCard,
      );

  static ThemeData _build(ColorScheme scheme, {required Color scaffold, required Color card}) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: _font, package: _package);
    final text = base.textTheme
        .apply(fontFamily: _font, package: _package, bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: scheme.primary.withValues(alpha: .16),
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
