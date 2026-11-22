import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';
import 'l10n_core.dart';

// ================= 46. MODE LANSIA (SENIOR MODE / AKSESIBILITAS TINGGI) =================

class SeniorModeRepository {
  static const _key = 'senior_mode_enabled';
  final KeyValueStore _store;

  const SeniorModeRepository(this._store);

  Future<bool> isEnabled() async => (await _store.read(_key)) == 'true';

  Future<bool> setEnabled(bool enabled) async {
    await _store.write(_key, enabled ? 'true' : 'false');
    return enabled;
  }
}

// ================= 47. TIMER SESI TILAWAH, DZIKIR & I'TIKAF =================

enum WorshipFocusKind {
  tilawah('Fokus Tilawah Al-Qur\'an', 'Quran Reading Focus'),
  dzikir('Fokus Dzikir & Tadabbur', 'Dhikr & Reflection Focus'),
  itikaf('Sesi I\'tikaf & Doa', 'I\'tikaf & Supplication Session');

  final String label;
  final String labelEn;
  const WorshipFocusKind(this.label, this.labelEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
}

class WorshipTimerLog {
  final String id;
  final String dateKey;
  final WorshipFocusKind kind;
  final int durationMinutes;

  const WorshipTimerLog({
    required this.id,
    required this.dateKey,
    required this.kind,
    required this.durationMinutes,
  });

  Map<String, Object> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'kind': kind.name,
        'durationMinutes': durationMinutes,
      };

  factory WorshipTimerLog.fromJson(Map<String, dynamic> j) {
    final kName = j['kind'] as String?;
    final kind = WorshipFocusKind.values.where((e) => e.name == kName).firstOrNull ?? WorshipFocusKind.tilawah;
    return WorshipTimerLog(
      id: j['id'] as String? ?? 't',
      dateKey: j['dateKey'] as String? ?? '',
      kind: kind,
      durationMinutes: ((j['durationMinutes'] as num?)?.toInt() ?? 15).clamp(1, 1440),
    );
  }
}

class WorshipTimerRepository {
  static const _key = 'worship_timer_logs';
  final KeyValueStore _store;

  const WorshipTimerRepository(this._store);

  Future<List<WorshipTimerLog>> allLogs() async {
    final raw = await _store.readJson(_key);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) WorshipTimerLog.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<List<WorshipTimerLog>> logSession({
    required DateTime now,
    required WorshipFocusKind kind,
    required int durationMinutes,
    TrackerRepository? trackerRepo,
  }) async {
    final list = (await allLogs()).toList();
    list.insert(
      0,
      WorshipTimerLog(
        id: '${now.microsecondsSinceEpoch}',
        dateKey: TrackerRepository.dayKey(now),
        kind: kind,
        durationMinutes: durationMinutes.clamp(1, 1440),
      ),
    );
    await _store.writeJson(_key, [for (final l in list) l.toJson()]);

    if (trackerRepo != null) {
      final todayItems = await trackerRepo.day(now);
      final targetItem = kind == WorshipFocusKind.tilawah ? TrackerItem.tilawah : TrackerItem.dzikir;
      if (!todayItems.contains(targetItem)) {
        await trackerRepo.toggle(now, targetItem);
      }
    }
    return list;
  }
}

// ================= 48. RINGKASAN REFLEKSI IBADAH BULANAN & TAHUNAN =================

class WorshipReflectionSummary {
  final int fullPrayerDaysLast30;
  final int totalTilawahPagesLast30;
  final int totalFastingDaysLogged;
  final int totalSedekahRupiahLogged;
  final int totalFocusMinutesLogged;
  final int currentPrayerStreak;
  final int bestPrayerStreak;

  const WorshipReflectionSummary({
    required this.fullPrayerDaysLast30,
    required this.totalTilawahPagesLast30,
    required this.totalFastingDaysLogged,
    required this.totalSedekahRupiahLogged,
    required this.totalFocusMinutesLogged,
    required this.currentPrayerStreak,
    required this.bestPrayerStreak,
  });
}

// ================= 49. REFERENSI KODE BAHAN PANGAN HALAL (E-NUMBER CHECKER) =================

enum HalalAdditiveStatus {
  halal('Halal', 'Halal'),
  syubhat('Syubhat (Wajib Cek Sertifikat Halal)', 'Doubtful (Check Halal Certificate)'),
  haram('Haram', 'Haram');

