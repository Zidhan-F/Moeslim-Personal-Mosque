import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/mosque_providers.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/masjid/tv_config_page.dart';

import 'fake_mosque_backend.dart';
import 'helpers.dart';

void main() {
  testWidgets('TV Config Pro: siarkan override berita duka, atur iqamah & layar hening, dan aktifkan kas Jumat', (
    tester,
  ) async {
    final log = <http.Request>[];
    final tokens = MemoryTokenStore()..write('t0k3n');
    await pumpApp(
      tester,
      tokens: tokens,
      client: fakeMosqueBackend(log, role: 'admin', permissions: adminPermissions),
    );
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(
      MaterialPageRoute(
        builder: (_) => const TvConfigPage(
          ctx: MosqueCtx(id: 'M1', name: 'Masjid Al-Ikhlas', city: 'Jakarta', role: 'admin', permissions: {'*'}),
        ),
      ),
    );
    await tester.pumpAndSettle();

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
}
