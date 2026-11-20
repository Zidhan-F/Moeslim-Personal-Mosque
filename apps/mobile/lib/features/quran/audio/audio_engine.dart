import 'package:just_audio/just_audio.dart';

/// Abstraksi pemutar agar logika dapat diuji tanpa plugin native.
abstract class AudioEngine {
  Stream<int?> get currentIndex;
  Stream<bool> get playing;
  Stream<Duration> get position;
  Stream<Duration?> get duration;
  Future<void> setSpeed(double speed);
  Future<void> seek(Duration position);
  Future<void> playAll(List<Uri> uris, {int startIndex = 0});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> setRepeatOne(bool repeat);
  Future<void> dispose();
}

class JustAudioEngine implements AudioEngine {
  final _player = AudioPlayer();

  @override
  Stream<int?> get currentIndex => _player.currentIndexStream;

  @override
  Stream<bool> get playing => _player.playingStream;

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> playAll(List<Uri> uris, {int startIndex = 0}) async {
    await _player.setAudioSources([for (final u in uris) AudioSource.uri(u)], initialIndex: startIndex);
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setRepeatOne(bool repeat) => _player.setLoopMode(repeat ? LoopMode.one : LoopMode.off);

  @override
  Future<void> dispose() => _player.dispose();
}