  final String label;
  final String labelEn;
  const HalalAdditiveStatus(this.label, this.labelEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
}

class ENumberAdditiveItem {
  final String code;
  final String name;
  final String? nameEn;
  final String functionInFood;
  final String? functionInFoodEn;
  final HalalAdditiveStatus status;
  final String sourceExplanation;
  final String? sourceExplanationEn;

  const ENumberAdditiveItem({
    required this.code,
    required this.name,
    this.nameEn,
    required this.functionInFood,
    this.functionInFoodEn,
    required this.status,
    required this.sourceExplanation,
    this.sourceExplanationEn,
  });

  String nameFor(AppLanguage lang) =>
      lang == AppLanguage.en && (nameEn?.isNotEmpty ?? false) ? nameEn! : name;
  String functionInFoodFor(AppLanguage lang) =>
      lang == AppLanguage.en && (functionInFoodEn?.isNotEmpty ?? false) ? functionInFoodEn! : functionInFood;
  String sourceExplanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (sourceExplanationEn?.isNotEmpty ?? false)
          ? sourceExplanationEn!
          : sourceExplanation;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return code.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q) ||
        (nameEn?.toLowerCase().contains(q) ?? false) ||
        functionInFood.toLowerCase().contains(q) ||
        (functionInFoodEn?.toLowerCase().contains(q) ?? false) ||
        sourceExplanation.toLowerCase().contains(q) ||
        (sourceExplanationEn?.toLowerCase().contains(q) ?? false);
  }
}

