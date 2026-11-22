import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// Abstraksi pemutar agar logika dapat diuji tanpa plugin native.
abstract class AudioEngine {
  Stream<int?> get currentIndex;
  Stream<bool> get playing;
  Stream<bool> get completed;
  Stream<String> get errors;
  Stream<Duration> get position;
  Stream<Duration?> get duration;
  Future<void> setSpeed(double speed);
  Future<void> seek(Duration position, {int? index});
  Future<void> playAll(List<Uri> uris, {int startIndex = 0});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> setRepeatOne(bool repeat);
  Future<void> dispose();
}

class JustAudioEngine implements AudioEngine {
  final _player = AudioPlayer();
  late final StreamSubscription<ProcessingState> _completionSub;

  JustAudioEngine() {
    // Di just_audio, status `playing` tetap true saat ProcessingState.completed;
    // jeda otomatis saat daftar putar selesai agar UI dan putar ulang tetap sinkron.
    _completionSub = _player.processingStateStream.listen((s) {
      if (s == ProcessingState.completed && _player.playing) {
        unawaited(_player.pause().catchError((Object _) {}));
      }
    });
  }

  @override
  Stream<int?> get currentIndex => _player.currentIndexStream;

  @override
  Stream<bool> get playing => _player.playerStateStream
      .map((s) => s.playing && s.processingState != ProcessingState.completed)
      .distinct();

  @override
  Stream<bool> get completed =>
      _player.processingStateStream.map((s) => s == ProcessingState.completed).distinct();

  @override
  Stream<String> get errors =>
      _player.errorStream.map((e) => e.message ?? 'Gagal memutar audio (kode ${e.code}).');

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> seek(Duration position, {int? index}) => _player.seek(position, index: index);

  @override
  Future<void> playAll(List<Uri> uris, {int startIndex = 0}) async {
    await _player.setAudioSources(
      [for (final u in uris) AudioSource.uri(u)],
      initialIndex: startIndex,
      initialPosition: Duration.zero,
    );
    // AudioPlayer.play() baru selesai setelah jeda/berhenti/selesai; jangan di-await
    // agar pemanggil UI (ganti qari, lompat ayat, putar surah) tidak menggantung.
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero, index: 0);
    }
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setRepeatOne(bool repeat) => _player.setLoopMode(repeat ? LoopMode.one : LoopMode.off);

  @override
  Future<void> dispose() async {
    await _completionSub.cancel();
    await _player.dispose();
  }
}
