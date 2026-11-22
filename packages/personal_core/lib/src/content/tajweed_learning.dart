import 'tajweed.dart';

class MakhrajGroup {
  final String id;
  final String name;
  final String arabicName;
  final String letters;
  final String organDescription;
  final String practiceTip;

  const MakhrajGroup({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.letters,
    required this.organDescription,
    required this.practiceTip,
  });
}

const List<MakhrajGroup> makharijulHurufCatalog = [
  MakhrajGroup(
    id: 'al_jauf',
    name: '1. Al-Jauf (Rongga Mulut & Tenggorokan)',
    arabicName: 'الجَوْفُ',
    letters: 'ا و ي (Huruf Mad)',
    organDescription:
        'Tempat keluarnya tiga huruf mad: Alif setelah fathah, Wawu sukun setelah dhammah, dan Ya sukun setelah kasrah.',
    practiceTip: 'Suara mengalir bebas dari rongga tenggorokan hingga mulut tanpa hambatan lidah atau bibir.',
  ),
  MakhrajGroup(
    id: 'al_halq',
    name: '2. Al-Halq (Tenggorokan)',
    arabicName: 'الحَلْقُ',
    letters: 'ء هـ · ع ح · غ خ',
    organDescription:
        'Terbagi tiga titik: Pangkal tenggorokan (ء، هـ), Tengah tenggorokan (ع، ح), dan Ujung tenggorokan dekat mulut (غ، خ).',
    practiceTip: 'Huruf-huruf ini merupakan huruf Idzhar Halqi; ketika nun sukun/tanwin bertemu salah satunya, dibaca jelas tanpa dengung.',
  ),
  MakhrajGroup(
    id: 'al_lisan',
    name: '3. Al-Lisan (Lidah)',
    arabicName: 'اللِّسَانُ',
    letters: 'ق ك · ج ش ي · ض · ل ن ر · ط د ت · ص ز س · ظ ذ ث',
    organDescription:
        'Mencakup 10 titik makhraj untuk 18 huruf: pangkal lidah (ق، ك), tengah lidah (ج، ش، ي), tepi lidah ke geraham (ض), hingga ujung lidah.',
    practiceTip: 'Perhatikan perbedaan tipis antara huruf ujung lidah dengan gigi seri atas (ظ، ذ، ث) dan huruf desis/shafir (ص، ز، س).',
  ),
  MakhrajGroup(
    id: 'asy_syafatain',
    name: '4. Asy-Syafatain (Kedua Bibir)',
    arabicName: 'الشَّفَتَانِ',
    letters: 'ف · و ب م',
    organDescription:
        'Bibir bawah bagian dalam bertemu ujung gigi seri atas (ف), serta pertemuan atau membulatnya kedua bibir (ب، م، و).',
    practiceTip: 'Huruf ب dan م berkaitan langsung dengan hukum Ikhfa Syafawi, Idgham Mimi, dan Iqlab.',
  ),
  MakhrajGroup(
    id: 'al_khaisyum',
    name: '5. Al-Khaisyum (Pangkal Rongga Hidung)',
    arabicName: 'الخَيْشُومُ',
    letters: 'نّ مّ (Suara Ghunnah / Dengung)',
    organDescription:
        'Tempat keluarnya suara dengung (ghunnah) yang menyertai huruf Nun dan Mim bertasydid, Idgham Bighunnah, Iqlab, serta Ikhfa.',
    practiceTip: 'Tahan dengung selama 2 harakat penuh; jika hidung dipencet maka suara ghunnah akan tertahan.',
  ),
];

class TajweedLesson {
  final TajweedRule rule;
  final String title;
  final String triggerLetters;
  final String howToRead;
  final String exampleArabic;
  final String exampleSurahRef;
  final String exampleExplanation;

  const TajweedLesson({
    required this.rule,
    required this.title,
    required this.triggerLetters,
    required this.howToRead,
    required this.exampleArabic,
    required this.exampleSurahRef,
    required this.exampleExplanation,
  });
}

