import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/family_education_page.dart';
import 'package:moeslim_mobile/features/ibadah/seasonal_ramadan_page.dart';
import 'package:moeslim_mobile/features/ibadah/sedekah_tracker_page.dart';
import 'package:moeslim_mobile/features/ibadah/share_card_page.dart';
import 'package:moeslim_mobile/features/ibadah/zakat_faraid_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  testWidgets('ZakatFaraidPage kosong default (contoh hanya di hint) dan bebas overflow di layar 360px fontScale 1.3', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, fontScale: 1.3),
    );
    await pumpApp(tester, store: store);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const ZakatFaraidPage()));
    await tester.pumpAndSettle();

    // Semua kolom mulai kosong, contoh hanya tampil sebagai hintText.
    final goldField = tester.widget<TextField>(find.byKey(const Key('zakat-gold-price')));
    final savingsField = tester.widget<TextField>(find.byKey(const Key('zakat-savings-field')));
    expect(goldField.controller!.text, isEmpty);
    expect(savingsField.controller!.text, isEmpty);
    expect(savingsField.decoration?.hintText, contains('Contoh:'));
    expect(tester.widget<Text>(find.byKey(const Key('zakat-maal-output'))).data, 'Rp0');

    // Isi nominal besar dan pastikan perhitungan tampil utuh tanpa overflow di 360px fontScale 1.3.
    await tester.enterText(find.byKey(const Key('zakat-savings-field')), '160000000');
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('zakat-maal-output'))).data, 'Rp4.000.000');

    final scrollable = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('zakat-income-field')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    final incomeField = tester.widget<TextField>(find.byKey(const Key('zakat-income-field')));
    expect(incomeField.controller!.text, isEmpty);
    await tester.enterText(find.byKey(const Key('zakat-income-field')), '15000000');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('zakat-profesi-output')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('zakat-profesi-output'))).data, 'Rp375.000');
    expect(tester.takeException(), isNull);

    // Reset mengosongkan kembali seluruh isian.
    await tester.tap(find.byKey(const Key('zakat-reset-btn')));
    await tester.pumpAndSettle();
    expect(savingsField.controller!.text, isEmpty);
    expect(incomeField.controller!.text, isEmpty);

    // Tab Fitrah & Fidyah juga bebas default terisi & bebas overflow.
    await tester.tap(find.byKey(const Key('tab-Fitrah & Fidyah')));
    await tester.pumpAndSettle();
    final fitrahScrollable = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('fitrah-money-output')), 150, scrollable: fitrahScrollable);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('fitrah-money-output'))).data, 'Rp0');
    expect(tester.takeException(), isNull);

    // Tab Waris (Faraid) mulai kosong (harta kosong, ahli waris belum dipilih).
    await tester.tap(find.byKey(const Key('tab-Waris (Faraid)')));
    await tester.pumpAndSettle();
    final estateField = tester.widget<TextField>(find.byKey(const Key('faraid-estate-field')));
    expect(estateField.controller!.text, isEmpty);
    await tester.enterText(find.byKey(const Key('faraid-estate-field')), '120000000');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sedekah, Kurban/Aqiqah, Utang-Piutang, dan ShareCard mulai kosong (contoh di hint, hilang saat diisi)', (
    tester,
  ) async {
    await pumpApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);

    nav.push(MaterialPageRoute(builder: (_) => const SedekahTrackerPage()));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('sedekah-amount-field'))).controller!.text, isEmpty);

    nav.push(MaterialPageRoute(builder: (_) => const SeasonalRamadanPage(initialTab: 1)));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('qurban-cow-price'))).controller!.text, isEmpty);

    nav.push(MaterialPageRoute(builder: (_) => const FamilyEducationPage(initialTab: 4)));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('debt-amount-field'))).controller!.text, isEmpty);

    nav.push(MaterialPageRoute(builder: (_) => const ShareCardPage()));
    await tester.pumpAndSettle();
    final cardScrollable = find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('share-translation-field')), 200, scrollable: cardScrollable);
    await tester.pumpAndSettle();
    final shareArabic = tester.widget<TextField>(find.byKey(const Key('share-arabic-field')));
    final shareTrans = tester.widget<TextField>(find.byKey(const Key('share-translation-field')));
    expect(shareArabic.controller!.text, isEmpty);
    expect(shareTrans.controller!.text, isEmpty);
    expect(shareTrans.decoration?.hintText, contains('Contoh:'));
    await tester.enterText(find.byKey(const Key('share-translation-field')), 'Kutipan baru pengguna');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-card-preview')), -250, scrollable: cardScrollable);
    await tester.pumpAndSettle();
    expect(find.text('"Kutipan baru pengguna"'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
