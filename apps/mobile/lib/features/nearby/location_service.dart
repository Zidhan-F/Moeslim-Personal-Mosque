import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Posisi perangkat beserta akurasinya (meter).
class LocationFix {
  final double latitude;
  final double longitude;
  final double accuracyM;
  const LocationFix(this.latitude, this.longitude, this.accuracyM);

  /// Akurasi cukup untuk "masjid terdekat" (di dalam gedung GPS sering melenceng > 100 m).
  bool get precise => accuracyM <= 100;
}

enum LocationProblem { serviceDisabled, denied, deniedForever, unavailable }

class LocationException implements Exception {
  final LocationProblem problem;
  const LocationException(this.problem);

  String get message => switch (problem) {
    LocationProblem.serviceDisabled =>
      'Layanan lokasi (GPS) sedang mati. Nyalakan untuk menemukan masjid di sekitar Anda.',
    LocationProblem.denied => 'Izin lokasi belum diberikan.',
    LocationProblem.deniedForever => 'Izin lokasi ditolak permanen. Aktifkan lewat Pengaturan aplikasi.',
    LocationProblem.unavailable => 'Lokasi belum dapat ditentukan. Coba lagi di tempat terbuka.',
  };

  @override
  String toString() => message;
}

/// Abstraksi lokasi (GPS nyata di perangkat, palsu di test). Hanya dipakai saat aplikasi dibuka.
abstract class LocationService {
  Future<LocationFix> current();
  Future<void> openSettings();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationFix> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw const LocationException(LocationProblem.serviceDisabled);
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) throw const LocationException(LocationProblem.denied);
    if (perm == LocationPermission.deniedForever) throw const LocationException(LocationProblem.deniedForever);
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
      );
      return LocationFix(p.latitude, p.longitude, p.accuracy);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LocationFix(last.latitude, last.longitude, last.accuracy);
      throw const LocationException(LocationProblem.unavailable);
    }
  }

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => GeolocatorLocationService());
