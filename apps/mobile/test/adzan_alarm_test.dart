import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:moeslim_mobile/app.dart';
import 'package:moeslim_mobile/core/adzan_service.dart';
import 'package:moeslim_mobile/core/location_service.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/prayer/prayer_page.dart';
import 'package:moeslim_mobile/features/quran/audio/audio_providers.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'helpers.dart';

Future<void> _scrollIntoView(WidgetTester tester, Finder target) async {
  final listFinder = find.descendant(
    of: find.byType(PrayerSettingsPage),
    matching: find.byType(ListView),
  );
  for (var i = 0; i < 12; i++) {
    final center = tester.getCenter(target);
    if (center.dy >= 90 && center.dy <= 510) return;
    final dy = center.dy > 510 ? -220.0 : 220.0;
    await tester.drag(listFinder.first, Offset(0, dy));
    await tester.pumpAndSettle();
  }
}

void main() {
  test('semua berkas audio adzan muadzin tersedia secara offline dan merupakan rekaman MP3 asli', () {
    expect(adzanMuadzins.length, greaterThanOrEqualTo(4));
    for (final m in adzanMuadzins) {
      expect(m.assetPath.endsWith('.mp3'), isTrue, reason: 'Asset ${m.assetPath} harus berformat MP3');
      final file = File(m.assetPath);
      expect(file.existsSync(), isTrue, reason: 'Asset ${m.assetPath} untuk ${m.name} harus ada');
      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(400000), reason: 'Asset ${m.assetPath} harus rekaman adzan penuh, bukan nada singkat');
      final isId3 = String.fromCharCodes(bytes.sublist(0, 3)) == 'ID3';
      final isMpegFrame = bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
      expect(isId3 || isMpegFrame, isTrue, reason: 'Header MP3 ${m.assetPath} harus valid');
    }
  });

  test('computeUpcomingAdzanAlarms menjadwalkan waktu adzan setempat sesuai zona waktu dan filter salat', () {
    final baseSettings = PersonalSettings.defaults.copyWith(onboardingDone: true);
    // 1 Jan 2025 05:00 UTC = 12:00 WIB (Jakarta, sebelum Ashar/Maghrib/Isya).
    final nowUtc = DateTime.utc(2025, 1, 1, 5, 0, 0);
    final alarms = computeUpcomingAdzanAlarms(baseSettings, nowUtc);

    expect(alarms.length, 5);
    expect(alarms.every((a) => a.triggerUtc.isAfter(nowUtc)), isTrue);
    expect(alarms.every((a) => a.locationName == 'Jakarta'), isTrue);
    expect(alarms.every((a) => a.muadzinId == 'makkah'), isTrue);

    // Nonaktifkan Ashar dan Maghrib -> hanya 3 waktu salat yang dijadwalkan.
    final filteredSettings = baseSettings
        .setPrayerAdzan(Prayer.asr, false)
        .setPrayerAdzan(Prayer.maghrib, false)
        .copyWith(muadzinId: 'al_aqsa');
    final filteredAlarms = computeUpcomingAdzanAlarms(filteredSettings, nowUtc);
    expect(filteredAlarms.map((a) => a.prayer).toSet(), {Prayer.fajr, Prayer.dhuhr, Prayer.isha});
    expect(filteredAlarms.every((a) => a.muadzinId == 'al_aqsa'), isTrue);

    // Lokasi GPS Jayapura (WIT / UTC+9) menggunakan offset setempat.
    final jayapuraSettings = baseSettings.copyWith(
      useDeviceLocation: true,
      deviceLocation: DeviceLocation(
        latitude: -2.5337,
        longitude: 140.7181,
        utcOffset: 9.0,
        accuracyMeters: 5.0,
        updatedAt: DateTime.utc(2025, 1, 1),
        label: 'Jayapura (WIT)',
      ),
    );
    final jayapuraAlarms = computeUpcomingAdzanAlarms(jayapuraSettings, nowUtc);
    expect(jayapuraAlarms.length, 5);
    expect(jayapuraAlarms.first.locationName, 'Jayapura (WIT)');

    // Master switch mati -> tidak ada alarm yang dijadwalkan.
    final offAlarms = computeUpcomingAdzanAlarms(
      baseSettings.copyWith(notificationsEnabled: false),
      nowUtc,
    );
    expect(offAlarms, isEmpty);
  });

  testWidgets('toggle alarm adzan per waktu salat di halaman Jadwal Salat memperbarui jadwal alarm', (tester) async {
    final store = InMemoryStore();
    final backend = FakeAdzanAlarmBackend();
    await pumpApp(tester, store: store, adzanBackend: backend);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerPage()));
    await tester.pumpAndSettle();

    expect(backend.syncedAlarms.length, 5);

    // Matikan adzan untuk waktu Subuh langsung dari baris jadwal.
    final fajrToggle = find.byKey(const Key('toggle-adzan-fajr'));
    await tester.ensureVisible(fajrToggle);
    await tester.tap(fajrToggle);
    await tester.pumpAndSettle();

    final saved = await SettingsRepository(store).load();
    expect(saved.isAdzanActiveFor(Prayer.fajr), isFalse);
    expect(saved.activeAdzanCount, 4);
    expect(backend.syncedAlarms.map((a) => a.prayer), isNot(contains(Prayer.fajr)));

    await tester.scrollUntilVisible(find.byKey(const Key('prayer-adzan-summary')), 200);
    expect(find.byKey(const Key('prayer-adzan-summary')), findsOneWidget);
    expect(find.textContaining('Aktif (4/5 waktu)'), findsOneWidget);
  });

  testWidgets('memilih muadzin dan memutar preview suara adzan di Pengaturan Jadwal', (tester) async {
    final store = InMemoryStore();
    final backend = FakeAdzanAlarmBackend();
    await pumpApp(tester, store: store, adzanBackend: backend);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('adzan-settings-card')), findsOneWidget);

    // Pilih Muadzin Masjid Nabawi, Madinah (Syaikh Essam Bukhari).
    final madinahTile = find.byKey(const Key('muadzin-option-madinah'));
    await _scrollIntoView(tester, madinahTile);
    await tester.tap(madinahTile);
    await tester.pumpAndSettle();

    final saved = await SettingsRepository(store).load();
    expect(saved.muadzinId, 'madinah');
    expect(backend.syncedAlarms.every((a) => a.muadzinId == 'madinah'), isTrue);

    // Tekan tombol preview untuk muadzin Mishary Alafasy.
    final misharyPreview = find.byKey(const Key('preview-muadzin-mishary'));
    await _scrollIntoView(tester, misharyPreview);
    await tester.tap(misharyPreview);
    await tester.pumpAndSettle();

    expect(backend.playedMuadzins.last.id, 'mishary');
    expect(find.byKey(const Key('preview-playing-banner')), findsOneWidget);

    // Saat audio selesai diputar secara alami, status pratinjau otomatis berhenti.
    backend.completePlayback();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('preview-playing-banner')), findsNothing);

    // Putar lagi lalu tekan sekali lagi untuk menghentikan manual.
    await tester.tap(misharyPreview);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('preview-playing-banner')), findsOneWidget);

    await tester.tap(misharyPreview);
    await tester.pumpAndSettle();
    expect(backend.stopCalls, greaterThanOrEqualTo(1));
    expect(find.byKey(const Key('preview-playing-banner')), findsNothing);
  });

  testWidgets('saat waktu adzan tiba, suara adzan berkumandang dan banner alarm tampil hingga dimatikan', (tester) async {
    final store = InMemoryStore();
    final repo = SettingsRepository(store);
    final settings = PersonalSettings.defaults.copyWith(onboardingDone: true, muadzinId: 'makkah');
    await repo.save(settings);

    // Hitung waktu Subuh tepat untuk Jakarta pada 1 Jan 2025.
    final times = settings.timesFor(DateTime(2025, 1, 1));
    final fajrWall = times.timeOf(Prayer.fajr);
    final fajrUtc = localWallClockToUtc(fajrWall, settings.effectiveUtcOffset);
    final beforeFajrUtc = fajrUtc.subtract(const Duration(minutes: 1));

    final clockController = StreamController<DateTime>.broadcast();
    addTearDown(clockController.close);
    final backend = FakeAdzanAlarmBackend();
    final location = FakeLocationService();
    addTearDown(location.dispose);

    final container = ProviderContainer(
      overrides: [
        storeProvider.overrideWithValue(store),
        nowProvider.overrideWith((ref) => clockController.stream),
        headingProvider.overrideWith((ref) => Stream.value(null)),
        compassProvider.overrideWith((ref) => Stream.value(null)),
        locationServiceProvider.overrideWithValue(location),
        declinationServiceProvider.overrideWithValue(const FakeDeclinationService()),
        adzanBackendProvider.overrideWithValue(backend),
        quranSourceProvider.overrideWithValue(FakeQuranSource()),
        dailyDuasProvider.overrideWith((ref) async => const <DailyDua>[]),
        audioManifestProvider.overrideWith((ref) async => AudioManifest.empty),
        audioEngineProvider.overrideWithValue(FakeAudioEngine()),
        offlineAudioProvider.overrideWithValue(FakeOfflineAudio()),
        tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MoeslimApp()));
    clockController.add(beforeFajrUtc);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('active-adzan-banner')), findsNothing);
    expect(backend.playedPrayers, isEmpty);

    // Waktu bergerak masuk ke menit Subuh setempat.
    clockController.add(fajrUtc);
    await tester.pump();
    await tester.pump();

    expect(backend.playedPrayers, [Prayer.fajr]);
    expect(backend.playedMuadzins.single.id, 'makkah');
    expect(find.byKey(const Key('active-adzan-banner')), findsOneWidget);
    expect(find.textContaining('Waktu Adzan Subuh'), findsOneWidget);
    expect(find.textContaining('Ash-shalaatu khairum minan-nauum'), findsOneWidget);

    // Pengguna menekan tombol Matikan pada banner adzan.
    await tester.tap(find.byKey(const Key('stop-adzan-alarm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('active-adzan-banner')), findsNothing);
    expect(backend.stopCalls, 1);
  });

  testWidgets('pop-up alarm adzan tampil di atas sub-halaman (Pengaturan) dan dapat dimatikan', (tester) async {
    final store = InMemoryStore();
    final backend = FakeAdzanAlarmBackend();
    await pumpApp(tester, store: store, adzanBackend: backend);

    // Buka halaman Pengaturan Jadwal (bukan HomeShell) dan tekan Uji Pop-up Alarm.
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage()));
    await tester.pumpAndSettle();

    final testBtn = find.byKey(const Key('test-adzan-alarm'));
    await tester.ensureVisible(testBtn);
    await tester.tap(testBtn);
    await tester.pumpAndSettle();

    // Pop-up alarm tampil mengambang di atas halaman Pengaturan Jadwal!
    expect(find.byKey(const Key('active-adzan-banner')), findsOneWidget);
    expect(find.textContaining('Waktu Adzan Dzuhur'), findsOneWidget);
    expect(find.byKey(const Key('stop-adzan-alarm')), findsOneWidget);

    await tester.tap(find.byKey(const Key('stop-adzan-alarm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('active-adzan-banner')), findsNothing);
    expect(backend.stopCalls, 1);

    // Simulasi alarm berbunyi dari background native receiver -> pop-up langsung muncul!
    backend.emitNativeAlarm(Prayer.maghrib);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-adzan-banner')), findsOneWidget);
    expect(find.textContaining('Waktu Adzan Maghrib'), findsOneWidget);

    // Simulasi pengguna menekan Matikan Adzan dari notifikasi Android -> pop-up langsung hilang!
    backend.emitNativeAlarm(null);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-adzan-banner')), findsNothing);
  });

  testWidgets('tema pop-up adzan mengikuti pilihan aplikasi, bukan tema sistem HP', (
    tester,
  ) async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, themeMode: AppThemeMode.light),
    );
    final backend = FakeAdzanAlarmBackend();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final container = await pumpApp(tester, store: store, adzanBackend: backend);

    backend.emitNativeAlarm(Prayer.dhuhr);
    await tester.pumpAndSettle();
    expect(backend.lastThemeMode, AppThemeMode.light);
    var surface = tester.widget<Material>(find.byKey(const Key('active-adzan-popup-surface')));
    expect(surface.color, BrandColors.white);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    surface = tester.widget<Material>(find.byKey(const Key('active-adzan-popup-surface')));
    expect(surface.color, BrandColors.white);

    final current = await SettingsRepository(store).load();
    await container.read(settingsProvider.notifier).save(current.copyWith(themeMode: AppThemeMode.light));
    await tester.pumpAndSettle();
    surface = tester.widget<Material>(find.byKey(const Key('active-adzan-popup-surface')));
    expect(surface.color, BrandColors.white);
    expect(backend.lastThemeMode, AppThemeMode.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await container.read(settingsProvider.notifier).save(current.copyWith(themeMode: AppThemeMode.dark));
    await tester.pumpAndSettle();
    surface = tester.widget<Material>(find.byKey(const Key('active-adzan-popup-surface')));
    expect(surface.color, BrandColors.nightCard);
    expect(backend.lastThemeMode, AppThemeMode.dark);
  });

  testWidgets('pengaturan volume adzan mandiri tersimpan, tersinkron ke backend, dan pop-up hilang otomatis saat adzan selesai', (
    tester,
  ) async {
    final store = InMemoryStore();
    final backend = FakeAdzanAlarmBackend();
    final container = await pumpApp(tester, store: store, adzanBackend: backend);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage()));
    await tester.pumpAndSettle();

    // Default: suara adzan mandiri aktif (85%, mengabaikan aturan hening/volume HP).
    expect(backend.lastVolume, closeTo(0.85, 0.001));
    expect(backend.lastOverrideDeviceVolume, isTrue);

    // Ubah volume ke 100% dan matikan override -> tersimpan & tersinkron ke backend.
    final maxBtn = find.byKey(const Key('adzan-volume-max'));
    await _scrollIntoView(tester, maxBtn);
    await tester.tap(maxBtn);
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).adzanVolume, closeTo(1.0, 0.001));
    expect(backend.lastVolume, closeTo(1.0, 0.001));

    final overrideSwitch = find.byKey(const Key('adzan-override-device-switch'));
    await _scrollIntoView(tester, overrideSwitch);
    await tester.tap(overrideSwitch);
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).adzanOverrideDeviceVolume, isFalse);
    expect(backend.lastOverrideDeviceVolume, isFalse);

    // Nyalakan lagi mode mandiri & uji pop-up alarm.
    await _scrollIntoView(tester, overrideSwitch);
    await tester.tap(overrideSwitch);
    await tester.pumpAndSettle();
    final testBtn = find.byKey(const Key('test-adzan-alarm'));
    await _scrollIntoView(tester, testBtn);
    await tester.tap(testBtn);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-adzan-banner')), findsOneWidget);
    expect(backend.lastVolume, closeTo(1.0, 0.001));
    expect(backend.lastOverrideDeviceVolume, isTrue);

    // Begitu audio adzan selesai secara alami -> pop-up notifikasi otomatis hilang!
    backend.completePlayback();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-adzan-banner')), findsNothing);

    // Simulasi alarm selesai saat aplikasi di background lalu app kembali dibuka (syncActiveNativeAlarm).
    await container.read(adzanControllerProvider.notifier).triggerAlarm(Prayer.asr);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-adzan-banner')), findsOneWidget);
    backend.activeNativeAlarm = null;
    await container.read(adzanControllerProvider.notifier).syncActiveNativeAlarm();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-adzan-banner')), findsNothing);
  });

  testWidgets('pengaturan suara adzan langsung di Profil tersimpan, memutar pratinjau, dan membuka detail muadzin', (
    tester,
  ) async {
    final store = InMemoryStore();
    final backend = FakeAdzanAlarmBackend();
    await pumpApp(tester, store: store, adzanBackend: backend);

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();

    final scroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.byKey(const Key('profile-adzan-volume-max')), 200, scrollable: scroll);
    await Scrollable.ensureVisible(tester.element(find.byKey(const Key('profile-adzan-volume-max'))), alignment: 0.5);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-adzan-card')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-adzan-volume-max')));
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).adzanVolume, closeTo(1.0, 0.001));
    expect(backend.lastVolume, closeTo(1.0, 0.001));

    await Scrollable.ensureVisible(
      tester.element(find.byKey(const Key('profile-adzan-override-switch'))),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-adzan-override-switch')));
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).adzanOverrideDeviceVolume, isFalse);
    expect(backend.lastOverrideDeviceVolume, isFalse);

    await tester.scrollUntilVisible(find.byKey(const Key('profile-adzan-muadzin')), 200, scrollable: scroll);
    await Scrollable.ensureVisible(tester.element(find.byKey(const Key('profile-adzan-muadzin'))), alignment: 0.5);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-adzan-preview')));
    await tester.pumpAndSettle();
    expect(backend.playedMuadzins.last.id, 'makkah');

    await tester.tap(find.byKey(const Key('profile-adzan-muadzin')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adzan-settings-card')), findsOneWidget);
  });
}
