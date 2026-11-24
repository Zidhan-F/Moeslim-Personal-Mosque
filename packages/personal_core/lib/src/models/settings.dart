import 'package:shared_prayer/shared_prayer.dart';

import '../content/cities.dart';

enum AppThemeMode { light, dark, nature, sky, twilight, sahara, layl, sakina, zamrud, rosa }

/// Pilihan suara muadzin untuk alarm adzan waktu salat.
class AdzanMuadzin {
  final String id;
  final String name;
  final String origin;
  final String originEn;
  final String style;
  final String styleEn;
  final String assetPath;

  const AdzanMuadzin({
    required this.id,
    required this.name,
    required this.origin,
    required this.originEn,
    required this.style,
    required this.styleEn,
    required this.assetPath,
  });

  String originFor(AppLanguage lang) => lang == AppLanguage.en ? originEn : origin;
  String styleFor(AppLanguage lang) => lang == AppLanguage.en ? styleEn : style;
}

/// Katalog muadzin pilihan yang tersedia di aplikasi (termasuk aset audio adzan offline).
const adzanMuadzins = <AdzanMuadzin>[
  AdzanMuadzin(
    id: 'makkah',
    name: 'Syaikh Ali Ahmad Mulla',
    origin: 'Masjidil Haram, Makkah',
    originEn: 'Al-Masjid al-Haram, Makkah',
    style: 'Maqam Hijaz klasik Makkah',
    styleEn: 'Classic Makkah Hijaz maqam',
    assetPath: 'assets/audio/adzan/makkah.mp3',
  ),
  AdzanMuadzin(
    id: 'madinah',
    name: 'Syaikh Essam Bukhari',
    origin: 'Masjid Nabawi, Madinah',
    originEn: 'Al-Masjid an-Nabawi, Madinah',
    style: 'Maqam Bayati syahdu Madinah',
    styleEn: 'Serene Madinah Bayati maqam',
    assetPath: 'assets/audio/adzan/madinah.mp3',
  ),
  AdzanMuadzin(
    id: 'al_aqsa',
    name: 'Muadzin Al-Quds',
    origin: 'Masjidil Aqsa, Yerusalem',
    originEn: 'Al-Aqsa Mosque, Jerusalem',
    style: 'Maqam Rast khas Al-Quds',
    styleEn: 'Distinctive Al-Quds Rast maqam',
    assetPath: 'assets/audio/adzan/al_aqsa.mp3',
  ),
  AdzanMuadzin(
    id: 'mishary',
    name: 'Syaikh Mishary Rashid Alafasy',
    origin: 'Masjid Al-Kabir, Kuwait',
    originEn: 'Grand Mosque, Kuwait',
    style: 'Maqam Nahawand lembut & khusyuk',
    styleEn: 'Gentle and contemplative Nahawand maqam',
    assetPath: 'assets/audio/adzan/mishary.mp3',
  ),
];

/// Koordinat GPS aktual perangkat yang tersimpan secara lokal untuk jadwal salat.
class DeviceLocation {
  final double latitude;
  final double longitude;
  final double utcOffset;
  final String label;
  final double? accuracyMeters;
  final DateTime updatedAt;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.utcOffset,
    required this.label,
    this.accuracyMeters,
    required this.updatedAt,
  });

  Coordinates get coordinates => Coordinates(latitude, longitude);

  String get zone => switch (utcOffset) {
        7.0 => 'WIB',
        8.0 => 'WITA',
        9.0 => 'WIT',
        _ => utcOffset >= 0 ? 'UTC+$utcOffset' : 'UTC$utcOffset',
      };

  Map<String, Object> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'tz': utcOffset,
        'label': label,
        if (accuracyMeters != null) 'accuracyMeters': accuracyMeters!,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory DeviceLocation.fromJson(Map<String, dynamic> j) => DeviceLocation(
        latitude: (j['lat'] as num).toDouble(),
        longitude: (j['lng'] as num).toDouble(),
        utcOffset: (j['tz'] as num).toDouble(),
        label: j['label'] as String? ?? 'Lokasi GPS',
        accuracyMeters: (j['accuracyMeters'] as num?)?.toDouble(),
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
}

class PersonalSettings {
  final City location;
  final bool useDeviceLocation;
  final DeviceLocation? deviceLocation;
  final CalculationMethod method;
  final AsrMadhab madhab;
  final Map<Prayer, int> adjustments;
  final int hijriOffset;
  final AppThemeMode themeMode;
  final double fontScale;
  final bool notificationsEnabled;
  final Map<Prayer, bool> prayerAdzan;
  final String muadzinId;

