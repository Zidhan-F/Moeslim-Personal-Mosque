import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

/// Alias warna lama ke token brand kit Moeslim PM (lihat packages/moeslim_brand).
class MoeslimColors {
  static const emerald = BrandColors.emerald;
  static const emeraldDark = BrandColors.deep;
  static const cream = BrandColors.cream;
  static const gold = BrandColors.gold;
}

ThemeData buildTheme(Brightness brightness) =>
    brightness == Brightness.light ? buildAppTheme(AppThemeMode.light) : buildAppTheme(AppThemeMode.dark);

enum HeroMotif {
  geometric,
  nightStars,
  natureLeaves,
  skyClouds,
  twilightMoon,
  desertSun,
  midnightMoon,
  lavenderBlossoms,
  tealArch,
  rosePetals,
}

/// Token visual khusus untuk tiap tema tampilan (hero banner, motif atmosfer, palet swatch, dan aksen).
class AppThemeVisual extends ThemeExtension<AppThemeVisual> {
  final AppThemeMode mode;
  final List<Color> heroGradient;
  final Color heroTextColor;
  final Color heroSubtextColor;
  final Color heroAccentColor;
  final Color? heroSunsetGlow;
  final List<Color> bannerGradient;
  final List<Color> swatches;
  final Color countdownBg;
  final Color countdownText;
  final Color activePrayerBg;
  final Color activePrayerText;
  final HeroMotif motif;
  final IconData icon;

  const AppThemeVisual({
    required this.mode,
    required this.heroGradient,
    required this.heroTextColor,
    required this.heroSubtextColor,
    required this.heroAccentColor,
    this.heroSunsetGlow,
    required this.bannerGradient,
    required this.swatches,
    required this.countdownBg,
    required this.countdownText,
    required this.activePrayerBg,
    required this.activePrayerText,
    required this.motif,
    required this.icon,
  });

  static AppThemeVisual of(BuildContext context) =>
      Theme.of(context).extension<AppThemeVisual>() ?? visualForMode(AppThemeMode.light);

  @override
  AppThemeVisual copyWith({
    AppThemeMode? mode,
    List<Color>? heroGradient,
    Color? heroTextColor,
    Color? heroSubtextColor,
    Color? heroAccentColor,
    Color? heroSunsetGlow,
    List<Color>? bannerGradient,
    List<Color>? swatches,
    Color? countdownBg,
    Color? countdownText,
    Color? activePrayerBg,
    Color? activePrayerText,
    HeroMotif? motif,
    IconData? icon,
  }) => AppThemeVisual(
    mode: mode ?? this.mode,
    heroGradient: heroGradient ?? this.heroGradient,
    heroTextColor: heroTextColor ?? this.heroTextColor,
    heroSubtextColor: heroSubtextColor ?? this.heroSubtextColor,
    heroAccentColor: heroAccentColor ?? this.heroAccentColor,
    heroSunsetGlow: heroSunsetGlow ?? this.heroSunsetGlow,
    bannerGradient: bannerGradient ?? this.bannerGradient,
    swatches: swatches ?? this.swatches,
    countdownBg: countdownBg ?? this.countdownBg,
    countdownText: countdownText ?? this.countdownText,
    activePrayerBg: activePrayerBg ?? this.activePrayerBg,
    activePrayerText: activePrayerText ?? this.activePrayerText,
    motif: motif ?? this.motif,
    icon: icon ?? this.icon,
  );

