import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/ibadah/asmaul_husna_page.dart';
import 'package:moeslim_mobile/features/ibadah/astronomy_qibla_fiqih_page.dart';
import 'package:moeslim_mobile/features/ibadah/family_education_page.dart';
import 'package:moeslim_mobile/features/ibadah/fasting_tracker_page.dart';
import 'package:moeslim_mobile/features/ibadah/fiqih_guide_page.dart';
import 'package:moeslim_mobile/features/ibadah/guided_dzikir_page.dart';
import 'package:moeslim_mobile/features/ibadah/hadith_page.dart';
import 'package:moeslim_mobile/features/ibadah/manasik_page.dart';
import 'package:moeslim_mobile/features/ibadah/muhasabah_journal_page.dart';
import 'package:moeslim_mobile/features/ibadah/muslimah_mode_page.dart';
import 'package:moeslim_mobile/features/ibadah/seasonal_ramadan_page.dart';
import 'package:moeslim_mobile/features/ibadah/sedekah_tracker_page.dart';
import 'package:moeslim_mobile/features/ibadah/share_card_page.dart';
import 'package:moeslim_mobile/features/ibadah/sirah_page.dart';
import 'package:moeslim_mobile/features/ibadah/spiritual_care_page.dart';
import 'package:moeslim_mobile/features/ibadah/utility_accessibility_page.dart';
import 'package:moeslim_mobile/features/ibadah/zakat_faraid_page.dart';
import 'package:moeslim_mobile/features/more/backup_restore_page.dart';
import 'package:moeslim_mobile/features/more/nearby_mosques_gps_page.dart';
import 'package:moeslim_mobile/features/prayer/auto_dnd_page.dart';
import 'package:moeslim_mobile/features/prayer/home_widget_page.dart';
import 'package:moeslim_mobile/features/quran/khatam_planner_page.dart';
import 'package:moeslim_mobile/features/quran/quran_study_suite_page.dart';
import 'package:moeslim_mobile/features/quran/tafsir_search_page.dart';
import 'package:moeslim_mobile/features/quran/tahfidz_page.dart';
import 'package:moeslim_mobile/features/quran/tajweed_learning_page.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'helpers.dart';

Future<void> _openPage(WidgetTester tester, Widget page) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  nav.push(MaterialPageRoute(builder: (_) => page));
  await tester.pumpAndSettle();
}

