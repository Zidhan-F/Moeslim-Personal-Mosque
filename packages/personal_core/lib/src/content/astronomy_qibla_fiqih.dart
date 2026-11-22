import 'dart:math' as math;

import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';
import 'l10n_core.dart';
import 'nearby_mosque_finder.dart';

// ================= 26. KIBLAT BAYANGAN MATAHARI (ISTIWA & RASHDUL QIBLAH) =================

class SolarQiblaSnapshot {
  final double sunAltitudeDeg;
  final double sunAzimuthDeg;
  final double shadowAzimuthDeg;
  final double qiblaBearingDeg;
  final double angleFromShadowToQiblaDeg;
  final bool isSunAboveHorizon;
  final String alignmentInstruction;
  final String? alignmentInstructionEn;

  const SolarQiblaSnapshot({
    required this.sunAltitudeDeg,
    required this.sunAzimuthDeg,
    required this.shadowAzimuthDeg,
    required this.qiblaBearingDeg,
    required this.angleFromShadowToQiblaDeg,
    required this.isSunAboveHorizon,
    required this.alignmentInstruction,
    this.alignmentInstructionEn,
  });

  String alignmentInstructionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (alignmentInstructionEn?.isNotEmpty ?? false)
          ? alignmentInstructionEn!
          : alignmentInstruction;
}

SolarQiblaSnapshot computeSolarShadowQibla({
  required Coordinates coords,
  required DateTime localTime,
  required double utcOffsetHours,
  AppLanguage lang = AppLanguage.id,
}) {
  final utc = localTime.subtract(Duration(minutes: (utcOffsetHours * 60).round()));
  final dayOfYear = utc.difference(DateTime.utc(utc.year, 1, 1)).inDays + 1;
  final fractionalHour = utc.hour + (utc.minute / 60.0) + (utc.second / 3600.0);
  final gamma = 2.0 * math.pi / 365.0 * (dayOfYear - 1 + (fractionalHour - 12.0) / 24.0);

  // Equation of time (minutes) and solar declination (radians)
  final eqTime = 229.18 *
      (0.000075 +
          0.001868 * math.cos(gamma) -
          0.032077 * math.sin(gamma) -
          0.014615 * math.cos(2 * gamma) -
          0.040849 * math.sin(2 * gamma));
  final decl = 0.006918 -
      0.399912 * math.cos(gamma) +
      0.070257 * math.sin(gamma) -
      0.006758 * math.cos(2 * gamma) +
      0.000907 * math.sin(2 * gamma) -
      0.002697 * math.cos(3 * gamma) +
      0.00148 * math.sin(3 * gamma);

  final localMinutes = localTime.hour * 60.0 + localTime.minute + (localTime.second / 60.0);
  final timeOffset = eqTime + 4.0 * coords.longitude - 60.0 * utcOffsetHours;
  final trueSolarTime = localMinutes + timeOffset;
  final hourAngleDeg = (trueSolarTime / 4.0) - 180.0;
  final haRad = hourAngleDeg * math.pi / 180.0;
  final latRad = coords.latitude * math.pi / 180.0;

  final sinAlt = math.sin(latRad) * math.sin(decl) + math.cos(latRad) * math.cos(decl) * math.cos(haRad);
  final altRad = math.asin(sinAlt.clamp(-1.0, 1.0));
  final altDeg = altRad * 180.0 / math.pi;

  final y = -math.sin(haRad);
  final x = math.tan(decl) * math.cos(latRad) - math.sin(latRad) * math.cos(haRad);
  final azDeg = ((math.atan2(y, x) * 180.0 / math.pi) + 360.0) % 360.0;
  final shadowDeg = (azDeg + 180.0) % 360.0;
  final qiblaDeg = qiblaBearing(coords);

  var delta = (qiblaDeg - shadowDeg) % 360.0;
  if (delta > 180.0) delta -= 360.0;

  final above = altDeg > 2.0;
  final String instructionId;
  final String instructionEn;
  if (!above) {
    instructionId =
        'Matahari sedang di bawah atau terlalu dekat ufuk. Gunakan metode bayangan saat matahari bersinar terang, atau gunakan patokan sudut bangunan di tab Peta Kiblat.';
    instructionEn =
        'The sun is below or too close to the horizon. Use the shadow method when the sun is shining clearly, or align with building landmarks in the Qibla Map tab.';
  } else if (delta.abs() <= 3.0) {
    instructionId =
        'Bayangan benda tegak saat ini SEJAJAR langsung dengan arah Kiblat! Arahkan sajadah mengikuti garis bayangan.';
    instructionEn =
        'A vertical object\'s shadow is currently aligned directly with the Qibla. Point your prayer mat along the shadow line.';
  } else if (delta > 0) {
    instructionId =
        'Tegakkan tongkat/benda lurus di bawah sinar matahari. Dari arah jatuhnya bayangan (${shadowDeg.toStringAsFixed(1)}°), putar ${delta.abs().toStringAsFixed(1)}° searah jarum jam (ke kanan) untuk menghadap Kiblat (${qiblaDeg.toStringAsFixed(1)}°).';
    instructionEn =
        'Stand a straight stick vertically in sunlight. From the shadow direction (${shadowDeg.toStringAsFixed(1)}°), rotate ${delta.abs().toStringAsFixed(1)}° clockwise (to the right) to face the Qibla (${qiblaDeg.toStringAsFixed(1)}°).';
  } else {
    instructionId =
        'Tegakkan tongkat/benda lurus di bawah sinar matahari. Dari arah jatuhnya bayangan (${shadowDeg.toStringAsFixed(1)}°), putar ${delta.abs().toStringAsFixed(1)}° berlawanan jarum jam (ke kiri) untuk menghadap Kiblat (${qiblaDeg.toStringAsFixed(1)}°).';
    instructionEn =
        'Stand a straight stick vertically in sunlight. From the shadow direction (${shadowDeg.toStringAsFixed(1)}°), rotate ${delta.abs().toStringAsFixed(1)}° counterclockwise (to the left) to face the Qibla (${qiblaDeg.toStringAsFixed(1)}°).';
  }

  return SolarQiblaSnapshot(
    sunAltitudeDeg: altDeg,
    sunAzimuthDeg: azDeg,
    shadowAzimuthDeg: shadowDeg,
    qiblaBearingDeg: qiblaDeg,
    angleFromShadowToQiblaDeg: delta,
    isSunAboveHorizon: above,
    alignmentInstruction: tr(lang, instructionId, instructionEn),
    alignmentInstructionEn: instructionEn,
  );
}

