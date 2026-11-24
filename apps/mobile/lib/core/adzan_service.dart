import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'format.dart';
import 'providers.dart';

/// Satu jadwal alarm adzan yang akan datang untuk waktu salat tertentu.
class ScheduledAdzanAlarm {
  final Prayer prayer;
  final DateTime localTime;
  final DateTime triggerUtc;
  final String muadzinId;
  final String locationName;

  const ScheduledAdzanAlarm({
    required this.prayer,
    required this.localTime,
    required this.triggerUtc,
    required this.muadzinId,
    required this.locationName,
  });

  Map<String, Object> toMap({AppLanguage lang = AppLanguage.id}) => {
        'id': prayer.index + 100,
        'prayer': prayer.name,
        'prayerLabel': prayer.labelFor(lang),
        'isFajr': prayer == Prayer.fajr,
        'localTime': '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}',
        'triggerAtMs': triggerUtc.millisecondsSinceEpoch,
        'muadzinId': muadzinId,
        'locationName': locationName,
        'language': lang.code,
      };
}

/// Status izin notifikasi alarm adzan pada perangkat.
class AdzanNotificationStatus {
  final bool granted;
  final bool fullScreenAllowed;

  const AdzanNotificationStatus({this.granted = true, this.fullScreenAllowed = true});

  factory AdzanNotificationStatus.fromMap(Map<Object?, Object?>? m) {
    if (m == null) return const AdzanNotificationStatus();
    return AdzanNotificationStatus(
      granted: m['granted'] as bool? ?? true,
      fullScreenAllowed: m['fullScreenAllowed'] as bool? ?? true,
    );
  }
}

/// Konversi waktu jam dinding lokal (sesuai [utcOffsetHours]) menjadi waktu absolut UTC.
DateTime localWallClockToUtc(DateTime localWallClock, double utcOffsetHours) {
  final offsetMinutes = (utcOffsetHours * 60).round();
  final asUtc = DateTime.utc(
    localWallClock.year,
    localWallClock.month,
    localWallClock.day,
    localWallClock.hour,
    localWallClock.minute,
    localWallClock.second,
  );
  return asUtc.subtract(Duration(minutes: offsetMinutes));
}

/// Hitung daftar alarm adzan aktif berikutnya (hari ini & besok) berdasarkan pengaturan lokasi setempat.
List<ScheduledAdzanAlarm> computeUpcomingAdzanAlarms(PersonalSettings settings, DateTime deviceNow) {
  if (!settings.notificationsEnabled) return const [];
  final localNow = wallClock(deviceNow, settings.effectiveUtcOffset);
  final todayDate = DateTime(localNow.year, localNow.month, localNow.day);
  final tomorrowDate = todayDate.add(const Duration(days: 1));
  final todayTimes = settings.timesFor(todayDate);
  final tomorrowTimes = settings.timesFor(tomorrowDate);

  final alarms = <ScheduledAdzanAlarm>[];
  for (final p in Prayer.values) {
    if (!settings.isAdzanActiveFor(p)) continue;
    var targetLocal = todayTimes.timeOf(p);
    if (!targetLocal.isAfter(localNow)) {
      targetLocal = tomorrowTimes.timeOf(p);
    }
    alarms.add(
      ScheduledAdzanAlarm(
        prayer: p,
        localTime: targetLocal,
        triggerUtc: localWallClockToUtc(targetLocal, settings.effectiveUtcOffset),
        muadzinId: settings.muadzin.id,
        locationName: settings.effectiveLocationName,
      ),
    );
  }
  alarms.sort((a, b) => a.triggerUtc.compareTo(b.triggerUtc));
  return alarms;
}

