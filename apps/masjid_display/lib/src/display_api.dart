import 'dart:convert';

import 'package:http/http.dart' as http;

class DisplayApiException implements Exception {
  final int status;
  final String message;
  const DisplayApiException(this.status, this.message);

  bool get unpaired => status == 401;

  @override
  String toString() => message;
}

class ContentResponse {
  final Map<String, dynamic>? content; // null = 304 tidak berubah
  final String? etag;
  const ContentResponse(this.content, this.etag);
}

class DisplayApi {
  static const defaultBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api');

  final http.Client client;
  final String baseUrl;
  DisplayApi(this.client, {this.baseUrl = defaultBaseUrl});

  Future<({String token, String mosqueName})> pair(String code) async {
    final res = await _guard(
      () => client.post(
        Uri.parse('$baseUrl/display/pair'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'code': code, 'device_name': 'Moeslim Display'}),
      ),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw DisplayApiException(res.statusCode, (body['message'] as String?) ?? 'Pairing gagal.');
    }
    return (token: body['token'] as String, mosqueName: (body['mosque'] as Map)['name'] as String);
  }

  Future<ContentResponse> content(String token, {String? etag}) async {
    final res = await _guard(
      () => client.get(
        Uri.parse('$baseUrl/display/content'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token', 'If-None-Match': ?etag},
      ),
    );
    if (res.statusCode == 304) return ContentResponse(null, etag);
    if (res.statusCode != 200) {
      throw DisplayApiException(res.statusCode, 'Gagal mengambil konten (${res.statusCode}).');
    }
    return ContentResponse(jsonDecode(res.body) as Map<String, dynamic>, res.headers['etag']);
  }

  Future<http.Response> _guard(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const DisplayApiException(0, 'Tidak ada koneksi.');
    }
  }
}