  /// Volume khusus suara adzan di dalam aplikasi (0.0 sampai 1.0, independen dari volume HP).
  final double adzanVolume;

  /// Bila true, suara adzan memakai pengaturan volume aplikasi sendiri (mengabaikan mode hening/volume HP).
  final bool adzanOverrideDeviceVolume;

  /// Warnai teks Al-Qur'an sesuai hukum tajwid (bila dataset anotasi tersedia).
  final bool tajweedColors;

  /// Nama panggilan untuk sapaan di Beranda (opsional, hanya di perangkat).
  final String? displayName;

  /// Path berkas foto profil lokal di perangkat (100% offline, tidak pernah diunggah).
  final String? profilePhotoPath;
  final bool onboardingDone;
  final int tilawahTargetPages;
  final AppLanguage language;

  const PersonalSettings({
    required this.location,
    this.useDeviceLocation = false,
    this.deviceLocation,
    this.method = CalculationMethod.kemenag,
    this.madhab = AsrMadhab.shafii,
    this.adjustments = const {},
    this.hijriOffset = 0,
    this.themeMode = AppThemeMode.light,
    this.fontScale = 1.0,
    this.notificationsEnabled = true,
    this.prayerAdzan = const {},
    this.muadzinId = 'makkah',
    this.adzanVolume = 0.85,
    this.adzanOverrideDeviceVolume = true,
    this.tajweedColors = true,
    this.displayName,
    this.profilePhotoPath,
    this.onboardingDone = false,
    this.tilawahTargetPages = 20,
    this.language = AppLanguage.id,
  });

  static final PersonalSettings defaults =
      PersonalSettings(location: indonesianCities.firstWhere((c) => c.name == 'Jakarta'));

  AdzanMuadzin get muadzin =>
      adzanMuadzins.where((m) => m.id == muadzinId).firstOrNull ?? adzanMuadzins.first;

  bool isAdzanActiveFor(Prayer prayer) => notificationsEnabled && (prayerAdzan[prayer] ?? true);

  int get activeAdzanCount =>
      !notificationsEnabled ? 0 : Prayer.values.where((p) => prayerAdzan[p] ?? true).length;

  PersonalSettings setPrayerAdzan(Prayer prayer, bool enabled) {
    final nextMap = {
      for (final p in Prayer.values) p: prayerAdzan[p] ?? true,
      prayer: enabled,
    };
    return copyWith(
      notificationsEnabled: enabled ? true : notificationsEnabled,
      prayerAdzan: nextMap,
    );
  }

  bool get isUsingGpsLocation => useDeviceLocation && deviceLocation != null;

  Coordinates get effectiveCoordinates => isUsingGpsLocation ? deviceLocation!.coordinates : location.coordinates;

  double get effectiveUtcOffset => isUsingGpsLocation ? deviceLocation!.utcOffset : location.utcOffset;

  String get effectiveLocationName => isUsingGpsLocation ? deviceLocation!.label : location.name;

  String get effectiveLocationSubtitle =>
      isUsingGpsLocation ? '${deviceLocation!.label} (GPS)' : '${location.name}, ${location.province}';

  PrayerCalculator get calculator => PrayerCalculator(method, madhab: madhab, adjustments: adjustments);

  PrayerTimes timesFor(DateTime date) =>
      calculator.compute(date, effectiveCoordinates, utcOffsetHours: effectiveUtcOffset);

  PersonalSettings copyWith({
    City? location,
    bool? useDeviceLocation,
    DeviceLocation? deviceLocation,
    bool clearDeviceLocation = false,
    CalculationMethod? method,
    AsrMadhab? madhab,
    Map<Prayer, int>? adjustments,
    int? hijriOffset,
    AppThemeMode? themeMode,
    double? fontScale,
    bool? notificationsEnabled,
    Map<Prayer, bool>? prayerAdzan,
    String? muadzinId,
    double? adzanVolume,
    bool? adzanOverrideDeviceVolume,
    bool? tajweedColors,
    String? displayName,
    String? profilePhotoPath,
    bool clearProfilePhoto = false,
    bool? onboardingDone,
    int? tilawahTargetPages,
    AppLanguage? language,
  }) =>
      PersonalSettings(
        location: location ?? this.location,
        useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
        deviceLocation: clearDeviceLocation ? null : (deviceLocation ?? this.deviceLocation),
        method: method ?? this.method,
        madhab: madhab ?? this.madhab,
        adjustments: adjustments ?? this.adjustments,
        hijriOffset: hijriOffset ?? this.hijriOffset,
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        prayerAdzan: prayerAdzan ?? this.prayerAdzan,
        muadzinId: muadzinId ?? this.muadzinId,
        adzanVolume: (adzanVolume ?? this.adzanVolume).clamp(0.0, 1.0).toDouble(),
        adzanOverrideDeviceVolume: adzanOverrideDeviceVolume ?? this.adzanOverrideDeviceVolume,
        tajweedColors: tajweedColors ?? this.tajweedColors,
        displayName: displayName ?? this.displayName,
        profilePhotoPath: clearProfilePhoto ? null : (profilePhotoPath ?? this.profilePhotoPath),
        onboardingDone: onboardingDone ?? this.onboardingDone,
        tilawahTargetPages: tilawahTargetPages ?? this.tilawahTargetPages,
        language: language ?? this.language,
      );

