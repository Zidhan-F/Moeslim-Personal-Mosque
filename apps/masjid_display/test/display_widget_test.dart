import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_display/main.dart';
import 'package:moeslim_display/src/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> content({Map<String, dynamic>? finance}) => {
      'server_time': '2025-01-01T05:00:00+00:00',
      'mosque': {
        'id': 'M1', 'name': 'Masjid Al-Ikhlas', 'address': 'Jl. Merdeka', 'city': 'Jakarta',
        'latitude': -6.1754, 'longitude': 106.8272, 'timezone': 'Asia/Jakarta', 'prayer_method': 'kemenag',
        'settings': {
          'iqamah_minutes': {'fajr': 10, 'dhuhr': 10, 'asr': 10, 'maghrib': 5, 'isha': 10},
          'prayer_adjustments': {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
          'hijri_offset_days': 0,
        },
      },
      'events': [
        {'id': 1, 'title': 'Kajian Ahad', 'category': 'kajian', 'speaker': 'Ust. Fulan', 'location': null, 'starts_at': '2025-01-05T00:00:00+00:00', 'ends_at': null},
      ],
      'announcements': [],
      'staff_today': [{'duty_type': 'imam', 'prayer': 'maghrib', 'name': 'H. Ahmad'}],
      'finance': finance,
      'device': {'id': 1, 'name': 'TV', 'config': {}},
    };

Future<void> pump(WidgetTester tester, http.Client client, {DateTime? now}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      httpClientProvider.overrideWithValue(client),
      nowProvider.overrideWith((ref) => Stream.value(now ?? DateTime.utc(2025, 1, 1, 4, 30))), // 11:30 WIB
      clockProvider.overrideWithValue(() => now ?? DateTime.utc(2025, 1, 1, 4, 30)),
    ],
    child: const DisplayApp(),
  ));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('belum dipasangkan: pairing lalu tampil konten masjid', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((req) async {
      if (req.url.path.endsWith('/display/pair')) {
        expect(jsonDecode(req.body)['code'], '123456');
        return http.Response(jsonEncode({'token': 'dev-token', 'mosque': {'name': 'Masjid Al-Ikhlas'}}), 201);
      }
      expect(req.headers['Authorization'], 'Bearer dev-token');
      return http.Response(jsonEncode(content()), 200, headers: {'etag': '"v1"'});
    });
    await pump(tester, client);
    expect(find.text('Hubungkan TV Display'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('pair-code')), '123456');
    await tester.tap(find.byKey(const Key('pair-submit')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('mosque-name')), findsOneWidget);
    expect(find.text('Masjid Al-Ikhlas'), findsOneWidget);
    // jam perangkat 11:30 WIB, server 12:00 WIB → jam layar dikoreksi ke jam server
    expect(tester.widget<Text>(find.byKey(const Key('clock'))).data, startsWith('12:00'));
    expect(find.text('Iqamah Dzuhur'), findsOneWidget); // azan Dzuhur ±11:59 WIB
    expect(find.textContaining('Kajian Ahad'), findsOneWidget);
    expect(find.text('Imam: H. Ahmad'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('display.token'), 'dev-token');
  });

  testWidgets('offline: tampil dari cache dengan label terakhir sinkron', (tester) async {
    SharedPreferences.setMockInitialValues({
      'display.token': 't',
      'display.content': jsonEncode(content(finance: {'balance': 1500000, 'month_in': 2000000, 'month_out': 500000})),
      'display.lastSync': DateTime(2025, 1, 1, 10, 15).toIso8601String(),
    });
    await pump(tester, MockClient((_) => throw Exception('offline')));
    expect(find.text('Masjid Al-Ikhlas'), findsOneWidget);
    expect(find.text('Menuju azan Dzuhur'), findsOneWidget); // 11:30 WIB tanpa koreksi jam
    expect(find.text('Rp1.500.000'), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.textContaining('10:15'), findsOneWidget);
  });

  testWidgets('perangkat dicabut (401) kembali ke layar pairing', (tester) async {
    SharedPreferences.setMockInitialValues({'display.token': 't', 'display.content': jsonEncode(content())});
    await pump(tester, MockClient((_) async => http.Response('{"message":"x"}', 401)));
    expect(find.text('Hubungkan TV Display'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('display.token'), isNull);
  });

  testWidgets('fase iqamah tampil setelah azan', (tester) async {
    SharedPreferences.setMockInitialValues({'display.token': 't', 'display.content': jsonEncode(content())});
    // 12:01 WIB (setelah azan Dzuhur ±11:59) — server tidak berubah (304)
    await pump(tester, MockClient((_) async => http.Response('', 304)), now: DateTime.utc(2025, 1, 1, 5, 1));
    expect(find.text('Iqamah Dzuhur'), findsOneWidget);
  });
}
