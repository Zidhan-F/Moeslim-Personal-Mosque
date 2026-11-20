import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

final manifest = AudioManifest.fromJson({
  'version': 1,
  'recitations': [
    {
      'id': 'a-bayyati',
      'qari': 'Qari A',
      'naghom': 'bayyati',
      'base_url': 'https://cdn.test/a/bayyati',
      'license': 'Izin',
      'attribution': 'Qari A',
      'surahs': [1],
    },
    {
      'id': 'a-rast',
      'qari': 'Qari A',
      'naghom': 'rast',
      'base_url': 'https://cdn.test/a/rast',
      'license': 'Izin',
      'attribution': 'Qari A',
      'surahs': [1],
    },
  ],
});

Future<void> openFatihah(WidgetTester tester) async {
  await tester.tap(find.text('Quran').last);
  await tester.pump();
  await tester.tap(find.text('Al-Fatihah'));
  await tester.pumpAndSettle();
}

ChoiceChip chip(WidgetTester tester, String slug) => tester.widget<ChoiceChip>(find.byKey(Key('naghom-$slug')));

void main() {
  testWidgets('7 pilihan irama; yang belum ada rekamannya nonaktif', (tester) async {
    await pumpApp(tester, manifest: manifest);
    await openFatihah(tester);
    for (final s in naghomStyles) {
      expect(find.byKey(Key('naghom-${s.slug}')), findsOneWidget);
    }
    expect(chip(tester, 'rast').onSelected, isNotNull);
    expect(chip(tester, 'hijaz').onSelected, isNull);
  });

  testWidgets('putar surah dengan irama terpilih lalu ganti irama melanjutkan ayat yang sama', (tester) async {
    final engine = FakeAudioEngine();
    final store = InMemoryStore();
    await pumpApp(tester, manifest: manifest, engine: engine, store: store);
    await openFatihah(tester);
    expect(chip(tester, 'bayyati').selected, isTrue); // irama pertama yang tersedia

    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.length, 7);
    expect(engine.calls.single.first.toString(), 'https://cdn.test/a/bayyati/001001.mp3');

    await tester.tap(find.byKey(const Key('naghom-rast')));
    await tester.pumpAndSettle();
    expect(engine.calls.length, 2);
    expect(engine.calls.last.first.toString(), 'https://cdn.test/a/rast/001001.mp3');
    expect(await AudioPreferenceRepository(store).naghom(), 'rast');
  });

  testWidgets('putar satu ayat & audio offline dipakai bila sudah diunduh', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine, offline: FakeOfflineAudio({'001003.mp3'}));
    await openFatihah(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('play-ayah-3')),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('play-ayah-3')));
    await tester.pumpAndSettle();
    expect(engine.calls.single, [Uri.file('/local/001003.mp3')]);
  });

  testWidgets('ulang ayat mengatur mode repeat', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openFatihah(tester);
    await tester.tap(find.byKey(const Key('repeat-ayah')));
    await tester.pumpAndSettle();
    expect(engine.repeat, isTrue);
  });

  testWidgets('tanpa katalog: pesan rekaman belum tersedia, semua irama nonaktif', (tester) async {
    await pumpApp(tester);
    await openFatihah(tester);
    expect(find.byKey(const Key('no-audio')), findsOneWidget);
    expect(chip(tester, 'bayyati').onSelected, isNull);
  });

  testWidgets('contoh audio di modul Naghom memutar irama itu', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await tester.tap(find.text('Quran').last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('naghom-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rast'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('naghom-sample')));
    await tester.pumpAndSettle();
    expect(engine.calls.single, [Uri.parse('https://cdn.test/a/rast/001001.mp3')]);
  });
}
