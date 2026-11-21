import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';
import 'package:test/test.dart';

void main() {
  group('nearestIndonesianCity & formatGpsLocationLabel', () {
    test('menemukan kota terdekat di Indonesia beserta jaraknya', () {
      final nearBandung = nearestIndonesianCity(const Coordinates(-6.9175, 107.6191));
      expect(nearBandung, isNotNull);
      expect(nearBandung!.city.name, 'Bandung');
      expect(nearBandung.distanceKm, lessThan(1.0));

      final sumedang = nearestIndonesianCity(const Coordinates(-6.8586, 107.9207));
      expect(sumedang, isNotNull);
      expect(sumedang!.city.name, 'Bandung');
      expect(sumedang.distanceKm, greaterThan(15.0));
      expect(sumedang.distanceKm, lessThan(60.0));
    });

    test('mengembalikan null untuk koordinat di luar jangkauan Indonesia', () {
      expect(nearestIndonesianCity(const Coordinates(51.5074, -0.1278)), isNull);
    });

    test('formatGpsLocationLabel menghasilkan label offline yang ramah', () {
      expect(formatGpsLocationLabel(const Coordinates(-6.9175, 107.6191)), 'Bandung');
      expect(formatGpsLocationLabel(const Coordinates(-6.8586, 107.9207)), 'Sekitar Bandung');
      expect(formatGpsLocationLabel(const Coordinates(51.5074, -0.1278)), 'Lokasi GPS');
    });
  });

  group('DeviceLocation & PersonalSettings GPS efektif', () {
    test('DeviceLocation round-trip JSON menjaga koordinat, zona waktu, dan akurasi', () {
      final updatedAt = DateTime.utc(2026, 11, 21, 9, 30);
      final loc = DeviceLocation(
        latitude: -7.2575,
        longitude: 112.7521,
        utcOffset: 7,
        label: 'Surabaya',
        accuracyMeters: 8.5,
        updatedAt: updatedAt,
      );
      final restored = DeviceLocation.fromJson(loc.toJson());
      expect(restored.latitude, -7.2575);
      expect(restored.longitude, 112.7521);
      expect(restored.utcOffset, 7);
      expect(restored.label, 'Surabaya');
      expect(restored.accuracyMeters, 8.5);
      expect(restored.updatedAt, updatedAt);
      expect(restored.zone, 'WIB');
    });

    test('PersonalSettings memakai koordinat & zona waktu GPS ketika useDeviceLocation aktif', () {
      final gpsJayapura = DeviceLocation(
        latitude: -2.5337,
        longitude: 140.7181,
        utcOffset: 9,
        label: 'Jayapura',
        accuracyMeters: 6.0,
        updatedAt: DateTime.utc(2026, 11, 21, 10, 0),
      );
      final manualJakarta = PersonalSettings.defaults;
      final withGps = manualJakarta.copyWith(useDeviceLocation: true, deviceLocation: gpsJayapura);

      expect(withGps.isUsingGpsLocation, isTrue);
      expect(withGps.effectiveCoordinates.latitude, closeTo(-2.5337, 1e-6));
      expect(withGps.effectiveCoordinates.longitude, closeTo(140.7181, 1e-6));
      expect(withGps.effectiveUtcOffset, 9);
      expect(withGps.effectiveLocationName, 'Jayapura');
      expect(withGps.effectiveLocationSubtitle, 'Jayapura (GPS)');

      final date = DateTime(2025, 1, 1);
      final gpsTimes = withGps.timesFor(date);
      final expectedJayapuraTimes = manualJakarta.calculator.compute(
        date,
        const Coordinates(-2.5337, 140.7181),
        utcOffsetHours: 9,
      );
      expect(gpsTimes.fajr, expectedJayapuraTimes.fajr);
      expect(gpsTimes.maghrib, expectedJayapuraTimes.maghrib);
      // Pastikan berbeda nyata dari Jakarta.
      expect(gpsTimes.dhuhr.difference(manualJakarta.timesFor(date).dhuhr).inMinutes.abs(), greaterThan(10));
    });

    test('PersonalSettings tetap kompatibel dengan JSON lama tanpa deviceLocation', () {
      final legacyJson = PersonalSettings.defaults.toJson()..remove('deviceLocation');
      final restored = PersonalSettings.fromJson(legacyJson);
      expect(restored.deviceLocation, isNull);
      expect(restored.isUsingGpsLocation, isFalse);
      expect(restored.effectiveLocationName, 'Jakarta');
    });

    test('PersonalSettings menyimpan dan memuat deviceLocation lewat SettingsRepository', () async {
      final store = InMemoryStore();
      final repo = SettingsRepository(store);
      final gps = DeviceLocation(
        latitude: -6.9175,
        longitude: 107.6191,
        utcOffset: 7,
        label: 'Bandung',
        accuracyMeters: 12.0,
        updatedAt: DateTime.utc(2026, 11, 21, 10, 0),
      );
      await repo.save(PersonalSettings.defaults.copyWith(useDeviceLocation: true, deviceLocation: gps));

      final loaded = await SettingsRepository(store).load();
      expect(loaded.useDeviceLocation, isTrue);
      expect(loaded.deviceLocation?.label, 'Bandung');
      expect(loaded.deviceLocation?.accuracyMeters, 12.0);
    });
  });
}
