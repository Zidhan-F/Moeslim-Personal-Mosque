import '../storage/key_value_store.dart';

class ManasikStep {
  final int order;
  final String title;
  final String ruling;
  final String location;
  final String description;
  final String arabic;
  final String latin;
  final String translation;

  const ManasikStep({
    required this.order,
    required this.title,
    required this.ruling,
    required this.location,
    required this.description,
    required this.arabic,
    required this.latin,
    required this.translation,
  });
}

const List<ManasikStep> manasikUmrahHajiSteps = [
  ManasikStep(
    order: 1,
    title: 'Ihram dari Miqat & Membaca Talbiyah',
    ruling: 'Rukun & Wajib',
    location: 'Miqat (Dzulhulaifah / Bir Ali, Juhfah, Qarnul Manazil, Yalamlam)',
    description:
        'Mandi sunnah ihram, memakai pakaian ihram (2 lembar kain putih tanpa jahitan bagi laki-laki; busana muslimah menutup aurat tanpa cadar/sarung tangan bagi perempuan), berniat ihram dari Miqat, dan memperbanyak Talbiyah.',
    arabic: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً ۝ لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    latin:
        'Labbayka Allahumma \'umratan. Labbayka Allahumma labbayk, labbayka la syarika laka labbayk, innal-hamda wan-ni\'mata laka wal-mulk, la syarika lak.',
    translation:
        'Aku penuhi panggilan-Mu ya Allah untuk berumrah. Aku penuhi panggilan-Mu ya Allah, tiada sekutu bagi-Mu. Sesungguhnya segala puji, nikmat, dan kerajaan adalah milik-Mu.',
  ),
  ManasikStep(
    order: 2,
    title: 'Thawaf Mengelilingi Ka\'bah 7 Putaran',
    ruling: 'Rukun',
    location: 'Masjidil Haram (Mulai & berakhir sejajar Hajar Aswad)',
    description:
        'Dalam keadaan suci dari hadats, mengelilingi Ka\'bah 7 putaran berlawanan arah jarum jam (Ka\'bah di sebelah kiri). Mengucapkan Bismillahi Allahu Akbar saat sejajar Hajar Aswad, dan membaca doa sapu jagat di antara Rukun Yamani dan Hajar Aswad.',
    arabic: 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ ۝ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    latin: 'Bismillahi wallahu Akbar. Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adzaban-nar.',
    translation: 'Dengan nama Allah dan Allah Mahabesar. Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, serta lindungilah kami dari azab neraka.',
  ),
  ManasikStep(
    order: 3,
    title: 'Salat Sunnah 2 Rakaat di Belakang Maqam Ibrahim & Minum Air Zamzam',
    ruling: 'Sunnah Muakkadah',
    location: 'Belakang Maqam Ibrahim / Area Masjidil Haram',
    description:
        'Melaksanakan salat sunnah Thawaf 2 rakaat (rakaat pertama membaca Al-Kafirun, rakaat kedua membaca Al-Ikhlas setelah Al-Fatihah), lalu minum air Zamzam sambil berdoa.',
    arabic: 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
    latin: 'Wattakhidzu min maqami Ibrahima mushalla.',
    translation: 'Dan jadikanlah sebagian Maqam Ibrahim sebagai tempat salat. (QS. Al-Baqarah: 125)',
  ),
  ManasikStep(
    order: 4,
    title: 'Sa\'i Antara Bukit Shafa dan Marwah (7 Lintasan)',
    ruling: 'Rukun',
    location: 'Mas\'a (Dimulai dari Bukit Shafa dan berakhir di Bukit Marwah)',
    description:
        'Menuju Bukit Shafa, menghadap Ka\'bah sambil bertakbir dan bertahlil. Berjalan dari Shafa ke Marwah dihitung 1 lintasan, dan dari Marwah ke Shafa dihitung lintasan ke-2, hingga genap 7 lintasan berakhir di Marwah.',
    arabic: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
    latin: 'Innash-Shafa wal-Marwata min sya\'a\'irillah.',
    translation: 'Sesungguhnya Shafa dan Marwah adalah sebagian dari syiar-syiar Allah. (QS. Al-Baqarah: 158)',
  ),
  ManasikStep(
    order: 5,
    title: 'Tahallul (Mencukur / Memendekkan Rambut)',
    ruling: 'Rukun / Wajib',
    location: 'Bukit Marwah / Sekitar Masjidil Haram',
    description:
        'Laki-laki menggundul seluruh rambut kepala (halq, lebih utama) atau memendekkan merata (taqshir). Perempuan memotong ujung rambut sepanjang satu ruas jari. Dengan tahallul, selesailah rangkaian Umrah.',
    arabic: 'اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ',
    latin: 'Allahummaghfir lil-muhalliqin.',
    translation: 'Ya Allah, ampunilah orang-orang yang mencukur bersih rambutnya. (HR. Bukhari & Muslim)',
  ),
  ManasikStep(
    order: 6,
    title: 'Puncak Haji: Wukuf di Arafah, Mabit Muzdalifah & Mina (8–13 Dzulhijjah)',
    ruling: 'Rukun Puncak Haji',
    location: 'Arafah (9 Dzulhijjah), Muzdalifah & Mina',
    description:
        'Tanggal 8 Dzulhijjah berihram haji menuju Mina (Tarwiyah). Tanggal 9 Dzulhijjah Wukuf di Arafah sejak tergelincir matahari (Dzuhur-Ashar dijama\' qashar) hingga terbenam matahari sambil memperbanyak dzikir dan doa. Malam 10 Dzulhijjah mabit di Muzdalifah, lalu melontar Jumrah Aqabah, menyembelih Hadyu, Tahallul, Thawaf Ifadhah, dan mabit di Mina pada Hari Tasyrik (11–13 Dzulhijjah).',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin: 'La ilaha illallahu wahdahu la syarika lah, lahul-mulku wa lahul-hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation: 'Sebaik-baik doa pada hari Arafah: Tiada Tuhan yang berhak disembah selain Allah semata, tiada sekutu bagi-Nya.',
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

const List<String> manasikPackingChecklist = [
  'Kain Ihram (2 set untuk laki-laki) & sabuk ihram tanpa jahitan',
  'Busana muslimah longgar & kaos kaki tebal untuk Thawaf/Sa\'i',
  'Gunting kecil lipat untuk Tahallul (masuk bagasi saat penerbangan)',
  'Obat-obatan pribadi, pelembap/vaseline tanpa parfum, dan masker',
  'Salinan paspor, visa, bukti vaksin, dan identitas darurat',
  'Buku saku / aplikasi Moeslim PM offline untuk doa Thawaf, Sa\'i & Wukuf',
];

class ManasikCounterState {
  final int thawafLap; // 0..7
  final int saiLap; // 0..7
  final Set<int> checkedPackingIndexes;

  const ManasikCounterState({
    this.thawafLap = 0,
    this.saiLap = 0,
    this.checkedPackingIndexes = const {},
  });

  String get saiRouteDirection {
    if (saiLap >= 7) return 'Selesai 7 Lintasan di Bukit Marwah (Lanjut Tahallul)';
    final nextLap = saiLap + 1;
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
