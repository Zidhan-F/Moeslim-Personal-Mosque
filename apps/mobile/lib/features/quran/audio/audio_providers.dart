import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_core/personal_core.dart';

import '../../../core/l10n.dart';
import '../../../core/providers.dart';
import '../../masjid/session.dart';
import 'audio_engine.dart';
import 'offline_audio.dart';

/// URL katalog audio jarak jauh (opsional): `--dart-define=AUDIO_MANIFEST_URL=https://cdn…/manifest.json`.
const audioManifestUrl = String.fromEnvironment('AUDIO_MANIFEST_URL');

/// Katalog rekaman: aset bawaan → cache lokal → pembaruan dari CDN (bila dikonfigurasi & online).
final audioManifestProvider = FutureProvider<AudioManifest>((ref) async {
  final store = ref.watch(storeProvider);
  AudioManifest best = AudioManifest.empty;
  try {
    best = AudioManifest.fromJson(
      jsonDecode(await rootBundle.loadString('assets/audio/manifest.json')) as Map<String, dynamic>,
    );
  } catch (_) {}
  final cached = await store.readJson('audio.manifest');
  if (cached is Map) {
    final m = AudioManifest.fromJson(Map<String, dynamic>.from(cached));
    if (m.version >= best.version) best = m;
  }
  if (audioManifestUrl.isNotEmpty) {
    try {
      final res = await ref
          .read(httpClientProvider)
          .get(Uri.parse(audioManifestUrl))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final m = AudioManifest.fromJson(json);
        if (m.version >= best.version) {
          best = m;
          await store.writeJson('audio.manifest', json);
        }
      }
    } catch (_) {
      // offline: pakai katalog terakhir
    }
  }
  return best;
});

final audioEngineProvider = Provider<AudioEngine>((ref) {
  final e = JustAudioEngine();
  ref.onDispose(e.dispose);
  return e;
});

final offlineAudioProvider = Provider<OfflineAudioStore>((ref) => FileOfflineAudioStore(ref.watch(httpClientProvider)));

final audioPrefsProvider = Provider((ref) => AudioPreferenceRepository(ref.watch(storeProvider)));

class PlayerState {
  final int? surah;
  final Recitation? recitation;
  final List<AudioTrack> queue;
  final int? index;
  final bool playing;
  final bool completed;
  final bool repeatAyah;
  final String? error;
  final double speed;
  final Duration position;
  final Duration? duration;

  const PlayerState({
    this.surah,
    this.recitation,
    this.queue = const [],
    this.index,
    this.playing = false,
    this.completed = false,
    this.repeatAyah = false,
    this.error,
    this.speed = 1,
    this.position = Duration.zero,
    this.duration,
  });

  AudioTrack? get current => index != null && index! >= 0 && index! < queue.length ? queue[index!] : null;

  PlayerState copyWith({
    int? surah,
    Recitation? recitation,
    List<AudioTrack>? queue,
    int? index,
    bool clearIndex = false,
    bool? playing,
    bool? completed,
    bool? repeatAyah,
    String? error,
    bool clearError = false,
    double? speed,
    Duration? position,
    Duration? duration,
  }) => PlayerState(
    surah: surah ?? this.surah,
    recitation: recitation ?? this.recitation,
    queue: queue ?? this.queue,
    index: clearIndex ? null : (index ?? this.index),
    playing: playing ?? this.playing,
    completed: completed ?? this.completed,
    repeatAyah: repeatAyah ?? this.repeatAyah,
    error: clearError ? null : (error ?? this.error),
    speed: speed ?? this.speed,
    position: position ?? this.position,
    duration: duration ?? this.duration,
  );
}

/// Pemutar murottal per surah / per ayat dengan pilihan qari.
class QuranPlayer extends Notifier<PlayerState> {
  final _subs = <StreamSubscription>[];
  int _playGen = 0;

  AudioEngine get _engine => ref.read(audioEngineProvider);

  String _playbackError() => tr(
    ref.read(appLanguageProvider),
    'Gagal memutar audio. Periksa koneksi atau unduh untuk offline.',
    'Failed to play audio. Check your connection or download for offline use.',
  );