void main() {
  test('unit domain: 50 fitur inti (zakat, faraid aul/radd, asmaul husna 99, khatam, safar, hijaiyah 29, halal, backup)', () async {
    // 1. Guided dzikir
    expect(guidedDzikirFor(GuidedDzikirTime.pagi).length, greaterThanOrEqualTo(10));
    expect(guidedDzikirFor(GuidedDzikirTime.petang).length, greaterThanOrEqualTo(8));
    expect(guidedDzikirFor(GuidedDzikirTime.badaSalat).length, greaterThanOrEqualTo(8));

    // 2. Tafsir & Notes
    final store = InMemoryStore();
    final noteRepo = AyahNoteRepository(store);
    await noteRepo.saveNote(2, 255, 'Ayat Kursi pelindung');
    expect((await noteRepo.noteFor(2, 255))?.note, 'Ayat Kursi pelindung');
    expect(buildConciseTafsir(surah: surahs[0], ayah: const Ayah(1, 1, '')), contains('Basmalah'));

    // 3. Tahfidz masking
    expect(
      maskArabicForTahfidz('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', TahfidzMaskMode.firstWordsOnly),
      contains('•••'),
    );

    // 4. Hadith catalog
    expect(hadithCatalog.length, 50);
    expect(dailyHadithFor(DateTime(2026, 11, 22)).title, isNotEmpty);

    // 5. Zakat & Faraid (Normal, Aul, Radd)
    final zakat = calculateZakatMaal(
      cashAndSavings: 150000000,
      goldGrams: 10,
      tradeInventory: 0,
      shortTermDebt: 5000000,
      goldPricePerGram: 1500000,
    );
    expect(zakat.isObligatory, isTrue);
    expect(zakat.zakatAmount, closeTo(4000000, 1));

    // Faraid Aul case: Husband (1/2 = 12/24) + 2 Full Sisters (2/3 = 16/24) -> 28/24 Aul
    final aul = computeFaraid(
      const FaraidInput(grossEstate: 28000000, hasHusband: true, fullSistersCount: 2),
    );
    expect(aul.caseType, contains('Aul'));
    expect(aul.shares.fold<double>(0, (s, e) => s + e.totalAmount), closeTo(28000000, 1));

    // Faraid Radd case: Mother (1/6) + 1 Daughter (1/2) -> 16/24 Radd
    final radd = computeFaraid(
      const FaraidInput(grossEstate: 24000000, hasMother: true, daughtersCount: 1),
    );
    expect(radd.caseType, contains('Radd'));
    expect(radd.shares.fold<double>(0, (s, e) => s + e.totalAmount), closeTo(24000000, 1));

    // 6. Fiqih guide
    expect(fiqihGuideCatalog.length, 7);

    // 7. Fasting evaluator (Ramadan & Senin-Kamis)
    final fastEval = evaluateFastingDate(DateTime(2026, 11, 23)); // Monday
    expect(fastEval.recommended, contains(FastingType.seninKamis));

    // 9. Asmaul Husna 99
    expect(asmaulHusnaCatalog.length, 99);
    expect(asmaulHusnaCatalog.first.latin, 'Ar-Rahman');
    expect(asmaulHusnaCatalog.last.latin, 'Ash-Shabur');

    // 10. Khatam Planner
    final plan = KhatamPlan(targetDays: 30, startDate: DateTime(2026, 11, 1), completedPages: 40);
    expect(plan.pagesPerPrayer, 5);

    // 11–20. Wave 2 domain
    expect(makharijulHurufCatalog.length, 5);
    expect(tajweedLessonsCatalog.length, 7);
    expect(manasikUmrahHajiSteps.length, 6);
    expect(sirahLibraryCatalog.length, 74);

    // 19. Muslimah mode pauses prayer streak
    final tracker = TrackerRepository(store);
    final muslimah = MuslimahRepository(store);
    final day1 = DateTime(2026, 11, 20);
    final day2Uzur = DateTime(2026, 11, 21);
    final day3 = DateTime(2026, 11, 22);
    for (final p in TrackerItem.prayers) {
      await tracker.toggle(day1, p);
      await tracker.toggle(day3, p);
    }
    await muslimah.toggleUzurDay(day2Uzur);
    expect(await tracker.prayerStreak(day3), 2);

    // 20. Backup & Restore
    final backupSvc = BackupRestoreService(store);
    final bundle = await backupSvc.createBackup();
    expect(bundle.exportedKeysCount, greaterThanOrEqualTo(2));
    final freshStore = InMemoryStore();
    final restoredCount = await BackupRestoreService(freshStore).restoreFromJson(bundle.jsonPayload);
    expect(restoredCount, bundle.exportedKeysCount);

    // 21–30. Wave 3 & 4 domain
    final wbw = analyzeAyahWordByWord(const Ayah(1, 1, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'));
    expect(wbw.length, 4);
    expect(wbw.first.meaning, 'Dengan nama');
    expect(sajdahVersesCatalog.length, 15);
    final safar = evaluateSafarRukhshah(
      originName: 'Jakarta',
      originCoords: const Coordinates(-6.2088, 106.8456),
      destinationName: 'Bandung',
      destinationCoords: const Coordinates(-6.9175, 107.6191),
    );
    expect(safar.eligibleForQasharAndJama, isTrue);

    // 31–50. Wave 5–8 domain
    final qurban = calculateQurbanAndAqiqah(
      cowPriceRupiah: 21000000,
      liveWeightKg: 300,
      isBabyBoy: true,
      goatPriceRupiah: 3000000,
      babyBirthDate: DateTime(2026, 5, 1),
    );
    expect(qurban.cowSharePerPerson, 3000000);
    expect(qurban.aqiqahGoatsRequired, 2);
    expect(hijaiyah29Catalog.length, 29);
    expect(halalENumberCatalog.any((e) => e.code == 'E471' && e.status == HalalAdditiveStatus.syubhat), isTrue);
    expect(evaluateContextualSunnahForTime(DateTime(2026, 11, 20, 6, 0)), isNotEmpty);
  });

  testWidgets('UI gelombang 1 (fitur 1–10): dzikir terpandu, tafsir, tahfidz, hadits, zakat/faraid, fiqih, puasa, widget, asmaul husna, khatam', (tester) async {
    await pumpApp(tester);

    // 1. Dzikir Terpandu
    await _openPage(tester, const GuidedDzikirPage());
    expect(find.text('Dzikir Terpandu'), findsOneWidget);
    final tapKursi = find.byKey(const Key('tap-dzikir-pagi_ayat_kursi'));
    await tester.ensureVisible(tapKursi);
    await tester.pumpAndSettle();
    await tester.tap(tapKursi);
    await tester.pumpAndSettle();
    expect(find.text('Selesai (1/1)'), findsOneWidget);

    // 2. Tafsir & Pencarian Ayat
    await _openPage(tester, const TafsirSearchPage());
    expect(find.text('Tafsir & Pencarian Ayat'), findsOneWidget);

    // 3. Tahfidz & Muraja'ah
    await _openPage(tester, const TahfidzPage());
    expect(find.text('Tahfidz & Muraja\'ah'), findsOneWidget);

    // 4. Kitab Hadits Pilihan
    await _openPage(tester, const HadithPage());
    expect(find.text('Kitab Hadits Pilihan'), findsOneWidget);
    expect(find.text('Menampilkan ${hadithCatalog.length} hadits shahih'), findsOneWidget);

    // 5. Kalkulator Zakat, Fidyah & Waris (Faraid)
    await _openPage(tester, const ZakatFaraidPage());
    expect(find.byKey(const Key('zakat-maal-output')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Waris (Faraid)')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('faraid-case-type')), findsOneWidget);

    // 6. Panduan Ibadah & Fiqih
    await _openPage(tester, const FiqihGuidePage());
    expect(find.text('Panduan Ibadah & Fiqih'), findsOneWidget);

    // 7. Pelacak Puasa & Qadha
    await _openPage(tester, const FastingTrackerPage());
    expect(find.byKey(const Key('fasting-today-status')), findsOneWidget);

    // 8. Widget Layar Utama Android
    await _openPage(tester, const HomeWidgetPage());
    expect(find.byKey(const Key('home-widget-preview')), findsOneWidget);

    // 9. Asmaul Husna (99 Nama Allah)
    await _openPage(tester, const AsmaulHusnaPage());
    expect(find.text('Ar-Rahman · Yang Maha Pengasih'), findsOneWidget);

    // 10. Perencana Khatam Al-Qur'an
    await _openPage(tester, const KhatamPlannerPage());
    expect(find.byKey(const Key('khatam-progress-pages')), findsOneWidget);
    await tester.tap(find.byKey(const Key('khatam-add-one-page')));
    await tester.pumpAndSettle();
    expect(find.text('1 / 604 Halaman'), findsOneWidget);
  });

  testWidgets('UI gelombang 2–8 (fitur 11–50): tajwid, auto dnd, masjid gps, manasik, sedekah, muhasabah, sirah, share card, muslimah, backup, studi quran, astronomi, ramadan, spiritual, keluarga, utilitas', (tester) async {
    await pumpApp(tester);

    // 11. Belajar Tajwid & Makhraj
    await _openPage(tester, const TajweedLearningPage());
    expect(find.text('Belajar Tajwid & Makhraj'), findsOneWidget);

    // 12. Mode Hening Otomatis
    await _openPage(tester, const AutoDndPage());
    expect(find.byKey(const Key('auto-dnd-enable-switch')), findsOneWidget);

    // 13. Pencari Masjid Terdekat (GPS)
    await _openPage(tester, const NearbyMosquesGpsPage());
    expect(find.text('Pencari Masjid Terdekat (GPS)'), findsOneWidget);

    // 14. Manasik Haji & Umrah
    await _openPage(tester, const ManasikPage());
    await tester.tap(find.byKey(const Key('tab-Counter Thawaf & Sa\'i')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manasik-thawaf-tap')));
    await tester.pumpAndSettle();
    expect(find.text('Putaran Selesai: 1 / 7'), findsOneWidget);

    // 15. Pelacak Sedekah
    await _openPage(tester, const SedekahTrackerPage());
    expect(find.byKey(const Key('sedekah-total-amount')), findsOneWidget);

    // 16. Jurnal Muhasabah
    await _openPage(tester, const MuhasabahJournalPage());
    expect(find.text('Jurnal Muhasabah & Syukur'), findsOneWidget);

    // 17. Sirah, 25 Nabi & Sahabat
    await _openPage(tester, const SirahPage());
    expect(find.text('Sirah, 25 Nabi & Sahabat'), findsOneWidget);

    // 18. Pembuat Kartu Bagikan Ayat & Doa
    await _openPage(tester, const ShareCardPage());
    expect(find.byKey(const Key('share-card-preview')), findsOneWidget);

    // 19. Mode Muslimah
    await _openPage(tester, const MuslimahModePage());
    expect(find.byKey(const Key('muslimah-today-uzur-switch')), findsOneWidget);

    // 20. Cadangkan & Pulihkan Data Lokal
    await _openPage(tester, const BackupRestorePage());
    await tester.tap(find.byKey(const Key('backup-generate-btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('backup-status-msg')), findsOneWidget);

    // 21–25. Pendalaman Al-Qur'an & Arab + Fokus Tilawah (pilih dari 114 surah)
    await _openPage(tester, const QuranStudySuitePage());
    expect(find.text('Pendalaman Al-Qur\'an & Arab'), findsOneWidget);
    await _openPage(tester, const FocusTilawahPage());
    expect(find.byKey(const Key('focus-tilawah-autoscroll')), findsOneWidget);
    expect(find.text('1. Al-Fatihah'), findsOneWidget);

    await tester.tap(find.byKey(const Key('focus-surah-picker')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focus-surah-sheet')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('focus-surah-search')), '114');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('focus-surah-item-114')));
    await tester.pumpAndSettle();
    expect(find.text('114. An-Nas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('focus-surah-prev')));
    await tester.pumpAndSettle();
    expect(find.text('113. Al-Falaq'), findsOneWidget);

    // 26–30. Salat, Kiblat & Astronomi
    await _openPage(tester, const AstronomyQiblaFiqihPage());
    expect(find.byKey(const Key('solar-qibla-summary')), findsOneWidget);

    // 31–35. Ramadan, Hari Besar & Hijriah
    await _openPage(tester, const SeasonalRamadanPage());
    expect(find.byKey(const Key('ramadan-dashboard-summary')), findsOneWidget);

    // 36–40. Dzikir, Doa & Penguatan Hati
    await _openPage(tester, const SpiritualCarePage());
    expect(find.byKey(const Key('mood-quran-comfort')), findsOneWidget);

    // 41–45. Keluarga, Anak & Edukasi
    await _openPage(tester, const FamilyEducationPage());
    expect(find.byKey(const Key('baby-name-combo-output')), findsOneWidget);

    // 46–50. Utilitas, Lansia & Halal
    await _openPage(tester, const UtilityAccessibilityPage());
    expect(find.byKey(const Key('senior-mode-switch')), findsOneWidget);
  });
}
