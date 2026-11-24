import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';


import 'helpers.dart';

void main() {
  testWidgets('Beranda memakai ilustrasi brand, tema brand, dan font Inter', (tester) async {
    await pumpApp(tester);
    // Banner sapaan tampil bersih tanpa ikon masjid, memakai tema brand dan font Inter.
    expect(find.byKey(const Key('greeting')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('greeting')), matching: find.byType(BrandArt)), findsNothing);
    final ctx = tester.element(find.byKey(const Key('countdown')));
    expect(Theme.of(ctx).colorScheme.primary, BrandColors.emerald);
    expect(Theme.of(ctx).textTheme.bodyMedium?.fontFamily, contains('Inter'));
  });

  testWidgets('teks di kartu jadwal (latar putih) memenuhi kontras ≥ 4.5:1', (tester) async {
    await pumpApp(tester);
    final card = find.byKey(const Key('prayer-card'));
    expect(card, findsOneWidget);
    for (final t in tester.widgetList<Text>(find.descendant(of: card, matching: find.byType(Text)))) {
      final color = t.style?.color ?? DefaultTextStyle.of(tester.element(find.byWidget(t))).style.color!;
      expect(
        contrastRatio(Color.alphaBlend(color, Colors.white), Colors.white),
        greaterThanOrEqualTo(4.5),
        reason: '"${t.data}"',
      );
    }
  });

  testWidgets('semua teks di kartu jadwal memakai Inter (DefaultTextStyle tidak menghapus font tema)', (tester) async {
    await pumpApp(tester);
    final card = find.byKey(const Key('prayer-card'));
    final texts = find.descendant(of: card, matching: find.byType(RichText));
    expect(texts, findsWidgets);
    for (final e in texts.evaluate()) {
      final rich = e.widget as RichText;
      final family = rich.text.style?.fontFamily ?? '';
      if (family == 'MaterialIcons' || family.endsWith('MoeslimIcons')) continue; // ikon dekoratif
      expect(rich.text.style?.fontFamily, contains('Inter'), reason: rich.text.toPlainText());
    }
  });
}