const List<TajweedLesson> tajweedLessonsCatalog = [
  TajweedLesson(
    rule: TajweedRule.ghunnah,
    title: 'Ghunnah Musyaddadah (Nun & Mim Tasydid)',
    triggerLetters: 'نّ ، مّ',
    howToRead: 'Didengungkan dengan jelas ke rongga hidung (Al-Khaisyum) sepanjang 2 ketukan/harakat.',
    exampleArabic: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
    exampleSurahRef: 'QS. Al-Kautsar: 1',
    exampleExplanation: 'Huruf Nun bertasydid pada kata إِنَّا wajib ditahan dengungnya 2 harakat.',
  ),
  TajweedLesson(
    rule: TajweedRule.idghamBighunnah,
    title: 'Idgham Bighunnah (Melebur dengan Dengung)',
    triggerLetters: 'ي ن م و (Yanmu)',
    howToRead: 'Nun sukun atau tanwin dileburkan ke dalam salah satu huruf ي ن م و disertai dengung 2 harakat.',
    exampleArabic: 'فَمَنْ يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
    exampleSurahRef: 'QS. Az-Zalzalah: 7',
    exampleExplanation: 'Nun sukun pada فَمَنْ bertemu ي, dan tanwin pada خَيْرًا bertemu ي dibaca melebur disertai dengung.',
  ),
  TajweedLesson(
    rule: TajweedRule.idghamBilaghunnah,
    title: 'Idgham Bilaghunnah (Melebur Tanpa Dengung)',
    triggerLetters: 'ل ، ر',
    howToRead: 'Nun sukun atau tanwin masuk penuh ke huruf Lam atau Ra tanpa menahan dengung.',
    exampleArabic: 'وَيْلٌ لِكُلِّ هُمَزَةٍ لُمَزَةٍ',
    exampleSurahRef: 'QS. Al-Humazah: 1',
    exampleExplanation: 'Tanwin pada وَيْلٌ bertemu ل dan هُمَزَةٍ bertemu ل dileburkan langsung tanpa dengung.',
  ),
  TajweedLesson(
    rule: TajweedRule.iqlab,
    title: 'Iqlab (Membalikkan Nun Sukun/Tanwin menjadi Mim)',
    triggerLetters: 'ب',
    howToRead: 'Suara nun sukun atau tanwin diubah menjadi bunyi Mim samar saat bertemu huruf Ba, disertai dengung 2 harakat.',
    exampleArabic: 'كَلَّا ۖ لَيُنْبَذَنَّ فِي الْحُطَمَةِ',
    exampleSurahRef: 'QS. Al-Humazah: 4',
    exampleExplanation: 'Nun sukun sebelum huruf ب pada لَيُنْبَذَنَّ dibaca menjadi bunyi mim berdengung.',
  ),
  TajweedLesson(
    rule: TajweedRule.ikhfa,
    title: 'Ikhfa Haqiqi & Ikhfa Syafawi (Samar Berdengung)',
    triggerLetters: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك (dan مْ bertemu ب)',
    howToRead: 'Dibaca samar antara jelas (Idzhar) dan melebur (Idgham) disertai dengung 2 harakat menuju makhraj huruf berikutnya.',
    exampleArabic: 'مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
    exampleSurahRef: 'QS. An-Nas: 4',
    exampleExplanation: 'Nun sukun pada مِنْ bertemu ش dibaca samar berdengung (Ikhfa Haqiqi).',
  ),
  TajweedLesson(
    rule: TajweedRule.qalqalah,
    title: 'Qalqalah (Pantulan Huruf Sukun)',
    triggerLetters: 'ق ط ب ج د (Baju Di Toko)',
    howToRead: 'Memantulkan bunyi huruf qalqalah saat bersukun asli di tengah kata (Qalqalah Sugra) atau sukun karena waqaf di akhir ayat (Qalqalah Kubra).',
    exampleArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ',
    exampleSurahRef: 'QS. Al-Ikhlas: 1–3',
    exampleExplanation: 'Huruf د di akhir ayat (أَحَدٌ، الصَّمَدُ، يُولَدْ) memantul kuat (Kubra), sedangkan pada يَلِدْ memantul ringan (Sugra).',
  ),
  TajweedLesson(
    rule: TajweedRule.madWajibMuttashil,
    title: 'Hukum Bacaan Mad (Panjang)',
    triggerLetters: 'ا ، و ، ي (dan bertemu Hamzah / Tasydid / Sukun)',
    howToRead: 'Mad Thabi\'i dibaca 2 harakat; Mad Wajib Muttashil & Mad Jaiz Munfashil dibaca 4–5 harakat; Mad Lazim dibaca 6 harakat.',
    exampleArabic: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
    exampleSurahRef: 'QS. An-Nashr: 1',
    exampleExplanation: 'Kata جَاءَ mengandung huruf mad bertemu hamzah dalam satu kata (Mad Wajib Muttashil, panjang 4–5 harakat).',
  ),
];

