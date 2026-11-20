import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// Kata yang menandakan unsur komersial dan tidak boleh muncul di layar fitur Personal.
final _commercial = RegExp(r'Rp\s?\d|langganan|berlangganan|premium|beli|upgrade|iklan berbayar', caseSensitive: false);

Iterable<String> _visibleTexts(WidgetTester tester) sync* {
  for (final w in tester.widgetList<Text>(find.byType(Text))) {
    final t = w.data ?? w.textSpan?.toPlainText();
    if (t != null) yield t;
  }
}

void main() {
  testWidgets('layar fitur Personal (Beranda, Quran, Sholat, Ibadah) bebas unsur berbayar', (tester) async {
    await pumpApp(tester);
    for (final tab in ['Beranda', 'Quran', 'Sholat', 'Ibadah']) {
      await tester.tap(find.text(tab).last);
      await tester.pump();
      for (final t in _visibleTexts(tester)) {
        expect(_commercial.hasMatch(t), isFalse, reason: 'Tab $tab memuat teks komersial: "$t"');
      }
    }
  });

  testWidgets('Mosque hanya muncul sebagai fitur tambahan opsional di menu Lainnya', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Lainnya').last);
    await tester.pump();
    expect(find.text('Fitur tambahan (opsional)'), findsOneWidget);
    final entry = find.byKey(const Key('masjid-entry'));
    expect(find.descendant(of: entry, matching: find.text('Moeslim Mosque')), findsOneWidget);
    expect(find.descendant(of: entry, matching: find.textContaining('tidak diperlukan')), findsOneWidget);
    // Fitur Personal tidak pernah memaksa login: Beranda langsung bisa dipakai tanpa akun.
    await tester.tap(find.text('Beranda').last);
    await tester.pump();
    expect(find.byKey(const Key('countdown')), findsOneWidget);
  });
}
