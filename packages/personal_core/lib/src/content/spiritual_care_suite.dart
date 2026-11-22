import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';
import 'daily_dua.dart';

// ================= 36. PANDUAN RUQYAH SYAR'IYYAH MANDIRI =================

class RuqyahReadingItem {
  final int order;
  final String title;
  final String? titleEn;
  final String repeatLabel;
  final String? repeatLabelEn;
  final String arabic;
  final String latin;
  final String translation;
  final String? translationEn;
  final String reference;
  final String? referenceEn;
  final int? linkedSurah;

  const RuqyahReadingItem({
    required this.order,
    required this.title,
    this.titleEn,
    required this.repeatLabel,
    this.repeatLabelEn,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.translationEn,
    required this.reference,
    this.referenceEn,
    this.linkedSurah,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String repeatLabelFor(AppLanguage lang) =>
      lang == AppLanguage.en && (repeatLabelEn?.isNotEmpty ?? false) ? repeatLabelEn! : repeatLabel;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
  String referenceFor(AppLanguage lang) =>
      lang == AppLanguage.en && (referenceEn?.isNotEmpty ?? false) ? referenceEn! : reference;
}

const List<RuqyahReadingItem> ruqyahMandiriCatalog = [
  RuqyahReadingItem(
    order: 1,
    title: 'Surah Al-Fatihah (Ummul Kitab / Asy-Syifa)',
    titleEn: 'Surah Al-Fatihah (The Opening / The Healing)',
    repeatLabel: 'Dibaca 1x / 3x / 7x',
    repeatLabelEn: 'Recite 1x / 3x / 7x',
    arabic:
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    latin:
        'Bismillahir-Rahmanir-Rahim. Al-hamdu lillahi Rabbil-\'alamin. Ar-Rahmanir-Rahim. Maliki yawmid-din. Iyyaka na\'budu wa iyyaka nasta\'in. Ihdinash-shirathal-mustaqim...',
    translation:
        'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang. Segala puji bagi Allah, Tuhan seluruh alam... Tunjukilah kami jalan yang lurus.',
    translationEn:
        'In the name of Allah, the Entirely Merciful, the Especially Merciful. All praise is due to Allah, Lord of the worlds... Guide us to the straight path.',
    reference: 'HR. Bukhari no. 2276 (Sahabat meruqyah dengan Al-Fatihah dan dibenarkan Nabi SAW)',
    referenceEn: 'Sahih al-Bukhari 2276 (Companions performed ruqyah with Al-Fatihah and the Prophet approved)',
    linkedSurah: 1,
  ),
  RuqyahReadingItem(
    order: 2,
    title: 'Ayat Kursi (QS. Al-Baqarah: 255)',
    titleEn: 'Ayat al-Kursi (Quran 2:255)',
    repeatLabel: 'Dibaca 1x',
    repeatLabelEn: 'Recite 1x',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...',
    latin: 'Allahu la ilaha illa Huwal-Hayyul-Qayyum, la ta\'khudzuhu sinatun wa la naum...',
    translation: 'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus makhluk-Nya.',
    translationEn: 'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence.',
    reference: 'HR. Bukhari no. 2311 (Penjagaan Allah dari gangguan setan)',
    referenceEn: 'Sahih al-Bukhari 2311 (Allah\'s protection against satanic harm)',
    linkedSurah: 2,
  ),
  RuqyahReadingItem(
    order: 3,
    title: 'Al-Mu\'awwidzat (Al-Ikhlas, Al-Falaq & An-Nas)',
    titleEn: 'Al-Mu\'awwidhat (Al-Ikhlas, Al-Falaq & An-Nas)',
    repeatLabel: 'Dibaca 3x sambil mengusap tubuh',
    repeatLabelEn: 'Recite 3x while wiping over the body',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ... ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
    latin: 'Qul Huwallahu Ahad... Qul a\'udzu birabbil-falaq... Qul a\'udzu birabbin-nas...',
    translation: 'Membaca Al-Ikhlas, Al-Falaq, dan An-Nas, meniupkan lembut ke kedua telapak tangan lalu mengusapkannya ke kepala, wajah, dan bagian tubuh yang terjangkau.',
    translationEn: 'Recite Al-Ikhlas, Al-Falaq, and An-Nas, blow gently into cupped palms, and wipe over the head, face, and as much of the body as you can reach.',
    reference: 'HR. Bukhari no. 5017 & Muslim no. 2192 (Dari Aisyah RA)',
    referenceEn: 'Sahih al-Bukhari 5017 & Sahih Muslim 2192 (Narrated by Aisha RA)',
    linkedSurah: 112,
  ),
  RuqyahReadingItem(
    order: 4,
    title: 'Doa Ruqyah Memegang Bagian Tubuh yang Sakit',
    titleEn: 'Ruqyah Supplication Placing Hand on the Area of Pain',
    repeatLabel: 'Bismillah 3x + Doa 7x',
    repeatLabelEn: 'Bismillah 3x + Supplication 7x',
    arabic: 'بِسْمِ اللَّهِ (٣×) أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (٧×)',
    latin: 'Bismillah (3x). A\'udzu billahi wa qudratihi min syarri ma ajidu wa uhadziru (7x).',
    translation:
        'Dengan nama Allah (3x). Aku berlindung kepada Allah dan kekuasaan-Nya dari keburukan penyakit yang aku rasakan dan yang aku khawatirkan (7x).',
    translationEn:
        'In the name of Allah (3x). I seek refuge in Allah and His power from the evil of what I feel and what I guard against (7x).',
    reference: 'HR. Muslim no. 2202 (Wasiat Nabi SAW kepada Utsman bin Abil \'Ash RA)',
    referenceEn: 'Sahih Muslim 2202 (Counsel of the Prophet to Uthman ibn Abi al-\'As RA)',
  ),
  RuqyahReadingItem(
    order: 5,
    title: 'Doa Kesembuhan kepada Asy-Syafi',
    titleEn: 'Supplication for Healing to Ash-Shafi',
    repeatLabel: 'Dibaca 1x / 3x',
    repeatLabelEn: 'Recite 1x / 3x',
    arabic:
        'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
    latin:
        'Allahumma Rabban-nas, adzhibil-ba\'sa, isyfi Antasy-Syafi, la syifa\'a illa syifa\'uka, syifa\'an la yughadiru saqama.',
    translation:
        'Ya Allah, Tuhan seluruh manusia, hilangkanlah penyakit ini, sembuhkanlah karena Engkaulah Yang Maha Menyembuhkan. Tiada kesembuhan selain kesembuhan dari-Mu, kesembuhan yang tidak meninggalkan rasa sakit.',
    translationEn:
        'O Allah, Lord of mankind, remove the affliction and heal, for You are the Healer. There is no healing except Your healing, a healing that leaves behind no illness.',
    reference: 'HR. Bukhari no. 5743 & Muslim no. 2191',
    referenceEn: 'Sahih al-Bukhari 5743 & Sahih Muslim 2191',
  ),
];

// ================= 37. PENCARI DOA BERBASIS KONDISI / SUASANA HATI =================

class SpiritualMoodCondition {
  final String id;
  final String label;
  final String? labelEn;
  final String quranicComfort;
  final String? quranicComfortEn;
  final List<String> searchKeywords;
  final List<String> searchKeywordsEn;

  const SpiritualMoodCondition({
    required this.id,
    required this.label,
    this.labelEn,
    required this.quranicComfort,
    this.quranicComfortEn,
    required this.searchKeywords,
    this.searchKeywordsEn = const [],
  });

  String labelFor(AppLanguage lang) =>
      lang == AppLanguage.en && (labelEn?.isNotEmpty ?? false) ? labelEn! : label;
  String quranicComfortFor(AppLanguage lang) =>
      lang == AppLanguage.en && (quranicComfortEn?.isNotEmpty ?? false)
          ? quranicComfortEn!
          : quranicComfort;
}

const List<SpiritualMoodCondition> spiritualMoodCatalog = [
  SpiritualMoodCondition(
    id: 'gelisah',
    label: 'Gelisah & Cemas',
    labelEn: 'Anxious & Restless',
    quranicComfort: 'QS. Ar-Ra\'d: 28: "Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram."',
    quranicComfortEn: 'Quran 13:28: "Verily, in the remembrance of Allah do hearts find rest."',
    searchKeywords: ['gelisah', 'sedih', 'takut', 'hati', 'tidur', 'lindung'],
    searchKeywordsEn: ['anxious', 'worry', 'fear', 'heart', 'sleep', 'refuge'],
  ),
  SpiritualMoodCondition(
    id: 'sedih',
    label: 'Sedih & Duka',
    labelEn: 'Sadness & Grief',
    quranicComfort: 'QS. At-Taubah: 40: "Janganlah engkau bersedih, sesungguhnya Allah bersama kita."',
    quranicComfortEn: 'Quran 9:40: "Do not grieve; indeed Allah is with us."',
    searchKeywords: ['sedih', 'musibah', 'duka', 'ampun', 'rahmat'],
    searchKeywordsEn: ['grief', 'calamity', 'distress', 'forgiveness', 'mercy'],
  ),
  SpiritualMoodCondition(
    id: 'marah',
    label: 'Marah & Emosi',
    labelEn: 'Anger & Frustration',
    quranicComfort: 'QS. Ali \'Imran: 134: "...dan orang-orang yang menahan amarahnya serta memaafkan kesalahan orang lain."',
    quranicComfortEn: 'Quran 3:134: "...who restrain anger and who pardon the people."',
    searchKeywords: ['marah', 'setan', 'lindung', 'sabar'],
    searchKeywordsEn: ['anger', 'satan', 'refuge', 'patience'],
  ),
  SpiritualMoodCondition(
    id: 'sakit',
    label: 'Sakit & Lelah',
    labelEn: 'Illness & Fatigue',
    quranicComfort: 'QS. Asy-Syu\'ara: 80: "Dan apabila aku sakit, Dialah (Allah) yang menyembuhkanku."',
    quranicComfortEn: 'Quran 26:80: "And when I am ill, it is He who cures me."',
    searchKeywords: ['sakit', 'sembuh', 'sehat', 'afiyat', 'tubuh'],
    searchKeywordsEn: ['sick', 'heal', 'health', 'well-being', 'body'],
  ),
  SpiritualMoodCondition(
    id: 'ujian',
    label: 'Kesulitan & Utang',
    labelEn: 'Hardship & Debt',
    quranicComfort: 'QS. Ath-Thalaq: 2–3: "Barang siapa bertakwa kepada Allah niscaya Dia akan membukakan jalan keluar baginya."',
    quranicComfortEn: 'Quran 65:2-3: "Whoever is mindful of Allah, He will make for them a way out."',
    searchKeywords: ['utang', 'sulit', 'mudah', 'rezeki', 'cukup'],
    searchKeywordsEn: ['debt', 'hardship', 'ease', 'provision', 'suffice'],
  ),
  SpiritualMoodCondition(
    id: 'safar',
    label: 'Safar & Perjalanan',
    labelEn: 'Travel & Journey',
    quranicComfort: 'QS. Az-Zukhruf: 13–14: "Mahasuci Tuhan yang telah menundukkan semua ini bagi kami."',
    quranicComfortEn: 'Quran 43:13-14: "Exalted is He who has subjected this to us."',
    searchKeywords: ['kendaraan', 'safar', 'perjalanan', 'keluar rumah', 'pulang'],
    searchKeywordsEn: ['travel', 'journey', 'vehicle', 'leaving home', 'returning'],
  ),
  SpiritualMoodCondition(
    id: 'syukur',
    label: 'Bahagia & Syukur',
    labelEn: 'Joy & Gratitude',
    quranicComfort: 'QS. Ibrahim: 7: "Jika kalian bersyukur, pasti Aku akan menambah (nikmat) kepada kalian."',
    quranicComfortEn: 'Quran 14:7: "If you are grateful, I will surely increase you in favor."',
    searchKeywords: ['syukur', 'nikmat', 'pujian', 'makan', 'berkah'],
    searchKeywordsEn: ['gratitude', 'blessing', 'praise', 'food', 'thankful'],
  ),
  SpiritualMoodCondition(
    id: 'keluarga',
    label: 'Keluarga & Ilmu',
    labelEn: 'Family & Knowledge',
    quranicComfort: 'QS. Al-Furqan: 74: "Ya Tuhan kami, anugerahkanlah kepada kami pasangan dan keturunan sebagai penyejuk hati."',
    quranicComfortEn: 'Quran 25:74: "Our Lord, grant us from among our spouses and offspring comfort to our eyes."',
    searchKeywords: ['orang tua', 'anak', 'keluarga', 'ilmu', 'rumah'],
    searchKeywordsEn: ['parents', 'child', 'family', 'knowledge', 'home'],
  ),
];

List<DailyDua> filterDailyDuasByMood(List<DailyDua> all, SpiritualMoodCondition mood) {
  final matches = <DailyDua>[];
  for (final d in all) {
    final hit = mood.searchKeywords.any((kw) => d.matches(kw)) ||
        mood.searchKeywordsEn.any((kw) => d.matches(kw));
    if (hit) matches.add(d);
    if (matches.length >= 25) break;
  }
  return matches.isEmpty ? all.take(10).toList() : matches;
}

// ================= 38. KOLEKSI SHALAWAT MA'TSUR & COUNTER =================

class ShalawatReading {
  final String id;
  final String title;
  final String? titleEn;
  final String arabic;
  final String latin;
  final String translation;
  final String? translationEn;
  final String sourceAndVirtue;
  final String? sourceAndVirtueEn;

  const ShalawatReading({
    required this.id,
    required this.title,
    this.titleEn,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.translationEn,
    required this.sourceAndVirtue,
    this.sourceAndVirtueEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
  String sourceAndVirtueFor(AppLanguage lang) =>
      lang == AppLanguage.en && (sourceAndVirtueEn?.isNotEmpty ?? false)
          ? sourceAndVirtueEn!
          : sourceAndVirtue;
}

const List<ShalawatReading> shalawatCatalog = [
  ShalawatReading(
    id: 'ibrahimiyah',
    title: 'Shalawat Ibrahimiyah (Paling Utama & Shahih)',
    titleEn: 'Salawat Ibrahimiyyah (Most Authentic & Complete)',
    arabic:
        'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin:
        'Allahumma shalli \'ala Muhammad wa \'ala ali Muhammad, kama shallayta \'ala Ibrahim wa \'ala ali Ibrahim, innaka Hamidum Majid. Allahumma barik \'ala Muhammad wa \'ala ali Muhammad, kama barakta \'ala Ibrahim wa \'ala ali Ibrahim, innaka Hamidum Majid.',
    translation:
        'Ya Allah, limpahkanlah rahmat kepada Muhammad dan keluarga Muhammad sebagaimana Engkau melimpahkan rahmat kepada Ibrahim dan keluarga Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Mahamulia.',
    translationEn:
        'O Allah, send Your grace upon Muhammad and the family of Muhammad, as You sent grace upon Abraham and the family of Abraham; You are Praiseworthy and Glorious. O Allah, bless Muhammad and the family of Muhammad, as You blessed Abraham and the family of Abraham; You are Praiseworthy and Glorious.',
    sourceAndVirtue: 'HR. Bukhari no. 3370 & Muslim no. 406 (Shalawat yang diajarkan langsung oleh Rasulullah SAW kepada para sahabat)',
    sourceAndVirtueEn: 'Sahih al-Bukhari 3370 & Sahih Muslim 406 (Taught directly by the Prophet to the Companions)',
  ),
  ShalawatReading(
    id: 'ringkas_matsur',
    title: 'Shalawat Ringkas Ma\'tsur',
    titleEn: 'Concise Authentic Salawat',
    arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
    latin: 'Allahumma shalli wa sallim \'ala Nabiyyina Muhammad.',
    translation: 'Ya Allah, limpahkanlah shalawat dan salam kepada Nabi kami Muhammad.',
    translationEn: 'O Allah, send Your blessings and peace upon our Prophet Muhammad.',
    sourceAndVirtue: 'HR. Muslim no. 408: "Barang siapa bershalawat kepadaku satu kali, niscaya Allah bershalawat (melimpahkan rahmat) kepadanya sepuluh kali."',
    sourceAndVirtueEn: 'Sahih Muslim 408: "Whoever sends blessings upon me once, Allah sends blessings upon them tenfold."',
  ),
  ShalawatReading(
    id: 'dzurriyah',
    title: 'Shalawat Nabi beserta Istri & Keturunan Beliau',
    titleEn: 'Salawat Upon the Prophet, His Wives & Offspring',
    arabic:
        'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا صَلَّيْتَ عَلَىٰ آلِ إِبْرَاهِيمَ، وَبَارِكْ عَلَىٰ مُحَمَّدٍ وَأَزْوَاجِهِ وَذُرِّيَّتِهِ، كَمَا بَارَكْتَ عَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin:
        'Allahumma shalli \'ala Muhammadin wa azwajihi wa dzurriyyatihi, kama shallayta \'ala ali Ibrahim, wa barik \'ala Muhammadin wa azwajihi wa dzurriyyatihi, kama barakta \'ala ali Ibrahim, innaka Hamidum Majid.',
    translation:
        'Ya Allah, limpahkanlah rahmat kepada Muhammad, istri-istri beliau, dan keturunan beliau, sebagaimana Engkau telah melimpahkan rahmat kepada keluarga Ibrahim.',
    translationEn:
        'O Allah, send grace upon Muhammad, his wives, and his offspring, as You sent grace upon the family of Abraham, and bless Muhammad, his wives, and his offspring, as You blessed the family of Abraham. Truly You are Praiseworthy and Glorious.',
    sourceAndVirtue: 'HR. Bukhari no. 3369 & Muslim no. 407 (Dari Abu Humaid As-Sa\'idi RA)',
    sourceAndVirtueEn: 'Sahih al-Bukhari 3369 & Sahih Muslim 407 (Narrated by Abu Humayd as-Sa\'idi RA)',
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

  static const Map<String, String> _categoryEnMap = {
    'Diri Sendiri & Keluarga': 'Self & Family',
    'Keluarga & Orang Tua': 'Family & Parents',
    'Rezeki & Pekerjaan': 'Provision & Work',
    'Kesehatan & Kesembuhan': 'Health & Healing',
    'Kesehatan': 'Health',
    'Ilmu & Ibadah': 'Knowledge & Worship',
    'Orang Tua': 'Parents',
    'Umum': 'General',
  };

  String categoryFor(AppLanguage lang) =>
      lang == AppLanguage.en ? (_categoryEnMap[category] ?? category) : category;

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
  final String? titleEn;
  final int rakaatCount;
  final bool isRawatib12;
  final String virtue;
  final String? virtueEn;

  const SunnahHabitSpec({
    required this.id,
    required this.title,
    this.titleEn,
    required this.rakaatCount,
    required this.isRawatib12,
    required this.virtue,
    this.virtueEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String virtueFor(AppLanguage lang) =>
      lang == AppLanguage.en && (virtueEn?.isNotEmpty ?? false) ? virtueEn! : virtue;
}

const List<SunnahHabitSpec> sunnahHabitsCatalog = [
  SunnahHabitSpec(
    id: 'qabliyah_subuh',
    title: '2 Rakaat Qabliyah Subuh',
    titleEn: '2 Rak\'ah Before Fajr (Qabliyah)',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'HR. Muslim no. 725: "Dua rakaat fajar (Qabliyah Subuh) lebih baik daripada dunia dan seisinya."',
    virtueEn: 'Sahih Muslim 725: "The two rak\'ah before Fajr are better than this world and all it contains."',
  ),
  SunnahHabitSpec(
    id: 'qabliyah_dzuhur',
    title: '4 Rakaat Qabliyah Dzuhur',
    titleEn: '4 Rak\'ah Before Dhuhr (Qabliyah)',
    rakaatCount: 4,
    isRawatib12: true,
    virtue: 'Bagian dari 12 rakaat Rawatib yang dijanjikan rumah di surga (HR. Muslim no. 728).',
    virtueEn: 'Part of the 12 daily Rawatib rak\'ah rewarded with a house in Paradise (Sahih Muslim 728).',
  ),
  SunnahHabitSpec(
    id: 'badiyah_dzuhur',
    title: '2 Rakaat Ba\'diyah Dzuhur',
    titleEn: '2 Rak\'ah After Dhuhr (Ba\'diyah)',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'Bagian dari 12 rakaat Rawatib muakkadah setelah Salat Dzuhur.',
    virtueEn: 'Part of the 12 confirmed daily Rawatib rak\'ah following Dhuhr prayer.',
  ),
  SunnahHabitSpec(
    id: 'badiyah_maghrib',
    title: '2 Rakaat Ba\'diyah Maghrib',
    titleEn: '2 Rak\'ah After Maghrib (Ba\'diyah)',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'Bagian dari 12 rakaat Rawatib setelah Salat Maghrib.',
    virtueEn: 'Part of the 12 daily Rawatib rak\'ah following Maghrib prayer.',
  ),
  SunnahHabitSpec(
    id: 'badiyah_isya',
    title: '2 Rakaat Ba\'diyah Isya',
    titleEn: '2 Rak\'ah After Isha (Ba\'diyah)',
    rakaatCount: 2,
    isRawatib12: true,
    virtue: 'Melengkapi genap 12 rakaat Rawatib harian.',
    virtueEn: 'Completes the full 12 daily Rawatib Sunnah rak\'ah.',
  ),
  SunnahHabitSpec(
    id: 'salat_dhuha',
    title: 'Salat Sunnah Dhuha (Minimal 2 Rakaat)',
    titleEn: 'Duha Sunnah Prayer (At Least 2 Rak\'ah)',
    rakaatCount: 2,
    isRawatib12: false,
    virtue: 'HR. Muslim no. 720: Mencukupi sedekah bagi 360 persendian tubuh setiap pagi.',
    virtueEn: 'Sahih Muslim 720: Fulfills charity on behalf of all 360 joints of the body each morning.',
  ),
  SunnahHabitSpec(
    id: 'salat_witir',
    title: 'Salat Sunnah Witir Penutup Malam',
    titleEn: 'Witr Prayer Closing the Night',
    rakaatCount: 3,
    isRawatib12: false,
    virtue: 'HR. Bukhari no. 998: "Jadikanlah akhir salat malam kalian adalah salat Witir."',
    virtueEn: 'Sahih al-Bukhari 998: "Make Witr the last of your night prayers."',
  ),
  SunnahHabitSpec(
    id: 'wudhu_sebelum_tidur',
    title: 'Berwudhu & Dzikir Sebelum Tidur',
    titleEn: 'Wudu & Remembrance Before Sleep',
    rakaatCount: 0,
    isRawatib12: false,
    virtue: 'HR. Bukhari no. 247: Tidur dalam keadaan suci didoakan ampunan oleh malaikat.',
    virtueEn: 'Sahih al-Bukhari 247: Sleeping in ritual purity invites angels to pray for your forgiveness.',
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
