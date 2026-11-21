import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  test('114 surah dengan total 6236 ayat', () {
    expect(surahs.length, 114);
    expect(surahs.fold<int>(0, (s, e) => s + e.ayahCount), 6236);
    expect(surahs.first.name, 'Al-Fatihah');
    expect(surahs[35].name, 'Yasin');
    expect(surahs.last.number, 114);
    for (var i = 0; i < surahs.length; i++) {
      expect(surahs[i].number, i + 1);
    }
  });

  test('dzikir dasar memiliki target default', () {
    expect(dzikirList.map((d) => d.id), containsAll(['tasbih', 'tahmid', 'takbir']));
    expect(dzikirList.firstWhere((d) => d.id == 'tasbih').defaultTarget, 33);
  });

  test('kota Indonesia memiliki zona waktu WIB/WITA/WIT', () {
    final offsets = indonesianCities.map((c) => c.utcOffset).toSet();
    expect(offsets, {7.0, 8.0, 9.0});
    expect(indonesianCities.any((c) => c.name == 'Jakarta'), isTrue);
  });

  test('parser format Tanzil (sura|aya|teks)', () {
    const raw = '1|1|teks satu\n1|2|teks dua\n# komentar\n\n2|1|teks tiga\n';
    final parsed = parseTanzil(raw);
    expect(parsed.keys, [1, 2]);
    expect(parsed[1]!.map((a) => a.text), ['teks satu', 'teks dua']);
    expect(parsed[2]!.single.number, 1);
    expect(() => parseTanzil('rusak'), throwsFormatException);
  });
}
