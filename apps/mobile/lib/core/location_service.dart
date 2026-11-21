import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'providers.dart';

enum LocationPermissionState { denied, deniedForever, granted }

/// Posisi GPS presisi dari sensor lokasi perangkat.
class GpsPosition {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final bool isMocked;

  const GpsPosition({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    required this.accuracyMeters,
    required this.timestamp,
    this.isMocked = false,
  });

  Coordinates get coordinates => Coordinates(latitude, longitude);

  /// Sinyal GPS dianggap lemah bila radius galat horizontal > 50 meter.
  bool get isLowAccuracy => accuracyMeters > 50.0;

  DeviceLocation toDeviceLocation() {
    final nearest = nearestIndonesianCity(coordinates);
    final utcOffset = nearest?.city.utcOffset ?? (DateTime.now().timeZoneOffset.inMinutes / 60.0);
    return DeviceLocation(
      latitude: latitude,
      longitude: longitude,
      utcOffset: utcOffset,
      label: formatGpsLocationLabel(coordinates),
      accuracyMeters: accuracyMeters,
      updatedAt: timestamp.toUtc(),
    );
  }
}

/// Kontrak layanan GPS perangkat (di-override di pengujian dengan implementasi tiruan).
abstract interface class LocationService {
  Future<bool> isServiceEnabled();
  Stream<bool> serviceStatusStream();
  Future<LocationPermissionState> checkPermission();
  Future<LocationPermissionState> requestPermission();
  Future<GpsPosition> getCurrentPosition();
  Stream<GpsPosition> positionStream();
  Future<bool> openLocationSettings();
  Future<bool> openAppSettings();
}

/// Implementasi produksi menggunakan plugin `geolocator`.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static LocationPermissionState _mapPermission(LocationPermission p) => switch (p) {
        LocationPermission.always || LocationPermission.whileInUse => LocationPermissionState.granted,
        LocationPermission.deniedForever => LocationPermissionState.deniedForever,
        LocationPermission.denied || LocationPermission.unableToDetermine => LocationPermissionState.denied,
      };

  static GpsPosition _mapPosition(Position p) => GpsPosition(
        latitude: p.latitude,
        longitude: p.longitude,
        altitude: p.altitude,
        accuracyMeters: p.accuracy,
        timestamp: p.timestamp,
        isMocked: p.isMocked,
      );

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Stream<bool> serviceStatusStream() =>
      Geolocator.getServiceStatusStream().map((status) => status == ServiceStatus.enabled);

  @override
  Future<LocationPermissionState> checkPermission() async => _mapPermission(await Geolocator.checkPermission());

  @override
  Future<LocationPermissionState> requestPermission() async => _mapPermission(await Geolocator.requestPermission());

  @override
  Future<GpsPosition> getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return _mapPosition(pos);
  }

  @override
  Stream<GpsPosition> positionStream() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 2,
        ),
      ).map(_mapPosition);

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

/// Layanan deklinasi magnetik (utara magnetik -> utara sejati) berbasis posisi GPS.
abstract interface class DeclinationService {
  Future<double> getDeclination(GpsPosition position);
}

/// Menggunakan Android `GeomagneticField` (World Magnetic Model) via MethodChannel.
class AndroidDeclinationService implements DeclinationService {
  static const _channel = MethodChannel('id.moeslim.moeslim_mobile/geomagnetic');

  const AndroidDeclinationService();

  @override
  Future<double> getDeclination(GpsPosition position) async {
    try {
      final result = await _channel.invokeMethod<double>('getDeclination', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'altitude': position.altitude,
        'timestampMs': position.timestamp.millisecondsSinceEpoch,
      });
      return result ?? 0.0;
    } on MissingPluginException {
      return 0.0;
    } on PlatformException {
      return 0.0;
    }
  }
}

/// Status siklus hidup GPS untuk Arah Kiblat dan Jadwal Salat.
sealed class GpsState {
  const GpsState();
}

class GpsChecking extends GpsState {
  const GpsChecking();
}

class GpsServiceDisabled extends GpsState {
  const GpsServiceDisabled();
}

class GpsPermissionDenied extends GpsState {
  const GpsPermissionDenied();
}

class GpsPermissionDeniedForever extends GpsState {
  const GpsPermissionDeniedForever();
}

class GpsAcquiring extends GpsState {
  const GpsAcquiring();
}

class GpsReady extends GpsState {
  final GpsPosition position;
  final double declinationDegrees;

  const GpsReady({required this.position, required this.declinationDegrees});
}

class GpsError extends GpsState {
  final String message;
  const GpsError(this.message);
}

final locationServiceProvider = Provider<LocationService>((ref) => const GeolocatorLocationService());

final declinationServiceProvider = Provider<DeclinationService>((ref) => const AndroidDeclinationService());

class GpsController extends Notifier<GpsState> {
  StreamSubscription<bool>? _serviceSub;
  StreamSubscription<GpsPosition>? _positionSub;
  int _epoch = 0;
  bool _disposed = false;
  GpsPosition? _lastDeclinationPos;
  double _cachedDeclination = 0.0;
  bool _hasDeclination = false;

  @override
  GpsState build() {
    _disposed = false;
    final service = ref.watch(locationServiceProvider);
    _serviceSub?.cancel();
    _serviceSub = service.serviceStatusStream().listen(_onServiceStatusChanged, onError: (_) {});

    ref.onDispose(() {
      _disposed = true;
      _epoch++;
      _serviceSub?.cancel();
      _positionSub?.cancel();
    });
    return const GpsChecking();
  }