  @override
  AppThemeVisual lerp(ThemeExtension<AppThemeVisual>? other, double t) {
    if (other is! AppThemeVisual) return this;
    final len = heroGradient.length < other.heroGradient.length ? heroGradient.length : other.heroGradient.length;
    return AppThemeVisual(
      mode: t < 0.5 ? mode : other.mode,
      heroGradient: [
        for (var i = 0; i < len; i++) Color.lerp(heroGradient[i], other.heroGradient[i], t) ?? other.heroGradient[i],
      ],
      heroTextColor: Color.lerp(heroTextColor, other.heroTextColor, t) ?? other.heroTextColor,
      heroSubtextColor: Color.lerp(heroSubtextColor, other.heroSubtextColor, t) ?? other.heroSubtextColor,
      heroAccentColor: Color.lerp(heroAccentColor, other.heroAccentColor, t) ?? other.heroAccentColor,
      heroSunsetGlow: Color.lerp(heroSunsetGlow, other.heroSunsetGlow, t),
      bannerGradient: [
        Color.lerp(bannerGradient.first, other.bannerGradient.first, t) ?? other.bannerGradient.first,
        Color.lerp(bannerGradient.last, other.bannerGradient.last, t) ?? other.bannerGradient.last,
      ],
      swatches: t < 0.5 ? swatches : other.swatches,
      countdownBg: Color.lerp(countdownBg, other.countdownBg, t) ?? other.countdownBg,
      countdownText: Color.lerp(countdownText, other.countdownText, t) ?? other.countdownText,
      activePrayerBg: Color.lerp(activePrayerBg, other.activePrayerBg, t) ?? other.activePrayerBg,
      activePrayerText: Color.lerp(activePrayerText, other.activePrayerText, t) ?? other.activePrayerText,
      motif: t < 0.5 ? motif : other.motif,
      icon: t < 0.5 ? icon : other.icon,
    );
  }
}

