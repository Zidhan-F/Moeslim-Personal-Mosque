import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'package:moeslim_mobile/features/quran/naghom_pages.dart';

import 'helpers.dart';

final toneBars = find.byWidgetPredicate(
  (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('tone-bar-'),
);

final manifest = AudioManifest.fromJson({
  'version': 1,
  'recitations': [
    {
      'id': 'm',
      'qari': 'Qari M',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/m',
      'license': 'L',
      'attribution': 'A',
      'surahs': 'all',
    },
    {
      'id': 'r',
      'qari': 'Qari R',
      'naghom': 'rast',
      'base_url': 'https://cdn.test/r',
      'license': 'L',
      'attribution': 'A',
      'surahs': [1, 112],
    },
  ],
});

void main() {
  testWidgets('Beranda menampilkan 7 Irama sebagai fitur andalan di bagian atas', (tester) async {
    await pumpApp(tester, manifest: manifest);
    final hero = find.byKey(const Key('naghom-hero'));
    expect(hero, findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('7 Irama Al-Qur\'an')), findsOneWidget);
    // Hero berada di atas kartu jadwal sholat
    expect(tester.getTopLeft(hero).dy, lessThan(tester.getTopLeft(find.byKey(const Key('countdown'))).dy));
    for (final s in naghomStyles) {
      await tester.scrollUntilVisible(
        find.byKey(Key('hero-${s.slug}')),
        120,
        scrollable: find.descendant(of: hero, matching: find.byType(Scrollable)),
      );
    }
  });

  testWidgets('detail irama: deskripsi resmi, visual tingkat nada, dengarkan surah dengan irama itu', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    final hero = find.byKey(const Key('naghom-hero'));
    await tester.scrollUntilVisible(
      find.byKey(const Key('hero-rast')),
      120,
      scrollable: find.descendant(of: hero, matching: find.byType(Scrollable)),
    );
    await tester.ensureVisible(find.byKey(const Key('hero-rast')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hero-rast')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('naghom-summary'))).data,
      'Memiliki 6 tingkat nada yang ringan dan cepat, sering dipakai untuk azan atau imam shalat.',
    );
    expect(find.descendant(of: find.byType(NaghomDetailPage), matching: toneBars), findsNWidgets(6));

    await tester.ensureVisible(find.byKey(const Key('listen-with-naghom')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('listen-with-naghom')));
    await tester.pumpAndSettle();
    expect(find.text('Al-Ikhlas'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsNothing); // hanya surah yang tersedia untuk Rast
    await tester.tap(find.text('Al-Ikhlas'));
    await tester.pumpAndSettle();

    expect(tester.widget<ChoiceChip>(find.byKey(const Key('naghom-rast'))).selected, isTrue);
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.first.toString(), 'https://cdn.test/r/112001.mp3');
  });

  testWidgets('Sika memakai istilah "jenis nada" sesuai materi', (tester) async {
    await pumpApp(tester, manifest: manifest);
    final hero = find.byKey(const Key('naghom-hero'));
    await tester.scrollUntilVisible(
      find.byKey(const Key('hero-sika')),
      120,
      scrollable: find.descendant(of: hero, matching: find.byType(Scrollable)),
    );
    await tester.ensureVisible(find.byKey(const Key('hero-sika')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hero-sika')));
    await tester.pumpAndSettle();
    expect(find.text('4 jenis nada'), findsWidgets);
    expect(find.descendant(of: find.byType(NaghomDetailPage), matching: toneBars), findsNWidgets(4));
  });
}
