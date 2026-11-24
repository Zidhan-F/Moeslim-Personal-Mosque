import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:personal_core/personal_core.dart';

/// Path aset MP3 offline untuk Asmaul Husna nomor 1..99.
String asmaulHusnaAssetPath(int number) =>
    'assets/audio/asmaul_husna/${number.clamp(1, 99).toString().padLeft(2, '0')}.mp3';

/// Semua 99 path aset MP3 Asmaul Husna berurutan (1..99).
final List<String> allAsmaulHusnaAssetPaths = List.unmodifiable([
  for (var i = 1; i <= asmaulHusnaCatalog.length; i++) asmaulHusnaAssetPath(i),
]);

enum AsmaulRepeatMode { off, one, all }

class AsmaulAudioState {
  final int? currentNumber;
  final bool playing;
  final bool playAllQueue;
  final AsmaulRepeatMode repeatMode;
  final double speed;
  final String? error;

  const AsmaulAudioState({
    this.currentNumber,
    this.playing = false,
    this.playAllQueue = false,
    this.repeatMode = AsmaulRepeatMode.off,
    this.speed = 1.0,
    this.error,
  });

  static const _unset = Object();

  AsmaulAudioState copyWith({
    Object? currentNumber = _unset,
    bool? playing,
    bool? playAllQueue,
    AsmaulRepeatMode? repeatMode,
    double? speed,
    Object? error = _unset,
  }) =>
      AsmaulAudioState(
        currentNumber: identical(currentNumber, _unset) ? this.currentNumber : currentNumber as int?,
        playing: playing ?? this.playing,
        playAllQueue: playAllQueue ?? this.playAllQueue,
        repeatMode: repeatMode ?? this.repeatMode,
        speed: speed ?? this.speed,
        error: identical(error, _unset) ? this.error : error as String?,
      );
}

/// Abstraksi mesin audio offline Asmaul Husna agar dapat diuji tanpa plugin native.
abstract class AsmaulAudioEngine {
  Stream<bool> get playingStream;
  Stream<int?> get currentIndexStream;
  Stream<void> get completedStream;

  Future<void> playAsset(String assetPath, {double speed = 1.0, bool loopOne = false});
  Future<void> playPlaylist(
    List<String> assetPaths, {
    int startIndex = 0,
    double speed = 1.0,
    AsmaulRepeatMode repeatMode = AsmaulRepeatMode.off,
  });
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seekToIndex(int index);
  Future<void> setSpeed(double speed);
  Future<void> setRepeatMode(AsmaulRepeatMode mode);
  Future<void> dispose();
}

class JustAudioAsmaulEngine implements AsmaulAudioEngine {
  final _player = AudioPlayer();
  late final StreamSubscription<ProcessingState> _completionSub;
  final _completed = StreamController<void>.broadcast();

  JustAudioAsmaulEngine() {
    _completionSub = _player.processingStateStream.listen((s) {
      if (s == ProcessingState.completed) {
        if (_player.playing) {
          unawaited(_player.pause().catchError((Object _) {}));
        }
        if (!_completed.isClosed) _completed.add(null);
      }
    });
  }

  LoopMode _loopMode(AsmaulRepeatMode mode) => switch (mode) {
        AsmaulRepeatMode.off => LoopMode.off,
        AsmaulRepeatMode.one => LoopMode.one,
        AsmaulRepeatMode.all => LoopMode.all,
      };

  @override
  Stream<bool> get playingStream => _player.playerStateStream
      .map((s) => s.playing && s.processingState != ProcessingState.completed)
      .distinct();

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Stream<void> get completedStream => _completed.stream;

