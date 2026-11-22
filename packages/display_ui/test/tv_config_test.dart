import 'package:display_ui/display_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

final content = <String, dynamic>{
  'mosque': {
    'id': 'M1',
    'name': 'Masjid Uji',
    'address': 'Jl. Uji',
    'city': 'Jakarta',
    'latitude': -6.2,
    'longitude': 106.8,
    'timezone': 'Asia/Jakarta',
    'prayer_method': 'kemenag',
    'settings': <String, dynamic>{},
  },
  'events': <Map>[],
  'announcements': [
    {'id': 1, 'title': 'Kerja bakti', 'body': 'Ahad pagi', 'priority': 1},
  ],
  'staff_today': <Map>[],
};

Future<void> pumpStage(WidgetTester tester, TvDisplayConfig config, {TvScreen screen = TvScreen.main}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final mosque = Map<String, dynamic>.from(content['mosque'] as Map);
  final schedule = DisplaySchedule.fromMosque(mosque);
  final now = DateTime(2026, 11, 20, 9, 15, 30);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TvStage(
          content: content,
          config: config,
          now: now,
          schedule: schedule,
          status: schedule.statusAt(now),
          screen: screen,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  test('config: bawaan, round-trip JSON, kunci lain tetap dibawa, nilai tak valid diabaikan', () {
    const d = TvDisplayConfig();
    expect(d.theme, TvThemePreset.auto);
    expect(d.showIllustration && d.showTicker && d.showInfoScreen, isTrue);

    final c = TvDisplayConfig.fromJson({
      'theme': 'custom',
      'custom_background': '#123456',
      'show_hijri': false,
      'info_seconds': 30,
      'ticker_text': '  Mohon tenang  ',
      'language': 'en',
      'rotation_seconds': 25,
    });
    expect(c.customBackground, const Color(0xFF123456));
    expect(c.tickerText, 'Mohon tenang');
    final j = c.toJson();
    expect(j['language'], 'en');
    expect(j['rotation_seconds'], 25);
    expect(j['custom_background'], '#123456');
    expect(TvDisplayConfig.fromJson(j).toJson(), j);

    final bad = TvDisplayConfig.fromJson({'theme': 'pink', 'info_seconds': 17, 'custom_accent': 'merah'});
    expect(bad.theme, TvThemePreset.auto);
    expect(bad.infoSeconds, 20);
    expect(bad.customAccent, BrandColors.gold);
  });

  test('palet: tema lama tidak berubah, teks selalu kontras di semua preset & warna sendiri', () {
    expect(TvPalette.of('light').fg, BrandColors.deep);
    expect(TvPalette.of('dark').card, BrandColors.nightCard);
    expect(TvPalette.of(null).background, [BrandColors.emerald, BrandColors.deep]);

    for (final p in TvThemePreset.values) {
      final pal = TvDisplayConfig(theme: p).palette;
      expect(pal.minTextContrast, greaterThanOrEqualTo(4.5), reason: p.id);
      expect(contrastRatio(pal.onAccent, pal.accent), greaterThanOrEqualTo(4.5), reason: p.id);
    }
    const choices = [Color(0xFFFFFFFF), Color(0xFFF7F7F1), Color(0xFF1C1C1C), Color(0xFF2E86C1), Color(0xFFD9AB36)];
    for (final bg in choices) {
      for (final accent in choices) {
        final pal = TvDisplayConfig(
          theme: TvThemePreset.custom,
          customBackground: bg,
          customBackground2: bg,
          customAccent: accent,
        ).palette;
        expect(pal.minTextContrast, greaterThanOrEqualTo(4.5), reason: '$bg');
        for (final b in pal.background) {
          expect(contrastRatio(pal.accentText, b), greaterThanOrEqualTo(3), reason: '$bg / $accent');
        }
      }
    }
  });

  testWidgets('TvStage: widget yang dimatikan pengurus tidak tampil', (tester) async {
    await pumpStage(tester, const TvDisplayConfig());
    expect(find.byKey(const Key('tv-mosque-art')), findsOneWidget);
    expect(find.byKey(const Key('tv-hijri')), findsOneWidget);
    expect(find.text('09:15:30'), findsOneWidget);
    expect(find.text('Syuruq'), findsOneWidget);
    expect(find.byKey(const Key('sync-label')), findsOneWidget);

    await pumpStage(
      tester,
      const TvDisplayConfig(
        showIllustration: false,
        showHijri: false,
        showSeconds: false,
        showSunrise: false,
        showTicker: false,
      ),
    );
    expect(find.byKey(const Key('tv-mosque-art')), findsNothing);
    expect(find.byKey(const Key('tv-hijri')), findsNothing);
    expect(find.text('09:15'), findsOneWidget);
    expect(find.text('Syuruq'), findsNothing);
    expect(find.byKey(const Key('sync-label')), findsNothing);
  });

  testWidgets('TvStage: teks berjalan pengurus tampil paling depan; layar info', (tester) async {
    const config = TvDisplayConfig(tickerText: 'Mohon matikan ponsel');
    await pumpStage(tester, config, screen: TvScreen.info);
    expect(find.text('Kerja bakti'), findsOneWidget);
    final stage = tester.widget<TvStage>(find.byType(TvStage));
    expect(stage.tickerText(), startsWith('Mohon matikan ponsel'));
    expect(TvStage.hasInfo(content, config), isTrue);
    expect(TvStage.hasInfo(content, const TvDisplayConfig(showInfoScreen: false)), isFalse);
  });
}