AppThemeVisual visualForMode(AppThemeMode mode) => switch (mode) {
  AppThemeMode.light => const AppThemeVisual(
    mode: AppThemeMode.light,
    heroGradient: [Color(0xFFE6F2EA), Color(0xFFD0E7DA)],
    heroTextColor: Color(0xFF07372F),
    heroSubtextColor: Color(0xFF1D4F44),
    heroAccentColor: Color(0xFF087E65),
    bannerGradient: [Color(0xFF087E65), Color(0xFF07372F)],
    swatches: [Color(0xFFF5F7F3), Color(0xFFD6E9DF), Color(0xFF087E65), Color(0xFFD9AB36)],
    countdownBg: Color(0xFFFAF1D8),
    countdownText: Color(0xFF7B5B0C),
    activePrayerBg: Color(0xFFDDF1E8),
    activePrayerText: Color(0xFF065A48),
    motif: HeroMotif.geometric,
    icon: Icons.wb_sunny_rounded,
  ),
  AppThemeMode.dark => const AppThemeVisual(
    mode: AppThemeMode.dark,
    heroGradient: [Color(0xFF062922), Color(0xFF0F463A)],
    heroTextColor: Color(0xFFF7F7F1),
    heroSubtextColor: Color(0xFFD1E6DF),
    heroAccentColor: Color(0xFFD9AB36),
    bannerGradient: [Color(0xFF0A4F41), Color(0xFF04221C)],
    swatches: [Color(0xFF041F1A), Color(0xFF0A2E27), Color(0xFF087E65), Color(0xFFD9AB36)],
    countdownBg: Color(0xFF1B3A31),
    countdownText: Color(0xFFF0CA67),
    activePrayerBg: Color(0xFF12463B),
    activePrayerText: Color(0xFF7EE0C1),
    motif: HeroMotif.nightStars,
    icon: Icons.dark_mode_rounded,
  ),
  AppThemeMode.nature => const AppThemeVisual(
    mode: AppThemeMode.nature,
    heroGradient: [Color(0xFFBEE4B4), Color(0xFFDDF2D2)],
    heroTextColor: Color(0xFF123618),
    heroSubtextColor: Color(0xFF214D27),
    heroAccentColor: Color(0xFF2E7D32),
    bannerGradient: [Color(0xFF2C6E30), Color(0xFF153B19)],
    swatches: [Color(0xFFEDF6EA), Color(0xFFA7DBA0), Color(0xFF2E7D32), Color(0xFFC2A03F)],
    countdownBg: Color(0xFFF7EED5),
    countdownText: Color(0xFF6B4F0E),
    activePrayerBg: Color(0xFFD5EED2),
    activePrayerText: Color(0xFF1D5B22),
    motif: HeroMotif.natureLeaves,
    icon: Icons.eco_rounded,
  ),
  AppThemeMode.sky => const AppThemeVisual(
    mode: AppThemeMode.sky,
    heroGradient: [Color(0xFF1760A8), Color(0xFF2473BE)],
    heroTextColor: Color(0xFFFFFFFF),
    heroSubtextColor: Color(0xFFF0F8FF),
    heroAccentColor: Color(0xFFD6EEFF),
    bannerGradient: [Color(0xFF1560AA), Color(0xFF0C396B)],
    swatches: [Color(0xFFEAF4FC), Color(0xFF7EC3F7), Color(0xFF1462B2), Color(0xFFD1A038)],
    countdownBg: Color(0xFFFAF0D7),
    countdownText: Color(0xFF76560A),
    activePrayerBg: Color(0xFFD4E9FC),
    activePrayerText: Color(0xFF0E4D8F),
    motif: HeroMotif.skyClouds,
    icon: Icons.cloud_rounded,
  ),
  AppThemeMode.twilight => const AppThemeVisual(
    mode: AppThemeMode.twilight,
    heroGradient: [Color(0xFF3E2E7A), Color(0xFF6E4190), Color(0xFF944870)],
    heroTextColor: Color(0xFFFFFFFF),
    heroSubtextColor: Color(0xFFF7EEF9),
    heroAccentColor: Color(0xFFF5C99E),
    heroSunsetGlow: Color(0x66F2B28F),
    bannerGradient: [Color(0xFF56388A), Color(0xFF2E1C54)],
    swatches: [Color(0xFFF4EEFA), Color(0xFF5A4396), Color(0xFFB85F8E), Color(0xFFF0B392)],
    countdownBg: Color(0xFFFAECDF),
    countdownText: Color(0xFF774A1C),
    activePrayerBg: Color(0xFFE7DBF8),
    activePrayerText: Color(0xFF4F2E80),
    motif: HeroMotif.twilightMoon,
    icon: Icons.nights_stay_rounded,
  ),
  AppThemeMode.sahara => const AppThemeVisual(
    mode: AppThemeMode.sahara,
    heroGradient: [Color(0xFFF3E1C6), Color(0xFFE7CCA6)],
    heroTextColor: Color(0xFF3A240E),
    heroSubtextColor: Color(0xFF57391B),
    heroAccentColor: Color(0xFF8B5D2B),
    bannerGradient: [Color(0xFF7B5125), Color(0xFF472C12)],
    swatches: [Color(0xFFFAF2E6), Color(0xFFE5C69A), Color(0xFF845727), Color(0xFF6A441F)],
    countdownBg: Color(0xFFF5E5C8),
    countdownText: Color(0xFF684116),
    activePrayerBg: Color(0xFFF0DFC2),
    activePrayerText: Color(0xFF684116),
    motif: HeroMotif.desertSun,
    icon: Icons.landscape_rounded,
  ),
  AppThemeMode.layl => const AppThemeVisual(
    mode: AppThemeMode.layl,
    heroGradient: [Color(0xFF081428), Color(0xFF163360)],
    heroTextColor: Color(0xFFF1F6FF),
    heroSubtextColor: Color(0xFFC5DAF5),
    heroAccentColor: Color(0xFFE5B852),
    bannerGradient: [Color(0xFF163563), Color(0xFF09162B)],
    swatches: [Color(0xFF0A1930), Color(0xFF162F56), Color(0xFF3A72BC), Color(0xFFE2B24E)],
    countdownBg: Color(0xFF1D3357),
    countdownText: Color(0xFFF2CA6E),
    activePrayerBg: Color(0xFF1E3C6B),
    activePrayerText: Color(0xFFA7D0FF),
    motif: HeroMotif.midnightMoon,
    icon: Icons.bedtime_rounded,
  ),
  AppThemeMode.sakina => const AppThemeVisual(
    mode: AppThemeMode.sakina,
    heroGradient: [Color(0xFFE0D5F5), Color(0xFFF0EAFC)],
    heroTextColor: Color(0xFF2B1B49),
    heroSubtextColor: Color(0xFF47326D),
    heroAccentColor: Color(0xFF6A4C9E),
    bannerGradient: [Color(0xFF5F4391), Color(0xFF332056)],
    swatches: [Color(0xFFF4F0FA), Color(0xFFC7B4E8), Color(0xFF6A4C9E), Color(0xFF9A7FC8)],
    countdownBg: Color(0xFFFAF0DA),
    countdownText: Color(0xFF725210),
    activePrayerBg: Color(0xFFE8DEF8),
    activePrayerText: Color(0xFF513485),
    motif: HeroMotif.lavenderBlossoms,
    icon: Icons.spa_rounded,
  ),
  AppThemeMode.zamrud => const AppThemeVisual(
    mode: AppThemeMode.zamrud,
    heroGradient: [Color(0xFF0A4E51), Color(0xFF106A6C), Color(0xFF157676)],
    heroTextColor: Color(0xFFFFFFFF),
    heroSubtextColor: Color(0xFFDCF6F4),
    heroAccentColor: Color(0xFFE2B854),
    bannerGradient: [Color(0xFF0E6466), Color(0xFF073A3D)],
    swatches: [Color(0xFFE5F5F3), Color(0xFF0D6B6A), Color(0xFF0A4E51), Color(0xFF5CC0BA)],
    countdownBg: Color(0xFFFAF0D8),
    countdownText: Color(0xFF73530C),
    activePrayerBg: Color(0xFFCDECE9),
    activePrayerText: Color(0xFF084F50),
    motif: HeroMotif.tealArch,
    icon: Icons.diamond_rounded,
  ),
  AppThemeMode.rosa => const AppThemeVisual(
    mode: AppThemeMode.rosa,
    heroGradient: [Color(0xFFF8D6E0), Color(0xFFFDEAF0)],
    heroTextColor: Color(0xFF471828),
    heroSubtextColor: Color(0xFF64283D),
    heroAccentColor: Color(0xFFA83E61),
    bannerGradient: [Color(0xFF9A3859), Color(0xFF591B31)],
    swatches: [Color(0xFFFDF0F4), Color(0xFFF3BECA), Color(0xFFA83E61), Color(0xFFE287A0)],
    countdownBg: Color(0xFFFBECD8),
    countdownText: Color(0xFF764D15),
    activePrayerBg: Color(0xFFF9DCE5),
    activePrayerText: Color(0xFF8C2A4C),
    motif: HeroMotif.rosePetals,
    icon: Icons.local_florist_rounded,
  ),
};

