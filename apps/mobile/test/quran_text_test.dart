import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
import 'package:moeslim_mobile/features/quran/surah_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  test('dataset bawaan: 114 surah lengkap, basmalah bukan bagian ayat 1', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final src = AssetQuranSource();
    var total = 0;
    for (final s in surahs) {
      final ayat = await src.load(s.number);
      expect(ayat, isNotNull, reason: 'surah ${s.number}');
      expect(ayat!.length, s.ayahCount, reason: 'surah ${s.number}');
      total += ayat.length;
    }
    expect(total, 6236);
    expect((await src.load(1))!.first.translation, startsWith('Dengan menyebut nama Allah'));
    expect((await src.load(114))!.last.translation, isNotEmpty);
    expect((await src.load(2))!.first.text, isNot(startsWith('\u0628\u0650\u0633\u0652\u0645\u0650')));
    expect(
      (await src.load(1))!.first.text,
      startsWith('\u0628\u0650\u0633\u0652\u0645\u0650'),
    ); // Al-Fatihah: basmalah = ayat 1
  });

  Future<void> openSurah(WidgetTester tester, String name) async {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.popUntil((r) => r.isFirst);
    await tester.pumpAndSettle();
    nav.push(MaterialPageRoute(builder: (_) => SurahPage(surah: surahs.firstWhere((s) => s.name == name))));
    await tester.pumpAndSettle();
  }

  final data = {
    1: [const Ayah(1, 1, 'بِسْمِ ٱللَّهِ')],
    2: [const Ayah(2, 1, 'الٓمٓ')],
    9: [const Ayah(9, 1, 'بَرَآءَةٌ')],
  };

  testWidgets('pembuka basmalah tampil di Al-Baqarah, tidak di Al-Fatihah & At-Taubah', (tester) async {
    await pumpApp(tester, quran: FakeQuranSource(data));
    await openSurah(tester, 'Al-Baqarah');
    expect(find.byKey(const Key('basmala-header')), findsOneWidget);
    await openSurah(tester, 'Al-Fatihah');
    expect(find.byKey(const Key('basmala-header')), findsNothing);
    await openSurah(tester, 'At-Taubah');
    expect(find.byKey(const Key('basmala-header')), findsNothing);
  });

  testWidgets('teks ayat memakai font mushaf Amiri Quran', (tester) async {
    await pumpApp(tester, quran: FakeQuranSource(data));
    await openSurah(tester, 'Al-Baqarah');
    final rich = tester.widget<RichText>(
      find.descendant(of: find.byKey(const Key('ayah-1')), matching: find.byType(RichText)).first,
    );
    expect(rich.text.style?.fontFamily, contains('AmiriQuran'));
  });

  testWidgets("Tentang & Lisensi mencantumkan sumber teks Al-Qur'an (Tanzil)", (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Profil').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('about-licenses')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('about-licenses')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Tanzil Quran Text'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Tanzil'), findsWidgets);
    await tester.scrollUntilVisible(
      find.textContaining('Kementerian Agama RI'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Kementerian Agama RI'), findsWidgets);
    await tester.scrollUntilVisible(
      find.textContaining('Font mushaf: Amiri Quran'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Amiri Quran'), findsWidgets);
  });
}
