import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/core/theme.dart';
import 'package:moeslim_mobile/features/more/theme_picker.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  test('ten themes persist; old Auto, missing and invalid values become Light', () async {
    expect(AppThemeMode.values.length, 10);
    expect(PersonalSettings.defaults.themeMode, AppThemeMode.light);
    for (final value in ['system', null, 'unknown']) {
      final json = <String, dynamic>{...PersonalSettings.defaults.toJson(), 'themeMode': value};
      expect(PersonalSettings.fromJson(json).themeMode, AppThemeMode.light);
    }
    final repo = SettingsRepository(InMemoryStore());
    for (final mode in AppThemeMode.values) {
      await repo.save(PersonalSettings.defaults.copyWith(themeMode: mode));
      expect((await repo.load()).themeMode, mode);
      final theme = buildAppTheme(mode);
      double contrast(Color a, Color b) {
        final x = a.computeLuminance();
        final y = b.computeLuminance();
        return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
      }

      expect(contrast(theme.colorScheme.onSurface, theme.scaffoldBackgroundColor), greaterThanOrEqualTo(4.5), reason: '${mode.name} onSurface/scaffold');
      expect(contrast(theme.colorScheme.onSurface, theme.cardTheme.color!), greaterThanOrEqualTo(4.5), reason: '${mode.name} onSurface/card');
      expect(contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary), greaterThanOrEqualTo(4.5), reason: '${mode.name} primary/onPrimary');
      final visual = mode.visual;
      for (final stop in visual.heroGradient) {
        expect(contrast(visual.heroTextColor, stop), greaterThanOrEqualTo(4.5), reason: '${mode.name} heroText');
        expect(contrast(visual.heroSubtextColor, stop), greaterThanOrEqualTo(4.5), reason: '${mode.name} heroSubtext');
      }
      for (final stop in visual.bannerGradient) {
        expect(contrast(Colors.white, stop), greaterThanOrEqualTo(4.5), reason: '${mode.name} bannerWhite');
      }
      expect(contrast(visual.countdownText, visual.countdownBg), greaterThanOrEqualTo(4.5), reason: '${mode.name} countdown');
      expect(contrast(visual.activePrayerText, visual.activePrayerBg), greaterThanOrEqualTo(4.5), reason: '${mode.name} activePrayer');
    }
  });

  testWidgets('profile selects and saves all ten themes independent of device brightness', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final store = InMemoryStore();
    if (const bool.fromEnvironment('WRITE_THEME_PREVIEWS')) {
      await tester.runAsync(() async {
        for (final entry in {'Inter': 'Inter-Regular.ttf', 'MoeslimIcons': 'MoeslimIcons.ttf'}.entries) {
          await (FontLoader(
            'packages/moeslim_brand/${entry.key}',
          )..addFont(rootBundle.load('packages/moeslim_brand/fonts/${entry.value}'))).load();
        }
        await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      });
    }
    await pumpApp(tester, store: store);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(NavigationBar))).brightness, Brightness.light);
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    // Uji tombol cepat Terang / Gelap langsung dari Profil.
    await tester.ensureVisible(find.byKey(const Key('quick-theme-dark')));
    await tester.tap(find.byKey(const Key('quick-theme-dark')));
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).themeMode, AppThemeMode.dark);
    await tester.ensureVisible(find.byKey(const Key('quick-theme-light')));
    await tester.tap(find.byKey(const Key('quick-theme-light')));
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).themeMode, AppThemeMode.light);
    for (final mode in AppThemeMode.values) {
      await Scrollable.ensureVisible(tester.element(find.byKey(const Key('theme-selector'))), alignment: .5);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('theme-selector')));
      await tester.pumpAndSettle();
      expect(find.text('Auto'), findsNothing);
      final option = find.byKey(Key('theme-${mode.name}'));
      await tester.scrollUntilVisible(
        option,
        180,
        scrollable: find.descendant(of: find.byType(AlertDialog), matching: find.byType(Scrollable)),
      );
      await Scrollable.ensureVisible(tester.element(option), alignment: .5);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect((await SettingsRepository(store).load()).themeMode, mode);
      final active = Theme.of(tester.element(find.byType(NavigationBar)));
      expect(active.scaffoldBackgroundColor, buildAppTheme(mode).scaffoldBackgroundColor);
      expect(active.brightness, mode.isDark ? Brightness.dark : Brightness.light);
      expect(tester.takeException(), isNull, reason: mode.name);
      if (const bool.fromEnvironment('WRITE_THEME_PREVIEWS')) {
        await tester.tap(find.text('Beranda').last);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final output = File('build/theme-previews/${mode.name}.png');
          await output.parent.create(recursive: true);
          await output.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.tap(find.text('Profil').last);
        await tester.pumpAndSettle();
      }
    }
  });

  for (final width in [320.0, 600.0, 1024.0]) {
    testWidgets('picker fits width $width with large text; cancel and Escape work', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      AppThemeMode? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(AppThemeMode.rosa),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showThemePicker(context, AppThemeMode.rosa);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('theme-rosa')), 180);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
}
