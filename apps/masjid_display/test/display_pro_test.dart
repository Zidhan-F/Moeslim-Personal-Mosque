import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_display/main.dart';
import 'package:display_ui/display_ui.dart';
import 'package:moeslim_display/src/screens.dart';
import 'package:moeslim_display/src/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_prayer/shared_prayer.dart';

Map<String, dynamic> _proContent({
  Map<String, dynamic>? finance,
  Map<String, dynamic>? qris,
  Map<String, dynamic>? override,
  Map<String, dynamic>? fridayStaff,
  bool silentPrayerScreen = true,
  bool iqamahBeep = true,
  Map<String, int>? prayingMinutes,
}) => {
  'server_time': '2025-01-03T05:00:00+00:00',
  'mosque': {
    'id': 'M1',
    'name': 'Masjid Al-Ikhlas',
    'address': 'Jl. Merdeka',
    'city': 'Jakarta',
    'latitude': -6.1754,
    'longitude': 106.8272,
    'timezone': 'Asia/Jakarta',
    'prayer_method': 'kemenag',
    'settings': {
      'iqamah_minutes': {'fajr': 10, 'dhuhr': 10, 'asr': 10, 'maghrib': 5, 'isha': 10},
      'praying_minutes': prayingMinutes ??
          {'fajr': 15, 'dhuhr': 15, 'asr': 15, 'maghrib': 12, 'isha': 15, 'jumuah': 45},
      'silent_prayer_screen': silentPrayerScreen,
      'silent_prayer_message': 'Luruskan & Rapatkan Shaf • Harap Tenangkan Ponsel',
      'iqamah_beep': iqamahBeep,
      'prayer_adjustments': {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
      'hijri_offset_days': 0,
    },
  },
  'events': [],
  'announcements': [],
  'staff_today': [
    {'duty_type': 'imam', 'prayer': 'maghrib', 'name': 'H. Ahmad'},
  ],
  'friday_staff': fridayStaff,
  'finance': finance,
  'qris': qris,
  'override': override,
  'device': {'id': 1, 'name': 'TV', 'config': {}},
};

Future<void> _pumpPro(
  WidgetTester tester,
  Map<String, dynamic> payload, {
  required DateTime now,
  Stream<DateTime>? clockStream,
  VoidCallback? onBeep,
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'display.token': 't',
    'display.content': jsonEncode(payload),
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        httpClientProvider.overrideWithValue(MockClient((_) async => http.Response('', 304))),
        nowProvider.overrideWith((ref) => clockStream ?? Stream.value(now)),
        clockProvider.overrideWithValue(() => now),
        if (onBeep != null) beepCallbackProvider.overrideWithValue(onBeep),
      ],
      child: const DisplayApp(),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  test('DisplaySchedule memakai durasi khusus Jumat (jumuah) pada Dzuhur hari Jumat', () {
    final s = DisplaySchedule.fromMosque(_proContent()['mosque'] as Map<String, dynamic>);
    // 2025-01-03 adalah hari Jumat!
    final fridayDhuhr = s.timesFor(DateTime(2025, 1, 3)).dhuhr;
    // 35 menit setelah adzan (melewati iqamah 10m + jendela biasa 15m, tapi masih dalam jumuah 45m).
    final duringJumuah = s.statusAt(fridayDhuhr.add(const Duration(minutes: 35)));
    expect(duringJumuah.phase, SchedulePhase.praying);
    expect(duringJumuah.prayer, Prayer.dhuhr);
    expect(duringJumuah.isJumuah, isTrue);

    // Hari biasa (Rabu 2025-01-01): 35 menit setelah adzan Dzuhur sudah lewat fase salat (10 + 15 = 25m).
    final wedDhuhr = s.timesFor(DateTime(2025, 1, 1)).dhuhr;
    final afterNormal = s.statusAt(wedDhuhr.add(const Duration(minutes: 35)));
    expect(afterNormal.phase, SchedulePhase.beforeAdhan);
    expect(afterNormal.prayer, Prayer.asr);
    expect(afterNormal.isJumuah, isFalse);
  });

  testWidgets('Override Berita Duka mengambil alih seluruh layar TV hingga kedaluwarsa', (tester) async {
    final now = DateTime.utc(2025, 1, 3, 4, 30); // 11:30 WIB
    await _pumpPro(
      tester,
      _proContent(
        override: {
          'type': 'duka',
          'title': 'Berita Duka',
          'body': 'Telah berpulang Bapak H. Budi Santoso. Jenazah disalatkan bakda Dzuhur.',
          'expires_at': now.add(const Duration(minutes: 30)).toIso8601String(),
        },
      ),
      now: now,
    );

    expect(find.byKey(const Key('tv-override-screen')), findsOneWidget);
    expect(find.textContaining('Inna Lillahi'), findsOneWidget);
    expect(find.text('Berita Duka'), findsOneWidget);
    expect(find.textContaining('H. Budi Santoso'), findsOneWidget);
  });

  testWidgets('Layar hening otomatis tampil saat fase salat / Khutbah Jumat', (tester) async {
    // 2025-01-03 (Jumat) 12:25 WIB (05:25 UTC) -> dalam jendela Khutbah & Sholat Jumat!
    final fridayPraying = DateTime.utc(2025, 1, 3, 5, 25);
    await _pumpPro(tester, _proContent(silentPrayerScreen: true), now: fridayPraying);

    expect(find.byKey(const Key('silent-prayer-screen')), findsOneWidget);
    expect(find.text('Khutbah & Sholat Jumat'), findsOneWidget);
    expect(find.textContaining('Luruskan & Rapatkan Shaf'), findsOneWidget);
  });

  testWidgets('Sinyal suara beep berbunyi sekali saat transisi masuk fase iqamah', (tester) async {
    var beeps = 0;
    final controller = StreamController<DateTime>.broadcast();
    addTearDown(controller.close);

    final start = DateTime.utc(2025, 1, 1, 4, 58); // 11:58 WIB (sebelum Dzuhur ~11:59)
    await _pumpPro(tester, _proContent(iqamahBeep: true), now: start, clockStream: controller.stream, onBeep: () => beeps++);

    controller.add(start);
    await tester.pump();
    await tester.pump();
    expect(beeps, 0);

    // Masuk fase iqamah Dzuhur (12:01 WIB)
    controller.add(DateTime.utc(2025, 1, 1, 5, 1));
    await tester.pump();
    await tester.pump();
    expect(beeps, 1);

    // Detik berikutnya masih di fase iqamah -> tidak spam beep
    controller.add(DateTime.utc(2025, 1, 1, 5, 1, 5));
    await tester.pump();
    await tester.pump();
    expect(beeps, 1);
  });

  testWidgets('Layar Informasi menampilkan Kas Jumat, kartu QRIS, dan Papan Petugas Jumat', (tester) async {
    // 11:30:45 WIB -> giliran layar Informasi Jamaah
    final infoTime = DateTime.utc(2025, 1, 3, 4, 30, 45);
    await _pumpPro(
      tester,
      _proContent(
        finance: {
          'balance': 4250000,
          'month_in': 3000000,
          'month_out': 1000000,
          'week_in': 950000,
          'week_out': 200000,
          'opening_balance': 3500000,
        },
        qris: {'enabled': true, 'label': 'QRIS Infaq Al-Ikhlas', 'url': '/api/display/qris'},
        fridayStaff: {
          'date': '2025-01-03',
          'items': [
            {'duty_type': 'khatib', 'prayer': 'dhuhr', 'name': 'Ust. Dr. Ahmad Fauzan'},
            {'duty_type': 'imam', 'prayer': 'dhuhr', 'name': 'Ust. Hafidz'},
          ],
        },
      ),
      now: infoTime,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('tv-qris-card')), findsOneWidget);
    expect(find.text('QRIS Infaq Al-Ikhlas'), findsOneWidget);
    expect(find.text('Rp950.000'), findsOneWidget);
    expect(find.byKey(const Key('friday-staff-board')), findsOneWidget);
    expect(find.textContaining('Ust. Dr. Ahmad Fauzan'), findsOneWidget);
  });
}