// ================= 28. KALKULATOR SAFAR & RUKHSHAH (JAMA' / QASHAR) =================

class SafarRukhshahEvaluation {
  final String originName;
  final String destinationName;
  final double straightDistanceKm;
  final double estimatedRoadDistanceKm;
  final bool eligibleForQasharAndJama;
  final String summary;
  final String? summaryEn;
  final List<String> prayerRules;
  final List<String>? prayerRulesEn;

  const SafarRukhshahEvaluation({
    required this.originName,
    required this.destinationName,
    required this.straightDistanceKm,
    required this.estimatedRoadDistanceKm,
    required this.eligibleForQasharAndJama,
    required this.summary,
    this.summaryEn,
    required this.prayerRules,
    this.prayerRulesEn,
  });

  String summaryFor(AppLanguage lang) =>
      lang == AppLanguage.en && (summaryEn?.isNotEmpty ?? false) ? summaryEn! : summary;
  List<String> prayerRulesFor(AppLanguage lang) =>
      lang == AppLanguage.en && (prayerRulesEn?.isNotEmpty ?? false) ? prayerRulesEn! : prayerRules;
}

SafarRukhshahEvaluation evaluateSafarRukhshah({
  required String originName,
  required Coordinates originCoords,
  required String destinationName,
  required Coordinates destinationCoords,
  AppLanguage lang = AppLanguage.id,
}) {
  const thresholdKm = 81.0; // 2 Marhalah / 16 Farsakh (Mayoritas Ulama / Jumhur)
  final straight = computeDistanceKm(originCoords, destinationCoords);
  final road = straight * 1.22;
  final eligible = road >= thresholdKm;

  final summaryId = eligible
      ? 'Jarak perjalanan tempuh (±${road.toStringAsFixed(1)} km) telah melampaui batas Masafatul Qashr (81 km). Anda mendapat keringanan (rukhshah) melaksanakan Salat Qashar dan Jama\' setelah keluar dari batas kota asal.'
      : 'Jarak perjalanan tempuh (±${road.toStringAsFixed(1)} km) belum mencapai batas Masafatul Qashr (81 km). Salat fardhu tetap dikerjakan sempurna (tamam) 4 rakaat pada waktunya masing-masing.';
  final summaryEn = eligible
      ? 'The estimated travel distance (about ${road.toStringAsFixed(1)} km) exceeds the Masafat al-Qasr threshold (81 km). You are eligible for the travel concession (rukhsah) to shorten (Qasr) and combine (Jam\') prayers once you pass your city limits.'
      : 'The estimated travel distance (about ${road.toStringAsFixed(1)} km) has not reached the Masafat al-Qasr threshold (81 km). Obligatory prayers remain full (4 rak\'ah) at their regular times.';

  final rulesId = eligible
      ? const [
          'Salat Dzuhur (4 -> 2 rakaat) & Ashar (4 -> 2 rakaat): dapat di-Qashar dan di-Jama\' (Taqdim di waktu Dzuhur atau Takhir di waktu Ashar).',
          'Salat Maghrib (tetap 3 rakaat) & Isya (4 -> 2 rakaat): dapat di-Jama\' (Taqdim di waktu Maghrib atau Takhir di waktu Isya).',
          'Salat Subuh (tetap 2 rakaat): dikerjakan pada waktunya sendiri (tidak di-jama\' dan tidak di-qashar).',
          'Batas Mukim: Rukhshah berlaku selama di perjalanan dan maksimal 4 hari (selain hari datang & pulang) di kota tujuan menurut mazhab Syafi\'i.',
        ]
      : const [
          'Seluruh salat fardhu (Subuh 2, Dzuhur 4, Ashar 4, Maghrib 3, Isya 4) dikerjakan sempurna pada waktunya.',
        ];
  final rulesEn = eligible
      ? const [
          'Dhuhr (4 -> 2 rak\'ah) & Asr (4 -> 2 rak\'ah): may be shortened (Qasr) and combined (Jam\' Taqdim during Dhuhr or Jam\' Ta\'khir during Asr).',
          'Maghrib (remains 3 rak\'ah) & Isha (4 -> 2 rak\'ah): may be combined (Jam\' Taqdim during Maghrib or Jam\' Ta\'khir during Isha).',
          'Fajr (remains 2 rak\'ah): always performed on its own time (neither shortened nor combined).',
          'Residency limit: The travel concession applies during transit and up to 4 full days (excluding arrival and departure days) at the destination under the Shafi\'i school.',
        ]
      : const [
          'All obligatory prayers (Fajr 2, Dhuhr 4, Asr 4, Maghrib 3, Isha 4) are performed in full at their appointed times.',
        ];

  return SafarRukhshahEvaluation(
    originName: originName,
    destinationName: destinationName,
    straightDistanceKm: straight,
    estimatedRoadDistanceKm: road,
    eligibleForQasharAndJama: eligible,
    summary: tr(lang, summaryId, summaryEn),
    summaryEn: summaryEn,
    prayerRules: lang == AppLanguage.en ? rulesEn : rulesId,
    prayerRulesEn: rulesEn,
  );
}

