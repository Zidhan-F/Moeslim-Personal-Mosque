import 'dart:math' as math;

import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';
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

  const SolarQiblaSnapshot({
    required this.sunAltitudeDeg,
    required this.sunAzimuthDeg,
    required this.shadowAzimuthDeg,
    required this.qiblaBearingDeg,
    required this.angleFromShadowToQiblaDeg,
    required this.isSunAboveHorizon,
    required this.alignmentInstruction,
  });
}

SolarQiblaSnapshot computeSolarShadowQibla({
  required Coordinates coords,
  required DateTime localTime,
  required double utcOffsetHours,
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
  final String instruction;
  if (!above) {
    instruction =
        'Matahari sedang di bawah atau terlalu dekat ufuk. Gunakan metode bayangan saat matahari bersinar terang, atau gunakan patokan sudut bangunan di tab Peta Kiblat.';
  } else if (delta.abs() <= 3.0) {
    instruction =
        'Bayangan benda tegak saat ini SEJAJAR langsung dengan arah Kiblat! Arahkan sajadah mengikuti garis bayangan.';
  } else if (delta > 0) {
    instruction =
        'Tegakkan tongkat/benda lurus di bawah sinar matahari. Dari arah jatuhnya bayangan (${shadowDeg.toStringAsFixed(1)}°), putar ${delta.abs().toStringAsFixed(1)}° searah jarum jam (ke kanan) untuk menghadap Kiblat (${qiblaDeg.toStringAsFixed(1)}°).';
  } else {
    instruction =
        'Tegakkan tongkat/benda lurus di bawah sinar matahari. Dari arah jatuhnya bayangan (${shadowDeg.toStringAsFixed(1)}°), putar ${delta.abs().toStringAsFixed(1)}° berlawanan jarum jam (ke kiri) untuk menghadap Kiblat (${qiblaDeg.toStringAsFixed(1)}°).';
  }

  return SolarQiblaSnapshot(
    sunAltitudeDeg: altDeg,
    sunAzimuthDeg: azDeg,
    shadowAzimuthDeg: shadowDeg,
    qiblaBearingDeg: qiblaDeg,
    angleFromShadowToQiblaDeg: delta,
    isSunAboveHorizon: above,
    alignmentInstruction: instruction,
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
  final List<String> prayerRules;

  const SafarRukhshahEvaluation({
    required this.originName,
    required this.destinationName,
    required this.straightDistanceKm,
    required this.estimatedRoadDistanceKm,
    required this.eligibleForQasharAndJama,
    required this.summary,
    required this.prayerRules,
  });
}

SafarRukhshahEvaluation evaluateSafarRukhshah({
  required String originName,
  required Coordinates originCoords,
  required String destinationName,
  required Coordinates destinationCoords,
}) {
  const thresholdKm = 81.0; // 2 Marhalah / 16 Farsakh (Mayoritas Ulama / Jumhur)
  final straight = computeDistanceKm(originCoords, destinationCoords);
  final road = straight * 1.22;
  final eligible = road >= thresholdKm;

  final summary = eligible
      ? 'Jarak perjalanan tempuh (±${road.toStringAsFixed(1)} km) telah melampaui batas Masafatul Qashr (81 km). Anda mendapat keringanan (rukhshah) melaksanakan Salat Qashar dan Jama\' setelah keluar dari batas kota asal.'
      : 'Jarak perjalanan tempuh (±${road.toStringAsFixed(1)} km) belum mencapai batas Masafatul Qashr (81 km). Salat fardhu tetap dikerjakan sempurna (tamam) 4 rakaat pada waktunya masing-masing.';

  final rules = eligible
      ? const [
          'Salat Dzuhur (4 -> 2 rakaat) & Ashar (4 -> 2 rakaat): dapat di-Qashar dan di-Jama\' (Taqdim di waktu Dzuhur atau Takhir di waktu Ashar).',
          'Salat Maghrib (tetap 3 rakaat) & Isya (4 -> 2 rakaat): dapat di-Jama\' (Taqdim di waktu Maghrib atau Takhir di waktu Isya).',
          'Salat Subuh (tetap 2 rakaat): dikerjakan pada waktunya sendiri (tidak di-jama\' dan tidak di-qashar).',
          'Batas Mukim: Rukhshah berlaku selama di perjalanan dan maksimal 4 hari (selain hari datang & pulang) di kota tujuan menurut mazhab Syafi\'i.',
        ]
      : const [
          'Seluruh salat fardhu (Subuh 2, Dzuhur 4, Ashar 4, Maghrib 3, Isya 4) dikerjakan sempurna pada waktunya.',
        ];

  return SafarRukhshahEvaluation(
    originName: originName,
    destinationName: destinationName,
    straightDistanceKm: straight,
    estimatedRoadDistanceKm: road,
    eligibleForQasharAndJama: eligible,
    summary: summary,
    prayerRules: rules,
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

  const ExtendedPrayerWindows({
    required this.dhuhaStart,
    required this.dhuhaOptimal,
    required this.dhuhaEnd,
    required this.midnightNishfulLail,
    required this.lastThirdNightStart,
    required this.lastThirdNightEnd,
    required this.forbiddenWindows,
  });
}

ExtendedPrayerWindows computeExtendedPrayerWindows(PrayerTimes today, PrayerTimes tomorrow) {
  final dhuhaStart = today.sunrise.add(const Duration(minutes: 15));
  final dhuhaEnd = today.dhuhr.subtract(const Duration(minutes: 10));
  final dhuhaSpanMinutes = dhuhaEnd.difference(dhuhaStart).inMinutes.clamp(10, 600);
  final dhuhaOptimal = dhuhaStart.add(Duration(minutes: (dhuhaSpanMinutes * 0.6).round()));

  final nightDurationMinutes = tomorrow.fajr.difference(today.maghrib).inMinutes.clamp(60, 1000);
  final midnight = today.maghrib.add(Duration(minutes: (nightDurationMinutes / 2.0).round()));
  final lastThirdStart = tomorrow.fajr.subtract(Duration(minutes: (nightDurationMinutes / 3.0).round()));

  final forbidden = <(String, DateTime, DateTime, String)>[
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

  return ExtendedPrayerWindows(
    dhuhaStart: dhuhaStart,
    dhuhaOptimal: dhuhaOptimal,
    dhuhaEnd: dhuhaEnd,
    midnightNishfulLail: midnight,
    lastThirdNightStart: lastThirdStart,
    lastThirdNightEnd: tomorrow.fajr,
    forbiddenWindows: forbidden,
  );
}

// ================= 30. PANDUAN & CHECKLIST SUNNAH HARI JUMAT =================

class FridaySunnahItem {
  final String id;
  final String title;
  final String dalilAndVirtue;

  const FridaySunnahItem({
    required this.id,
    required this.title,
    required this.dalilAndVirtue,
  });
}

const List<FridaySunnahItem> fridaySunnahCatalog = [
  FridaySunnahItem(
    id: 'mandi_jumat',
    title: 'Mandi Sunnah Hari Jumat',
    dalilAndVirtue: 'HR. Bukhari no. 877: "Mandi pada hari Jumat adalah wajib (sangat ditekankan) bagi setiap orang yang sudah baligh."',
  ),
  FridaySunnahItem(
    id: 'siwak_wewangian',
    title: 'Bersiwak, Memotong Kuku & Memakai Wewangian',
    dalilAndVirtue: 'HR. Bukhari no. 880: Dianjurkan bersiwak dan memakai wewangian terbaik sebelum berangkat ke masjid.',
  ),
  FridaySunnahItem(
    id: 'pakaian_terbaik',
    title: 'Memakai Pakaian Terbaik (Utama Warna Putih)',
    dalilAndVirtue: 'HR. Abu Dawud no. 343: Mengenakan pakaian yang bersih dan terbaik untuk menghormati hari raya pekanan.',
  ),
  FridaySunnahItem(
    id: 'baca_alkahfi',
    title: 'Membaca Surah Al-Kahfi',
    dalilAndVirtue: 'HR. Al-Hakim II/399 (Shahih): Disinari cahaya keberkahan di antara dua Jumat.',
  ),
  FridaySunnahItem(
    id: 'perbanyak_shalawat',
    title: 'Memperbanyak Shalawat kepada Nabi SAW',
    dalilAndVirtue: 'HR. Abu Dawud no. 1047: "Perbanyaklah shalawat kepadaku pada hari Jumat dan malam Jumat."',
  ),
  FridaySunnahItem(
    id: 'berangkat_awal',
    title: 'Berangkat Lebih Awal ke Masjid & Salat Tahiyatul Masjid',
    dalilAndVirtue: 'HR. Bukhari no. 881: Berangkat di jam pertama bagaikan berkurban seekor unta.',
  ),
  FridaySunnahItem(
    id: 'simak_khutbah',
    title: 'Mendengarkan Khutbah Jumat dengan Khusyuk',
    dalilAndVirtue: 'HR. Bukhari no. 934: Diam menyimak khutbah Jumat menjadi sebab diampuninya dosa di antara dua Jumat.',
  ),
  FridaySunnahItem(
    id: 'doa_ashar_jumat',
    title: 'Berdoa pada Waktu Mustajab Akhir Hari Jumat (Ba\'da Ashar)',
    dalilAndVirtue: 'HR. Abu Dawud no. 1048: Waktu mustajab pada penghujung hari Jumat setelah Ashar menjelang Maghrib.',
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
