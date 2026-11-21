import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:moeslim_mobile/features/home/home_page.dart';
import 'package:moeslim_mobile/features/prayer/prayer_page.dart';
import 'package:moeslim_mobile/ui/components.dart';
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
    expect(
      find.descendant(of: find.byKey(const Key('row-Subuh')), matching: find.byIcon(MoeslimIcons.check)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byKey(const Key('row-Ashar')), matching: find.byIcon(MoeslimIcons.play)),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('weekly-schedule')));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsOneWidget);
  });

  testWidgets('navigasi bawah & Menu Cepat memakai ikon sesuai labelnya', (tester) async {
    await pumpApp(tester);
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    final byLabel = {
      for (final d in navBar.destinations.cast<NavigationDestination>()) d.label: (d.icon as Icon).icon,
    };
    expect(byLabel['Beranda'], MoeslimIcons.beranda);
    expect(byLabel["Al-Qur'an"], MoeslimIcons.quranTerbuka);
    expect(byLabel['Ibadah'], MoeslimIcons.zikr);
    expect(byLabel['Masjid'], MoeslimIcons.masjid);
    expect(byLabel['Profil'], MoeslimIcons.profil);

    final tiles = tester.widgetList<MenuTile>(find.byType(MenuTile));
    final tileByLabel = {for (final t in tiles) t.label: t.tile};
    expect(tileByLabel["Al-Qur'an"], BrandTile.alquran);
    expect(tileByLabel['Doa & Dzikir'], BrandTile.doaDzikir);
    expect(tileByLabel['Jadwal Salat'], BrandTile.jadwalSholat);
    expect(tileByLabel['Arah Kiblat'], BrandTile.arahKiblat);
    expect(tileByLabel['Kalender Hijriah'], BrandTile.kalenderHijriah);
    expect(tileByLabel['Catatan Ibadah'], BrandTile.catatanIbadah);
    expect(tileByLabel['Tasbih'], BrandTile.tasbih);
    expect(tileByLabel['Masjid Diikuti'], BrandTile.masjid);
  });

  testWidgets('ayat harian di bagian bawah Beranda tampil lengkap tanpa terpotong ellipsis', (tester) async {
    final day = DateTime.now().difference(DateTime(2024)).inDays;
    final (s, a) = dailyAyahRefs[day % dailyAyahRefs.length];
    const longTranslation =
        'Janganlah kamu bersikap lemah, dan janganlah (pula) kamu bersedih hati, '
        'padahal kamulah orang-orang yang paling tinggi (derajatnya), jika kamu orang-orang yang beriman.';
    final fakeAyat = [
      for (var i = 1; i <= a; i++) Ayah(s, i, 'آية $i', translation: i == a ? longTranslation : 'Ayat $i'),
    ];
    await pumpApp(tester, quran: FakeQuranSource({s: fakeAyat}));
    await tester.pumpAndSettle();

    final listView = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.byKey(const Key('daily-ayah')), 200, scrollable: listView);
    await tester.pumpAndSettle();

    final ayahCard = find.byKey(const Key('daily-ayah'));
    expect(ayahCard, findsOneWidget);
    final quoteFinder = find.descendant(of: ayahCard, matching: find.text('"$longTranslation"'));
    expect(quoteFinder, findsOneWidget);
    final quoteWidget = tester.widget<Text>(quoteFinder);
    expect(quoteWidget.maxLines, isNull);
    expect(quoteWidget.overflow, isNot(TextOverflow.ellipsis));
  });
}
