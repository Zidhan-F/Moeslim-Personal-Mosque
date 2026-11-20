import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'package:moeslim_mobile/features/ibadah/ibadah_page.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';

import 'helpers.dart';

void main() {
  testWidgets('Beranda menampilkan sholat berikutnya dan countdown', (tester) async {
    await pumpApp(tester);
    expect(find.text('Menuju Ashar'), findsOneWidget);
    final countdown = tester.widget<Text>(find.byKey(const Key('countdown')));
    expect(countdown.data, matches(RegExp(r'^03:\d\d:\d\d lagi$')));
    expect(find.textContaining('Jakarta'), findsWidgets);
  });

  testWidgets('setelah Isya, sholat berikutnya adalah Subuh besok', (tester) async {
    await pumpApp(tester, now: DateTime.utc(2025, 1, 1, 14, 0)); // 21:00 WIB
    expect(find.text('Menuju Subuh'), findsOneWidget);
  });

  testWidgets('navigasi lima menu sesuai desain', (tester) async {
    await pumpApp(tester);
    for (final label in ['Beranda', "Al-Qur'an", 'Ibadah', 'Masjid', 'Profil']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    expect(find.text('Al-Fatihah'), findsOneWidget);

    await tester.tap(find.text('Ibadah').last);
    await tester.pumpAndSettle();
    expect(find.text('Ibadah Harian'), findsOneWidget);

    await tester.tap(find.text('Masjid').last);
    await tester.pumpAndSettle();
    expect(find.text('Masjid Diikuti'), findsOneWidget);

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Moeslim Mosque'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Moeslim Mosque'), findsOneWidget);
  });

  testWidgets('tasbih menghitung dan menyimpan ke penyimpanan lokal', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store);
    await tester.tap(find.text('Ibadah').last);
    await tester.pump();
    await tester.tap(find.text('Dzikir & Tasbih'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('tasbih-button')));
      await tester.pump();
    }
    expect(tester.widget<Text>(find.byKey(const Key('tasbih-count'))).data, '3');
    expect(await TasbihRepository(store).count('tasbih'), 3);
  });

  testWidgets('kiblat menampilkan sudut tanpa sensor', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Ibadah').last);
    await tester.pump();
    final tile = find.descendant(of: find.byType(IbadahPage), matching: find.text('Arah Kiblat'));
    await tester.scrollUntilVisible(
      tile,
      200,
      scrollable: find.descendant(of: find.byType(IbadahPage), matching: find.byType(Scrollable)),
    );
    await tester.ensureVisible(tile); // hindari tertutup bilah navigasi bawah
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.byType(QiblaPage), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('qibla-bearing'))).data, startsWith('295,'));
    expect(find.textContaining('Sensor kompas tidak tersedia'), findsOneWidget);
  });

  testWidgets('ganti kota di pengaturan menyimpan dan mengubah beranda', (tester) async {
    final store = InMemoryStore();
    await SettingsRepository(store)
        .save(PersonalSettings.defaults.copyWith(location: indonesianCities.firstWhere((c) => c.name == 'Makassar')));
    await pumpApp(tester, store: store);
    expect(find.textContaining('Makassar'), findsWidgets);
  });
}
