import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/hadith_page.dart';
import 'package:moeslim_mobile/features/ibadah/share_card_page.dart';
import 'package:moeslim_mobile/features/quran/surah_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  testWidgets('ShareCardPage mencakup picker semua 114 surah & rentang ayat, 50 hadits, 229 doa, dan bahasa dwibahasa', (
    tester,
  ) async {
    final quranMap = {
      112: [
        const Ayah(
          112,
          1,
          'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
          translation: 'Katakanlah, Dialah Allah Yang Maha Esa.',
          translationEn: 'Say, He is Allah, the One.',
        ),
        const Ayah(
          112,
          2,
          'ٱللَّهُ ٱلصَّمَدُ',
          translation: 'Allah tempat meminta segala sesuatu.',
          translationEn: 'Allah, the Eternal Refuge.',
        ),
        const Ayah(
          112,
          3,
          'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          translation: 'Dia tidak beranak dan tidak pula diperanakkan.',
          translationEn: 'He neither begets nor is born.',
        ),
        const Ayah(
          112,
          4,
          'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ',
          translation: 'Dan tidak ada sesuatu yang setara dengan Dia.',
          translationEn: 'Nor is there to Him any equivalent.',
        ),
      ],
    };

    await pumpApp(tester, quran: FakeQuranSource(quranMap));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const ShareCardPage()));
    await tester.pumpAndSettle();

    // 1. Pilih Surah 112 (Al-Ikhlas) & ayat 2 dari picker Al-Qur'an
    await tester.ensureVisible(find.byKey(const Key('share-pick-quran')));
    await tester.tap(find.byKey(const Key('share-pick-quran')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('share-quran-surah-search')), '112');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('share-surah-item-112')), findsOneWidget);
    await tester.tap(find.byKey(const Key('share-surah-item-112')));
    await tester.pumpAndSettle();

    // Pilih rentang ayat 1 sampai 2 menggunakan tombol Pakai setelah memilih Ayat 2
    await tester.tap(find.byKey(const Key('share-ayah-end-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayat 2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-apply-quran-range')));
    await tester.pumpAndSettle();

    expect(find.text('QS. Al-Ikhlas: 1-2'), findsWidgets);
    expect(find.textContaining('Allah tempat meminta segala sesuatu'), findsWidgets);

    // Ganti mode bahasa kartu ke ID + EN (dwibahasa)
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.byKey(const Key('share-lang-mode')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byKey(const Key('share-lang-mode')), matching: find.text('ID + EN')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Say, He is Allah, the One.'), findsWidgets);

    // 2. Pilih Hadits ke-44 (Senyum adalah Sedekah) dari picker 50 Hadits
    await tester.scrollUntilVisible(find.byKey(const Key('share-pick-hadith')), -200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-pick-hadith')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('share-hadith-search')), 'senyum');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('share-hadith-item-44')), findsOneWidget);
    await tester.tap(find.byKey(const Key('share-hadith-item-44')));
    await tester.pumpAndSettle();

    expect(find.textContaining('تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ'), findsWidgets);
    expect(find.textContaining('Tirmidzi'), findsWidgets);

    // 3. Pilih Doa Harian dari picker 229 Doa
    await tester.scrollUntilVisible(find.byKey(const Key('share-pick-dua')), -200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-pick-dua')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('share-dua-search')), 'tidur');
    await tester.pumpAndSettle();
    final firstDuaTile = find.descendant(of: find.byType(BottomSheet), matching: find.byType(ListTile)).first;
    await tester.tap(firstDuaTile);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ShareCardPage studio kustomisasi penuh (Tema, Ornamen, Tipografi, Reset) aman di 360px & fontScale 1.3', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, fontScale: 1.3, themeMode: AppThemeMode.dark),
    );
    await pumpApp(tester, store: store);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const ShareCardPage()));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;

    // Tab Tema: pilih rasio 4:5, tema baru oliveMadinah, gradien radial
    await tester.scrollUntilVisible(find.byKey(const Key('tab-Tema')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-Tema')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-ratio-potret')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-ratio-potret')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-theme-oliveMadinah')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-theme-oliveMadinah')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-grad-radial')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-grad-radial')));
    await tester.pumpAndSettle();

    // Tab Ornamen: pilih pola kisi mushaf, bingkai ganda, pemisah rub el hizb
    await tester.scrollUntilVisible(find.byKey(const Key('tab-Ornamen')), -200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-Ornamen')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-pattern-mushafLattice')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-pattern-mushafLattice')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-frame-doubleClassic')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-frame-doubleClassic')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-divider-rubElHizb')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-divider-rubElHizb')));
    await tester.pumpAndSettle();

    // Tab Tipografi: ubah perataan ke Kiri
    await tester.scrollUntilVisible(find.byKey(const Key('tab-Tipografi')), -200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-Tipografi')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('share-align-selector')), 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byKey(const Key('share-align-selector')), matching: find.text('Kiri')));
    await tester.pumpAndSettle();

    // Reset gaya
    await tester.tap(find.byKey(const Key('share-reset-style-btn')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pintasan langsung Buat Kartu dari SurahPage, HadithDetailPage, dan DailyDuaDetailPage', (tester) async {
    final quranMap = {
      1: [
        const Ayah(
          1,
          1,
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          translation: 'Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
          translationEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
      ],
    };
    await pumpApp(tester, quran: FakeQuranSource(quranMap));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);

    // 1. Dari SurahPage
    nav.push(MaterialPageRoute(builder: (_) => SurahPage(surah: surahs.first)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('share-ayah-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('share-card-preview')), findsOneWidget);
    expect(find.text('QS. Al-Fatihah: 1'), findsWidgets);

    // 2. Dari HadithDetailPage
    nav.push(MaterialPageRoute(builder: (_) => HadithDetailPage(hadith: hadithCatalog.first)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hadith-share-card-btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('share-card-preview')), findsOneWidget);
    expect(find.textContaining('Bukhari'), findsWidgets);

    // 3. Dari DailyDuaDetailPage & DoaDetailPage
    const sampleDua = DailyDua(
      id: 999,
      group: 'Doa Harian',
      title: 'Doa Kebaikan Dunia Akhirat',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
      latin: '',
      translation: 'Ya Tuhan kami, berilah kami kebaikan di dunia.',
      source: 'QS. Al-Baqarah: 201',
    );
    nav.push(MaterialPageRoute(builder: (_) => const DailyDuaDetailPage(dua: sampleDua)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dua-share-card-btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('share-card-preview')), findsOneWidget);
    expect(find.textContaining('Doa Kebaikan Dunia Akhirat'), findsWidgets);

    nav.push(
      MaterialPageRoute(
        builder: (_) => DoaDetailPage(dua: QuranicDua(1, 1, 1, quranMap[1]!)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quran-dua-share-card-btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('share-card-preview')), findsOneWidget);
    expect(find.text('QS. Al-Fatihah: 1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
