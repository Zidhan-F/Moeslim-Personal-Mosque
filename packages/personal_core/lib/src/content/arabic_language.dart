import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import 'quran_study_suite.dart' show normalizeArabicWord;

/// Entri kamus & kosakata Bahasa Arab terkurasi (offline-first, ARB-02 / ARB-05 / ARB-06).
class ArabicLexeme {
  final String id;
  final String lemmaAr;
  final String transliteration;
  final String root;
  final String pos; // ism, fil, harf, frasa
  final List<String> meaningsId;
  final List<String> meaningsEn;
  final String contextId;
  final String contextEn;
  final String exampleAr;
  final String exampleId;
  final String exampleEn;
  final String theme;
  final int level; // 1..5
  final String sourceRef;

  const ArabicLexeme({
    required this.id,
    required this.lemmaAr,
    required this.transliteration,
    required this.root,
    required this.pos,
    required this.meaningsId,
    required this.meaningsEn,
    required this.contextId,
    required this.contextEn,
    required this.exampleAr,
    required this.exampleId,
    required this.exampleEn,
    required this.theme,
    required this.level,
    this.sourceRef = 'Kurasi Moeslim PM (Mu\'jam Wasith & Durus al-Lughah)',
  });

  List<String> meaningsFor(AppLanguage lang) => lang == AppLanguage.en ? meaningsEn : meaningsId;
  String contextFor(AppLanguage lang) => lang == AppLanguage.en ? contextEn : contextId;
  String exampleFor(AppLanguage lang) => lang == AppLanguage.en ? exampleEn : exampleId;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final normQ = normalizeArabicWord(q);
    final normAr = normalizeArabicWord(lemmaAr);
    return normAr.contains(normQ) ||
        lemmaAr.contains(q) ||
        transliteration.toLowerCase().contains(q) ||
        root.contains(q) ||
        theme.toLowerCase().contains(q) ||
        meaningsId.any((m) => m.toLowerCase().contains(q)) ||
        meaningsEn.any((m) => m.toLowerCase().contains(q));
  }
}

class ArabicDialogueLine {
  final String speakerId;
  final String speakerEn;
  final String arabic;
  final String transliteration;
  final String translationId;
  final String translationEn;

  const ArabicDialogueLine({
    required this.speakerId,
    required this.speakerEn,
    required this.arabic,
    required this.transliteration,
    required this.translationId,
    required this.translationEn,
  });
}

class ArabicDialogue {
  final String id;
  final String titleId;
  final String titleEn;
  final String theme;
  final int level;
  final List<ArabicDialogueLine> lines;
  final String promptAr;
  final String promptHintId;
  final String promptHintEn;
  final List<String> choices;
  final int correctIndex;

  const ArabicDialogue({
    required this.id,
    required this.titleId,
    required this.titleEn,
    required this.theme,
    required this.level,
    required this.lines,
    required this.promptAr,
    required this.promptHintId,
    required this.promptHintEn,
    required this.choices,
    required this.correctIndex,
  });
}

