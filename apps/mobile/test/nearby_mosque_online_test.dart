import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:moeslim_mobile/core/nearby_mosque_online.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

const _sample = '''
{"elements":[
 {"type":"node","id":1,"lat":-6.21,"lon":106.73,"tags":{"name":"Masjid Al-Ikhlas","addr:street":"Jl. Melati","addr:housenumber":"5","wheelchair":"yes"}},
 {"type":"way","id":2,"center":{"lat":-6.22,"lon":106.74},"tags":{"name":"Musholla An-Nur"}},
 {"type":"node","id":3,"lat":-6.23,"lon":106.75,"tags":{}},
 {"type":"relation","id":4,"tags":{"name":"Tanpa Koordinat"}}
]}''';

const _photonSample = '''
{"type":"FeatureCollection","features":[
 {"type":"Feature","geometry":{"type":"Point","coordinates":[106.7380,-6.2110]},"properties":{"osm_type":"W","osm_id":101,"name":"Masjid Al-Hidayah","street":"Jl. Cempaka","city":"Tangerang Selatan"}},
 {"type":"Feature","geometry":{"type":"Point","coordinates":[106.7400,-6.2150]},"properties":{"osm_type":"N","osm_id":102,"name":"Musholla","street":"Gg. Mawar","district":"Bintaro"}},
 {"type":"Feature","geometry":{"type":"Point","coordinates":[112.7150,-7.3365]},"properties":{"osm_type":"W","osm_id":999,"name":"Masjid Jauh Surabaya","city":"Surabaya"}}
]}''';

void main() {
  test('GoogleMosqueFinder: nonaktif tanpa key, parse & kirim permintaan saat dikonfigurasi', () async {
    expect(GoogleMosqueFinder(client: MockClient((_) async => http.Response('', 500))).enabled, isFalse);

    late http.Request seen;
    final client = MockClient((req) async {
      seen = req;
      return http.Response(
        '{"places":[{"id":"abc","displayName":{"text":"Masjid Raya"},"formattedAddress":"Jl. A","location":{"latitude":-6.2,"longitude":106.8},"rating":4.8,"userRatingCount":120},{"id":"x"}]}',
        200,
      );
    });
    final g = GoogleMosqueFinder(client: client, proxy: '', key: 'k');
    expect(g.enabled, isTrue);
    final r = await g.search(const Coordinates(-6.2, 106.8));
    expect(r, hasLength(1));
    expect(r.first.name, 'Masjid Raya');
    expect(r.first.facilities, contains('4.8'));
    expect(seen.headers['X-Goog-Api-Key'], 'k');
    expect(seen.body, contains('"mosque"'));
  });

  test('parseOverpass: node, way(center), tanpa nama, dan tanpa koordinat', () {
    final r = OnlineMosqueFinder.parseOverpass(_sample);
    expect(r, hasLength(3));
    expect(r[0].name, 'Masjid Al-Ikhlas');
    expect(r[0].address, 'Jl. Melati 5');
    expect(r[0].facilities, contains('Akses Disabilitas'));
    expect(r[1].kind, 'Musholla');
    expect(r[1].latitude, -6.22);
    expect(r[2].name, 'Masjid (tanpa nama)');
  });

  test('parsePhoton: menyaring jarak jauh, membentuk alamat, dan memperjelas nama generik', () {
    final r = OnlineMosqueFinder.parsePhoton(
      _photonSample,
      origin: const Coordinates(-6.2102, 106.7359),
      maxDistanceKm: 15,
    );
    expect(r, hasLength(2));
    expect(r[0].name, 'Masjid Al-Hidayah');
    expect(r[0].address, 'Jl. Cempaka, Tangerang Selatan');
    expect(r[1].name, 'Musholla Gg. Mawar');
    expect(r[1].kind, 'Musholla');
  });

  test('search: ambil dari jaringan, simpan cache, pakai cache saat jaringan putus', () async {
    final store = InMemoryStore();
    var calls = 0;
    var fail = false;
    final client = MockClient((req) async {
      calls++;
      if (fail) return http.Response('x', 500);
      expect(Uri.decodeQueryComponent(req.body), contains('around:5000,-6.2102,106.7359'));
      return http.Response.bytes(utf8.encode(_sample), 200);
    });
    var clock = DateTime(2026, 1, 1);
    final finder = OnlineMosqueFinder(client: client, store: store, now: () => clock);
    const origin = Coordinates(-6.2102, 106.7359);

    expect(await finder.search(origin), hasLength(3));
    expect(calls, 1);
    expect(await finder.search(origin), hasLength(3)); // dari cache
    expect(calls, 1);

    clock = clock.add(const Duration(days: 2));
    fail = true;
    expect(await finder.search(origin), hasLength(3)); // cache lama sebagai cadangan
    expect(calls, 4); // Overpass + 2 query Photon dicoba
  });

  test('search: fallback otomatis ke Photon OSM saat Overpass timeout/gagal', () async {
    final store = InMemoryStore();
    final urls = <String>[];
    final client = MockClient((req) async {
      urls.add(req.url.host);
      if (req.url.host.contains('overpass')) {
        return http.Response('Gateway Timeout', 504);
      }
      return http.Response.bytes(utf8.encode(_photonSample), 200);
    });
    final finder = OnlineMosqueFinder(client: client, store: store);
    final items = await finder.search(const Coordinates(-6.2102, 106.7359));

    expect(urls.first, contains('overpass'));
    expect(urls.any((h) => h.contains('photon.komoot.io')), isTrue);
    expect(items, hasLength(2));
    expect(items.map((m) => m.name), containsAll(['Masjid Al-Hidayah', 'Musholla Gg. Mawar']));
  });
}
