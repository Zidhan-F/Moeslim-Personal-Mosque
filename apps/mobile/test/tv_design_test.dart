import 'dart:convert';

import 'package:display_ui/display_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import 'mosque_ui_test.dart' show openMosque, openAccountMenu, tapVisible;

/// Halaman desain memakai jam berjalan & teks berjalan, jadi dipompa manual (bukan pumpAndSettle).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

final _list = find.byKey(const Key('tv-design-controls'));

Future<void> reveal(WidgetTester tester, Finder f, {bool up = false}) async {
  await tester.dragUntilVisible(f, _list, Offset(0, up ? 200 : -200));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> tapControl(WidgetTester tester, Finder f) async {
  await reveal(tester, f);
  await tester.tap(f);
  await settle(tester);
}

TvStage stage(WidgetTester tester) => tester.widget<TvStage>(find.byKey(const Key('tv-design-preview')));

void phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> openDesign(WidgetTester tester) async {
  await openAccountMenu(tester, 'menu-tv');
  await tapVisible(tester, find.byKey(const Key('screen-5')));
  await tester.tap(find.byKey(const Key('open-tv-design')));
  phoneSize(tester);
  await settle(tester);
}

void main() {
  testWidgets('desain TV: pratinjau langsung, ganti tema & widget, simpan ke TV', (tester) async {
    final log = await openMosque(tester);
    await openDesign(tester);

    // Pratinjau memakai data asli masjid dari endpoint preview.
    expect(find.byKey(const Key('tv-design-preview')), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const Key('tv-design-preview')), matching: find.text('Masjid Al-Ikhlas')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tv-mosque-art')), findsOneWidget);
    await reveal(tester, find.byKey(const Key('tv-design-save')));
    expect(tester.widget<FilledButton>(find.byKey(const Key('tv-design-save'))).onPressed, isNull);
    await reveal(tester, find.byKey(const Key('tv-theme-navy')), up: true);

    await tester.tap(find.byKey(const Key('tv-theme-navy')));
    await settle(tester);
    expect(stage(tester).config.theme, TvThemePreset.navy);

    await tapControl(tester, find.byKey(const Key('tv-widget-illustration')));
    expect(find.byKey(const Key('tv-mosque-art')), findsNothing);

    // Mode pratinjau Info Jamaah menampilkan pengumuman.
    await tester.tap(find.text('Info Jamaah'));
    await settle(tester);
    expect(stage(tester).screen, TvScreen.info);
    expect(find.text('Kerja bakti'), findsOneWidget);

    await tapControl(tester, find.byKey(const Key('tv-design-save')));
    final patch = log.lastWhere((r) => r.method == 'PATCH' && r.url.path.endsWith('/displays/5'));
    final config = (jsonDecode(patch.body) as Map)['config'] as Map;
    expect(config['theme'], 'navy');
    expect(config['show_illustration'], false);
    expect(config['info_seconds'], 20);
    expect(tester.widget<FilledButton>(find.byKey(const Key('tv-design-save'))).onPressed, isNull);

    // Pratinjau layar penuh (lanskap) bisa dibuka dan ditutup.
    await tester.tap(find.byKey(const Key('tv-preview-fullscreen')));
    await settle(tester);
    expect(find.byType(RotatedBox), findsOneWidget);
    expect(find.text('Kerja bakti'), findsWidgets);
    await tester.tap(find.byKey(const Key('tv-preview-close')));
    await settle(tester);
    expect(find.byKey(const Key('tv-preview-close')), findsNothing);
  });

  testWidgets('warna sendiri: latar terang membuat teks TV otomatis gelap', (tester) async {
    await openMosque(tester);
    await openDesign(tester);

    // Geser daftar tema ke ujung kanan.
    await tester.drag(find.byKey(const Key('tv-theme-auto')), const Offset(-500, 0));
    await settle(tester);
    await tester.tap(find.byKey(const Key('tv-theme-custom')));
    await settle(tester);
    for (final row in ['bg1', 'bg2']) {
      await tapControl(tester, find.byKey(Key('tv-custom-$row')));
      await tester.tap(find.byKey(const Key('tv-color-F7F7F1')));
      await settle(tester);
    }
    expect(stage(tester).config.palette.fg, BrandColors.deep);
    expect(stage(tester).config.palette.minTextContrast, greaterThanOrEqualTo(4.5));
  });
}
