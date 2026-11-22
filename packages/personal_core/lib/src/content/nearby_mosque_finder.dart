import 'dart:math' as math;

import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';

class NearbyMosqueItem {
  final String id;
  final String name;
  final String kind;
  final String address;
  final double latitude;
  final double longitude;
  final String facilities;

  const NearbyMosqueItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.facilities = 'Tempat Wudhu, Ruang Salat Utama, Parkir',
  });

  Coordinates get coordinates => Coordinates(latitude, longitude);

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'kind': kind,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'facilities': facilities,
      };

  factory NearbyMosqueItem.fromJson(Map<String, dynamic> j) => NearbyMosqueItem(
        id: j['id'] as String? ?? 'm',
        name: j['name'] as String? ?? 'Masjid',
        kind: j['kind'] as String? ?? 'Masjid',
        address: j['address'] as String? ?? '',
        latitude: (j['latitude'] as num?)?.toDouble() ?? -6.1702,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 106.8314,
        facilities: j['facilities'] as String? ?? 'Tempat Wudhu, Ruang Salat Utama',
      );
}

class RankedNearbyMosque {
  final NearbyMosqueItem mosque;
  final double distanceKm;
  final double bearingDegrees;
  final String cardinalDirection;

  const RankedNearbyMosque({
    required this.mosque,
    required this.distanceKm,
    required this.bearingDegrees,
    required this.cardinalDirection,
  });

  String get formattedDistance =>
      distanceKm < 1.0 ? '${(distanceKm * 1000).round()} m' : '${distanceKm.toStringAsFixed(1)} km';
}

const List<NearbyMosqueItem> defaultIndonesianMosqueDirectory = [
  NearbyMosqueItem(
    id: 'istiqlal_jakarta',
    name: 'Masjid Istiqlal',
    kind: 'Masjid Negara',
    address: 'Jl. Taman Wijaya Kusuma, Sawah Besar, Jakarta Pusat',
    latitude: -6.17017,
    longitude: 106.83139,
    facilities: 'Parkir Luas, Perpustakaan, Akses Disabilitas, Air Wudhu Siap',
  ),
  NearbyMosqueItem(
    id: 'al_azhar_jakarta',
    name: 'Masjid Agung Al-Azhar',
    kind: 'Masjid Agung',
    address: 'Jl. Sisingamangaraja, Kebayoran Baru, Jakarta Selatan',
    latitude: -6.23494,
    longitude: 106.79928,
    facilities: 'Kajian Rutin, Aula, Tempat Wudhu, Parkir',
  ),
  NearbyMosqueItem(
    id: 'sunda_kelapa_jakarta',
    name: 'Masjid Agung Sunda Kelapa',
    kind: 'Masjid Agung',
    address: 'Jl. Taman Sunda Kelapa No. 16, Menteng, Jakarta Pusat',
    latitude: -6.20165,
    longitude: 106.83226,
    facilities: 'Kajian Ba\'da Salat, Ruang Ber-AC, Parkir',
  ),
  NearbyMosqueItem(
    id: 'raya_bandung',
    name: 'Masjid Raya Bandung Jawa Barat',
    kind: 'Masjid Raya',
    address: 'Jl. Dalem Kaum No. 14, Alun-Alun Bandung',
    latitude: -6.92176,
    longitude: 107.60614,
    facilities: 'Alun-Alun, Tempat Wudhu, Menara, Parkir Basement',
  ),
  NearbyMosqueItem(
    id: 'pusdai_bandung',
    name: 'Masjid Pusdai Jawa Barat',
    kind: 'Masjid Pusat Dakwah',
    address: 'Jl. Diponegoro No. 63, Cibeunying Kaler, Bandung',
    latitude: -6.90018,
    longitude: 107.62598,
    facilities: 'Perpustakaan Islam, Kajian Rutin, Parkir Luas',
  ),
  NearbyMosqueItem(
    id: 'al_akbar_surabaya',
    name: 'Masjid Nasional Al-Akbar Surabaya',
    kind: 'Masjid Nasional',
    address: 'Jl. Masjid Al-Akbar Timur No. 1, Pagesangan, Surabaya',
    latitude: -7.33658,
    longitude: 112.71506,
    facilities: 'Menara Pandang, Poliklinik, Parkir Luas, Kajian',
  ),
  NearbyMosqueItem(
    id: 'gedhe_kauman_yogya',
    name: 'Masjid Gedhe Kauman Kraton Yogyakarta',
    kind: 'Masjid Bersejarah',
    address: 'Alun-Alun Utara, Ngupasan, Gondomanan, Yogyakarta',
    latitude: -7.80390,
    longitude: 110.36246,
    facilities: 'Serambi Kajian, Perpustakaan, Tempat Wudhu Tradisional',
  ),
  NearbyMosqueItem(
    id: 'baiturrahman_aceh',
    name: 'Masjid Raya Baiturrahman',
    kind: 'Masjid Raya',
    address: 'Jl. Moh. Jam No. 1, Kp. Baru, Baiturrahman, Banda Aceh',
    latitude: 5.55365,
    longitude: 95.31730,
    facilities: 'Payung Elektrik, Basement Parkir & Wudhu, Kajian',
  ),
];

double computeDistanceKm(Coordinates a, Coordinates b) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(b.latitude - a.latitude);
  final dLon = _degToRad(b.longitude - a.longitude);
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthRadiusKm * c;
}

double computeBearingDegrees(Coordinates from, Coordinates to) {
  final lat1 = _degToRad(from.latitude);
  final lat2 = _degToRad(to.latitude);
  final dLon = _degToRad(to.longitude - from.longitude);
  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  final brng = (_radToDeg(math.atan2(y, x)) + 360.0) % 360.0;
  return brng;
}

String cardinalFromBearing(double bearing) {
  const dirs = ['Utara', 'Timur Laut', 'Timur', 'Tenggara', 'Selatan', 'Barat Daya', 'Barat', 'Barat Laut'];
  final idx = ((bearing + 22.5) % 360.0) ~/ 45.0;
  return dirs[idx.clamp(0, 7)];
}

double _degToRad(double d) => d * math.pi / 180.0;
double _radToDeg(double r) => r * 180.0 / math.pi;

List<RankedNearbyMosque> rankMosquesByDistance(
  Coordinates userOrigin,
  List<NearbyMosqueItem> mosques,
) {
  final list = [
    for (final m in mosques)
      () {
        final dist = computeDistanceKm(userOrigin, m.coordinates);
        final brng = computeBearingDegrees(userOrigin, m.coordinates);
        return RankedNearbyMosque(
          mosque: m,
          distanceKm: dist,
          bearingDegrees: brng,
          cardinalDirection: cardinalFromBearing(brng),
        );
      }(),
  ];
  list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return list;
}

class NearbyMosqueRepository {
  static const _customKey = 'custom_nearby_mosques';
  final KeyValueStore _store;

  const NearbyMosqueRepository(this._store);

  Future<List<NearbyMosqueItem>> savedCustomMosques() async {
    final raw = await _store.readJson(_customKey);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) NearbyMosqueItem.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<List<NearbyMosqueItem>> allAvailableMosques() async {
    final custom = await savedCustomMosques();
    return [...custom, ...defaultIndonesianMosqueDirectory];
  }

  Future<void> addCustomMosque(NearbyMosqueItem item) async {
    final list = (await savedCustomMosques()).where((m) => m.id != item.id).toList();
    list.insert(0, item);
    await _store.writeJson(_customKey, [for (final m in list) m.toJson()]);
  }
}
