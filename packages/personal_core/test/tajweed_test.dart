import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  test('nama aturan dari sumber anotasi dipetakan, yang tak dikenal null', () {
    expect(TajweedRule.fromSource('ikhfa'), TajweedRule.ikhfa);
    expect(TajweedRule.fromSource('idghaam_ghunnah'), TajweedRule.idghamBighunnah);
    expect(TajweedRule.fromSource('madd_6'), TajweedRule.madLazim);
    expect(TajweedRule.fromSource('qalqalah'), TajweedRule.qalqalah);
    expect(TajweedRule.fromSource('aturan_baru'), isNull);
  });

  test('setiap aturan punya nama Indonesia, penjelasan, dan warna unik', () {
    for (final r in TajweedRule.values) {
      expect(r.label, isNotEmpty);
      expect(r.description, isNotEmpty);
    }
    expect(TajweedRule.values.map((r) => r.color).toSet().length, TajweedRule.values.length);
  });

  group('segmentasi teks', () {
    const text = 'abcdefghij';

    test('tanpa anotasi: satu segmen polos', () {
      final s = segmentTajweed(text, const []);
      expect(s.single.text, text);
      expect(s.single.rule, isNull);
    });

    test('segmen bersambung, menutup seluruh teks', () {
      final s = segmentTajweed(text, const [TajweedSpan(2, 4, TajweedRule.ikhfa), TajweedSpan(7, 8, TajweedRule.qalqalah)]);
      expect(s.map((e) => e.text).join(), text);
      expect([for (final e in s) (e.text, e.rule)], [
        ('ab', null),
        ('cd', TajweedRule.ikhfa),
        ('efg', null),
        ('h', TajweedRule.qalqalah),
        ('ij', null),
      ]);
    });

    test('tumpang tindih: anotasi yang lebih pendek (lebih spesifik) menang', () {
      final s = segmentTajweed(text, const [TajweedSpan(0, 6, TajweedRule.madThabii), TajweedSpan(2, 3, TajweedRule.ghunnah)]);
      expect([for (final e in s) (e.text, e.rule)], [
        ('ab', TajweedRule.madThabii),
        ('c', TajweedRule.ghunnah),
        ('def', TajweedRule.madThabii),
        ('ghij', null),
      ]);
    });

    test('anotasi di luar batas teks diabaikan dengan aman', () {
      final s = segmentTajweed('abc', const [TajweedSpan(1, 99, TajweedRule.iqlab), TajweedSpan(5, 6, TajweedRule.ikhfa)]);
      expect([for (final e in s) (e.text, e.rule)], [('a', null), ('bc', TajweedRule.iqlab)]);
    });
  });

  test('parser anotasi format [{surah, ayah, annotations:[{rule,start,end}]}]', () {
    final r = parseTajweedAnnotations([
      {
        'surah': 1,
        'ayah': 1,
        'annotations': [
          {'rule': 'hamzat_wasl', 'start': 0, 'end': 1},
          {'rule': 'tidak_dikenal', 'start': 2, 'end': 3},
        ],
      },
    ]);
    expect(r.spans[(1, 1)]!.single.rule, TajweedRule.hamzatWasl);
    expect(r.unknownRules, {'tidak_dikenal'});
  });

  test('Ayah membawa anotasi tajwid melalui JSON', () {
    const a = Ayah(1, 1, 'abc', tajweed: [TajweedSpan(0, 1, TajweedRule.ikhfa)]);
    final back = Ayah.fromJson(a.toJson());
    expect(back.tajweed.single.rule, TajweedRule.ikhfa);
    expect(back.tajweed.single.end, 1);
    expect(Ayah.fromJson(const Ayah(1, 2, 'x').toJson()).tajweed, isEmpty);
  });
}
