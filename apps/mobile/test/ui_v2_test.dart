import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/prayer/prayer_page.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  testWidgets('onboarding: 3 langkah dengan pilihan kota, Mulai Sekarang → Beranda', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store, showOnboarding: true);
    expect(find.text('Moeslim PM'), findsWidgets);
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-city')), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    final s = await SettingsRepository(store).load();
    expect(s.onboardingDone, isTrue);
    expect(s.location.name, 'Jakarta');
    expect(find.byKey(const Key('greeting')), findsOneWidget);
  });

  testWidgets('onboarding dapat dilewati', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store, showOnboarding: true);
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('countdown')), findsOneWidget);
  });

  testWidgets('sapaan memakai nama panggilan dari Profil', (tester) async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(PersonalSettings.defaults.copyWith(displayName: 'Ahmad Fauzi'));
    await pumpApp(tester, store: store);
    expect(find.text('Ahmad Fauzi'), findsOneWidget);
    expect(find.text("Assalamu'alaikum"), findsOneWidget);
  });

  testWidgets('Jadwal Salat: menuju Ashar, Subuh & Dzuhur sudah lewat, jadwal 7 hari', (tester) async {
    await pumpApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerPage()));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('next-prayer'))).data, 'Ashar');
    expect(find.descendant(of: find.byKey(const Key('row-Subuh')), matching: find.byIcon(Icons.check)), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const Key('row-Ashar')), matching: find.byIcon(Icons.play_arrow)),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('weekly-schedule')));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsOneWidget);
  });
}
