import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';

/// Aktivitas latihan interaktif pada setiap pelajaran Learning Path (LP-05).
class LearningActivity {
  final String id;
  final String promptId;
  final String promptEn;
  final String? arabicSample;
  final List<String> choicesId;
  final List<String> choicesEn;
  final int correctIndex;
  final String feedbackId;
  final String feedbackEn;

  const LearningActivity({
    required this.id,
    required this.promptId,
    required this.promptEn,
    this.arabicSample,
    required this.choicesId,
    required this.choicesEn,
    required this.correctIndex,
    required this.feedbackId,
    required this.feedbackEn,
  });

  String promptFor(AppLanguage l) => l == AppLanguage.en ? promptEn : promptId;
  List<String> choicesFor(AppLanguage l) => l == AppLanguage.en ? choicesEn : choicesId;
  String feedbackFor(AppLanguage l) => l == AppLanguage.en ? feedbackEn : feedbackId;
}

class LearningLesson {
  final String id;
  final String pathId;
  final int levelOrder;
  final String levelTitleId;
  final String levelTitleEn;
  final String titleId;
  final String titleEn;
  final int estimatedMinutes;
  final String bodyId;
  final String bodyEn;
  final String? arabicHighlight;
  final String sourceRef;
  final String reviewer;
  final String reviewedAt;
  final String contentVersion;
  final String offlineBundleId;
  final int bundleSizeKb;
  final List<LearningActivity> activities;

  const LearningLesson({
    required this.id,
    required this.pathId,
    required this.levelOrder,
    required this.levelTitleId,
    required this.levelTitleEn,
    required this.titleId,
    required this.titleEn,
    required this.estimatedMinutes,
    required this.bodyId,
    required this.bodyEn,
    this.arabicHighlight,
    required this.sourceRef,
    this.reviewer = 'Tim Kurasi Materi Moeslim PM',
    this.reviewedAt = '2026-11-24',
    this.contentVersion = '1.0',
    required this.offlineBundleId,
    this.bundleSizeKb = 48,
    this.activities = const [],
  });

  String titleFor(AppLanguage l) => l == AppLanguage.en ? titleEn : titleId;
  String levelTitleFor(AppLanguage l) => l == AppLanguage.en ? levelTitleEn : levelTitleId;
  String bodyFor(AppLanguage l) => l == AppLanguage.en ? bodyEn : bodyId;
}

class LearningPathTrack {
  final String id; // arabic, quran, fiqih, hadith, sejarah, akhlak
  final String titleId;
  final String titleEn;
  final String summaryId;
  final String summaryEn;
  final List<LearningLesson> lessons;

  const LearningPathTrack({
    required this.id,
    required this.titleId,
    required this.titleEn,
    required this.summaryId,
    required this.summaryEn,
    required this.lessons,
  });

  String titleFor(AppLanguage l) => l == AppLanguage.en ? titleEn : titleId;
  String summaryFor(AppLanguage l) => l == AppLanguage.en ? summaryEn : summaryId;
}

