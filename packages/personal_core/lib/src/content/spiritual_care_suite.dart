import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';
import 'daily_dua.dart';

// ================= 36. PANDUAN RUQYAH SYAR'IYYAH MANDIRI =================

class RuqyahReadingItem {
  final int order;
  final String title;
  final String repeatLabel;
  final String arabic;
  final String latin;
  final String translation;
  final String reference;
  final int? linkedSurah;

  const RuqyahReadingItem({
    required this.order,
    required this.title,
    required this.repeatLabel,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.reference,
    this.linkedSurah,
  });
}

const List<RuqyahReadingItem> ruqyahMandiriCatalog = [
  RuqyahReadingItem(
    order: 1,
    title: 'Surah Al-Fatihah (Ummul Kitab / Asy-Syifa)',
    repeatLabel: 'Dibaca 1x / 3x / 7x',
    arabic:
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    latin:
        'Bismillahir-Rahmanir-Rahim. Al-hamdu lillahi Rabbil-\'alamin. Ar-Rahmanir-Rahim. Maliki yawmid-din. Iyyaka na\'budu wa iyyaka nasta\'in. Ihdinash-shirathal-mustaqim...',
    translation:
        'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang. Segala puji bagi Allah, Tuhan seluruh alam... Tunjukilah kami jalan yang lurus.',
    reference: 'HR. Bukhari no. 2276 (Sahabat meruqyah dengan Al-Fatihah dan dibenarkan Nabi SAW)',
    linkedSurah: 1,
  ),
  RuqyahReadingItem(
    order: 2,
    title: 'Ayat Kursi (QS. Al-Baqarah: 255)',
    repeatLabel: 'Dibaca 1x',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...',
    latin: 'Allahu la ilaha illa Huwal-Hayyul-Qayyum, la ta\'khudzuhu sinatun wa la naum...',
    translation: 'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus makhluk-Nya.',
    reference: 'HR. Bukhari no. 2311 (Penjagaan Allah dari gangguan setan)',
    linkedSurah: 2,
  ),
  RuqyahReadingItem(
    order: 3,
    title: 'Al-Mu\'awwidzat (Al-Ikhlas, Al-Falaq & An-Nas)',
    repeatLabel: 'Dibaca 3x sambil mengusap tubuh',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ... ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
    latin: 'Qul Huwallahu Ahad... Qul a\'udzu birabbil-falaq... Qul a\'udzu birabbin-nas...',
    translation: 'Membaca Al-Ikhlas, Al-Falaq, dan An-Nas, meniupkan lembut ke kedua telapak tangan lalu mengusapkannya ke kepala, wajah, dan bagian tubuh yang terjangkau.',
    reference: 'HR. Bukhari no. 5017 & Muslim no. 2192 (Dari Aisyah RA)',
    linkedSurah: 112,
  ),
  RuqyahReadingItem(
    order: 4,
    title: 'Doa Ruqyah Memegang Bagian Tubuh yang Sakit',
    repeatLabel: 'Bismillah 3x + Doa 7x',
    arabic: 'بِسْمِ اللَّهِ (٣×) أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (٧×)',
    latin: 'Bismillah (3x). A\'udzu billahi wa qudratihi min syarri ma ajidu wa uhadziru (7x).',
    translation:
        'Dengan nama Allah (3x). Aku berlindung kepada Allah dan kekuasaan-Nya dari keburukan penyakit yang aku rasakan dan yang aku khawatirkan (7x).',
    reference: 'HR. Muslim no. 2202 (Wasiat Nabi SAW kepada Utsman bin Abil \'Ash RA)',
  ),
  RuqyahReadingItem(
    order: 5,
    title: 'Doa Kesembuhan kepada Asy-Syafi',
    repeatLabel: 'Dibaca 1x / 3x',
    arabic:
        'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
    latin:
        'Allahumma Rabban-nas, adzhibil-ba\'sa, isyfi Antasy-Syafi, la syifa\'a illa syifa\'uka, syifa\'an la yughadiru saqama.',
    translation:
        'Ya Allah, Tuhan seluruh manusia, hilangkanlah penyakit ini, sembuhkanlah karena Engkaulah Yang Maha Menyembuhkan. Tiada kesembuhan selain kesembuhan dari-Mu, kesembuhan yang tidak meninggalkan rasa sakit.',
    reference: 'HR. Bukhari no. 5743 & Muslim no. 2191',
  ),
];

// ================= 37. PENCARI DOA BERBASIS KONDISI / SUASANA HATI =================

class SpiritualMoodCondition {
  final String id;
  final String label;
  final String quranicComfort;
  final List<String> searchKeywords;