extension AppThemeAppearance on AppThemeMode {
  bool get isDark => this == AppThemeMode.dark || this == AppThemeMode.layl;

  AppThemeVisual get visual => visualForMode(this);

  String get labelId => switch (this) {
    AppThemeMode.light => 'Terang',
    AppThemeMode.dark => 'Gelap',
    AppThemeMode.nature => 'Hijau Alam',
    AppThemeMode.sky => 'Biru Langit',
    AppThemeMode.twilight => 'Ungu Senja',
    AppThemeMode.sahara => 'Sahara',
    AppThemeMode.layl => 'Layl',
    AppThemeMode.sakina => 'Sakina',
    AppThemeMode.zamrud => 'Zamrud',
    AppThemeMode.rosa => 'Rosa',
  };

  String get labelEn => switch (this) {
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
    AppThemeMode.nature => 'Nature',
    AppThemeMode.sky => 'Sky',
    AppThemeMode.twilight => 'Twilight',
    AppThemeMode.sahara => 'Warm Sand',
    AppThemeMode.layl => 'Midnight Blue',
    AppThemeMode.sakina => 'Soft Lavender',
    AppThemeMode.zamrud => 'Teal',
    AppThemeMode.rosa => 'Rose Pastel',
  };

  String get subtitleId => switch (this) {
    AppThemeMode.light => 'Bersih, jelas, dan nyaman',
    AppThemeMode.dark => 'Nyaman di malam hari',
    AppThemeMode.nature => 'Segar dan menenangkan',
    AppThemeMode.sky => 'Tenang, modern, dan lapang',
    AppThemeMode.twilight => 'Hangat dan menenangkan',
    AppThemeMode.sahara => 'Nuansa gurun yang hangat',
    AppThemeMode.layl => 'Tenang, modern, dan premium',
    AppThemeMode.sakina => 'Damai, lembut, dan nyaman',
    AppThemeMode.zamrud => 'Elegan, segar, dan fokus',
    AppThemeMode.rosa => 'Lembut, hangat, dan bersahabat',
  };

