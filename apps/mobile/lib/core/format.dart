import 'package:intl/intl.dart';

String hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String countdown(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
String rupiah(num v) => _rupiah.format(v);

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String longDate(DateTime d) => '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

/// Jam dinding di lokasi dengan offset UTC tertentu (jadwal dihitung per lokasi, bukan zona perangkat).
DateTime wallClock(DateTime now, double utcOffsetHours) {
  final t = now.toUtc().add(Duration(minutes: (utcOffsetHours * 60).round()));
  return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
}
