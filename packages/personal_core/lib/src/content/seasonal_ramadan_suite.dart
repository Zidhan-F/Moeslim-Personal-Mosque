import 'package:shared_prayer/shared_prayer.dart';

import '../models/settings.dart';
import '../storage/key_value_store.dart';

// ================= 31. DASBOR KHUSUS RAMADAN 30 HARI =================

class RamadanDayChecklist {
  final int dayNumber; // 1..30
  final bool fasting;
  final bool tarawih;
  final bool tilawahJuz;
  final bool sedekah;
  final bool itikaf;

  const RamadanDayChecklist({
    required this.dayNumber,
    this.fasting = false,
    this.tarawih = false,
    this.tilawahJuz = false,
    this.sedekah = false,
    this.itikaf = false,
  });

  bool get isLastTenNights => dayNumber >= 21;
  bool get isOddNightLailatulQadar => isLastTenNights && dayNumber.isOdd;

  RamadanDayChecklist copyWith({
    bool? fasting,
    bool? tarawih,
    bool? tilawahJuz,
    bool? sedekah,
    bool? itikaf,
  }) =>
      RamadanDayChecklist(
        dayNumber: dayNumber,
        fasting: fasting ?? this.fasting,
        tarawih: tarawih ?? this.tarawih,
        tilawahJuz: tilawahJuz ?? this.tilawahJuz,
        sedekah: sedekah ?? this.sedekah,
        itikaf: itikaf ?? this.itikaf,
      );

  Map<String, Object> toJson() => {
        'dayNumber': dayNumber,
        'fasting': fasting,
        'tarawih': tarawih,
        'tilawahJuz': tilawahJuz,
        'sedekah': sedekah,
        'itikaf': itikaf,
      };

  factory RamadanDayChecklist.fromJson(Map<String, dynamic> j) => RamadanDayChecklist(
        dayNumber: ((j['dayNumber'] as num?)?.toInt() ?? 1).clamp(1, 30),
        fasting: j['fasting'] as bool? ?? false,
        tarawih: j['tarawih'] as bool? ?? false,
        tilawahJuz: j['tilawahJuz'] as bool? ?? false,
        sedekah: j['sedekah'] as bool? ?? false,
        itikaf: j['itikaf'] as bool? ?? false,
      );
}

class RamadanDashboardRepository {
  static const _key = 'ramadan_dashboard_state';
  final KeyValueStore _store;

  const RamadanDashboardRepository(this._store);

  Future<List<RamadanDayChecklist>> loadAll30Days() async {
    final raw = await _store.readJson(_key);
    final map = <int, RamadanDayChecklist>{};
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final c = RamadanDayChecklist.fromJson(Map<String, dynamic>.from(item));
          map[c.dayNumber] = c;
        }
      }
    }
    return [
      for (var d = 1; d <= 30; d++) map[d] ?? RamadanDayChecklist(dayNumber: d),
    ];
  }

  Future<List<RamadanDayChecklist>> saveDay(RamadanDayChecklist updated) async {
    final all = await loadAll30Days();
    final next = [
      for (final d in all) d.dayNumber == updated.dayNumber ? updated : d,
    ];
    await _store.writeJson(_key, [for (final d in next) d.toJson()]);
    return next;
  }
}

// ================= 32. PANDUAN & KALKULATOR KURBAN + AQIQAH =================

class QurbanAqiqahSummary {
  final int cowTotalPrice;
  final int cowSharePerPerson;
  final double estimatedMeatKg;
  final double familyPortionKg;
  final double neighborsPortionKg;
  final double poorPortionKg;
  final int aqiqahGoatsRequired;
  final int aqiqahTotalCost;
  final DateTime aqiqahDay7;
  final DateTime aqiqahDay14;
  final DateTime aqiqahDay21;

  const QurbanAqiqahSummary({
    required this.cowTotalPrice,
    required this.cowSharePerPerson,
    required this.estimatedMeatKg,
    required this.familyPortionKg,
    required this.neighborsPortionKg,
    required this.poorPortionKg,
    required this.aqiqahGoatsRequired,
    required this.aqiqahTotalCost,
    required this.aqiqahDay7,
    required this.aqiqahDay14,
    required this.aqiqahDay21,
  });
}

