import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:moeslim_mobile/app.dart';
import 'package:moeslim_mobile/core/adzan_service.dart';
import 'package:moeslim_mobile/core/location_service.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';

import 'package:moeslim_mobile/features/quran/audio/audio_engine.dart';
import 'package:moeslim_mobile/features/quran/audio/audio_providers.dart';
import 'package:moeslim_mobile/features/quran/audio/offline_audio.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

List<DailyDua>? _cachedDailyDuas;

List<DailyDua> _defaultDailyDuas() =>
    _cachedDailyDuas ??= parseDailyDuasJson(File('assets/doa/daily_duas.json').readAsStringSync());

class FakeQuranSource implements QuranTextSource {
  final Map<int, List<Ayah>> data;
  FakeQuranSource([this.data = const {}]);

  @override
  Future<List<Ayah>?> load(int surah) async => data[surah];
}

class FakeAudioEngine implements AudioEngine {
  final calls = <List<Uri>>[];
  bool repeat = false;
  final _index = StreamController<int?>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _completed = StreamController<bool>.broadcast();
  final _errors = StreamController<String>.broadcast();

  @override
  Stream<int?> get currentIndex => _index.stream;
  @override
  Stream<bool> get playing => _playing.stream;
  @override
  Stream<bool> get completed => _completed.stream;
  @override
  Stream<String> get errors => _errors.stream;

  void emitCompleted() {
    _playing.add(false);
    _completed.add(true);
  }

  void emitError(String message) => _errors.add(message);

  double speed = 1;
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration?>.broadcast();

  @override
  Stream<Duration> get position => _position.stream;
  @override
  Stream<Duration?> get duration => _duration.stream;
  @override
  Future<void> setSpeed(double s) async => speed = s;
  @override
  Future<void> seek(Duration p, {int? index}) async {
    if (index != null) _index.add(index);
    _position.add(p);
  }

  @override
  Future<void> playAll(List<Uri> uris, {int startIndex = 0}) async {
    calls.add(uris);
    _completed.add(false);
    _index.add(startIndex);
    _playing.add(true);
  }

  @override
  Future<void> pause() async => _playing.add(false);
  @override
  Future<void> resume() async => _playing.add(true);
  @override
  Future<void> stop() async => _playing.add(false);
  @override
  Future<void> setRepeatOne(bool r) async => repeat = r;
  @override
  Future<void> dispose() async {}
}

class FakeOfflineAudio implements OfflineAudioStore {
  final Set<String> downloaded; // nama berkas, mis. 001001.mp3
  FakeOfflineAudio([Set<String>? d]) : downloaded = d ?? {};

  @override
  Future<Uri?> localUri(AudioTrack t) async =>
      downloaded.contains(t.fileName) ? Uri.file('/local/${t.fileName}') : null;
  @override
  Future<bool> isSurahDownloaded(Recitation r, int surah) async =>
      r.playlist(surah).every((t) => downloaded.contains(t.fileName));
  @override
  Future<void> downloadSurah(Recitation r, int surah, {void Function(int, int)? onProgress}) async {
    downloaded.addAll(r.playlist(surah).map((t) => t.fileName));
  }

  @override
  Future<void> deleteSurah(Recitation r, int surah) async {}
}

/// 1 Jan 2025 05:00 UTC = 12:00 WIB (Jakarta).
final fixedNow = DateTime.utc(2025, 1, 1, 5, 0, 0);

final defaultJakartaGps = GpsPosition(
  latitude: -6.1754,
  longitude: 106.8272,
  altitude: 10.0,
  accuracyMeters: 6.0,
  timestamp: DateTime.utc(2025, 1, 1, 5, 0, 0),
);

class FakeLocationService implements LocationService {
  bool serviceEnabled;
  LocationPermissionState permission;
  LocationPermissionState requestResult;
  GpsPosition? currentPosition;
  Object? positionError;
  int openLocationSettingsCalls = 0;
  int openAppSettingsCalls = 0;
  int requestPermissionCalls = 0;

  final serviceController = StreamController<bool>.broadcast();
  final positionController = StreamController<GpsPosition>.broadcast();