  const SpiritualMoodCondition({
    required this.id,
    required this.label,
    required this.quranicComfort,
    required this.searchKeywords,
  });
}

const List<SpiritualMoodCondition> spiritualMoodCatalog = [
  SpiritualMoodCondition(
    id: 'gelisah',
    label: 'Gelisah & Cemas',
    quranicComfort: 'QS. Ar-Ra\'d: 28: "Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram."',
    searchKeywords: ['gelisah', 'sedih', 'takut', 'hati', 'tidur', 'lindung'],
  ),
  SpiritualMoodCondition(
    id: 'sedih',
    label: 'Sedih & Duka',
    quranicComfort: 'QS. At-Taubah: 40: "Janganlah engkau bersedih, sesungguhnya Allah bersama kita."',
    searchKeywords: ['sedih', 'musibah', 'duka', 'ampun', 'rahmat'],
  ),
  SpiritualMoodCondition(
    id: 'marah',
    label: 'Marah & Emosi',
    quranicComfort: 'QS. Ali \'Imran: 134: "...dan orang-orang yang menahan amarahnya serta memaafkan kesalahan orang lain."',
    searchKeywords: ['marah', 'setan', 'lindung', 'sabar'],
  ),
  SpiritualMoodCondition(
    id: 'sakit',
    label: 'Sakit & Lelah',
    quranicComfort: 'QS. Asy-Syu\'ara: 80: "Dan apabila aku sakit, Dialah (Allah) yang menyembuhkanku."',
    searchKeywords: ['sakit', 'sembuh', 'sehat', 'afiyat', 'tubuh'],
  ),
  SpiritualMoodCondition(
    id: 'ujian',
    label: 'Kesulitan & Utang',
    quranicComfort: 'QS. Ath-Thalaq: 2–3: "Barang siapa bertakwa kepada Allah niscaya Dia akan membukakan jalan keluar baginya."',
    searchKeywords: ['utang', 'sulit', 'mudah', 'rezeki', 'cukup'],
  ),
  SpiritualMoodCondition(
    id: 'safar',
    label: 'Safar & Perjalanan',
    quranicComfort: 'QS. Az-Zukhruf: 13–14: "Mahasuci Tuhan yang telah menundukkan semua ini bagi kami."',
    searchKeywords: ['kendaraan', 'safar', 'perjalanan', 'keluar rumah', 'pulang'],
  ),
  SpiritualMoodCondition(
    id: 'syukur',
    label: 'Bahagia & Syukur',
    quranicComfort: 'QS. Ibrahim: 7: "Jika kalian bersyukur, pasti Aku akan menambah (nikmat) kepada kalian."',
    searchKeywords: ['syukur', 'nikmat', 'pujian', 'makan', 'berkah'],
  ),
  SpiritualMoodCondition(
    id: 'keluarga',
    label: 'Keluarga & Ilmu',
    quranicComfort: 'QS. Al-Furqan: 74: "Ya Tuhan kami, anugerahkanlah kepada kami pasangan dan keturunan sebagai penyejuk hati."',
    searchKeywords: ['orang tua', 'anak', 'keluarga', 'ilmu', 'rumah'],
  ),
];

List<DailyDua> filterDailyDuasByMood(List<DailyDua> all, SpiritualMoodCondition mood) {
  final matches = <DailyDua>[];
  for (final d in all) {
    final hit = mood.searchKeywords.any((kw) => d.matches(kw));
    if (hit) matches.add(d);
    if (matches.length >= 25) break;
  }
  return matches.isEmpty ? all.take(10).toList() : matches;
}

// ================= 38. KOLEKSI SHALAWAT MA'TSUR & COUNTER =================

class ShalawatReading {
  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String sourceAndVirtue;

  const ShalawatReading({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.sourceAndVirtue,
  });
}

