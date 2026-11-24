import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/hijri_page.dart';
import 'package:moeslim_mobile/features/quran/murottal_page.dart';
import 'package:moeslim_mobile/features/quran/surah_page.dart';
import 'package:moeslim_mobile/features/quran/tajweed_view.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  testWidgets('Menu Tentang memuat daftar isi, seluruh referensi, audio, dan lisensi terpusat', (tester) async {
    await pumpApp(
      tester,
      manifest: AudioManifest.fromJson({
        'version': 1,
        'recitations': [
          {
            'id': 'a',
            'qari': 'Qari A',
            'kind': 'murattal',
            'base_url': 'https://c/a',
            'license': 'CC BY-NC 4.0',
            'attribution': 'Rekaman Qari A (sumber X)',
            'surahs': [1],
          },
          {
            'id': 'b',
            'qari': 'Qari B',
            'kind': 'murattal',
            'base_url': 'https://c/b',
            'license': 'Izin non-komersial tertulis',
            'attribution': 'Qari B',
            'surahs': 'all',
          },
        ],
      }),
    );

    await tester.tap(find.text('Profil').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-developer-watermark')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('profile-developer-watermark')), findsOneWidget);
    expect(find.text('Develop by zidhan.id'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('about-licenses')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    // Tidak ada lagi AboutListTile ganda di Profil: semua masuk ke satu menu Tentang.
    expect(find.byType(AboutListTile), findsNothing);

    await tester.tap(find.byKey(const Key('about-licenses')));
    await tester.pumpAndSettle();

    // Watermark pengembang, pernyataan non-komersial & Daftar Isi interaktif.
    expect(find.byKey(const Key('about-developer-watermark')), findsOneWidget);
    expect(find.text('Develop by zidhan.id'), findsOneWidget);
    expect(find.textContaining('non-komersial'), findsWidgets);
    expect(find.textContaining('tanpa iklan'), findsOneWidget);
    expect(find.text('Daftar Isi'), findsOneWidget);
    expect(find.byKey(const Key('toc-1')), findsOneWidget);
    expect(find.byKey(const Key('toc-2')), findsOneWidget);
    expect(find.byKey(const Key('toc-3')), findsOneWidget);
    expect(find.byKey(const Key('toc-4')), findsOneWidget);

    // Lompat via Daftar Isi ke bagian Referensi & Sumber.
    await tester.tap(find.byKey(const Key('toc-2')));
    await tester.pumpAndSettle();
    expect(find.text('2. Referensi & Sumber'), findsOneWidget);
    expect(find.textContaining('Tanzil Quran Text'), findsOneWidget);
    expect(find.textContaining('Hisnul Muslim'), findsWidgets);
    expect(find.textContaining('WGS84'), findsOneWidget);

    // Lompat ke bagian Audio Murottal & Adzan.
    final scroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Rekaman Qari A (sumber X)'), 200, scrollable: scroll);
    expect(find.text('Rekaman Qari A (sumber X)'), findsOneWidget);
    expect(find.textContaining('CC BY-NC 4.0'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Qari B'), 200, scrollable: scroll);
    expect(find.textContaining('Izin non-komersial tertulis'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Audio Adzan Bawaan'), 200, scrollable: scroll);
    expect(find.text('Syaikh Ali Ahmad Mulla'), findsOneWidget);

    // Bagian Lisensi & tombol Lisensi Pustaka Sumber Terbuka.
    await tester.scrollUntilVisible(find.byKey(const Key('open-oss-licenses')), 200, scrollable: scroll);
    expect(find.text('4. Lisensi & Ketentuan'), findsOneWidget);
    expect(find.textContaining('SIL Open Font License 1.1'), findsWidgets);
    await tester.tap(find.byKey(const Key('open-oss-licenses')));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('halaman lain tidak lagi menampilkan info referensi, atribusi, atau lisensi', (tester) async {
    final testManifest = AudioManifest.fromJson({
      'version': 1,
      'recitations': [
        {
          'id': 'a',
          'qari': 'Qari A',
          'kind': 'murattal',
          'base_url': 'https://c/a',
          'license': 'Lisensi Khusus Uji',
          'attribution': 'Atribusi Uji EveryAyah',
          'surahs': 'all',
        },
      ],
    });
    const fakeDua = DailyDua(
      id: 1,
      group: 'Doa Sebelum dan Sesudah Tidur',
      title: 'Doa Uji',
      arabic: 'بِسْمِكَ اللَّهُمَّ',
      latin: 'Bismika Allahumma',
      translation: 'Dengan nama-Mu ya Allah.',
      source: 'HR. Bukhari 6324.\n\nSumber: Hisnul Muslim.\nSumber: http://example.com',
      tags: ['tidur'],
    );
    await pumpApp(
      tester,
      manifest: testManifest,
      dailyDuas: const [fakeDua],
      quran: FakeQuranSource({
        2: [
          for (var i = 1; i <= 286; i++) Ayah(2, i, 'آية $i', translation: 'Terjemahan ayat $i'),
        ],
      }),
    );

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);

    // 1. DoaListPage (Doa Harian & Doa Al-Qur'an) bebas Hisnul Muslim & Kemenag.
    nav.push(MaterialPageRoute(builder: (_) => const DoaListPage()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hisnul Muslim'), findsNothing);
    expect(find.textContaining('Kemenag'), findsNothing);

    // 2. DailyDuaDetailPage menghapus baris "Sumber: ..." namun tetap menampilkan dalil hadis.
    await tester.tap(find.text('Doa Uji'));
    await tester.pumpAndSettle();
    expect(find.textContaining('HR. Bukhari 6324'), findsOneWidget);
    expect(find.textContaining('Hisnul Muslim'), findsNothing);
    expect(find.textContaining('Sumber:'), findsNothing);
    expect(find.text('Sumber & Keterangan'), findsNothing);
    nav.pop();
    await tester.pumpAndSettle();

    // 3. DoaDetailPage (Doa Al-Qur'an) bebas Tanzil & Kementerian Agama RI.
    await tester.tap(find.byKey(const Key('tab-Doa Al-Qur\'an')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('doa-search')), '200');
    await tester.pumpAndSettle();
    await tester.tap(find.text('QS. Al-Baqarah: 200–201'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tanzil'), findsNothing);
    expect(find.textContaining('Kemenag'), findsNothing);
    expect(find.textContaining('Kementerian Agama'), findsNothing);

    // 4. MurottalPage bebas atribusi & lisensi.
    nav.push(MaterialPageRoute(builder: (_) => const MurottalPage(initialSurah: 1)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Lisensi:'), findsNothing);
    expect(find.textContaining('Atribusi Uji'), findsNothing);

    // 5. AudioSheet (di SurahPage) bebas atribusi & lisensi.
    nav.push(MaterialPageRoute(builder: (_) => SurahPage(surah: surahs.first)));
    await tester.pumpAndSettle();
    await openAudioSheet(tester);
    expect(find.textContaining('Lisensi:'), findsNothing);
    expect(find.textContaining('Atribusi Uji'), findsNothing);
    nav.pop();
    await tester.pumpAndSettle();

    // 6. TajweedLegendPage bebas referensi Tanzil.
    nav.push(MaterialPageRoute(builder: (_) => const TajweedLegendPage()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tanzil'), findsNothing);

    // 7. HijriPage bebas catatan metode aritmetika/sidang isbat (sudah pindah ke Tentang).
    nav.push(MaterialPageRoute(builder: (_) => const HijriPage()));
    await tester.pumpAndSettle();
    expect(find.textContaining('sidang isbat'), findsNothing);
  });

  testWidgets('halaman Tentang aman tanpa overflow pada layar 360px, fontScale 1.3, dan mode gelap', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, themeMode: AppThemeMode.dark, fontScale: 1.3),
    );
    await pumpApp(tester, store: store);
    await tester.tap(find.text('Profil').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('about-licenses')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('about-licenses')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('toc-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toc-4')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-oss-licenses')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