/// Katalog resmi 6 jalur Moeslim Learning Path (LP-01..LP-09).
/// Catatan produk: TIDAK memuat fitur 7 Naghom (dikeluarkan dari roadmap).
const List<LearningPathTrack> learningPathCatalog = [
  LearningPathTrack(
    id: 'arabic',
    titleId: 'Bahasa Arab & Terjemahan',
    titleEn: 'Arabic & Translation',
    summaryId: 'L1 Huruf Hijaiyah, L2 Kosakata & Percakapan, L3 Nahwu Sharaf, L4 Terjemahan, L5 Arab Al-Qur\'an.',
    summaryEn: 'L1 Arabic Letters, L2 Vocabulary & Dialogue, L3 Grammar, L4 Translation, L5 Quranic Arabic.',
    lessons: [
      LearningLesson(
        id: 'ar_l1_huruf',
        pathId: 'arabic',
        levelOrder: 1,
        levelTitleId: 'L1: Huruf & Dasar',
        levelTitleEn: 'L1: Letters & Basics',
        titleId: 'Mengenal Huruf Hijaiyah & Bentuk Sambung',
        titleEn: 'Arabic Letters & Connected Forms',
        estimatedMinutes: 8,
        arabicHighlight: 'بَ بِ بُ  •  بـ  ـبـ  ـب',
        bodyId: 'Huruf Arab ditulis dari kanan ke kiri (RTL). Sebagian besar huruf dapat disambung ke kiri, kecuali 6 huruf non-sambung ke kiri: ا د ذ ر ز و. Harakat fathah (a), kasrah (i), dan dhammah (u) menjadi bunyi vokal dasar.',
        bodyEn: 'Arabic is written right-to-left (RTL). Most letters connect on both sides except six non-connecting letters to the left: alif, dal, dzal, ra, zay, and waw. Fathah (a), kasrah (i), and dhammah (u) form the basic vowel sounds.',
        sourceRef: 'Qaidah Baghdadiyah & Iqra Dasar',
        offlineBundleId: 'bundle_arabic_l1',
        bundleSizeKb: 64,
        activities: [
          LearningActivity(
            id: 'ar_l1_q1',
            promptId: 'Manakah huruf yang TIDAK bisa disambung dengan huruf setelahnya (di sebelah kirinya)?',
            promptEn: 'Which letter does NOT connect to the letter following it (to its left)?',
            arabicSample: 'د  /  ب  /  س',
            choicesId: ['Huruf Dal (د)', 'Huruf Ba (ب)', 'Huruf Sin (س)'],
            choicesEn: ['Letter Dal (د)', 'Letter Ba (ب)', 'Letter Sin (س)'],
            correctIndex: 0,
            feedbackId: 'Benar! Dal (د) termasuk 6 huruf (ا د ذ ر ز و) yang hanya menerima sambungan dari kanan.',
            feedbackEn: 'Correct! Dal (د) belongs to the six letters that only connect from the right.',
          ),
        ],
      ),
      LearningLesson(
        id: 'ar_l2_kosakata',
        pathId: 'arabic',
        levelOrder: 2,
        levelTitleId: 'L2: Kosakata & Percakapan',
        levelTitleEn: 'L2: Vocabulary & Dialogue',
        titleId: 'Salam, Perkenalan & Kosakata Masjid',
        titleEn: 'Greetings, Introductions & Mosque Words',
        estimatedMinutes: 10,
        arabicHighlight: 'السَّلَامُ عَلَيْكُمْ • أَنَا ذَاهِبٌ إِلَى الْمَسْجِدِ',
        bodyId: 'Mulailah dengan ungkapan yang langsung terpakai setiap hari: salam (السَّلَامُ عَلَيْكُمْ), menyebut nama (اِسْمِي ...), dan kata benda sekitar masjid seperti مَسْجِد (masjid), بَيْت (rumah), وُضُوء (wudhu), dan كِتَاب (buku).',
        bodyEn: 'Start with phrases you use every day: greetings (As-salamu \'alaykum), introducing yourself (Ismi ...), and mosque vocabulary such as masjid, bayt (house), wudu, and kitab (book).',
        sourceRef: 'Durus al-Lughah al-Arabiyyah Jilid 1',
        offlineBundleId: 'bundle_arabic_l2',
        bundleSizeKb: 72,
        activities: [
          LearningActivity(
            id: 'ar_l2_q1',
            promptId: 'Apa arti kalimat di bawah ini?',
            promptEn: 'What does the sentence below mean?',
            arabicSample: 'بَيْتِي قَرِيبٌ مِنَ الْمَسْجِدِ',
            choicesId: ['Rumahku dekat dari masjid', 'Masjidku jauh dari rumah', 'Bukuku ada di rumah'],
            choicesEn: ['My house is close to the mosque', 'My mosque is far from home', 'My book is at home'],
            correctIndex: 0,
            feedbackId: 'Tepat sekali! بَيْتِي = rumahku, قَرِيبٌ = dekat, مِنَ الْمَسْجِدِ = dari masjid.',
            feedbackEn: 'Spot on! Bayti = my house, qaribun = close, minal-masjid = from the mosque.',
          ),
        ],
      ),
      LearningLesson(
        id: 'ar_l3_nahwu',
        pathId: 'arabic',
        levelOrder: 3,
        levelTitleId: 'L3: Tata Bahasa (Nahwu & Sharaf)',
        levelTitleEn: 'L3: Grammar (Nahwu & Sharaf)',
        titleId: 'Tiga Jenis Kata: Ism, Fi\'il, dan Harf',
        titleEn: 'Three Word Classes: Ism, Fi\'l, and Harf',
        estimatedMinutes: 12,
        arabicHighlight: 'الْكَلِمَةُ: اِسْمٌ • فِعْلٌ • حَرْفٌ',
        bodyId: 'Seluruh kata dalam bahasa Arab terbagi menjadi 3 golongan utama: (1) Ism (kata benda/sifat/nama, menerima tanwin atau ال), (2) Fi\'il (kata kerja yang terikat waktu: madhi/lampau, mudhari\'/sekarang-akan datang, amr/perintah), dan (3) Harf (kata hubung/depan seperti فِي، إِلَى، مِنْ).',
        bodyEn: 'Every Arabic word belongs to one of three categories: (1) Ism (nouns/adjectives, accepting tanwin or al-), (2) Fi\'l (verbs tied to time: past, present/future, imperative), and (3) Harf (particles/prepositions like fi, ila, min).',
        sourceRef: 'Matn Al-Ajurrumiyyah (Ringkasan Nahwu Dasar)',
        offlineBundleId: 'bundle_arabic_l3',
        bundleSizeKb: 68,
        activities: [
          LearningActivity(
            id: 'ar_l3_q1',
            promptId: 'Kata "فِي" (di dalam) termasuk jenis kata apa dalam Nahwu?',
            promptEn: 'Which word class does "فِي" (in) belong to?',
            arabicSample: 'الْكِتَابُ فِي الْمَسْجِدِ',
            choicesId: ['Harf (Kata depan/hubung)', 'Fi\'il Madhi (Kata kerja lampau)', 'Ism Isyarah (Kata tunjuk)'],
            choicesEn: ['Harf (Particle / Preposition)', 'Past Verb (Fi\'l Madhi)', 'Demonstrative Noun'],
            correctIndex: 0,
            feedbackId: 'Benar! فِي adalah Harf Jar yang membuat kata benda setelahnya berharakat kasrah (الْمَسْجِدِ).',
            feedbackEn: 'Correct! Fi is a preposition (harf jarr) that gives the following noun a kasrah ending.',
          ),
        ],
      ),
      LearningLesson(
        id: 'ar_l4_terjemah',
        pathId: 'arabic',
        levelOrder: 4,
        levelTitleId: 'L4: Terjemahan',
        levelTitleEn: 'L4: Translation',
        titleId: 'Menerjemahkan Kalimat Nominal & Verbal Sederhana',
        titleEn: 'Translating Basic Nominal & Verbal Sentences',
        estimatedMinutes: 12,
        arabicHighlight: 'الْقُرْآنُ هُدًى لِلنَّاسِ  •  قَرَأَ أَحْمَدُ الْقُرْآنَ',
        bodyId: 'Dalam bahasa Arab, kalimat nominal (Jumlah Ismiyyah) dimulai dari subjek (Mubtada\') lalu predikat (Khabar) tanpa kata "adalah". Kalimat verbal (Jumlah Fi\'liyyah) sering mendahulukan kata kerja sebelum pelaku (Fa\'il). Perhatikan konteks agar terjemahan tetap alami dalam bahasa Indonesia.',
        bodyEn: 'Nominal sentences (Jumlah Ismiyyah) open with subject + predicate without an explicit "is". Verbal sentences (Jumlah Fi\'liyyah) typically place the verb before its subject. Always translate according to natural context.',
        sourceRef: 'Panduan Tarjamah Arab-Indonesia Moeslim PM',
        offlineBundleId: 'bundle_arabic_l4',
        bundleSizeKb: 60,
        activities: [
          LearningActivity(
            id: 'ar_l4_q1',
            promptId: 'Terjemahan alami untuk "قَرَأَ أَحْمَدُ الْكِتَابَ" adalah:',
            promptEn: 'The natural translation of "قَرَأَ أَحْمَدُ الْكِتَابَ" is:',
            arabicSample: 'قَرَأَ أَحْمَدُ الْكِتَابَ',
            choicesId: ['Ahmad telah membaca buku itu', 'Buku itu membaca Ahmad', 'Ahmad akan menulis buku'],
            choicesEn: ['Ahmad read the book', 'The book read Ahmad', 'Ahmad will write the book'],
            correctIndex: 0,
            feedbackId: 'Bagus! قَرَأَ = telah membaca (fi\'il madhi), أَحْمَدُ = pelaku (fa\'il), الْكِتَابَ = objek (maf\'ul bih).',
            feedbackEn: 'Well done! Qara\'a (read), Ahmad (subject), al-kitaba (direct object).',
          ),
        ],
      ),
      LearningLesson(
        id: 'ar_l5_quran',
        pathId: 'arabic',
        levelOrder: 5,
        levelTitleId: 'L5: Bahasa Arab Al-Qur\'an',
        levelTitleEn: 'L5: Quranic Arabic',
        titleId: 'Mengenal Akar Kata Al-Qur\'an & Batas Tafsir',
        titleEn: 'Quranic Word Roots & Distinguishing Tafsir',
        estimatedMinutes: 14,
        arabicHighlight: 'ر ح م  →  رَحْمَةٌ • الرَّحْمٰن • الرَّحِيم',
        bodyId: 'Banyak kosakata Al-Qur\'an terbentuk dari akar tiga huruf (tsulatsi). Memahami akar kata membantu tadabbur bahasa, namun analisis bahasa BUKAN pengganti tafsir. Untuk hukum dan maksud ayat, selalu rujuk terjemahan resmi dan kitab tafsir mu\'tabar.',
        bodyEn: 'Most Quranic vocabulary derives from three-letter roots. Studying roots enriches linguistic appreciation, yet lexical analysis does not replace tafsir. Always consult authorized translations and classical tafsir for verse meanings.',
        sourceRef: 'Mu\'jam Alfazh Al-Qur\'an & Al-Qur\'an Kemenag RI',
        offlineBundleId: 'bundle_arabic_l5',
        bundleSizeKb: 76,
        activities: [
          LearningActivity(
            id: 'ar_l5_q1',
            promptId: 'Akar kata tiga huruf (tsulatsi) dari kata الرَّحْمٰن dan الرَّحِيم adalah:',
            promptEn: 'The three-letter root of Ar-Rahman and Ar-Rahim is:',
            arabicSample: 'الرَّحْمٰنِ الرَّحِيمِ',
            choicesId: ['ر - ح - م (kasih sayang)', 'ع - ل - م (ilmu)', 'ح - م - د (pujian)'],
            choicesEn: ['ر - ح - م (mercy)', 'ع - ل - م (knowledge)', 'ح - م - د (praise)'],
            correctIndex: 0,
            feedbackId: 'Tepat! Keduanya berasal dari akar ر ح م yang menunjukkan keluasan dan kekekalan rahmat Allah.',
            feedbackEn: 'Correct! Both derive from the root r-h-m signifying vast and enduring mercy.',
          ),
        ],
      ),
    ],
  ),
  LearningPathTrack(
    id: 'quran',
    titleId: 'Al-Qur\'an & Tajwid',
    titleEn: 'Al-Qur\'an & Tajweed',
    summaryId: 'Tahsin bacaan, makharijul huruf, hukum nun mati & mad, serta metode muraja\'ah hafalan.',
    summaryEn: 'Recitation refinement, articulation points, noon sakinah & madd rules, and memorization review.',
    lessons: [
      LearningLesson(
        id: 'qr_l1_tahsin',
        pathId: 'quran',
        levelOrder: 1,
        levelTitleId: 'L1: Dasar Tajwid',
        levelTitleEn: 'L1: Tajweed Basics',
        titleId: 'Hukum Nun Sukun & Tanwin dalam Bacaan Harian',
        titleEn: 'Noon Sakinah & Tanwin Rules in Daily Recitation',
        estimatedMinutes: 10,
        arabicHighlight: 'إِظْهَار • إِدْغَام • إِقْلَاب • إِخْفَاء',
        bodyId: 'Empat hukum pokok nun sukun/tanwin adalah Idzhar (jelas bertemu huruf tenggorokan), Idgham (melebur ke ي ر م ل و ن), Iqlab (berubah ke mim bertemu ب), dan Ikhfa\' (samar dengan dengung). Pelajari perlahan dan periksakan bacaan kepada guru talaqqi.',
        bodyEn: 'The four main rules are Idzhar (clear), Idgham (merging), Iqlab (converting to meem before ba), and Ikhfa\' (concealed nasalization). Practice steadily and verify with a qualified teacher.',
        sourceRef: 'Tuhfatul Athfal, Syaikh Sulaiman Al-Jamzuri',
        offlineBundleId: 'bundle_quran_l1',
        bundleSizeKb: 52,
        activities: [
          LearningActivity(
            id: 'qr_l1_q1',
            promptId: 'Jika nun sukun (نْ) bertemu huruf ba (ب), hukum bacaannya adalah:',
            promptEn: 'When noon sakinah meets the letter ba (ب), the tajweed rule is:',
            arabicSample: 'مِنْ بَعْدِ',
            choicesId: ['Iqlab', 'Idzhar Halqi', 'Idgham Bilaghunnah'],
            choicesEn: ['Iqlab', 'Idzhar Halqi', 'Idgham Bilaghunnah'],
            correctIndex: 0,
            feedbackId: 'Benar! Nun sukun bertemu ب dibaca Iqlab (bunyi mim halus disertai ghunnah 2 harakat).',
            feedbackEn: 'Correct! Noon sakinah before ba is recited as Iqlab with gentle ghunnah.',
          ),
        ],
      ),
    ],
  ),
  LearningPathTrack(
    id: 'fiqih',
    titleId: 'Fikih Ibadah',
    titleEn: 'Fiqh of Worship',
    summaryId: 'Thaharah, syarat & rukun salat, fikih puasa, serta prinsip zakat beserta catatan rujukan.',
    summaryEn: 'Purification, prayer pillars, fasting jurisprudence, and zakat principles with scholarly references.',
    lessons: [
      LearningLesson(
        id: 'fq_l1_thaharah',
        pathId: 'fiqih',
        levelOrder: 1,
        levelTitleId: 'L1: Bersuci',
        levelTitleEn: 'L1: Purification',
        titleId: 'Rukun Wudhu & Catatan Perbedaan Mazhab',
        titleEn: 'Pillars of Wudu & Madhab Notes',
        estimatedMinutes: 10,
        bodyId: 'Rukun wudhu yang disepakati mayoritas ulama merujuk QS. Al-Ma\'idah: 6: niat (menurut jumhur Syafi\'i/Maliki/Hanbali; sunnah mu\'akkadah menurut Hanafi), membasuh wajah, kedua tangan hingga siku, mengusap kepala, membasuh kaki hingga mata kaki, serta tertib (wajib menurut Syafi\'i & Hanbali).',
        bodyEn: 'Based on QS. Al-Ma\'idah: 6, core wudu pillars include intention (obligatory in Shafi\'i/Maliki/Hanbali; emphasized sunnah in Hanafi), washing the face, arms to elbows, wiping the head, washing feet to ankles, and maintaining order.',
        sourceRef: 'Safinatun Najah & Al-Fiqh al-Islami wa Adillatuhu',
        offlineBundleId: 'bundle_fiqih_l1',
        bundleSizeKb: 44,
        activities: [
          LearningActivity(
            id: 'fq_l1_q1',
            promptId: 'Ayat Al-Qur\'an utama yang menjadi dasar perintah dan anggota wudhu adalah:',
            promptEn: 'Which Quranic verse forms the primary basis for the limbs of wudu?',
            choicesId: ['QS. Al-Ma\'idah: 6', 'QS. Al-Baqarah: 282', 'QS. Al-Ikhlas: 1-4'],
            choicesEn: ['QS. Al-Ma\'idah: 6', 'QS. Al-Baqarah: 282', 'QS. Al-Ikhlas: 1-4'],
            correctIndex: 0,
            feedbackId: 'Tepat! QS. Al-Ma\'idah ayat 6 menjelaskan anggota wudhu dan tayammum.',
            feedbackEn: 'Correct! QS. Al-Ma\'idah verse 6 outlines wudu and tayammum.',
          ),
        ],
      ),
    ],
  ),
  LearningPathTrack(
    id: 'hadith',
    titleId: 'Hadis & Tafsir',
    titleEn: 'Hadith & Tafsir',
    summaryId: 'Hadis pilihan Arba\'in beserta derajat sanad, serta kaidah dasar memahami tafsir ayat.',
    summaryEn: 'Selected Arba\'in hadiths with authenticity grades and foundational principles of tafsir.',
    lessons: [
      LearningLesson(
        id: 'hd_l1_niat',
        pathId: 'hadith',
        levelOrder: 1,
        levelTitleId: 'L1: Hadis Pokok',
        levelTitleEn: 'L1: Core Hadiths',
        titleId: 'Hadis Niat & Cara Membaca Derajat Hadis',
        titleEn: 'Hadith of Intention & Understanding Hadith Grades',
        estimatedMinutes: 8,
        arabicHighlight: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        bodyId: 'Hadis pertama dalam Shahih al-Bukhari (no. 1) dan Arba\'in Nawawi diriwayatkan Umar bin Khaththab RA dengan derajat Shahih (Muttafaqun \'Alaih). Selalu periksa perawi dan derajat (shahih/hasan/dhaif) sebelum menyandarkan ucapan kepada Nabi SAW.',
        bodyEn: 'The opening hadith of Sahih al-Bukhari (#1) and Nawawi\'s Forty, narrated by Umar ibn al-Khattab (RA), is graded Sahih (Agreed Upon). Always verify the narrator chain and grade before attributing a saying to the Prophet (PBUH).',
        sourceRef: 'Shahih al-Bukhari no. 1 & Syarh Arba\'in Nawawi',
        offlineBundleId: 'bundle_hadith_l1',
        bundleSizeKb: 42,
        activities: [
          LearningActivity(
            id: 'hd_l1_q1',
            promptId: 'Apa arti istilah "Muttafaqun \'Alaih" pada sebuah hadis?',
            promptEn: 'What does "Muttafaqun \'Alayh" (Agreed Upon) mean for a hadith?',
            choicesId: [
              'Diriwayatkan oleh Imam al-Bukhari dan Imam Muslim sekaligus',
              'Hadis yang tidak memiliki perawi',
              'Pendapat pribadi seorang penulis modern',
            ],
            choicesEn: [
              'Recorded by both Imam al-Bukhari and Imam Muslim',
              'A report with no narrators',
              'An opinion of a modern author',
            ],
            correctIndex: 0,
            feedbackId: 'Benar! Muttafaqun \'Alaih berarti disepakati kesahihannya dalam Shahih al-Bukhari dan Shahih Muslim.',
            feedbackEn: 'Correct! It signifies agreement in both Sahih al-Bukhari and Sahih Muslim.',
          ),
        ],
      ),
    ],
  ),
  LearningPathTrack(
    id: 'sejarah',
    titleId: 'Sejarah Islam',
    titleEn: 'Islamic History',
    summaryId: 'Kronologi Sirah Nabawiyah periode Makkah–Madinah, kisah sahabat, dan hikmah sejarah.',
    summaryEn: 'Chronology of the Prophetic Seerah across Makkah and Madinah, companions, and lessons.',
    lessons: [
      LearningLesson(
        id: 'sj_l1_hijrah',
        pathId: 'sejarah',
        levelOrder: 1,
        levelTitleId: 'L1: Sirah Nabawiyah',
        levelTitleEn: 'L1: Prophetic Seerah',
        titleId: 'Hijrah ke Madinah & Pembangunan Masjid Pertama',
        titleEn: 'The Hijrah to Madinah & Building the First Mosque',
        estimatedMinutes: 10,
        bodyId: 'Pada tahun 1 H (622 M), Rasulullah SAW berhijrah dari Makkah ke Yatsrib (Madinah). Langkah awal peradaban yang dilakukan adalah mendirikan Masjid Quba, membangun Masjid Nabawi sebagai pusat ibadah dan musyawarah, serta mempersaudarakan Muhajirin dan Anshar.',
        bodyEn: 'In 1 AH (622 CE), the Prophet (PBUH) migrated from Makkah to Madinah. His earliest civic milestones included establishing Masjid Quba, building the Prophet\'s Mosque as a hub of worship and community life, and uniting the Muhajirun and Ansar.',
        sourceRef: 'Ar-Rahiq al-Makhtum, Syaikh Shafiyyurrahman al-Mubarakfuri',
        offlineBundleId: 'bundle_sejarah_l1',
        bundleSizeKb: 46,
        activities: [
          LearningActivity(
            id: 'sj_l1_q1',
            promptId: 'Masjid pertama yang dibangun Rasulullah SAW saat tiba di pinggiran Madinah adalah:',
            promptEn: 'What was the first mosque built by the Prophet (PBUH) upon reaching the outskirts of Madinah?',
            choicesId: ['Masjid Quba', 'Masjid Al-Aqsa', 'Masjid Istiqlal'],
            choicesEn: ['Masjid Quba', 'Al-Aqsa Mosque', 'Istiqlal Mosque'],
            correctIndex: 0,
            feedbackId: 'Benar! Masjid Quba menjadi masjid pertama yang didirikan atas dasar takwa saat Hijrah.',
            feedbackEn: 'Correct! Masjid Quba was the first mosque founded upon taqwa during the Hijrah.',
          ),
        ],
      ),
    ],
  ),
  LearningPathTrack(
    id: 'akhlak',
    titleId: 'Akhlak & Adab',
    titleEn: 'Character & Etiquette',
    summaryId: 'Adab harian, etika berkeluarga, tabayyun dalam bermuamalah, tanpa pemeringkatan kesalehan.',
    summaryEn: 'Daily etiquette, family warmth, verifying news (tabayyun), focused on gentle learning habits.',
    lessons: [
      LearningLesson(
        id: 'ak_l1_tabayyun',
        pathId: 'akhlak',
        levelOrder: 1,
        levelTitleId: 'L1: Adab Harian',
        levelTitleEn: 'L1: Daily Etiquette',
        titleId: 'Adab Tabayyun & Menjaga Lisan di Era Digital',
        titleEn: 'Tabayyun & Guarding Speech in the Digital Era',
        estimatedMinutes: 7,
        bodyId: 'QS. Al-Hujurat ayat 6 mengajarkan prinsip tabayyun: memeriksa kebenaran kabar sebelum meneruskannya agar tidak menzalimi sesama. Kebiasaan kecil seperti menahan diri sebelum meneruskan pesan berantai merupakan bagian penting dari akhlak mulia.',
        bodyEn: 'QS. Al-Hujurat verse 6 teaches tabayyun: verifying news before spreading it so we never harm others unjustly. Pausing before forwarding messages is a practical modern expression of noble character.',
        sourceRef: 'QS. Al-Hujurat: 6 & Al-Adab al-Mufrad',
        offlineBundleId: 'bundle_akhlak_l1',
        bundleSizeKb: 40,
        activities: [
          LearningActivity(
            id: 'ak_l1_q1',
            promptId: 'Sikap terbaik menurut prinsip tabayyun saat menerima kabar yang belum jelas sumbernya adalah:',
            promptEn: 'According to tabayyun, what is the best response to unverified news?',
            choicesId: [
              'Memeriksa kebenarannya dahulu dan tidak tergesa menyebarkan',
              'Langsung meneruskan ke semua grup',
              'Menambahkan opini tanpa mengecek fakta',
            ],
            choicesEn: [
              'Verify its truth first and avoid rushing to forward it',
              'Immediately forward it to every group',
              'Add speculation without checking facts',
            ],
            correctIndex: 0,
            feedbackId: 'Tepat! Menahan diri untuk memeriksa kebenaran menjaga kehormatan sesama dan ketenangan umat.',
            feedbackEn: 'Correct! Pausing to verify protects others\' dignity and community peace.',
          ),
        ],
      ),
    ],
  ),
];

