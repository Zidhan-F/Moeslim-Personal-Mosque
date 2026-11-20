import 'package:flutter_test/flutter_test.dart';
import 'package:moeslim_display/src/schedule.dart';
import 'package:shared_prayer/shared_prayer.dart';

Map<String, dynamic> mosque({Map<String, int>? iqamah}) => {
  'latitude': -6.1754,
  'longitude': 106.8272,
  'timezone': 'Asia/Jakarta',
  'prayer_method': 'kemenag',
  'settings': {
    'iqamah_minutes': iqamah ?? {'fajr': 10, 'dhuhr': 10, 'asr': 10, 'maghrib': 5, 'isha': 10},
    'prayer_adjustments': {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
    'hijri_offset_days': 0,
  },
};

void main() {
  test('offset zona waktu Indonesia', () {
    expect(utcOffsetFor('Asia/Jakarta'), 7);
    expect(utcOffsetFor('Asia/Makassar'), 8);
    expect(utcOffsetFor('Asia/Jayapura'), 9);
  });

  final schedule = DisplaySchedule.fromMosque(mosque());
  final dhuhr = schedule.timesFor(DateTime(2025, 1, 1)).dhuhr;

  test('sebelum azan: menuju waktu sholat', () {
    final s = schedule.statusAt(dhuhr.subtract(const Duration(minutes: 30)));
    expect(s.phase, SchedulePhase.beforeAdhan);
    expect(s.prayer, Prayer.dhuhr);
    expect(s.remaining, const Duration(minutes: 30));
  });

  test('setelah azan: hitung mundur iqamah', () {
    final s = schedule.statusAt(dhuhr.add(const Duration(minutes: 4)));
    expect(s.phase, SchedulePhase.beforeIqamah);
    expect(s.prayer, Prayer.dhuhr);
    expect(s.remaining, const Duration(minutes: 6));
  });

  test('setelah iqamah: sholat berlangsung, lalu menuju waktu berikutnya', () {
    expect(schedule.statusAt(dhuhr.add(const Duration(minutes: 12))).phase, SchedulePhase.praying);
    final later = schedule.statusAt(dhuhr.add(const Duration(minutes: 30)));
    expect(later.phase, SchedulePhase.beforeAdhan);
    expect(later.prayer, Prayer.asr);
  });

  test('setelah isya menuju subuh besok', () {
    final isha = schedule.timesFor(DateTime(2025, 1, 1)).isha;
    final s = schedule.statusAt(isha.add(const Duration(hours: 1)));
    expect(s.prayer, Prayer.fajr);
    expect(s.target.day, 2);
  });

  test('jeda iqamah mengikuti pengaturan masjid', () {
    final custom = DisplaySchedule.fromMosque(
      mosque(iqamah: {'fajr': 15, 'dhuhr': 3, 'asr': 10, 'maghrib': 5, 'isha': 10}),
    );
    final s = custom.statusAt(dhuhr.add(const Duration(minutes: 1)));
    expect(s.remaining, const Duration(minutes: 2));
  });
}