// ================= 29. WAKTU DHUHA, SEPERTIGA MALAM & WAKTU TERLARANG =================

class ExtendedPrayerWindows {
  final DateTime dhuhaStart;
  final DateTime dhuhaOptimal;
  final DateTime dhuhaEnd;
  final DateTime midnightNishfulLail;
  final DateTime lastThirdNightStart;
  final DateTime lastThirdNightEnd;
  final List<(String, DateTime, DateTime, String)> forbiddenWindows;
  final List<(String, DateTime, DateTime, String)>? forbiddenWindowsEn;

  const ExtendedPrayerWindows({
    required this.dhuhaStart,
    required this.dhuhaOptimal,
    required this.dhuhaEnd,
    required this.midnightNishfulLail,
    required this.lastThirdNightStart,
    required this.lastThirdNightEnd,
    required this.forbiddenWindows,
    this.forbiddenWindowsEn,
  });

  List<(String, DateTime, DateTime, String)> forbiddenWindowsFor(AppLanguage lang) =>
      lang == AppLanguage.en && (forbiddenWindowsEn?.isNotEmpty ?? false)
          ? forbiddenWindowsEn!
          : forbiddenWindows;
}

ExtendedPrayerWindows computeExtendedPrayerWindows(
  PrayerTimes today,
  PrayerTimes tomorrow, {
  AppLanguage lang = AppLanguage.id,
}) {
  final dhuhaStart = today.sunrise.add(const Duration(minutes: 15));
  final dhuhaEnd = today.dhuhr.subtract(const Duration(minutes: 10));
  final dhuhaSpanMinutes = dhuhaEnd.difference(dhuhaStart).inMinutes.clamp(10, 600);
  final dhuhaOptimal = dhuhaStart.add(Duration(minutes: (dhuhaSpanMinutes * 0.6).round()));

  final nightDurationMinutes = tomorrow.fajr.difference(today.maghrib).inMinutes.clamp(60, 1000);
  final midnight = today.maghrib.add(Duration(minutes: (nightDurationMinutes / 2.0).round()));
  final lastThirdStart = tomorrow.fajr.subtract(Duration(minutes: (nightDurationMinutes / 3.0).round()));

  final forbiddenId = <(String, DateTime, DateTime, String)>[
    (
      '1. Ba\'da Subuh hingga Matahari Naik',
      today.fajr,
      dhuhaStart,
      'Dilarang mengerjakan salat sunnah mutlak setelah Salat Subuh hingga matahari terbit dan naik setinggi tombak (±15 menit pasca Syuruq).',
    ),
    (
      '2. Saat Matahari Tepat di Atas Kepala (Istiwa)',
      dhuhaEnd,
      today.dhuhr,
      'Menjelang matahari tergelincir (±10 menit sebelum Dzuhur), kecuali pada hari Jumat.',
    ),
    (
      '3. Ba\'da Ashar hingga Matahari Terbenam',
      today.asr,
      today.maghrib,
      'Setelah menunaikan Salat Ashar hingga matahari tenggelam sempurna pada waktu Maghrib.',
    ),
  ];

  final forbiddenEn = <(String, DateTime, DateTime, String)>[
    (
      '1. After Fajr Until Sunrise Rises',
      today.fajr,
      dhuhaStart,
      'Unrestricted voluntary prayers are forbidden after Fajr until the sun rises a spear\'s height above the horizon (about 15 minutes after sunrise).',
    ),
    (
      '2. Solar Zenith (Istiwa)',
      dhuhaEnd,
      today.dhuhr,
      'When the sun is directly overhead (about 10 minutes before Dhuhr), except on Fridays.',
    ),
    (
      '3. After Asr Until Sunset',
      today.asr,
      today.maghrib,
      'After performing the Asr prayer until the sun has completely set at Maghrib.',
    ),
  ];

  return ExtendedPrayerWindows(
    dhuhaStart: dhuhaStart,
    dhuhaOptimal: dhuhaOptimal,
    dhuhaEnd: dhuhaEnd,
    midnightNishfulLail: midnight,
    lastThirdNightStart: lastThirdStart,
    lastThirdNightEnd: tomorrow.fajr,
    forbiddenWindows: lang == AppLanguage.en ? forbiddenEn : forbiddenId,
    forbiddenWindowsEn: forbiddenEn,
  );
}

