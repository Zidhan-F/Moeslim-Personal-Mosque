import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/tasbih_page.dart';
import 'package:moeslim_mobile/features/ibadah/tracker_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

Future<void> open(WidgetTester tester, Widget page) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  nav.push(MaterialPageRoute(builder: (_) => page));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tasbih: +1, −1, dan target 99 tersimpan', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store);
    await open(tester, const TasbihPage());
    await tester.tap(find.byKey(const Key('tasbih-button')));
    await tester.tap(find.byKey(const Key('tasbih-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tasbih-minus')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('tasbih-count'))).data, '1');
    await tester.scrollUntilVisible(
      find.byKey(const Key('edit-target')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('edit-target')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('99 kali'));
    await tester.pumpAndSettle();
    expect(await TasbihRepository(store).target('tasbih'), 99);
  });

  testWidgets('catatan ibadah: centang salat, tambah halaman tilawah, progres mingguan', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store);
    await open(tester, const TrackerPage());
    expect(tester.widget<Text>(find.byKey(const Key('week-progress'))).data, '0%');
    await tester.tap(find.byKey(const Key('check-subuh')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-page')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('tilawah-pages'))).data, '1 / 20 halaman');
    final today = DateTime.now();
    expect((await TrackerRepository(store).day(today)).contains(TrackerItem.subuh), isTrue);
    expect(tester.widget<Text>(find.byKey(const Key('week-progress'))).data, '2%');
    await tester.tap(find.byKey(const Key('tab-Riwayat')));
    await tester.pumpAndSettle();
    expect(find.text('Subuh'), findsWidgets);
  });

  testWidgets('doa Qur\'ani: daftar dari dataset & pencarian terjemahan', (tester) async {
    await pumpApp(
      tester,
      quran: FakeQuranSource({
        2: [
          for (var i = 1; i <= 286; i++)
            Ayah(2, i, 'نص $i', translation: i == 201 ? 'Ya Tuhan kami, berilah kami kebaikan di dunia' : 'teks $i'),
        ],
      }),
    );
    await open(tester, const DoaListPage());
    expect(find.textContaining('QS. Al-Baqarah'), findsWidgets);
    await tester.enterText(find.byKey(const Key('doa-search')), 'kebaikan di dunia');
    await tester.pumpAndSettle();
    expect(find.text('QS. Al-Baqarah: 200–201'), findsOneWidget);
    await tester.tap(find.text('QS. Al-Baqarah: 200–201'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Doa'), findsOneWidget);
  });
}
