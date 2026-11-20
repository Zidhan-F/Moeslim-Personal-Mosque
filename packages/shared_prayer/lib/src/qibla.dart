import 'dart:math' as math;

import 'astro.dart';
import 'coordinates.dart';

/// Koordinat Ka'bah.
const kaaba = Coordinates(21.4225, 39.8262);

/// Arah kiblat dalam derajat dari utara sejati (searah jarum jam), 0..360.
double qiblaBearing(Coordinates from) {
  final phi = dtr(from.latitude);
  final dl = dtr(kaaba.longitude - from.longitude);
  final phiK = dtr(kaaba.latitude);
  final y = math.sin(dl);
  final x = math.cos(phi) * math.tan(phiK) - math.sin(phi) * math.cos(dl);
  return fixAngle(rtd(math.atan2(y, x)));
}

/// Jarak lingkaran besar ke Ka'bah dalam kilometer.
double distanceToKaabaKm(Coordinates from) {
  const r = 6371.0;
  final dLat = dtr(kaaba.latitude - from.latitude);
  final dLng = dtr(kaaba.longitude - from.longitude);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(dtr(from.latitude)) * math.cos(dtr(kaaba.latitude)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}
