import 'package:shared_prayer/shared_prayer.dart';

import 'tajweed.dart';

class MakhrajGroup {
  final String id;
  final String name;
  final String? nameEn;
  final String arabicName;
  final String letters;
  final String? lettersEn;
  final String organDescription;
  final String? organDescriptionEn;
  final String practiceTip;
  final String? practiceTipEn;

  const MakhrajGroup({
    required this.id,
    required this.name,
    this.nameEn,
    required this.arabicName,
    required this.letters,
    this.lettersEn,
    required this.organDescription,
    this.organDescriptionEn,
    required this.practiceTip,
    this.practiceTipEn,
  });

  String nameFor(AppLanguage lang) =>
      lang == AppLanguage.en && (nameEn?.isNotEmpty ?? false) ? nameEn! : name;
  String lettersFor(AppLanguage lang) =>
      lang == AppLanguage.en && (lettersEn?.isNotEmpty ?? false) ? lettersEn! : letters;
  String organDescriptionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (organDescriptionEn?.isNotEmpty ?? false)
          ? organDescriptionEn!
          : organDescription;
  String practiceTipFor(AppLanguage lang) =>
      lang == AppLanguage.en && (practiceTipEn?.isNotEmpty ?? false) ? practiceTipEn! : practiceTip;
}

const List<MakhrajGroup> makharijulHurufCatalog = [
  MakhrajGroup(
    id: 'al_jauf',
    name: '1. Al-Jauf (Rongga Mulut & Tenggorokan)',
    nameEn: '1. Al-Jawf (Oral & Throat Cavity)',
    arabicName: 'الجَوْفُ',
    letters: 'ا و ي (Huruf Mad)',
    lettersEn: 'ا و ي (Madd Letters)',
    organDescription:
        'Tempat keluarnya tiga huruf mad: Alif setelah fathah, Wawu sukun setelah dhammah, dan Ya sukun setelah kasrah.',
    organDescriptionEn:
        'The articulation area for the three elongation letters: Alif after fathah, sakin Waw after dammah, and sakin Ya after kasrah.',
    practiceTip: 'Suara mengalir bebas dari rongga tenggorokan hingga mulut tanpa hambatan lidah atau bibir.',
    practiceTipEn: 'Let the sound flow freely through the throat and mouth cavity without blocking it with the tongue or lips.',
  ),
  MakhrajGroup(
    id: 'al_halq',
    name: '2. Al-Halq (Tenggorokan)',
    nameEn: '2. Al-Halq (The Throat)',
    arabicName: 'الحَلْقُ',
    letters: 'ء هـ · ع ح · غ خ',
    lettersEn: 'ء هـ · ع ح · غ خ',
    organDescription:
        'Terbagi tiga titik: Pangkal tenggorokan (ء، هـ), Tengah tenggorokan (ع، ح), dan Ujung tenggorokan dekat mulut (غ، خ).',
    organDescriptionEn:
        'Divided into three points: deepest throat (ء, هـ), middle throat (ع, ح), and upper throat nearest the mouth (غ, خ).',
    practiceTip: 'Huruf-huruf ini merupakan huruf Idzhar Halqi; ketika nun sukun/tanwin bertemu salah satunya, dibaca jelas tanpa dengung.',
    practiceTipEn: 'These are the letters of Izhar Halqi; when sakin nun or tanwin precedes any of them, pronounce it clearly without nasalization.',
  ),
  MakhrajGroup(
    id: 'al_lisan',
    name: '3. Al-Lisan (Lidah)',
    nameEn: '3. Al-Lisan (The Tongue)',
    arabicName: 'اللِّسَانُ',
    letters: 'ق ك · ج ش ي · ض · ل ن ر · ط د ت · ص ز س · ظ ذ ث',
    lettersEn: 'ق ك · ج ش ي · ض · ل ن ر · ط د ت · ص ز س · ظ ذ ث',
    organDescription:
        'Mencakup 10 titik makhraj untuk 18 huruf: pangkal lidah (ق، ك), tengah lidah (ج، ش، ي), tepi lidah ke geraham (ض), hingga ujung lidah.',
    organDescriptionEn:
        'Covers 10 articulation points for 18 letters: back of the tongue (ق, ك), middle of the tongue (ج, ش, ي), side of the tongue against upper molars (ض), down to the tip.',
    practiceTip: 'Perhatikan perbedaan tipis antara huruf ujung lidah dengan gigi seri atas (ظ، ذ، ث) dan huruf desis/shafir (ص، ز، س).',
    practiceTipEn: 'Pay close attention to the difference between interdental tip letters (ظ, ذ, ث) and sibilant/whistling letters (ص, ز, س).',
  ),
  MakhrajGroup(
    id: 'asy_syafatain',
    name: '4. Asy-Syafatain (Kedua Bibir)',
    nameEn: '4. Ash-Shafatan (The Two Lips)',
    arabicName: 'الشَّفَتَانِ',
    letters: 'ف · و ب م',
    lettersEn: 'ف · و ب م',
    organDescription:
        'Bibir bawah bagian dalam bertemu ujung gigi seri atas (ف), serta pertemuan atau membulatnya kedua bibir (ب، م، و).',
    organDescriptionEn:
        'Inside of the lower lip meets the edges of the upper front teeth (ف), while both lips close or round for (ب, م, و).',
    practiceTip: 'Huruf ب dan م berkaitan langsung dengan hukum Ikhfa Syafawi, Idgham Mimi, dan Iqlab.',
    practiceTipEn: 'The letters ب and م are directly involved in Ikhfa Shafawi, Idgham Mimi, and Iqlab rules.',
  ),
  MakhrajGroup(
    id: 'al_khaisyum',
    name: '5. Al-Khaisyum (Pangkal Rongga Hidung)',
    nameEn: '5. Al-Khayshum (The Nasal Passage)',
    arabicName: 'الخَيْشُومُ',
    letters: 'نّ مّ (Suara Ghunnah / Dengung)',
    lettersEn: 'نّ مّ (Ghunnah / Nasal Sound)',
    organDescription:
        'Tempat keluarnya suara dengung (ghunnah) yang menyertai huruf Nun dan Mim bertasydid, Idgham Bighunnah, Iqlab, serta Ikhfa.',
    organDescriptionEn:
        'The nasal passage where ghunnah resonance emerges for doubled Nun and Mim, Idgham with Ghunnah, Iqlab, and Ikhfa.',
    practiceTip: 'Tahan dengung selama 2 harakat penuh; jika hidung dipencet maka suara ghunnah akan tertahan.',
    practiceTipEn: 'Hold the nasal resonance for 2 full counts; pinching your nose gently confirms whether sound is resonating through the nasal passage.',
  ),
];