/// Abstraksi penjadwal alarm & pemutar suara adzan agar mudah diuji dan terhubung ke Android native.
abstract class AdzanAlarmBackend {
  Stream<void> get onCompleted;
  Stream<Prayer?> get onNativeAlarmChanged;
  Future<void> syncAlarms(List<ScheduledAdzanAlarm> alarms, PersonalSettings settings);
  Future<void> playAdzan(
    AdzanMuadzin muadzin, {
    Prayer? prayer,
    String? localTime,
    String? locationName,
    AppThemeMode themeMode = AppThemeMode.light,
    AppLanguage language = AppLanguage.id,
    double volume = 0.85,
    bool overrideDeviceVolume = true,
  });
  Future<void> setVolume(double volume, {bool overrideDeviceVolume = true});
  Future<void> stopAdzan();
  Future<Prayer?> getActiveNativeAlarm();
  Future<AdzanNotificationStatus> checkNotificationStatus();
  Future<AdzanNotificationStatus> requestNotificationPermission();
  Future<void> openNotificationSettings();
  Future<void> dispose();
}

Prayer? _prayerFromName(String? name) {
  if (name == null) return null;
  for (final p in Prayer.values) {
    if (p.name == name) return p;
  }
  return null;
}

class PlatformAdzanAlarmBackend implements AdzanAlarmBackend {
  static const _channel = MethodChannel('id.moeslim.moeslim_mobile/adzan_alarm');
  final _completed = StreamController<void>.broadcast();
  final _nativeAlarm = StreamController<Prayer?>.broadcast();
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerSub;

  PlatformAdzanAlarmBackend() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPlaybackCompleted' && !_completed.isClosed) {
        _completed.add(null);
      } else if (call.method == 'onAlarmStateChanged' && !_nativeAlarm.isClosed) {
        final args = call.arguments as Map?;
        _nativeAlarm.add(_prayerFromName(args?['prayer'] as String?));
      }
    });
  }

  @override
  Stream<void> get onCompleted => _completed.stream;

  @override
  Stream<Prayer?> get onNativeAlarmChanged => _nativeAlarm.stream;

  @override
  Future<void> syncAlarms(List<ScheduledAdzanAlarm> alarms, PersonalSettings settings) async {
    try {
      if (alarms.isEmpty || !settings.notificationsEnabled) {
        await _channel.invokeMethod<void>('cancelAllAlarms', {
          'themeMode': settings.themeMode.name,
          'language': settings.language.code,
          'adzanVolume': settings.adzanVolume,
          'overrideDeviceVolume': settings.adzanOverrideDeviceVolume,
        });
      } else {
        await _channel.invokeMethod<void>('scheduleAlarms', {
          'alarms': [for (final a in alarms) a.toMap(lang: settings.language)],
          'muadzinId': settings.muadzin.id,
          'muadzinName': settings.muadzin.name,
          'assetPath': settings.muadzin.assetPath,
          'themeMode': settings.themeMode.name,
          'language': settings.language.code,
          'adzanVolume': settings.adzanVolume,
          'overrideDeviceVolume': settings.adzanOverrideDeviceVolume,
        });
      }
    } catch (_) {
      // Abaikan bila dijalankan di lingkungan uji atau platform non-Android.
    }
  }

  @override
  Future<void> playAdzan(
    AdzanMuadzin muadzin, {
    Prayer? prayer,
    String? localTime,
    String? locationName,
    AppThemeMode themeMode = AppThemeMode.light,
    AppLanguage language = AppLanguage.id,
    double volume = 0.85,
    bool overrideDeviceVolume = true,
  }) async {
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    var handledByNative = false;
    try {
      final res = await _channel.invokeMethod<bool>('playAdzan', {
        'muadzinId': muadzin.id,
        'muadzinName': muadzin.name,
        'assetPath': muadzin.assetPath,
        'prayer': prayer?.name,
        'prayerLabel': prayer?.labelFor(language),
        'localTime': localTime ?? '',
        'locationName': locationName ?? '',
        'isFajr': prayer == Prayer.fajr,
        'isPreview': prayer == null,
        'themeMode': themeMode.name,
        'language': language.code,
        'adzanVolume': safeVolume,
        'overrideDeviceVolume': overrideDeviceVolume,
      });
      handledByNative = res == true;
    } catch (_) {}

    if (!handledByNative) {
      await _player?.stop();
      if (safeVolume <= 0.001) {
        if (prayer == null) {
          if (!_completed.isClosed) _completed.add(null);
        } else {
          Future<void>.delayed(const Duration(seconds: 20), () {
            if (!_completed.isClosed) _completed.add(null);
          });
        }
        return;
      }
      final player = _ensurePlayer();
      await player.setAsset(muadzin.assetPath);
      await player.setVolume(safeVolume);
      unawaited(player.play());
    }
  }

  @override
  Future<void> setVolume(double volume, {bool overrideDeviceVolume = true}) async {
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    try {
      await _channel.invokeMethod<void>('setAdzanVolume', {
        'adzanVolume': safeVolume,
        'overrideDeviceVolume': overrideDeviceVolume,
      });
    } catch (_) {}
    try {
      await _player?.setVolume(safeVolume);
    } catch (_) {}
  }

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;
    final created = AudioPlayer();
    _player = created;
    _playerSub = created.playerStateStream.listen((st) {
      if (st.processingState == ProcessingState.completed && !_completed.isClosed) {
        _completed.add(null);
      }
    });
    return created;
  }

  @override
  Future<void> stopAdzan() async {
    try {
      await _channel.invokeMethod<void>('stopAdzan');
    } catch (_) {}
    try {
      await _player?.stop();
    } catch (_) {}
  }

  @override
  Future<Prayer?> getActiveNativeAlarm() async {
    try {
      final res = await _channel.invokeMethod<Map<Object?, Object?>>('getActiveAlarm');
      return _prayerFromName(res?['prayer'] as String?);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AdzanNotificationStatus> checkNotificationStatus() async {
    try {
      final res = await _channel.invokeMethod<Map<Object?, Object?>>('checkNotificationStatus');
      return AdzanNotificationStatus.fromMap(res);
    } catch (_) {
      return const AdzanNotificationStatus();
    }
  }

  @override
  Future<AdzanNotificationStatus> requestNotificationPermission() async {
    try {
      final res = await _channel.invokeMethod<Map<Object?, Object?>>('requestNotificationPermission');
      return AdzanNotificationStatus.fromMap(res);
    } catch (_) {
      return const AdzanNotificationStatus();
    }
  }

  @override
  Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod<void>('openNotificationSettings');
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _playerSub?.cancel();
    try {
      await _player?.dispose();
    } catch (_) {}
    await _completed.close();
    await _nativeAlarm.close();
  }
}

