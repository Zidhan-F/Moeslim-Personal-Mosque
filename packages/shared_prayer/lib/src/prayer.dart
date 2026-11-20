import 'dart:math' as math;

import 'astro.dart';
import 'coordinates.dart';

/// Lima waktu sholat wajib.
enum Prayer {
  fajr('Subuh'),
  dhuhr('Dzuhur'),
  asr('Ashar'),
  maghrib('Maghrib'),
  isha('Isya');

  final String label;
  const Prayer(this.label);
}

/// Mazhab perhitungan bayangan Ashar.
enum AsrMadhab { shafii, hanafi }

/// Metode perhitungan jadwal sholat.
enum CalculationMethod {
  /// Kementerian Agama RI: Subuh −20°, Isya −18°, ihtiyat 2 menit.
  kemenag('Kemenag RI', fajrAngle: 20, ishaAngle: 18, ihtiyatMinutes: 2),
  muslimWorldLeague('Muslim World League', fajrAngle: 18, ishaAngle: 17),
  ummAlQura('Umm al-Qura', fajrAngle: 18.5, ishaMinutesAfterMaghrib: 90),
  isna('ISNA', fajrAngle: 15, ishaAngle: 15),
  egypt('Mesir', fajrAngle: 19.5, ishaAngle: 17.5),
  jakim('JAKIM Malaysia', fajrAngle: 20, ishaAngle: 18, ihtiyatMinutes: 1);

  final String label;
  final double fajrAngle;
  final double? ishaAngle;
  final int? ishaMinutesAfterMaghrib;
  final int ihtiyatMinutes;

  const CalculationMethod(
    this.label, {
    required this.fajrAngle,
    this.ishaAngle,
    this.ishaMinutesAfterMaghrib,
    this.ihtiyatMinutes = 0,
  });
}

/// Hasil perhitungan satu hari (waktu lokal sesuai offset yang diberikan).
class PrayerTimes {
  final DateTime date;
  final DateTime imsak;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTimes({
    required this.date,
    required this.imsak,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  DateTime timeOf(Prayer p) => switch (p) {
        Prayer.fajr => fajr,
        Prayer.dhuhr => dhuhr,
        Prayer.asr => asr,
        Prayer.maghrib => maghrib,
        Prayer.isha => isha,
      };

  /// Waktu sholat pertama yang jatuh setelah [now], atau `null` jika sudah lewat Isya.
  Prayer? nextAfter(DateTime now) {
    for (final p in Prayer.values) {
      if (timeOf(p).isAfter(now)) return p;
    }
    return null;
  }

  /// Waktu sholat terakhir yang sudah masuk pada [now], atau `null` sebelum Subuh.
  Prayer? currentAt(DateTime now) {
    Prayer? current;
    for (final p in Prayer.values) {
      if (!timeOf(p).isAfter(now)) current = p;
    }
    return current;
  }
}

/// Kalkulator jadwal sholat berbasis posisi matahari.
class PrayerCalculator {
  final CalculationMethod method;
  final AsrMadhab madhab;

  /// Penyesuaian manual (menit) per waktu sholat, misalnya mengikuti masjid lokal.
  final Map<Prayer, int> adjustments;

  /// Jarak imsak sebelum Subuh (menit).
  final int imsakMinutesBeforeFajr;

  const PrayerCalculator(
    this.method, {
    this.madhab = AsrMadhab.shafii,
    this.adjustments = const {},
    this.imsakMinutesBeforeFajr = 10,
  });

  PrayerTimes compute(DateTime date, Coordinates c, {required double utcOffsetHours}) {
    final jd = julianDay(date.year, date.month, date.day) - c.longitude / (15 * 24);
    final lat = c.latitude;

    // Iterasi dua kali: perkiraan awal, lalu posisi matahari pada jam tiap waktu.
    var t = <String, double>{
      'fajr': 5, 'sunrise': 6, 'dhuhr': 12, 'asr': 13, 'maghrib': 18, 'isha': 18,
    };
    for (var i = 0; i < 2; i++) {
      double sun(double hour, double angle, {bool ccw = false}) {
        final p = sunPosition(jd + hour / 24);
        final noon = _midDay(jd, hour);
        final x = (-math.sin(dtr(angle)) - math.sin(dtr(p.declination)) * math.sin(dtr(lat))) /
            (math.cos(dtr(p.declination)) * math.cos(dtr(lat)));
        final v = rtd(math.acos(x.clamp(-1.0, 1.0))) / 15.0;
        return noon + (ccw ? -v : v);
      }

      double asrTime(double hour) {
        final p = sunPosition(jd + hour / 24);
        final factor = madhab == AsrMadhab.shafii ? 1 : 2;
        final angle = -rtd(_acot(factor + math.tan(dtr((lat - p.declination).abs()))));
        return sun(hour, angle);
      }

      t = {
        'fajr': sun(t['fajr']!, method.fajrAngle, ccw: true),
        'sunrise': sun(t['sunrise']!, 0.833, ccw: true),
        'dhuhr': _midDay(jd, t['dhuhr']!),
        'asr': asrTime(t['asr']!),
        'maghrib': sun(t['maghrib']!, 0.833),
        'isha': method.ishaAngle != null ? sun(t['isha']!, method.ishaAngle!) : t['isha']!,
      };
    }
    if (method.ishaMinutesAfterMaghrib != null) {
      t['isha'] = t['maghrib']! + method.ishaMinutesAfterMaghrib! / 60.0;
    }

    final shift = utcOffsetHours - c.longitude / 15.0;
    final day = DateTime(date.year, date.month, date.day);
    final ih = method.ihtiyatMinutes;

    DateTime at(double hoursUtcLocal, {required int extra, bool roundUp = true}) {
      final h = hoursUtcLocal + shift;
      final secs = h * 3600 + extra * 60;
      final mins = roundUp ? (secs / 60).ceil() : (secs / 60).floor();
      return day.add(Duration(minutes: mins));
    }

    int adj(Prayer p) => adjustments[p] ?? 0;

    final fajr = at(t['fajr']!, extra: ih + adj(Prayer.fajr));
    return PrayerTimes(
      date: day,
      imsak: fajr.subtract(Duration(minutes: imsakMinutesBeforeFajr)),
      fajr: fajr,
      sunrise: at(t['sunrise']!, extra: -ih, roundUp: false),
      dhuhr: at(t['dhuhr']!, extra: ih + adj(Prayer.dhuhr)),
      asr: at(t['asr']!, extra: ih + adj(Prayer.asr)),
      maghrib: at(t['maghrib']!, extra: ih + adj(Prayer.maghrib)),
      isha: at(t['isha']!, extra: ih + adj(Prayer.isha)),
    );
  }

  /// Jam transit matahari (UT + bujur/15, sebelum offset zona waktu).
  static double _midDay(double jd, double hour) {
    final eqt = sunPosition(jd + hour / 24).equation;
    return fixHour(12 - eqt);
  }

  static double _acot(double x) => math.atan(1 / x);
}
