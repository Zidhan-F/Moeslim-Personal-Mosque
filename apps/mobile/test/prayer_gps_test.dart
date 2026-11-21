import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:moeslim_mobile/core/location_service.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/prayer/prayer_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

final _jayapuraGps = GpsPosition(
  latitude: -2.5337,
  longitude: 140.7181,
  altitude: 25.0,
  accuracyMeters: 5.0,
  timestamp: DateTime.utc(2025, 1, 1, 5, 0),
);

final _surabayaGps = GpsPosition(
  latitude: -7.2575,
  longitude: 112.7521,
  altitude: 10.0,
  accuracyMeters: 9.0,
  timestamp: DateTime.utc(2025, 1, 1, 5, 0),
);

void main() {
  test('computeStatus menggunakan effectiveUtcOffset dan koordinat GPS saat useDeviceLocation aktif', () {
    final gpsSettings = PersonalSettings.defaults.copyWith(
      useDeviceLocation: true,
      deviceLocation: _jayapuraGps.toDeviceLocation(),
    );
    // 2025-01-01 05:00 UTC = 12:00 WIB (Jakarta) = 14:00 WIT (Jayapura).
    final jakartaStatus = computeStatus(PersonalSettings.defaults, fixedNow);
    final jayapuraStatus = computeStatus(gpsSettings, fixedNow);

    expect(jakartaStatus.now.hour, 12);
    expect(jayapuraStatus.now.hour, 14);
    expect(jayapuraStatus.today.fajr, isNot(jakartaStatus.today.fajr));
  });

  testWidgets('Jadwal Salat dapat mengaktifkan GPS presisi dan langsung memperbarui jadwal & lokasi', (tester) async {
    final store = InMemoryStore();
    final gps = FakeLocationService(serviceEnabled: true, currentPosition: _jayapuraGps);
    addTearDown(gps.dispose);

    await pumpApp(tester, store: store, locationService: gps);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jakarta'), findsWidgets);
    expect(find.byKey(const Key('prayer-use-gps')), findsOneWidget);

    await tester.tap(find.byKey(const Key('prayer-use-gps')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jayapura (GPS)'), findsWidgets);
    expect(find.byKey(const Key('prayer-gps-active')), findsOneWidget);

    final saved = await SettingsRepository(store).load();
    expect(saved.useDeviceLocation, isTrue);
    expect(saved.deviceLocation?.label, 'Jayapura');
    expect(saved.deviceLocation?.utcOffset, 9.0);
  });

  testWidgets('Jadwal Salat dalam mode GPS menampilkan peringatan dan tombol Aktifkan GPS saat GPS mati', (
    tester,
  ) async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(
        onboardingDone: true,
        useDeviceLocation: true,
        deviceLocation: _surabayaGps.toDeviceLocation(),
      ),
    );
    final gps = FakeLocationService(serviceEnabled: false, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);

    await pumpApp(tester, store: store, locationService: gps);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prayer-gps-disabled')), findsOneWidget);
    await tester.tap(find.byKey(const Key('prayer-enable-gps')));
    await tester.pump();
    expect(gps.openLocationSettingsCalls, 1);
  });

  testWidgets('Pengaturan Jadwal: toggle Gunakan Lokasi GPS menyinkronkan GPS dan tombol Aktifkan GPS muncul bila mati', (
    tester,
  ) async {
    final store = InMemoryStore();
    final gps = FakeLocationService(serviceEnabled: false, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);

    await pumpApp(tester, store: store, locationService: gps);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('use-gps-switch')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-enable-gps')), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-enable-gps')));
    await tester.pump();
    expect(gps.openLocationSettingsCalls, 1);

    // Nyalakan GPS lalu perbarui.
    gps.serviceEnabled = true;
    await tester.tap(find.byKey(const Key('settings-refresh-gps')));
    await tester.pumpAndSettle();

    final saved = await SettingsRepository(store).load();
    expect(saved.useDeviceLocation, isTrue);
    expect(saved.deviceLocation?.label, 'Surabaya');
  });

  testWidgets('Beranda menampilkan lokasi GPS dengan kontras teks kartu >= 4.5:1', (tester) async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(
        onboardingDone: true,
        useDeviceLocation: true,
        deviceLocation: _surabayaGps.toDeviceLocation(),
      ),
    );
    final gps = FakeLocationService(serviceEnabled: true, currentPosition: _surabayaGps);
    addTearDown(gps.dispose);

    await pumpApp(tester, store: store, locationService: gps);
    expect(find.textContaining('Surabaya'), findsWidgets);
    expect(find.byKey(const Key('home-gps-badge')), findsOneWidget);

    final card = find.byKey(const Key('prayer-card'));
    for (final t in tester.widgetList<Text>(find.descendant(of: card, matching: find.byType(Text)))) {
      final color = t.style?.color ?? DefaultTextStyle.of(tester.element(find.byWidget(t))).style.color!;
      expect(
        contrastRatio(Color.alphaBlend(color, Colors.white), Colors.white),
        greaterThanOrEqualTo(4.5),
        reason: '"${t.data}"',
      );
    }
  });
}
