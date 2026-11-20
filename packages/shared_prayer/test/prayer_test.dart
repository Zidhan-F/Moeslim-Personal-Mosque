import 'package:adhan/adhan.dart' as adhan;
import 'package:shared_prayer/shared_prayer.dart';
import 'package:test/test.dart';

int minutes(DateTime t) => t.hour * 60 + t.minute;

void main() {
  const jakarta = Coordinates(-6.1754, 106.8272);

  group('PrayerCalculator Kemenag', () {
    final calc = PrayerCalculator(CalculationMethod.kemenag);
    final t = calc.compute(DateTime(2025, 1, 1), jakarta, utcOffsetHours: 7);

    // Pembanding independen: pustaka `adhan` (algoritma Meeus) dengan parameter
    // Kemenag (Subuh 20°, Isya 18°, ihtiyat +2 menit). Toleransi 2 menit karena
    // perbedaan pembulatan (Kemenag membulatkan ke atas, adhan ke menit terdekat).
    final cities = {
      'Jakarta': (jakarta, 7.0),
      'Makassar': (const Coordinates(-5.1477, 119.4327), 8.0),
      'Banda Aceh': (const Coordinates(5.5483, 95.3238), 7.0),
      'Jayapura': (const Coordinates(-2.5337, 140.7181), 9.0),
    };
    for (final city in cities.entries) {
      for (final date in [DateTime(2025, 1, 1), DateTime(2025, 4, 15), DateTime(2025, 9, 23)]) {
        test('${city.key} ${date.toIso8601String().substring(0, 10)} cocok dengan adhan', () {
          final (coord, tz) = city.value;
          final ours = calc.compute(date, coord, utcOffsetHours: tz);
          final params = adhan.CalculationParameters(fajrAngle: 20, ishaAngle: 18)
            ..adjustments = adhan.PrayerAdjustments(fajr: 2, dhuhr: 2, asr: 2, maghrib: 2, isha: 2);
          final ref = adhan.PrayerTimes.utcOffset(
              adhan.Coordinates(coord.latitude, coord.longitude),
              adhan.DateComponents(date.year, date.month, date.day),
              params,
              Duration(minutes: (tz * 60).round()));
          final pairs = {
            'subuh': (ours.fajr, ref.fajr),
            'dzuhur': (ours.dhuhr, ref.dhuhr),
            'ashar': (ours.asr, ref.asr),
            'maghrib': (ours.maghrib, ref.maghrib),
            'isya': (ours.isha, ref.isha),
          };
          for (final e in pairs.entries) {
            final r = e.value.$2;
            final diff = (minutes(e.value.$1) - (r.hour * 60 + r.minute)).abs();
            expect(diff, lessThanOrEqualTo(2), reason: '${e.key}: ${e.value.$1} vs $r');
          }
        });
      }
    }

    test('urutan waktu benar & imsak 10 menit sebelum subuh', () {
      final order = [t.imsak, t.fajr, t.sunrise, t.dhuhr, t.asr, t.maghrib, t.isha];
      for (var i = 1; i < order.length; i++) {
        expect(order[i].isAfter(order[i - 1]), isTrue);
      }
      expect(t.fajr.difference(t.imsak).inMinutes, 10);
    });

    test('penyesuaian menit diterapkan', () {
      final adj = PrayerCalculator(CalculationMethod.kemenag,
              adjustments: const {Prayer.isha: 3, Prayer.fajr: -2})
          .compute(DateTime(2025, 1, 1), jakarta, utcOffsetHours: 7);
      expect(adj.isha.difference(t.isha).inMinutes, 3);
      expect(adj.fajr.difference(t.fajr).inMinutes, -2);
    });

    test('nextPrayer memilih waktu berikutnya', () {
      final now = DateTime(2025, 1, 1, 12, 0);
      expect(t.nextAfter(now), Prayer.asr);
      expect(t.nextAfter(DateTime(2025, 1, 1, 20, 0)), isNull);
    });
  });

  test('metode lain menghasilkan waktu valid', () {
    for (final m in CalculationMethod.values) {
      final t = PrayerCalculator(m).compute(DateTime(2025, 6, 1), jakarta, utcOffsetHours: 7);
      expect(t.isha.isAfter(t.maghrib), isTrue, reason: m.name);
    }
  });

  test('kiblat Jakarta ~295.1 derajat', () {
    expect(qiblaBearing(jakarta), closeTo(295.15, 0.5));
  });

  test('kiblat London ~119 derajat', () {
    expect(qiblaBearing(const Coordinates(51.5074, -0.1278)), closeTo(118.99, 0.5));
  });
}