final adzanBackendProvider = Provider<AdzanAlarmBackend>((ref) {
  final backend = PlatformAdzanAlarmBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

class AdzanAlarmState {
  final List<ScheduledAdzanAlarm> scheduledAlarms;
  final Prayer? ringingPrayer;
  final String? previewingMuadzinId;
  final String? lastTriggeredSlotKey;
  final String? lastError;
  final bool notificationsGranted;

  const AdzanAlarmState({
    this.scheduledAlarms = const [],
    this.ringingPrayer,
    this.previewingMuadzinId,
    this.lastTriggeredSlotKey,
    this.lastError,
    this.notificationsGranted = true,
  });

  bool get isRinging => ringingPrayer != null;
  bool get isPlaying => ringingPrayer != null || previewingMuadzinId != null;

  ScheduledAdzanAlarm? get nextScheduled => scheduledAlarms.firstOrNull;

  AdzanAlarmState copyWith({
    List<ScheduledAdzanAlarm>? scheduledAlarms,
    Prayer? ringingPrayer,
    bool clearRinging = false,
    String? previewingMuadzinId,
    bool clearPreview = false,
    String? lastTriggeredSlotKey,
    String? lastError,
    bool clearError = false,
    bool? notificationsGranted,
  }) =>
      AdzanAlarmState(
        scheduledAlarms: scheduledAlarms ?? this.scheduledAlarms,
        ringingPrayer: clearRinging ? null : (ringingPrayer ?? this.ringingPrayer),
        previewingMuadzinId: clearPreview ? null : (previewingMuadzinId ?? this.previewingMuadzinId),
        lastTriggeredSlotKey: lastTriggeredSlotKey ?? this.lastTriggeredSlotKey,
        lastError: clearError ? null : (lastError ?? this.lastError),
        notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      );
}

class AdzanController extends Notifier<AdzanAlarmState> {
  String? _lastSyncSignature;
  DateTime? _previousLocalMinute;
  bool _autoRequestedNotif = false;

  AdzanAlarmBackend get _backend => ref.read(adzanBackendProvider);

  @override
  AdzanAlarmState build() {
    final completedSub = _backend.onCompleted.listen((_) {
      if (state.isPlaying) {
        state = state.copyWith(clearRinging: true, clearPreview: true);
      }
    });
    final nativeSub = _backend.onNativeAlarmChanged.listen((prayer) {
      if (prayer == null) {
        if (state.isRinging) {
          state = state.copyWith(clearRinging: true);
        }
      } else {
        state = state.copyWith(ringingPrayer: prayer, clearPreview: true, clearError: true);
      }
    });
    ref.onDispose(() {
      completedSub.cancel();
      nativeSub.cancel();
    });

    ref.listen<AsyncValue<PersonalSettings>>(settingsProvider, (_, next) {
      final s = next.value;
      final now = ref.read(nowProvider).value;
      if (s != null && now != null) {
        unawaited(_onTickOrSettings(s, now));
      }
    });

    ref.listen<AsyncValue<DateTime>>(nowProvider, (_, next) {
      final s = ref.read(settingsProvider).value;
      final now = next.value;
      if (s != null && now != null) {
        unawaited(_onTickOrSettings(s, now));
      }
    });

    Future.microtask(() async {
      await syncActiveNativeAlarm();
      await refreshNotificationStatus(requestIfNeeded: true);
    });

    final initialSettings = ref.read(settingsProvider).value;
    final initialNow = ref.read(nowProvider).value;
    if (initialSettings != null && initialNow != null) {
      final upcoming = computeUpcomingAdzanAlarms(initialSettings, initialNow);
      final local = wallClock(initialNow, initialSettings.effectiveUtcOffset);
      _previousLocalMinute = DateTime(local.year, local.month, local.day, local.hour, local.minute);
      Future.microtask(() => _syncScheduleIfNeeded(initialSettings, upcoming));
      return AdzanAlarmState(scheduledAlarms: upcoming);
    }
    return const AdzanAlarmState();
  }

  Future<void> syncActiveNativeAlarm() async {
    final active = await _backend.getActiveNativeAlarm();
    if (active != null && state.ringingPrayer != active) {
      state = state.copyWith(ringingPrayer: active, clearPreview: true, clearError: true);
    } else if (active == null && state.ringingPrayer != null) {
      state = state.copyWith(clearRinging: true);
    }
  }

  Future<void> refreshNotificationStatus({bool requestIfNeeded = false}) async {
    var status = await _backend.checkNotificationStatus();
    final enabled = ref.read(settingsProvider).value?.notificationsEnabled ?? false;
    if (requestIfNeeded && enabled && !status.granted && !_autoRequestedNotif) {
      _autoRequestedNotif = true;
      status = await _backend.requestNotificationPermission();
    }
    if (state.notificationsGranted != status.granted) {
      state = state.copyWith(notificationsGranted: status.granted);
    }
  }

  Future<void> requestNotificationPermission() async {
    final status = await _backend.requestNotificationPermission();
    state = state.copyWith(notificationsGranted: status.granted);
  }

  Future<void> openNotificationSettings() => _backend.openNotificationSettings();

  Future<void> _syncScheduleIfNeeded(PersonalSettings s, List<ScheduledAdzanAlarm> upcoming) async {
    final sig = [
      s.notificationsEnabled,
      s.muadzin.id,
      s.effectiveLocationName,
      s.themeMode.name,
      s.language.code,
      s.adzanVolume.toStringAsFixed(2),
      s.adzanOverrideDeviceVolume,
      for (final a in upcoming) '${a.prayer.name}:${a.triggerUtc.millisecondsSinceEpoch}',
    ].join('|');
    if (sig == _lastSyncSignature) return;
    _lastSyncSignature = sig;
    await _backend.syncAlarms(upcoming, s);
  }

  Future<void> _onTickOrSettings(PersonalSettings s, DateTime deviceNow) async {
    final upcoming = computeUpcomingAdzanAlarms(s, deviceNow);
    state = state.copyWith(scheduledAlarms: upcoming);
    await _syncScheduleIfNeeded(s, upcoming);

    if (!s.notificationsEnabled && state.isRinging) {
      await stopAdzan();
      return;
    }

    final localNow = wallClock(deviceNow, s.effectiveUtcOffset);
    final currentMinute = DateTime(localNow.year, localNow.month, localNow.day, localNow.hour, localNow.minute);
    final minuteChanged = _previousLocalMinute != currentMinute;
    _previousLocalMinute = currentMinute;

    if (!minuteChanged || !s.notificationsEnabled) return;

    final todayTimes = s.timesFor(DateTime(localNow.year, localNow.month, localNow.day));
    for (final p in Prayer.values) {
      if (!s.isAdzanActiveFor(p)) continue;
      final pTime = todayTimes.timeOf(p);
      if (pTime.hour == localNow.hour && pTime.minute == localNow.minute) {
        final slotKey = '${localNow.year}-${localNow.month}-${localNow.day}-${p.name}';
        if (state.lastTriggeredSlotKey != slotKey) {
          state = state.copyWith(
            ringingPrayer: p,
            clearPreview: true,
            clearError: true,
            lastTriggeredSlotKey: slotKey,
          );
          try {
            await _backend.playAdzan(
              s.muadzin,
              prayer: p,
              localTime: hhmm(pTime),
              locationName: s.effectiveLocationName,
              themeMode: s.themeMode,
              language: s.language,
              volume: s.adzanVolume,
              overrideDeviceVolume: s.adzanOverrideDeviceVolume,
            );
          } catch (_) {
            state = state.copyWith(lastError: 'Gagal memutar suara adzan. Periksa volume perangkat.');
          }
        }
        break;
      }
    }
  }

  /// Putar atau hentikan pratinjau suara muadzin pilihan memakai volume adzan aplikasi.
  Future<void> togglePreviewMuadzin(AdzanMuadzin muadzin) async {
    if (state.previewingMuadzinId == muadzin.id) {
      await stopAdzan();
      return;
    }
    final s = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
    state = state.copyWith(
      previewingMuadzinId: muadzin.id,
      clearRinging: true,
      clearError: true,
    );
    try {
      await _backend.playAdzan(
        muadzin,
        themeMode: s.themeMode,
        language: s.language,
        volume: s.adzanVolume,
        overrideDeviceVolume: s.adzanOverrideDeviceVolume,
      );
    } catch (_) {
      state = state.copyWith(
        clearPreview: true,
        lastError: 'Suara adzan belum dapat diputar. Pastikan volume perangkat aktif.',
      );
    }
  }

  /// Perbarui volume adzan secara langsung saat audio adzan/pratinjau sedang diputar.
  Future<void> updateLiveVolume(double volume, {required bool overrideDeviceVolume}) async {
    await _backend.setVolume(volume, overrideDeviceVolume: overrideDeviceVolume);
  }

  /// Picu alarm adzan untuk waktu salat [prayer] beserta pop-up notifikasi & tombol matikan.
  Future<void> triggerAlarm(Prayer prayer) async {
    final s = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
    final now = ref.read(nowProvider).value ?? DateTime.now();
    final local = wallClock(now, s.effectiveUtcOffset);
    state = state.copyWith(
      ringingPrayer: prayer,
      clearPreview: true,
      clearError: true,
    );
    try {
      await _backend.playAdzan(
        s.muadzin,
        prayer: prayer,
        localTime: hhmm(local),
        locationName: s.effectiveLocationName,
        themeMode: s.themeMode,
        language: s.language,
        volume: s.adzanVolume,
        overrideDeviceVolume: s.adzanOverrideDeviceVolume,
      );
    } catch (_) {
      state = state.copyWith(lastError: 'Gagal memutar suara adzan. Periksa volume alarm perangkat.');
    }
  }

  /// Hentikan suara adzan yang sedang berkumandang (alarm maupun pratinjau).
  Future<void> stopAdzan() async {
    state = state.copyWith(clearRinging: true, clearPreview: true, clearError: true);
    await _backend.stopAdzan();
  }
}

final adzanControllerProvider = NotifierProvider<AdzanController, AdzanAlarmState>(AdzanController.new);