  void _onServiceStatusChanged(bool enabled) {
    if (_disposed) return;
    if (!enabled) {
      _epoch++;
      _positionSub?.cancel();
      _positionSub = null;
      _hasDeclination = false;
      _lastDeclinationPos = null;
      state = const GpsServiceDisabled();
      return;
    }
    unawaited(ensureActive());
  }

  /// Memastikan status GPS aktif dan izin lokasi tersedia, lalu mengunci koordinat live.
  Future<GpsState> ensureActive({bool requestPermissionIfNeeded = false}) async {
    final epoch = ++_epoch;
    await _positionSub?.cancel();
    _positionSub = null;

    if (!_disposed && state is! GpsReady) {
      state = const GpsChecking();
    }

    final service = ref.read(locationServiceProvider);

    final enabled = await service.isServiceEnabled();
    if (_disposed || epoch != _epoch) return state;
    if (!enabled) {
      state = const GpsServiceDisabled();
      return state;
    }

    var permission = await service.checkPermission();
    if (_disposed || epoch != _epoch) return state;

    if (permission == LocationPermissionState.denied && requestPermissionIfNeeded) {
      permission = await service.requestPermission();
      if (_disposed || epoch != _epoch) return state;
    }

    if (permission == LocationPermissionState.denied) {
      state = const GpsPermissionDenied();
      return state;
    }
    if (permission == LocationPermissionState.deniedForever) {
      state = const GpsPermissionDeniedForever();
      return state;
    }

    state = const GpsAcquiring();

    // Mulai dengarkan pembaruan live GPS segera.
    _positionSub = service.positionStream().listen(
      (pos) => unawaited(_handlePosition(pos, epoch)),
      onError: (Object err) async {
        if (_disposed || epoch != _epoch) return;
        final stillOn = await service.isServiceEnabled();
        if (_disposed || epoch != _epoch) return;
        if (!stillOn) {
          state = const GpsServiceDisabled();
        } else if (state is! GpsReady) {
          state = GpsError(_friendlyError(err));
        }
      },
    );

    try {
      final pos = await service.getCurrentPosition();
      if (_disposed || epoch != _epoch) return state;
      await _handlePosition(pos, epoch);
    } catch (err) {
      if (_disposed || epoch != _epoch) return state;
      final stillOn = await service.isServiceEnabled();
      if (_disposed || epoch != _epoch) return state;
      if (!stillOn) {
        await _positionSub?.cancel();
        _positionSub = null;
        state = const GpsServiceDisabled();
      } else if (state is! GpsReady) {
        state = GpsError(_friendlyError(err));
      }
    }
    return state;
  }

  Future<GpsState> requestPermissionAndStart() => ensureActive(requestPermissionIfNeeded: true);

  Future<bool> openLocationSettings() => ref.read(locationServiceProvider).openLocationSettings();

  Future<bool> openAppSettings() => ref.read(locationServiceProvider).openAppSettings();

  /// Mengunci GPS lalu menyimpan lokasi presisi ke pengaturan untuk Jadwal Salat.
  Future<GpsState> syncToPrayerSettings() async {
    final result = await ensureActive(requestPermissionIfNeeded: true);
    if (result is GpsReady && !_disposed) {
      await _persistGpsToSettings(result.position, forceEnable: true);
    }
    return result;
  }

  Future<void> _handlePosition(GpsPosition pos, int epoch) async {
    if (_disposed || epoch != _epoch) return;
    final declination = await _resolveDeclination(pos);
    if (_disposed || epoch != _epoch) return;

    state = GpsReady(position: pos, declinationDegrees: declination);
    await _maybeSyncActivePrayerLocation(pos);
  }

  Future<double> _resolveDeclination(GpsPosition pos) async {
    if (_hasDeclination && _lastDeclinationPos != null) {
      final movedKm = distanceBetweenKm(_lastDeclinationPos!.coordinates, pos.coordinates);
      if (movedKm < 10.0) return _cachedDeclination;
    }
    final decl = await ref.read(declinationServiceProvider).getDeclination(pos);
    _lastDeclinationPos = pos;
    _cachedDeclination = decl;
    _hasDeclination = true;
    return decl;
  }

  Future<void> _maybeSyncActivePrayerLocation(GpsPosition pos) async {
    final current = ref.read(settingsProvider).value;
    if (current == null || !current.useDeviceLocation) return;
    final prev = current.deviceLocation;
    final shouldUpdate = prev == null ||
        distanceBetweenKm(prev.coordinates, pos.coordinates) >= 0.5 ||
        pos.timestamp.toUtc().difference(prev.updatedAt).inMinutes.abs() >= 5;
    if (shouldUpdate) {
      await _persistGpsToSettings(pos, forceEnable: false);
    }
  }

  Future<void> _persistGpsToSettings(GpsPosition pos, {required bool forceEnable}) async {
    final current = ref.read(settingsProvider).value;
    if (current == null || _disposed) return;
    await ref.read(settingsProvider.notifier).save(
          current.copyWith(
            useDeviceLocation: forceEnable ? true : current.useDeviceLocation,
            deviceLocation: pos.toDeviceLocation(),
          ),
        );
  }

  static String _friendlyError(Object err) {
    if (err is TimeoutException) {
      return 'Sinyal GPS belum terkunci. Pindah ke area yang lebih terbuka lalu coba lagi.';
    }
    return 'Gagal membaca lokasi GPS. Pastikan GPS aktif dan sinyal memadai.';
  }
}

final gpsControllerProvider = NotifierProvider<GpsController, GpsState>(GpsController.new);
