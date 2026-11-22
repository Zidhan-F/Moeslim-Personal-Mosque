import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/masjid_api.dart';
import 'package:moeslim_mobile/features/masjid/mosque_providers.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/masjid/zakat_qurban_page.dart';

import 'fake_mosque_backend.dart';

void main() {
  const ctx = MosqueCtx(
    id: 'M1',
    name: 'Masjid Al-Ikhlas',
    city: 'Jakarta',
    slug: 'masjid-al-ikhlas',
    role: 'admin',
    permissions: {'*'},
  );

  Widget wrap(Widget child, List<http.Request> log) => ProviderScope(
    overrides: [
      masjidApiProvider.overrideWithValue(
        MasjidApi(fakeMosqueBackend(log, role: 'admin', permissions: adminPermissions), baseUrl: 'https://t.test/api', token: 'tok'),
      ),
    ],
    child: MaterialApp(home: child),
  );

  testWidgets('Zakat Page: catat penerimaan muzakki dan salurkan ke mustahik', (t) async {
    final log = <http.Request>[];
    await t.pumpWidget(wrap(const ZakatPage(ctx: ctx), log));
    await t.pumpAndSettle();

    expect(find.text('Keluarga Bpk. Hasan'), findsOneWidget);

    await t.tap(find.byKey(const Key('add-zakat-collection')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('muzakki-name')), 'Bpk. Ridwan');
    await t.enterText(find.byKey(const Key('muzakki-souls')), '3');
    await t.enterText(find.byKey(const Key('muzakki-money')), '135000');
    await t.ensureVisible(find.byKey(const Key('save-zakat-collection')));
    await t.tap(find.byKey(const Key('save-zakat-collection')));
    await t.pumpAndSettle();

    final post = log.firstWhere((r) => r.method == 'POST' && r.url.path.endsWith('/zakat/collections'));
    final body = jsonDecode(post.body) as Map;
    expect(body['muzakki_name'], 'Bpk. Ridwan');
    expect(body['souls_count'], 3);
    expect(body['money_amount'], 135000);

    // Pindah ke tab Mustahik dan salurkan
    await t.tap(find.text('Mustahik (Salur)'));
    await t.pumpAndSettle();
    expect(find.text('Mbah Suyono'), findsOneWidget);
    await t.tap(find.byKey(const Key('distribute-mustahik-10')));
    await t.pumpAndSettle();
    expect(log.any((r) => r.method == 'POST' && r.url.path.endsWith('/zakat/mustahiks/10/distribute')), isTrue);
  });

  testWidgets('Kurban & Kupon QR: tambah shohibul qurban 1/7 dan verifikasi kupon anti-dobel', (t) async {
    final log = <http.Request>[];
    await t.pumpWidget(wrap(const QurbanPage(ctx: ctx), log));
    await t.pumpAndSettle();

    expect(find.text('SAPI-01 • Sapi'), findsOneWidget);
    await t.scrollUntilVisible(
      find.byKey(const Key('add-participant-5')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('add-participant-5')));
    await t.pumpAndSettle();

    await t.enterText(find.byKey(const Key('participant-name')), 'Ibu Aminah');
    await t.enterText(find.byKey(const Key('participant-shares')), '2');
    await t.enterText(find.byKey(const Key('participant-amount')), '7000000');
    await t.ensureVisible(find.byKey(const Key('save-participant')));
    await t.tap(find.byKey(const Key('save-participant')));
    await t.pumpAndSettle();

    final postPart = log.firstWhere((r) => r.method == 'POST' && r.url.path.endsWith('/qurban/animals/5/participants'));
    expect((jsonDecode(postPart.body) as Map)['name'], 'Ibu Aminah');

    // Gulir kembali ke atas untuk pindah ke tab Kupon QR & Scan
    await t.drag(find.byType(ListView), const Offset(0, 400));
    await t.pumpAndSettle();
    await t.tap(find.text('Kupon QR & Scan'));
    await t.pumpAndSettle();

    // Verifikasi kupon valid
    await t.enterText(find.byKey(const Key('coupon-code-input')), 'QBN-ABC123');
    await t.tap(find.byKey(const Key('redeem-coupon-btn')));
    await t.pumpAndSettle();
    expect(find.textContaining('berhasil ditukar'), findsOneWidget);

    // Verifikasi kupon ganda -> tampilkan pesan tolak anti-dobel
    await t.enterText(find.byKey(const Key('coupon-code-input')), 'QBN-DUP');
    await t.tap(find.byKey(const Key('redeem-coupon-btn')));
    await t.pumpAndSettle();
    expect(find.textContaining('sudah ditukarkan sebelumnya'), findsOneWidget);
  });
}
