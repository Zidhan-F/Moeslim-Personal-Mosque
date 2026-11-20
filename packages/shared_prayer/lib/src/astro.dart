import 'dart:math' as math;

double dtr(double d) => d * math.pi / 180.0;
double rtd(double r) => r * 180.0 / math.pi;
double fixAngle(double a) => a - 360.0 * (a / 360.0).floorToDouble();
double fixHour(double a) => a - 24.0 * (a / 24.0).floorToDouble();

/// Julian Day (UT tengah malam) untuk tanggal kalender Gregorian.
double julianDay(int year, int month, int day) {
  if (month <= 2) {
    year -= 1;
    month += 12;
  }
  final a = (year / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (year + 4716)).floorToDouble() +
      (30.6001 * (month + 1)).floorToDouble() +
      day +
      b -
      1524.5;
}

/// Deklinasi matahari (derajat) dan equation of time (jam) untuk Julian Day [jd].
({double declination, double equation}) sunPosition(double jd) {
  final d = jd - 2451545.0;
  final g = fixAngle(357.529 + 0.98560028 * d);
  final q = fixAngle(280.459 + 0.98564736 * d);
  final l = fixAngle(q + 1.915 * math.sin(dtr(g)) + 0.020 * math.sin(dtr(2 * g)));
  final e = 23.439 - 0.00000036 * d;
  final ra = rtd(math.atan2(math.cos(dtr(e)) * math.sin(dtr(l)), math.cos(dtr(l)))) / 15.0;
  final eqt = q / 15.0 - fixHour(ra);
  final decl = rtd(math.asin(math.sin(dtr(e)) * math.sin(dtr(l))));
  // Normalisasi eqt ke rentang -12..12 jam.
  final eq = eqt > 12 ? eqt - 24 : (eqt < -12 ? eqt + 24 : eqt);
  return (declination: decl, equation: eq);
}