// ================= 30. PANDUAN & CHECKLIST SUNNAH HARI JUMAT =================

class FridaySunnahItem {
  final String id;
  final String title;
  final String? titleEn;
  final String dalilAndVirtue;
  final String? dalilAndVirtueEn;

  const FridaySunnahItem({
    required this.id,
    required this.title,
    this.titleEn,
    required this.dalilAndVirtue,
    this.dalilAndVirtueEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String dalilAndVirtueFor(AppLanguage lang) =>
      lang == AppLanguage.en && (dalilAndVirtueEn?.isNotEmpty ?? false) ? dalilAndVirtueEn! : dalilAndVirtue;
}

const List<FridaySunnahItem> fridaySunnahCatalog = [
  FridaySunnahItem(
    id: 'mandi_jumat',
    title: 'Mandi Sunnah Hari Jumat',
    titleEn: 'Take the Friday Bath (Ghusl)',
    dalilAndVirtue: 'HR. Bukhari no. 877: "Mandi pada hari Jumat adalah wajib (sangat ditekankan) bagi setiap orang yang sudah baligh."',
    dalilAndVirtueEn: 'Sahih al-Bukhari 877: "Bathing on Friday is strongly emphasized upon every adult Muslim."',
  ),
  FridaySunnahItem(
    id: 'siwak_wewangian',
    title: 'Bersiwak, Memotong Kuku & Memakai Wewangian',
    titleEn: 'Use Siwak, Trim Nails & Apply Perfume',
    dalilAndVirtue: 'HR. Bukhari no. 880: Dianjurkan bersiwak dan memakai wewangian terbaik sebelum berangkat ke masjid.',
    dalilAndVirtueEn: 'Sahih al-Bukhari 880: Brushing the teeth and applying one\'s best fragrance before heading to the mosque is recommended.',
  ),
  FridaySunnahItem(
    id: 'pakaian_terbaik',
    title: 'Memakai Pakaian Terbaik (Utama Warna Putih)',
    titleEn: 'Wear Your Best Clothes (Preferably White)',
    dalilAndVirtue: 'HR. Abu Dawud no. 343: Mengenakan pakaian yang bersih dan terbaik untuk menghormati hari raya pekanan.',
    dalilAndVirtueEn: 'Sunan Abi Dawud 343: Wear clean, fine garments to honor the weekly day of gathering.',
  ),
  FridaySunnahItem(
    id: 'baca_alkahfi',
    title: 'Membaca Surah Al-Kahfi',
    titleEn: 'Recite Surah Al-Kahf',
    dalilAndVirtue: 'HR. Al-Hakim II/399 (Shahih): Disinari cahaya keberkahan di antara dua Jumat.',
    dalilAndVirtueEn: 'Al-Hakim 2/399 (Sahih): Illuminated by a light of guidance and blessing between two Fridays.',
  ),
  FridaySunnahItem(
    id: 'perbanyak_shalawat',
    title: 'Memperbanyak Shalawat kepada Nabi SAW',
    titleEn: 'Send Abundant Blessings (Salawat) Upon the Prophet',
    dalilAndVirtue: 'HR. Abu Dawud no. 1047: "Perbanyaklah shalawat kepadaku pada hari Jumat dan malam Jumat."',
    dalilAndVirtueEn: 'Sunan Abi Dawud 1047: "Send abundant blessings upon me on Friday and the night before Friday."',
  ),
  FridaySunnahItem(
    id: 'berangkat_awal',
    title: 'Berangkat Lebih Awal ke Masjid & Salat Tahiyatul Masjid',
    titleEn: 'Arrive Early to the Mosque & Pray Tahiyyatul Masjid',
    dalilAndVirtue: 'HR. Bukhari no. 881: Berangkat di jam pertama bagaikan berkurban seekor unta.',
    dalilAndVirtueEn: 'Sahih al-Bukhari 881: Arriving in the first hour carries a reward comparable to offering a camel in charity.',
  ),
  FridaySunnahItem(
    id: 'simak_khutbah',
    title: 'Mendengarkan Khutbah Jumat dengan Khusyuk',
    titleEn: 'Listen Attentively to the Friday Sermon (Khutbah)',
    dalilAndVirtue: 'HR. Bukhari no. 934: Diam menyimak khutbah Jumat menjadi sebab diampuninya dosa di antara dua Jumat.',
    dalilAndVirtueEn: 'Sahih al-Bukhari 934: Listening quietly to the sermon brings forgiveness of sins between two Fridays.',
  ),
  FridaySunnahItem(
    id: 'doa_ashar_jumat',
    title: 'Berdoa pada Waktu Mustajab Akhir Hari Jumat (Ba\'da Ashar)',
    titleEn: 'Make Dua in the Blessed Hour After Asr on Friday',
    dalilAndVirtue: 'HR. Abu Dawud no. 1048: Waktu mustajab pada penghujung hari Jumat setelah Ashar menjelang Maghrib.',
    dalilAndVirtueEn: 'Sunan Abi Dawud 1048: Seek the hour of answered supplication at the close of Friday between Asr and Maghrib.',
  ),
];

class FridaySunnahRepository {
  static const _key = 'friday_sunnah_checks';
  final KeyValueStore _store;

  const FridaySunnahRepository(this._store);

  Future<Set<String>> checkedForDate(DateTime date) async {
    final raw = await _store.readJson(_key);
    if (raw is! Map) return {};
    final list = raw[TrackerRepository.dayKey(date)];
    if (list is! List) return {};
    return {
      for (final x in list)
        if (x is String) x,
    };
  }

  Future<Set<String>> toggleItem(DateTime date, String itemId) async {
    final raw = await _store.readJson(_key);
    final all = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final current = await checkedForDate(date);
    if (!current.remove(itemId)) {
      current.add(itemId);
    }
    all[TrackerRepository.dayKey(date)] = current.toList();
    await _store.writeJson(_key, all);
    return current;
  }
}
