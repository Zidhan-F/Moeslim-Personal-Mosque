import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/agenda_page.dart';
import 'package:moeslim_mobile/features/masjid/masjid_api.dart';
import 'package:moeslim_mobile/features/masjid/microsite_page.dart';
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

  testWidgets('Generator Poster & Teks WA dari Agenda ganti tema dan salin teks WA', (t) async {
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

    await t.pumpWidget(wrap(const AgendaPage(ctx: ctx), log));
    await t.pumpAndSettle();

    await t.tap(find.text('Daftar'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('share-event-7')));
    await t.pumpAndSettle();

    expect(find.text('Bagikan Poster & Teks WA'), findsOneWidget);
    await t.tap(find.byKey(const Key('theme-night')));
    await t.pump();

    await t.ensureVisible(find.byKey(const Key('poster-copy-wa')));
    await t.tap(find.byKey(const Key('poster-copy-wa')));
    await t.pumpAndSettle();

    expect(copied, contains('KAJIAN RUTIN JUMAT'));
    expect(copied, contains('Masjid Al-Ikhlas'));
  });

  testWidgets('Microsite Profil Masjid tampilkan QR tautan publik dan aktifkan transparansi kas', (t) async {
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

    await t.pumpWidget(wrap(const MosqueMicrositePage(ctx: ctx), log));
    await t.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('https://t.test/m/masjid-al-ikhlas'), findsOneWidget);

    await t.ensureVisible(find.byKey(const Key('microsite-copy-url')));
    await t.tap(find.byKey(const Key('microsite-copy-url')));
    await t.pumpAndSettle();
    expect(copied, 'https://t.test/m/masjid-al-ikhlas');

    await t.drag(find.byType(ListView), const Offset(0, -300));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const Key('microsite-finance-switch')));
    await t.tap(find.byKey(const Key('microsite-finance-switch')));
    await t.pumpAndSettle();

    final patch = log.firstWhere((r) => r.method == 'PATCH' && r.url.path.endsWith('/mosques/M1'));
    final body = jsonDecode(patch.body) as Map;
    expect((body['settings'] as Map)['public_show_finance'], isTrue);
  });
}