  FakeLocationService({
    this.serviceEnabled = true,
    this.permission = LocationPermissionState.granted,
    LocationPermissionState? requestResult,
    GpsPosition? currentPosition,
    bool holdPosition = false,
    this.positionError,
  })  : requestResult = requestResult ?? permission,
        currentPosition = holdPosition ? null : (currentPosition ?? defaultJakartaGps);

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Stream<bool> serviceStatusStream() => serviceController.stream;

  @override
  Future<LocationPermissionState> checkPermission() async => permission;

  @override
  Future<LocationPermissionState> requestPermission() async {
    requestPermissionCalls++;
    permission = requestResult;
    return permission;
  }

  @override
  Future<GpsPosition> getCurrentPosition() async {
    if (positionError != null) throw positionError!;
    if (currentPosition != null) return currentPosition!;
    return positionController.stream.first;
  }

  @override
  Stream<GpsPosition> positionStream() => positionController.stream;

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }

  void dispose() {
    serviceController.close();
    positionController.close();
  }
}

class FakeDeclinationService implements DeclinationService {
  final double declinationDegrees;
  const FakeDeclinationService([this.declinationDegrees = 0.0]);

  @override
  Future<double> getDeclination(GpsPosition position) async => declinationDegrees;
}

class FakeAdzanAlarmBackend implements AdzanAlarmBackend {
  final _completed = StreamController<void>.broadcast();
  List<ScheduledAdzanAlarm> syncedAlarms = const [];
  final List<AdzanMuadzin> playedMuadzins = [];
  final List<Prayer?> playedPrayers = [];
  int stopCalls = 0;

  @override
  Stream<void> get onCompleted => _completed.stream;

  void completePlayback() {
    if (!_completed.isClosed) _completed.add(null);
  }

  @override
  Future<void> syncAlarms(List<ScheduledAdzanAlarm> alarms, PersonalSettings settings) async {
    syncedAlarms = List.unmodifiable(alarms);
  }

  @override
  Future<void> playAdzan(AdzanMuadzin muadzin, {Prayer? prayer}) async {
    playedMuadzins.add(muadzin);
    playedPrayers.add(prayer);
  }

  @override
  Future<void> stopAdzan() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    await _completed.close();
  }
}

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  KeyValueStore? store,
  DateTime? now,
  http.Client? client,
  TokenStore? tokens,
  QuranTextSource? quran,
  List<DailyDua>? dailyDuas,
  AudioManifest? manifest,
  AudioEngine? engine,
  OfflineAudioStore? offline,
  LocationService? locationService,
  DeclinationService? declinationService,
  AdzanAlarmBackend? adzanBackend,
  bool showOnboarding = false,
}) async {
  store ??= InMemoryStore();
  if (!showOnboarding) {
    final repo = SettingsRepository(store);
    await repo.save((await repo.load()).copyWith(onboardingDone: true));
  }
  final ownLocation = locationService == null ? FakeLocationService() : null;
  if (ownLocation != null) addTearDown(ownLocation.dispose);
  final container = ProviderContainer(
    overrides: [
      storeProvider.overrideWithValue(store),
      nowProvider.overrideWith((ref) => Stream.value(now ?? fixedNow)),
      headingProvider.overrideWith((ref) => Stream.value(null)),
      compassProvider.overrideWith((ref) => Stream.value(null)),
      locationServiceProvider.overrideWithValue(locationService ?? ownLocation!),
      declinationServiceProvider.overrideWithValue(declinationService ?? const FakeDeclinationService()),
      adzanBackendProvider.overrideWithValue(adzanBackend ?? FakeAdzanAlarmBackend()),
      quranSourceProvider.overrideWithValue(quran ?? FakeQuranSource()),
      dailyDuasProvider.overrideWith((ref) async => dailyDuas ?? _defaultDailyDuas()),
      audioManifestProvider.overrideWith((ref) async => manifest ?? AudioManifest.empty),
      audioEngineProvider.overrideWithValue(engine ?? FakeAudioEngine()),
      offlineAudioProvider.overrideWithValue(offline ?? FakeOfflineAudio()),
      if (client != null) httpClientProvider.overrideWithValue(client),
      tokenStoreProvider.overrideWithValue(tokens ?? MemoryTokenStore()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MoeslimApp()));
  await tester.pump();
  await tester.pump();
  return container;
}

/// Buka lembar audio (pilih qari) dari bar pemutar mushaf.
Future<void> openAudioSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('audio-picker')));
  await tester.pumpAndSettle();
}
