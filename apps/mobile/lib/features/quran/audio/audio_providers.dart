import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_core/personal_core.dart';

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
  final String? naghom;
  final Recitation? recitation;
  final List<AudioTrack> queue;
  final int? index;
  final bool playing;
  final bool repeatAyah;
  final String? error;

  const PlayerState({
    this.surah,
    this.naghom,
    this.recitation,
    this.queue = const [],
    this.index,
    this.playing = false,
    this.repeatAyah = false,
    this.error,
  });

  AudioTrack? get current => index != null && index! < queue.length ? queue[index!] : null;

  PlayerState copyWith({
    int? surah,
    String? naghom,
    Recitation? recitation,
    List<AudioTrack>? queue,
    int? index,
    bool? playing,
    bool? repeatAyah,
    String? error,
    bool clearError = false,
  }) => PlayerState(
    surah: surah ?? this.surah,
    naghom: naghom ?? this.naghom,
    recitation: recitation ?? this.recitation,
    queue: queue ?? this.queue,
    index: index ?? this.index,
    playing: playing ?? this.playing,
    repeatAyah: repeatAyah ?? this.repeatAyah,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Pemutar murottal dengan pilihan 7 irama naghom per surah / per ayat.
class QuranPlayer extends Notifier<PlayerState> {
  final _subs = <StreamSubscription>[];

  AudioEngine get _engine => ref.read(audioEngineProvider);

  @override
  PlayerState build() {
    final engine = ref.watch(audioEngineProvider);
    _subs
      ..add(engine.currentIndex.listen((i) => state = state.copyWith(index: i)))
      ..add(engine.playing.listen((p) => state = state.copyWith(playing: p)));
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();
    });
    return const PlayerState();
  }

  /// Siapkan pilihan untuk surah: pakai preferensi terakhir bila tersedia, jika tidak irama pertama yang ada.
  Future<void> prepare(int surah, {String? prefer}) async {
    if (state.surah != null && state.surah != surah && state.playing) await _engine.stop();
    final manifest = await ref.read(audioManifestProvider.future);
    final options = manifest.optionsFor(surah);
    final prefs = ref.read(audioPrefsProvider);
    final prefNaghom = await prefs.naghom(), prefRec = await prefs.recitationId();
    final opt =
        options.where((o) => o.available && o.key == prefNaghom).firstOrNull ??
        options.where((o) => o.available).firstOrNull;
    final rec = opt == null
        ? null
        : (opt.recitations.where((r) => r.id == prefRec).firstOrNull ?? opt.recitations.first);
    state = PlayerState(surah: surah, naghom: opt?.key, recitation: rec, repeatAyah: state.repeatAyah);
  }

  /// Pilih bacaan: [slug] = `murattal` atau slug irama.
  Future<void> selectNaghom(String slug, {String? recitationId}) async {
    final surah = state.surah;
    if (surah == null) return;
    final manifest = await ref.read(audioManifestProvider.future);
    final opt = manifest.optionsFor(surah).firstWhere((o) => o.key == slug);
    if (!opt.available) return;
    final rec = opt.recitations.where((r) => r.id == recitationId).firstOrNull ?? opt.recitations.first;
    final wasPlaying = state.playing;
    final resumeAyah = state.current?.ayah;
    state = state.copyWith(naghom: slug, recitation: rec, clearError: true);
    await ref.read(audioPrefsProvider).save(naghom: slug, recitationId: rec.id);
    // Ganti irama saat memutar: lanjutkan dari ayat yang sama dengan irama baru.
    if (wasPlaying && resumeAyah != null) await playFrom(resumeAyah);
  }

  /// Putar surah mulai ayat [ayah] sampai akhir surah.
  Future<void> playFrom(int ayah) => _play(fromAyah: ayah);

  /// Putar satu ayat saja.
  Future<void> playAyah(int ayah) => _play(fromAyah: ayah, toAyah: ayah);

  Future<void> _play({required int fromAyah, int? toAyah}) async {
    final rec = state.recitation, surah = state.surah;
    if (rec == null || surah == null) return;
    try {
      final tracks = rec.playlist(surah, fromAyah: fromAyah, toAyah: toAyah);
      final offline = ref.read(offlineAudioProvider);
      final uris = [for (final t in tracks) await offline.localUri(t) ?? Uri.parse(t.url)];
      state = state.copyWith(queue: tracks, index: 0, clearError: true);
      await _engine.setRepeatOne(state.repeatAyah);
      await _engine.playAll(uris);
    } catch (e) {
      state = state.copyWith(error: 'Gagal memutar audio. Periksa koneksi atau unduh untuk offline.');
    }
  }

  /// Contoh irama untuk modul Naghom: ayat pertama Al-Fatihah dengan irama [slug].
  Future<bool> playSample(String slug) async {
    await prepare(1);
    final manifest = await ref.read(audioManifestProvider.future);
    if (!manifest.naghomOptionsFor(1).any((o) => o.style.slug == slug && o.available)) return false;
    await selectNaghom(slug);
    await playAyah(1);
    return true;
  }

  Future<void> togglePause() => state.playing ? _engine.pause() : _engine.resume();

  Future<void> stop() async {
    await _engine.stop();
    state = state.copyWith(playing: false);
  }

  Future<void> toggleRepeat() async {
    state = state.copyWith(repeatAyah: !state.repeatAyah);
    await _engine.setRepeatOne(state.repeatAyah);
  }
}

final quranPlayerProvider = NotifierProvider<QuranPlayer, PlayerState>(QuranPlayer.new);
