import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:moeslim_mobile/core/profile_photo_service.dart';
import 'package:moeslim_mobile/features/home/home_page.dart';
import 'package:moeslim_mobile/features/prayer/prayer_page.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
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

  testWidgets('navigasi bawah & Menu Cepat hanya menampilkan 4 ikon utama dan Lihat Semua membuka semua fitur', (
    tester,
  ) async {
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

    final tiles = tester.widgetList<MenuTile>(find.byType(MenuTile)).toList();
    expect(tiles, hasLength(4));
    final tileByLabel = {for (final t in tiles) t.label: t.tile};
    expect(tileByLabel, {
      "Al-Qur'an": BrandTile.alquran,
      'Doa & Dzikir': BrandTile.doaDzikir,
      'Arah Kiblat': BrandTile.arahKiblat,
      'Lihat Semua': BrandTile.lihatSemua,
    });

    final lihatSemuaTile = find.byKey(const Key('quick-lihat-semua'));
    await tester.ensureVisible(lihatSemuaTile);
    await tester.pumpAndSettle();
    await tester.tap(lihatSemuaTile);
    await tester.pumpAndSettle();

    expect(find.text('Semua Fitur'), findsOneWidget);
    expect(find.byKey(const Key('feature-jadwal-salat')), findsOneWidget);
    expect(find.byKey(const Key('feature-murottal')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('all-features-search')), 'tasbih');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feature-tasbih')), findsOneWidget);
    await tester.tap(find.byKey(const Key('feature-tasbih')));
    await tester.pumpAndSettle();
    expect(find.text('Dzikir & Tasbih'), findsOneWidget);
  });

  testWidgets('Menu Cepat Al-Qur\'an, Doa & Dzikir, dan Arah Kiblat membuka halaman tujuan yang sesuai', (
    tester,
  ) async {
    await pumpApp(tester);

    final doaTile = find.byKey(const Key('quick-doa-dzikir'));
    await tester.ensureVisible(doaTile);
    await tester.pumpAndSettle();
    await tester.tap(doaTile);
    await tester.pumpAndSettle();
    expect(find.text('Doa & Dzikir'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    final kiblatTile = find.byKey(const Key('quick-arah-kiblat'));
    await tester.ensureVisible(kiblatTile);
    await tester.pumpAndSettle();
    await tester.tap(kiblatTile);
    await tester.pumpAndSettle();
    expect(find.text('Arah Kiblat'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    final quranTile = find.byKey(const Key('quick-alquran'));
    await tester.ensureVisible(quranTile);
    await tester.pumpAndSettle();
    await tester.tap(quranTile);
    await tester.pumpAndSettle();
    expect(find.text('Daftar Surah\nAl-Qur\'an'), findsOneWidget);
  });

  test('koleksi ayat acak Beranda berisi 30 ayat berbeda dari 30 surah dan ayat yang berbeda', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(dailyAyahRefs, hasLength(30));
    expect(dailyAyahRefs.toSet(), hasLength(30));
    expect(dailyAyahRefs.map((e) => e.$1).toSet(), hasLength(30));

    final source = AssetQuranSource();
    final translations = <String>{};
    for (final (s, a) in dailyAyahRefs) {
      final ayat = await source.load(s);
      expect(ayat, isNotNull, reason: 'Surah $s harus tersedia di aset');
      expect(a, lessThanOrEqualTo(ayat!.length), reason: 'Ayat $s:$a di luar batas surah');
      final tr = ayat[a - 1].translation?.trim() ?? '';
      expect(tr, isNotEmpty, reason: 'Terjemahan $s:$a kosong');
      translations.add(tr);
    }
    expect(translations, hasLength(30));
  });

  testWidgets('ayat di bagian paling bawah Beranda tampil lengkap dan berganti acak di 30 ayat berbeda', (
    tester,
  ) async {
    final fakeMap = <int, List<Ayah>>{};
    for (var idx = 0; idx < dailyAyahRefs.length; idx++) {
      final (s, a) = dailyAyahRefs[idx];
      fakeMap[s] = [
        for (var i = 1; i <= a; i++)
          Ayah(
            s,
            i,
            'آية $s:$i',
            translation: i == a
                ? 'Kalimat ayat pilihan nomor ${idx + 1} dari surah ${surahs[s - 1].name} ayat $a yang lengkap.'
                : 'Ayat $i',
          ),
      ];
    }

    await pumpApp(tester, quran: FakeQuranSource(fakeMap));
    await tester.pumpAndSettle();

    final listView = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.byKey(const Key('daily-ayah')), 200, scrollable: listView);
    await tester.pumpAndSettle();

    final ayahCard = find.byKey(const Key('daily-ayah'));
    expect(ayahCard, findsOneWidget);

    // Kartu sunnah/dzikir kontekstual tidak tampil di Beranda utama; kartu ayat berada tepat di bawah Menu Cepat.
    expect(find.byKey(const Key('home-contextual-sunnah-card')), findsNothing);
    final quickMenuTop = tester.getTopLeft(find.byKey(const Key('quick-alquran'))).dy;
    final ayahTop = tester.getTopLeft(ayahCard).dy;
    expect(ayahTop, greaterThan(quickMenuTop));

    final quoteWidget = tester.widget<Text>(find.byKey(const Key('daily-ayah-text')));
    expect(quoteWidget.maxLines, isNull);
    expect(quoteWidget.overflow, isNot(TextOverflow.ellipsis));

    // Verifikasi rotasi otomatis oleh timer mengganti ayat tanpa pengulangan berurutan.
    final firstRef = tester.widget<Text>(find.byKey(const Key('daily-ayah-ref'))).data!;
    await tester.pump(dailyAyahRotationInterval);
    await tester.pumpAndSettle();
    final secondRef = tester.widget<Text>(find.byKey(const Key('daily-ayah-ref'))).data!;
    expect(secondRef, isNot(firstRef));

    // Verifikasi semua 30 ayat berbeda dikunjungi dalam satu siklus acak lewat tombol acak.
    final seenRefs = <String>{firstRef, secondRef};
    String prevRef = secondRef;
    for (var step = 0; step < 28; step++) {
      await tester.tap(find.byKey(const Key('shuffle-ayah')));
      await tester.pumpAndSettle();
      final nextRef = tester.widget<Text>(find.byKey(const Key('daily-ayah-ref'))).data!;
      expect(nextRef, isNot(prevRef));
      seenRefs.add(nextRef);
      prevRef = nextRef;
    }
    expect(seenRefs, hasLength(30));
  });

  test('koleksi kalimat pembuka Beranda memiliki 30 variasi unik ID dan EN tanpa em-dash', () {
    expect(greetingBlessingPhrases, hasLength(30));
    expect(greetingBlessingPhrases.map((p) => p.$1).toSet(), hasLength(30));
    expect(greetingBlessingPhrases.map((p) => p.$2).toSet(), hasLength(30));
    for (final (id, en) in greetingBlessingPhrases) {
      expect(id.trim(), isNotEmpty);
      expect(en.trim(), isNotEmpty);
      expect(id.contains('\u2014'), isFalse);
      expect(en.contains('\u2014'), isFalse);
    }
  });

  testWidgets('kalimat pembuka Beranda dipilih acak 1x saat aplikasi dibuka dan tidak berubah saat pindah tab', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    final firstText = tester.widget<Text>(find.byKey(const Key('greeting-blessing'))).data!;
    expect(greetingBlessingPhrases.map((p) => p.$1), contains(firstText));

    // Pindah ke tab lain lalu kembali ke Beranda: kalimat harus tetap sama.
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();

    // Tunggu beberapa detik (melebihi rotasi ayat): kalimat pembuka tetap tidak berubah.
    await tester.pump(dailyAyahRotationInterval * 2);
    await tester.pumpAndSettle();
    final afterReturnText = tester.widget<Text>(find.byKey(const Key('greeting-blessing'))).data!;
    expect(afterReturnText, equals(firstText));

    // Simulasi dua kali buka aplikasi baru dengan seed acak berbeda -> memilih variasi berbeda.
    final launchA = ProviderContainer(
      overrides: [greetingBlessingRandomProvider.overrideWithValue(math.Random(1))],
    );
    final launchB = ProviderContainer(
      overrides: [greetingBlessingRandomProvider.overrideWithValue(math.Random(42))],
    );
    addTearDown(launchA.dispose);
    addTearDown(launchB.dispose);

    final idxA = launchA.read(sessionGreetingBlessingIndexProvider);
    final idxB = launchB.read(sessionGreetingBlessingIndexProvider);
    expect(idxA, inInclusiveRange(0, 29));
    expect(idxB, inInclusiveRange(0, 29));
    expect(idxA, isNot(idxB));
    expect(launchA.read(sessionGreetingBlessingIndexProvider), equals(idxA));
  });

  testWidgets('foto profil di Beranda & Profil dapat diganti dan dihapus secara offline', (tester) async {
    final tmpDir = Directory.systemTemp.createTempSync('moeslim_avatar_test_');
    addTearDown(() {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    });
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    final photoFile = File('${tmpDir.path}/avatar_test.png')..writeAsBytesSync(pngBytes);

    final store = InMemoryStore();
    final fakeService = _FakeProfilePhotoService(photoFile.path);
    await pumpApp(tester, store: store, profilePhotoService: fakeService);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-profile-avatar')), findsOneWidget);
    expect(find.byKey(const Key('profile-avatar-image')), findsNothing);

    // Ketuk avatar di Beranda -> pilih foto dari galeri lokal (offline)
    await tester.tap(find.byKey(const Key('home-profile-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-photo-pick-gallery')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-avatar-image')), findsOneWidget);
    final saved = await SettingsRepository(store).load();
    expect(saved.profilePhotoPath, equals(photoFile.path));

    // Pastikan foto yang sama tampil di tab Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-page-avatar')), findsOneWidget);
    expect(find.byKey(const Key('profile-avatar-image')), findsOneWidget);

    // Hapus foto profil dari tab Profil -> kembali ke avatar default
    await tester.tap(find.byKey(const Key('profile-page-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-photo-remove')));
    await tester.pumpAndSettle();

    expect(fakeService.deletedPath, equals(photoFile.path));
    expect(find.byKey(const Key('profile-avatar-image')), findsNothing);
    final cleared = await SettingsRepository(store).load();
    expect(cleared.profilePhotoPath, isNull);
  });
}

class _FakeProfilePhotoService extends ProfilePhotoService {
  final String _nextPath;
  String? deletedPath;
  _FakeProfilePhotoService(this._nextPath);

  @override
  Future<String?> pickFromGallery() async => _nextPath;

  @override
  Future<void> deleteLocalPhoto(String? path) async {
    deletedPath = path;
  }
}
