import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

final manifest = AudioManifest.fromJson({
  'version': 1,
  'recitations': [
    {
      'id': 'm',
      'qari': 'Qari M',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/m',
      'license': 'Izin',
      'attribution': 'Qari M',
      'surahs': 'all',
    },
    {
      'id': 'r',
      'qari': 'Qari R',
      'naghom': 'rast',
      'base_url': 'https://cdn.test/r',
      'license': 'Izin',
      'attribution': 'Qari R',
      'surahs': [1],
    },
  ],
});

Future<void> openSurah(WidgetTester tester, String name) async {
  await tester.tap(find.text("Al-Qur'an").last);
  await tester.pump();
  await tester.scrollUntilVisible(find.text(name), 300, scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

ChoiceChip chip(WidgetTester t, String key) => t.widget<ChoiceChip>(find.byKey(Key('naghom-$key')));

void main() {
  testWidgets('irama didahulukan sebagai default; Murattal di urutan terakhir', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    expect(chip(tester, 'rast').selected, isTrue);
    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
    expect((chips.first.label as Text).data, 'Bayyati');
    for (final key in [murattalKey, ...naghomStyles.map((n) => n.slug)]) {
      expect(find.byKey(Key('naghom-$key')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.first.toString(), 'https://cdn.test/r/001001.mp3');
  });

  testWidgets('pindah dari Murattal ke irama Rast melanjutkan ayat yang sama', (tester) async {
    final engine = FakeAudioEngine();
    final store = InMemoryStore();
    await AudioPreferenceRepository(store).save(naghom: 'murattal', recitationId: 'm');
    await pumpApp(tester, manifest: manifest, engine: engine, store: store);
    await openSurah(tester, 'Al-Fatihah');
    expect(chip(tester, 'murattal').selected, isTrue);
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('naghom-rast')));
    await tester.pumpAndSettle();
    expect(engine.calls.last.first.toString(), 'https://cdn.test/r/001001.mp3');
    expect(await AudioPreferenceRepository(store).naghom(), 'rast');
  });

  testWidgets('surah tanpa rekaman irama tetap bisa diputar dengan Murattal', (tester) async {
    final engine = FakeAudioEngine();
    final store = InMemoryStore();
    await AudioPreferenceRepository(store).save(naghom: 'rast', recitationId: 'r'); // rast tak ada di surah 114
    await pumpApp(tester, manifest: manifest, engine: engine, store: store);
    await openSurah(tester, 'An-Nas');
    expect(chip(tester, 'murattal').selected, isTrue);
    expect(chip(tester, 'rast').onSelected, isNull);
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.length, 6);
    expect(engine.calls.single.last.toString(), 'https://cdn.test/m/114006.mp3');
  });
}
