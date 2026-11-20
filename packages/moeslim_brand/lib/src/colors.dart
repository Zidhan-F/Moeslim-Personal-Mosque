import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Palet resmi brand kit + token turunan untuk kebutuhan aksesibilitas.
abstract final class BrandColors {
  static const emerald = Color(0xFF087E65);
  static const deep = Color(0xFF07372F);
  static const dark = Color(0xFF06473D);

  /// Emas hanya sebagai AKSEN. Sebagai warna teks hanya di atas [deep]/[dark] (≥ 4.9:1).
  static const gold = Color(0xFFD9AB36);
  static const cream = Color(0xFFF7F7F1);
  static const white = Color(0xFFFFFFFF);

  /// Emas gelap untuk teks bernuansa emas di latar terang (4.7:1 di [cream]).
  static const goldText = Color(0xFF8A6A14);

  /// Emerald terang untuk teks/ikon utama di mode gelap.
  static const emeraldLight = Color(0xFF5FD1AE);

  /// Permukaan mode gelap (turunan [deep]).
  static const nightSurface = Color(0xFF041F1A);
  static const nightCard = Color(0xFF0A2E27);

  static const textMuted = Color(0xFF4B5B57);
}

/// Rasio kontras WCAG 2.x antara dua warna.
double contrastRatio(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final l1 = lum(a), l2 = lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}
