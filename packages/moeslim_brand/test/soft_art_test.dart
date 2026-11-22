import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

void main() {
  test('every 3D asset has a compact local thumbnail and full image', () {
    var total = 0;
    for (final asset in SoftAsset.values) {
      for (final path in [asset.assetPath, asset.thumbnailPath]) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        total += file.lengthSync();
      }
      expect(File(asset.thumbnailPath).lengthSync(), lessThan(100 * 1024));
    }
    expect(total, lessThan(8 * 1024 * 1024));
  });

  testWidgets('3D icons preserve semantics, sizing, finder compatibility and disabled tint', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: IconTheme(
      data: const IconThemeData(size: 32),
      child: const Column(children: [
        Icon(MoeslimIcons.masjid, semanticLabel: 'Masjid'),
        Icon(MoeslimIcons.kembali, semanticLabel: 'Kembali'),
        Icon(MoeslimIcons.masjid, color: Color(0x61000000), semanticLabel: 'Nonaktif'),
      ]),
    ))));
    await tester.pumpAndSettle();
    expect(find.byIcon(MoeslimIcons.kembali), findsOneWidget);
    expect(find.bySemanticsLabel('Masjid'), findsOneWidget);
    expect(find.byType(SoftArt), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('Masjid')), const Size(32, 32));
    final disabled = find.byWidgetPredicate((widget) => widget is material.Icon && widget.semanticLabel == 'Nonaktif');
    expect(tester.widget<material.Icon>(disabled).color, const Color(0x61000000));
  });
}
