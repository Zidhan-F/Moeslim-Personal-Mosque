import 'dart:convert';
import 'dart:io';

import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

List<List<Object>> spans(String t) => [
      for (final s in classifyTajweed(t)) [s.start, s.end, s.rule.name]
    ];

Map<int, List<Ayah>> loadQuran() {
  final dir = Directory('../../apps/mobile/assets/quran');
  return {
    for (var s = 1; s <= 114; s++)
      s: (jsonDecode(File('${dir.path}/$s.json').readAsStringSync()) as List)
          .map((j) => Ayah.fromJson(j as Map<String, dynamic>))
          .toList(),
  };
}

void main() {
  test('Al-Fatihah 1: sama persis dengan keluaran cpfair', () {
    expect(spans(loadQuran()[1]![0].text), [
      [7, 8, 'hamzatWasl'],
      [15, 16, 'hamzatWasl'],
      [16, 17, 'lamSyamsiyah'],
      [24, 25, 'madThabii'],
      [28, 29, 'hamzatWasl'],
      [29, 30, 'lamSyamsiyah'],
      [35, 36, 'madAridLissukun'],
    ]);
  });

  test(
      'Al-Fatihah 2: hamzah washal di awal ayat tidak diwarnai; lafaz Allah bukan lam syamsiyah',
      () {
    final t = loadQuran()[1]![1].text;
    final s = classifyTajweed(t);
    expect(s.first.rule, TajweedRule.hamzatWasl);
    expect(s.first.start, t.indexOf('ٱ', 1));
    expect(s.last.rule, TajweedRule.madAridLissukun);
    expect(s.any((x) => x.rule == TajweedRule.lamSyamsiyah), isFalse);
  });

  test('mad lazim pada ٱلضَّآلِّينَ (Al-Fatihah 7) mencakup alif + maddah', () {
    final t = loadQuran()[1]![6].text;
    final i = t.indexOf('آ'.isEmpty ? '' : 'ا\u0653');
    expect(
        classifyTajweed(t)
            .where((s) => s.rule == TajweedRule.madLazim)
            .map((s) => [s.start, s.end]),
        [
          [i, i + 2],
        ]);
  });

  test('hukum nun mati & tanwin', () {
    // ikhfa: nun tanpa sukun sebelum ت (أَنتُمْ)
    expect(
        classifyTajweed('وَأَنتُمْ').where((s) => s.rule == TajweedRule.ikhfa),
        isNotEmpty);
    // idgham bighunnah: tanwin + و / ي di kata berikut
    expect(classifyTajweed('هُدًى لِّلْمُتَّقِينَ').map((s) => s.rule),
        contains(TajweedRule.idghamBilaghunnah));
    // iqlab: mim kecil sebelum ب
    expect(classifyTajweed('مِنۢ بَعْدِ').map((s) => s.rule),
        contains(TajweedRule.iqlab));
    // ghunnah: nun bertasydid
    expect(classifyTajweed('إِنَّ').map((s) => s.rule),
        contains(TajweedRule.ghunnah));
    // qalqalah: dal sukun
    expect(classifyTajweed('قَدْ').map((s) => s.rule),
        contains(TajweedRule.qalqalah));
  });

  test('seluruh 6.236 ayat terklasifikasi: rentang valid & tiap hukum muncul',
      () {
    final quran = loadQuran();
    final counts = <TajweedRule, int>{};
    var total = 0;
    for (final ayat in quran.values) {
      for (final a in ayat) {
        total++;
        for (final s in classifyTajweed(a.text)) {
          expect(
              s.start >= 0 && s.end <= a.text.length && s.start < s.end, isTrue,
              reason: '${a.surah}:${a.number}');
          counts[s.rule] = (counts[s.rule] ?? 0) + 1;
        }
      }
    }
    expect(total, 6236);
    for (final r in TajweedRule.values) {
      expect(counts[r] ?? 0, greaterThan(0), reason: r.name);
    }
  });

  test(
      'aset terpasang memuat anotasi terbaru (jalankan tool/annotate_tajweed.dart bila gagal)',
      () {
    var colored = 0;
    for (final ayat in loadQuran().values) {
      for (final a in ayat) {
        final want = [for (final s in classifyTajweed(a.text)) s.toJson()];
        final got = [for (final s in a.tajweed) s.toJson()];
        expect(got, want, reason: '${a.surah}:${a.number}');
        if (got.isNotEmpty) colored++;
      }
    }
    expect(colored, greaterThan(6000));
  });
}
