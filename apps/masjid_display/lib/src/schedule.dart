import 'package:shared_prayer/shared_prayer.dart';

/// Offset UTC untuk zona waktu masjid. Indonesia tidak memakai DST.
double utcOffsetFor(String timezone) => switch (timezone) {
  'Asia/Jakarta' || 'Asia/Pontianak' => 7,
  'Asia/Makassar' => 8,
  'Asia/Jayapura' => 9,
  _ => DateTime.now().timeZoneOffset.inMinutes / 60,
};

enum SchedulePhase { beforeAdhan, beforeIqamah, praying }

class ScheduleStatus {
  final SchedulePhase phase;
  final Prayer prayer;
  final DateTime target;
  final Duration remaining;
  final bool isJumuah;
  const ScheduleStatus(this.phase, this.prayer, this.target, this.remaining, {this.isJumuah = false});
}

/// Jadwal dihitung lokal dari koordinat masjid sehingga tetap berjalan saat offline.
class DisplaySchedule {
  static const prayingWindow = Duration(minutes: 15);
  static const defaultJumuahMinutes = 45;

  final Coordinates coordinates;
  final double utcOffset;
  final PrayerCalculator calculator;
  final Map<Prayer, int> iqamahMinutes;
  final Map<Prayer, int> prayingMinutes;
  final int jumuahMinutes;
  final int hijriOffset;

  DisplaySchedule({
    required this.coordinates,
    required this.utcOffset,
    required this.calculator,
    required this.iqamahMinutes,
    this.prayingMinutes = const {},
    this.jumuahMinutes = defaultJumuahMinutes,
    this.hijriOffset = 0,
  });

  factory DisplaySchedule.fromMosque(Map<String, dynamic> m) {
    final settings = Map<String, dynamic>.from(m['settings'] as Map? ?? const {});
    Map<Prayer, int> perPrayer(Object? raw, {int fallback = 0}) => {
      for (final p in Prayer.values) p: ((raw as Map?)?[p.name] as num?)?.toInt() ?? fallback,
    };
    final prayingRaw = settings['praying_minutes'] as Map?;
    final method =
        CalculationMethod.values.where((v) => v.name == m['prayer_method']).firstOrNull ?? CalculationMethod.kemenag;
    return DisplaySchedule(
      coordinates: Coordinates((m['latitude'] as num).toDouble(), (m['longitude'] as num).toDouble()),
      utcOffset: utcOffsetFor(m['timezone'] as String? ?? 'Asia/Jakarta'),
      calculator: PrayerCalculator(method, adjustments: perPrayer(settings['prayer_adjustments'])),
      iqamahMinutes: perPrayer(settings['iqamah_minutes']),
      prayingMinutes: perPrayer(prayingRaw, fallback: prayingWindow.inMinutes),
      jumuahMinutes: (prayingRaw?['jumuah'] as num?)?.toInt() ?? defaultJumuahMinutes,
      hijriOffset: (settings['hijri_offset_days'] as num?)?.toInt() ?? 0,
    );
  }

  PrayerTimes timesFor(DateTime day) => calculator.compute(day, coordinates, utcOffsetHours: utcOffset);

  /// Jam dinding masjid dari waktu absolut (koreksi selisih jam server sudah diterapkan pemanggil).
  DateTime wallClock(DateTime instant) {
    final t = instant.toUtc().add(Duration(minutes: (utcOffset * 60).round()));
    return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
  }

  Duration _prayingDurationFor(Prayer p, {required bool isJumuah}) {
    if (isJumuah) return Duration(minutes: jumuahMinutes);
    return Duration(minutes: prayingMinutes[p] ?? prayingWindow.inMinutes);
  }

  /// [now] adalah jam dinding masjid.
  ScheduleStatus statusAt(DateTime now) {
    final today = timesFor(now);
    final isFriday = now.weekday == DateTime.friday;
    for (final p in Prayer.values) {
      final adhan = today.timeOf(p);
      final isJumuah = isFriday && p == Prayer.dhuhr;
      final iqamah = adhan.add(Duration(minutes: iqamahMinutes[p] ?? 0));
      if (now.isBefore(adhan)) {
        return ScheduleStatus(SchedulePhase.beforeAdhan, p, adhan, adhan.difference(now), isJumuah: isJumuah);
      }
      if (now.isBefore(iqamah)) {
        return ScheduleStatus(SchedulePhase.beforeIqamah, p, iqamah, iqamah.difference(now), isJumuah: isJumuah);
      }
      final prayingEnd = iqamah.add(_prayingDurationFor(p, isJumuah: isJumuah));
      if (now.isBefore(prayingEnd)) {
        return ScheduleStatus(SchedulePhase.praying, p, iqamah, prayingEnd.difference(now), isJumuah: isJumuah);
      }
    }
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    final fajr = timesFor(nextDay).fajr;
    return ScheduleStatus(SchedulePhase.beforeAdhan, Prayer.fajr, fajr, fajr.difference(now));
  }
}
