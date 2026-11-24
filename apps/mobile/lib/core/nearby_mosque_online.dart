import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

/// Pencarian masjid lewat Google Places API (New), data sama dengan Google Maps.
///
/// Aktif hanya bila dikonfigurasi saat build:
///  - `--dart-define=PLACES_PROXY_URL=https://server-anda/places` (disarankan; key tetap di server), atau
///  - `--dart-define=PLACES_API_KEY=...` (hanya untuk uji coba; key ikut di aplikasi).
/// Server perantara cukup meneruskan body JSON ke `places:searchNearby` dengan key Google.
class GoogleMosqueFinder {
  static const proxyUrl = String.fromEnvironment('PLACES_PROXY_URL');
  static const apiKey = String.fromEnvironment('PLACES_API_KEY');
  static const _direct = 'https://places.googleapis.com/v1/places:searchNearby';
  static const _fields =
      'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount';

  final http.Client client;
  final String proxy;
  final String key;
  GoogleMosqueFinder({required this.client, this.proxy = proxyUrl, this.key = apiKey});

  bool get enabled => proxy.isNotEmpty || key.isNotEmpty;

  Future<List<NearbyMosqueItem>> search(
    Coordinates o, {
    int radiusMeters = 5000,
    AppLanguage lang = AppLanguage.id,
  }) async {
    final res = await client
        .post(
          Uri.parse(proxy.isNotEmpty ? proxy : _direct),
          headers: {
            'Content-Type': 'application/json',
            if (proxy.isEmpty) 'X-Goog-Api-Key': key,
            if (proxy.isEmpty) 'X-Goog-FieldMask': _fields,
          },
          body: jsonEncode({
            'includedTypes': ['mosque'],
            'maxResultCount': 20,
            'rankPreference': 'DISTANCE',
            'languageCode': lang.code,
            'locationRestriction': {
              'circle': {
                'center': {'latitude': o.latitude, 'longitude': o.longitude},
                'radius': radiusMeters.toDouble(),
              },
            },
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw Exception('Places HTTP ${res.statusCode}');
    return parse(utf8.decode(res.bodyBytes), lang: lang);
  }

  static List<NearbyMosqueItem> parse(String body, {AppLanguage lang = AppLanguage.id}) {
    final isEn = lang == AppLanguage.en;
    final json = jsonDecode(body);
    final places = (json is Map ? json['places'] : null) as List? ?? const [];
    final out = <NearbyMosqueItem>[];
    for (final p in places) {
      if (p is! Map) continue;
      final loc = p['location'] as Map?;
      final lat = (loc?['latitude'] as num?)?.toDouble();
      final lon = (loc?['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final name = ((p['displayName'] as Map?)?['text'] as String?)?.trim();
      final rating = (p['rating'] as num?)?.toDouble();
      final count = p['userRatingCount'] as num?;
      final isSmall = (name ?? '').toLowerCase().contains('musholla');
      out.add(NearbyMosqueItem(
        id: 'gmaps_${p['id']}',
        name: (name == null || name.isEmpty) ? (isEn ? 'Mosque' : 'Masjid') : name,
        kind: isSmall ? (isEn ? 'Prayer Room' : 'Musholla') : (isEn ? 'Mosque' : 'Masjid'),
        address: (p['formattedAddress'] as String?) ?? '',
        latitude: lat,
        longitude: lon,
        facilities: rating == null
            ? (isEn ? 'From Google Maps' : 'Dari Google Maps')
            : (isEn
                ? 'Google rating ${rating.toStringAsFixed(1)} (${count ?? 0} reviews)'
                : 'Rating Google ${rating.toStringAsFixed(1)} (${count ?? 0} ulasan)'),
      ));
    }
    return out;
  }
}

/// Mencari masjid/musholla di sekitar koordinat lewat OpenStreetMap (Overpass API
/// dengan cadangan cepat Photon Komoot). Gratis, tanpa API key, dan tidak memerlukan
/// server backend sendiri.
class OnlineMosqueFinder {
  static const _overpassEndpoint = 'https://overpass-api.de/api/interpreter';
  static const _photonEndpoint = 'https://photon.komoot.io/api/';
  static const _userAgent = 'MoeslimPM/1.0 (https://moeslim.id)';
  static const _cachePrefix = 'nearby_mosques_cache_';
  static const _cacheTtl = Duration(hours: 24);

  final http.Client client;
  final KeyValueStore store;
  final DateTime Function() now;

  OnlineMosqueFinder({required this.client, required this.store, DateTime Function()? now})
      : now = now ?? DateTime.now;

  String _cacheKey(Coordinates c, AppLanguage lang) => lang == AppLanguage.en
      ? '$_cachePrefix${c.latitude.toStringAsFixed(2)}_${c.longitude.toStringAsFixed(2)}_en'
      : '$_cachePrefix${c.latitude.toStringAsFixed(2)}_${c.longitude.toStringAsFixed(2)}';

  /// Hasil cache (maks 24 jam) dipakai dulu kecuali [forceRefresh]; bila tidak ada,
  /// ambil dari jaringan (Overpass lalu fallback cepat Photon OSM).
  Future<List<NearbyMosqueItem>> search(
    Coordinates origin, {
    int radiusMeters = 5000,
    AppLanguage lang = AppLanguage.id,
    bool forceRefresh = false,
  }) async {
    final key = _cacheKey(origin, lang);
    final cached = await store.readJson(key);
    List<NearbyMosqueItem>? stale;
    if (cached is Map && cached['items'] is List) {
      final items = [
        for (final e in cached['items'] as List)
          if (e is Map) NearbyMosqueItem.fromJson(Map<String, dynamic>.from(e)),
      ];
      final at = DateTime.tryParse(cached['at'] as String? ?? '');
      if (!forceRefresh && items.isNotEmpty && at != null && now().difference(at) < _cacheTtl) {
        return items;
      }
      stale = items;
    }
    try {
      final items = await _fetch(origin, radiusMeters, lang);
      if (items.isNotEmpty) {
        await store.writeJson(key, {
          'at': now().toIso8601String(),
          'items': [for (final m in items) m.toJson()],
        });
      }
      return items;
    } catch (_) {
      if (stale != null && stale.isNotEmpty) return stale;
      rethrow;
    }
  }

  Future<List<NearbyMosqueItem>> _fetch(Coordinates o, int radius, AppLanguage lang) async {
    Object? lastError;

    // 1. Coba Overpass (node & way saja, timeout cepat 7 detik agar tidak menggantung).
    final around = '(around:$radius,${o.latitude},${o.longitude})';
    final query = '[out:json][timeout:7];('
        'node["amenity"="place_of_worship"]["religion"="muslim"]$around;'
        'way["amenity"="place_of_worship"]["religion"="muslim"]$around;'
        ');out center tags 200;';
    try {
      final res = await client
          .post(
            Uri.parse(_overpassEndpoint),
            headers: {'User-Agent': _userAgent},
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final items = parseOverpass(utf8.decode(res.bodyBytes), lang: lang);
        if (items.isNotEmpty) return items;
      } else {
        lastError = 'Overpass HTTP ${res.statusCode}';
      }
    } catch (e) {
      lastError = e;
    }

    // 2. Fallback cepat ke Photon (OpenStreetMap geocoder gratis, ~1-2 detik).
    try {
      final items = await _fetchPhoton(o, radius, lang);
      if (items.isNotEmpty) return items;
    } catch (e) {
      lastError = e;
    }

    throw Exception(
      lang == AppLanguage.en ? 'Mosque search failed: $lastError' : 'Pencarian masjid gagal: $lastError',
    );
  }

  Future<List<NearbyMosqueItem>> _fetchPhoton(Coordinates o, int radius, AppLanguage lang) async {
    final terms = lang == AppLanguage.en ? const ['mosque', 'masjid'] : const ['masjid', 'musholla'];
    final maxKm = (radius / 1000.0 * 3).clamp(10.0, 20.0);
    Object? firstError;

    final results = await Future.wait(
      terms.map((term) async {
        final uri = Uri.parse(_photonEndpoint).replace(
          queryParameters: {
            'q': term,
            'lat': o.latitude.toStringAsFixed(5),
            'lon': o.longitude.toStringAsFixed(5),
            'limit': '30',
            'osm_tag': 'amenity:place_of_worship',
            'location_bias_scale': '0.1',
          },
        );
        try {
          final res = await client
              .get(uri, headers: {'User-Agent': _userAgent})
              .timeout(const Duration(seconds: 10));
          if (res.statusCode != 200) {
            firstError ??= 'Photon HTTP ${res.statusCode}';
            return const <NearbyMosqueItem>[];
          }
          return parsePhoton(utf8.decode(res.bodyBytes), origin: o, maxDistanceKm: maxKm, lang: lang);
        } catch (e) {
          firstError ??= e;
          return const <NearbyMosqueItem>[];
        }
      }),
    );

    final dedup = <String, NearbyMosqueItem>{};
    for (final list in results) {
      for (final item in list) {
        dedup.putIfAbsent(item.id, () => item);
      }
    }
    if (dedup.isEmpty && firstError != null) {
      throw Exception('$firstError');
    }
    return dedup.values.toList();
  }

  static bool _isSmallPrayerRoom(String lower) =>
      lower.contains('musholla') ||
      lower.contains('mushola') ||
      lower.contains('musala') ||
      lower.contains('surau') ||
      lower.contains('langgar');

  /// Mengubah respons Overpass menjadi daftar masjid (harus berkoordinat).
  static List<NearbyMosqueItem> parseOverpass(String body, {AppLanguage lang = AppLanguage.id}) {
    final isEn = lang == AppLanguage.en;
    final json = jsonDecode(body);
    final elements = (json is Map ? json['elements'] : null) as List? ?? const [];
    final out = <NearbyMosqueItem>[];
    for (final e in elements) {
      if (e is! Map) continue;
      final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
      final center = e['center'] as Map?;
      final lat = ((e['lat'] ?? center?['lat']) as num?)?.toDouble();
      final lon = ((e['lon'] ?? center?['lon']) as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final name = (tags['name'] as String?)?.trim();
      final isSmall = _isSmallPrayerRoom((name ?? '').toLowerCase());
      final kind = isSmall ? (isEn ? 'Prayer Room' : 'Musholla') : (isEn ? 'Mosque' : 'Masjid');
      out.add(NearbyMosqueItem(
        id: 'osm_${e['type']}_${e['id']}',
        name: (name == null || name.isEmpty) ? (isEn ? '$kind (unnamed)' : '$kind (tanpa nama)') : name,
        kind: kind,
        address: _address(tags, lang),
        latitude: lat,
        longitude: lon,
        facilities: _facilities(tags, lang),
      ));
    }
    return out;
  }

  /// Mengubah respons GeoJSON Photon (OpenStreetMap) menjadi daftar masjid sekitar.
  static List<NearbyMosqueItem> parsePhoton(
    String body, {
    required Coordinates origin,
    double maxDistanceKm = 15.0,
    AppLanguage lang = AppLanguage.id,
  }) {
    final isEn = lang == AppLanguage.en;
    final json = jsonDecode(body);
    final features = (json is Map ? json['features'] : null) as List? ?? const [];
    final out = <NearbyMosqueItem>[];
    for (final f in features) {
      if (f is! Map) continue;
      final geom = f['geometry'] as Map?;
      final coords = geom?['coordinates'] as List?;
      if (coords == null || coords.length < 2) continue;
      final lon = (coords[0] as num?)?.toDouble();
      final lat = (coords[1] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      if (computeDistanceKm(origin, Coordinates(lat, lon)) > maxDistanceKm) continue;

      final props = (f['properties'] as Map?)?.cast<String, dynamic>() ?? const {};
      final rawName = (props['name'] as String?)?.trim() ?? '';
      final lower = rawName.toLowerCase();
      final isSmall = _isSmallPrayerRoom(lower);
      final kind = isSmall ? (isEn ? 'Prayer Room' : 'Musholla') : (isEn ? 'Mosque' : 'Masjid');
      final street = (props['street'] as String?)?.trim() ?? '';
      final displayName = rawName.isEmpty
          ? (street.isNotEmpty ? '$kind $street' : (isEn ? '$kind (unnamed)' : '$kind (tanpa nama)'))
          : (lower == 'masjid' || lower == 'musholla' || lower == 'mushola') && street.isNotEmpty
              ? '$rawName $street'
              : rawName;

      final addrParts = <String>[
        if (street.isNotEmpty)
          [street, props['housenumber']].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).join(' '),
        for (final key in const ['district', 'locality', 'city', 'county', 'state'])
          if (props[key] is String && (props[key] as String).trim().isNotEmpty) (props[key] as String).trim(),
      ];
      final uniqueAddr = <String>[];
      for (final p in addrParts) {
        if (!uniqueAddr.contains(p)) uniqueAddr.add(p);
      }

      final osmType = props['osm_type'] ?? 'N';
      final osmId = props['osm_id'] ?? '${lat.toStringAsFixed(5)}_${lon.toStringAsFixed(5)}';
      out.add(NearbyMosqueItem(
        id: 'osm_${osmType}_$osmId',
        name: displayName,
        kind: kind,
        address: uniqueAddr.isEmpty
            ? (isEn ? 'Address not listed on map' : 'Alamat belum tercatat di peta')
            : uniqueAddr.join(', '),
        latitude: lat,
        longitude: lon,
        facilities: isEn ? 'No facility data yet' : 'Belum ada data fasilitas',
      ));
    }
    return out;
  }

  static String _address(Map<String, dynamic> t, AppLanguage lang) {
    final full = t['addr:full'] as String?;
    if (full != null && full.trim().isNotEmpty) return full.trim();
    final street = [t['addr:street'], t['addr:housenumber']].whereType<String>().join(' ').trim();
    final parts = [
      if (street.isNotEmpty) street,
      t['addr:suburb'],
      t['addr:city'] ?? t['addr:subdistrict'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty
        ? (lang == AppLanguage.en ? 'Address not listed on map' : 'Alamat belum tercatat di peta')
        : parts.join(', ');
  }

  static String _facilities(Map<String, dynamic> t, AppLanguage lang) {
    final isEn = lang == AppLanguage.en;
    final f = <String>[
      if (t['wheelchair'] == 'yes') (isEn ? 'Wheelchair Access' : 'Akses Disabilitas'),
      if (t['toilets'] == 'yes') (isEn ? 'Restrooms' : 'Toilet'),
      if (t['drinking_water'] == 'yes') (isEn ? 'Drinking Water' : 'Air Minum'),
      if (t['parking'] != null && t['parking'] != 'no') (isEn ? 'Parking' : 'Parkir'),
    ];
    return f.isEmpty ? (isEn ? 'No facility data yet' : 'Belum ada data fasilitas') : f.join(', ');
  }
}