  Map<String, Object> toJson() => {
        'location': location.toJson(),
        'useDeviceLocation': useDeviceLocation,
        if (deviceLocation != null) 'deviceLocation': deviceLocation!.toJson(),
        'method': method.name,
        'madhab': madhab.name,
        'adjustments': {for (final e in adjustments.entries) e.key.name: e.value},
        'hijriOffset': hijriOffset,
        'themeMode': themeMode.name,
        'fontScale': fontScale,
        'notificationsEnabled': notificationsEnabled,
        'prayerAdzan': {for (final e in prayerAdzan.entries) e.key.name: e.value},
        'muadzinId': muadzinId,
        'adzanVolume': adzanVolume,
        'adzanOverrideDeviceVolume': adzanOverrideDeviceVolume,
        'tajweedColors': tajweedColors,
        if (displayName != null) 'displayName': displayName!,
        if (profilePhotoPath != null) 'profilePhotoPath': profilePhotoPath!,
        'onboardingDone': onboardingDone,
        'tilawahTargetPages': tilawahTargetPages,
        'language': language.code,
      };

  factory PersonalSettings.fromJson(Map<String, dynamic> j) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    final adj = (j['adjustments'] as Map?) ?? const {};
    final adzanMap = (j['prayerAdzan'] as Map?) ?? const {};
    final rawDeviceLoc = j['deviceLocation'];
    final rawMuadzin = j['muadzinId'] as String?;
    return PersonalSettings(
      location: City.fromJson(Map<String, dynamic>.from(j['location'] as Map)),
      useDeviceLocation: j['useDeviceLocation'] as bool? ?? false,
      deviceLocation:
          rawDeviceLoc is Map ? DeviceLocation.fromJson(Map<String, dynamic>.from(rawDeviceLoc)) : null,
      method: byName(CalculationMethod.values, j['method'], CalculationMethod.kemenag),
      madhab: byName(AsrMadhab.values, j['madhab'], AsrMadhab.shafii),
      adjustments: {
        for (final e in adj.entries)
          if (Prayer.values.any((p) => p.name == e.key))
            Prayer.values.byName(e.key as String): (e.value as num).toInt(),
      },
      hijriOffset: (j['hijriOffset'] as num?)?.toInt() ?? 0,
      themeMode: byName(AppThemeMode.values, j['themeMode'], AppThemeMode.light),
      fontScale: (j['fontScale'] as num?)?.toDouble() ?? 1.0,
      notificationsEnabled: j['notificationsEnabled'] as bool? ?? true,
      prayerAdzan: {
        for (final e in adzanMap.entries)
          if (Prayer.values.any((p) => p.name == e.key) && e.value is bool)
            Prayer.values.byName(e.key as String): e.value as bool,
      },
      muadzinId: adzanMuadzins.any((m) => m.id == rawMuadzin) ? rawMuadzin! : 'makkah',
      adzanVolume: ((j['adzanVolume'] as num?)?.toDouble() ?? 0.85).clamp(0.0, 1.0).toDouble(),
      adzanOverrideDeviceVolume: j['adzanOverrideDeviceVolume'] as bool? ?? true,
      tajweedColors: j['tajweedColors'] as bool? ?? true,
      displayName: j['displayName'] as String?,
      profilePhotoPath: j['profilePhotoPath'] as String?,
      onboardingDone: j['onboardingDone'] as bool? ?? false,
      tilawahTargetPages: (j['tilawahTargetPages'] as num?)?.toInt() ?? 20,
      language: AppLanguage.fromCode(j['language'] as String?),
    );
  }
}
