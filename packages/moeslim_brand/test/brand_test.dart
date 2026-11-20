import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

void main() {
  test('palet resmi brand kit', () {
    expect(BrandColors.emerald, const Color(0xFF087E65));
    expect(BrandColors.deep, const Color(0xFF07372F));
    expect(BrandColors.dark, const Color(0xFF06473D));
    expect(BrandColors.gold, const Color(0xFFD9AB36));
    expect(BrandColors.cream, const Color(0xFFF7F7F1));
  });

  group('kontras WCAG ≥ 4.5:1 untuk pasangan teks', () {
    final pairs = {
      'emerald di cream': (BrandColors.emerald, BrandColors.cream),
      'putih di emerald': (Colors.white, BrandColors.emerald),
      'deep di cream': (BrandColors.deep, BrandColors.cream),
      'emas di deep': (BrandColors.gold, BrandColors.deep),
      'emas teks di cream': (BrandColors.goldText, BrandColors.cream),
      'deep di emas': (BrandColors.deep, BrandColors.gold),
    };
    for (final e in pairs.entries) {
      test(e.key, () => expect(contrastRatio(e.value.$1, e.value.$2), greaterThanOrEqualTo(4.5)));
    }
    test('emas di latar terang gagal → hanya dekoratif', () {
      expect(contrastRatio(BrandColors.gold, BrandColors.cream), lessThan(3));
    });
  });

  test('tema memakai Inter, warna brand, dan mode gelap', () {
    final light = BrandTheme.light();
    final dark = BrandTheme.dark();
    expect(light.textTheme.bodyMedium?.fontFamily, contains('Inter'));
    expect(light.colorScheme.primary, BrandColors.emerald);
    expect(light.colorScheme.secondary, BrandColors.gold);
    expect(light.scaffoldBackgroundColor, BrandColors.cream);
    expect(dark.brightness, Brightness.dark);
    expect(contrastRatio(dark.colorScheme.primary, dark.scaffoldBackgroundColor), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(dark.colorScheme.onSurface, dark.scaffoldBackgroundColor), greaterThanOrEqualTo(4.5));
  });

  testWidgets('BrandLogo: varian otomatis per kecerahan & label aksesibilitas', (tester) async {
    Future<String> assetFor(Brightness b, BrandLogoVariant v) async {
      await tester.pumpWidget(MaterialApp(
        theme: b == Brightness.light ? BrandTheme.light() : BrandTheme.dark(),
        home: Scaffold(body: BrandLogo(variant: v, height: 40)),
      ));
      await tester.pumpAndSettle(); // tema beranimasi saat berganti
      final img = tester.widget<Image>(find.byType(Image));
      return (img.image as AssetImage).keyName;
    }

    expect(await assetFor(Brightness.light, BrandLogoVariant.horizontal),
        'packages/moeslim_brand/assets/logo/horizontal.png');
    expect(await assetFor(Brightness.dark, BrandLogoVariant.horizontal),
        'packages/moeslim_brand/assets/logo/horizontal_white.png');
    expect(await assetFor(Brightness.dark, BrandLogoVariant.symbol),
        'packages/moeslim_brand/assets/logo/symbol_white.png');
    expect(find.bySemanticsLabel('Moeslim PM — Personal & Mosque'), findsOneWidget);
  });
}
