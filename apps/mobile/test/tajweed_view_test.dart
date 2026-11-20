import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

const _ayah = Ayah(
  1,
  1,
  'ابجدهوز',
  translation: 'uji',
  tajweed: [TajweedSpan(0, 2, TajweedRule.ikhfa), TajweedSpan(4, 5, TajweedRule.qalqalah)],
);

Future<void> openFatihah(WidgetTester tester, {InMemoryStore? store}) async {
  await pumpApp(
    tester,
    store: store,
    quran: FakeQuranSource({
      1: [_ayah],
    }),
  );
  await tester.tap(find.text("Al-Qur'an").last);
  await tester.pump();
  await tester.tap(find.text('Al-Fatihah'));
  await tester.pumpAndSettle();
}

List<InlineSpan> ayahSpans(WidgetTester tester) {
  final rich = tester.widget<RichText>(
    find.descendant(of: find.byKey(const Key('ayah-1')), matching: find.byType(RichText)).first,
  );
  return (rich.text as TextSpan).children ?? const [];
}

void main() {
  testWidgets('teks ayat diwarnai sesuai anotasi tajwid', (tester) async {
    await openFatihah(tester);
    final spans = ayahSpans(tester).cast<TextSpan>();
    expect(spans.map((s) => s.text).join(), _ayah.text);
    expect(spans.first.text, 'اب');
    expect(spans.first.style?.color, Color(TajweedRule.ikhfa.color));
    expect(spans[2].text, 'ه');
    expect(spans[2].style?.color, Color(TajweedRule.qalqalah.color));
    expect(spans[1].style?.color, isNull); // teks polos memakai warna tema
  });

  testWidgets('pewarnaan dapat dimatikan dan tersimpan', (tester) async {
    final store = InMemoryStore();
    await openFatihah(tester, store: store);
    await tester.tap(find.byKey(const Key('toggle-tajweed')));
    await tester.pumpAndSettle();
    expect(ayahSpans(tester).length, 1);
    expect((await SettingsRepository(store).load()).tajweedColors, isFalse);
  });

  testWidgets('panduan warna tajwid menampilkan semua aturan', (tester) async {
    await openFatihah(tester);
    await tester.tap(find.byTooltip('Lainnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tajweed-legend')));
    await tester.pumpAndSettle();
    expect(find.text('Hamzah Washal'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Ikhfa\' Haqiqi'), 200);
    expect(find.text('Ikhfa\' Haqiqi'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mad \'Aridh Lissukun'), 200);
    expect(find.text('Mad \'Aridh Lissukun'), findsOneWidget);
  });
}
