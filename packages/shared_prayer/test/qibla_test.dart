import 'package:shared_prayer/shared_prayer.dart';
import 'package:test/test.dart';

void main() {
  group('WGS84 geodetic Qibla bearing & distance', () {
    final cases = <String, (Coordinates, double, double)>{
      'Jakarta': (const Coordinates(-6.1754, 106.8272), 295.0191, 7918.83),
      'Surabaya': (const Coordinates(-7.2575, 112.7521), 293.9130, 8564.64),
      'Banda Aceh': (const Coordinates(5.5483, 95.3238), 292.0727, 6224.61),
      'Makassar': (const Coordinates(-5.1477, 119.4327), 292.3738, 9153.25),
      'Jayapura': (const Coordinates(-2.5337, 140.7181), 291.2818, 11247.48),
      'London': (const Coordinates(51.5074, -0.1278), 118.8684, 4794.76),
      'New York': (const Coordinates(40.7128, -74.0060), 58.3960, 10323.92),
      'Tokyo': (const Coordinates(35.6762, 139.6503), 293.0720, 9487.88),
      'Sydney': (const Coordinates(-33.8688, 151.2093), 277.3188, 13236.95),
    };

    for (final entry in cases.entries) {
      test('${entry.key} bearing & distance presisi WGS84', () {
        final (coord, expectedBearing, expectedKm) = entry.value;
        expect(qiblaBearing(coord), closeTo(expectedBearing, 0.01));
        expect(distanceToKaabaKm(coord), closeTo(expectedKm, 0.5));
      });
    }

    test('koordinat tepat di Ka\'bah tidak menghasilkan NaN', () {
      expect(qiblaBearing(kaaba), 0.0);
      expect(distanceToKaabaKm(kaaba), 0.0);
    });

    test('antipode Ka\'bah tetap konvergen aman tanpa NaN', () {
      final antipode = Coordinates(-kaaba.latitude, kaaba.longitude - 180);
      final bearing = qiblaBearing(antipode);
      final dist = distanceToKaabaKm(antipode);
      expect(bearing.isFinite, isTrue);
      expect(bearing, inInclusiveRange(0.0, 360.0));
      expect(dist, closeTo(20004, 25));
    });
  });

  group('True north declination & angular helpers', () {
    test('applyMagneticDeclination mengoreksi deklinasi timur (+), barat (-), dan sudut negatif Android', () {
      expect(applyMagneticDeclination(0, 1.5), closeTo(1.5, 1e-6));
      expect(applyMagneticDeclination(359, 2.5), closeTo(1.5, 1e-6));
      expect(applyMagneticDeclination(0, -2.0), closeTo(358.0, 1e-6));
      expect(applyMagneticDeclination(-90, -1.5), closeTo(268.5, 1e-6));
      expect(applyMagneticDeclination(-65, 0.8), closeTo(295.8, 1e-6));
    });

    test('shortestAngleDelta mengembalikan selisih bertanda dalam (-180, 180]', () {
      expect(shortestAngleDelta(285, 295), closeTo(10, 1e-6));
      expect(shortestAngleDelta(305, 295), closeTo(-10, 1e-6));
      expect(shortestAngleDelta(355, 5), closeTo(10, 1e-6));
      expect(shortestAngleDelta(5, 355), closeTo(-10, 1e-6));
      expect(shortestAngleDelta(295, 295), closeTo(0, 1e-6));
      expect(shortestAngleDelta(10, 190), closeTo(180, 1e-6));
    });

    test('smoothHeading menghaluskan lintas 359° <-> 1° tanpa loncatan ke 180°', () {
      expect(smoothHeading(359, 1, alpha: 0.25), closeTo(359.5, 1e-6));
      expect(smoothHeading(1, 359, alpha: 0.25), closeTo(0.5, 1e-6));
      expect(smoothHeading(290, 294, alpha: 0.5), closeTo(292.0, 1e-6));
    });

    test('isAlignedWithQibla mengecek toleransi termasuk lintas 0°/360°', () {
      expect(isAlignedWithQibla(295.0, 295.0), isTrue);
      expect(isAlignedWithQibla(293.1, 295.0, toleranceDeg: 2.0), isTrue);
      expect(isAlignedWithQibla(297.0, 295.0, toleranceDeg: 2.0), isTrue);
      expect(isAlignedWithQibla(292.9, 295.0, toleranceDeg: 2.0), isFalse);
      expect(isAlignedWithQibla(359.0, 0.5, toleranceDeg: 2.0), isTrue);
      expect(isAlignedWithQibla(1.0, 358.5, toleranceDeg: 2.0), isFalse);
    });
  });
}
