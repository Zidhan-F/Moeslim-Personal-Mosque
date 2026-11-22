import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'display_api.dart';

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());
final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final displayApiProvider = Provider((ref) => DisplayApi(ref.watch(httpClientProvider)));

/// Sumber waktu perangkat (di-override di test agar selisih jam server dapat diuji).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Jam berjalan; di-override di test.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

class DisplayState {
  final String? token;
  final Map<String, dynamic>? content;
  final String? etag;
  final DateTime? lastSync;
  final Duration clockSkew; // server - perangkat
  final bool offline;
  final AppLanguage language;

  const DisplayState({
    this.token,
    this.content,
    this.etag,
    this.lastSync,
    this.clockSkew = Duration.zero,
    this.offline = false,
    this.language = AppLanguage.id,
  });

  bool get paired => token != null;

  /// Bahasa aktif layar TV: membaca `device.config.language` bila diatur dari admin,
  /// jika tidak memakai bahasa lokal [language] (bawaan Bahasa Indonesia).
  AppLanguage get effectiveLanguage {
    final config = (content?['device'] as Map?)?['config'] as Map?;
    final cfgLang = config?['language'] as String?;
    if (cfgLang != null && cfgLang.trim().isNotEmpty) {
      return AppLanguage.fromCode(cfgLang);
    }
    return language;
  }
}

class DisplayController extends Notifier<DisplayState> {
  static const _kToken = 'display.token', _kContent = 'display.content', _kSync = 'display.lastSync';
  static const _kEtag = 'display.etag', _kSkew = 'display.skewMs', _kLang = 'display.language';
  static const refreshEvery = Duration(seconds: 60);

  DateTime? _lastAttempt;
  bool _busy = false;

  SharedPreferences get _prefs => ref.read(prefsProvider);

  @override
  DisplayState build() {
    final raw = _prefs.getString(_kContent);
    Map<String, dynamic>? cached;
    if (raw != null) {
      try {
        cached = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return DisplayState(
      token: _prefs.getString(_kToken),
      content: cached,
      etag: _prefs.getString(_kEtag),
      lastSync: DateTime.tryParse(_prefs.getString(_kSync) ?? ''),
      clockSkew: Duration(milliseconds: _prefs.getInt(_kSkew) ?? 0),
      language: AppLanguage.fromCode(_prefs.getString(_kLang)),
    );
  }

  Future<void> setLanguage(AppLanguage lang) async {
    await _prefs.setString(_kLang, lang.code);
    state = DisplayState(
      token: state.token,
      content: state.content,
      etag: state.etag,
      lastSync: state.lastSync,
      clockSkew: state.clockSkew,
      offline: state.offline,
      language: lang,
    );
  }

  Future<String> pair(String code) async {
    final lang = state.effectiveLanguage;
    final r = await ref.read(displayApiProvider).pair(code, lang: lang);
    await _prefs.setString(_kToken, r.token);
    for (final k in [_kContent, _kEtag, _kSync]) {
      await _prefs.remove(k);
    }
    state = DisplayState(token: r.token, language: state.language);
    await refresh(force: true);
    return r.mosqueName;
  }

  /// Dipanggil tiap detik oleh layar; hanya menyinkron bila sudah waktunya.
  Future<void> tick(DateTime now) async {
    // Selisih negatif = jam perangkat mundur (mis. koreksi NTP) → anggap sudah waktunya.
    final elapsed = _lastAttempt == null ? null : now.difference(_lastAttempt!);
    if (elapsed == null || elapsed.isNegative || elapsed >= refreshEvery) await refresh();
  }

  Future<void> refresh({bool force = false}) async {
    final token = state.token;
    if (token == null || _busy) return;
    _busy = true;
    final clock = ref.read(clockProvider);
    _lastAttempt = clock();
    try {
      final res = await ref
          .read(displayApiProvider)
          .content(token, etag: force ? null : state.etag, lang: state.effectiveLanguage);
      final now = clock();
      var content = state.content;
      var skew = state.clockSkew;
      if (res.serverTime != null) {
        skew = res.serverTime!.difference(now);
        await _prefs.setInt(_kSkew, skew.inMilliseconds);
      }
      if (res.content != null) {
        content = res.content;
        await _prefs.setString(_kContent, jsonEncode(content));
        if (res.etag != null) await _prefs.setString(_kEtag, res.etag!);
      }
      await _prefs.setString(_kSync, now.toIso8601String());
      state = DisplayState(
        token: token,
        content: content,
        etag: res.etag,
        lastSync: now,
        clockSkew: skew,
        language: state.language,
      );
    } on DisplayApiException catch (e) {
      if (e.unpaired) {
        await unpair();
      } else {
        state = DisplayState(
          token: token,
          content: state.content,
          etag: state.etag,
          lastSync: state.lastSync,
          clockSkew: state.clockSkew,
          offline: true,
          language: state.language,
        );
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> unpair() async {
    for (final k in [_kToken, _kContent, _kEtag, _kSync, _kSkew]) {
      await _prefs.remove(k);
    }
    state = DisplayState(language: state.language);
  }
}

final displayControllerProvider = NotifierProvider<DisplayController, DisplayState>(DisplayController.new);
