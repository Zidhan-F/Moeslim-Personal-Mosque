import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/quran/quran_page.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
import 'package:moeslim_mobile/features/quran/audio/audio_providers.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('largest surah parses with translations and tajweed in background', () async {
    final ayat = await AssetQuranSource().load(2);
    expect(ayat, hasLength(286));
    expect(ayat!.first.surah, 2);
    expect(ayat.last.number, 286);
    expect(ayat.first.translation, isNotEmpty);
    expect(ayat.any((a) => a.tajweed.isNotEmpty), isTrue);
  });

  testWidgets('tabs mount on demand and retain their state', (tester) async {
    await pumpApp(tester);
    expect(find.byType(QuranPage, skipOffstage: false), findsNothing);
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    final element = tester.element(find.byType(QuranPage));
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(QuranPage, skipOffstage: false)), same(element));
  });

  testWidgets('home fits a narrow phone with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = InMemoryStore();
    final repo = SettingsRepository(store);
    await repo.save((await repo.load()).copyWith(fontScale: 1.3));
    await pumpApp(tester, store: store);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('prayer times are reused within a day and refreshed at midnight', () async {
    final clock = StreamController<DateTime>();
    final container = ProviderContainer(
      overrides: [storeProvider.overrideWithValue(InMemoryStore()), nowProvider.overrideWith((ref) => clock.stream)],
    );
    final sub = container.listen(prayerStatusProvider, (_, _) {});
    addTearDown(() async {
      sub.close();
      container.dispose();
      await clock.close();
    });
    await container.read(settingsProvider.future);
    clock.add(DateTime.utc(2025, 1, 1, 5));
    await container.read(nowProvider.future);
    await Future<void>.delayed(Duration.zero);
    final first = container.read(prayerStatusProvider).requireValue;
    clock.add(DateTime.utc(2025, 1, 1, 5, 0, 1));
    await Future<void>.delayed(Duration.zero);
    final second = container.read(prayerStatusProvider).requireValue;
    expect(second.today, same(first.today));
    expect(second.remaining, first.remaining - const Duration(seconds: 1));
    clock.add(DateTime.utc(2025, 1, 2, 5));
    await Future<void>.delayed(Duration.zero);
    final nextDay = container.read(prayerStatusProvider).requireValue;
    expect(nextDay.today, isNot(same(first.today)));
    expect(
      nextDay.nextTime,
      computeStatus(await container.read(settingsProvider.future), DateTime.utc(2025, 1, 2, 5)).nextTime,
    );
  });

  test('audio updates retain speed, position and duration', () {
    final state = const PlayerState()
        .copyWith(speed: 1.5, position: const Duration(seconds: 8), duration: const Duration(minutes: 2))
        .copyWith(playing: true);
    expect(state.speed, 1.5);
    expect(state.position, const Duration(seconds: 8));
    expect(state.duration, const Duration(minutes: 2));
  });
}
