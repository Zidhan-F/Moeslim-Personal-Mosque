import 'package:material_ui/material_ui.dart';

/// Hijau zamrud, latar krem/putih, aksen emas (Blueprint §02).
class MoeslimColors {
  static const emerald = Color(0xFF0B6E4F);
  static const emeraldDark = Color(0xFF07513A);
  static const cream = Color(0xFFFBF7EE);
  static const gold = Color(0xFFC9A227);
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: MoeslimColors.emerald,
    brightness: brightness,
    primary: brightness == Brightness.light ? MoeslimColors.emerald : const Color(0xFF6FD3A8),
    secondary: MoeslimColors.gold,
    surface: brightness == Brightness.light ? MoeslimColors.cream : const Color(0xFF101814),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface, centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      color: brightness == Brightness.light ? Colors.white : const Color(0xFF17221C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