  @override
  PlayerState build() {
    final engine = ref.watch(audioEngineProvider);
    _subs
      ..add(engine.currentIndex.listen((i) => state = state.copyWith(index: i)))
      ..add(engine.playing.listen((p) => state = state.copyWith(playing: p, completed: p ? false : state.completed)))
      ..add(
        engine.completed.listen((done) {
          if (done) {
            state = state.copyWith(completed: true, playing: false);
          } else if (state.completed) {
            state = state.copyWith(completed: false);
          }
        }),
      )
      ..add(
        engine.errors.listen(
          (_) => state = state.copyWith(
            playing: false,
            error: _playbackError(),
          ),
        ),
      )
      ..add(engine.position.listen((p) => state = state.copyWith(position: p)))
      ..add(engine.duration.listen((d) => state = state.copyWith(duration: d)));
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();
    });
    return const PlayerState();
  }

  /// Siapkan qari untuk surah: pakai preferensi terakhir bila tersedia, jika tidak qari pertama.
  Future<void> prepare(int surah) async {
    final switchingSurah = state.surah != null && state.surah != surah;
    if (switchingSurah) {
      await _engine.stop();
    } else if (state.surah == surah && state.recitation != null && state.queue.isNotEmpty) {
      return;
    }
    final manifest = await ref.read(audioManifestProvider.future);
    final options = manifest.recitationsFor(surah);
    final prefRec = await ref.read(audioPrefsProvider).recitationId();
    final rec = options.where((r) => r.id == prefRec).firstOrNull ?? options.firstOrNull;
    state = PlayerState(surah: surah, recitation: rec, repeatAyah: state.repeatAyah, speed: state.speed);
  }

  /// Pilih qari; bila sedang memutar, lanjutkan dari ayat yang sama.
  Future<void> selectRecitation(String id) async {
    final surah = state.surah;
    if (surah == null) return;
    final manifest = await ref.read(audioManifestProvider.future);
    final rec = manifest.recitationsFor(surah).where((r) => r.id == id).firstOrNull;
    if (rec == null) return;
    final wasPlaying = state.playing;
    final resumeAyah = state.current?.ayah;
    await ref.read(audioPrefsProvider).save(recitationId: rec.id);
    if (wasPlaying && resumeAyah != null) {
      state = state.copyWith(recitation: rec, clearError: true);
      await playFrom(resumeAyah);
    } else {
      await _engine.stop();
      state = state.copyWith(
        recitation: rec,
        queue: const [],
        clearIndex: true,
        playing: false,
        completed: false,
        clearError: true,
      );
    }
  }

  /// Putar surah mulai ayat [ayah] sampai akhir surah.
  Future<void> playFrom(int ayah) => _play(fromAyah: ayah);

  /// Putar satu ayat saja.
  Future<void> playAyah(int ayah) => _play(fromAyah: ayah, toAyah: ayah);

  /// Putar berurutan mulai dari [ayah] hingga akhir surah; jika ayat ini sedang diputar, jeda/lanjutkan.
  Future<void> playOrToggleFromAyah(int ayah) async {
    final surah = state.surah;
    final rec = state.recitation;
    if (surah == null || rec == null) return;
    if (state.current?.ayah == ayah && state.playing) {
      await _engine.pause();
      return;
    }
    final isSameContinuousQueue =
        state.current?.ayah == ayah &&
        !state.completed &&
        state.queue.isNotEmpty &&
        state.queue.first.surah == surah &&
        state.queue.first.recitation.id == rec.id &&
        state.queue.last.ayah == surahs[surah - 1].ayahCount;
    if (isSameContinuousQueue) {
      await _engine.resume();
      return;
    }
    await playFrom(ayah);
  }

  /// Putar seluruh surah berurutan atau jeda/lanjutkan antrean surah yang sedang aktif.
  Future<void> toggleSurahPlayback([int? targetSurah]) async {
    if (targetSurah != null && state.surah != targetSurah) {
      await prepare(targetSurah);
    }
    final surah = state.surah;
    final rec = state.recitation;
    if (surah == null || rec == null) return;
    if (state.playing) {
      await _engine.pause();
      return;
    }
    final expectedLast = surahs[surah - 1].ayahCount;
    final hasContinuousSurahQueue =
        state.queue.isNotEmpty &&
        state.queue.first.surah == surah &&
        state.queue.first.recitation.id == rec.id &&
        state.queue.last.ayah == expectedLast;
    if (hasContinuousSurahQueue && !state.completed) {
      await _engine.resume();
    } else {
      await playFrom(1);
    }
  }

  Future<void> _play({required int fromAyah, int? toAyah}) async {
    final rec = state.recitation, surah = state.surah;
    if (rec == null || surah == null) return;
    final gen = ++_playGen;
    try {
      final tracks = rec.playlist(surah, fromAyah: fromAyah, toAyah: toAyah);
      final offline = ref.read(offlineAudioProvider);
      final uris = [for (final t in tracks) await offline.localUri(t) ?? Uri.parse(t.url)];
      if (gen != _playGen) return;
      state = state.copyWith(queue: tracks, index: 0, completed: false, clearError: true);
      await _engine.setRepeatOne(state.repeatAyah);
      await _engine.playAll(uris);
    } catch (_) {
      if (gen != _playGen) return;
      state = state.copyWith(
        playing: false,
        error: _playbackError(),
      );
    }
  }

  /// Lompat ke ayat sebelumnya/berikutnya (delta -1/+1) dalam surah aktif.
  Future<void> skip(int delta) async {
    final surah = state.surah;
    if (surah == null || state.recitation == null) return;
    final current = state.current?.ayah ?? 1;
    final target = (current + delta).clamp(1, surahs[surah - 1].ayahCount);
    await playFrom(target);
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _engine.setSpeed(speed);
  }

  Future<void> togglePause() => toggleSurahPlayback();

  Future<void> stop() async {
    await _engine.stop();
    state = state.copyWith(playing: false, completed: false);
  }

  Future<void> toggleRepeat() async {
    state = state.copyWith(repeatAyah: !state.repeatAyah);
    await _engine.setRepeatOne(state.repeatAyah);
  }
}

final quranPlayerProvider = NotifierProvider<QuranPlayer, PlayerState>(QuranPlayer.new);