class LessonProgress {
  final String lessonId;
  final String status; // not_started, in_progress, completed
  final int bestScore;
  final int totalQuestions;
  final DateTime updatedAt;

  const LessonProgress({
    required this.lessonId,
    required this.status,
    this.bestScore = 0,
    this.totalQuestions = 0,
    required this.updatedAt,
  });

  bool get isCompleted => status == 'completed';

  Map<String, Object> toJson() => {
        'lessonId': lessonId,
        'status': status,
        'bestScore': bestScore,
        'totalQuestions': totalQuestions,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory LessonProgress.fromJson(Map<String, dynamic> j) => LessonProgress(
        lessonId: j['lessonId'] as String? ?? '',
        status: j['status'] as String? ?? 'not_started',
        bestScore: (j['bestScore'] as num?)?.toInt() ?? 0,
        totalQuestions: (j['totalQuestions'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      );
}

/// Penyimpanan progres Learning Path 100% lokal (LP-03 / LP-07 / LP-AC02):
/// Menghapus paket unduhan offline TIDAK menghapus progres belajar pengguna.
class LearningPathRepository {
  static const _progressKey = 'learning_path_progress_v1';
  static const _bookmarksKey = 'learning_path_bookmarks_v1';
  static const _bundlesKey = 'learning_path_bundles_v1';

  final KeyValueStore _store;
  final DateTime Function() _now;

  LearningPathRepository(this._store, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  Future<Map<String, LessonProgress>> loadProgress() async {
    final raw = await _store.readJson(_progressKey);
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries)
        if (e.value is Map) '${e.key}': LessonProgress.fromJson(Map<String, dynamic>.from(e.value as Map)),
    };
  }

  Future<LessonProgress> saveLessonProgress(
    String lessonId, {
    required String status,
    int bestScore = 0,
    int totalQuestions = 0,
  }) async {
    final all = Map<String, LessonProgress>.from(await loadProgress());
    final prev = all[lessonId];
    final nextStatus = (prev?.isCompleted == true) ? 'completed' : status;
    final nextBest = prev != null && prev.bestScore > bestScore ? prev.bestScore : bestScore;
    final p = LessonProgress(
      lessonId: lessonId,
      status: nextStatus,
      bestScore: nextBest,
      totalQuestions: totalQuestions,
      updatedAt: _now().toUtc(),
    );
    all[lessonId] = p;
    await _store.writeJson(_progressKey, {for (final e in all.entries) e.key: e.value.toJson()});
    return p;
  }

  Future<Set<String>> bookmarks() async {
    final raw = await _store.readJson(_bookmarksKey);
    if (raw is! List) return {};
    return raw.map((e) => '$e').toSet();
  }

  Future<Set<String>> toggleBookmark(String lessonId) async {
    final cur = await bookmarks();
    if (!cur.remove(lessonId)) cur.add(lessonId);
    await _store.writeJson(_bookmarksKey, cur.toList());
    return cur;
  }

  /// Paket offline terpasang (secara bawaan seluruh kurikulum inti sudah tertanam lokal).
  Future<Set<String>> installedBundles() async {
    final raw = await _store.readJson(_bundlesKey);
    if (raw is! List) {
      return {for (final t in learningPathCatalog) for (final l in t.lessons) l.offlineBundleId};
    }
    return raw.map((e) => '$e').toSet();
  }

  Future<Set<String>> setBundleInstalled(String bundleId, bool installed) async {
    final cur = await installedBundles();
    if (installed) {
      cur.add(bundleId);
    } else {
      cur.remove(bundleId);
    }
    await _store.writeJson(_bundlesKey, cur.toList());
    return cur;
  }

  /// Rekomendasi pelajaran berikutnya murni berdasarkan progres lokal (LP-01).
  Future<LearningLesson> recommendedNext() async {
    final prog = await loadProgress();
    for (final track in learningPathCatalog) {
      for (final lesson in track.lessons) {
        if (prog[lesson.id]?.isCompleted != true) return lesson;
      }
    }
    return learningPathCatalog.first.lessons.first;
  }
}
