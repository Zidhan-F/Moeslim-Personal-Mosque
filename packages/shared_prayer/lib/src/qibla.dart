import 'dart:math' as math;

import 'astro.dart';
import 'coordinates.dart';

/// Koordinat pusat Ka'bah pada datum WGS84 (21°25'20.95"N, 39°49'34.34"E).
const kaaba = Coordinates(21.422487, 39.826206);

const _wgs84A = 6378137.0;
const _wgs84F = 1.0 / 298.257223563;
const _wgs84B = _wgs84A * (1.0 - _wgs84F);

({double bearingDeg, double distanceKm}) _vincentyInverse(Coordinates from, Coordinates to) {
  final phi1 = dtr(from.latitude);
  final phi2 = dtr(to.latitude);
  final l = dtr(to.longitude - from.longitude);

  final u1 = math.atan((1.0 - _wgs84F) * math.tan(phi1));
  final u2 = math.atan((1.0 - _wgs84F) * math.tan(phi2));
  final sinU1 = math.sin(u1), cosU1 = math.cos(u1);
  final sinU2 = math.sin(u2), cosU2 = math.cos(u2);

  var lam = l;
  double sinSigma = 0, cosSigma = 0, sigma = 0;
  double sinAlpha = 0, cos2Alpha = 0, cos2SigmaM = 0;
  var converged = false;

  for (var i = 0; i < 200; i++) {
    final sinLam = math.sin(lam), cosLam = math.cos(lam);
    final t1 = cosU2 * sinLam;
    final t2 = cosU1 * sinU2 - sinU1 * cosU2 * cosLam;
    sinSigma = math.sqrt(t1 * t1 + t2 * t2);
    if (sinSigma == 0.0) {
      return (bearingDeg: 0.0, distanceKm: 0.0);
    }
    cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLam;
    sigma = math.atan2(sinSigma, cosSigma);
    sinAlpha = cosU1 * cosU2 * sinLam / sinSigma;
    cos2Alpha = 1.0 - sinAlpha * sinAlpha;
    cos2SigmaM = cos2Alpha == 0.0 ? 0.0 : cosSigma - 2.0 * sinU1 * sinU2 / cos2Alpha;
    final c = (_wgs84F / 16.0) * cos2Alpha * (4.0 + _wgs84F * (4.0 - 3.0 * cos2Alpha));
    final prevLam = lam;
    lam = l +
        (1.0 - c) *
            _wgs84F *
            sinAlpha *
            (sigma + c * sinSigma * (cos2SigmaM + c * cosSigma * (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM)));
    if ((lam - prevLam).abs() < 1e-12) {
      converged = true;
      break;
    }
  }

  if (!converged) {
    return (bearingDeg: _sphericalBearing(from, to), distanceKm: _sphericalDistanceKm(from, to));
  }

  final uSq = cos2Alpha * (_wgs84A * _wgs84A - _wgs84B * _wgs84B) / (_wgs84B * _wgs84B);
  final capA = 1.0 + uSq / 16384.0 * (4096.0 + uSq * (-768.0 + uSq * (320.0 - 175.0 * uSq)));
  final capB = uSq / 1024.0 * (256.0 + uSq * (-128.0 + uSq * (74.0 - 47.0 * uSq)));
  final deltaSigma = capB *
      sinSigma *
      (cos2SigmaM +
          capB /
              4.0 *
              (cosSigma * (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM) -
                  capB /
                      6.0 *
                      cos2SigmaM *
                      (-3.0 + 4.0 * sinSigma * sinSigma) *
                      (-3.0 + 4.0 * cos2SigmaM * cos2SigmaM)));

  final distKm = _wgs84B * capA * (sigma - deltaSigma) / 1000.0;
  final azRad = math.atan2(
    cosU2 * math.sin(lam),
    cosU1 * sinU2 - sinU1 * cosU2 * math.cos(lam),
  );
  return (bearingDeg: fixAngle(rtd(azRad)), distanceKm: distKm);
}

double _sphericalBearing(Coordinates from, Coordinates to) {
  final phi = dtr(from.latitude);
  final dl = dtr(to.longitude - from.longitude);
  final phiT = dtr(to.latitude);
  final y = math.sin(dl);
  final x = math.cos(phi) * math.tan(phiT) - math.sin(phi) * math.cos(dl);
  return fixAngle(rtd(math.atan2(y, x)));
}

double _sphericalDistanceKm(Coordinates from, Coordinates to) {
  const r = 6371.0088;
  final dLat = dtr(to.latitude - from.latitude);
  final dLng = dtr(to.longitude - from.longitude);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(dtr(from.latitude)) * math.cos(dtr(to.latitude)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
}

/// Jarak geodesik WGS84 antara dua koordinat dalam kilometer.
double distanceBetweenKm(Coordinates from, Coordinates to) => _vincentyInverse(from, to).distanceKm;

/// Arah kiblat geodesik WGS84 dalam derajat dari utara sejati (searah jarum jam), [0, 360).
double qiblaBearing(Coordinates from) => _vincentyInverse(from, kaaba).bearingDeg;

/// Jarak geodesik WGS84 ke Ka'bah dalam kilometer.
double distanceToKaabaKm(Coordinates from) => _vincentyInverse(from, kaaba).distanceKm;

/// Konversi arah kompas magnetik (derajat, boleh negatif seperti -180..180) ke utara sejati [0, 360)
/// menggunakan deklinasi magnetik (positif timur, negatif barat, sesuai Android GeomagneticField).
double applyMagneticDeclination(double magneticHeadingDeg, double declinationDeg) =>
    fixAngle(magneticHeadingDeg + declinationDeg);

/// Selisih sudut terpendek dari [fromDeg] menuju [toDeg] dalam rentang (-180, 180].
/// Positif berarti perlu berputar searah jarum jam (kanan), negatif berlawanan arah (kiri).
double shortestAngleDelta(double fromDeg, double toDeg) {
  var delta = fixAngle(toDeg - fromDeg);
  if (delta > 180.0) delta -= 360.0;
  return delta;
}

/// Pemulusan sudut kompas (circular exponential moving average) agar tidak meloncat di batas 0°/360°.
double smoothHeading(double previousDeg, double nextDeg, {double alpha = 0.25}) {
  assert(alpha > 0 && alpha <= 1);
  return fixAngle(previousDeg + alpha * shortestAngleDelta(previousDeg, nextDeg));
}

/// Bernilai true apabila arah utara sejati perangkat berada dalam [toleranceDeg] dari arah kiblat.
bool isAlignedWithQibla(double trueHeadingDeg, double qiblaBearingDeg, {double toleranceDeg = 2.0}) =>
    shortestAngleDelta(trueHeadingDeg, qiblaBearingDeg).abs() <= toleranceDeg;
