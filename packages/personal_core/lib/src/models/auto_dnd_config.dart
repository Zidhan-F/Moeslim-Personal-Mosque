import 'package:shared_prayer/shared_prayer.dart';

import '../content/l10n_core.dart';
import '../storage/key_value_store.dart';

class AutoDndConfig {
  final bool enabled;
  final int minutesBeforeAdzan;
  final int minutesAfterAdzan;
  final int fridayDurationMinutes;
  final Set<Prayer> activePrayers;

  const AutoDndConfig({
    this.enabled = false,
    this.minutesBeforeAdzan = 5,
    this.minutesAfterAdzan = 20,
    this.fridayDurationMinutes = 55,
    this.activePrayers = const {
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    },
  });

  AutoDndConfig copyWith({
    bool? enabled,
    int? minutesBeforeAdzan,
    int? minutesAfterAdzan,
    int? fridayDurationMinutes,
    Set<Prayer>? activePrayers,
  }) =>
      AutoDndConfig(
        enabled: enabled ?? this.enabled,
        minutesBeforeAdzan: (minutesBeforeAdzan ?? this.minutesBeforeAdzan).clamp(0, 30),
        minutesAfterAdzan: (minutesAfterAdzan ?? this.minutesAfterAdzan).clamp(5, 90),
        fridayDurationMinutes: (fridayDurationMinutes ?? this.fridayDurationMinutes).clamp(20, 120),
        activePrayers: activePrayers ?? this.activePrayers,
      );

  Map<String, Object> toJson() => {
        'enabled': enabled,
        'minutesBeforeAdzan': minutesBeforeAdzan,
        'minutesAfterAdzan': minutesAfterAdzan,
        'fridayDurationMinutes': fridayDurationMinutes,
        'activePrayers': [for (final p in activePrayers) p.name],
      };

  factory AutoDndConfig.fromJson(Map<String, dynamic> j) {
    final rawList = j['activePrayers'];
    final set = <Prayer>{};
    if (rawList is List) {
      for (final name in rawList) {
        final match = Prayer.values.where((p) => p.name == name).firstOrNull;
        if (match != null) set.add(match);
      }
    }
    return AutoDndConfig(
      enabled: j['enabled'] as bool? ?? false,
      minutesBeforeAdzan: ((j['minutesBeforeAdzan'] as num?)?.toInt() ?? 5).clamp(0, 30),
      minutesAfterAdzan: ((j['minutesAfterAdzan'] as num?)?.toInt() ?? 20).clamp(5, 90),
      fridayDurationMinutes: ((j['fridayDurationMinutes'] as num?)?.toInt() ?? 55).clamp(20, 120),
      activePrayers: set.isEmpty ? Prayer.values.toSet() : set,
    );
  }
}

class AutoDndWindow {
  final Prayer prayer;
  final String label;
  final String? labelEn;
  final DateTime start;
  final DateTime end;

  const AutoDndWindow({
    required this.prayer,
    required this.label,
    this.labelEn,
    required this.start,
    required this.end,
  });

  String labelFor(AppLanguage lang) =>
      lang == AppLanguage.en && (labelEn?.isNotEmpty ?? false) ? labelEn! : label;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}

List<AutoDndWindow> buildDailyDndWindows(
  AutoDndConfig config,
  PrayerTimes times, {
  AppLanguage lang = AppLanguage.id,
}) {
  final isFriday = times.fajr.weekday == DateTime.friday;
  final out = <AutoDndWindow>[];
  for (final p in Prayer.values) {
    if (!config.activePrayers.contains(p)) continue;
    final adzanTime = times.timeOf(p);
    final before = Duration(minutes: config.minutesBeforeAdzan);
    final after = Duration(
      minutes: (isFriday && p == Prayer.dhuhr) ? config.fridayDurationMinutes : config.minutesAfterAdzan,
    );
    final labelId = (isFriday && p == Prayer.dhuhr) ? 'Salat Jumat' : 'Salat ${p.label}';
    final labelEn = (isFriday && p == Prayer.dhuhr) ? 'Friday Prayer (Jumu\'ah)' : '${p.labelEn} Prayer';
    out.add(
      AutoDndWindow(
        prayer: p,
        label: tr(lang, labelId, labelEn),
        labelEn: labelEn,
        start: adzanTime.subtract(before),
        end: adzanTime.add(after),
      ),
    );
  }
  return out;
}

class AutoDndRepository {
  static const _key = 'auto_dnd_config';
  final KeyValueStore _store;

  const AutoDndRepository(this._store);

  Future<AutoDndConfig> load() async {
    final raw = await _store.readJson(_key);
    if (raw is! Map) return const AutoDndConfig();
    return AutoDndConfig.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<AutoDndConfig> save(AutoDndConfig config) async {
    await _store.writeJson(_key, config.toJson());
    return config;
  }
}
