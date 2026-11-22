import 'dart:convert';

import 'package:shared_prayer/shared_prayer.dart';

/// Satu doa harian atau doa aktivitas (Hisnul Muslim & sunnah harian) beserta
/// teks Arab, transliterasi Latin, terjemahan Indonesia/Inggris, dan rujukan hadis.
class DailyDua {
  final int id;
  final String group;
  final String? groupEn;
  final String title;
  final String? titleEn;
  final String arabic;
  final String latin;
  final String translation;
  final String? translationEn;
  final String source;
  final String? sourceEn;
  final List<String> tags;

  const DailyDua({
    required this.id,
    required this.group,
    this.groupEn,
    required this.title,
    this.titleEn,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.translationEn,
    required this.source,
    this.sourceEn,
    this.tags = const [],
  });

  String groupFor(AppLanguage lang) => lang == AppLanguage.en && (groupEn?.isNotEmpty ?? false) ? groupEn! : group;
  String titleFor(AppLanguage lang) => lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
  String sourceFor(AppLanguage lang) => lang == AppLanguage.en && (sourceEn?.isNotEmpty ?? false) ? sourceEn! : source;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        (titleEn?.toLowerCase().contains(q) ?? false) ||
        group.toLowerCase().contains(q) ||
        (groupEn?.toLowerCase().contains(q) ?? false) ||
        translation.toLowerCase().contains(q) ||
        (translationEn?.toLowerCase().contains(q) ?? false) ||
        latin.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }

  static DailyDua? tryParse(Map<String, dynamic> j) {
    final title = (j['nama'] as String?)?.trim() ?? '';
    final arabic = (j['ar'] as String?)?.trim() ?? '';
    final translation = (j['idn'] as String?)?.trim() ?? '';
    if (title.isEmpty || arabic.isEmpty || translation.isEmpty) return null;
    final rawTags = j['tag'];
    return DailyDua(
      id: (j['id'] as num?)?.toInt() ?? 0,
      group: (j['grup'] as String?)?.trim() ?? 'Doa Harian',
      groupEn: (j['grup_en'] as String?)?.trim(),
      title: title,
      titleEn: (j['nama_en'] as String?)?.trim(),
      arabic: arabic,
      latin: (j['tr'] as String?)?.trim() ?? '',
      translation: translation,
      translationEn: (j['en'] as String?)?.trim(),
      source: (j['tentang'] as String?)?.trim() ?? '',
      sourceEn: (j['tentang_en'] as String?)?.trim(),
      tags: rawTags is List
          ? [for (final t in rawTags) t.toString().trim()].where((t) => t.isNotEmpty).toList()
          : const [],
    );
  }
}

/// Memuat daftar doa harian dari JSON (mendukung format list langsung atau `{ "data": [...] }`).
List<DailyDua> parseDailyDuasJson(String raw) {
  final decoded = jsonDecode(raw);
  final items = decoded is List ? decoded : (decoded is Map ? decoded['data'] as List? : null);
  if (items == null) throw const FormatException('Format JSON doa harian tidak valid');
  return [
    for (final item in items)
      if (item is Map<String, dynamic>) DailyDua.tryParse(item),
  ].whereType<DailyDua>().toList();
}
