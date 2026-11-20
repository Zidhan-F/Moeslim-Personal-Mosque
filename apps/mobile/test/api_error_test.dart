import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:moeslim_mobile/features/masjid/masjid_api.dart';

void main() {
  test('respons error non-JSON (HTML 502) menjadi ApiException', () async {
    final api = MasjidApi(MockClient((_) async => http.Response('<html>Bad Gateway</html>', 502)), baseUrl: 'https://x/api');
    expect(() => api.me(), throwsA(isA<ApiException>().having((e) => e.status, 'status', 502)));
  });
}
