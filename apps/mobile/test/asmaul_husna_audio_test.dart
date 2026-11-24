import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_mobile/features/ibadah/asmaul_husna_audio.dart';
import 'package:moeslim_mobile/features/ibadah/asmaul_husna_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  test('seluruh 99 berkas audio MP3 Asmaul Husna offline tersedia dan valid di aset', () {
    expect(allAsmaulHusnaAssetPaths, hasLength(99));
    for (var i = 1; i <= 99; i++) {
      final path = asmaulHusnaAssetPath(i);
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Berkas $path harus ada di aset');
      expect(file.lengthSync(), greaterThan(1500), reason: 'Berkas $path terlalu kecil/kosong');
    }
  });

  testWidgets('Asmaul Husna mendukung putar satuan, putar semua 1-99, kontrol audio, dan audio kuis', (
    tester,
  ) async {
    final engine = FakeAsmaulAudioEngine();
    await pumpApp(tester, asmaulAudioEngine: engine);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const AsmaulHusnaPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('asmaul-audio-card')), findsOneWidget);
    expect(find.byKey(const Key('asmaul-play-all')), findsOneWidget);

    // 1. Putar satuan (Ar-Rahman #1)
    await tester.tap(find.byKey(const Key('asmaul-play-1')));
    await tester.pumpAndSettle();
    expect(engine.playedAssets, contains('assets/audio/asmaul_husna/01.mp3'));
    expect(find.byKey(const Key('asmaul-audio-now')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('asmaul-audio-now'))).data, '#1 Ar-Rahman');

    // Jeda dengan menekan tombol yang sama
    await tester.tap(find.byKey(const Key('asmaul-play-1')));
    await tester.pumpAndSettle();
    expect(engine.pauseCalls, 1);

    // Hentikan agar kembali ke tombol Putar Semua
    await tester.tap(find.byKey(const Key('asmaul-audio-stop')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('asmaul-play-all')), findsOneWidget);

    // 2. Putar Semua (99 nama berurutan)
    await tester.tap(find.byKey(const Key('asmaul-play-all')));
    await tester.pumpAndSettle();
    expect(engine.lastPlaylist, hasLength(99));
    expect(engine.lastPlaylist!.first, 'assets/audio/asmaul_husna/01.mp3');
    expect(engine.lastPlaylist!.last, 'assets/audio/asmaul_husna/99.mp3');

    // Next, Repeat, dan Speed
    await tester.tap(find.byKey(const Key('asmaul-audio-next')));
    await tester.pumpAndSettle();
    expect(engine.lastSeekIndex, 1);
    expect(tester.widget<Text>(find.byKey(const Key('asmaul-audio-now'))).data, '#2 Ar-Rahim');

    await tester.tap(find.byKey(const Key('asmaul-audio-repeat')));
    await tester.pumpAndSettle();
    expect(engine.repeatMode, AsmaulRepeatMode.one);

    await tester.tap(find.byKey(const Key('asmaul-audio-speed')));
    await tester.pumpAndSettle();
    expect(engine.speed, 1.25);

    // 3. Kuis Hafalan juga punya tombol audio pelafalan
    await tester.tap(find.text('Kuis Hafalan'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('asmaul-quiz-play')), findsOneWidget);
    await tester.tap(find.byKey(const Key('asmaul-quiz-play')));
    await tester.pumpAndSettle();
    expect(engine.playedAssets.last, 'assets/audio/asmaul_husna/01.mp3');
  });

  testWidgets('AsmaulHusnaPage dengan pemutar audio aman di layar 360px, fontScale 1.3, dan mode gelap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, fontScale: 1.3, themeMode: AppThemeMode.dark),
    );
    final engine = FakeAsmaulAudioEngine();
    await pumpApp(tester, store: store, asmaulAudioEngine: engine);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const AsmaulHusnaPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('asmaul-play-all')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
