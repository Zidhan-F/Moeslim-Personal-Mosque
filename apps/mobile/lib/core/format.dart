import 'package:intl/intl.dart';
import 'package:shared_prayer/shared_prayer.dart';

String hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String hhmmss(DateTime t) => '${hhmm(t)}:${t.second.toString().padLeft(2, '0')}';

String countdown(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
String rupiah(num v) => _rupiah.format(v);

const _daysId = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
const _daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _monthsId = [
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
const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String longDate(DateTime d, {AppLanguage lang = AppLanguage.id}) => lang == AppLanguage.en
    ? '${_daysEn[d.weekday - 1]}, ${_monthsEn[d.month - 1]} ${d.day}, ${d.year}'
    : '${_daysId[d.weekday - 1]}, ${d.day} ${_monthsId[d.month - 1]} ${d.year}';

String shortDate(DateTime d, {AppLanguage lang = AppLanguage.id}) => lang == AppLanguage.en
    ? '${_monthsEn[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}'
    : '${d.day} ${_monthsId[d.month - 1].substring(0, 3)} ${d.year}';

/// Jam dinding di lokasi dengan offset UTC tertentu (jadwal dihitung per lokasi, bukan zona perangkat).
DateTime wallClock(DateTime now, double utcOffsetHours) {
  final t = now.toUtc().add(Duration(minutes: (utcOffsetHours * 60).round()));
  return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
}
