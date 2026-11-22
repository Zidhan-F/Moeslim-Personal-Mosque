import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/core/adzan_service.dart';
import 'package:moeslim_mobile/core/format.dart';
import 'package:moeslim_mobile/features/home/all_features_page.dart';
import 'package:moeslim_mobile/features/ibadah/asmaul_husna_page.dart';
import 'package:moeslim_mobile/features/ibadah/astronomy_qibla_fiqih_page.dart';
import 'package:moeslim_mobile/features/ibadah/doa_pages.dart';
import 'package:moeslim_mobile/features/ibadah/family_education_page.dart';
import 'package:moeslim_mobile/features/ibadah/fasting_tracker_page.dart';
import 'package:moeslim_mobile/features/ibadah/fiqih_guide_page.dart';
import 'package:moeslim_mobile/features/ibadah/guided_dzikir_page.dart';
import 'package:moeslim_mobile/features/ibadah/hadith_page.dart';
import 'package:moeslim_mobile/features/ibadah/hijri_page.dart';
import 'package:moeslim_mobile/features/ibadah/manasik_page.dart';
import 'package:moeslim_mobile/features/ibadah/muhasabah_journal_page.dart';
import 'package:moeslim_mobile/features/ibadah/muslimah_mode_page.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/ibadah/seasonal_ramadan_page.dart';
import 'package:moeslim_mobile/features/ibadah/sedekah_tracker_page.dart';
import 'package:moeslim_mobile/features/ibadah/share_card_page.dart';
import 'package:moeslim_mobile/features/ibadah/sirah_page.dart';
import 'package:moeslim_mobile/features/ibadah/spiritual_care_page.dart';
import 'package:moeslim_mobile/features/ibadah/tasbih_page.dart';
import 'package:moeslim_mobile/features/ibadah/tracker_page.dart';
import 'package:moeslim_mobile/features/ibadah/utility_accessibility_page.dart';
import 'package:moeslim_mobile/features/ibadah/zakat_faraid_page.dart';
import 'package:moeslim_mobile/features/masjid/masjid_home_page.dart';
import 'package:moeslim_mobile/features/more/about_licenses_page.dart';
import 'package:moeslim_mobile/features/more/backup_restore_page.dart';
import 'package:moeslim_mobile/features/more/nearby_mosques_gps_page.dart';
import 'package:moeslim_mobile/features/prayer/auto_dnd_page.dart';
import 'package:moeslim_mobile/features/prayer/home_widget_page.dart';
import 'package:moeslim_mobile/features/prayer/prayer_page.dart';
import 'package:moeslim_mobile/features/quran/khatam_planner_page.dart';
import 'package:moeslim_mobile/features/quran/murottal_page.dart';
import 'package:moeslim_mobile/features/quran/quran_study_suite_page.dart';
import 'package:moeslim_mobile/features/quran/surah_page.dart';
import 'package:moeslim_mobile/features/quran/tafsir_search_page.dart';
import 'package:moeslim_mobile/features/quran/tahfidz_page.dart';
import 'package:moeslim_mobile/features/quran/tajweed_learning_page.dart';
import 'package:moeslim_mobile/features/quran/tajweed_view.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'helpers.dart';

