import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/quran/murottal_page.dart';
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
      'license': 'L',
      'attribution': 'Qari M — uji',
      'surahs': 'all',
    },
  ],
});

void main() {
  testWidgets('tab Juz: 30 juz, membuka surah di ayat awal juz', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store);
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-Juz')));
    await tester.pumpAndSettle();
    expect(find.text('Juz 2'), findsOneWidget);
    expect(find.text('Mulai Al-Baqarah ayat 142'), findsOneWidget);
    await tester.tap(find.byKey(const Key('juz-2')));
    await tester.pumpAndSettle();
    expect(find.text('Al-Baqarah'), findsWidgets);
    expect(find.text('Mushaf'), findsOneWidget);
    expect(await QuranProgressRepository(store).lastRead(), const AyahRef(2, 142));
  });

  testWidgets('tab Surah menampilkan nama Arab; tab Mushaf menampilkan lanjut baca', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    expect(find.text(surahs.first.arabicName), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Mushaf')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('continue-reading')), findsOneWidget);
    expect(find.byKey(const Key('open-murottal')), findsOneWidget);
  });

  testWidgets('Murottal: qari tampil, kecepatan berganti, daftar putar memutar surah', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const MurottalPage()));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('murottal-qari'))).data, 'Qari M');
    await tester.tap(find.byKey(const Key('murottal-speed')));
    await tester.pumpAndSettle();
    expect(engine.speed, 1.25);
    await tester.scrollUntilVisible(
      find.byKey(const Key('playlist-3')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('playlist-3')));
    await tester.pumpAndSettle();
    expect(engine.calls.last.first.toString(), 'https://cdn.test/m/003001.mp3');
    expect(engine.calls.last.length, 200);
  });

  testWidgets('bar mushaf: tombol ayat berikutnya melompat ke ayat selanjutnya', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('next-ayah')));
    await tester.pumpAndSettle();
    expect(engine.calls.last.first.toString(), 'https://cdn.test/m/001002.mp3');
  });
}