const List<ENumberAdditiveItem> halalENumberCatalog = [
  ENumberAdditiveItem(
    code: 'E100',
    name: 'Kurkumin (Kunyit)',
    nameEn: 'Curcumin (Turmeric)',
    functionInFood: 'Pewarna kuning alami',
    functionInFoodEn: 'Natural yellow coloring',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Berasal dari ekstrak rimpang kunyit nabati (Curcuma longa); halal dikonsumsi.',
    sourceExplanationEn: 'Extracted from the plant turmeric rhizome (Curcuma longa); halal to consume.',
  ),
  ENumberAdditiveItem(
    code: 'E120',
    name: 'Karmin / Cochineal (Asam Karminat)',
    nameEn: 'Carmine / Cochineal (Carminic Acid)',
    functionInFood: 'Pewarna merah makanan & kosmetik',
    functionInFoodEn: 'Red food & cosmetic coloring',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Diekstrak dari serangga Cochineal. Terdapat perbedaan fatwa ulama; periksa logo Halal resmi pada kemasan.',
    sourceExplanationEn: 'Extracted from Cochineal insects. Scholarly rulings differ; verify an official Halal certification mark on the package.',
  ),
  ENumberAdditiveItem(
    code: 'E160a',
    name: 'Beta-Karoten',
    nameEn: 'Beta-Carotene',
    functionInFood: 'Pewarna oranye/kuning',
    functionInFoodEn: 'Orange/yellow coloring',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Pigmen alami dari wortel dan tumbuhan hijau (pastikan pelarut kapsul bukan gelatin non-halal).',
    sourceExplanationEn: 'Natural pigment from carrots and green plants (ensure any carrier capsule is not non-halal gelatin).',
  ),
  ENumberAdditiveItem(
    code: 'E300',
    name: 'Asam Askorbat (Vitamin C)',
    nameEn: 'Ascorbic Acid (Vitamin C)',
    functionInFood: 'Antioksidan & pengatur keasaman',
    functionInFoodEn: 'Antioxidant & acidity regulator',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Berasal dari sintesis glukosa nabati; halal.',
    sourceExplanationEn: 'Derived from plant-based glucose synthesis; halal.',
  ),
  ENumberAdditiveItem(
    code: 'E322',
    name: 'Lesitin (Lecithin)',
    nameEn: 'Lecithin',
    functionInFood: 'Pengemulsi cokelat, roti & susu',
    functionInFoodEn: 'Emulsifier in chocolate, bread & dairy',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Umumnya halal karena dari kacang kedelai (Soy Lecithin) atau bunga matahari, namun syubhat bila berasal dari lemak hewani tidak bersertifikat.',
    sourceExplanationEn: 'Usually halal when sourced from soy or sunflower, but doubtful if derived from uncertified animal fat.',
  ),
  ENumberAdditiveItem(
    code: 'E330',
    name: 'Asam Sitrat (Citric Acid)',
    nameEn: 'Citric Acid',
    functionInFood: 'Pengatur keasaman minuman & permen',
    functionInFoodEn: 'Acidity regulator in drinks & candies',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Berasal dari buah jeruk atau fermentasi tetes tebu/tapioka; halal.',
    sourceExplanationEn: 'Sourced from citrus fruits or fermentation of sugarcane molasses or tapioca; halal.',
  ),
  ENumberAdditiveItem(
    code: 'E406',
    name: 'Agar-Agar',
    nameEn: 'Agar-Agar',
    functionInFood: 'Pembentuk gel & pengental',
    functionInFoodEn: 'Gelling agent & thickener',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: '100% nabati dari rumput laut merah; pengganti terbaik gelatin hewani.',
    sourceExplanationEn: '100% plant-based from red seaweed; the ideal halal alternative to animal gelatin.',
  ),
  ENumberAdditiveItem(
    code: 'E407',
    name: 'Karagenan',
    nameEn: 'Carrageenan',
    functionInFood: 'Pengental es krim & produk susu',
    functionInFoodEn: 'Thickener in ice cream & dairy products',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Ekstrak rumput laut alami; halal.',
    sourceExplanationEn: 'Natural seaweed extract; halal.',
  ),
  ENumberAdditiveItem(
    code: 'E422',
    name: 'Gliserol / Gliserin',
    nameEn: 'Glycerol / Glycerin',
    functionInFood: 'Pemanis & pelembap makanan/obat',
    functionInFoodEn: 'Sweetener & humectant in food/medicine',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Halal bila dari minyak nabati (kelapa sawit), namun haram/syubhat bila hasil sampingan hidrolisis lemak babi atau hewan tak disembelih syar\'i.',
    sourceExplanationEn: 'Halal when derived from vegetable oils (such as palm oil), but haram or doubtful if obtained from pork fat or non-halal slaughtered animals.',
  ),
  ENumberAdditiveItem(
    code: 'E441',
    name: 'Gelatin',
    nameEn: 'Gelatin',
    functionInFood: 'Pembentuk gel permen kenyal, kapsul & marshmallow',
    functionInFoodEn: 'Gelling agent in gummies, capsules & marshmallows',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Titik kritis tinggi: berasal dari kolagen tulang/kulit hewan. Wajib memastikan bersertifikat Halal (sapi sembelihan syar\'i atau gelatin ikan).',
    sourceExplanationEn: 'High critical point: derived from animal bone or skin collagen. Always confirm official Halal certification (halal-slaughtered beef or fish gelatin).',
  ),
  ENumberAdditiveItem(
    code: 'E471',
    name: 'Mono- dan Digliserida Asam Lemak',
    nameEn: 'Mono- and Diglycerides of Fatty Acids',
    functionInFood: 'Pengemulsi margarin, es krim & roti',
    functionInFoodEn: 'Emulsifier in margarine, ice cream & baked goods',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Dapat dibuat dari minyak nabati (halal) maupun lemak hewani (haram/syubhat). Pastikan produk berlabel Halal resmi.',
    sourceExplanationEn: 'Can be produced from vegetable oils (halal) or animal fats (haram/doubtful). Check for an official Halal label.',
  ),
  ENumberAdditiveItem(
    code: 'E542',
    name: 'Fosfat Tulang (Edible Bone Phosphate)',
    nameEn: 'Edible Bone Phosphate',
    functionInFood: 'Anti-kempal suplemen',
    functionInFoodEn: 'Anti-caking agent in supplements',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Berasal dari ekstrak tulang hewan; haram bila dari babi atau bangkai hewan yang tidak disembelih secara syar\'i.',
    sourceExplanationEn: 'Derived from animal bone extracts; haram if sourced from pigs or animals not slaughtered according to Islamic law.',
  ),
  ENumberAdditiveItem(
    code: 'E621',
    name: 'Mononatrium Glutamat (MSG)',
    nameEn: 'Monosodium Glutamate (MSG)',
    functionInFood: 'Penguat rasa gurih (umami)',
    functionInFoodEn: 'Savory (umami) flavor enhancer',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Diproduksi melalui fermentasi bakteri atas tetes tebu/tapioka (periksa sertifikat halal untuk media enzim fermentasinya).',
    sourceExplanationEn: 'Produced via bacterial fermentation of sugarcane molasses or tapioca (check Halal certification for the fermentation media).',
  ),
  ENumberAdditiveItem(
    code: 'E904',
    name: 'Syelak (Shellac)',
    nameEn: 'Shellac',
    functionInFood: 'Pelapis mengilap permen & cokelat',
    functionInFoodEn: 'Glazing agent on candies & chocolates',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Resin alami yang disekresikan serangga Laccifer lacca (halal bila pelarut alkoholnya telah menguap/bersertifikat halal).',
    sourceExplanationEn: 'Natural resin secreted by the lac insect (Laccifer lacca); halal when no intoxicating solvent remains and certified halal.',
  ),
  ENumberAdditiveItem(
    code: 'E920',
    name: 'L-Sistein (L-Cysteine)',
    nameEn: 'L-Cysteine',
    functionInFood: 'Pelembut adonan tepung & roti',
    functionInFoodEn: 'Dough conditioner in flour & bread',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Haram bila diekstrak dari rambut manusia; syubhat bila dari bulu unggas; halal bila dari fermentasi nabati/sintetis.',
    sourceExplanationEn: 'Haram if extracted from human hair; doubtful if from poultry feathers; halal if produced via microbial or plant fermentation.',
  ),
  ENumberAdditiveItem(
    code: 'MIRIN',
    name: 'Mirin / Angciu / Rhum / Khamr Masak',
    nameEn: 'Mirin / Cooking Wine / Rum / Alcohol Flavoring',
    functionInFood: 'Penyedap masakan beralkohol (khamr)',
    functionInFoodEn: 'Alcoholic cooking seasoning (khamr)',
    status: HalalAdditiveStatus.haram,
    sourceExplanation: 'Termasuk khamr (minuman beralkohol memabukkan) yang haram digunakan meskipun hanya sedikit dalam masakan.',
    sourceExplanationEn: 'Classified as khamr (intoxicating alcohol), which is forbidden even in small quantities in cooking.',
  ),
];

// ================= 50. PENGINGAT SUNNAH KONTEKSTUAL BERBASIS WAKTU =================

class ContextualSunnahAdvice {
  final String id;
  final String timeWindowLabel;
  final String? timeWindowLabelEn;
  final String title;
  final String? titleEn;
  final String subtitle;
  final String? subtitleEn;
  final String actionType; // 'dzikir_pagi' | 'dhuha' | 'alkahfi' | 'dzikir_petang' | 'almulk' | 'tahajud'

  const ContextualSunnahAdvice({
    required this.id,
    required this.timeWindowLabel,
    this.timeWindowLabelEn,
    required this.title,
    this.titleEn,
    required this.subtitle,
    this.subtitleEn,
    required this.actionType,
  });

  String timeWindowLabelFor(AppLanguage lang) =>
      lang == AppLanguage.en && (timeWindowLabelEn?.isNotEmpty ?? false)
          ? timeWindowLabelEn!
          : timeWindowLabel;
  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String subtitleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (subtitleEn?.isNotEmpty ?? false) ? subtitleEn! : subtitle;
}

ContextualSunnahAdvice _advice(
  AppLanguage lang, {
  required String id,
  required String windowId,
  required String windowEn,
  required String titleId,
  required String titleEn,
  required String subtitleId,
  required String subtitleEn,
  required String actionType,
}) =>
    ContextualSunnahAdvice(
      id: id,
      timeWindowLabel: tr(lang, windowId, windowEn),
      timeWindowLabelEn: windowEn,
      title: tr(lang, titleId, titleEn),
      titleEn: titleEn,
      subtitle: tr(lang, subtitleId, subtitleEn),
      subtitleEn: subtitleEn,
      actionType: actionType,
    );

List<ContextualSunnahAdvice> evaluateContextualSunnahForTime(
  DateTime now, {
  AppLanguage lang = AppLanguage.id,
}) {
  final hour = now.hour;
  final isFridayOrThursdayNight =
      now.weekday == DateTime.friday || (now.weekday == DateTime.thursday && hour >= 18);

  final list = <ContextualSunnahAdvice>[];

  if (hour >= 3 && hour < 5) {
    list.add(_advice(
      lang,
      id: 'tahajud_sahur',
      windowId: 'Sepertiga Malam Terakhir & Sahur',
      windowEn: 'Last Third of the Night & Suhoor',
      titleId: 'Waktu Mustajab Tahajud, Witir & Istighfar Sahur',
      titleEn: 'Blessed Time for Tahajjud, Witr & Pre-Dawn Istighfar',
      subtitleId: 'Allah turun ke langit dunia mengabulkan doa dan mengampuni hamba yang memohon ampun di waktu sahur.',
      subtitleEn: 'A precious quiet hour when supplications are answered and those seeking forgiveness before dawn are pardoned.',
      actionType: 'tahajud',
    ));
  } else if (hour >= 5 && hour < 8) {
    list.add(_advice(
      lang,
      id: 'dzikir_pagi',
      windowId: 'Waktu Pagi Ba\'da Subuh',
      windowEn: 'Morning After Fajr',
      titleId: 'Amalkan Dzikir Pagi & Sedekah Subuh',
      titleEn: 'Recite Morning Dhikr & Give Fajr Charity',
      subtitleId: 'Bentengi hari Anda dengan Ayat Kursi, Sayyidul Istighfar, dan dzikir pagi terpandu.',
      subtitleEn: 'Guard your day with Ayat al-Kursi, Sayyidul Istighfar, and guided morning remembrance.',
      actionType: 'dzikir_pagi',
    ));
  } else if (hour >= 8 && hour < 11) {
    list.add(_advice(
      lang,
      id: 'salat_dhuha',
      windowId: 'Waktu Pagi Menjelang Siang',
      windowEn: 'Forenoon Window',
      titleId: 'Saatnya Salat Sunnah Dhuha (2–8 Rakaat)',
      titleEn: 'Time for Duha Prayer (2 to 8 Rak\'ah)',
      subtitleId: 'Dua rakaat Dhuha mencukupi sedekah bagi 360 persendian tubuh Anda hari ini.',
      subtitleEn: 'Two rak\'ah of Duha fulfill charity on behalf of all 360 joints of your body today.',
      actionType: 'dhuha',
    ));
  } else if (hour >= 15 && hour < 18) {
    list.add(_advice(
      lang,
      id: 'dzikir_petang',
      windowId: 'Waktu Petang Ba\'da Ashar',
      windowEn: 'Evening After Asr',
      titleId: 'Amalkan Dzikir Petang Terpandu',
      titleEn: 'Recite Guided Evening Dhikr',
      subtitleId: 'Sempurnakan penjagaan sore dan malam hari dengan rangkaian dzikir petang shahih.',
      subtitleEn: 'Complete your afternoon and evening protection with authentic guided evening remembrances.',
      actionType: 'dzikir_petang',
    ));
  } else if (hour >= 20 || hour < 3) {
    list.add(_advice(
      lang,
      id: 'almulk_muhasabah',
      windowId: 'Menjelang Istirahat Malam',
      windowEn: 'Before Sleeping',
      titleId: 'Baca Surah Al-Mulk, Berwudhu & Muhasabah',
      titleEn: 'Recite Surah Al-Mulk, Make Wudu & Reflect',
      subtitleId: 'Surah Al-Mulk (30 ayat) menjadi penyelamat dari siksa kubur, ditutup dengan evaluasi diri sebelum tidur.',
      subtitleEn: 'Surah Al-Mulk (30 verses) intercedes against the torment of the grave; close your night with quiet self-reflection.',
      actionType: 'almulk',
    ));
  } else {
    list.add(_advice(
      lang,
      id: 'dzikrullah_siang',
      windowId: 'Pertengahan Hari',
      windowEn: 'Midday',
      titleId: 'Jaga Salat Tepat Waktu & Basahi Lisan dengan Dzikir',
      titleEn: 'Guard Timely Prayers & Keep Your Tongue in Dhikr',
      subtitleId: 'Siapkan diri menyambut panggilan adzan Dzuhur/Ashar dan perbanyak istighfar di sela aktivitas.',
      subtitleEn: 'Prepare for the Dhuhr or Asr call to prayer and weave istighfar between daily tasks.',
      actionType: 'dzikir_pagi',
    ));
  }

  if (isFridayOrThursdayNight) {
    list.insert(
      0,
      _advice(
        lang,
        id: 'sunnah_jumat',
        windowId: 'Keberkahan Malam & Hari Jumat',
        windowEn: 'Blessings of Friday & Thursday Night',
        titleId: 'Baca Surah Al-Kahfi & Perbanyak Shalawat Nabi',
        titleEn: 'Recite Surah Al-Kahf & Send Abundant Salawat',
        subtitleId: 'Hari terbaik di mana matahari terbit adalah hari Jumat. Jangan lewatkan Al-Kahfi, shalawat, dan doa akhir Ashar.',
        subtitleEn: 'The best day the sun rises upon is Friday. Do not miss Surah Al-Kahf, salawat, and dua before Maghrib.',
        actionType: 'alkahfi',
      ),
    );
  }

  return list;
}