void main() {
  test('format tanggal, waktu salat, Hijriah, dan alarm adzan mendukung id dan en', () {
    final dt = DateTime(2026, 11, 22, 4, 38);
    expect(longDate(dt, lang: AppLanguage.id), 'Ahad, 22 November 2026');
    expect(longDate(dt, lang: AppLanguage.en), 'Sunday, November 22, 2026');
    expect(shortDate(dt, lang: AppLanguage.id), '22 Nov 2026');
    expect(shortDate(dt, lang: AppLanguage.en), 'Nov 22, 2026');

    expect(Prayer.fajr.labelFor(AppLanguage.id), 'Subuh');
    expect(Prayer.fajr.labelFor(AppLanguage.en), 'Fajr');
    expect(Prayer.dhuhr.labelFor(AppLanguage.en), 'Dhuhr');
    expect(Prayer.asr.labelFor(AppLanguage.en), 'Asr');
    expect(Prayer.isha.labelFor(AppLanguage.en), 'Isha');

    final h = HijriDate(1447, 9, 1);
    expect(h.format(AppLanguage.id), '1 Ramadan 1447 H');
    expect(h.format(AppLanguage.en), '1 Ramadan 1447 AH');

    final alarm = ScheduledAdzanAlarm(
      prayer: Prayer.fajr,
      localTime: dt,
      triggerUtc: dt.toUtc(),
      muadzinId: 'makkah',
      locationName: 'Jakarta',
    );
    expect(alarm.toMap(lang: AppLanguage.id)['prayerLabel'], 'Subuh');
    expect(alarm.toMap(lang: AppLanguage.id)['language'], 'id');
    expect(alarm.toMap(lang: AppLanguage.en)['prayerLabel'], 'Fajr');
    expect(alarm.toMap(lang: AppLanguage.en)['language'], 'en');
  });

  testWidgets('pengalih bahasa di Onboarding mengganti bahasa id <-> en dan tersimpan', (tester) async {
    final store = InMemoryStore();
    await pumpApp(tester, store: store, showOnboarding: true);

    expect(find.text('Selamat Datang di'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byKey(const Key('onboarding-language')), matching: find.text('EN')));
    await tester.pumpAndSettle();

    expect((await SettingsRepository(store).load()).language, AppLanguage.en);
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.descendant(of: find.byKey(const Key('onboarding-language')), matching: find.text('ID')));
    await tester.pumpAndSettle();
    expect((await SettingsRepository(store).load()).language, AppLanguage.id);
    expect(find.text('Selamat Datang di'), findsOneWidget);
  });

  testWidgets('pengalih bahasa di Profil mengubah seluruh navigasi utama, Beranda, Al-Qur\'an, Ibadah & Masjid ke English', (
    tester,
  ) async {
    final store = InMemoryStore();
    final quranMap = {
      1: [
        const Ayah(
          1,
          1,
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          translation: 'Dengan menyebut nama Allah Yang Maha Pemurah lagi Maha Penyayang.',
          translationEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
      ],
      13: [
        for (var i = 1; i <= 28; i++)
          Ayah(
            13,
            i,
            'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
            translation: 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
            translationEn: 'Unquestionably, by the remembrance of Allah hearts are assured.',
          ),
      ],
    };

    await pumpApp(tester, store: store, quran: FakeQuranSource(quranMap));

    // Default: Bahasa Indonesia
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Menu Cepat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Buka tab Profil dan ganti ke EN
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    final langSelector = find.byKey(const Key('language-selector'));
    await tester.ensureVisible(langSelector);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: langSelector, matching: find.text('EN')));
    await tester.pumpAndSettle();

    expect((await SettingsRepository(store).load()).language, AppLanguage.en);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text("Qur'an"), findsOneWidget);
    expect(find.text('Worship'), findsOneWidget);
    expect(find.text('Mosque'), findsOneWidget);

    // Kembali ke tab Home (Beranda) -> seluruh kartu berbahasa Inggris termasuk ayat harian Saheeh International
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Quick Menu'), findsOneWidget);
    expect(find.text('Duas & Dhikr'), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('See All'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('daily-ayah')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Unquestionably, by the remembrance of Allah'), findsOneWidget);

    // Tab Qur'an & SurahPage menampilkan terjemahan Inggris (Saheeh International)
    await tester.tap(find.text("Qur'an").last);
    await tester.pumpAndSettle();
    expect(find.textContaining('114 Surahs'), findsOneWidget);
    expect(find.textContaining('Meccan'), findsWidgets);
    await tester.tap(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();
    expect(find.textContaining('In the name of Allah, the Entirely Merciful'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tab Worship (Ibadah)
    await tester.tap(find.text('Worship').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily Worship'), findsOneWidget);
    expect(find.textContaining('Morning, Evening & Post-Prayer Dhikr'), findsOneWidget);
  });

  testWidgets('seluruh halaman fitur utama dan 50 fitur tambahan merender bersih dalam mode English (AppLanguage.en)', (
    tester,
  ) async {
    final store = InMemoryStore();
    await SettingsRepository(store).save(
      PersonalSettings.defaults.copyWith(onboardingDone: true, language: AppLanguage.en),
    );
    await pumpApp(tester, store: store);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    final pages = <Widget>[
      AllFeaturesPage(onNavigate: (_) {}),
      const PrayerPage(),
      const PrayerSettingsPage(),
      const AutoDndPage(),
      const HomeWidgetPage(),
      SurahPage(surah: surahs.first),
      const MurottalPage(),
      const TafsirSearchPage(),
      const TahfidzPage(),
      const KhatamPlannerPage(),
      const TajweedLearningPage(),
      const TajweedLegendPage(),
      const QuranStudySuitePage(),
      const FocusTilawahPage(),
      const DoaListPage(),
      const GuidedDzikirPage(),
      const TasbihPage(),
      const TrackerPage(),
      const HijriPage(),
      const QiblaPage(),
      const FastingTrackerPage(),
      const HadithPage(),
      const FiqihGuidePage(),
      const ZakatFaraidPage(),
      const AsmaulHusnaPage(),
      const ManasikPage(),
      const SedekahTrackerPage(),
      const MuhasabahJournalPage(),
      const SirahPage(),
      const ShareCardPage(),
      const MuslimahModePage(),
      const AstronomyQiblaFiqihPage(),
      const SeasonalRamadanPage(),
      const SpiritualCarePage(),
      const FamilyEducationPage(),
      const UtilityAccessibilityPage(),
      const NearbyMosquesGpsPage(),
      const BackupRestorePage(),
      const AboutLicensesPage(),
      const MasjidHomePage(),
    ];

    for (final page in pages) {
      nav.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull, reason: 'Page ${page.runtimeType} threw in English mode');
      nav.pop();
      await tester.pump();
    }
  });
}