/// Katalog kosakata & kamus dua arah offline (L2 Percakapan, L3 Tata Bahasa, L4 Frasa Terjemahan, L5 Al-Qur'an).
const List<ArabicLexeme> arabicLexemeCatalog = [
  // L2: Salam, Masjid, Keluarga, Waktu, Aktivitas
  ArabicLexeme(
    id: 'ar_salam',
    lemmaAr: 'السَّلَامُ عَلَيْكُمْ',
    transliteration: 'As-salamu \'alaykum',
    root: 'س ل م',
    pos: 'frasa',
    meaningsId: ['Semoga keselamatan tercurah atas kalian'],
    meaningsEn: ['Peace be upon you'],
    contextId: 'Salam pembuka pertemuan dan masuk rumah/masjid',
    contextEn: 'Standard Islamic greeting when meeting or entering',
    exampleAr: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
    exampleId: 'Semoga keselamatan dan rahmat Allah tercurah atas kalian.',
    exampleEn: 'Peace and mercy of Allah be upon you.',
    theme: 'Salam',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_ahlan',
    lemmaAr: 'أَهْلًا وَسَهْلًا',
    transliteration: 'Ahlan wa sahlan',
    root: 'أ ه ل',
    pos: 'frasa',
    meaningsId: ['Selamat datang'],
    meaningsEn: ['Welcome'],
    contextId: 'Menyambut tamu atau jamaah',
    contextEn: 'Welcoming a guest or congregation member',
    exampleAr: 'أَهْلًا وَسَهْلًا فِي الْمَسْجِدِ',
    exampleId: 'Selamat datang di masjid.',
    exampleEn: 'Welcome to the mosque.',
    theme: 'Salam',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_syukran',
    lemmaAr: 'شُكْرًا جَزِيلًا',
    transliteration: 'Syukran jazilan',
    root: 'ش ك ر',
    pos: 'frasa',
    meaningsId: ['Terima kasih banyak'],
    meaningsEn: ['Thank you very much'],
    contextId: 'Ungkapan terima kasih dalam percakapan sehari-hari',
    contextEn: 'Everyday expression of gratitude',
    exampleAr: 'شُكْرًا جَزِيلًا عَلَى مُسَاعَدَتِكَ',
    exampleId: 'Terima kasih banyak atas bantuanmu.',
    exampleEn: 'Thank you very much for your help.',
    theme: 'Salam',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_masjid',
    lemmaAr: 'مَسْجِدٌ',
    transliteration: 'Masjidun',
    root: 'س ج د',
    pos: 'ism',
    meaningsId: ['Masjid', 'Tempat sujud'],
    meaningsEn: ['Mosque', 'Place of prostration'],
    contextId: 'Ism makan (kata tempat) dari fi\'il sajada (sujud). Jamak: مَسَاجِدُ',
    contextEn: 'Noun of place from sajada (to prostrate). Plural: masajid',
    exampleAr: 'أَذْهَبُ إِلَى الْمَسْجِدِ لِصَلَاةِ الْجَمَاعَةِ',
    exampleId: 'Saya pergi ke masjid untuk salat berjamaah.',
    exampleEn: 'I go to the mosque for congregational prayer.',
    theme: 'Masjid',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_bayt',
    lemmaAr: 'بَيْتٌ',
    transliteration: 'Baytun',
    root: 'ب ي ت',
    pos: 'ism',
    meaningsId: ['Rumah', 'Kediaman'],
    meaningsEn: ['House', 'Home'],
    contextId: 'Jamak taksir: بُيُوتٌ (buyut)',
    contextEn: 'Broken plural: buyut',
    exampleAr: 'بَيْتِي قَرِيبٌ مِنَ الْمَسْجِدِ',
    exampleId: 'Rumahku dekat dari masjid.',
    exampleEn: 'My house is close to the mosque.',
    theme: 'Keluarga',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_usrah',
    lemmaAr: 'أُسْرَةٌ',
    transliteration: 'Usratun',
    root: 'أ س ر',
    pos: 'ism',
    meaningsId: ['Keluarga'],
    meaningsEn: ['Family'],
    contextId: 'Ism muannats (berakhiran ta marbuthah). Jamak: أُسَرٌ',
    contextEn: 'Feminine noun ending in ta marbuta. Plural: usar',
    exampleAr: 'نَتَعَلَّمُ الْقُرْآنَ مَعَ الْأُسْرَةِ',
    exampleId: 'Kami belajar Al-Qur\'an bersama keluarga.',
    exampleEn: 'We study the Qur\'an together with the family.',
    theme: 'Keluarga',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_ab',
    lemmaAr: 'أَبٌ',
    transliteration: 'Abun',
    root: 'أ ب و',
    pos: 'ism',
    meaningsId: ['Ayah', 'Bapak'],
    meaningsEn: ['Father'],
    contextId: 'Termasuk Al-Asma\' Al-Khamsah. Jamak: آبَاءٌ',
    contextEn: 'One of the Five Nouns. Plural: aba\'',
    exampleAr: 'أَبِي يَقْرَأُ سُورَةَ الْكَهْفِ يَوْمَ الْجُمُعَةِ',
    exampleId: 'Ayahku membaca Surah Al-Kahfi pada hari Jumat.',
    exampleEn: 'My father reads Surah Al-Kahf on Friday.',
    theme: 'Keluarga',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_umm',
    lemmaAr: 'أُمٌّ',
    transliteration: 'Ummun',
    root: 'أ م م',
    pos: 'ism',
    meaningsId: ['Ibu'],
    meaningsEn: ['Mother'],
    contextId: 'Jamak: أُمَّهَاتٌ (ummahat)',
    contextEn: 'Plural: ummahat',
    exampleAr: 'بِرُّ الْوَالِدَيْنِ وَخَاصَّةً الْأُمَّ وَاجِبٌ',
    exampleId: 'Berbakti kepada orang tua khususnya ibu adalah kewajiban.',
    exampleEn: 'Honoring parents, especially the mother, is an obligation.',
    theme: 'Keluarga',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_kitab',
    lemmaAr: 'كِتَابٌ',
    transliteration: 'Kitabun',
    root: 'ك ت ب',
    pos: 'ism',
    meaningsId: ['Buku', 'Kitab'],
    meaningsEn: ['Book', 'Scripture'],
    contextId: 'Jamak taksir: كُتُبٌ (kutub)',
    contextEn: 'Broken plural: kutub',
    exampleAr: 'هٰذَا كِتَابٌ مُفِيدٌ لِتَعَلُّمِ الْعَرَبِيَّةِ',
    exampleId: 'Ini buku yang bermanfaat untuk belajar bahasa Arab.',
    exampleEn: 'This is a useful book for learning Arabic.',
    theme: 'Ilmu',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_qalam',
    lemmaAr: 'قَلَمٌ',
    transliteration: 'Qalamun',
    root: 'ق ل م',
    pos: 'ism',
    meaningsId: ['Pena', 'Pulpen'],
    meaningsEn: ['Pen'],
    contextId: 'Jamak: أَقْلَامٌ (aqlam)',
    contextEn: 'Plural: aqlam',
    exampleAr: 'أَكْتُبُ الْفَوَائِدَ بِالْقَلَمِ',
    exampleId: 'Saya menulis faedah pelajaran dengan pena.',
    exampleEn: 'I write lesson notes with a pen.',
    theme: 'Ilmu',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_waqt',
    lemmaAr: 'وَقْتٌ',
    transliteration: 'Waqtun',
    root: 'و ق ت',
    pos: 'ism',
    meaningsId: ['Waktu', 'Saat'],
    meaningsEn: ['Time', 'Period'],
    contextId: 'Jamak: أَوْقَاتٌ (awqat)',
    contextEn: 'Plural: awqat',
    exampleAr: 'حَانَ وَقْتُ صَلَاةِ الْمَغْرِبِ',
    exampleId: 'Telah tiba waktu salat Maghrib.',
    exampleEn: 'The time for Maghrib prayer has arrived.',
    theme: 'Waktu',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_yawm',
    lemmaAr: 'يَوْمٌ',
    transliteration: 'Yawmun',
    root: 'ي و م',
    pos: 'ism',
    meaningsId: ['Hari'],
    meaningsEn: ['Day'],
    contextId: 'Jamak: أَيَّامٌ (ayyam)',
    contextEn: 'Plural: ayyam',
    exampleAr: 'الْيَوْمُ يَوْمُ الْجُمُعَةِ الْمُبَارَكُ',
    exampleId: 'Hari ini adalah hari Jumat yang penuh berkah.',
    exampleEn: 'Today is the blessed day of Friday.',
    theme: 'Waktu',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_maa',
    lemmaAr: 'مَاءٌ',
    transliteration: 'Ma\'un',
    root: 'م و ه',
    pos: 'ism',
    meaningsId: ['Air'],
    meaningsEn: ['Water'],
    contextId: 'Sering dipakai dalam bab wudhu & thaharah. Jamak: مِيَاهٌ',
    contextEn: 'Commonly used in wudu and purification chapters. Plural: miyah',
    exampleAr: 'أَتَوَضَّأُ بِالْمَاءِ الطَّهُورِ',
    exampleId: 'Saya berwudhu dengan air yang suci menyucikan.',
    exampleEn: 'I perform ablution with pure water.',
    theme: 'Ibadah',
    level: 2,
  ),
  ArabicLexeme(
    id: 'ar_wudhu',
    lemmaAr: 'وُضُوءٌ',
    transliteration: 'Wudhu\'un',
    root: 'و ض أ',
    pos: 'ism',
    meaningsId: ['Wudhu', 'Bersuci sebelum salat'],
    meaningsEn: ['Ablution', 'Ritual washing before prayer'],
    contextId: 'Ibadah penyucian diri sebelum salat dan membaca mushaf',
    contextEn: 'Ritual purification prior to prayer',
    exampleAr: 'الْوُضُوءُ شَرْطٌ لِصِحَّةِ الصَّلَاةِ',
    exampleId: 'Wudhu adalah syarat sah salat.',
    exampleEn: 'Wudu is a condition for the validity of prayer.',
    theme: 'Ibadah',
    level: 2,
  ),
  // L3: Tata Bahasa (Fi'l, Ism, Harf, Kata Ganti)
  ArabicLexeme(
    id: 'ar_kataba',
    lemmaAr: 'كَتَبَ - يَكْتُبُ',
    transliteration: 'Kataba - Yaktubu',
    root: 'ك ت ب',
    pos: 'fil',
    meaningsId: ['Menulis', 'Mewajibkan (konteks fikih/Al-Qur\'an)'],
    meaningsEn: ['To write', 'To prescribe/ordain (in Quranic context)'],
    contextId: 'Fi\'il tsulatsi mujarrad wazan fa\'ala - yaf\'ulu (Bab 1)',
    contextEn: 'Form I triliteral verb pattern fa\'ala - yaf\'ulu',
    exampleAr: 'كَتَبَ الطَّالِبُ الدَّرْسَ فِي الدَّفْتَرِ',
    exampleId: 'Murid itu telah menulis pelajaran di buku catatan.',
    exampleEn: 'The student wrote the lesson in the notebook.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  ArabicLexeme(
    id: 'ar_qaraa',
    lemmaAr: 'قَرَأَ - يَقْرَأُ',
    transliteration: 'Qara\'a - Yaqra\'u',
    root: 'ق ر أ',
    pos: 'fil',
    meaningsId: ['Membaca', 'Melafalkan'],
    meaningsEn: ['To read', 'To recite'],
    contextId: 'Fi\'il madhi (telah membaca) & mudhari\' (sedang/akan membaca); amr: اِقْرَأْ',
    contextEn: 'Past & present verb; imperative: Iqra\'',
    exampleAr: 'اِقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
    exampleId: 'Bacalah dengan nama Tuhanmu yang menciptakan.',
    exampleEn: 'Read in the name of your Lord who created.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  ArabicLexeme(
    id: 'ar_dzahaba',
    lemmaAr: 'ذَهَبَ - يَذْهَبُ',
    transliteration: 'Dzahaba - Yadzhabu',
    root: 'ذ ه ب',
    pos: 'fil',
    meaningsId: ['Pergi', 'Berangkat'],
    meaningsEn: ['To go', 'To depart'],
    contextId: 'Sering diikuti huruf jar إِلَى (ke)',
    contextEn: 'Commonly followed by the preposition ila (to)',
    exampleAr: 'ذَهَبَ أَحْمَدُ إِلَى الْمَسْجِدِ مُبَكِّرًا',
    exampleId: 'Ahmad pergi ke masjid lebih awal.',
    exampleEn: 'Ahmad went to the mosque early.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  ArabicLexeme(
    id: 'ar_alima',
    lemmaAr: 'عَلِمَ - يَعْلَمُ',
    transliteration: '\'Alima - Ya\'lamu',
    root: 'ع ل م',
    pos: 'fil',
    meaningsId: ['Mengetahui', 'Memahami dengan pasti'],
    meaningsEn: ['To know', 'To have certain knowledge'],
    contextId: 'Berakar ع ل م yang melahirkan عِلْمٌ (ilmu), عَالِمٌ (ulama/berilmu), مُعَلِّمٌ (pengajar)',
    contextEn: 'Root \'-l-m producing ilm (knowledge), alim (scholar), mu\'allim (teacher)',
    exampleAr: 'وَاللَّهُ يَعْلَمُ مَا فِي قُلُوبِكُمْ',
    exampleId: 'Dan Allah mengetahui apa yang ada di dalam hati kalian.',
    exampleEn: 'And Allah knows what is within your hearts.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  ArabicLexeme(
    id: 'ar_fi',
    lemmaAr: 'فِي',
    transliteration: 'Fi',
    root: '-',
    pos: 'harf',
    meaningsId: ['Di dalam', 'Pada'],
    meaningsEn: ['In', 'Inside', 'At'],
    contextId: 'Harf jar: membuat ism sesudahnya berharakat kasrah (majrur)',
    contextEn: 'Preposition (harf jarr): puts the following noun in genitive case (-i)',
    exampleAr: 'الْمُصْحَفُ فِي الْمَسْجِدِ',
    exampleId: 'Mushaf itu berada di dalam masjid.',
    exampleEn: 'The Mushaf is inside the mosque.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  ArabicLexeme(
    id: 'ar_ila',
    lemmaAr: 'إِلَى',
    transliteration: 'Ila',
    root: '-',
    pos: 'harf',
    meaningsId: ['Ke', 'Menuju', 'Sampai'],
    meaningsEn: ['To', 'Toward', 'Until'],
    contextId: 'Harf jar penunjuk arah atau batas akhir',
    contextEn: 'Preposition indicating direction or endpoint',
    exampleAr: 'نَتَوَجَّهُ إِلَى الْقِبْلَةِ',
    exampleId: 'Kami menghadap ke arah kiblat.',
    exampleEn: 'We face toward the Qibla.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  ArabicLexeme(
    id: 'ar_min',
    lemmaAr: 'مِنْ',
    transliteration: 'Min',
    root: '-',
    pos: 'harf',
    meaningsId: ['Dari', 'Sebagian dari'],
    meaningsEn: ['From', 'Some of'],
    contextId: 'Harf jar penunjuk asal atau bagian',
    contextEn: 'Preposition indicating origin or partitive meaning',
    exampleAr: 'رَجَعْتُ مِنَ الْمَسْجِدِ بَعْدَ الْعِشَاءِ',
    exampleId: 'Saya pulang dari masjid setelah Isya.',
    exampleEn: 'I returned from the mosque after Isha.',
    theme: 'Tata Bahasa',
    level: 3,
  ),
  // L4: Frasa Terjemahan Terkurasi (Arab <-> Indonesia)
  ArabicLexeme(
    id: 'ar_phr_barakallah',
    lemmaAr: 'بَارَكَ اللَّهُ فِيكَ',
    transliteration: 'Barakallahu fika',
    root: 'ب ر ك',
    pos: 'frasa',
    meaningsId: ['Semoga Allah memberkahimu'],
    meaningsEn: ['May Allah bless you'],
    contextId: 'Untuk laki-laki: فِيكَ (fika); perempuan: فِيكِ (fiki); jamak: فِيكُمْ (fikum)',
    contextEn: 'Masc: fika; Fem: fiki; Plural: fikum',
    exampleAr: 'جَزَاكَ اللَّهُ خَيْرًا وَبَارَكَ اللَّهُ فِيكَ',
    exampleId: 'Semoga Allah membalasmu dengan kebaikan dan memberkahimu.',
    exampleEn: 'May Allah reward you with good and bless you.',
    theme: 'Terjemahan',
    level: 4,
  ),
  ArabicLexeme(
    id: 'ar_phr_kaifa',
    lemmaAr: 'كَيْفَ حَالُكَ؟',
    transliteration: 'Kayfa haluka?',
    root: 'ح و ل',
    pos: 'frasa',
    meaningsId: ['Bagaimana kabarmu?'],
    meaningsEn: ['How are you?'],
    contextId: 'Dijawab biasanya: بِخَيْرٍ وَالْحَمْدُ لِلَّهِ (Baik, alhamdulillah)',
    contextEn: 'Common reply: Bi-khayr wal-hamdulillah (Well, praise be to Allah)',
    exampleAr: 'كَيْفَ حَالُكَ؟ أَنَا بِخَيْرٍ وَالْحَمْدُ لِلَّهِ',
    exampleId: 'Bagaimana kabarmu? Saya baik, segala puji bagi Allah.',
    exampleEn: 'How are you? I am well, praise be to Allah.',
    theme: 'Terjemahan',
    level: 4,
  ),
  ArabicLexeme(
    id: 'ar_phr_aina',
    lemmaAr: 'أَيْنَ مَكَانُ الْوُضُوءِ؟',
    transliteration: 'Ayna makanul-wudhu\'?',
    root: 'ك و ن',
    pos: 'frasa',
    meaningsId: ['Di mana tempat wudhu?'],
    meaningsEn: ['Where is the ablution area?'],
    contextId: 'Frasa praktis saat berkunjung ke masjid baru atau safar',
    contextEn: 'Practical phrase when visiting an unfamiliar mosque or traveling',
    exampleAr: 'عَفْوًا، أَيْنَ مَكَانُ الْوُضُوءِ؟',
    exampleId: 'Permisi, di mana tempat wudhu?',
    exampleEn: 'Excuse me, where is the wudu area?',
    theme: 'Terjemahan',
    level: 4,
  ),
  // L5: Bahasa Arab Al-Qur'an (akar kata & morfologi terpisah dari tafsir)
  ArabicLexeme(
    id: 'ar_q_rahmat',
    lemmaAr: 'رَحْمَةٌ',
    transliteration: 'Rahmatun',
    root: 'ر ح م',
    pos: 'ism',
    meaningsId: ['Kasih sayang', 'Rahmat'],
    meaningsEn: ['Mercy', 'Compassion'],
    contextId: 'Analisis bahasa: akar ر ح م melahirkan الرَّحْمٰن (Maha Pengasih luas) & الرَّحِيم (Maha Penyayang tetap). Untuk tafsir ayat, rujuk kitab tafsir resmi.',
    contextEn: 'Linguistic note: root r-h-m derives Ar-Rahman and Ar-Rahim. Consult authoritative tafsir for verse exegesis.',
    exampleAr: 'وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ',
    exampleId: 'Dan tiadalah Kami mengutus engkau melainkan sebagai rahmat bagi seluruh alam (QS. Al-Anbiya: 107).',
    exampleEn: 'And We have not sent you except as a mercy to the worlds (QS. Al-Anbiya: 107).',
    theme: 'Al-Qur\'an',
    level: 5,
    sourceRef: 'Mu\'jam Alfazh Al-Qur\'an Al-Karim (terpisah dari tafsir)',
  ),
  ArabicLexeme(
    id: 'ar_q_huda',
    lemmaAr: 'هُدًى',
    transliteration: 'Hudan',
    root: 'ه د ي',
    pos: 'ism',
    meaningsId: ['Petunjuk', 'Hidayah'],
    meaningsEn: ['Guidance'],
    contextId: 'Analisis bahasa: mashdar dari هَدَى - يَهْدِي (memberi petunjuk lembut). Muncul di QS. Al-Baqarah: 2 & Al-Fatihah: 6.',
    contextEn: 'Verbal noun from hada-yahdi (to guide gently). Appears in QS. Al-Baqarah: 2 & Al-Fatihah: 6.',
    exampleAr: 'ذٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ',
    exampleId: 'Kitab (Al-Qur\'an) ini tidak ada keraguan padanya, petunjuk bagi orang-orang bertakwa (QS. Al-Baqarah: 2).',
    exampleEn: 'This is the Book about which there is no doubt, a guidance for the God-conscious (QS. Al-Baqarah: 2).',
    theme: 'Al-Qur\'an',
    level: 5,
    sourceRef: 'Mu\'jam Alfazh Al-Qur\'an Al-Karim (terpisah dari tafsir)',
  ),
  ArabicLexeme(
    id: 'ar_q_sabr',
    lemmaAr: 'صَبْرٌ',
    transliteration: 'Shabrun',
    root: 'ص ب ر',
    pos: 'ism',
    meaningsId: ['Kesabaran', 'Keteguhan menahan diri'],
    meaningsEn: ['Patience', 'Steadfast perseverance'],
    contextId: 'Analisis bahasa: asal makna menahan diri dengan teguh; fi\'il amr: اِصْبِرْ (bersabarlah).',
    contextEn: 'Linguistic core: holding oneself firm; imperative: isbir (be patient).',
    exampleAr: 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    exampleId: 'Sesungguhnya Allah beserta orang-orang yang sabar (QS. Al-Baqarah: 153).',
    exampleEn: 'Indeed, Allah is with the patient (QS. Al-Baqarah: 153).',
    theme: 'Al-Qur\'an',
    level: 5,
    sourceRef: 'Mu\'jam Alfazh Al-Qur\'an Al-Karim (terpisah dari tafsir)',
  ),
  ArabicLexeme(
    id: 'ar_q_taqwa',
    lemmaAr: 'تَقْوَى',
    transliteration: 'Taqwa',
    root: 'و ق ي',
    pos: 'ism',
    meaningsId: ['Ketakwaan', 'Menjaga diri dari murka Allah'],
    meaningsEn: ['God-consciousness', 'Self-protection through obedience'],
    contextId: 'Analisis bahasa: dari akar و ق ي (melindungi/menjaga). Pelakunya: مُتَّقٍ / مُتَّقُونَ.',
    contextEn: 'From root w-q-y (to shield/protect). Active participle: muttaqi / muttaqun.',
    exampleAr: 'وَتَزَوَّدُوا فَإِنَّ خَيْرَ الزَّادِ التَّقْوَى',
    exampleId: 'Berbekallah, sesungguhnya sebaik-baik bekal adalah takwa (QS. Al-Baqarah: 197).',
    exampleEn: 'And take provisions, for indeed the best provision is taqwa (QS. Al-Baqarah: 197).',
    theme: 'Al-Qur\'an',
    level: 5,
    sourceRef: 'Mu\'jam Alfazh Al-Qur\'an Al-Karim (terpisah dari tafsir)',
  ),
  ArabicLexeme(
    id: 'ar_q_sakinah',
    lemmaAr: 'سَكِينَةٌ',
    transliteration: 'Sakinatun',
    root: 'س ك ن',
    pos: 'ism',
    meaningsId: ['Ketenangan jiwa', 'Ketenteraman'],
    meaningsEn: ['Tranquility', 'Serenity of the heart'],
    contextId: 'Analisis bahasa: akar س ك ن bermakna diam menetap dengan tenang (juga akar kata مَسْكَن tempat tinggal).',
    contextEn: 'Root s-k-n means peaceful stillness and dwelling.',
    exampleAr: 'هُوَ الَّذِي أَنزَلَ السَّكِينَةَ فِي قُلُوبِ الْمُؤْمِنِينَ',
    exampleId: 'Dialah yang menurunkan ketenangan ke dalam hati orang-orang mukmin (QS. Al-Fath: 4).',
    exampleEn: 'It is He who sent down tranquility into the hearts of the believers (QS. Al-Fath: 4).',
    theme: 'Al-Qur\'an',
    level: 5,
    sourceRef: 'Mu\'jam Alfazh Al-Qur\'an Al-Karim (terpisah dari tafsir)',
  ),
  ArabicLexeme(
    id: 'ar_q_syukr',
    lemmaAr: 'شُكْرٌ',
    transliteration: 'Syukrun',
    root: 'ش ك ر',
    pos: 'ism',
    meaningsId: ['Syukur', 'Berterima kasih atas nikmat'],
    meaningsEn: ['Gratitude', 'Thankfulness'],
    contextId: 'Analisis bahasa: mengakui nikmat dengan hati, lisan, dan amal.',
    contextEn: 'Recognizing blessings in heart, speech, and action.',
    exampleAr: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    exampleId: 'Sungguh jika kamu bersyukur, pasti Aku akan menambah nikmat kepadamu (QS. Ibrahim: 7).',
    exampleEn: 'If you are grateful, I will surely increase you (QS. Ibrahim: 7).',
    theme: 'Al-Qur\'an',
    level: 5,
    sourceRef: 'Mu\'jam Alfazh Al-Qur\'an Al-Karim (terpisah dari tafsir)',
  ),
];

