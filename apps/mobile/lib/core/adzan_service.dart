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

  Map<String, Object> toMap() => {
        'id': prayer.index + 100,
        'prayer': prayer.name,
        'prayerLabel': prayer.label,
        'isFajr': prayer == Prayer.fajr,
        'localTime': '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}',
        'triggerAtMs': triggerUtc.millisecondsSinceEpoch,
        'muadzinId': muadzinId,
        'locationName': locationName,
      };
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
  Future<void> syncAlarms(List<ScheduledAdzanAlarm> alarms, PersonalSettings settings);
  Future<void> playAdzan(AdzanMuadzin muadzin, {Prayer? prayer});
  Future<void> stopAdzan();
  Future<void> dispose();
}

class PlatformAdzanAlarmBackend implements AdzanAlarmBackend {
  static const _channel = MethodChannel('id.moeslim.moeslim_mobile/adzan_alarm');
  AudioPlayer? _player;

  @override
  Future<void> syncAlarms(List<ScheduledAdzanAlarm> alarms, PersonalSettings settings) async {
    try {
      if (alarms.isEmpty || !settings.notificationsEnabled) {
        await _channel.invokeMethod<void>('cancelAllAlarms');
      } else {
        await _channel.invokeMethod<void>('scheduleAlarms', {
          'alarms': [for (final a in alarms) a.toMap()],
          'muadzinId': settings.muadzin.id,
          'muadzinName': settings.muadzin.name,
          'assetPath': settings.muadzin.assetPath,
        });
      }
    } catch (_) {
      // Abaikan bila dijalankan di lingkungan uji atau platform non-Android.
    }
  }

  @override
  Future<void> playAdzan(AdzanMuadzin muadzin, {Prayer? prayer}) async {
    var handledByNative = false;
    try {
      final res = await _channel.invokeMethod<bool>('playAdzan', {
        'muadzinId': muadzin.id,
        'muadzinName': muadzin.name,
        'assetPath': muadzin.assetPath,
        'prayerLabel': prayer?.label,
        'isFajr': prayer == Prayer.fajr,
      });
      handledByNative = res == true;
    } catch (_) {}

    if (!handledByNative) {
      try {
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setAsset(muadzin.assetPath);
        await player.play();
      } catch (_) {}
    }
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
  Future<void> dispose() async {
    try {
      await _player?.dispose();
    } catch (_) {}
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

  const AdzanAlarmState({
    this.scheduledAlarms = const [],
    this.ringingPrayer,
    this.previewingMuadzinId,
    this.lastTriggeredSlotKey,
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
  }) =>
      AdzanAlarmState(
        scheduledAlarms: scheduledAlarms ?? this.scheduledAlarms,
        ringingPrayer: clearRinging ? null : (ringingPrayer ?? this.ringingPrayer),
        previewingMuadzinId: clearPreview ? null : (previewingMuadzinId ?? this.previewingMuadzinId),
        lastTriggeredSlotKey: lastTriggeredSlotKey ?? this.lastTriggeredSlotKey,
      );
}

class AdzanController extends Notifier<AdzanAlarmState> {
  String? _lastSyncSignature;
  DateTime? _previousLocalMinute;

  AdzanAlarmBackend get _backend => ref.read(adzanBackendProvider);

  @override
  AdzanAlarmState build() {
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

  Future<void> _syncScheduleIfNeeded(PersonalSettings s, List<ScheduledAdzanAlarm> upcoming) async {
    final sig = [
      s.notificationsEnabled,
      s.muadzin.id,
      s.effectiveLocationName,
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
            lastTriggeredSlotKey: slotKey,
          );
          await _backend.playAdzan(s.muadzin, prayer: p);
        }
        break;
      }
    }
  }

  /// Putar atau hentikan pratinjau suara muadzin pilihan.
  Future<void> togglePreviewMuadzin(AdzanMuadzin muadzin) async {
    if (state.previewingMuadzinId == muadzin.id) {
      await stopAdzan();
      return;
    }
    state = state.copyWith(
      previewingMuadzinId: muadzin.id,
      clearRinging: true,
    );
    await _backend.playAdzan(muadzin);
  }

  /// Picu alarm adzan untuk waktu salat [prayer] (untuk simulasi/uji alarm maupun saat waktu tiba).
  Future<void> triggerAlarm(Prayer prayer) async {
    final s = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
    state = state.copyWith(
      ringingPrayer: prayer,
      clearPreview: true,
    );
    await _backend.playAdzan(s.muadzin, prayer: prayer);
  }

  /// Hentikan suara adzan yang sedang berkumandang (alarm maupun pratinjau).
  Future<void> stopAdzan() async {
    state = state.copyWith(clearRinging: true, clearPreview: true);
    await _backend.stopAdzan();
  }
}

final adzanControllerProvider = NotifierProvider<AdzanController, AdzanAlarmState>(AdzanController.new);