const List<ShalawatReading> shalawatCatalog = [
  ShalawatReading(
    id: 'ibrahimiyah',
    title: 'Shalawat Ibrahimiyah (Paling Utama & Shahih)',
    arabic:
        'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin:
        'Allahumma shalli \'ala Muhammad wa \'ala ali Muhammad, kama shallayta \'ala Ibrahim wa \'ala ali Ibrahim, innaka Hamidum Majid. Allahumma barik \'ala Muhammad wa \'ala ali Muhammad, kama barakta \'ala Ibrahim wa \'ala ali Ibrahim, innaka Hamidum Majid.',
    translation:
        'Ya Allah, limpahkanlah rahmat kepada Muhammad dan keluarga Muhammad sebagaimana Engkau melimpahkan rahmat kepada Ibrahim dan keluarga Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Mahamulia.',
    sourceAndVirtue: 'HR. Bukhari no. 3370 & Muslim no. 406 (Shalawat yang diajarkan langsung oleh Rasulullah SAW kepada para sahabat)',
  ),
  ShalawatReading(
    id: 'ringkas_matsur',
    title: 'Shalawat Ringkas Ma\'tsur',
    arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
    latin: 'Allahumma shalli wa sallim \'ala Nabiyyina Muhammad.',
    translation: 'Ya Allah, limpahkanlah shalawat dan salam kepada Nabi kami Muhammad.',
    sourceAndVirtue: 'HR. Muslim no. 408: "Barang siapa bershalawat kepadaku satu kali, niscaya Allah bershalawat (melimpahkan rahmat) kepadanya sepuluh kali."',
  ),
  ShalawatReading(
    id: 'dzurriyah',
    title: 'Shalawat Nabi beserta Istri & Keturunan Beliau',
    arabic:
        'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا صَلَّيْتَ عَلَىٰ آلِ إِبْرَاهِيمَ، وَبَارِكْ عَلَىٰ مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا بَارَكْتَ عَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin:
        'Allahumma shalli \'ala Muhammadin wa azwajihi wa dzurriyyatihi, kama shallayta \'ala ali Ibrahim, wa barik \'ala Muhammadin wa azwajihi wa dzurriyyatihi, kama barakta \'ala ali Ibrahim, innaka Hamidum Majid.',
    translation:
        'Ya Allah, limpahkanlah rahmat kepada Muhammad, istri-istri beliau, dan keturunan beliau, sebagaimana Engkau telah melimpahkan rahmat kepada keluarga Ibrahim.',
    sourceAndVirtue: 'HR. Bukhari no. 3369 & Muslim no. 407 (Dari Abu Humaid As-Sa\'idi RA)',
  ),
];

class ShalawatCounterRepository {
  static const _key = 'shalawat_counter_state';
  final KeyValueStore _store;

  const ShalawatCounterRepository(this._store);

  Future<({int count, int target})> loadForDay(DateTime day) async {
    final raw = await _store.readJson(_key);
    if (raw is! Map) return (count: 0, target: 100);
    final dayKey = TrackerRepository.dayKey(day);
    final savedDay = raw['dayKey'] as String?;
    final target = ((raw['target'] as num?)?.toInt() ?? 100).clamp(10, 10000);
    final count = savedDay == dayKey ? (((raw['count'] as num?)?.toInt() ?? 0).clamp(0, 100000)) : 0;
    return (count: count, target: target);
  }

  Future<({int count, int target})> increment(DateTime day, {int step = 1}) async {
    final current = await loadForDay(day);
    final nextCount = (current.count + step).clamp(0, 100000);
    await _store.writeJson(_key, {
      'dayKey': TrackerRepository.dayKey(day),
      'count': nextCount,
      'target': current.target,
    });
    return (count: nextCount, target: current.target);
  }

  Future<({int count, int target})> setTarget(DateTime day, int target) async {
    final current = await loadForDay(day);
    final safeTarget = target.clamp(10, 10000);
    await _store.writeJson(_key, {
      'dayKey': TrackerRepository.dayKey(day),
      'count': current.count,
      'target': safeTarget,
    });
    return (count: current.count, target: safeTarget);
  }
}

// ================= 39. DAFTAR HAJAT & DOA PRIBADI (PRAYER LIST) =================

class PersonalHajatItem {
  final String id;
  final String title;
  final String category;
  final String createdAtKey;
  final bool isAnswered;

  const PersonalHajatItem({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAtKey,
    this.isAnswered = false,
  });

  PersonalHajatItem copyWith({bool? isAnswered}) => PersonalHajatItem(
        id: id,
        title: title,
        category: category,
        createdAtKey: createdAtKey,
        isAnswered: isAnswered ?? this.isAnswered,
      );

  Map<String, Object> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'createdAtKey': createdAtKey,
        'isAnswered': isAnswered,
      };

  factory PersonalHajatItem.fromJson(Map<String, dynamic> j) => PersonalHajatItem(
        id: j['id'] as String? ?? 'h',
        title: j['title'] as String? ?? '',
        category: j['category'] as String? ?? 'Diri Sendiri & Keluarga',
        createdAtKey: j['createdAtKey'] as String? ?? '',
        isAnswered: j['isAnswered'] as bool? ?? false,
      );
}

class HajatPrayerListRepository {
  static const _key = 'hajat_prayer_list';
  final KeyValueStore _store;

  const HajatPrayerListRepository(this._store);

