import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/masjid_home_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/nearby/location_service.dart';
import 'package:personal_core/personal_core.dart';

import 'fake_mosque_backend.dart';
import 'helpers.dart';

const istiqlal = {
  'id': 1,
  'name': 'Masjid Istiqlal',
  'kind': 'masjid',
  'lat': -6.1702,
  'lng': 106.8314,
  'address': 'Jl. Taman Wijaya Kusuma',
  'city': 'Jakarta Pusat',
  'verified': true,
  'mosque_slug': 'istiqlal',
  'source': 'osm',
};
const hidayah = {
  'id': 2,
  'name': 'Musholla Al-Hidayah',
  'kind': 'musala',
  'lat': -6.1820,
  'lng': 106.8290,
  'verified': false,
  'source': 'osm',
};
const sundaKelapa = {
  'id': 3,
  'name': 'Masjid Agung Sunda Kelapa',
  'kind': 'masjid',
  'lat': -6.2000,
  'lng': 106.8450,
  'verified': false,
  'source': 'osm',
};

/// Pengguna berdiri ±560 m di selatan Istiqlal.
const here = LocationFix(-6.1750, 106.8300, 12);

MockClient directoryBackend(List<http.Request> log, {bool offline = false}) => MockClient((req) async {
  log.add(req);
  if (offline) throw Exception('offline');
  final p = req.url.path;
  if (p.startsWith('/api/public/directory/cells/')) {
    final cell = p.split('/').last;
    return http.Response(
      jsonEncode({
        'cell': cell,
        'attribution': cell == geohashEncode(here.latitude, here.longitude, precision: 4)
            ? ['© OpenStreetMap contributors (ODbL 1.0)']
            : [],
        'data': cell == geohashEncode(here.latitude, here.longitude, precision: 4)
            ? [istiqlal, hidayah, sundaKelapa]
            : [],
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
  if (p == '/api/public/directory/reports') return http.Response('{"data":{"id":1,"status":"pending"}}', 201);
  return http.Response('{"message":"not found"}', 404);
});

Future<void> openNearby(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('menu-nearby')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('menu-nearby')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('GPS → masjid terdekat terurut jarak, arah, terverifikasi, atribusi OSM; unduhan sel tanpa token', (
    tester,
  ) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      client: directoryBackend(log),
      location: const FakeLocationService(fix: here),
    );
    await openNearby(tester);

    expect(find.text('Lokasi Anda saat ini'), findsOneWidget);
    expect(find.text('Akurasi ±12 m'), findsOneWidget);
    final tiles = tester
        .widgetList<ListTile>(find.byWidgetPredicate((w) => w is ListTile && '${w.key}'.contains('place-')))
        .toList();
    expect(tiles.map((t) => t.key).take(2), [const Key('place-1'), const Key('place-2')]); // terdekat dulu
    expect(find.descendant(of: find.byKey(const Key('place-1')), matching: find.text('Terverifikasi')), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const Key('place-1')), matching: find.textContaining('560 m • Utara')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('osm-attribution')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('OpenStreetMap'), findsOneWidget);

    final cellRequests = log.where((r) => r.url.path.contains('/directory/cells/'));
    expect(cellRequests, isNotEmpty);
    for (final r in cellRequests) {
      expect(r.headers.containsKey('Authorization'), isFalse);
      expect(r.url.query, isEmpty); // koordinat persis tidak pernah dikirim
    }
  });

  testWidgets('radius 1 km menyaring yang jauh; tampilan radar menampilkan titik', (tester) async {
    await pumpApp(
      tester,
      client: directoryBackend([]),
      location: const FakeLocationService(fix: here),
    );
    await openNearby(tester);
    await tester.tap(find.byKey(const Key('radius-1000')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('place-1')), findsOneWidget);
    expect(find.byKey(const Key('place-3')), findsNothing); // ±3,8 km

    await tester.tap(find.byKey(const Key('tab-Radar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nearby-radar')), findsOneWidget);
    expect(find.byKey(const Key('radar-1')), findsOneWidget);
    expect(find.byKey(const Key('radar-3')), findsNothing);
  });

  testWidgets('izin lokasi ditolak: perkiraan dari pusat kota + tombol izinkan', (tester) async {
    await pumpApp(tester, client: directoryBackend([]));
    await openNearby(tester);
    expect(find.textContaining('Perkiraan dari pusat kota'), findsOneWidget);
    expect(find.byKey(const Key('location-error')), findsOneWidget);
    expect(find.byKey(const Key('location-fix')), findsOneWidget);
  });

  testWidgets('detail: rute, ikuti masjid terverifikasi, laporkan lokasi salah', (tester) async {
    final log = <http.Request>[];
    final routed = <DirectoryPlace>[];
    final store = InMemoryStore();
    await pumpApp(
      tester,
      store: store,
      client: directoryBackend(log),
      location: const FakeLocationService(fix: here),
      mapLauncher: (p) async {
        routed.add(p);
        return true;
      },
    );
    await openNearby(tester);
    await tester.tap(find.byKey(const Key('place-1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('place-route')));
    await tester.pump();
    expect(routed.single.name, 'Masjid Istiqlal');

    await tester.tap(find.byKey(const Key('place-follow')));
    await tester.pumpAndSettle();
    expect((await FavoriteMosqueRepository(store).all()).single.slug, 'istiqlal');
    expect(find.text('Diikuti'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('report-location')));
    await tester.tap(find.byKey(const Key('report-location')));
    await tester.pumpAndSettle();
    final body = jsonDecode(log.lastWhere((r) => r.method == 'POST').body) as Map;
    expect(body['type'], 'wrong_location');
    expect(body['directory_id'], 1);
    expect(body['latitude'], here.latitude);
    expect(find.textContaining('akan ditinjau'), findsOneWidget);
  });

  testWidgets('tambah masjid baru memakai posisi GPS saat ini', (tester) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      client: directoryBackend(log),
      location: const FakeLocationService(fix: here),
    );
    await openNearby(tester);
    await tester.tap(find.byKey(const Key('add-place')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('new-place-name')), 'Musala Nurul Huda');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Musala')));
    await tester.tap(find.byKey(const Key('send-new-place')));
    await tester.pumpAndSettle();
    final body = jsonDecode(log.lastWhere((r) => r.method == 'POST').body) as Map;
    expect(body, {
      'type': 'new_mosque',
      'name': 'Musala Nurul Huda',
      'kind': 'musala',
      'latitude': here.latitude,
      'longitude': here.longitude,
    });
  });

  testWidgets('offline tanpa data tersimpan: pemberitahuan; dengan data lama: tetap tampil & ditandai', (tester) async {
    await pumpApp(
      tester,
      client: directoryBackend([], offline: true),
      location: const FakeLocationService(fix: here),
    );
    await openNearby(tester);
    expect(find.byKey(const Key('nearby-missing')), findsOneWidget);
    expect(find.byKey(const Key('nearby-empty')), findsOneWidget);
  });

  testWidgets('data wilayah lama dipakai saat offline', (tester) async {
    final store = InMemoryStore();
    final cell = geohashEncode(here.latitude, here.longitude, precision: 4);
    for (final c in cellsCovering(here.latitude, here.longitude, 3000)) {
      await store.writeJson('directory.cell.$c', {
        'fetched_at': DateTime(2026, 1, 1).toIso8601String(),
        'attribution': <String>[],
        'data': c == cell ? [istiqlal] : <Object>[],
      });
    }
    await pumpApp(
      tester,
      store: store,
      client: directoryBackend([], offline: true),
      location: const FakeLocationService(fix: here),
    );
    await openNearby(tester);
    expect(find.byKey(const Key('nearby-stale')), findsOneWidget);
    expect(find.byKey(const Key('place-1')), findsOneWidget);
  });

  testWidgets('registrasi masjid memakai titik GPS persis, bukan pusat kota', (tester) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      client: fakeMosqueBackend(log),
      tokens: MemoryTokenStore('t0k3n'),
      location: const FakeLocationService(fix: LocationFix(-6.91234, 107.61111, 8)),
    );
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(MaterialPageRoute(builder: (_) => const RegisterMosquePage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mosque-name')), 'Masjid Al-Ikhlas');
    await tester.tap(find.byKey(const Key('use-gps')));
    await tester.pumpAndSettle();
    expect(find.textContaining('-6.91234, 107.61111'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('register-mosque')),
      200,
      scrollable: find.descendant(of: find.byType(RegisterMosquePage), matching: find.byType(Scrollable)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('register-mosque')));
    await tester.pumpAndSettle();
    final body = jsonDecode(log.lastWhere((r) => r.method == 'POST' && r.url.path.endsWith('/mosques')).body) as Map;
    expect(body['latitude'], -6.91234);
    expect(body['longitude'], 107.61111);
  });
}
