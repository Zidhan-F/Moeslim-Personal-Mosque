/// Tanggal Hijriah berbasis kalender tabular (aritmetika) dengan dukungan
/// koreksi lokal (`offsetDays`) karena penetapan resmi bisa berbeda ±1–2 hari.
class HijriDate {
  static const monthNames = [
    'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir', 'Jumadil Awal', 'Jumadil Akhir',
    'Rajab', "Sya'ban", 'Ramadan', 'Syawal', "Dzulqa'dah", 'Dzulhijjah',
  ];

  static const _epoch = 1948439.5; // 16 Juli 622 M (Julian), epoch sipil.

  final int year;
  final int month;
  final int day;

  HijriDate(this.year, this.month, this.day) {
    if (month < 1 || month > 12) throw ArgumentError.value(month, 'month');
    if (day < 1 || day > 30) throw ArgumentError.value(day, 'day');
  }

  String get monthName => monthNames[month - 1];

  static double _toJd(int y, int m, int d) =>
      d + (29.5 * (m - 1)).ceil() + (y - 1) * 354 + ((3 + 11 * y) / 30).floor() + _epoch - 1;

  /// Konversi dari tanggal Gregorian; hanya komponen tanggal yang dipakai.
  factory HijriDate.fromGregorian(DateTime date, {int offsetDays = 0}) {
    final utc = DateTime.utc(date.year, date.month, date.day).add(Duration(days: offsetDays));
    final jd = utc.millisecondsSinceEpoch / 86400000 + 2440587.5;
    final y = ((30 * (jd - _epoch) + 10646) / 10631).floor();
    var m = ((jd - (29 + _toJd(y, 1, 1))) / 29.5).ceil() + 1;
    if (m > 12) m = 12;
    if (m < 1) m = 1;
    final d = (jd - _toJd(y, m, 1)).round() + 1;
    return HijriDate(y, m, d);
  }

  /// Tanggal Gregorian (UTC, tengah malam) untuk tanggal Hijriah ini.
  DateTime toGregorian({int offsetDays = 0}) {
    final jd = _toJd(year, month, day);
    final ms = ((jd - 2440587.5) * 86400000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).subtract(Duration(days: offsetDays));
  }

  @override
  bool operator ==(Object other) =>
      other is HijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$day $monthName $year H';
}