class TajweedQuizItem {
  final String question;
  final String arabicSnippet;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const TajweedQuizItem({
    required this.question,
    required this.arabicSnippet,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

const List<TajweedQuizItem> tajweedQuizBank = [
  TajweedQuizItem(
    question: 'Apakah hukum bacaan nun sukun bertemu huruf Syin (ش) pada potongan ayat berikut?',
    arabicSnippet: 'مِنْ شَرِّ مَا خَلَقَ',
    options: ['Idzhar Halqi', 'Ikhfa Haqiqi', 'Idgham Bighunnah', 'Iqlab'],
    correctIndex: 1,
    explanation: 'Nun sukun bertemu huruf ش termasuk 15 huruf Ikhfa Haqiqi, dibaca samar dengan dengung 2 harakat.',
  ),
  TajweedQuizItem(
    question: 'Huruf Dal (د) yang bersukun pada kata berikut dibaca memantul karena termasuk hukum...',
    arabicSnippet: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
    options: ['Qalqalah', 'Ghunnah', 'Idgham Bilaghunnah', 'Mad Wajib Muttashil'],
    correctIndex: 0,
    explanation: 'Huruf د termasuk lima huruf Qalqalah (ق ط ب ج د) yang wajib dipantulkan saat sukun.',
  ),
  TajweedQuizItem(
    question: 'Nun sukun bertemu huruf Ba (ب) pada ayat berikut memiliki hukum bacaan...',
    arabicSnippet: 'لَيُنْبَذَنَّ فِي الْحُطَمَةِ',
    options: ['Ikhfa Syafawi', 'Idzhar Syafawi', 'Iqlab', 'Idgham Bilaghunnah'],
    correctIndex: 2,
    explanation: 'Nun sukun bertemu huruf ب adalah Iqlab: bunyi nun berubah menjadi mim samar disertai dengung.',
  ),
  TajweedQuizItem(
    question: 'Di manakah tempat keluar (makhraj) suara dengung (ghunnah) pada huruf نّ dan مّ?',
    arabicSnippet: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
    options: ['Al-Jauf (Rongga Mulut)', 'Al-Halq (Tenggorokan)', 'Al-Khaisyum (Rongga Hidung)', 'Asy-Syafatain (Dua Bibir)'],
    correctIndex: 2,
    explanation: 'Suara dengung (ghunnah) keluar dari Al-Khaisyum (pangkal rongga hidung).',
  ),
  TajweedQuizItem(
    question: 'Tanwin bertemu huruf Lam (ل) pada potongan ayat berikut dibaca...',
    arabicSnippet: 'وَيْلٌ لِكُلِّ هُمَزَةٍ لُمَزَةٍ',
    options: ['Idgham Bilaghunnah (Melebur Tanpa Dengung)', 'Idgham Bighunnah', 'Idzhar Halqi', 'Ikhfa Haqiqi'],
    correctIndex: 0,
    explanation: 'Tanwin bertemu huruf ل atau ر adalah Idgham Bilaghunnah: melebur penuh tanpa ditahan dengungnya.',
  ),
];
