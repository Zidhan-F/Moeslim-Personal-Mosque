import 'dart:math' as math;

/// Geohash, sel wilayah, jarak & arah — untuk fitur Masjid Terdekat (tanpa layanan peta eksternal).

const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Presisi sel paket wilayah: geohash 4 karakter (±39 × 20 km di khatulistiwa).
const directoryCellPrecision = 4;

String geohashEncode(double lat, double lng, {int precision = 9}) {
  var latR = [-90.0, 90.0];
  var lngR = [-180.0, 180.0];
  final out = StringBuffer();
  var bit = 0, ch = 0;
  var even = true;
  while (out.length < precision) {
    final r = even ? lngR : latR;
    final mid = (r[0] + r[1]) / 2;
    final v = even ? lng : lat;
    if (v >= mid) {
      ch |= 1 << (4 - bit);
      r[0] = mid;
    } else {
      r[1] = mid;
    }
    even = !even;
    if (++bit == 5) {
      out.write(_base32[ch]);
      bit = 0;
      ch = 0;
    }
  }
  return out.toString();
}

/// Kotak batas sebuah geohash: (selatan, barat, utara, timur).
(double, double, double, double) geohashBounds(String hash) {
  var latR = [-90.0, 90.0];
  var lngR = [-180.0, 180.0];
  var even = true;
  for (final c in hash.split('')) {
    final cd = _base32.indexOf(c);
    if (cd < 0) throw ArgumentError('Karakter geohash tidak valid: $c');
    for (var b = 4; b >= 0; b--) {
      final r = even ? lngR : latR;
      final mid = (r[0] + r[1]) / 2;
      if ((cd >> b) & 1 == 1) {
        r[0] = mid;
      } else {
        r[1] = mid;
      }
      even = !even;
    }
  }
  return (latR[0], lngR[0], latR[1], lngR[1]);
}

/// Semua sel (geohash [precision]) yang beririsan dengan lingkaran radius [radiusM] di sekitar titik.
Set<String> cellsCovering(double lat, double lng, double radiusM, {int precision = directoryCellPrecision}) {
  final dLat = radiusM / 111320;
  final dLng = radiusM / (111320 * math.max(math.cos(lat * math.pi / 180), 0.01));
  final (s0, w0, n0, e0) = geohashBounds(geohashEncode(lat, lng, precision: precision));
  final stepLat = (n0 - s0) / 2;
  final stepLng = (e0 - w0) / 2;
  final cells = <String>{};
  for (var y = lat - dLat; y <= lat + dLat + stepLat; y += stepLat) {
    for (var x = lng - dLng; x <= lng + dLng + stepLng; x += stepLng) {
      cells.add(geohashEncode(y.clamp(lat - dLat, lat + dLat), x.clamp(lng - dLng, lng + dLng), precision: precision));
    }
  }
  return cells;
}

double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371008.8;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLng = rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

/// Arah awal dari titik 1 ke titik 2 (derajat dari utara sejati, 0..360).
double bearingDegrees(double lat1, double lng1, double lat2, double lng2) {
  double rad(double d) => d * math.pi / 180;
  final y = math.sin(rad(lng2 - lng1)) * math.cos(rad(lat2));
  final x = math.cos(rad(lat1)) * math.sin(rad(lat2)) -
      math.sin(rad(lat1)) * math.cos(rad(lat2)) * math.cos(rad(lng2 - lng1));
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

const _points = ['Utara', 'Timur Laut', 'Timur', 'Tenggara', 'Selatan', 'Barat Daya', 'Barat', 'Barat Laut'];

/// Nama arah mata angin (8 arah) dalam bahasa Indonesia.
String compassPointId(double degrees) => _points[((degrees % 360) / 45).round() % 8];

/// "350 m" atau "1,2 km".
String formatDistanceId(double meters) {
  if (meters < 1000) return '${(meters / 10).round() * 10} m';
  final km = meters / 1000;
  return '${km.toStringAsFixed(km < 10 ? 1 : 0).replaceAll('.', ',')} km';
}
