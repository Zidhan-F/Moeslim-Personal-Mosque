import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/masjid_api.dart';
import 'package:moeslim_mobile/features/masjid/mosque_providers.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/masjid/tv_config_page.dart';

import 'fake_mosque_backend.dart';

Future<void> _pumpTvConfig(WidgetTester tester, List<http.Request> log) async {
  final client = fakeMosqueBackend(log, role: 'admin', permissions: adminPermissions);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        httpClientProvider.overrideWithValue(client),
        masjidApiProvider.overrideWith((ref) => MasjidApi(client, token: 't0k3n')),
      ],
      child: const MaterialApp(
        home: TvConfigPage(
          ctx: MosqueCtx(id: 'M1', name: 'Masjid Al-Ikhlas', city: 'Jakarta', role: 'admin', permissions: {'*'}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('TV Config Pro: siarkan override berita duka, atur iqamah & layar hening, dan aktifkan kas Jumat', (
    tester,
  ) async {
    final log = <http.Request>[];
    await _pumpTvConfig(tester, log);

    final tvScroll = find.descendant(of: find.byType(TvConfigPage), matching: find.byType(Scrollable)).first;

    // 1. Trigger override berita duka
    await tester.scrollUntilVisible(find.byKey(const Key('tv-override-btn')), 200, scrollable: tvScroll);
    await tester.ensureVisible(find.byKey(const Key('tv-override-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tv-override-btn')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('override-title')), 'Berita Duka');
    await tester.enterText(find.byKey(const Key('override-body')), 'Telah berpulang Bpk. H. Hasan.');
    await tester.tap(find.byKey(const Key('override-submit')));
    await tester.pumpAndSettle();

    final ovReq = log.lastWhere((r) => r.url.path.endsWith('/displays/override') && r.method == 'POST');
    expect(jsonDecode(ovReq.body)['type'], 'duka');
    expect(jsonDecode(ovReq.body)['title'], 'Berita Duka');

    // 2. Toggle tampilkan kas Jumat di TV
    await tester.scrollUntilVisible(find.byKey(const Key('tv-show-finance-switch')), 200, scrollable: tvScroll);
    await tester.ensureVisible(find.byKey(const Key('tv-show-finance-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tv-show-finance-switch')));
    await tester.pumpAndSettle();

    final finReq = log.lastWhere((r) => r.url.path.endsWith('/displays/settings') && r.method == 'PATCH');
    expect(jsonDecode(finReq.body)['display_show_finance'], isTrue);

    // 3. Buka pengaturan iqamah & layar hening salat lalu simpan
    await tester.scrollUntilVisible(find.byKey(const Key('tv-prayer-settings-btn')), 200, scrollable: tvScroll);
    await tester.ensureVisible(find.byKey(const Key('tv-prayer-settings-btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tv-prayer-settings-btn')));
    await tester.pumpAndSettle();
    final sheetScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.byKey(const Key('save-tv-settings')), 200, scrollable: sheetScroll);
    await tester.ensureVisible(find.byKey(const Key('save-tv-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-tv-settings')));
    await tester.pumpAndSettle();

    final setReq = log.lastWhere((r) => r.url.path.endsWith('/displays/settings') && r.method == 'PATCH');
    expect((jsonDecode(setReq.body) as Map).containsKey('iqamah_minutes'), isTrue);
    expect((jsonDecode(setReq.body) as Map).containsKey('praying_minutes'), isTrue);
  });

  testWidgets('TV Web Zero-Install: salin tautan /tv, hubungkan sesi QR via kode layar TV, dan slot manual tetap jalan', (
    tester,
  ) async {
    final log = <http.Request>[];
    await _pumpTvConfig(tester, log);

    final tvScroll = find.descendant(of: find.byType(TvConfigPage), matching: find.byType(Scrollable)).first;

    // 1. Kartu TV Web & tombol salin tautan /tv tampil
    expect(find.byKey(const Key('tv-web-card')), findsOneWidget);
    expect(find.byKey(const Key('copy-tv-url')), findsOneWidget);
    expect(find.textContaining('/tv'), findsWidgets);

    // 2. Buka sheet Scan QR TV dan masukkan kode 6 digit sesi dari layar TV
    await tester.scrollUntilVisible(find.byKey(const Key('scan-tv-qr')), 200, scrollable: tvScroll);
    await tester.ensureVisible(find.byKey(const Key('scan-tv-qr')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scan-tv-qr')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-tv-qr-scanner')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('qr-tv-name')), 'TV Ruang Utama');
    await tester.enterText(find.byKey(const Key('tv-session-code')), '654321');
    await tester.tap(find.byKey(const Key('approve-tv-session')));
    await tester.pumpAndSettle();

    final approveReq = log.lastWhere((r) => r.url.path.endsWith('/displays/approve-session') && r.method == 'POST');
    final payload = jsonDecode(approveReq.body) as Map<String, dynamic>;
    expect(payload['code'], '654321');
    expect(payload['name'], 'TV Ruang Utama');

    // 3. Backward-compatibility: tap slot kosong masih membuka dialog buat kode manual
    await tester.scrollUntilVisible(find.byKey(const Key('slot-1')), -200, scrollable: tvScroll);
    await tester.ensureVisible(find.byKey(const Key('slot-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('slot-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tv-name')), 'Serambi');
    await tester.tap(find.byKey(const Key('create-code')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pairing-code')), findsOneWidget);
  });
}
