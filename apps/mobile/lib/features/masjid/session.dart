import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'masjid_api.dart';

/// Penyimpanan token (secure storage di perangkat; in-memory di test).
abstract class TokenStore {
  Future<String?> read();
  Future<void> write(String? token);
}

class SecureTokenStore implements TokenStore {
  static const _key = 'moeslim.masjid.token';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? token) =>
      token == null ? _storage.delete(key: _key) : _storage.write(key: _key, value: token);
}

class MemoryTokenStore implements TokenStore {
  String? value;
  MemoryTokenStore([this.value]);

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? token) async => value = token;
}

final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
final masjidApiProvider = Provider<MasjidApi>((ref) => MasjidApi(ref.watch(httpClientProvider)));

class MasjidSession {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> mosques;
  final String? activeMosqueId;

  const MasjidSession({required this.user, required this.mosques, this.activeMosqueId});

  Map<String, dynamic>? get activeMosque => mosques.where((m) => m['id'] == activeMosqueId).firstOrNull;
  bool get emailVerified => user['email_verified'] == true;

  MasjidSession copyWith({List<Map<String, dynamic>>? mosques, String? activeMosqueId, Map<String, dynamic>? user}) =>
      MasjidSession(
        user: user ?? this.user,
        mosques: mosques ?? this.mosques,
        activeMosqueId: activeMosqueId ?? this.activeMosqueId,
      );
}

/// null = belum login.
class SessionNotifier extends AsyncNotifier<MasjidSession?> {
  @override
  Future<MasjidSession?> build() async {
    final token = await ref.read(tokenStoreProvider).read();
    if (token == null) return null;
    ref.read(masjidApiProvider).token = token;
    try {
      return await _load();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(tokenStoreProvider).write(null);
        return null;
      }
      rethrow;
    }
  }

  Future<MasjidSession> _load() async {
    final api = ref.read(masjidApiProvider);
    final me = await api.me();
    final mosques = await api.myMosques();
    return MasjidSession(
      user: Map<String, dynamic>.from(me['user'] as Map),
      mosques: mosques,
      activeMosqueId: mosques.isNotEmpty ? mosques.first['id'] as String : null,
    );
  }

  Future<void> login(String email, String password) async {
    final token = await ref.read(masjidApiProvider).login(email, password);
    await ref.read(tokenStoreProvider).write(token);
    state = AsyncData(await _load());
  }

  Future<void> register(String name, String email, String password) async {
    final token = await ref.read(masjidApiProvider).register(name, email, password);
    await ref.read(tokenStoreProvider).write(token);
    state = AsyncData(await _load());
  }

  Future<void> refresh() async => state = AsyncData(await _load());

  void selectMosque(String id) {
    final s = state.value;
    if (s != null) state = AsyncData(s.copyWith(activeMosqueId: id));
  }

  Future<void> logout() async {
    try {
      await ref.read(masjidApiProvider).logout().timeout(const Duration(seconds: 3));
    } catch (_) {}
    ref.read(masjidApiProvider).token = null;
    await ref.read(tokenStoreProvider).write(null);
    state = const AsyncData(null);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, MasjidSession?>(
  SessionNotifier.new,
  retry: (_, _) => null,
);

/// Kode undangan yang dimasukkan saat aktivasi akun; diterima otomatis setelah email terverifikasi.
class PendingInviteNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? token) => state = token;
}

final pendingInviteProvider = NotifierProvider<PendingInviteNotifier, String?>(PendingInviteNotifier.new);
