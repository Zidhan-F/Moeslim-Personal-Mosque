import 'package:shared_prayer/shared_prayer.dart';
import 'package:test/test.dart';

void main() {
  test('1 Muharram 1446 ~ 7 Juli 2024 (±1 hari)', () {
    final g = HijriDate(1446, 1, 1).toGregorian();
    expect(g.difference(DateTime.utc(2024, 7, 7)).inDays.abs(), lessThanOrEqualTo(1));
  });

  test('round-trip gregorian -> hijri -> gregorian', () {
    for (var d = DateTime.utc(2020, 1, 1);
        d.isBefore(DateTime.utc(2030, 1, 1));
        d = d.add(const Duration(days: 17))) {
      expect(HijriDate.fromGregorian(d).toGregorian(), d);
    }
  });

  test('offset koreksi lokal menggeser tanggal', () {
    final d = DateTime.utc(2025, 3, 1);
    final base = HijriDate.fromGregorian(d);
    final shifted = HijriDate.fromGregorian(d, offsetDays: 1);
    expect(shifted.toGregorian().difference(base.toGregorian()).inDays, 1);
  });

  test('nama bulan dan format', () {
    expect(HijriDate(1446, 9, 1).monthName, 'Ramadan');
    expect(HijriDate(1446, 9, 1).toString(), '1 Ramadan 1446 H');
  });

  test('validasi bulan', () {
    expect(() => HijriDate(1446, 13, 1), throwsArgumentError);
  });
}
