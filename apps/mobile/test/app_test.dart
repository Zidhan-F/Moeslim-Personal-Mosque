import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  testWidgets('Beranda menampilkan sholat berikutnya dan countdown', (tester) async {
    await pumpApp(tester);
    expect(find.text('Menuju Ashar'), findsOneWidget);
    final countdown = tester.widget<Text>(find.byKey(const Key('countdown')));
    expect(countdown.data, matches(RegExp(r'^03:\d\d:\d\d$')));
    expect(find.textContaining('Jakarta'), findsWidgets);
  });

  testWidgets('setelah Isya, sholat berikutnya adalah Subuh besok', (tester) async {
    await pumpApp(tester, now: DateTime.utc(2025, 1, 1, 14, 0)); // 21:00 WIB
    expect(find.text('Menuju Subuh'), findsOneWidget);
  });

  testWidgets('navigasi lima menu', (tester) async {
    await pumpApp(tester);
    for (final label in ['Beranda', 'Quran', 'Sholat', 'Ibadah', 'Lainnya']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    await tester.tap(find.text('Quran').last);
    await tester.pump();
    expect(find.text('Al-Fatihah'), findsOneWidget);

    await tester.tap(find.text('Sholat').last);
    await tester.pump();
    expect(find.text('Jadwal Sholat'), findsOneWidget);

    await tester.tap(find.text('Lainnya').last);
    await tester.pump();
    expect(find.text('Moeslim Masjid (pengurus)'), findsOneWidget);
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
    await tester.tap(find.text('Arah Kiblat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('295.'), findsOneWidget);
    expect(find.textContaining('Sensor kompas tidak tersedia'), findsOneWidget);
  });

  testWidgets('ganti kota di pengaturan menyimpan dan mengubah beranda', (tester) async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(location: indonesianCities.firstWhere((c) => c.name == 'Makassar')),
    );
    await pumpApp(tester, store: store);
    expect(find.textContaining('Makassar'), findsWidgets);
  });
}
