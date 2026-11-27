import '../geo/geo.dart';
import 'key_value_store.dart';

/// Satu masjid/musala dari direktori Masjid Terdekat.
class DirectoryPlace {
  final int id;
  final String name;
  final String kind; // masjid | musala
  final double lat;
  final double lng;
  final String? address;
  final String? city;
  final bool verified;
  final String? mosqueSlug;
  final String source;

  const DirectoryPlace({
    required this.id,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lng,
    this.address,
    this.city,
    this.verified = false,
    this.mosqueSlug,
    this.source = 'osm',
  });

  factory DirectoryPlace.fromJson(Map<String, dynamic> j) => DirectoryPlace(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        kind: j['kind'] as String? ?? 'masjid',
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        address: j['address'] as String?,
        city: j['city'] as String?,
        verified: j['verified'] == true,
        mosqueSlug: j['mosque_slug'] as String?,
        source: j['source'] as String? ?? 'osm',
      );

  bool get isMusala => kind == 'musala';
}

class NearbyPlace {
  final DirectoryPlace place;
  final double distanceM;
  final double bearing;
  const NearbyPlace(this.place, this.distanceM, this.bearing);
}

class NearbyResult {
  final List<NearbyPlace> places;

  /// Sebagian data dari cache lama karena perangkat offline.
  final bool stale;

  /// Jumlah sel yang belum pernah terunduh (offline sejak awal).
  final int missingCells;
  final Set<String> attribution;
  const NearbyResult(this.places, {this.stale = false, this.missingCells = 0, this.attribution = const {}});
}

typedef CellFetcher = Future<Map<String, dynamic>> Function(String cell);

/// Paket wilayah offline: sel diunduh sekali, disimpan di perangkat, diperbarui berkala.
/// Jarak dihitung di perangkat sehingga koordinat persis pengguna tidak pernah dikirim ke server.
class DirectoryRepository {
  static const maxAge = Duration(days: 7);

  final KeyValueStore _store;
  final CellFetcher _fetch;
  DirectoryRepository(this._store, this._fetch);

  String _key(String cell) => 'directory.cell.$cell';

  Future<NearbyResult> nearby(double lat, double lng, double radiusM, {DateTime? now}) async {
    now ??= DateTime.now();
    final places = <int, DirectoryPlace>{};
    final attribution = <String>{};
    var stale = false;
    var missing = 0;
    for (final cell in cellsCovering(lat, lng, radiusM)) {
      final cached = await _store.readJson(_key(cell));
      final fetchedAt = cached is Map ? DateTime.tryParse('${cached['fetched_at']}') : null;
      Map? payload = cached is Map ? cached : null;
      if (fetchedAt == null || now.difference(fetchedAt) > maxAge) {
        try {
          final fresh = await _fetch(cell);
          payload = {...fresh, 'fetched_at': now.toIso8601String()};
          await _store.writeJson(_key(cell), payload);
        } catch (_) {
          if (payload == null) {
            missing++;
            continue;
          }
          stale = true;
        }
      }
      for (final a in (payload!['attribution'] as List? ?? const [])) {
        attribution.add('$a');
      }
      for (final raw in (payload['data'] as List? ?? const [])) {
        final p = DirectoryPlace.fromJson(Map<String, dynamic>.from(raw as Map));
        places[p.id] = p;
      }
    }
    final list = [
      for (final p in places.values)
        NearbyPlace(p, haversineMeters(lat, lng, p.lat, p.lng), bearingDegrees(lat, lng, p.lat, p.lng)),
    ].where((n) => n.distanceM <= radiusM).toList()
      ..sort((a, b) => a.distanceM.compareTo(b.distanceM));
    return NearbyResult(list, stale: stale, missingCells: missing, attribution: attribution);
  }

  /// Hapus cache sel (mis. dari Pengaturan).
  Future<void> clearCell(String cell) => _store.delete(_key(cell));
}