/// Dialog percakapan dasar Bahasa Arab (ARB-03) dengan latihan melengkapi dialog.
const List<ArabicDialogue> arabicDialoguesCatalog = [
  ArabicDialogue(
    id: 'dlg_taaruf',
    titleId: 'Perkenalan Singkat di Masjid',
    titleEn: 'Brief Introduction at the Mosque',
    theme: 'Salam & Perkenalan',
    level: 2,
    lines: [
      ArabicDialogueLine(
        speakerId: 'Ahmad',
        speakerEn: 'Ahmad',
        arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        transliteration: 'As-salamu \'alaykum wa rahmatullah',
        translationId: 'Semoga keselamatan dan rahmat Allah tercurah atasmu.',
        translationEn: 'Peace and mercy of Allah be upon you.',
      ),
      ArabicDialogueLine(
        speakerId: 'Bilal',
        speakerEn: 'Bilal',
        arabic: 'وَعَلَيْكُمُ السَّلَامُ، أَهْلًا وَسَهْلًا. مَا اسْمُكَ؟',
        transliteration: 'Wa \'alaykumus-salam, ahlan wa sahlan. Masmuka?',
        translationId: 'Wa\'alaikumussalam, selamat datang. Siapa namamu?',
        translationEn: 'And upon you be peace, welcome. What is your name?',
      ),
      ArabicDialogueLine(
        speakerId: 'Ahmad',
        speakerEn: 'Ahmad',
        arabic: 'اِسْمِي أَحْمَدُ، وَأَنَا مِنْ بَانْدُونْغ.',
        transliteration: 'Ismi Ahmad, wa ana min Bandung.',
        translationId: 'Namaku Ahmad, dan saya dari Bandung.',
        translationEn: 'My name is Ahmad, and I am from Bandung.',
      ),
    ],
    promptAr: 'مَا اسْمُكَ؟ / ____ أَحْمَدُ.',
    promptHintId: 'Pilih kata yang tepat untuk menjawab "Siapa namamu?"',
    promptHintEn: 'Choose the right word to answer "What is your name?"',
    choices: ['اِسْمِي (Namaku)', 'بَيْتِي (Rumahku)', 'قَلَمِي (Penaku)'],
    correctIndex: 0,
  ),
  ArabicDialogue(
    id: 'dlg_masjid',
    titleId: 'Menuju Salat Berjamaah',
    titleEn: 'Heading to Congregational Prayer',
    theme: 'Masjid & Waktu',
    level: 2,
    lines: [
      ArabicDialogueLine(
        speakerId: 'Ayah',
        speakerEn: 'Father',
        arabic: 'هَيَّا نَذْهَبُ إِلَى الْمَسْجِدِ، حَانَ وَقْتُ الْمَغْرِبِ.',
        transliteration: 'Hayya nadzhabu ilal-masjid, hana waqtul-maghrib.',
        translationId: 'Ayo kita pergi ke masjid, waktu Maghrib telah tiba.',
        translationEn: 'Let us go to the mosque, Maghrib time has arrived.',
      ),
      ArabicDialogueLine(
        speakerId: 'Anak',
        speakerEn: 'Child',
        arabic: 'حَاضِرٌ يَا أَبِي، أَتَوَضَّأُ أَوَّلًا.',
        transliteration: 'Hadhirun ya abi, atawadhdha\'u awwalan.',
        translationId: 'Siap Ayah, saya berwudhu terlebih dahulu.',
        translationEn: 'Ready Father, I will make wudu first.',
      ),
    ],
    promptAr: 'هَيَّا نَذْهَبُ ____ الْمَسْجِدِ.',
    promptHintId: 'Lengkapi huruf jar yang berarti "ke":',
    promptHintEn: 'Fill in the preposition meaning "to":',
    choices: ['مِنْ (dari)', 'إِلَى (ke)', 'عَنْ (tentang)'],
    correctIndex: 1,
  ),
];

