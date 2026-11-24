import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/tasbih_page.dart';
import 'package:moeslim_mobile/features/ibadah/tracker_page.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
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

  testWidgets('doa harian & aktivitas: daftar lengkap, filter kategori, pencarian & detail', (tester) async {
    await pumpApp(tester);
    await open(tester, const DoaListPage());
    expect(find.text('Menampilkan 229 doa'), findsOneWidget);
    final chipBar = find.descendant(of: find.byKey(const Key('doa-categories')), matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(find.text('Doa Terkait Masjid').hitTestable(), 150, scrollable: chipBar);
    await tester.tap(find.text('Doa Terkait Masjid'));
    await tester.pumpAndSettle();
    expect(find.text('Menampilkan 3 doa'), findsOneWidget);
    expect(find.text('Doa Masuk Masjid'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('doa-cat-all')).hitTestable(), -150, scrollable: chipBar);
    await tester.tap(find.byKey(const Key('doa-cat-all')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('doa-search')), 'Naik Kendaraan');
    await tester.pumpAndSettle();
    expect(find.text('Doa Naik Kendaraan'), findsOneWidget);
    await tester.tap(find.text('Doa Naik Kendaraan'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Doa'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Bacaan Latin'), 150, scrollable: find.byType(Scrollable).last);
    expect(find.text('Bacaan Latin'), findsOneWidget);
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
    await tester.tap(find.byKey(const Key('tab-Doa Al-Qur\'an')));
    await tester.pumpAndSettle();
    expect(find.textContaining('QS. Al-Baqarah'), findsWidgets);
    await tester.enterText(find.byKey(const Key('doa-search')), 'kebaikan di dunia');
    await tester.pumpAndSettle();
    expect(find.text('QS. Al-Baqarah: 200–201'), findsOneWidget);
    await tester.tap(find.text('QS. Al-Baqarah: 200–201'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Doa'), findsOneWidget);
  });

  testWidgets('doa: hapus pencarian, reset filter, loading, error & skala teks 200%', (tester) async {
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

    // Clear search icon restores all 229 daily duas.
    await tester.enterText(find.byKey(const Key('doa-search')), 'tidur');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('doa-search-clear')), findsOneWidget);
    await tester.tap(find.byKey(const Key('doa-search-clear')));
    await tester.pumpAndSettle();
    expect(find.text('Menampilkan 229 doa'), findsOneWidget);

    // Empty filtered daily state offers Reset filter.
    await tester.enterText(find.byKey(const Key('doa-search')), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('Doa tidak ditemukan'), findsOneWidget);
    final resetDaily = find.byKey(const Key('doa-reset-filter'));
    await tester.ensureVisible(resetDaily);
    await tester.pumpAndSettle();
    await tester.tap(resetDaily);
    await tester.pumpAndSettle();
    expect(find.text('Menampilkan 229 doa'), findsOneWidget);

    // Quranic empty filtered state offers Hapus pencarian.
    final quranTab = find.byKey(const Key('tab-Doa Al-Qur\'an'));
    await tester.ensureVisible(quranTab);
    await tester.pumpAndSettle();
    await tester.tap(quranTab);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('doa-search')), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('Doa tidak ditemukan'), findsOneWidget);
    final resetQuran = find.byKey(const Key('doa-search-reset'));
    await tester.ensureVisible(resetQuran);
    await tester.pumpAndSettle();
    await tester.tap(resetQuran);
    await tester.pumpAndSettle();
    expect(find.textContaining('QS. Al-Baqarah'), findsWidgets);
  });

  testWidgets('doa: loading & skala teks 200% tanpa overflow', (tester) async {
    final completer = Completer<List<DailyDua>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranSourceProvider.overrideWithValue(FakeQuranSource()),
          dailyDuasProvider.overrideWith((ref) => completer.future),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: const DoaListPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pump();
    expect(find.text('Memuat kumpulan doa harian...'), findsOneWidget);
    completer.complete(const [
      DailyDua(
        id: 1,
        group: 'Doa Harian & Aktivitas Sehari-hari',
        title: 'Doa Sebelum Tidur',
        arabic: 'بِسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        latin: 'Bismika Allahumma amutu wa ahya',
        translation: 'Dengan nama-Mu ya Allah aku mati dan hidup.',
        source: 'HR. Bukhari',
      ),
    ]);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Doa Sebelum Tidur'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Doa Sebelum Tidur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('doa: status gagal memuat menampilkan penjelasan & tombol coba lagi', (tester) async {
    var fail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranSourceProvider.overrideWithValue(FakeQuranSource()),
          dailyDuasProvider.overrideWith((ref) async {
            if (fail) throw StateError('Berkas doa rusak');
            return const [];
          }),
        ],
        child: const MaterialApp(home: DoaListPage()),
      ),
    );
    await tester.pumpAndSettle();
    final retryBtn = find.text('Coba lagi');
    await tester.scrollUntilVisible(
      retryBtn,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat daftar doa harian.'), findsOneWidget);
    expect(retryBtn, findsOneWidget);
    fail = false;
    await tester.tap(retryBtn);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Data doa belum tersedia'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Data doa belum tersedia'), findsOneWidget);
  });

  testWidgets('Doa & Dzikir memuat tab Dzikir Terpandu beserta pengingat dzikir kontekstual', (tester) async {
    await pumpApp(tester);
    await open(tester, const DoaListPage());
    expect(find.byKey(const Key('tab-Dzikir Terpandu')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Dzikir Terpandu')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dzikir-contextual-sunnah-card')), findsOneWidget);
    expect(find.byKey(const Key('tab-Dzikir Pagi')), findsOneWidget);
    expect(find.byKey(const Key('tab-Dzikir Petang')), findsOneWidget);
    expect(find.byKey(const Key('tab-Ba\'da Salat')), findsOneWidget);
    expect(find.byKey(const Key('guided-dzikir-progress-text')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
