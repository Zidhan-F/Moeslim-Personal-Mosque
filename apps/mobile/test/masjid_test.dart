import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/masjid_api.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';

import 'fake_mosque_backend.dart';
import 'helpers.dart';

void main() {
  group('MasjidApi', () {
    test('login menyimpan token dan header Authorization terkirim', () async {
      final log = <http.Request>[];
      final api = MasjidApi(fakeMosqueBackend(log), baseUrl: 'https://api.test/api');
      await api.login('b@x.id', 'benar-sekali-123');
      expect(api.token, 't0k3n');
      await api.me();
      expect(log.last.headers['Authorization'], 'Bearer t0k3n');
    });

    test('error 422 diterjemahkan ke ApiException', () async {
      final api = MasjidApi(fakeMosqueBackend([]), baseUrl: 'https://api.test/api');
      expect(
        () => api.login('b@x.id', 'salah'),
        throwsA(
          isA<ApiException>().having((e) => e.status, 'status', 422).having((e) => e.errors.keys, 'errors', ['email']),
        ),
      );
    });

    test('createTransaction mengirim Idempotency-Key', () async {
      final log = <http.Request>[];
      final api = MasjidApi(fakeMosqueBackend(log), baseUrl: 'https://api.test/api', token: 't');
      final key = MasjidApi.newIdempotencyKey();
      expect(key, hasLength(32));
      await api.createTransaction('M1', {'amount': 1}, idempotencyKey: key);
      expect(log.single.headers['Idempotency-Key'], key);
    });

    test('kegagalan jaringan menjadi pesan yang ramah', () async {
      final api = MasjidApi(MockClient((_) => throw Exception('offline')), baseUrl: 'https://api.test/api');
      expect(() => api.me(), throwsA(isA<ApiException>().having((e) => e.status, 'status', 0)));
    });
  });

  testWidgets('login pengurus lalu dashboard menampilkan saldo & peringatan', (tester) async {
    final log = <http.Request>[];
    final tokens = MemoryTokenStore();
    await pumpApp(tester, client: fakeMosqueBackend(log), tokens: tokens);
    await tester.tap(find.text('Profil').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('masjid-entry')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('masjid-entry')));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Peran di Moeslim PM'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('login-admin-start')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('login-admin-start')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email')), 'b@x.id');
    await tester.enterText(find.byKey(const Key('password')), 'salah');
    await tester.ensureVisible(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('password')), 'benar-sekali-123');
    await tester.ensureVisible(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(tokens.value, 't0k3n');
    expect(find.text('Masjid Al-Ikhlas'), findsOneWidget);
    expect(find.textContaining('250.000'), findsWidgets);
    expect(find.textContaining('80%'), findsOneWidget);
    expect(find.text('Keuangan'), findsOneWidget); // tab sesuai izin finance.view
    expect(find.text('Petugas'), findsNothing); // bendahara tanpa staff.view
  });
}
