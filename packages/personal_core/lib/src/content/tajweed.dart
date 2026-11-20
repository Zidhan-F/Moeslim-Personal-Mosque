/// Aturan tajwid untuk pewarnaan teks Al-Qur'an.
///
/// Pewarnaan TIDAK ditebak dari teks: anotasi (posisi awal–akhir + aturan) harus berasal dari
/// dataset yang ditelaah dan dibuat untuk EDISI TEKS YANG SAMA dengan teks yang ditampilkan.
/// Palet warna di sini satu sumber kebenaran dan dapat diselaraskan dengan konvensi mushaf
/// tajwid yang dipilih penelaah.
enum TajweedRule {
  hamzatWasl('Hamzah Washal', 'Hamzah yang dibaca saat memulai, gugur saat disambung.', 0xFF9E9E9E, ['hamzat_wasl']),
  lamSyamsiyah('Lam Syamsiyah', 'Lam ta\'rif tidak dibaca, melebur ke huruf syamsiyah sesudahnya.', 0xFFB0A48A, ['lam_shamsiyyah']),
  silent('Huruf tidak dibaca', 'Huruf yang tertulis tetapi tidak dilafalkan.', 0xFFBDBDBD, ['silent']),
  ghunnah('Ghunnah', 'Dengung pada nun atau mim bertasydid, ±2 harakat.', 0xFFE65100, ['ghunnah']),
  idghamBighunnah('Idgham Bighunnah', 'Nun mati/tanwin melebur ke ي ن م و dengan dengung.', 0xFF2E7D32, ['idghaam_ghunnah']),
  idghamBilaghunnah('Idgham Bilaghunnah', 'Nun mati/tanwin melebur ke ل ر tanpa dengung.', 0xFF66BB6A, ['idghaam_no_ghunnah']),
  idghamMutajanisain('Idgham Mutajanisain', 'Dua huruf satu makhraj berbeda sifat, huruf pertama melebur.', 0xFF00897B, ['idghaam_mutajanisayn']),
  idghamMutaqaribain('Idgham Mutaqaribain', 'Dua huruf berdekatan makhraj dan sifat, huruf pertama melebur.', 0xFF26A69A, ['idghaam_mutaqaribayn']),
  idghamMimi('Idgham Mimi', 'Mim mati bertemu mim, dibaca dengung.', 0xFF558B2F, ['idghaam_shafawi']),
  ikhfa('Ikhfa\' Haqiqi', 'Nun mati/tanwin dibaca samar dengan dengung.', 0xFFD81B60, ['ikhfa']),
  ikhfaSyafawi('Ikhfa\' Syafawi', 'Mim mati bertemu ba\', dibaca samar dengan dengung.', 0xFFAD1457, ['ikhfa_shafawi']),
  iqlab('Iqlab', 'Nun mati/tanwin bertemu ba\', diubah menjadi mim samar.', 0xFF1565C0, ['iqlab']),
  qalqalah('Qalqalah', 'Pantulan pada ق ط ب ج د yang mati.', 0xFF0277BD, ['qalqalah']),
  madThabii('Mad Thabi\'i', 'Panjang 2 harakat.', 0xFF8E24AA, ['madd_2']),
  madJaizMunfashil('Mad Jaiz Munfashil', 'Mad bertemu hamzah di kata berbeda, 2–5 harakat.', 0xFF6A1B9A, ['madd_munfasil']),
  madWajibMuttashil('Mad Wajib Muttashil', 'Mad bertemu hamzah dalam satu kata, 4–5 harakat.', 0xFFC62828, ['madd_muttasil']),
  madLazim('Mad Lazim', 'Panjang 6 harakat.', 0xFFB71C1C, ['madd_6']),
  madAridLissukun('Mad \'Aridh Lissukun', 'Mad sebelum huruf yang dimatikan karena waqaf, 2/4/6 harakat.', 0xFFF9A825, ['madd_246']);

  final String label;
  final String description;

  /// Warna ARGB (0xAARRGGBB).
  final int color;
  final List<String> sourceNames;

  const TajweedRule(this.label, this.description, this.color, this.sourceNames);

  static TajweedRule? fromSource(String name) {
    for (final r in values) {
      if (r.sourceNames.contains(name)) return r;
    }
    return null;
  }
}

/// Rentang [start, end) dalam unit kode string ayat.
class TajweedSpan {
  final int start;
  final int end;
  final TajweedRule rule;
  const TajweedSpan(this.start, this.end, this.rule);

  List<Object> toJson() => [start, end, rule.name];

  static TajweedSpan? fromJson(Object? j) {
    if (j is! List || j.length < 3) return null;
    final rule = TajweedRule.values.where((r) => r.name == j[2]).firstOrNull;
    return rule == null ? null : TajweedSpan((j[0] as num).toInt(), (j[1] as num).toInt(), rule);
  }
}

class TajweedSegment {
  final String text;
  final TajweedRule? rule;
  const TajweedSegment(this.text, this.rule);
}

/// Pecah teks ayat menjadi segmen bersambung berwarna/polos.
/// Bila anotasi tumpang tindih, yang lebih pendek (lebih spesifik) menang.
List<TajweedSegment> segmentTajweed(String text, List<TajweedSpan> spans) {
  if (text.isEmpty) return const [];
  final perChar = List<TajweedRule?>.filled(text.length, null);
  final sorted = [...spans]..sort((a, b) => (b.end - b.start).compareTo(a.end - a.start));
  for (final s in sorted) {
    final start = s.start.clamp(0, text.length), end = s.end.clamp(0, text.length);
    for (var i = start; i < end; i++) {
      perChar[i] = s.rule;
    }
  }
  final out = <TajweedSegment>[];
  var from = 0;
  for (var i = 1; i <= text.length; i++) {
    if (i == text.length || perChar[i] != perChar[from]) {
      out.add(TajweedSegment(text.substring(from, i), perChar[from]));
      from = i;
    }
  }
  return out;
}

class TajweedParseResult {
  final Map<(int, int), List<TajweedSpan>> spans;
  final Set<String> unknownRules;
  const TajweedParseResult(this.spans, this.unknownRules);
}

/// Parser dataset anotasi tajwid: `[{surah, ayah, annotations: [{rule, start, end}]}]`.
TajweedParseResult parseTajweedAnnotations(List<dynamic> data) {
  final spans = <(int, int), List<TajweedSpan>>{};
  final unknown = <String>{};
  for (final entry in data.whereType<Map>()) {
    final key = ((entry['surah'] as num).toInt(), (entry['ayah'] as num).toInt());
    for (final a in (entry['annotations'] as List? ?? const []).whereType<Map>()) {
      final name = a['rule'] as String;
      final rule = TajweedRule.fromSource(name);
      if (rule == null) {
        unknown.add(name);
        continue;
      }
      spans.putIfAbsent(key, () => []).add(TajweedSpan((a['start'] as num).toInt(), (a['end'] as num).toInt(), rule));
    }
  }
  return TajweedParseResult(spans, unknown);
}
