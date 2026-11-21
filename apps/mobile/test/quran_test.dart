import 'package:flutter_test/flutter_test.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

import 'package:moeslim_brand/moeslim_brand.dart';

void main() {
  testWidgets('tanpa dataset, surah menampilkan pesan impor sumber resmi', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pump();
    await tester.tap(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();
    expect(find.textContaining('belum tersedia'), findsOneWidget);
  });

  testWidgets('dengan dataset, ayat tampil dan bookmark tersimpan', (tester) async {
    final store = InMemoryStore();
    await pumpApp(
      tester,
      store: store,
      quran: FakeQuranSource({
        1: [
          const Ayah(1, 1, 'نص تجريبي', translation: 'teks uji 1'),
          const Ayah(1, 2, 'نص', translation: 'teks uji 2'),
        ],
      }),
    );
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pump();
    await tester.tap(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();
    expect(find.text('teks uji 1'), findsOneWidget);
    await tester.tap(find.byIcon(MoeslimIcons.penanda).first);
    await tester.pumpAndSettle();
    expect(await QuranProgressRepository(store).bookmarks(), [const AyahRef(1, 1)]);
  });
}
