import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/quran/audio/audio_providers.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

final manifest = AudioManifest.fromJson({
  'version': 1,
  'recitations': [
    {
      'id': 'a',
      'qari': 'Qari A',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/a',
      'license': 'Izin',
      'attribution': 'Qari A',
      'surahs': 'all',
    },
    {
      'id': 'b',
      'qari': 'Qari B',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/b',
      'license': 'Izin',
      'attribution': 'Qari B',
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

ChoiceChip chip(WidgetTester t, String id) => t.widget<ChoiceChip>(find.byKey(Key('qari-$id')));

void main() {
  testWidgets('qari pertama jadi default dan memutar surah dari ayat 1', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    expect(tester.widget<Text>(find.byKey(const Key('now-playing'))).data, 'Qari A');
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.first.toString(), 'https://cdn.test/a/001001.mp3');
    expect(engine.calls.single.length, 7);
  });

  testWidgets('ganti qari saat memutar melanjutkan ayat yang sama & tersimpan', (tester) async {
    final engine = FakeAudioEngine();
    final store = InMemoryStore();
    await pumpApp(tester, manifest: manifest, engine: engine, store: store);
    await openSurah(tester, 'Al-Fatihah');
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    await openAudioSheet(tester);
    expect(chip(tester, 'a').selected, isTrue);
    await tester.tap(find.byKey(const Key('qari-b')));
    await tester.pumpAndSettle();
    expect(engine.calls.last.first.toString(), 'https://cdn.test/b/001001.mp3');
    expect(await AudioPreferenceRepository(store).recitationId(), 'b');
  });

  testWidgets('qari pilihan yang tidak mencakup surah → qari lain dipakai', (tester) async {
    final engine = FakeAudioEngine();
    final store = InMemoryStore();
    await AudioPreferenceRepository(store).save(recitationId: 'b'); // b hanya surah 1
    await pumpApp(tester, manifest: manifest, engine: engine, store: store);
    await openSurah(tester, 'An-Nas');
    await openAudioSheet(tester);
    expect(find.byKey(const Key('qari-b')), findsNothing);
    expect(chip(tester, 'a').selected, isTrue);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.last.toString(), 'https://cdn.test/a/114006.mp3');
  });

  testWidgets('putar dari ayat 3 memutar berurutan sampai akhir surah & pakai audio offline', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine, offline: FakeOfflineAudio({'001003.mp3'}));
    await openSurah(tester, 'Al-Fatihah');
    await tester.scrollUntilVisible(
      find.byKey(const Key('play-ayah-3')),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('play-ayah-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-ayah-3')));
    await tester.pumpAndSettle();
    expect(engine.calls.single.first, Uri.file('/local/001003.mp3'));
    expect(engine.calls.single.length, 5);
    expect(engine.calls.single.last.toString(), 'https://cdn.test/a/001007.mp3');
  });

  testWidgets('tombol putar surah di bar bawah presisi di tengah horizontal', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    final barCenter = tester.getCenter(find.byKey(const Key('player-bar')));
    final playCenter = tester.getCenter(find.byKey(const Key('play-surah')));
    expect((playCenter.dx - barCenter.dx).abs(), lessThanOrEqualTo(0.5));
  });

  testWidgets('tombol putar surah tetap memutar seluruh surah setelah ganti qari saat dijeda', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    // Jeda pemutaran lalu ganti qari ke Qari B
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    await openAudioSheet(tester);
    await tester.tap(find.byKey(const Key('qari-b')));
    await tester.pumpAndSettle();
    // Putar lagi harus memuat surah penuh dari Qari B, bukan melanjutkan antrean Qari A
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.last.first.toString(), 'https://cdn.test/b/001001.mp3');
    expect(engine.calls.last.length, 7);
  });

  testWidgets('setelah selesai memutar, tombol putar surah memutar ulang seluruh surah', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    engine.emitCompleted();
    await tester.pumpAndSettle();
    expect(engine.calls.length, 1);
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.length, 2);
    expect(engine.calls.last.first.toString(), 'https://cdn.test/a/001001.mp3');
    expect(engine.calls.last.length, 7);
  });

  testWidgets('setelah antrean 1 ayat, tombol putar surah tetap memutar seluruh ayat surah', (tester) async {
    final engine = FakeAudioEngine();
    final container = await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    await container.read(quranPlayerProvider.notifier).playAyah(1);
    await tester.pumpAndSettle();
    expect(engine.calls.last.length, 1);
    // Jeda lalu tekan tombol putar surah di bar bawah -> harus memuat penuh 7 ayat
    await engine.pause();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-surah')));
    await tester.pumpAndSettle();
    expect(engine.calls.last.first.toString(), 'https://cdn.test/a/001001.mp3');
    expect(engine.calls.last.length, 7);
  });

  testWidgets('ulang ayat mengatur mode repeat', (tester) async {
    final engine = FakeAudioEngine();
    await pumpApp(tester, manifest: manifest, engine: engine);
    await openSurah(tester, 'Al-Fatihah');
    await openAudioSheet(tester);
    await tester.tap(find.byKey(const Key('repeat-ayah')));
    await tester.pumpAndSettle();
    expect(engine.repeat, isTrue);
  });

  testWidgets('tanpa katalog: pesan rekaman belum tersedia', (tester) async {
    await pumpApp(tester);
    await openSurah(tester, 'Al-Fatihah');
    await openAudioSheet(tester);
    expect(find.byKey(const Key('no-audio')), findsOneWidget);
  });
}
