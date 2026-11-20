import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

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
    await tester.tap(find.byIcon(Icons.bookmark_border).first);
    await tester.pumpAndSettle();
    expect(await QuranProgressRepository(store).bookmarks(), [const AyahRef(1, 1)]);
  });

  testWidgets('modul naghom: 7 irama dan tandai selesai', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store);
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('naghom-entry')));
    await tester.pumpAndSettle();
    expect(find.text('Bayyati'), findsOneWidget);
    expect(find.textContaining('0 dari 7'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Rast'), 150, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Rast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rast'));
    await tester.pumpAndSettle();
    expect(find.textContaining('6 tingkat'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Tandai sudah dipelajari'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tandai sudah dipelajari'));
    await tester.pumpAndSettle();
    expect(await NaghomProgressRepository(store).completed(), {'rast'});
  });
}
