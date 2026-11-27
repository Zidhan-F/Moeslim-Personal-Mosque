import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

Map<String, dynamic> cellPayload(List<Map<String, dynamic>> data) => {
      'cell': 'qqgu',
      'attribution': ['© OpenStreetMap contributors (ODbL 1.0)'],
      'data': data,
    };

const istiqlal = {
  'id': 1,
  'name': 'Masjid Istiqlal',
  'kind': 'masjid',
  'lat': -6.1702,
  'lng': 106.8314,
  'verified': true,
  'mosque_slug': 'istiqlal',
  'source': 'osm'
};
const hidayah = {
  'id': 2,
  'name': 'Musholla Al-Hidayah',
  'kind': 'musala',
  'lat': -6.1820,
  'lng': 106.8290,
  'verified': false,
  'source': 'osm'
};
const sundaKelapa = {
  'id': 3,
  'name': 'Masjid Agung Sunda Kelapa',
  'kind': 'masjid',
  'lat': -6.2000,
  'lng': 106.8450,
  'source': 'osm'
};

void main() {
  group('geo', () {
    test('geohash cocok dengan nilai rujukan & batas sel memuat titik', () {
      expect(geohashEncode(57.64911, 10.40744, precision: 11), 'u4pruydqqvj');
      final h = geohashEncode(-6.1702, 106.8314, precision: 4);
      expect(h, 'qqgu');
      final (s, w, n, e) = geohashBounds(h);
      expect(-6.1702, inInclusiveRange(s, n));
      expect(106.8314, inInclusiveRange(w, e));
    });

    test('sel penutup radius: titik di tengah sel = 1 sel, dekat tepi = beberapa sel', () {
      final (s, w, n, e) = geohashBounds('qqgu');
      expect(cellsCovering((s + n) / 2, (w + e) / 2, 1000), {'qqgu'});
      final near = cellsCovering(s + 0.001, w + 0.001, 3000);
      expect(near.length, greaterThanOrEqualTo(3));
      expect(near, contains('qqgu'));
      // Setiap titik dalam radius berada di salah satu sel.
      for (final (dLat, dLng) in [(0.02, 0.0), (-0.02, 0.0), (0.0, 0.02), (0.0, -0.02)]) {
        expect(near, contains(geohashEncode(s + 0.001 + dLat, w + 0.001 + dLng, precision: 4)));
      }
    });

    test('jarak, arah, mata angin & format', () {
      expect(haversineMeters(0, 0, 0.01, 0), closeTo(1112, 2));
      expect(bearingDegrees(0, 0, 1, 0), closeTo(0, .01));
      expect(bearingDegrees(0, 0, 0, 1), closeTo(90, .01));
      expect(compassPointId(0), 'Utara');
      expect(compassPointId(135), 'Tenggara');
      expect(compassPointId(300), 'Barat Laut');
      expect(formatDistanceId(347), '350 m');
      expect(formatDistanceId(1234), '1,2 km');
      expect(formatDistanceId(15400), '15 km');
    });
  });

  group('DirectoryRepository', () {
    test('mengunduh sel, mengurutkan jarak, menyaring radius & menyimpan atribusi', () async {
      final fetched = <String>[];
      final repo = DirectoryRepository(InMemoryStore(), (cell) async {
        fetched.add(cell);
        return cell == 'qqgu' ? cellPayload([sundaKelapa, istiqlal, hidayah]) : cellPayload([]);
      });
      final r = await repo.nearby(-6.1750, 106.8300, 2000);
      expect(r.places.map((p) => p.place.name), ['Masjid Istiqlal', 'Musholla Al-Hidayah']); // Sunda Kelapa > 2 km
      expect(r.places.first.place.verified, isTrue);
      expect(r.places[1].place.isMusala, isTrue);
      expect(r.attribution, {'© OpenStreetMap contributors (ODbL 1.0)'});
      expect(fetched, contains('qqgu'));
      expect(r.stale, isFalse);
    });

    test('offline: memakai cache yang tersimpan & menandainya lama; tanpa cache dihitung hilang', () async {
      final store = InMemoryStore();
      var online = true;
      final repo = DirectoryRepository(store, (cell) async {
        if (!online) throw Exception('offline');
        return cellPayload([istiqlal]);
      });
      final t0 = DateTime(2026, 11, 1);
      await repo.nearby(-6.1702, 106.8314, 500, now: t0);

      online = false;
      final cached = await repo.nearby(-6.1702, 106.8314, 500, now: t0.add(const Duration(days: 1)));
      expect(cached.places.single.place.name, 'Masjid Istiqlal');
      expect(cached.stale, isFalse); // masih segar, tidak perlu jaringan

      final old = await repo.nearby(-6.1702, 106.8314, 500, now: t0.add(const Duration(days: 30)));
      expect(old.places, hasLength(1));
      expect(old.stale, isTrue);

      final fresh = DirectoryRepository(InMemoryStore(), (_) async => throw Exception('offline'));
      final none = await fresh.nearby(-6.1702, 106.8314, 500);
      expect(none.places, isEmpty);
      expect(none.missingCells, greaterThan(0));
    });

    test('pengunduhan ulang hanya setelah kedaluwarsa (7 hari)', () async {
      var calls = 0;
      final repo = DirectoryRepository(InMemoryStore(), (cell) async {
        calls++;
        return cellPayload([istiqlal]);
      });
      final (s, w, n, e) = geohashBounds('qqgu');
      final lat = (s + n) / 2, lng = (w + e) / 2;
      final t0 = DateTime(2026, 11, 1);
      await repo.nearby(lat, lng, 500, now: t0);
      await repo.nearby(lat, lng, 500, now: t0.add(const Duration(days: 6)));
      expect(calls, 1);
      await repo.nearby(lat, lng, 500, now: t0.add(const Duration(days: 8)));
      expect(calls, 2);
    });
  });
}
