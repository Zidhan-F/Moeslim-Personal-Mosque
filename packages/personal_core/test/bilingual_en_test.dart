import 'dart:io';

import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';
import 'package:test/test.dart';

void _expectCleanEn(String value, {String? reason}) {
  expect(value.trim(), isNotEmpty, reason: reason);
  expect(value.contains('—'), isFalse, reason: 'Em-dash forbidden: $reason -> $value');
}

void main() {
  test('daily_duas.json parses all 229 entries with complete English fields and zero em-dashes', () {
    final file = File('../../apps/mobile/assets/doa/daily_duas.json');
    expect(file.existsSync(), isTrue);
    final duas = parseDailyDuasJson(file.readAsStringSync());
    expect(duas.length, 229);
    for (final d in duas) {
      expect(d.groupEn, isNotNull, reason: 'id ${d.id} groupEn');
      expect(d.titleEn, isNotNull, reason: 'id ${d.id} titleEn');
      expect(d.translationEn, isNotNull, reason: 'id ${d.id} translationEn');
      expect(d.sourceEn, isNotNull, reason: 'id ${d.id} sourceEn');
      _expectCleanEn(d.groupFor(AppLanguage.en), reason: 'id ${d.id} group');
      _expectCleanEn(d.titleFor(AppLanguage.en), reason: 'id ${d.id} title');
      _expectCleanEn(d.translationFor(AppLanguage.en), reason: 'id ${d.id} translation');
      _expectCleanEn(d.sourceFor(AppLanguage.en), reason: 'id ${d.id} source');
    }
    expect(duas.first.matches('righteous servants'), isTrue);
  });

  test('asmaul_husna & dzikir catalogs have full English support', () {
    expect(asmaulHusnaCatalog.length, 99);
    for (final item in asmaulHusnaCatalog) {
      _expectCleanEn(item.meaningFor(AppLanguage.en), reason: 'Asmaul Husna #${item.number}');
      _expectCleanEn(item.explanationFor(AppLanguage.en), reason: 'Asmaul Husna #${item.number} exp');
      expect(item.meaningFor(AppLanguage.en), isNot(item.meaning));
    }
    expect(asmaulHusnaCatalog.first.matches('compassionate'), isTrue);

    for (final d in dzikirList) {
      _expectCleanEn(d.nameFor(AppLanguage.en));
      _expectCleanEn(d.meaningFor(AppLanguage.en));
      expect(d.meaningFor(AppLanguage.en), isNot(d.meaning));
    }
  });

  test('all 74 sirah chapters have full English translations and zero em-dashes', () {
    expect(sirahLibraryCatalog.length, 74);
    for (final s in SirahSection.values) {
      _expectCleanEn(s.labelFor(AppLanguage.en));
      expect(s.labelFor(AppLanguage.en), isNot(s.label));
    }
    for (final ch in sirahLibraryCatalog) {
      _expectCleanEn(ch.titleFor(AppLanguage.en), reason: '${ch.id} title');
      _expectCleanEn(ch.periodOrTitleFor(AppLanguage.en), reason: '${ch.id} period');
      _expectCleanEn(ch.narrativeFor(AppLanguage.en), reason: '${ch.id} narrative');
      _expectCleanEn(ch.hikmahFor(AppLanguage.en), reason: '${ch.id} hikmah');
      _expectCleanEn(ch.referenceFor(AppLanguage.en), reason: '${ch.id} reference');
      expect(ch.narrativeFor(AppLanguage.en), isNot(ch.narrative), reason: '${ch.id} translated');
      expect(ch.blocksFor(AppLanguage.en).any((b) => b.kind == SirahBlockKind.heading), isTrue,
          reason: '${ch.id} EN headings');
      expect(ch.readingMinutesFor(AppLanguage.en), greaterThan(0));
    }
  });

  test('content suites: guided dzikir, hadith, fiqih, manasik, tajweed, quran study & tafsir', () {
    for (final t in GuidedDzikirTime.values) {
      _expectCleanEn(t.labelFor(AppLanguage.en));
      _expectCleanEn(t.timeHintFor(AppLanguage.en));
    }
    for (final item in guidedDzikirCatalog) {
      _expectCleanEn(item.titleFor(AppLanguage.en), reason: item.id);
      _expectCleanEn(item.translationFor(AppLanguage.en), reason: item.id);
      _expectCleanEn(item.sourceFor(AppLanguage.en), reason: item.id);
      _expectCleanEn(item.virtueFor(AppLanguage.en), reason: item.id);
    }
    for (final h in hadithCatalog) {
      _expectCleanEn(h.collectionFor(AppLanguage.en), reason: 'hadith ${h.id}');
      _expectCleanEn(h.titleFor(AppLanguage.en), reason: 'hadith ${h.id}');
      _expectCleanEn(h.topicFor(AppLanguage.en), reason: 'hadith ${h.id}');
      _expectCleanEn(h.translationFor(AppLanguage.en), reason: 'hadith ${h.id}');
      _expectCleanEn(h.narratorFor(AppLanguage.en), reason: 'hadith ${h.id}');
      _expectCleanEn(h.fiqhPointsFor(AppLanguage.en), reason: 'hadith ${h.id}');
    }
    for (final c in FiqihCategory.values) {
      _expectCleanEn(c.labelFor(AppLanguage.en));
    }
    for (final topic in fiqihGuideCatalog) {
      _expectCleanEn(topic.titleFor(AppLanguage.en));
      _expectCleanEn(topic.summaryFor(AppLanguage.en));
      _expectCleanEn(topic.dalilFor(AppLanguage.en));
      for (final step in topic.steps) {
        _expectCleanEn(step.titleFor(AppLanguage.en));
        _expectCleanEn(step.rulingFor(AppLanguage.en));
        _expectCleanEn(step.descriptionFor(AppLanguage.en));
        if (step.translation != null) {
          _expectCleanEn(step.translationFor(AppLanguage.en)!);
        }
      }
    }
    for (final step in manasikUmrahHajiSteps) {
      _expectCleanEn(step.titleFor(AppLanguage.en));
      _expectCleanEn(step.rulingFor(AppLanguage.en));
      _expectCleanEn(step.locationFor(AppLanguage.en));
      _expectCleanEn(step.descriptionFor(AppLanguage.en));
      _expectCleanEn(step.translationFor(AppLanguage.en));
    }
    expect(ihramProhibitionsFor(AppLanguage.en).length, ihramProhibitions.length);
    expect(manasikPackingChecklistFor(AppLanguage.en).length, manasikPackingChecklist.length);
    _expectCleanEn(const ManasikCounterState(saiLap: 0).saiRouteDirectionFor(AppLanguage.en));
    _expectCleanEn(const ManasikCounterState(saiLap: 7).saiRouteDirectionFor(AppLanguage.en));

    for (final r in TajweedRule.values) {
      _expectCleanEn(r.labelFor(AppLanguage.en));
      _expectCleanEn(r.descriptionFor(AppLanguage.en));
    }
    for (final m in makharijulHurufCatalog) {
      _expectCleanEn(m.nameFor(AppLanguage.en));
      _expectCleanEn(m.lettersFor(AppLanguage.en));
      _expectCleanEn(m.organDescriptionFor(AppLanguage.en));
      _expectCleanEn(m.practiceTipFor(AppLanguage.en));
    }
    for (final l in tajweedLessonsCatalog) {
      _expectCleanEn(l.titleFor(AppLanguage.en));
      _expectCleanEn(l.triggerLettersFor(AppLanguage.en));
      _expectCleanEn(l.howToReadFor(AppLanguage.en));
      _expectCleanEn(l.exampleSurahRefFor(AppLanguage.en));
      _expectCleanEn(l.exampleExplanationFor(AppLanguage.en));
    }
    for (final q in tajweedQuizBank) {
      _expectCleanEn(q.questionFor(AppLanguage.en));
      _expectCleanEn(q.explanationFor(AppLanguage.en));
      for (final opt in q.optionsFor(AppLanguage.en)) {
        _expectCleanEn(opt);
      }
    }
    for (final w in coreQuranVocabulary) {
      _expectCleanEn(w.meaningFor(AppLanguage.en));
    }
    for (final a in asbabunNuzulCatalog) {
      _expectCleanEn(a.titleFor(AppLanguage.en));
      _expectCleanEn(a.contextNarrativeFor(AppLanguage.en));
      _expectCleanEn(a.sourceFor(AppLanguage.en));
      _expectCleanEn(a.hikmahFor(AppLanguage.en));
    }
    for (final s in routineQuranShortcuts) {
      _expectCleanEn(s.titleFor(AppLanguage.en));
      _expectCleanEn(s.timingAndVirtueFor(AppLanguage.en));
    }
    for (final v in sajdahVersesCatalog) {
      _expectCleanEn(v.excerptMeaningFor(AppLanguage.en));
    }
    for (final t in quranThematicIndex) {
      _expectCleanEn(t.titleFor(AppLanguage.en));
      _expectCleanEn(t.descriptionFor(AppLanguage.en));
    }
    final fatihah = surahs.first;
    final ayah1 = const Ayah(1, 1, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        translation: 'Dengan nama Allah', translationEn: 'In the name of Allah');
    _expectCleanEn(buildConciseTafsir(surah: fatihah, ayah: ayah1, lang: AppLanguage.en));
    final ayah3 = const Ayah(1, 3, 'الرَّحْمَٰنِ الرَّحِيمِ',
        translation: 'Yang Maha Pengasih', translationEn: 'The Entirely Merciful');
    _expectCleanEn(buildConciseTafsir(surah: fatihah, ayah: ayah3, lang: AppLanguage.en));
    final words = analyzeAyahWordByWord(ayah1, lang: AppLanguage.en);
    expect(words.isNotEmpty, isTrue);
    _expectCleanEn(words.first.meaningFor(AppLanguage.en));
  });

  test('family, spiritual care, seasonal, utility, astronomy, zakat/faraid & storage/models EN APIs', () {
    for (final b in islamicBabyNamesCatalog) {
      _expectCleanEn(b.genderFor(AppLanguage.en));
      _expectCleanEn(b.meaningFor(AppLanguage.en));
      _expectCleanEn(b.themeFor(AppLanguage.en));
    }
    final combined = combineIslamicBabyNames(
      islamicBabyNamesCatalog[0],
      islamicBabyNamesCatalog[1],
      lang: AppLanguage.en,
    );
    _expectCleanEn(combined.combinedMeaning);

    for (final h in hijaiyah29Catalog) {
      _expectCleanEn(h.nameFor(AppLanguage.en));
      _expectCleanEn(h.latinSoundFor(AppLanguage.en));
      _expectCleanEn(h.makhrajNoteFor(AppLanguage.en));
    }
    for (final q in islamicKnowledgeQuizBank) {
      _expectCleanEn(q.categoryFor(AppLanguage.en));
      _expectCleanEn(q.questionFor(AppLanguage.en));
      _expectCleanEn(q.explanationFor(AppLanguage.en));
      expect(q.optionsFor(AppLanguage.en).length, 4);
    }
    for (final g in islamicGlossaryCatalog) {
      _expectCleanEn(g.categoryFor(AppLanguage.en));
      _expectCleanEn(g.definitionFor(AppLanguage.en));
    }
    for (final k in DebtRecordKind.values) {
      _expectCleanEn(k.labelFor(AppLanguage.en));
    }
    for (final r in ruqyahMandiriCatalog) {
      _expectCleanEn(r.titleFor(AppLanguage.en));
      _expectCleanEn(r.repeatLabelFor(AppLanguage.en));
      _expectCleanEn(r.translationFor(AppLanguage.en));
      _expectCleanEn(r.referenceFor(AppLanguage.en));
    }
    for (final m in spiritualMoodCatalog) {
      _expectCleanEn(m.labelFor(AppLanguage.en));
      _expectCleanEn(m.quranicComfortFor(AppLanguage.en));
    }
    for (final s in shalawatCatalog) {
      _expectCleanEn(s.titleFor(AppLanguage.en));
      _expectCleanEn(s.translationFor(AppLanguage.en));
      _expectCleanEn(s.sourceAndVirtueFor(AppLanguage.en));
    }
    for (final h in sunnahHabitsCatalog) {
      _expectCleanEn(h.titleFor(AppLanguage.en));
      _expectCleanEn(h.virtueFor(AppLanguage.en));
    }
    for (final e in eidSunnahChecklistCatalog) {
      _expectCleanEn(e.titleFor(AppLanguage.en));
      _expectCleanEn(e.descriptionFor(AppLanguage.en));
    }
    for (final k in WorshipFocusKind.values) {
      _expectCleanEn(k.labelFor(AppLanguage.en));
    }
    for (final s in HalalAdditiveStatus.values) {
      _expectCleanEn(s.labelFor(AppLanguage.en));
    }
    for (final e in halalENumberCatalog) {
      _expectCleanEn(e.nameFor(AppLanguage.en));
      _expectCleanEn(e.functionInFoodFor(AppLanguage.en));
      _expectCleanEn(e.sourceExplanationFor(AppLanguage.en));
    }
    final adviceEn = evaluateContextualSunnahForTime(DateTime(2026, 4, 3, 6, 30), lang: AppLanguage.en);
    expect(adviceEn.length, 2);
    for (final a in adviceEn) {
      _expectCleanEn(a.timeWindowLabelFor(AppLanguage.en));
      _expectCleanEn(a.titleFor(AppLanguage.en));
      _expectCleanEn(a.subtitleFor(AppLanguage.en));
    }

    final solar = computeSolarShadowQibla(
      coords: const Coordinates(-6.2, 106.8),
      localTime: DateTime(2026, 5, 28, 15, 0),
      utcOffsetHours: 7,
      lang: AppLanguage.en,
    );
    _expectCleanEn(solar.alignmentInstructionFor(AppLanguage.en));

    final safar = evaluateSafarRukhshah(
      originName: 'Jakarta',
      originCoords: const Coordinates(-6.2, 106.8),
      destinationName: 'Bandung',
      destinationCoords: const Coordinates(-6.9175, 107.6191),
      lang: AppLanguage.en,
    );
    _expectCleanEn(safar.summaryFor(AppLanguage.en));
    for (final r in safar.prayerRulesFor(AppLanguage.en)) {
      _expectCleanEn(r);
    }

    final settings = PersonalSettings.defaults;
    final today = settings.timesFor(DateTime(2026, 4, 3));
    final tomorrow = settings.timesFor(DateTime(2026, 4, 4));
    final ext = computeExtendedPrayerWindows(today, tomorrow, lang: AppLanguage.en);
    for (final f in ext.forbiddenWindowsFor(AppLanguage.en)) {
      _expectCleanEn(f.$1);
      _expectCleanEn(f.$4);
    }
    for (final f in fridaySunnahCatalog) {
      _expectCleanEn(f.titleFor(AppLanguage.en));
      _expectCleanEn(f.dalilAndVirtueFor(AppLanguage.en));
    }

    final zm = calculateZakatMaal(
      cashAndSavings: 200000000,
      goldGrams: 10,
      tradeInventory: 0,
      shortTermDebt: 0,
      goldPricePerGram: 1500000,
      lang: AppLanguage.en,
    );
    _expectCleanEn(zm.explanationFor(AppLanguage.en));

    final zp = calculateZakatProfesiMonthly(
      monthlyIncome: 20000000,
      monthlyNeedsOrDebt: 5000000,
      goldPricePerGram: 1500000,
      lang: AppLanguage.en,
    );
    _expectCleanEn(zp.explanationFor(AppLanguage.en));

    final faraid = computeFaraid(
      const FaraidInput(
        grossEstate: 100000000,
        wivesCount: 1,
        sonsCount: 1,
        daughtersCount: 1,
        hasMother: true,
        fullBrothersCount: 1,
      ),
      lang: AppLanguage.en,
    );
    _expectCleanEn(faraid.caseTypeFor(AppLanguage.en));
    _expectCleanEn(faraid.caseExplanationFor(AppLanguage.en));
    for (final s in faraid.shares) {
      _expectCleanEn(s.heirNameFor(AppLanguage.en));
      _expectCleanEn(s.portionLabelFor(AppLanguage.en));
      _expectCleanEn(s.legalReasonFor(AppLanguage.en));
    }

    for (final item in TrackerItem.values) {
      _expectCleanEn(item.labelFor(AppLanguage.en));
    }
    for (final f in FastingType.values) {
      _expectCleanEn(f.labelFor(AppLanguage.en));
      _expectCleanEn(f.descriptionFor(AppLanguage.en));
    }
    final dnd = buildDailyDndWindows(const AutoDndConfig(), today, lang: AppLanguage.en);
    for (final w in dnd) {
      _expectCleanEn(w.labelFor(AppLanguage.en));
    }
    for (final st in HomeWidgetStyle.values) {
      _expectCleanEn(st.labelFor(AppLanguage.en));
      _expectCleanEn(st.descriptionFor(AppLanguage.en));
    }
    const widgetCfg = HomeWidgetConfig();
    expect(widgetCfg.nextPrayerFor(AppLanguage.en), 'Fajr');
    _expectCleanEn(widgetCfg.quoteFor(AppLanguage.en));

    for (final st in ShareCardThemeStyle.values) {
      _expectCleanEn(st.labelFor(AppLanguage.en));
    }
    for (final tpl in defaultShareCardTemplates) {
      _expectCleanEn(tpl.categoryFor(AppLanguage.en));
      _expectCleanEn(tpl.translationFor(AppLanguage.en));
      _expectCleanEn(tpl.sourceFor(AppLanguage.en));
    }
  });
}
