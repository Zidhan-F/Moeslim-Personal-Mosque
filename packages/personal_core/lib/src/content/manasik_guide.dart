import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';

class ManasikStep {
  final int order;
  final String title;
  final String? titleEn;
  final String ruling;
  final String? rulingEn;
  final String location;
  final String? locationEn;
  final String description;
  final String? descriptionEn;
  final String arabic;
  final String latin;
  final String translation;
  final String? translationEn;

  const ManasikStep({
    required this.order,
    required this.title,
    this.titleEn,
    required this.ruling,
    this.rulingEn,
    required this.location,
    this.locationEn,
    required this.description,
    this.descriptionEn,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.translationEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String rulingFor(AppLanguage lang) =>
      lang == AppLanguage.en && (rulingEn?.isNotEmpty ?? false) ? rulingEn! : ruling;
  String locationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (locationEn?.isNotEmpty ?? false) ? locationEn! : location;
  String descriptionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (descriptionEn?.isNotEmpty ?? false) ? descriptionEn! : description;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
}

const List<ManasikStep> manasikUmrahHajiSteps = [
  ManasikStep(
    order: 1,
    title: 'Ihram dari Miqat & Membaca Talbiyah',
    titleEn: 'Enter Ihram at the Miqat & Recite Talbiyah',
    ruling: 'Rukun & Wajib',
    rulingEn: 'Pillar & Obligatory',
    location: 'Miqat (Dzulhulaifah / Bir Ali, Juhfah, Qarnul Manazil, Yalamlam)',
    locationEn: 'Miqat (Dhul-Hulayfah / Bir Ali, Al-Juhfah, Qarn al-Manazil, Yalamlam)',
    description:
        'Mandi sunnah ihram, memakai pakaian ihram (2 lembar kain putih tanpa jahitan bagi laki-laki; busana muslimah menutup aurat tanpa cadar/sarung tangan bagi perempuan), berniat ihram dari Miqat, dan memperbanyak Talbiyah.',
    descriptionEn:
        'Take the recommended Ihram bath, wear the Ihram garments (two unstitched white cloths for men; modest attire without face veil or gloves for women), make the intention at the Miqat, and recite the Talbiyah abundantly.',
    arabic: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً ۝ لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    latin:
        'Labbayka Allahumma \'umratan. Labbayka Allahumma labbayk, labbayka la syarika laka labbayk, innal-hamda wan-ni\'mata laka wal-mulk, la syarika lak.',
    translation:
        'Aku penuhi panggilan-Mu ya Allah untuk berumrah. Aku penuhi panggilan-Mu ya Allah, tiada sekutu bagi-Mu. Sesungguhnya segala puji, nikmat, dan kerajaan adalah milik-Mu.',
    translationEn:
        'Here I am, O Allah, for Umrah. Here I am at Your service, O Allah, You have no partner. Truly, all praise, grace, and sovereignty belong to You; You have no partner.',
  ),
  ManasikStep(
    order: 2,
    title: 'Thawaf Mengelilingi Ka\'bah 7 Putaran',
    titleEn: 'Tawaf Around the Ka\'bah (7 Circuits)',
    ruling: 'Rukun',
    rulingEn: 'Pillar',
    location: 'Masjidil Haram (Mulai & berakhir sejajar Hajar Aswad)',
    locationEn: 'Al-Masjid al-Haram (Starts & ends aligned with the Black Stone)',
    description:
        'Dalam keadaan suci dari hadats, mengelilingi Ka\'bah 7 putaran berlawanan arah jarum jam (Ka\'bah di sebelah kiri). Mengucapkan Bismillahi Allahu Akbar saat sejajar Hajar Aswad, dan membaca doa sapu jagat di antara Rukun Yamani dan Hajar Aswad.',
    descriptionEn:
        'In a state of ritual purity, circle the Ka\'bah 7 times counterclockwise (keeping the Ka\'bah to your left). Say "Bismillahi Allahu Akbar" when aligned with the Black Stone, and recite Rabbana atina fid-dunya hasanah between the Yemeni Corner and the Black Stone.',
    arabic: 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ ۝ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    latin: 'Bismillahi wallahu Akbar. Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adzaban-nar.',
    translation: 'Dengan nama Allah dan Allah Mahabesar. Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, serta lindungilah kami dari azab neraka.',
    translationEn: 'In the name of Allah, and Allah is the Greatest. Our Lord, grant us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
  ),
  ManasikStep(
    order: 3,
    title: 'Salat Sunnah 2 Rakaat di Belakang Maqam Ibrahim & Minum Air Zamzam',
    titleEn: 'Pray 2 Rak\'ah Behind Maqam Ibrahim & Drink Zamzam Water',
    ruling: 'Sunnah Muakkadah',
    rulingEn: 'Confirmed Sunnah',
    location: 'Belakang Maqam Ibrahim / Area Masjidil Haram',
    locationEn: 'Behind Maqam Ibrahim / Anywhere inside Al-Masjid al-Haram',
    description:
        'Melaksanakan salat sunnah Thawaf 2 rakaat (rakaat pertama membaca Al-Kafirun, rakaat kedua membaca Al-Ikhlas setelah Al-Fatihah), lalu minum air Zamzam sambil berdoa.',
    descriptionEn:
        'Pray 2 voluntary rak\'ah of Tawaf (reciting Al-Kafirun in the first rak\'ah and Al-Ikhlas in the second after Al-Fatihah), then drink Zamzam water while making heartfelt supplication.',
    arabic: 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
    latin: 'Wattakhidzu min maqami Ibrahima mushalla.',
    translation: 'Dan jadikanlah sebagian Maqam Ibrahim sebagai tempat salat. (QS. Al-Baqarah: 125)',
    translationEn: 'And take from the standing place of Abraham a place of prayer. (Quran 2:125)',
  ),
  ManasikStep(
    order: 4,
    title: 'Sa\'i Antara Bukit Shafa dan Marwah (7 Lintasan)',
    titleEn: 'Sa\'i Between Safa and Marwah (7 Laps)',
    ruling: 'Rukun',
    rulingEn: 'Pillar',
    location: 'Mas\'a (Dimulai dari Bukit Shafa dan berakhir di Bukit Marwah)',
    locationEn: 'Al-Mas\'a (Starts at Mount Safa and ends at Mount Marwah)',
    description:
        'Menuju Bukit Shafa, menghadap Ka\'bah sambil bertakbir dan bertahlil. Berjalan dari Shafa ke Marwah dihitung 1 lintasan, dan dari Marwah ke Shafa dihitung lintasan ke-2, hingga genap 7 lintasan berakhir di Marwah.',
    descriptionEn:
        'Ascend Safa, face the Ka\'bah, and glorify Allah with Takbir and Tahlil. Walking from Safa to Marwah counts as lap 1, and returning from Marwah to Safa counts as lap 2, continuing until lap 7 ends at Marwah.',
    arabic: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
    latin: 'Innash-Shafa wal-Marwata min sya\'a\'irillah.',
    translation: 'Sesungguhnya Shafa dan Marwah adalah sebagian dari syiar-syiar Allah. (QS. Al-Baqarah: 158)',
    translationEn: 'Indeed, Safa and Marwah are among the symbols of Allah. (Quran 2:158)',
  ),
  ManasikStep(
    order: 5,
    title: 'Tahallul (Mencukur / Memendekkan Rambut)',
    titleEn: 'Tahallul (Shaving or Trimming the Hair)',
    ruling: 'Rukun / Wajib',
    rulingEn: 'Pillar / Obligatory',
    location: 'Bukit Marwah / Sekitar Masjidil Haram',
    locationEn: 'Mount Marwah / Around Al-Masjid al-Haram',
    description:
        'Laki-laki menggundul seluruh rambut kepala (halq, lebih utama) atau memendekkan merata (taqshir). Perempuan memotong ujung rambut sepanjang satu ruas jari. Dengan tahallul, selesailah rangkaian Umrah.',
    descriptionEn:
        'Men shave the entire head (halq, preferred) or trim their hair evenly (taqsir). Women trim the tips of their hair by a fingertip\'s length. With Tahallul, the rites of Umrah are complete.',
    arabic: 'اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ',
    latin: 'Allahummaghfir lil-muhalliqin.',
    translation: 'Ya Allah, ampunilah orang-orang yang mencukur bersih rambutnya. (HR. Bukhari & Muslim)',
    translationEn: 'O Allah, forgive those who shave their heads. (Sahih al-Bukhari & Sahih Muslim)',
  ),
  ManasikStep(
    order: 6,
    title: 'Puncak Haji: Wukuf di Arafah, Mabit Muzdalifah & Mina (8–13 Dzulhijjah)',
    titleEn: 'Climax of Hajj: Standing at Arafah, Muzdalifah & Mina (8-13 Dhul-Hijjah)',
    ruling: 'Rukun Puncak Haji',
    rulingEn: 'Core Hajj Pillars',
    location: 'Arafah (9 Dzulhijjah), Muzdalifah & Mina',
    locationEn: 'Arafah (9 Dhul-Hijjah), Muzdalifah & Mina',
    description:
        'Tanggal 8 Dzulhijjah berihram haji menuju Mina (Tarwiyah). Tanggal 9 Dzulhijjah Wukuf di Arafah sejak tergelincir matahari (Dzuhur-Ashar dijama\' qashar) hingga terbenam matahari sambil memperbanyak dzikir dan doa. Malam 10 Dzulhijjah mabit di Muzdalifah, lalu melontar Jumrah Aqabah, menyembelih Hadyu, Tahallul, Thawaf Ifadhah, dan mabit di Mina pada Hari Tasyrik (11–13 Dzulhijjah).',
    descriptionEn:
        'On 8 Dhul-Hijjah (Tarwiyah), enter Hajj Ihram and head to Mina. On 9 Dhul-Hijjah, perform Wuquf at Arafah from midday (combining and shortening Dhuhr and Asr) until sunset with abundant dhikr and dua. Spend the night of 10 Dhul-Hijjah at Muzdalifah, then stone Jamarat al-Aqabah, offer Hady, perform Tahallul and Tawaf al-Ifadah, and stay in Mina during the Days of Tashriq (11-13 Dhul-Hijjah).',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin: 'La ilaha illallahu wahdahu la syarika lah, lahul-mulku wa lahul-hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation: 'Sebaik-baik doa pada hari Arafah: Tiada Tuhan yang berhak disembah selain Allah semata, tiada sekutu bagi-Nya.',
    translationEn: 'The best supplication on the Day of Arafah: There is no deity worthy of worship except Allah alone, without partner; to Him belong sovereignty and praise, and He is capable of all things.',
  ),
];

const List<String> ihramProhibitions = [
  'Memakai pakaian berjahit yang membentuk lekuk tubuh (khusus laki-laki).',
  'Menutup kepala bagi laki-laki atau menutup wajah (cadar) dan memakai sarung tangan bagi perempuan.',
  'Memakai wewangian (parfum) pada badan atau pakaian setelah berniat ihram.',
  'Memotong kuku atau mencukur/mencabut rambut dan bulu badan.',
  'Melakukan akad nikah, melamar, atau berhubungan suami-istri.',
  'Berburu atau membunuh binatang darat buruan di Tanah Haram.',
];

const List<String> ihramProhibitionsEn = [
  'Wearing stitched, form-fitting clothing (for men).',
  'Covering the head (for men) or wearing a face veil (niqab) and gloves (for women).',
  'Applying perfume or scented products to the body or garments after entering Ihram.',
  'Trimming nails or shaving/plucking hair from the head or body.',
  'Conducting a marriage contract, proposing marriage, or marital intimacy.',
  'Hunting or killing wild land game within the Sacred Precinct.',
];

List<String> ihramProhibitionsFor(AppLanguage lang) =>
    lang == AppLanguage.en ? ihramProhibitionsEn : ihramProhibitions;

const List<String> manasikPackingChecklist = [
  'Kain Ihram (2 set untuk laki-laki) & sabuk ihram tanpa jahitan',
  'Busana muslimah longgar & kaos kaki tebal untuk Thawaf/Sa\'i',
  'Gunting kecil lipat untuk Tahallul (masuk bagasi saat penerbangan)',
  'Obat-obatan pribadi, pelembap/vaseline tanpa parfum, dan masker',
  'Salinan paspor, visa, bukti vaksin, dan identitas darurat',
  'Buku saku / aplikasi Moeslim PM offline untuk doa Thawaf, Sa\'i & Wukuf',
];

const List<String> manasikPackingChecklistEn = [
  'Ihram cloths (2 sets for men) & unstitched Ihram belt',
  'Loose modest attire & thick socks for Tawaf and Sa\'i',
  'Small folding scissors for Tahallul (pack in checked luggage)',
  'Personal medication, fragrance-free moisturizer/petroleum jelly, and masks',
  'Copies of passport, visa, vaccination records, and emergency ID',
  'Pocket guide / offline Moeslim PM app for Tawaf, Sa\'i & Arafah duas',
];

List<String> manasikPackingChecklistFor(AppLanguage lang) =>
    lang == AppLanguage.en ? manasikPackingChecklistEn : manasikPackingChecklist;

class ManasikCounterState {
  final int thawafLap; // 0..7
  final int saiLap; // 0..7
  final Set<int> checkedPackingIndexes;

  const ManasikCounterState({
    this.thawafLap = 0,
    this.saiLap = 0,
    this.checkedPackingIndexes = const {},
  });

  String get saiRouteDirection => saiRouteDirectionFor(AppLanguage.id);

  String saiRouteDirectionFor(AppLanguage lang) {
    if (saiLap >= 7) {
      return lang == AppLanguage.en
          ? 'Completed 7 Laps at Mount Marwah (Proceed to Tahallul)'
          : 'Selesai 7 Lintasan di Bukit Marwah (Lanjut Tahallul)';
    }
    final nextLap = saiLap + 1;
    if (lang == AppLanguage.en) {
      return nextLap.isOdd
          ? 'Lap $nextLap: Mount Safa toward Mount Marwah'
          : 'Lap $nextLap: Mount Marwah toward Mount Safa';
    }
    return nextLap.isOdd
        ? 'Lintasan ke-$nextLap: Bukit Shafa menuju Bukit Marwah'
        : 'Lintasan ke-$nextLap: Bukit Marwah menuju Bukit Shafa';
  }

  ManasikCounterState copyWith({
    int? thawafLap,
    int? saiLap,
    Set<int>? checkedPackingIndexes,
  }) =>
      ManasikCounterState(
        thawafLap: (thawafLap ?? this.thawafLap).clamp(0, 7),
        saiLap: (saiLap ?? this.saiLap).clamp(0, 7),
        checkedPackingIndexes: checkedPackingIndexes ?? this.checkedPackingIndexes,
      );

  Map<String, Object> toJson() => {
        'thawafLap': thawafLap,
        'saiLap': saiLap,
        'checkedPackingIndexes': checkedPackingIndexes.toList()..sort(),
      };

  factory ManasikCounterState.fromJson(Map<String, dynamic> j) {
    final rawSet = j['checkedPackingIndexes'];
    final set = <int>{};
    if (rawSet is List) {
      for (final x in rawSet) {
        if (x is num) set.add(x.toInt());
      }
    }
    return ManasikCounterState(
      thawafLap: ((j['thawafLap'] as num?)?.toInt() ?? 0).clamp(0, 7),
      saiLap: ((j['saiLap'] as num?)?.toInt() ?? 0).clamp(0, 7),
      checkedPackingIndexes: set,
    );
  }
}

class ManasikRepository {
  static const _key = 'manasik_counter';
  final KeyValueStore _store;

  const ManasikRepository(this._store);

  Future<ManasikCounterState> load() async {
    final raw = await _store.readJson(_key);
    if (raw is! Map) return const ManasikCounterState();
    return ManasikCounterState.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<ManasikCounterState> save(ManasikCounterState state) async {
    await _store.writeJson(_key, state.toJson());
    return state;
  }
}
