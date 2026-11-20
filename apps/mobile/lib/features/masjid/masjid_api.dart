import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int status;
  final String? code;
  final String message;
  final Map<String, dynamic> errors;

  const ApiException(this.status, this.message, {this.code, this.errors = const {}});

  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}

/// Klien REST Moeslim Masjid. Base URL diatur saat build:
/// `--dart-define=API_BASE_URL=https://api.contoh.id/api`.
class MasjidApi {
  static const defaultBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api');

  final http.Client _client;
  final String baseUrl;
  String? token;

  MasjidApi(this._client, {this.baseUrl = defaultBaseUrl, this.token});

  static String newIdempotencyKey() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final req = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      });
    if (body != null) req.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await http.Response.fromStream(await _client.send(req).timeout(const Duration(seconds: 20)));
    } catch (_) {
      throw const ApiException(0, 'Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    throw ApiException(
      res.statusCode,
      (map['message'] as String?) ?? 'Terjadi kesalahan (${res.statusCode}).',
      code: map['code'] as String?,
      errors: (map['errors'] as Map<String, dynamic>?) ?? const {},
    );
  }

  // Auth
  Future<String> login(String email, String password) async {
    final r = await _send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password, 'device_name': 'moeslim-mobile'},
    );
    return token = r['token'] as String;
  }

  Future<String> register(String name, String email, String password) async {
    final r = await _send(
      'POST',
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'device_name': 'moeslim-mobile',
      },
    );
    return token = r['token'] as String;
  }

  Future<void> verifyEmail(String code) => _send('POST', '/auth/email/verify', body: {'code': code});
  Future<void> logout() => _send('POST', '/auth/logout');
  Future<Map<String, dynamic>> me() async => Map<String, dynamic>.from(await _send('GET', '/me') as Map);

  // Masjid
  Future<List<Map<String, dynamic>>> myMosques() async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/mosques'))['data'] as List);

  Future<Map<String, dynamic>> registerMosque(Map<String, dynamic> data) async =>
      Map<String, dynamic>.from((await _send('POST', '/mosques', body: data))['data'] as Map);

  Future<Map<String, dynamic>> dashboard(String mosqueId) async =>
      Map<String, dynamic>.from(await _send('GET', '/mosques/$mosqueId/dashboard') as Map);

  Future<Map<String, dynamic>> financeSetup(String mosqueId) async =>
      Map<String, dynamic>.from(await _send('GET', '/mosques/$mosqueId/finance/setup') as Map);

  Future<List<Map<String, dynamic>>> transactions(String mosqueId, {String? from, String? to}) async {
    final r = await _send('GET', '/mosques/$mosqueId/finance/transactions', query: {'from': ?from, 'to': ?to});
    return List<Map<String, dynamic>>.from(r['data'] as List);
  }

  Future<Map<String, dynamic>> createTransaction(
    String mosqueId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async {
    final r = await _send(
      'POST',
      '/mosques/$mosqueId/finance/transactions',
      body: data,
      headers: {'Idempotency-Key': idempotencyKey},
    );
    return Map<String, dynamic>.from(r['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> events(String mosqueId) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/mosques/$mosqueId/events'))['data'] as List);

  Future<Map<String, dynamic>> createEvent(String mosqueId, Map<String, dynamic> data) async =>
      Map<String, dynamic>.from((await _send('POST', '/mosques/$mosqueId/events', body: data))['data'] as Map);

  // Publik (tanpa akun)
  Future<List<Map<String, dynamic>>> searchPublicMosques(String q) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/public/mosques', query: {'q': q}))['data'] as List);

  Future<List<Map<String, dynamic>>> publicEvents(String slug) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/public/mosques/$slug/events'))['data'] as List);

  Future<List<Map<String, dynamic>>> publicAnnouncements(String slug) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/public/mosques/$slug/announcements'))['data'] as List);
}
