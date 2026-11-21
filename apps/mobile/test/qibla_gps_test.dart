import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/core/location_service.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

final _surabayaGps = GpsPosition(
  latitude: -7.2575,
  longitude: 112.7521,
  altitude: 15,
  accuracyMeters: 8.0,
  timestamp: DateTime.utc(2026, 11, 21, 10, 0),
);

Future<void> _pumpQibla(
  WidgetTester tester, {
  required FakeLocationService locationService,
  double declinationDegrees = 0.0,
  Stream<CompassReading?>? compassStream,
}) async {
  final store = InMemoryStore();
  final container = ProviderContainer(
    overrides: [
      storeProvider.overrideWithValue(store),
      nowProvider.overrideWith((ref) => Stream.value(fixedNow)),
      locationServiceProvider.overrideWithValue(locationService),
      declinationServiceProvider.overrideWithValue(FakeDeclinationService(declinationDegrees)),
      compassProvider.overrideWith((ref) => compassStream ?? Stream.value(null)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: QiblaPage()),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('GPS nonaktif memblokir kompas kiblat dan menampilkan tombol Aktifkan GPS', (tester) async {
    final gps = FakeLocationService(serviceEnabled: false, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);

    await _pumpQibla(tester, locationService: gps);

    expect(find.byKey(const Key('qibla-gps-disabled')), findsOneWidget);
    expect(find.byKey(const Key('qibla-bearing')), findsNothing);
    expect(find.byKey(const Key('compass-dial')), findsNothing);

    await tester.tap(find.byKey(const Key('enable-gps')));
    await tester.pump();
    expect(gps.openLocationSettingsCalls, 1);
  });

  testWidgets('izin lokasi ditolak memblokir kompas dan tombol Izinkan Lokasi GPS membuka kembali setelah disetujui', (
    tester,
  ) async {
    final gps = FakeLocationService(
      serviceEnabled: true,
      permission: LocationPermissionState.denied,
      requestResult: LocationPermissionState.granted,
      currentPosition: _surabayaGps,
    );
    addTearDown(gps.dispose);

    await _pumpQibla(tester, locationService: gps);

    expect(find.byKey(const Key('qibla-permission-denied')), findsOneWidget);
    expect(find.byKey(const Key('qibla-bearing')), findsNothing);

    await tester.tap(find.byKey(const Key('request-location-permission')));
    await tester.pumpAndSettle();

    expect(gps.requestPermissionCalls, 1);
    expect(find.byKey(const Key('qibla-bearing')), findsOneWidget);
    // Surabaya WGS84 bearing = 293,9°, bukan Jakarta 295,0°!
    expect(tester.widget<Text>(find.byKey(const Key('qibla-bearing'))).data, '293,9°');
  });

  testWidgets('izin ditolak permanen memblokir kompas dan membuka pengaturan aplikasi', (tester) async {
    final gps = FakeLocationService(
      serviceEnabled: true,
      permission: LocationPermissionState.deniedForever,
      currentPosition: _surabayaGps,
    );
    addTearDown(gps.dispose);

    await _pumpQibla(tester, locationService: gps);

    expect(find.byKey(const Key('qibla-permission-forever')), findsOneWidget);
    expect(find.byKey(const Key('qibla-bearing')), findsNothing);

    await tester.tap(find.byKey(const Key('open-app-settings')));
    await tester.pump();
    expect(gps.openAppSettingsCalls, 1);
  });

  testWidgets('saat menunggu kunci GPS, kompas tidak memakai fallback kota Jakarta', (tester) async {
    final gps = FakeLocationService(serviceEnabled: true, holdPosition: true);
    addTearDown(gps.dispose);

    await _pumpQibla(tester, locationService: gps);

    expect(find.byKey(const Key('qibla-gps-acquiring')), findsOneWidget);
    expect(find.byKey(const Key('qibla-bearing')), findsNothing);

    gps.positionController.add(_surabayaGps);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('qibla-bearing')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('qibla-bearing'))).data, '293,9°');
  });

  testWidgets('GPS dimatikan saat kompas aktif langsung mengunci kembali halaman kiblat', (tester) async {
    final gps = FakeLocationService(serviceEnabled: true, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);

    await _pumpQibla(tester, locationService: gps);
    expect(find.byKey(const Key('qibla-bearing')), findsOneWidget);

    gps.serviceEnabled = false;
    gps.serviceController.add(false);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('qibla-gps-disabled')), findsOneWidget);
    expect(find.byKey(const Key('qibla-bearing')), findsNothing);
  });

  testWidgets('koreksi deklinasi magnetik + panduan arah tepat menghadap kiblat & putar kanan/kiri', (tester) async {
    final gps = FakeLocationService(serviceEnabled: true, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);
    final compass = StreamController<CompassReading?>.broadcast();
    addTearDown(compass.close);

    // Surabaya true bearing = 293.91°. Dengan deklinasi +1.0°, magnetic heading 292.9° -> true heading 293.9° (TEPAT!).
    await _pumpQibla(tester, locationService: gps, declinationDegrees: 1.0, compassStream: compass.stream);
    expect(find.byKey(const Key('qibla-declination')), findsOneWidget);

    compass.add(const CompassReading(magneticHeading: 292.9, accuracyDeg: 15));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('qibla-aligned')), findsOneWidget);
    expect(find.textContaining('Tepat Menghadap Kiblat'), findsOneWidget);

    // Hadap ke kiri 20° (magnetic 272.9° + 1.0° = 273.9°) -> perlu putar kanan.
    compass.add(const CompassReading(magneticHeading: 272.9, accuracyDeg: 15));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('qibla-aligned')), findsNothing);
    expect(find.textContaining('Putar kanan'), findsOneWidget);
  });

  testWidgets('peringatan muncul bila akurasi kompas rendah, GPS lemah (>50m), atau lokasi mock', (tester) async {
    final weakMockGps = GpsPosition(
      latitude: -7.2575,
      longitude: 112.7521,
      accuracyMeters: 85.0,
      timestamp: DateTime.utc(2026, 11, 21, 10, 0),
      isMocked: true,
    );
    final gps = FakeLocationService(serviceEnabled: true, currentPosition: weakMockGps);
    addTearDown(gps.dispose);

    await _pumpQibla(
      tester,
      locationService: gps,
      compassStream: Stream.value(const CompassReading(magneticHeading: 290.0, accuracyDeg: 45)),
    );

    expect(find.byKey(const Key('qibla-mock-warning')), findsOneWidget);
    expect(find.byKey(const Key('qibla-gps-weak')), findsOneWidget);
    expect(find.byKey(const Key('qibla-compass-low')), findsOneWidget);
  });

  testWidgets('halaman kiblat aman tanpa overflow pada layar sempit 360px, fontScale 1.3, dan mode gelap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final gps = FakeLocationService(serviceEnabled: true, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);
    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, themeMode: AppThemeMode.dark, fontScale: 1.3),
    );
    await pumpApp(tester, store: store, locationService: gps);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const QiblaPage()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qibla-gps-status')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('qibla-bearing')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('qibla-bearing')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