  Future<List<PersonalHajatItem>> allItems() async {
    final raw = await _store.readJson(_key);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) PersonalHajatItem.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<List<PersonalHajatItem>> addHajat({
    required String title,
    required String category,
    required DateTime now,
  }) async {
    final list = (await allItems()).toList();
    list.insert(
      0,
      PersonalHajatItem(
        id: '${now.microsecondsSinceEpoch}',
        title: title.trim(),
        category: category,
        createdAtKey: TrackerRepository.dayKey(now),
      ),
    );
    await _store.writeJson(_key, [for (final i in list) i.toJson()]);
    return list;
  }

  Future<List<PersonalHajatItem>> toggleAnswered(String id) async {
    final list = [
      for (final i in await allItems()) i.id == id ? i.copyWith(isAnswered: !i.isAnswered) : i,
    ];
    await _store.writeJson(_key, [for (final i in list) i.toJson()]);
    return list;
  }

  Future<List<PersonalHajatItem>> deleteHajat(String id) async {
    final list = (await allItems()).where((i) => i.id != id).toList();
    await _store.writeJson(_key, [for (final i in list) i.toJson()]);
    return list;
  }
}

// ================= 40. PELACAK KEBIASAAN SUNNAH HARIAN (RAWATIB, DHUHA, WITIR) =================

class SunnahHabitSpec {
  final String id;
  final String title;
  final int rakaatCount;
  final bool isRawatib12;
  final String virtue;

  const SunnahHabitSpec({
    required this.id,
    required this.title,
    required this.rakaatCount,
    required this.isRawatib12,
    required this.virtue,
  });
}

const List<SunnahHabitSpec> sunnahHabitsCatalog = [
  SunnahHabitSpec(
    id: 'qabliyah_subuh',
    title: '2 Rakaat Qabliyah Subuh',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'HR. Muslim no. 725: "Dua rakaat fajar (Qabliyah Subuh) lebih baik daripada dunia dan seisinya."',
  ),
  SunnahHabitSpec(
    id: 'qabliyah_dzuhur',
    title: '4 Rakaat Qabliyah Dzuhur',
    rakaatCount: 4,
    isRawatib12: true,
    virtue: 'Bagian dari 12 rakaat Rawatib yang dijanjikan rumah di surga (HR. Muslim no. 728).',
  ),
  SunnahHabitSpec(
    id: 'badiyah_dzuhur',
    title: '2 Rakaat Ba\'diyah Dzuhur',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'Bagian dari 12 rakaat Rawatib muakkadah setelah Salat Dzuhur.',
  ),
  SunnahHabitSpec(
    id: 'badiyah_maghrib',
    title: '2 Rakaat Ba\'diyah Maghrib',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'Bagian dari 12 rakaat Rawatib setelah Salat Maghrib.',
  ),
  SunnahHabitSpec(
    id: 'badiyah_isya',
    title: '2 Rakaat Ba\'diyah Isya',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'Melengkapi genap 12 rakaat Rawatib harian.',
  ),
  SunnahHabitSpec(
    id: 'salat_dhuha',
    title: 'Salat Sunnah Dhuha (Minimal 2 Rakaat)',
    rakaatCount: 2,
    isRawatib12: false,
    virtue: 'HR. Muslim no. 720: Mencukupi sedekah bagi 360 persendian tubuh setiap pagi.',
  ),
  SunnahHabitSpec(
    id: 'salat_witir',
    title: 'Salat Sunnah Witir Penutup Malam',
    rakaatCount: 3,
    isRawatib12: false,
    virtue: 'HR. Bukhari no. 998: "Jadikanlah akhir salat malam kalian adalah salat Witir."',
  ),
  SunnahHabitSpec(
    id: 'wudhu_sebelum_tidur',
    title: 'Berwudhu & Dzikir Sebelum Tidur',
    rakaatCount: 0,
    isRawatib12: false,
    virtue: 'HR. Bukhari no. 247: Tidur dalam keadaan suci didoakan ampunan oleh malaikat.',
  ),
];

class SunnahHabitRepository {
  static const _key = 'sunnah_habit_logs';
  final KeyValueStore _store;

  const SunnahHabitRepository(this._store);

  Future<Set<String>> completedForDate(DateTime date) async {
    final raw = await _store.readJson(_key);
    if (raw is! Map) return {};
    final list = raw[TrackerRepository.dayKey(date)];
    if (list is! List) return {};
    return {
      for (final x in list)
        if (x is String) x,
    };
  }

  Future<Set<String>> toggleHabit(DateTime date, String habitId) async {
    final raw = await _store.readJson(_key);
    final all = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final current = await completedForDate(date);
    if (!current.remove(habitId)) {
      current.add(habitId);
    }
    all[TrackerRepository.dayKey(date)] = current.toList();
    await _store.writeJson(_key, all);
    return current;
  }
}