  @override
  Future<void> playAsset(String assetPath, {double speed = 1.0, bool loopOne = false}) async {
    await _player.setAudioSource(AudioSource.asset(assetPath));
    await _player.setSpeed(speed);
    await _player.setLoopMode(loopOne ? LoopMode.one : LoopMode.off);
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> playPlaylist(
    List<String> assetPaths, {
    int startIndex = 0,
    double speed = 1.0,
    AsmaulRepeatMode repeatMode = AsmaulRepeatMode.off,
  }) async {
    await _player.setAudioSources(
      [for (final p in assetPaths) AudioSource.asset(p)],
      initialIndex: startIndex.clamp(0, assetPaths.length - 1),
      initialPosition: Duration.zero,
    );
    await _player.setSpeed(speed);
    await _player.setLoopMode(_loopMode(repeatMode));
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seekToIndex(int index) => _player.seek(Duration.zero, index: index);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AsmaulRepeatMode mode) => _player.setLoopMode(_loopMode(mode));

  @override
  Future<void> dispose() async {
    await _completionSub.cancel();
    await _completed.close();
    await _player.dispose();
  }
}

final asmaulAudioEngineProvider = Provider<AsmaulAudioEngine>((ref) {
  final engine = JustAudioAsmaulEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

class AsmaulAudioController extends Notifier<AsmaulAudioState> {
  static const speeds = [0.75, 1.0, 1.25];
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<void>? _completedSub;

  AsmaulAudioEngine get _engine => ref.read(asmaulAudioEngineProvider);

  @override
  AsmaulAudioState build() {
    final engine = ref.watch(asmaulAudioEngineProvider);
    _playingSub?.cancel();
    _indexSub?.cancel();
    _completedSub?.cancel();

    _playingSub = engine.playingStream.listen((p) {
      if (state.playing != p) state = state.copyWith(playing: p);
    });
    _indexSub = engine.currentIndexStream.listen((idx) {
      if (state.playAllQueue && idx != null && idx >= 0 && idx < asmaulHusnaCatalog.length) {
        final nextNum = idx + 1;
        if (state.currentNumber != nextNum) {
          state = state.copyWith(currentNumber: nextNum);
        }
      }
    });
    _completedSub = engine.completedStream.listen((_) {
      if (state.playing) state = state.copyWith(playing: false);
    });

    ref.onDispose(() {
      _playingSub?.cancel();
      _indexSub?.cancel();
      _completedSub?.cancel();
      unawaited(engine.stop().catchError((Object _) {}));
    });

    return const AsmaulAudioState();
  }

  Future<void> playSingle(int number) async {
    final clamped = number.clamp(1, asmaulHusnaCatalog.length);
    if (state.currentNumber == clamped && !state.playAllQueue) {
      if (state.playing) {
        await pause();
        return;
      }
      try {
        await _engine.playAsset(
          asmaulHusnaAssetPath(clamped),
          speed: state.speed,
          loopOne: state.repeatMode == AsmaulRepeatMode.one,
        );
        state = state.copyWith(playing: true, error: null);
      } catch (_) {
        state = state.copyWith(playing: false, error: 'Gagal memutar audio Asmaul Husna.');
      }
      return;
    }

    state = state.copyWith(currentNumber: clamped, playing: true, playAllQueue: false, error: null);
    try {
      await _engine.playAsset(
        asmaulHusnaAssetPath(clamped),
        speed: state.speed,
        loopOne: state.repeatMode == AsmaulRepeatMode.one,
      );
    } catch (_) {
      state = state.copyWith(playing: false, error: 'Gagal memutar audio Asmaul Husna.');
    }
  }

  Future<void> playAll({int startNumber = 1}) async {
    final start = startNumber.clamp(1, asmaulHusnaCatalog.length);
    state = state.copyWith(currentNumber: start, playing: true, playAllQueue: true, error: null);
    try {
      await _engine.playPlaylist(
        allAsmaulHusnaAssetPaths,
        startIndex: start - 1,
        speed: state.speed,
        repeatMode: state.repeatMode,
      );
    } catch (_) {
      state = state.copyWith(playing: false, error: 'Gagal memutar daftar audio Asmaul Husna.');
    }
  }

  Future<void> togglePlayPause() async {
    if (state.currentNumber == null) {
      await playAll(startNumber: 1);
      return;
    }
    if (state.playing) {
      await pause();
    } else {
      try {
        await _engine.resume();
        state = state.copyWith(playing: true, error: null);
      } catch (_) {
        if (state.playAllQueue) {
          await playAll(startNumber: state.currentNumber!);
        } else {
          await playSingle(state.currentNumber!);
        }
      }
    }
  }

  Future<void> pause() async {
    try {
      await _engine.pause();
    } finally {
      state = state.copyWith(playing: false);
    }
  }

  Future<void> next() async {
    final curr = state.currentNumber ?? 0;
    final nextNum = curr >= asmaulHusnaCatalog.length ? 1 : curr + 1;
    if (state.playAllQueue) {
      state = state.copyWith(currentNumber: nextNum, playing: true, error: null);
      await _engine.seekToIndex(nextNum - 1);
      await _engine.resume();
    } else {
      await playSingle(nextNum);
    }
  }

  Future<void> previous() async {
    final curr = state.currentNumber ?? 1;
    final prevNum = curr <= 1 ? asmaulHusnaCatalog.length : curr - 1;
    if (state.playAllQueue) {
      state = state.copyWith(currentNumber: prevNum, playing: true, error: null);
      await _engine.seekToIndex(prevNum - 1);
      await _engine.resume();
    } else {
      await playSingle(prevNum);
    }
  }

  Future<void> cycleRepeat() async {
    final next = switch (state.repeatMode) {
      AsmaulRepeatMode.off => AsmaulRepeatMode.one,
      AsmaulRepeatMode.one => AsmaulRepeatMode.all,
      AsmaulRepeatMode.all => AsmaulRepeatMode.off,
    };
    state = state.copyWith(repeatMode: next);
    await _engine.setRepeatMode(next);
  }

  Future<void> cycleSpeed() async {
    final idx = speeds.indexOf(state.speed);
    final next = speeds[(idx + 1) % speeds.length];
    state = state.copyWith(speed: next);
    await _engine.setSpeed(next);
  }

  Future<void> stop() async {
    try {
      await _engine.stop();
    } catch (_) {}
    state = state.copyWith(currentNumber: null, playing: false, playAllQueue: false, error: null);
  }
}

final asmaulAudioControllerProvider = NotifierProvider.autoDispose<AsmaulAudioController, AsmaulAudioState>(
  AsmaulAudioController.new,
);
