import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:moeslim_mobile/app.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';

import 'dart:async';

import 'package:moeslim_mobile/features/quran/audio/audio_engine.dart';
import 'package:moeslim_mobile/features/quran/audio/audio_providers.dart';
import 'package:moeslim_mobile/features/quran/audio/offline_audio.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
import 'package:personal_core/personal_core.dart';

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

  @override
  Stream<int?> get currentIndex => _index.stream;
  @override
  Stream<bool> get playing => _playing.stream;

  @override
  Future<void> playAll(List<Uri> uris, {int startIndex = 0}) async {
    calls.add(uris);
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

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  KeyValueStore? store,
  DateTime? now,
  http.Client? client,
  TokenStore? tokens,
  QuranTextSource? quran,
  AudioManifest? manifest,
  AudioEngine? engine,
  OfflineAudioStore? offline,
  bool showOnboarding = false,
}) async {
  store ??= InMemoryStore();
  if (!showOnboarding) {
    final repo = SettingsRepository(store);
    await repo.save((await repo.load()).copyWith(onboardingDone: true));
  }
  final container = ProviderContainer(
    overrides: [
      storeProvider.overrideWithValue(store),
      nowProvider.overrideWith((ref) => Stream.value(now ?? fixedNow)),
      headingProvider.overrideWith((ref) => Stream.value(null)),
      quranSourceProvider.overrideWithValue(quran ?? FakeQuranSource()),
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