QurbanAqiqahSummary calculateQurbanAndAqiqah({
  required int cowPriceRupiah,
  required double liveWeightKg,
  required bool isBabyBoy,
  required int goatPriceRupiah,
  required DateTime babyBirthDate,
}) {
  final safeCow = cowPriceRupiah.clamp(0, 500000000);
  final share = (safeCow / 7.0).ceil();
  final meat = (liveWeightKg < 0 ? 0.0 : liveWeightKg) * 0.35;
  final third = meat / 3.0;
  final goats = isBabyBoy ? 2 : 1;
  final safeGoat = goatPriceRupiah.clamp(0, 100000000);
  final cleanBirth = DateTime(babyBirthDate.year, babyBirthDate.month, babyBirthDate.day);

  return QurbanAqiqahSummary(
    cowTotalPrice: safeCow,
    cowSharePerPerson: share,
    estimatedMeatKg: meat,
    familyPortionKg: third,
    neighborsPortionKg: third,
    poorPortionKg: third,
    aqiqahGoatsRequired: goats,
    aqiqahTotalCost: goats * safeGoat,
    aqiqahDay7: cleanBirth.add(const Duration(days: 6)),
    aqiqahDay14: cleanBirth.add(const Duration(days: 13)),
    aqiqahDay21: cleanBirth.add(const Duration(days: 20)),
  );
}

// ================= 33. KONVERTER MASEHI ↔ HIJRIAH & HITUNG UMUR HIJRIAH =================

class HijriAgeConversion {
  final DateTime birthGregorian;
  final HijriDate birthHijri;
  final DateTime todayGregorian;
  final HijriDate todayHijri;
  final int hijriYears;
  final int hijriMonths;
  final int hijriDays;
  final int gregorianYears;

  const HijriAgeConversion({
    required this.birthGregorian,
    required this.birthHijri,
    required this.todayGregorian,
    required this.todayHijri,
    required this.hijriYears,
    required this.hijriMonths,
    required this.hijriDays,
    required this.gregorianYears,
  });
}

HijriAgeConversion computeHijriAge({
  required DateTime birthDate,
  required DateTime currentDate,
  int hijriOffset = 0,
}) {
  final bClean = DateTime(birthDate.year, birthDate.month, birthDate.day);
  final cClean = DateTime(currentDate.year, currentDate.month, currentDate.day);
  final bHijri = HijriDate.fromGregorian(bClean, offsetDays: hijriOffset);
  final cHijri = HijriDate.fromGregorian(cClean, offsetDays: hijriOffset);

  var hYears = cHijri.year - bHijri.year;
  var hMonths = cHijri.month - bHijri.month;
  var hDays = cHijri.day - bHijri.day;
  if (hDays < 0) {
    hDays += 30;
    hMonths -= 1;
  }
  if (hMonths < 0) {
    hMonths += 12;
    hYears -= 1;
  }
  if (hYears < 0) {
    hYears = 0;
    hMonths = 0;
    hDays = 0;
  }

  var gYears = cClean.year - bClean.year;
  if (cClean.month < bClean.month || (cClean.month == bClean.month && cClean.day < bClean.day)) {
    gYears--;
  }

  return HijriAgeConversion(
    birthGregorian: bClean,
    birthHijri: bHijri,
    todayGregorian: cClean,
    todayHijri: cHijri,
    hijriYears: hYears,
    hijriMonths: hMonths,
    hijriDays: hDays,
    gregorianYears: gYears.clamp(0, 200),
  );
}

DateTime approximateGregorianFromHijri(int hYear, int hMonth, int hDay, {int hijriOffset = 0}) {
  // Approximate Gregorian date then binary/linear refine to match HijriDate.fromGregorian
  final approxDays = ((hYear - 1) * 354.367 + (hMonth - 1) * 29.53 + hDay).round();
  final epoch = DateTime(622, 7, 16);
  var candidate = epoch.add(Duration(days: approxDays - hijriOffset));
  for (var step = 0; step < 60; step++) {
    final h = HijriDate.fromGregorian(candidate, offsetDays: hijriOffset);
    final diff = (hYear - h.year) * 354 + (hMonth - h.month) * 29 + (hDay - h.day);
    if (diff == 0) return candidate;
    candidate = candidate.add(Duration(days: diff));
  }
  return candidate;
}

// ================= 34. JADWAL IMSAKIYAH / SALAT BULANAN SIAP CETAK =================

class MonthlyImsakiyahRow {
  final DateTime gregorian;
  final HijriDate hijri;
  final DateTime imsak;
  final PrayerTimes times;

  const MonthlyImsakiyahRow({
    required this.gregorian,
    required this.hijri,
    required this.imsak,
    required this.times,
  });
}

List<MonthlyImsakiyahRow> buildMonthlyImsakiyahTable(
  PersonalSettings settings,
  int year,
  int month,
) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final rows = <MonthlyImsakiyahRow>[];
  for (var d = 1; d <= daysInMonth; d++) {
    final dt = DateTime(year, month, d);
    final t = settings.timesFor(dt);
    final h = HijriDate.fromGregorian(dt, offsetDays: settings.hijriOffset);
    rows.add(
      MonthlyImsakiyahRow(
        gregorian: dt,
        hijri: h,
        imsak: t.fajr.subtract(const Duration(minutes: 10)),
        times: t,
      ),
    );
  }
  return rows;
}

