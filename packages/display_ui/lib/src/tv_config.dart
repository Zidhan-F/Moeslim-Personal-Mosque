import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

/// Tema warna TV Display yang bisa dipilih pengurus.
enum TvThemePreset {
  auto('auto', 'Hijau Masjid', [BrandColors.emerald, BrandColors.deep], BrandColors.gold),
  light('light', 'Krem Terang', [BrandColors.cream, Color(0xFFEFEBDD)], BrandColors.gold),
  dark('dark', 'Hijau Malam', [BrandColors.nightSurface, Color(0xFF020F0C)], BrandColors.gold),
  navy('navy', 'Biru Malam', [Color(0xFF123A63), Color(0xFF061A30)], BrandColors.gold),
  maroon('maroon', 'Merah Marun', [Color(0xFF6B1F2A), Color(0xFF2E0B12)], BrandColors.gold),
  custom('custom', 'Warna Sendiri', [BrandColors.emerald, BrandColors.deep], BrandColors.gold);

  final String id;
  final String label;
  final List<Color> background;
  final Color accent;
  const TvThemePreset(this.id, this.label, this.background, this.accent);

  static TvThemePreset fromId(String? id) => values.firstWhere((p) => p.id == id, orElse: () => auto);
}

/// Pengaturan tampilan TV per perangkat (`device.config` di server).
///
/// Kunci JSON sama dengan yang divalidasi backend (`DisplayController::update`). Kunci lama
/// (`theme`, `show_staff`, `rotation_seconds`, `language`) tetap dipakai apa adanya.
class TvDisplayConfig {
  final TvThemePreset theme;

  /// Warna kustom (dipakai bila [theme] = custom).
  final Color customBackground;
  final Color customBackground2;
  final Color customAccent;

  final bool showIllustration;
  final bool showPattern;
  final bool showSeconds;
  final bool showHijri;
  final bool showSunrise;
  final bool showStaff;
  final bool showTicker;
  final bool showInfoScreen;

  /// Lama Layar Informasi Jamaah tampil di setiap menit (detik).
  final int infoSeconds;

  /// Jam besar di layar utama.
  final bool largeClock;

  /// Teks berjalan tambahan dari pengurus (ditampilkan di depan pengumuman).
  final String tickerText;

  /// Kunci lain yang tidak diubah editor (mis. `language`, `rotation_seconds`) tetap dibawa.
  final Map<String, dynamic> extra;

  const TvDisplayConfig({
    this.theme = TvThemePreset.auto,
    this.customBackground = BrandColors.emerald,
    this.customBackground2 = BrandColors.deep,
    this.customAccent = BrandColors.gold,
    this.showIllustration = true,
    this.showPattern = true,
    this.showSeconds = true,
    this.showHijri = true,
    this.showSunrise = true,
    this.showStaff = true,
    this.showTicker = true,
    this.showInfoScreen = true,
    this.infoSeconds = 20,
    this.largeClock = false,
    this.tickerText = '',
    this.extra = const {},
  });

  static const allowedInfoSeconds = [10, 20, 30];
  static const maxTickerLength = 160;

  static Color? parseHex(Object? v) {
    if (v is! String) return null;
    final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(v.trim());
    return m == null ? null : Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
  }

