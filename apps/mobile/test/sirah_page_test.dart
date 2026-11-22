import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/sirah_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

Future<void> openSirah(WidgetTester tester, {InMemoryStore? store}) async {
  await pumpApp(tester, store: store);
  tester.state<NavigatorState>(find.byType(Navigator).first).push(
        MaterialPageRoute(builder: (_) => const SirahPage()),
      );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tab Kisah 25 Nabi berisi satu bab per nabi', (tester) async {
    await openSirah(tester);
    await tester.tap(find.byKey(const Key('tab-Kisah 25 Nabi')));
    await tester.pumpAndSettle();
    expect(find.textContaining('25 nabi dan rasul'), findsOneWidget);
    expect(find.text('Nabi Adam AS'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Nabi Muhammad SAW'), 400, scrollable: find.byType(Scrollable).last);
    expect(find.text('Nabi Muhammad SAW'), findsOneWidget);
  });

  testWidgets('detail bab: subjudul, hikmah, rujukan & lanjut ke bab berikutnya', (tester) async {
    final store = InMemoryStore();
    await openSirah(tester, store: store);
    await tester.tap(find.byKey(const Key('tab-Kisah 25 Nabi')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nabi Adam AS'));
    await tester.pumpAndSettle();

    expect(find.text('Diajari Nama-nama'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('sirah-next')), 400, scrollable: find.byType(Scrollable).last);
    expect(find.text('Hikmah & Keteladanan'), findsOneWidget);
    expect(find.textContaining('Rujukan:'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sirah-next')));
    await tester.pumpAndSettle();
    expect(find.text('Nabi Idris AS'), findsOneWidget);
    expect(await SirahRepository(store).lastReadChapterId(), 'nabi_02_idris');
  });

  testWidgets('pencarian lintas isi bab', (tester) async {
    await openSirah(tester);
    await tester.tap(find.byKey(const Key('tab-Biografi Sahabat')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sirah-search')), 'Dzatun Nithaqain');
    await tester.pumpAndSettle();
    expect(find.text("Asma' binti Abu Bakar RA"), findsOneWidget);
    expect(find.text('Abu Bakar Ash-Shiddiq RA'), findsNothing);
  });
}