// ================= 35. CHECKLIST & PANDUAN IDUL FITRI / IDUL ADHA =================

class EidSunnahItem {
  final String id;
  final String title;
  final String description;
  final String? titleEn;
  final String? descriptionEn;

  const EidSunnahItem(
    this.id,
    this.title,
    this.description, {
    this.titleEn,
    this.descriptionEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String descriptionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (descriptionEn?.isNotEmpty ?? false) ? descriptionEn! : description;
}

const List<EidSunnahItem> eidSunnahChecklistCatalog = [
  EidSunnahItem(
    'zakat_fitrah',
    'Menunaikan Zakat Fitrah Sebelum Salat Idul Fitri',
    'Wajib ditunaikan sebelum pelaksanaan Salat Idul Fitri agar sah sebagai zakat pembersih jiwa (HR. Abu Dawud no. 1609).',
    titleEn: 'Pay Zakat al-Fitr Before the Eid al-Fitr Prayer',
    descriptionEn: 'Must be paid before the Eid al-Fitr prayer so it counts as obligatory purification of the fast (Sunan Abi Dawud 1609).',
  ),
  EidSunnahItem(
    'mandi_id',
    'Mandi Sunnah Pagi Hari Raya & Memakai Pakaian Terbaik',
    'Diriwayatkan dari Ibnu Umar RA bahwa beliau mandi dan memakai pakaian terbaiknya pada pagi Hari Raya.',
    titleEn: 'Take the Eid Morning Bath (Ghusl) & Wear Your Best Clothes',
    descriptionEn: 'It is narrated from Ibn Umar (may Allah be pleased with him) that he bathed and wore his finest clothes on Eid morning.',
  ),
  EidSunnahItem(
    'makan_sebelum_id',
    'Makan Kurma Ganjil (Idul Fitri) atau Menunda Makan (Idul Adha)',
    'Pada Idul Fitri disunnahkan makan kurma ganjil sebelum berangkat; pada Idul Adha disunnahkan tidak makan hingga selesai salat Id (HR. Bukhari no. 953).',
    titleEn: 'Eat Odd Dates (Eid al-Fitr) or Delay Eating (Eid al-Adha)',
    descriptionEn: 'On Eid al-Fitr, it is Sunnah to eat an odd number of dates before leaving; on Eid al-Adha, delay eating until after the Eid prayer (Sahih al-Bukhari 953).',
  ),
  EidSunnahItem(
    'takbiran',
    'Mengumandangkan Takbir Hari Raya',
    'Bertakbir sejak malam Id hingga imam naik mimbar Salat Id (dan hingga akhir Hari Tasyrik 13 Dzulhijjah pada Idul Adha).',
    titleEn: 'Recite the Eid Takbir',
    descriptionEn: 'Chant the Takbir from Eid eve until the imam begins the Eid sermon (and through the Days of Tashriq until 13 Dhul-Hijjah on Eid al-Adha).',
  ),
  EidSunnahItem(
    'jalan_berbeda',
    'Menempuh Jalan Berangkat dan Pulang yang Berbeda',
    'Rasulullah SAW apabila keluar pada Hari Raya mengambil jalan yang berbeda saat berangkat dan pulang (HR. Bukhari no. 986).',
    titleEn: 'Take Different Routes Going to and Returning from Prayer',
    descriptionEn: 'When the Prophet (peace be upon him) went out for Eid prayer, he returned by a different route (Sahih al-Bukhari 986).',
  ),
  EidSunnahItem(
    'tahniah_id',
    'Mengucapkan Tahniah: Taqabbalallahu Minna wa Minkum',
    'Doa para sahabat saat bertemu di Hari Raya: "Semoga Allah menerima amal ibadah kami dan kalian."',
    titleEn: 'Exchange Eid Greetings: Taqabbalallahu Minna wa Minkum',
    descriptionEn: 'The greeting of the Companions on Eid: "May Allah accept good deeds from us and from you."',
  ),
];

class EidChecklistRepository {
  static const _key = 'eid_checklist_state';
  final KeyValueStore _store;

  const EidChecklistRepository(this._store);

  Future<Set<String>> checkedIds() async {
    final raw = await _store.readJson(_key);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is String) x,
    };
  }

  Future<Set<String>> toggle(String id) async {
    final set = await checkedIds();
    if (!set.remove(id)) set.add(id);
    await _store.writeJson(_key, set.toList());
    return set;
  }
}