  static String toHex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  factory TvDisplayConfig.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    bool b(String k) => j[k] is bool ? j[k] as bool : true;
    final info = (j['info_seconds'] as num?)?.toInt() ?? 20;
    return TvDisplayConfig(
      theme: TvThemePreset.fromId(j['theme'] as String?),
      customBackground: parseHex(j['custom_background']) ?? BrandColors.emerald,
      customBackground2: parseHex(j['custom_background_2']) ?? BrandColors.deep,
      customAccent: parseHex(j['custom_accent']) ?? BrandColors.gold,
      showIllustration: b('show_illustration'),
      showPattern: b('show_pattern'),
      showSeconds: b('show_seconds'),
      showHijri: b('show_hijri'),
      showSunrise: b('show_sunrise'),
      showStaff: b('show_staff'),
      showTicker: b('show_ticker'),
      showInfoScreen: b('show_info_screen'),
      infoSeconds: allowedInfoSeconds.contains(info) ? info : 20,
      largeClock: j['large_clock'] == true,
      tickerText: (j['ticker_text'] as String? ?? '').trim(),
      extra: {
        for (final e in j.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  static const _keys = {
    'theme',
    'custom_background',
    'custom_background_2',
    'custom_accent',
    'show_illustration',
    'show_pattern',
    'show_seconds',
    'show_hijri',
    'show_sunrise',
    'show_staff',
    'show_ticker',
    'show_info_screen',
    'info_seconds',
    'large_clock',
    'ticker_text',
  };

  Map<String, dynamic> toJson() => {
    ...extra,
    'theme': theme.id,
    'custom_background': toHex(customBackground),
    'custom_background_2': toHex(customBackground2),
    'custom_accent': toHex(customAccent),
    'show_illustration': showIllustration,
    'show_pattern': showPattern,
    'show_seconds': showSeconds,
    'show_hijri': showHijri,
    'show_sunrise': showSunrise,
    'show_staff': showStaff,
    'show_ticker': showTicker,
    'show_info_screen': showInfoScreen,
    'info_seconds': infoSeconds,
    'large_clock': largeClock,
    'ticker_text': tickerText,
  };

  TvDisplayConfig copyWith({
    TvThemePreset? theme,
    Color? customBackground,
    Color? customBackground2,
    Color? customAccent,
    bool? showIllustration,
    bool? showPattern,
    bool? showSeconds,
    bool? showHijri,
    bool? showSunrise,
    bool? showStaff,
    bool? showTicker,
    bool? showInfoScreen,
    int? infoSeconds,
    bool? largeClock,
    String? tickerText,
  }) => TvDisplayConfig(
    theme: theme ?? this.theme,
    customBackground: customBackground ?? this.customBackground,
    customBackground2: customBackground2 ?? this.customBackground2,
    customAccent: customAccent ?? this.customAccent,
    showIllustration: showIllustration ?? this.showIllustration,
    showPattern: showPattern ?? this.showPattern,
    showSeconds: showSeconds ?? this.showSeconds,
    showHijri: showHijri ?? this.showHijri,
    showSunrise: showSunrise ?? this.showSunrise,
    showStaff: showStaff ?? this.showStaff,
    showTicker: showTicker ?? this.showTicker,
    showInfoScreen: showInfoScreen ?? this.showInfoScreen,
    infoSeconds: infoSeconds ?? this.infoSeconds,
    largeClock: largeClock ?? this.largeClock,
    tickerText: tickerText ?? this.tickerText,
    extra: extra,
  );

  TvPalette get palette => TvPalette.fromConfig(this);
}

/// Palet layar TV. Warna teks diturunkan otomatis dari latar agar kontras tetap terjaga.
class TvPalette {
  final List<Color> background;
  final Color fg;
  final Color muted;
  final Color card;
  final Color cardFg;

  /// Teks aksen di atas latar (emas di latar gelap, emas tua di latar terang).
  final Color accentText;

  /// Warna aksen untuk bingkai, kartu waktu aktif, dan label pengumuman.
  final Color accent;

  /// Teks di atas [accent].
  final Color onAccent;

  const TvPalette({
    required this.background,
    required this.fg,
    required this.muted,
    required this.card,
    required this.cardFg,
    required this.accentText,
    this.accent = BrandColors.gold,
    this.onAccent = BrandColors.deep,
    this.adjusted = false,
  });

  /// true bila warna latar pilihan pengurus digeser otomatis agar teks tetap terbaca.
  final bool adjusted;

  bool get isLight => fg == BrandColors.deep;

  /// Palet dari nama tema lama (`auto`/`light`/`dark`).
  static TvPalette of(String? theme) => TvDisplayConfig(theme: TvThemePreset.fromId(theme)).palette;

  factory TvPalette.fromConfig(TvDisplayConfig c) {
    switch (c.theme) {
      case TvThemePreset.light:
        return const TvPalette(
          background: [BrandColors.cream, Color(0xFFEFEBDD)],
          fg: BrandColors.deep,
          muted: Color(0xFF3F5A53),
          card: Colors.white,
          cardFg: BrandColors.deep,
          accentText: BrandColors.goldText,
        );
      case TvThemePreset.dark:
        return const TvPalette(
          background: [BrandColors.nightSurface, Color(0xFF020F0C)],
          fg: BrandColors.cream,
          muted: Color(0xFFB5C9C2),
          card: BrandColors.nightCard,
          cardFg: BrandColors.cream,
          accentText: BrandColors.gold,
        );
      case TvThemePreset.auto:
        return const TvPalette(
          background: [BrandColors.emerald, BrandColors.deep],
          fg: Colors.white,
          muted: Color(0xFFD5E8E1),
          card: Color(0xFFFFFDF6),
          cardFg: BrandColors.deep,
          accentText: BrandColors.gold,
        );
      case TvThemePreset.navy:
      case TvThemePreset.maroon:
        return _derived(c.theme.background, c.theme.accent);
      case TvThemePreset.custom:
        return _derived([c.customBackground, c.customBackground2], c.customAccent);
    }
  }

  static double _minContrast(Color fg, List<Color> bg) => bg.map((b) => contrastRatio(fg, b)).reduce(math.min);

  static TvPalette _derived(List<Color> rawBg, Color accent) {
    // Teks putih atau hijau tua, mana yang lebih kontras terhadap latar.
    final light = _minContrast(BrandColors.deep, rawBg) > _minContrast(Colors.white, rawBg);
    final fg = light ? BrandColors.deep : Colors.white;
    // Latar warna tengah (mis. biru sedang) digeser sedikit agar teks utama mencapai 4.5:1.
    final toward = light ? Colors.white : Colors.black;
    final bg = [
      for (final b in rawBg)
        () {
          var c = b;
          for (var i = 0; i < 25 && contrastRatio(fg, c) < 4.5; i++) {
            c = Color.lerp(c, toward, .06)!;
          }
          return c;
        }(),
    ];
    final adjusted = [for (var i = 0; i < bg.length; i++) bg[i].toARGB32() != rawBg[i].toARGB32()].any((x) => x);
    final onAccent = contrastRatio(BrandColors.deep, accent) >= contrastRatio(Colors.white, accent)
        ? BrandColors.deep
        : Colors.white;
    // Aksen sebagai teks hanya bila ≥ 3:1 (teks besar) di kedua ujung latar; jika tidak, emas lalu warna teks.
    final accentText = [
      accent,
      light ? BrandColors.goldText : const Color(0xFFF2D88B),
      fg,
    ].firstWhere((c) => _minContrast(c, bg) >= 3);
    final muted = light ? const Color(0xFF3F5A53) : Colors.white.withValues(alpha: .85);
    return TvPalette(
      background: bg,
      fg: fg,
      muted: _minContrast(Color.alphaBlend(muted, bg.first), bg) >= 4.5 ? muted : fg,
      card: light ? Colors.white : const Color(0xFFFFFDF6),
      cardFg: BrandColors.deep,
      accentText: accentText,
      accent: accent,
      onAccent: onAccent,
      adjusted: adjusted,
    );
  }

  /// Kontras terendah teks utama terhadap latar (untuk peringatan di editor).
  double get minTextContrast => background.map((b) => contrastRatio(fg, b)).reduce(math.min);
}
