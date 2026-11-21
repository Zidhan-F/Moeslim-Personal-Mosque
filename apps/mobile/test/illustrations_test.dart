import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/masjid/masjid_home_page.dart';

import 'helpers.dart';

BrandIllustration artOf(WidgetTester tester, Finder f) => tester.widget<BrandArt>(f).art;

void main() {
  testWidgets('onboarding memakai ilustrasi masjid & Al-Qur\'an dari asset kit', (tester) async {
    await pumpApp(tester, showOnboarding: true);
    expect(artOf(tester, find.byKey(const Key('onboarding-art-0'))), BrandIllustration.masjidPagi4);
  });

  testWidgets('kompas kiblat menampilkan Ka\'bah di arah kiblat', (tester) async {
    await pumpApp(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(MaterialPageRoute(builder: (_) => const QiblaPage()));
    await tester.pumpAndSettle();
    expect(
      artOf(tester, find.descendant(of: find.byKey(const Key('compass-kaaba')), matching: find.byType(BrandArt))),
      BrandIllustration.kaaba,
    );
  });

  testWidgets('Pilih Peran & Login memakai ilustrasi masjid dan perisai', (tester) async {
    await pumpApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const MosqueLandingPage()));
    await tester.pumpAndSettle();
    expect(artOf(tester, find.byKey(const Key('landing-art'))), BrandIllustration.mosqueCircle);
    nav.push(MaterialPageRoute(builder: (_) => const LoginPage()));
    await tester.pumpAndSettle();
    expect(artOf(tester, find.byKey(const Key('login-art'))), BrandIllustration.loginShield);
  });
}