  String get subtitleEn => switch (this) {
    AppThemeMode.light => 'Clean, clear, and comfortable',
    AppThemeMode.dark => 'Comfortable at night',
    AppThemeMode.nature => 'Fresh and calming',
    AppThemeMode.sky => 'Calm, modern, and airy',
    AppThemeMode.twilight => 'Warm and soothing',
    AppThemeMode.sahara => 'Warm desert ambiance',
    AppThemeMode.layl => 'Calm, modern, and premium',
    AppThemeMode.sakina => 'Peaceful, gentle, and cozy',
    AppThemeMode.zamrud => 'Elegant, fresh, and focused',
    AppThemeMode.rosa => 'Soft, warm, and welcoming',
  };
}

ThemeData buildAppTheme(AppThemeMode mode) {
  final visual = visualForMode(mode);
  if (mode == AppThemeMode.light) return BrandTheme.light(extensions: [visual]);
  if (mode == AppThemeMode.dark) return BrandTheme.dark(extensions: [visual]);

  return switch (mode) {
    AppThemeMode.nature => BrandTheme.palette(
      seed: const Color(0xFF2E7D32),
      primary: const Color(0xFF266D2A),
      onPrimary: Colors.white,
      surface: const Color(0xFFEDF6EA),
      card: const Color(0xFFFAFFF7),
      onSurface: const Color(0xFF14351A),
      extensions: [visual],
    ),
    AppThemeMode.sky => BrandTheme.palette(
      seed: const Color(0xFF1565B8),
      primary: const Color(0xFF1462B2),
      onPrimary: Colors.white,
      surface: const Color(0xFFEAF4FC),
      card: const Color(0xFFF9FCFF),
      onSurface: const Color(0xFF0E2C4D),
      extensions: [visual],
    ),
    AppThemeMode.twilight => BrandTheme.palette(
      seed: const Color(0xFF6B469E),
      primary: const Color(0xFF674299),
      onPrimary: Colors.white,
      surface: const Color(0xFFF4EEFA),
      card: const Color(0xFFFDFBFF),
      onSurface: const Color(0xFF2A1B47),
      extensions: [visual],
    ),
    AppThemeMode.sahara => BrandTheme.palette(
      seed: const Color(0xFF8B5D2B),
      primary: const Color(0xFF845727),
      onPrimary: Colors.white,
      surface: const Color(0xFFFAF2E6),
      card: const Color(0xFFFFFDF8),
      onSurface: const Color(0xFF3A240E),
      extensions: [visual],
    ),
    AppThemeMode.layl => BrandTheme.palette(
      seed: const Color(0xFF4D89D6),
      primary: const Color(0xFF8FC2FA),
      onPrimary: const Color(0xFF081B38),
      secondary: const Color(0xFFE5B852),
      surface: const Color(0xFF0A1930),
      card: const Color(0xFF13284A),
      onSurface: const Color(0xFFEEF4FC),
      brightness: Brightness.dark,
      extensions: [visual],
    ),
    AppThemeMode.sakina => BrandTheme.palette(
      seed: const Color(0xFF6F51A3),
      primary: const Color(0xFF6A4C9E),
      onPrimary: Colors.white,
      surface: const Color(0xFFF4F0FA),
      card: const Color(0xFFFCFAFF),
      onSurface: const Color(0xFF2B1B49),
      extensions: [visual],
    ),
    AppThemeMode.zamrud => BrandTheme.palette(
      seed: const Color(0xFF0F6E6D),
      primary: const Color(0xFF0D6B6A),
      onPrimary: Colors.white,
      surface: const Color(0xFFE5F5F3),
      card: const Color(0xFFF6FFFE),
      onSurface: const Color(0xFF0A3638),
      extensions: [visual],
    ),
    AppThemeMode.rosa => BrandTheme.palette(
      seed: const Color(0xFFB14367),
      primary: const Color(0xFFA83E61),
      onPrimary: Colors.white,
      surface: const Color(0xFFFDF0F4),
      card: const Color(0xFFFFF9FB),
      onSurface: const Color(0xFF471828),
      extensions: [visual],
    ),
    _ => BrandTheme.light(extensions: [visual]),
  };
}
