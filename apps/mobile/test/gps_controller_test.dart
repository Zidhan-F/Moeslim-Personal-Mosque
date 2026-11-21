import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moeslim_mobile/core/location_service.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:personal_core/personal_core.dart';

class _TestLocationService implements LocationService {
  bool serviceEnabled;
  LocationPermissionState permission;
  LocationPermissionState requestResult;
  GpsPosition? currentPosition;
  Object? positionError;
  int openLocationSettingsCalls = 0;
  int openAppSettingsCalls = 0;
  int requestPermissionCalls = 0;

  final serviceController = StreamController<bool>.broadcast();
  final positionController = StreamController<GpsPosition>.broadcast();

  _TestLocationService({
    this.serviceEnabled = true,
    this.permission = LocationPermissionState.granted,
    LocationPermissionState? requestResult,
    this.currentPosition,
    this.positionError,
  }) : requestResult = requestResult ?? permission;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Stream<bool> serviceStatusStream() => serviceController.stream;

  @override
  Future<LocationPermissionState> checkPermission() async => permission;

  @override
  Future<LocationPermissionState> requestPermission() async {
    requestPermissionCalls++;
    permission = requestResult;
    return permission;
  }

  @override
  Future<GpsPosition> getCurrentPosition() async {
    if (positionError != null) throw positionError!;
    if (currentPosition != null) return currentPosition!;
    return positionController.stream.first;
  }

  @override
  Stream<GpsPosition> positionStream() => positionController.stream;

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }

  void dispose() {
    serviceController.close();
    positionController.close();
  }
}

class _FixedDeclinationService implements DeclinationService {
  final double value;
  int calls = 0;
  _FixedDeclinationService(this.value);

  @override
  Future<double> getDeclination(GpsPosition position) async {
    calls++;
    return value;
  }
}

final _surabayaPos = GpsPosition(
  latitude: -7.2575,
  longitude: 112.7521,
  altitude: 12.0,
  accuracyMeters: 7.5,
  timestamp: DateTime.utc(2026, 11, 21, 10, 0),
);

void main() {
  test('status GPS nonaktif menghasilkan GpsServiceDisabled dan tidak mengambil posisi', () async {
    final fake = _TestLocationService(serviceEnabled: false, currentPosition: _surabayaPos);
    addTearDown(fake.dispose);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(_FixedDeclinationService(0.8)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(gpsControllerProvider.notifier).ensureActive();
    expect(container.read(gpsControllerProvider), isA<GpsServiceDisabled>());
  });

  test('GPS aktif + izin diberikan mengunci koordinat & menghitung deklinasi magnetik', () async {
    final fake = _TestLocationService(serviceEnabled: true, currentPosition: _surabayaPos);
    addTearDown(fake.dispose);
    final decl = _FixedDeclinationService(0.85);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(decl),
      ],
    );
    addTearDown(container.dispose);

    await container.read(gpsControllerProvider.notifier).ensureActive();
    final state = container.read(gpsControllerProvider);
    expect(state, isA<GpsReady>());
    final ready = state as GpsReady;
    expect(ready.position.latitude, -7.2575);
    expect(ready.position.longitude, 112.7521);
    expect(ready.declinationDegrees, closeTo(0.85, 1e-6));
    expect(decl.calls, 1);
  });

  test('GPS dimatikan di tengah sesi langsung mengunci balik ke GpsServiceDisabled', () async {
    final fake = _TestLocationService(serviceEnabled: true, currentPosition: _surabayaPos);
    addTearDown(fake.dispose);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(_FixedDeclinationService(0.5)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(gpsControllerProvider.notifier).ensureActive();
    expect(container.read(gpsControllerProvider), isA<GpsReady>());

    fake.serviceEnabled = false;
    fake.serviceController.add(false);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(container.read(gpsControllerProvider), isA<GpsServiceDisabled>());

    // Saat GPS dinyalakan kembali, otomatis mencari & mengunci ulang.
    fake.serviceEnabled = true;
    fake.serviceController.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(container.read(gpsControllerProvider), isA<GpsReady>());
  });

  test('izin ditolak -> GpsPermissionDenied; setelah diminta & disetujui -> GpsReady', () async {
    final fake = _TestLocationService(
      serviceEnabled: true,
      permission: LocationPermissionState.denied,
      requestResult: LocationPermissionState.granted,
      currentPosition: _surabayaPos,
    );
    addTearDown(fake.dispose);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(_FixedDeclinationService(0.5)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(gpsControllerProvider.notifier).ensureActive();
    expect(container.read(gpsControllerProvider), isA<GpsPermissionDenied>());

    await container.read(gpsControllerProvider.notifier).requestPermissionAndStart();
    expect(fake.requestPermissionCalls, 1);
    expect(container.read(gpsControllerProvider), isA<GpsReady>());
  });

  test('izin ditolak permanen -> GpsPermissionDeniedForever', () async {
    final fake = _TestLocationService(
      serviceEnabled: true,
      permission: LocationPermissionState.deniedForever,
      currentPosition: _surabayaPos,
    );
    addTearDown(fake.dispose);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(_FixedDeclinationService(0.5)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(gpsControllerProvider.notifier).ensureActive();
    expect(container.read(gpsControllerProvider), isA<GpsPermissionDeniedForever>());
  });

  test('syncToPrayerSettings menyimpan deviceLocation & mengaktifkan useDeviceLocation', () async {
    final fake = _TestLocationService(serviceEnabled: true, currentPosition: _surabayaPos);
    addTearDown(fake.dispose);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(_FixedDeclinationService(0.5)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(settingsProvider.future);
    final result = await container.read(gpsControllerProvider.notifier).syncToPrayerSettings();
    expect(result, isA<GpsReady>());

    final settings = container.read(settingsProvider).value!;
    expect(settings.useDeviceLocation, isTrue);
    expect(settings.deviceLocation, isNotNull);
    expect(settings.deviceLocation!.label, 'Surabaya');
    expect(settings.deviceLocation!.latitude, closeTo(-7.2575, 1e-6));
    expect(settings.deviceLocation!.longitude, closeTo(112.7521, 1e-6));
  });

  test('timeout saat mengunci GPS menghasilkan GpsError dengan pesan ramah', () async {
    final fake = _TestLocationService(
      serviceEnabled: true,
      positionError: TimeoutException('timeout'),
    );
    addTearDown(fake.dispose);
    final store = InMemoryStore();
    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(fake),
        declinationServiceProvider.overrideWithValue(_FixedDeclinationService(0.5)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(gpsControllerProvider.notifier).ensureActive();
    final state = container.read(gpsControllerProvider);
    expect(state, isA<GpsError>());
    expect((state as GpsError).message, contains('Sinyal GPS belum terkunci'));
  });
}
