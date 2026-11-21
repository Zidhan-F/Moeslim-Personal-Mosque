import 'dart:convert';

/// Satu doa harian atau doa aktivitas (Hisnul Muslim & sunnah harian) beserta
/// teks Arab, transliterasi Latin, terjemahan Indonesia, dan rujukan hadis.
class DailyDua {
  final int id;
  final String group;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String source;
  final List<String> tags;

  const DailyDua({
    required this.id,
    required this.group,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.source,
    this.tags = const [],
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        group.toLowerCase().contains(q) ||
        translation.toLowerCase().contains(q) ||
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
      title: title,
      arabic: arabic,
      latin: (j['tr'] as String?)?.trim() ?? '',
      translation: translation,
      source: (j['tentang'] as String?)?.trim() ?? '',
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