/// Cari kamus dua arah lokal (offline-first, ARB-AC01).
List<ArabicLexeme> searchArabicDictionary(String query, {int? level, String? pos}) {
  return arabicLexemeCatalog.where((item) {
    if (level != null && item.level != level) return false;
    if (pos != null && pos.isNotEmpty && item.pos != pos) return false;
    return item.matches(query);
  }).toList();
}

/// Status Spaced Repetition lokal (SM-2 sederhana) untuk flashcard Bahasa Arab (ARB-02 / ARB-10).
class ArabicReviewState {
  final String lexemeId;
  final DateTime nextReviewAt;
  final double ease;
  final int repetitions;
  final int intervalDays;

  const ArabicReviewState({
    required this.lexemeId,
    required this.nextReviewAt,
    this.ease = 2.5,
    this.repetitions = 0,
    this.intervalDays = 1,
  });

  Map<String, Object> toJson() => {
        'lexemeId': lexemeId,
        'nextReviewAt': nextReviewAt.toUtc().toIso8601String(),
        'ease': ease,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
      };

  factory ArabicReviewState.fromJson(Map<String, dynamic> j) => ArabicReviewState(
        lexemeId: j['lexemeId'] as String? ?? '',
        nextReviewAt: DateTime.tryParse(j['nextReviewAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
        ease: (j['ease'] as num?)?.toDouble() ?? 2.5,
        repetitions: (j['repetitions'] as num?)?.toInt() ?? 0,
        intervalDays: (j['intervalDays'] as num?)?.toInt() ?? 1,
      );
}

class ArabicStudyRepository {
  static const _reviewKey = 'arabic_review_queue_v1';
  static const _favKey = 'arabic_fav_lexemes_v1';

  final KeyValueStore _store;
  final DateTime Function() _now;

  ArabicStudyRepository(this._store, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  Future<Map<String, ArabicReviewState>> loadReviews() async {
    final raw = await _store.readJson(_reviewKey);
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries)
        if (e.value is Map) '${e.key}': ArabicReviewState.fromJson(Map<String, dynamic>.from(e.value as Map)),
    };
  }

  /// Catat hasil ulangan kartu (quality: 1 = sulit/ulang besok, 3 = cukup, 5 = hafal lancar).
  Future<ArabicReviewState> recordReview(String lexemeId, {required int quality}) async {
    final all = Map<String, ArabicReviewState>.from(await loadReviews());
    final cur = all[lexemeId];
    final q = quality.clamp(1, 5);
    var ease = cur?.ease ?? 2.5;
    var reps = cur?.repetitions ?? 0;
    var interval = cur?.intervalDays ?? 1;

    if (q < 3) {
      reps = 0;
      interval = 1;
    } else {
      reps += 1;
      interval = switch (reps) {
        1 => 1,
        2 => 4,
        _ => (interval * ease).round().clamp(4, 60),
      };
      ease = (ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))).clamp(1.3, 3.0);
    }

    final next = ArabicReviewState(
      lexemeId: lexemeId,
      nextReviewAt: _now().toUtc().add(Duration(days: interval)),
      ease: ease,
      repetitions: reps,
      intervalDays: interval,
    );
    all[lexemeId] = next;
    await _store.writeJson(_reviewKey, {for (final e in all.entries) e.key: e.value.toJson()});
    return next;
  }

  Future<List<ArabicLexeme>> dueFlashcards() async {
    final reviews = await loadReviews();
    final now = _now().toUtc();
    return arabicLexemeCatalog.where((lex) {
      final st = reviews[lex.id];
      return st == null || !st.nextReviewAt.isAfter(now);
    }).toList();
  }

  Future<Set<String>> favoriteIds() async {
    final raw = await _store.readJson(_favKey);
    if (raw is! List) return {};
    return raw.map((e) => '$e').toSet();
  }

  Future<Set<String>> toggleFavorite(String lexemeId) async {
    final cur = await favoriteIds();
    if (!cur.remove(lexemeId)) cur.add(lexemeId);
    await _store.writeJson(_favKey, cur.toList());
    return cur;
  }
}
