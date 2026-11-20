import 'package:shared_prayer/shared_prayer.dart';

import '../content/cities.dart';

enum AppThemeMode { system, light, dark }

class PersonalSettings {
  final City location;
  final bool useDeviceLocation;
  final CalculationMethod method;
  final AsrMadhab madhab;
  final Map<Prayer, int> adjustments;
  final int hijriOffset;
  final AppThemeMode themeMode;
  final double fontScale;
  final bool notificationsEnabled;

  /// Warnai teks Al-Qur'an sesuai hukum tajwid (bila dataset anotasi tersedia).
  final bool tajweedColors;

  /// Nama panggilan untuk sapaan di Beranda (opsional, hanya di perangkat).
  final String? displayName;
  final bool onboardingDone;
  final int tilawahTargetPages;

  const PersonalSettings({
    required this.location,
    this.useDeviceLocation = false,
    this.method = CalculationMethod.kemenag,
    this.madhab = AsrMadhab.shafii,
    this.adjustments = const {},
    this.hijriOffset = 0,
    this.themeMode = AppThemeMode.system,
    this.fontScale = 1.0,
    this.notificationsEnabled = true,
    this.tajweedColors = true,
    this.displayName,
    this.onboardingDone = false,
    this.tilawahTargetPages = 20,
  });

  static final PersonalSettings defaults =
      PersonalSettings(location: indonesianCities.firstWhere((c) => c.name == 'Jakarta'));

  PrayerCalculator get calculator => PrayerCalculator(method, madhab: madhab, adjustments: adjustments);

  PrayerTimes timesFor(DateTime date) =>
      calculator.compute(date, location.coordinates, utcOffsetHours: location.utcOffset);

  PersonalSettings copyWith({
    City? location,
    bool? useDeviceLocation,
    CalculationMethod? method,
    AsrMadhab? madhab,
    Map<Prayer, int>? adjustments,
    int? hijriOffset,
    AppThemeMode? themeMode,
    double? fontScale,
    bool? notificationsEnabled,
    bool? tajweedColors,
    String? displayName,
    bool? onboardingDone,
    int? tilawahTargetPages,
  }) =>
      PersonalSettings(
        location: location ?? this.location,
        useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
        method: method ?? this.method,
        madhab: madhab ?? this.madhab,
        adjustments: adjustments ?? this.adjustments,
        hijriOffset: hijriOffset ?? this.hijriOffset,
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        tajweedColors: tajweedColors ?? this.tajweedColors,
        displayName: displayName ?? this.displayName,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        tilawahTargetPages: tilawahTargetPages ?? this.tilawahTargetPages,
      );

  Map<String, Object> toJson() => {
        'location': location.toJson(),
        'useDeviceLocation': useDeviceLocation,
        'method': method.name,
        'madhab': madhab.name,
        'adjustments': {for (final e in adjustments.entries) e.key.name: e.value},
        'hijriOffset': hijriOffset,
        'themeMode': themeMode.name,
        'fontScale': fontScale,
        'notificationsEnabled': notificationsEnabled,
        'tajweedColors': tajweedColors,
        if (displayName != null) 'displayName': displayName!,
        'onboardingDone': onboardingDone,
        'tilawahTargetPages': tilawahTargetPages,
      };

  factory PersonalSettings.fromJson(Map<String, dynamic> j) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    final adj = (j['adjustments'] as Map?) ?? const {};
    return PersonalSettings(
      location: City.fromJson(Map<String, dynamic>.from(j['location'] as Map)),
      useDeviceLocation: j['useDeviceLocation'] as bool? ?? false,
      method: byName(CalculationMethod.values, j['method'], CalculationMethod.kemenag),
      madhab: byName(AsrMadhab.values, j['madhab'], AsrMadhab.shafii),
      adjustments: {
        for (final e in adj.entries)
          if (Prayer.values.any((p) => p.name == e.key))
            Prayer.values.byName(e.key as String): (e.value as num).toInt(),
      },
      hijriOffset: (j['hijriOffset'] as num?)?.toInt() ?? 0,
      themeMode: byName(AppThemeMode.values, j['themeMode'], AppThemeMode.system),
      fontScale: (j['fontScale'] as num?)?.toDouble() ?? 1.0,
      notificationsEnabled: j['notificationsEnabled'] as bool? ?? true,
      tajweedColors: j['tajweedColors'] as bool? ?? true,
      displayName: j['displayName'] as String?,
      onboardingDone: j['onboardingDone'] as bool? ?? false,
      tilawahTargetPages: (j['tilawahTargetPages'] as num?)?.toInt() ?? 20,
    );
  }
}
