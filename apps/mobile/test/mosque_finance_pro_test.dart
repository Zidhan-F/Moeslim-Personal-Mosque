import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/finance_pages.dart';
import 'package:moeslim_mobile/features/masjid/finance_pro_pages.dart';
import 'package:moeslim_mobile/features/masjid/masjid_api.dart';
import 'package:moeslim_mobile/features/masjid/mosque_providers.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'fake_mosque_backend.dart';

void main() {
  const ctx = MosqueCtx(
    id: 'M1',
    name: 'Masjid Al-Ikhlas',
    city: 'Jakarta',
    slug: 'masjid-al-ikhlas',
    role: 'bendahara',
    permissions: {'finance.view', 'finance.write', 'finance.export'},
  );

  Widget wrap(Widget child, List<http.Request> log) => ProviderScope(
    overrides: [
      masjidApiProvider.overrideWithValue(
        MasjidApi(fakeMosqueBackend(log, permissions: ctx.permissions.toList()), baseUrl: 'https://t.test/api', token: 'tok'),
      ),
    ],
    child: MaterialApp(home: child),
  );

  testWidgets('Laporan Kas Jumat 1-Klik tampilkan saldo akhir dan salin teks WA', (t) async {
    final log = <http.Request>[];
    String? copied;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );

    await t.pumpWidget(wrap(const FridayReportPage(ctx: ctx), log));
    await t.pumpAndSettle();

    expect(find.byKey(const Key('friday-closing-balance')), findsOneWidget);
    expect(find.text('Rp1.350.000'), findsWidgets);

    await t.ensureVisible(find.byKey(const Key('friday-copy-wa')));
    await t.tap(find.byKey(const Key('friday-copy-wa')));
    await t.pumpAndSettle();

    expect(copied, contains('LAPORAN KAS JUMAT'));
    expect(copied, contains('1.350.000'));
  });

  testWidgets('Hitung Kotak Amal multi-saksi hitung total pecahan dan kirim idempoten', (t) async {
    final log = <http.Request>[];
    await t.pumpWidget(wrap(const DonationBoxCountPage(ctx: ctx), log));
    await t.pumpAndSettle();

    await t.enterText(find.byKey(const Key('witness-1')), 'H. Budi');
    await t.enterText(find.byKey(const Key('witness-2')), 'Bpk. Slamet');
    await t.enterText(find.byKey(const Key('denom-100000')), '2');
    await t.enterText(find.byKey(const Key('denom-50000')), '1');
    await t.pump();

    expect(find.byKey(const Key('box-total')), findsOneWidget);
    expect(find.text('Rp250.000'), findsWidgets);

    await t.scrollUntilVisible(
      find.byKey(const Key('save-box-count')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('save-box-count')));
    await t.pumpAndSettle();

    final post = log.firstWhere((r) => r.method == 'POST' && r.url.path.endsWith('/donation-box-counts'));
    expect(post.headers['Idempotency-Key'], isNotEmpty);
    final body = jsonDecode(post.body) as Map;
    expect(body['witness_1_name'], 'H. Budi');
    expect(body['witness_2_name'], 'Bpk. Slamet');
    expect(body['denominations']['100000'], 2);
    expect(body['denominations']['50000'], 1);
  });

  testWidgets('Kuitansi Digital QR tampilkan QR verifikasi, nama donatur, dan status valid', (t) async {
    final log = <http.Request>[];
    await t.pumpWidget(wrap(const TransactionHistoryPage(ctx: ctx), log));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('tx-11')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-receipt')));
    await t.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('H. Ahmad Fauzi'), findsOneWidget);
    expect(find.text('Terverifikasi'), findsOneWidget);
    expect(find.byKey(const Key('receipt-copy-wa')), findsOneWidget);
  });
}