class TajweedLesson {
  final TajweedRule rule;
  final String title;
  final String? titleEn;
  final String triggerLetters;
  final String? triggerLettersEn;
  final String howToRead;
  final String? howToReadEn;
  final String exampleArabic;
  final String exampleSurahRef;
  final String? exampleSurahRefEn;
  final String exampleExplanation;
  final String? exampleExplanationEn;

  const TajweedLesson({
    required this.rule,
    required this.title,
    this.titleEn,
    required this.triggerLetters,
    this.triggerLettersEn,
    required this.howToRead,
    this.howToReadEn,
    required this.exampleArabic,
    required this.exampleSurahRef,
    this.exampleSurahRefEn,
    required this.exampleExplanation,
    this.exampleExplanationEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String triggerLettersFor(AppLanguage lang) =>
      lang == AppLanguage.en && (triggerLettersEn?.isNotEmpty ?? false)
          ? triggerLettersEn!
          : triggerLetters;
  String howToReadFor(AppLanguage lang) =>
      lang == AppLanguage.en && (howToReadEn?.isNotEmpty ?? false) ? howToReadEn! : howToRead;
  String exampleSurahRefFor(AppLanguage lang) =>
      lang == AppLanguage.en && (exampleSurahRefEn?.isNotEmpty ?? false)
          ? exampleSurahRefEn!
          : exampleSurahRef;
  String exampleExplanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (exampleExplanationEn?.isNotEmpty ?? false)
          ? exampleExplanationEn!
          : exampleExplanation;
}

const List<TajweedLesson> tajweedLessonsCatalog = [
  TajweedLesson(
    rule: TajweedRule.ghunnah,
    title: 'Ghunnah Musyaddadah (Nun & Mim Tasydid)',
    titleEn: 'Ghunnah Mushaddadah (Doubled Nun & Mim)',
    triggerLetters: 'نّ ، مّ',
    triggerLettersEn: 'نّ , مّ',
    howToRead: 'Didengungkan dengan jelas ke rongga hidung (Al-Khaisyum) sepanjang 2 ketukan/harakat.',
    howToReadEn: 'Resonate clearly through the nasal passage (Al-Khayshum) for 2 full counts.',
    exampleArabic: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
    exampleSurahRef: 'QS. Al-Kautsar: 1',
    exampleSurahRefEn: 'Quran 108:1 (Al-Kawthar)',
    exampleExplanation: 'Huruf Nun bertasydid pada kata إِنَّا wajib ditahan dengungnya 2 harakat.',
    exampleExplanationEn: 'The doubled Nun in إِنَّا must be held with nasal resonance for 2 counts.',
  ),
  TajweedLesson(
    rule: TajweedRule.idghamBighunnah,
    title: 'Idgham Bighunnah (Melebur dengan Dengung)',
    titleEn: 'Idgham with Ghunnah (Merging with Nasalization)',
    triggerLetters: 'ي ن م و (Yanmu)',
    triggerLettersEn: 'ي ن م و (Yanmu)',
    howToRead: 'Nun sukun atau tanwin dileburkan ke dalam salah satu huruf ي ن م و disertai dengung 2 harakat.',
    howToReadEn: 'Merge sakin nun or tanwin into any of the letters ي ن م و accompanied by 2 counts of nasal resonance.',
    exampleArabic: 'فَمَنْ يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
    exampleSurahRef: 'QS. Az-Zalzalah: 7',
    exampleSurahRefEn: 'Quran 99:7 (Az-Zalzalah)',
    exampleExplanation: 'Nun sukun pada فَمَنْ bertemu ي, dan tanwin pada خَيْرًا bertemu ي dibaca melebur disertai dengung.',
    exampleExplanationEn: 'Sakin nun in فَمَنْ before ي and tanwin in خَيْرًا before ي merge smoothly with nasalization.',
  ),
  TajweedLesson(
    rule: TajweedRule.idghamBilaghunnah,
    title: 'Idgham Bilaghunnah (Melebur Tanpa Dengung)',
    titleEn: 'Idgham without Ghunnah (Complete Merging)',
    triggerLetters: 'ل ، ر',
    triggerLettersEn: 'ل , ر',
    howToRead: 'Nun sukun atau tanwin masuk penuh ke huruf Lam atau Ra tanpa menahan dengung.',
    howToReadEn: 'Merge sakin nun or tanwin completely into Lam or Ra with no nasal hold.',
    exampleArabic: 'وَيْلٌ لِكُلِّ هُمَزَةٍ لُمَزَةٍ',
    exampleSurahRef: 'QS. Al-Humazah: 1',
    exampleSurahRefEn: 'Quran 104:1 (Al-Humazah)',
    exampleExplanation: 'Tanwin pada وَيْلٌ bertemu ل dan هُمَزَةٍ bertemu ل dileburkan langsung tanpa dengung.',
    exampleExplanationEn: 'Tanwin in وَيْلٌ before ل and هُمَزَةٍ before ل merges directly into ل with zero nasalization.',
  ),
  TajweedLesson(
    rule: TajweedRule.iqlab,
    title: 'Iqlab (Membalikkan Nun Sukun/Tanwin menjadi Mim)',
    titleEn: 'Iqlab (Converting Sakin Nun/Tanwin into Mim)',
    triggerLetters: 'ب',
    triggerLettersEn: 'ب',
    howToRead: 'Suara nun sukun atau tanwin diubah menjadi bunyi Mim samar saat bertemu huruf Ba, disertai dengung 2 harakat.',
    howToReadEn: 'Change the sound of sakin nun or tanwin into a concealed Mim before Ba, held with 2 counts of nasalization.',
    exampleArabic: 'كَلَّا ۖ لَيُنْبَذَنَّ فِي الْحُطَمَةِ',
    exampleSurahRef: 'QS. Al-Humazah: 4',
    exampleSurahRefEn: 'Quran 104:4 (Al-Humazah)',
    exampleExplanation: 'Nun sukun sebelum huruf ب pada لَيُنْبَذَنَّ dibaca menjadi bunyi mim berdengung.',
    exampleExplanationEn: 'The sakin nun before ب in لَيُنْبَذَنَّ transforms into a nasalized mim sound.',
  ),
  TajweedLesson(
    rule: TajweedRule.ikhfa,
    title: 'Ikhfa Haqiqi & Ikhfa Syafawi (Samar Berdengung)',
    titleEn: 'Ikhfa Haqiqi & Ikhfa Shafawi (Concealed with Ghunnah)',
    triggerLetters: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك (dan مْ bertemu ب)',
    triggerLettersEn: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك (and مْ before ب)',
    howToRead: 'Dibaca samar antara jelas (Idzhar) dan melebur (Idgham) disertai dengung 2 harakat menuju makhraj huruf berikutnya.',
    howToReadEn: 'Pronounce softly between clarity (Izhar) and merging (Idgham), holding 2 counts of nasal resonance prepared for the next letter.',
    exampleArabic: 'مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
    exampleSurahRef: 'QS. An-Nas: 4',
    exampleSurahRefEn: 'Quran 114:4 (An-Nas)',
    exampleExplanation: 'Nun sukun pada مِنْ bertemu ش dibaca samar berdengung (Ikhfa Haqiqi).',
    exampleExplanationEn: 'Sakin nun in مِنْ before ش is softly concealed with nasalization (Ikhfa Haqiqi).',
  ),
  TajweedLesson(
    rule: TajweedRule.qalqalah,
    title: 'Qalqalah (Pantulan Huruf Sukun)',
    titleEn: 'Qalqalah (Echoing Bounce on Sakin Letters)',
    triggerLetters: 'ق ط ب ج د (Baju Di Toko)',
    triggerLettersEn: 'ق ط ب ج د (Qutb Jadd)',
    howToRead: 'Memantulkan bunyi huruf qalqalah saat bersukun asli di tengah kata (Qalqalah Sugra) atau sukun karena waqaf di akhir ayat (Qalqalah Kubra).',
    howToReadEn: 'Produce a crisp bouncing echo on a qalqalah letter when vowelless mid-word (Qalqalah Sughra) or stronger when stopping at the end of a verse (Qalqalah Kubra).',
    exampleArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ',
    exampleSurahRef: 'QS. Al-Ikhlas: 1–3',
    exampleSurahRefEn: 'Quran 112:1-3 (Al-Ikhlas)',
    exampleExplanation: 'Huruf د di akhir ayat (أَحَدٌ، الصَّمَدُ، يُولَدْ) memantul kuat (Kubra), sedangkan pada يَلِدْ memantul ringan (Sugra).',
    exampleExplanationEn: 'The letter د at verse endings (أَحَدٌ, الصَّمَدُ, يُولَدْ) bounces strongly (Kubra), while in يَلِدْ it bounces lightly (Sughra).',
  ),
  TajweedLesson(
    rule: TajweedRule.madWajibMuttashil,
    title: 'Hukum Bacaan Mad (Panjang)',
    titleEn: 'Madd Rules (Elongation)',
    triggerLetters: 'ا ، و ، ي (dan bertemu Hamzah / Tasydid / Sukun)',
    triggerLettersEn: 'ا , و , ي (followed by Hamzah, Shaddah, or Sukun)',
    howToRead: 'Mad Thabi\'i dibaca 2 harakat; Mad Wajib Muttashil & Mad Jaiz Munfashil dibaca 4–5 harakat; Mad Lazim dibaca 6 harakat.',
    howToReadEn: 'Madd Tabi\'i is held 2 counts; Madd Wajib Muttasil and Madd Ja\'iz Munfasil are held 4 to 5 counts; Madd Lazim is held 6 counts.',
    exampleArabic: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
    exampleSurahRef: 'QS. An-Nashr: 1',
    exampleSurahRefEn: 'Quran 110:1 (An-Nasr)',
    exampleExplanation: 'Kata جَاءَ mengandung huruf mad bertemu hamzah dalam satu kata (Mad Wajib Muttashil, panjang 4–5 harakat).',
    exampleExplanationEn: 'In جَاءَ, a madd letter is followed by hamzah within the same word (Madd Wajib Muttasil, held 4 to 5 counts).',
  ),
];

class TajweedQuizItem {
  final String question;
  final String? questionEn;
  final String arabicSnippet;
  final List<String> options;
  final List<String>? optionsEn;
  final int correctIndex;
  final String explanation;
  final String? explanationEn;

  const TajweedQuizItem({
    required this.question,
    this.questionEn,
    required this.arabicSnippet,
    required this.options,
    this.optionsEn,
    required this.correctIndex,
    required this.explanation,
    this.explanationEn,
  });

  String questionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (questionEn?.isNotEmpty ?? false) ? questionEn! : question;
  List<String> optionsFor(AppLanguage lang) =>
      lang == AppLanguage.en && (optionsEn?.isNotEmpty ?? false) ? optionsEn! : options;
  String explanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (explanationEn?.isNotEmpty ?? false) ? explanationEn! : explanation;
}

const List<TajweedQuizItem> tajweedQuizBank = [
  TajweedQuizItem(
    question: 'Apakah hukum bacaan nun sukun bertemu huruf Syin (ش) pada potongan ayat berikut?',
    questionEn: 'Which tajweed rule applies when sakin nun meets the letter Shin (ش) in this excerpt?',
    arabicSnippet: 'مِنْ شَرِّ مَا خَلَقَ',
    options: ['Idzhar Halqi', 'Ikhfa Haqiqi', 'Idgham Bighunnah', 'Iqlab'],
    optionsEn: ['Izhar Halqi', 'Ikhfa Haqiqi', 'Idgham with Ghunnah', 'Iqlab'],
    correctIndex: 1,
    explanation: 'Nun sukun bertemu huruf ش termasuk 15 huruf Ikhfa Haqiqi, dibaca samar dengan dengung 2 harakat.',
    explanationEn: 'Sakin nun before ش is one of the 15 Ikhfa Haqiqi letters, pronounced softly concealed with 2 counts of nasalization.',
  ),
  TajweedQuizItem(
    question: 'Huruf Dal (د) yang bersukun pada kata berikut dibaca memantul karena termasuk hukum...',
    questionEn: 'The vowelless Dal (د) in this verse is pronounced with a bouncing echo under which rule?',
    arabicSnippet: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
    options: ['Qalqalah', 'Ghunnah', 'Idgham Bilaghunnah', 'Mad Wajib Muttashil'],
    optionsEn: ['Qalqalah', 'Ghunnah', 'Idgham without Ghunnah', 'Madd Wajib Muttasil'],
    correctIndex: 0,
    explanation: 'Huruf د termasuk lima huruf Qalqalah (ق ط ب ج د) yang wajib dipantulkan saat sukun.',
    explanationEn: 'The letter د is one of the five Qalqalah letters (ق ط ب ج د) that bounce when vowelless.',
  ),
  TajweedQuizItem(
    question: 'Nun sukun bertemu huruf Ba (ب) pada ayat berikut memiliki hukum bacaan...',
    questionEn: 'Sakin nun followed by the letter Ba (ب) in this verse follows which tajweed rule?',
    arabicSnippet: 'لَيُنْبَذَنَّ فِي الْحُطَمَةِ',
    options: ['Ikhfa Syafawi', 'Idzhar Syafawi', 'Iqlab', 'Idgham Bilaghunnah'],
    optionsEn: ['Ikhfa Shafawi', 'Izhar Shafawi', 'Iqlab', 'Idgham without Ghunnah'],
    correctIndex: 2,
    explanation: 'Nun sukun bertemu huruf ب adalah Iqlab: bunyi nun berubah menjadi mim samar disertai dengung.',
    explanationEn: 'Sakin nun before ب is Iqlab: the nun sound converts into a concealed mim with nasal resonance.',
  ),
  TajweedQuizItem(
    question: 'Di manakah tempat keluar (makhraj) suara dengung (ghunnah) pada huruf نّ dan مّ?',
    questionEn: 'Where is the articulation point (makhraj) for the nasal resonance (ghunnah) in نّ and مّ?',
    arabicSnippet: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
    options: ['Al-Jauf (Rongga Mulut)', 'Al-Halq (Tenggorokan)', 'Al-Khaisyum (Rongga Hidung)', 'Asy-Syafatain (Dua Bibir)'],
    optionsEn: ['Al-Jawf (Oral Cavity)', 'Al-Halq (The Throat)', 'Al-Khayshum (Nasal Passage)', 'Ash-Shafatan (Two Lips)'],
    correctIndex: 2,
    explanation: 'Suara dengung (ghunnah) keluar dari Al-Khaisyum (pangkal rongga hidung).',
    explanationEn: 'Nasal resonance (ghunnah) emerges from Al-Khayshum (the nasal passage).',
  ),
  TajweedQuizItem(
    question: 'Tanwin bertemu huruf Lam (ل) pada potongan ayat berikut dibaca...',
    questionEn: 'Tanwin followed by the letter Lam (ل) in this excerpt is recited as...',
    arabicSnippet: 'وَيْلٌ لِكُلِّ هُمَزَةٍ لُمَزَةٍ',
    options: ['Idgham Bilaghunnah (Melebur Tanpa Dengung)', 'Idgham Bighunnah', 'Idzhar Halqi', 'Ikhfa Haqiqi'],
    optionsEn: ['Idgham without Ghunnah (Merging without Nasalization)', 'Idgham with Ghunnah', 'Izhar Halqi', 'Ikhfa Haqiqi'],
    correctIndex: 0,
    explanation: 'Tanwin bertemu huruf ل atau ر adalah Idgham Bilaghunnah: melebur penuh tanpa ditahan dengungnya.',
    explanationEn: 'Tanwin before ل or ر is Idgham without Ghunnah: it merges completely without holding nasal resonance.',
  ),
];
