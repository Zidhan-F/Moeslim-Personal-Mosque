import 'package:shared_prayer/shared_prayer.dart';

enum FiqihCategory {
  thaharah('Thaharah & Bersuci', 'Purification (Taharah)'),
  salatFardhu('Salat Fardhu', 'Obligatory Prayers'),
  salatSunnah('Salat Sunnah', 'Voluntary Prayers'),
  salatSafar('Salat Safar (Jama\' & Qashar)', 'Travel Prayer (Jam\' & Qasr)'),
  salatJenazah('Salat Jenazah', 'Funeral Prayer (Janazah)');

  final String label;
  final String labelEn;
  const FiqihCategory(this.label, this.labelEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
}

class FiqihStep {
  final int number;
  final String title;
  final String? titleEn;
  final String ruling;
  final String? rulingEn;
  final String description;
  final String? descriptionEn;
  final String? arabic;
  final String? latin;
  final String? translation;
  final String? translationEn;

  const FiqihStep({
    required this.number,
    required this.title,
    this.titleEn,
    required this.ruling,
    this.rulingEn,
    required this.description,
    this.descriptionEn,
    this.arabic,
    this.latin,
    this.translation,
    this.translationEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String rulingFor(AppLanguage lang) =>
      lang == AppLanguage.en && (rulingEn?.isNotEmpty ?? false) ? rulingEn! : ruling;
  String descriptionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (descriptionEn?.isNotEmpty ?? false) ? descriptionEn! : description;
  String? translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn : translation;
}

class FiqihGuideTopic {
  final String id;
  final FiqihCategory category;
  final String title;
  final String? titleEn;
  final String summary;
  final String? summaryEn;
  final String dalil;
  final String? dalilEn;
  final List<FiqihStep> steps;

  const FiqihGuideTopic({
    required this.id,
    required this.category,
    required this.title,
    this.titleEn,
    required this.summary,
    this.summaryEn,
    required this.dalil,
    this.dalilEn,
    required this.steps,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String summaryFor(AppLanguage lang) =>
      lang == AppLanguage.en && (summaryEn?.isNotEmpty ?? false) ? summaryEn! : summary;
  String dalilFor(AppLanguage lang) =>
      lang == AppLanguage.en && (dalilEn?.isNotEmpty ?? false) ? dalilEn! : dalil;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        (titleEn?.toLowerCase().contains(q) ?? false) ||
        summary.toLowerCase().contains(q) ||
        (summaryEn?.toLowerCase().contains(q) ?? false) ||
        category.label.toLowerCase().contains(q) ||
        category.labelEn.toLowerCase().contains(q) ||
        dalil.toLowerCase().contains(q) ||
        (dalilEn?.toLowerCase().contains(q) ?? false) ||
        steps.any((s) =>
            s.title.toLowerCase().contains(q) ||
            (s.titleEn?.toLowerCase().contains(q) ?? false) ||
            s.description.toLowerCase().contains(q) ||
            (s.descriptionEn?.toLowerCase().contains(q) ?? false));
  }
}

const List<FiqihGuideTopic> fiqihGuideCatalog = [
  FiqihGuideTopic(
    id: 'wudhu',
    category: FiqihCategory.thaharah,
    title: 'Tata Cara Wudhu Sesuai Sunnah',
    titleEn: 'How to Perform Wudu According to the Sunnah',
    summary: 'Urutan rukun dan sunnah wudhu dari niat hingga doa setelah wudhu.',
    summaryEn: 'Step-by-step pillars and Sunnah acts of ablution from intention to the closing supplication.',
    dalil: 'QS. Al-Ma\'idah: 6 · HR. Bukhari no. 159 & Muslim no. 226 (Hadits Utsman bin Affan RA)',
    dalilEn: 'Quran 5:6 · Sahih al-Bukhari 159 & Sahih Muslim 226 (Hadith of Uthman ibn Affan RA)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Niat di dalam Hati & Membaca Basmalah',
        titleEn: 'Intention in the Heart & Saying Bismillah',
        ruling: 'Rukun & Sunnah',
        rulingEn: 'Pillar & Sunnah',
        description: 'Berniat di dalam hati untuk menghilangkan hadats kecil karena Allah, lalu mengucapkan Bismillah.',
        descriptionEn: 'Make a sincere intention in your heart to lift minor ritual impurity for Allah\'s sake, then say Bismillah.',
        arabic: 'بِسْمِ اللَّهِ',
        latin: 'Bismillah.',
        translation: 'Dengan menyebut nama Allah.',
        translationEn: 'In the name of Allah.',
      ),
      FiqihStep(
        number: 2,
        title: 'Mencuci Kedua Telapak Tangan (3x) & Berkumur-Istinsyaq (3x)',
        titleEn: 'Wash Both Hands (3x), Rinse Mouth & Nose (3x)',
        ruling: 'Sunnah Muakkadah',
        rulingEn: 'Confirmed Sunnah',
        description:
            'Membasuh kedua telapak tangan hingga pergelangan 3 kali, lalu berkumur (madhmadhah) dan menghirup air ke hidung (istinsyaq) dengan tangan kanan serta mengeluarkannya (istintsar) dengan tangan kiri 3 kali.',
        descriptionEn:
            'Wash both hands up to the wrists three times, then rinse the mouth (madmadah) and sniff water gently into the nostrils (istinshaq) with the right hand, blowing it out (istinthar) with the left hand three times.',
      ),
      FiqihStep(
        number: 3,
        title: 'Membasuh Seluruh Wajah (3x)',
        titleEn: 'Wash the Entire Face (3x)',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description:
            'Membasuh wajah dari batas tumbuh rambut kepala hingga dagu, dan dari tepi telinga kanan hingga telinga kiri, disertai menyela-nyela jenggot yang tebal.',
        descriptionEn:
            'Wash the entire face from the hairline to the bottom of the chin and from ear to ear three times, running wet fingers through a thick beard.',
      ),
      FiqihStep(
        number: 4,
        title: 'Membasuh Kedua Tangan hingga Siku (3x)',
        titleEn: 'Wash Both Arms up to the Elbows (3x)',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description:
            'Membasuh tangan kanan dari ujung jari hingga melewati siku 3 kali, kemudian tangan kiri dengan cara yang sama sambil menyela jari-jemari.',
        descriptionEn:
            'Wash the right arm from the fingertips up to and including the elbow three times, then wash the left arm the same way while interlacing the fingers.',
      ),
      FiqihStep(
        number: 5,
        title: 'Mengusap Kepala & Kedua Telinga (1x)',
        titleEn: 'Wipe the Head & Both Ears (1x)',
        ruling: 'Rukun & Sunnah',
        rulingEn: 'Pillar & Sunnah',
        description:
            'Mengusap seluruh kepala dengan kedua tangan yang basah dari depan ke tengkuk lalu kembali ke depan, dilanjutkan mengusap bagian dalam telinga dengan jari telunjuk dan bagian luar dengan ibu jari.',
        descriptionEn:
            'Wipe the whole head with wet hands from the forehead to the nape of the neck and back again, then wipe the inside of the ears with the index fingers and the backs with the thumbs.',
      ),
      FiqihStep(
        number: 6,
        title: 'Membasuh Kedua Kaki hingga Mata Kaki (3x) & Tertib',
        titleEn: 'Wash Both Feet up to the Ankles (3x) in Order',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Membasuh kaki kanan hingga melewati kedua mata kaki 3 kali sambil menyela jari kaki, lalu kaki kiri, dan ditutup dengan doa ba\'da wudhu.',
        descriptionEn: 'Wash the right foot up to and including the ankles three times while cleaning between the toes, then the left foot, and close with the post-wudu supplication.',
        arabic: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        latin: 'Asyhadu an la ilaha illallahu wahdahu la syarika lah, wa asyhadu anna Muhammadan \'abduhu wa rasuluh.',
        translation: 'Aku bersaksi bahwa tiada Tuhan yang berhak disembah selain Allah semata, dan Muhammad adalah hamba serta utusan-Nya.',
        translationEn: 'I bear witness that there is no deity worthy of worship except Allah alone, without partner, and I bear witness that Muhammad is His servant and messenger.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'tayammum',
    category: FiqihCategory.thaharah,
    title: 'Tata Cara Tayammum (Saat Tidak Ada Air / Sakit)',
    titleEn: 'How to Perform Tayammum (Dry Ablution)',
    summary: 'Keringanan bersuci menggunakan debu yang suci saat tidak mendapati air atau uzur medis terkena air.',
    summaryEn: 'The concession of purifying with clean earth when water is unavailable or medically harmful.',
    dalil: 'QS. Al-Ma\'idah: 6 · HR. Bukhari no. 338 & Muslim no. 368 (Hadits Ammar bin Yasir RA)',
    dalilEn: 'Quran 5:6 · Sahih al-Bukhari 338 & Sahih Muslim 368 (Hadith of Ammar ibn Yasir RA)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Niat & Menepukkan Kedua Telapak Tangan ke Permukaan Berdebu Suci',
        titleEn: 'Make Intention & Lightly Strike Clean Earthy Surface',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Berniat tayammum untuk diperbolehkan salat, membaca Bismillah, lalu menepukkan kedua telapak tangan satu kali pada permukaan tanah/dinding berdebu suci dan meniup debu yang terlalu tebal.',
        descriptionEn: 'Intend Tayammum to permit prayer, say Bismillah, strike both palms gently once onto clean earth or a dusty natural surface, and blow off any excess dust.',
      ),
      FiqihStep(
        number: 2,
        title: 'Mengusap Wajah dan Kedua Punggung/Telapak Tangan',
        titleEn: 'Wipe the Face and Both Hands up to the Wrists',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Mengusap seluruh wajah satu kali, kemudian mengusap punggung dan telapak tangan kanan dengan tangan kiri serta tangan kiri dengan tangan kanan hingga pergelangan tangan.',
        descriptionEn: 'Wipe the entire face once, then wipe the back and palm of the right hand with the left hand, and the left hand with the right hand up to the wrists.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_fardhu',
    category: FiqihCategory.salatFardhu,
    title: 'Panduan Lengkap Rukun & Bacaan Salat Fardhu',
    titleEn: 'Complete Guide to Obligatory Prayer Pillars & Recitations',
    summary: 'Urutan gerakan dan bacaan salat fardhu dari Takbiratul Ihram hingga Salam dengan tuma\'ninah.',
    summaryEn: 'The sequence of postures and recitations from the opening Takbir to the closing Salam with calm stillness.',
    dalil: 'HR. Bukhari no. 631 ("Salatlah kalian sebagaimana kalian melihat aku salat") & HR. Muslim no. 397',
    dalilEn: 'Sahih al-Bukhari 631 ("Pray as you have seen me praying") & Sahih Muslim 397',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Berdiri Menghadap Kiblat, Niat & Takbiratul Ihram',
        titleEn: 'Stand Facing the Qibla, Make Intention & Opening Takbir',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Berdiri tegak menghadap kiblat (bagi yang mampu), berniat di dalam hati, mengangkat kedua tangan sejajar bahu atau telinga sambil mengucapkan Allahu Akbar.',
        descriptionEn: 'Stand upright facing the Qibla (if able), hold the intention in your heart, raise both hands to shoulder or ear level, and say Allahu Akbar.',
        arabic: 'اللَّهُ أَكْبَرُ',
        latin: 'Allahu Akbar.',
        translation: 'Allah Mahabesar.',
        translationEn: 'Allah is the Greatest.',
      ),
      FiqihStep(
        number: 2,
        title: 'Membaca Doa Iftitah & Surah Al-Fatihah',
        titleEn: 'Recite the Opening Supplication & Surah Al-Fatihah',
        ruling: 'Sunnah & Rukun',
        rulingEn: 'Sunnah & Pillar',
        description: 'Membaca doa iftitah secara sirr (pelan), ta\'awudz, basmalah, lalu membaca Surah Al-Fatihah ayat demi ayat (Rukun salat) dan ditutup dengan ucapan Amin.',
        descriptionEn: 'Quietly recite the opening dua, seek refuge in Allah, say Bismillah, and recite Surah Al-Fatihah verse by verse (a pillar of prayer), ending with Amin.',
        arabic: 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
        latin: 'Allahumma ba\'id bayni wa bayna khathayaya kama ba\'adta baynal-masyriqi wal-maghrib.',
        translation: 'Ya Allah, jauhkanlah antara aku dan kesalahan-kesalahanku sebagaimana Engkau menjauhkan antara timur dan barat.',
        translationEn: 'O Allah, distance me from my sins just as You have distanced the east from the west.',
      ),
      FiqihStep(
        number: 3,
        title: 'Ruku\' dengan Tuma\'ninah',
        titleEn: 'Bowing (Ruku\') with Calm Stillness',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Bertakbir sambil mengangkat tangan, lalu membungkuk hingga punggung rata dengan kepala dan kedua telapak tangan memegang lutut disertai tuma\'ninah.',
        descriptionEn: 'Say Takbir while raising your hands, then bow with a level back and head, placing palms firmly on the knees and pausing in stillness.',
        arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ (٣×)',
        latin: 'Subhana Rabbiyal-\'Azhim (3x).',
        translation: 'Mahasuci Rabbku Yang Mahaagung.',
        translationEn: 'Glory be to my Lord, the Magnificent (3x).',
      ),
      FiqihStep(
        number: 4,
        title: 'I\'tidal (Bangkit dari Ruku\') dengan Tuma\'ninah',
        titleEn: 'Rising Upright (I\'tidal) with Calm Stillness',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Bangkit tegak sambil mengucapkan Sami\'allahu liman hamidah, dan setelah berdiri tegak membaca Rabbana wa lakal-hamd.',
        descriptionEn: 'Rise completely upright saying Sami\'allahu liman hamidah, and once standing still recite Rabbana wa lakal-hamd.',
        arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۚ رَبَّنَا وَلَكَ الْحَمْدُ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
        latin: 'Sami\'allahu liman hamidah. Rabbana wa lakal-hamdu hamdan katsiran thayyiban mubarakan fih.',
        translation: 'Allah mendengar orang yang memuji-Nya. Wahai Rabb kami, bagi-Mu segala puji dengan pujian yang banyak, baik, dan penuh berkah.',
        translationEn: 'Allah hears the one who praises Him. Our Lord, to You belongs all praise, abundant, pure, and blessed.',
      ),
      FiqihStep(
        number: 5,
        title: 'Sujud di Atas Tujuh Anggota Tubuh & Duduk di Antara Dua Sujud',
        titleEn: 'Prostration (Sujud) on Seven Limbs & Sitting Between Prostrations',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Bersujud dengan menempelkan dahi bersama hidung, dua telapak tangan, dua lutut, dan ujung jari kedua kaki. Lalu bangkit duduk iftirasy di antara dua sujud.',
        descriptionEn: 'Prostrate firmly on the forehead and nose, both palms, both knees, and the toes of both feet. Then rise and sit calmly between the two prostrations.',
        arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى (٣×) ۝ رَبِّ اغْفِرْ لِي وَارْحَمْنِي وَاجْبُرْنِي وَارْفَعْنِي وَارْزُقْنِي وَاهْدِنِي وَعَافِنِي',
        latin: 'Subhana Rabbiyal-A\'la (3x). Rabbighfir li warhamni wajburni warfa\'ni warzuqni wahdini wa \'afini.',
        translation: 'Mahasuci Rabbku Yang Mahatinggi. Ya Rabbku, ampunilah aku, rahmatilah aku, cukupilah kekuranganku, angkatlah derajatku, berilah aku rezeki, tunjukilah aku, dan sehatkanlah aku.',
        translationEn: 'Glory be to my Lord, the Most High (3x). My Lord, forgive me, have mercy on me, mend my shortcomings, raise my rank, grant me provision, guide me, and grant me well-being.',
      ),
      FiqihStep(
        number: 6,
        title: 'Tasyahud Akhir, Shalawat Ibrahimiyah & Salam',
        titleEn: 'Final Tashahhud, Salawat Ibrahimiyyah & Closing Salam',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Duduk tawarruk pada rakaat terakhir, membaca tahiyat/tasyahud, shalawat Nabi, berlindung dari 4 fitnah, lalu menoleh ke kanan dan ke kiri sambil mengucapkan salam.',
        descriptionEn: 'Sit in tawarruk during the final rak\'ah, recite the Tashahhud and Salawat upon the Prophet, seek refuge from the four trials, then turn to the right and left saying the Salam.',
        arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        latin: 'Assalamu\'alaykum wa rahmatullah.',
        translation: 'Semoga keselamatan dan rahmat Allah tercurah atas kalian.',
        translationEn: 'May peace and the mercy of Allah be upon you.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_sunnah_dhuha_tahajud_istikharah',
    category: FiqihCategory.salatSunnah,
    title: 'Salat Dhuha, Tahajud (Witir) & Istikharah',
    titleEn: 'Duha, Tahajjud (Witr) & Istikharah Prayers',
    summary: 'Waktu pelaksanaan, jumlah rakaat, dan doa khusus salat sunnah harian utama.',
    summaryEn: 'Timing windows, rak\'ah counts, and key supplications for the core daily voluntary prayers.',
    dalil: 'HR. Muslim no. 720 (Dhuha), HR. Bukhari no. 1145 (Tahajud), HR. Bukhari no. 1166 (Istikharah)',
    dalilEn: 'Sahih Muslim 720 (Duha), Sahih al-Bukhari 1145 (Tahajjud), Sahih al-Bukhari 1166 (Istikharah)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Salat Sunnah Dhuha (2 s.d. 8 Rakaat)',
        titleEn: 'Duha Prayer (2 to 8 Rak\'ah)',
        ruling: 'Sunnah Muakkadah',
        rulingEn: 'Confirmed Sunnah',
        description:
            'Dikerjakan sejak matahari naik setinggi tombak (±15 menit setelah Syuruq) hingga menjelang zawal (±10 menit sebelum Dzuhur), dikerjakan 2 rakaat salam. Menggantikan sedekah bagi 360 persendian tubuh.',
        descriptionEn:
            'Performed from about 15 minutes after sunrise until about 10 minutes before Dhuhr, prayed in sets of two rak\'ah. It fulfills charity on behalf of all 360 joints of the body.',
      ),
      FiqihStep(
        number: 2,
        title: 'Salat Tahajud & Penutup Witir',
        titleEn: 'Tahajjud Night Prayer & Closing Witr',
        ruling: 'Sunnah Muakkadah',
        rulingEn: 'Confirmed Sunnah',
        description:
            'Dikerjakan setelah bangun tidur di malam hari (utama di sepertiga malam terakhir), 2 rakaat salam, lalu ditutup dengan Salat Witir ganjil (1 atau 3 rakaat).',
        descriptionEn:
            'Performed after waking at night (best in the last third of the night) in pairs of two rak\'ah, concluded with an odd-numbered Witr prayer (1 or 3 rak\'ah).',
      ),
      FiqihStep(
        number: 3,
        title: 'Salat & Doa Istikharah (Memohon Pilihan Terbaik)',
        titleEn: 'Istikharah Prayer & Supplication (Seeking Guidance)',
        ruling: 'Sunnah',
        rulingEn: 'Sunnah',
        description: 'Melaksanakan 2 rakaat salat sunnah, lalu setelah salam membaca doa Istikharah dengan menyebutkan urusan yang sedang dipertimbangkan.',
        descriptionEn: 'Pray two voluntary rak\'ah, then after the salam recite the Istikharah supplication while naming the decision you are weighing.',
        arabic:
            'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ',
        latin:
            'Allahumma inni astakhiruka bi\'ilmika, wa astaqdiruka biqudratika, wa as\'aluka min fadhlika-l\'azhim, fa innaka taqdiru wa la aqdiru, wa ta\'lamu wa la a\'lamu, wa Anta \'Allamul-ghuyub.',
        translation:
            'Ya Allah, sesungguhnya aku memohon pilihan yang terbaik kepada-Mu dengan ilmu-Mu, memohon ketetapan dengan kekuasaan-Mu, dan memohon karunia-Mu yang agung.',
        translationEn:
            'O Allah, I seek Your guidance through Your knowledge and Your ability through Your power, and I ask You of Your great bounty; for You have power and I do not, You know and I do not, and You are the Knower of the unseen.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_id_dan_gerhana',
    category: FiqihCategory.salatSunnah,
    title: 'Salat Hari Raya (Id) & Salat Gerhana (Kusuf/Khusuf)',
    titleEn: 'Eid Prayer & Eclipse Prayer (Kusuf / Khusuf)',
    summary: 'Tata cara takbir tambahan pada Salat Id (7 & 5 takbir) serta 2 ruku per rakaat pada Salat Gerhana.',
    summaryEn: 'How to perform the extra Takbirs in Eid prayer (7 and 5) and the double-bowing format of Eclipse prayer.',
    dalil: 'HR. Abu Dawud no. 1149 (Salat Id) & HR. Bukhari no. 1044 (Salat Gerhana)',
    dalilEn: 'Sunan Abi Dawud 1149 (Eid Prayer) & Sahih al-Bukhari 1044 (Eclipse Prayer)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Salat Idul Fitri & Idul Adha (2 Rakaat Tanpa Adzan/Iqamah)',
        titleEn: 'Eid al-Fitr & Eid al-Adha Prayer (2 Rak\'ah, No Adhan/Iqamah)',
        ruling: 'Sunnah Muakkadah / Fardhu Kifayah',
        rulingEn: 'Confirmed Sunnah / Communal Obligation',
        description:
            'Rakaat pertama: setelah Takbiratul Ihram dan doa iftitah, bertakbir 7 kali sebelum Al-Fatihah. Rakaat kedua: setelah takbir bangkit berdiri, bertakbir 5 kali sebelum Al-Fatihah. Di sela tiap takbir dianjurkan memuji Allah.',
        descriptionEn:
            'First rak\'ah: after the opening Takbir and opening dua, say 7 extra Takbirs before Al-Fatihah. Second rak\'ah: after rising, say 5 extra Takbirs before Al-Fatihah, praising Allah softly between each Takbir.',
        arabic: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
        latin: 'Subhanallahi walhamdu lillahi wa la ilaha illallahu wallahu Akbar.',
        translation: 'Mahasuci Allah, segala puji bagi Allah, tiada Tuhan selain Allah, dan Allah Mahabesar.',
        translationEn: 'Glory be to Allah, all praise is due to Allah, there is no deity except Allah, and Allah is the Greatest.',
      ),
      FiqihStep(
        number: 2,
        title: 'Salat Gerhana Matahari (Kusuf) & Bulan (Khusuf)',
        titleEn: 'Solar (Kusuf) & Lunar (Khusuf) Eclipse Prayer',
        ruling: 'Sunnah Muakkadah',
        rulingEn: 'Confirmed Sunnah',
        description:
            'Dikerjakan 2 rakaat dengan setiap rakaat memiliki 2 kali berdiri (membaca Al-Fatihah & surah panjang), 2 kali ruku\', dan 2 kali sujud, kemudian diikuti khutbah pengingat kebesaran Allah.',
        descriptionEn:
            'Performed as 2 rak\'ah where each rak\'ah contains 2 standings (reciting Al-Fatihah and a lengthy surah), 2 bowings, and 2 prostrations, followed by a sermon recalling Allah\'s majesty.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_safar_jama_qashar',
    category: FiqihCategory.salatSafar,
    title: 'Panduan Salat Safar: Qashar & Jama\' (Taqdim / Takhir)',
    titleEn: 'Travel Prayer Guide: Shortening (Qasr) & Combining (Jam\')',
    summary: 'Aturan meringkas salat 4 rakaat menjadi 2 rakaat dan menggabungkan dua waktu salat saat bepergian jauh.',
    summaryEn: 'Rules for shortening 4-rak\'ah prayers to 2 and combining paired prayers during long-distance travel.',
    dalil: 'QS. An-Nisa: 101 · HR. Muslim no. 686 & no. 705',
    dalilEn: 'Quran 4:101 · Sahih Muslim 686 & 705',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Syarat Jarak Safar & Salat yang Dapat Di-Qashar',
        titleEn: 'Distance Requirement & Eligible Prayers for Qasr',
        ruling: 'Rukhshah (Keringanan Syariat)',
        rulingEn: 'Legal Concession (Rukhsah)',
        description:
            'Perjalanan mencapai jarak masafatul qashr (±81–89 km) dan telah keluar dari batas kota domisili. Salat 4 rakaat (Dzuhur, Ashar, Isya) diringkas menjadi 2 rakaat. Adapun Subuh (2 rakaat) dan Maghrib (3 rakaat) tidak di-qashar.',
        descriptionEn:
            'Travel must reach Masafat al-Qasr (about 81 to 89 km) after leaving your home city limits. Four-rak\'ah prayers (Dhuhr, Asr, Isha) shorten to 2 rak\'ah, while Fajr (2) and Maghrib (3) remain unchanged.',
      ),
      FiqihStep(
        number: 2,
        title: 'Pasangan Salat Jama\' (Dzuhur-Ashar & Maghrib-Isya)',
        titleEn: 'Combined Prayer Pairs (Dhuhr-Asr & Maghrib-Isha)',
        ruling: 'Rukhshah',
        rulingEn: 'Concession (Rukhsah)',
        description:
            'Jama\' Taqdim: mengerjakan Dzuhur & Ashar di waktu Dzuhur (atau Maghrib & Isya di waktu Maghrib). Jama\' Takhir: mengerjakan Dzuhur & Ashar di waktu Ashar (atau Maghrib & Isya di waktu Isya). Subuh selalu dikerjakan pada waktunya sendiri.',
        descriptionEn:
            'Jam\' Taqdim: pray Dhuhr and Asr during Dhuhr (or Maghrib and Isha during Maghrib). Jam\' Ta\'khir: pray Dhuhr and Asr during Asr (or Maghrib and Isha during Isha). Fajr is always prayed on its own time.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_jenazah',
    category: FiqihCategory.salatJenazah,
    title: 'Tata Cara Salat Jenazah (4 Takbir Lengkap)',
    titleEn: 'How to Perform the Funeral Prayer (Janazah, 4 Takbirs)',
    summary: 'Panduan berdiri tanpa ruku\' dan sujud, 4 takbir beserta bacaan Al-Fatihah, shalawat, dan doa jenazah.',
    summaryEn: 'Performed entirely standing without bowing or prostration, across 4 Takbirs with Al-Fatihah, Salawat, and supplication for the deceased.',
    dalil: 'HR. Bukhari no. 1335 & Muslim no. 963',
    dalilEn: 'Sahih al-Bukhari 1335 & Sahih Muslim 963',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Takbir Pertama: Membaca Surah Al-Fatihah',
        titleEn: 'First Takbir: Recite Surah Al-Fatihah',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Berdiri menghadap kiblat (imam berdiri sejajar kepala jenazah laki-laki atau bagian tengah jenazah perempuan), Takbiratul Ihram, lalu membaca Surah Al-Fatihah.',
        descriptionEn: 'Stand facing the Qibla (the imam stands aligned with the head of a male deceased or the middle of a female deceased), say the opening Takbir, and recite Surah Al-Fatihah.',
      ),
      FiqihStep(
        number: 2,
        title: 'Takbir Kedua: Membaca Shalawat Ibrahimiyah',
        titleEn: 'Second Takbir: Recite Salawat Ibrahimiyyah',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Bertakbir kedua lalu membaca Shalawat kepada Nabi Muhammad SAW sebagaimana shalawat pada tasyahud akhir.',
        descriptionEn: 'Say the second Takbir and send blessings upon Prophet Muhammad (peace be upon him) just as in the final Tashahhud.',
        arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
        latin: 'Allahumma shalli \'ala Muhammad wa \'ala ali Muhammad, kama shallayta \'ala Ibrahim wa \'ala ali Ibrahim, innaka Hamidum Majid.',
        translation: 'Ya Allah, limpahkanlah rahmat kepada Muhammad dan keluarga Muhammad, sebagaimana Engkau melimpahkan rahmat kepada Ibrahim dan keluarga Ibrahim.',
        translationEn: 'O Allah, send blessings upon Muhammad and the family of Muhammad, as You sent blessings upon Abraham and the family of Abraham. Indeed, You are Praiseworthy and Glorious.',
      ),
      FiqihStep(
        number: 3,
        title: 'Takbir Ketiga: Doa Khusus untuk Jenazah',
        titleEn: 'Third Takbir: Supplicate Specifically for the Deceased',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Bertakbir ketiga lalu mendoakan ampunan dan kelapangan kubur bagi jenazah.',
        descriptionEn: 'Say the third Takbir and pray sincerely for the deceased\'s forgiveness, mercy, and spaciousness in the grave.',
        arabic:
            'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ',
        latin:
            'Allahummaghfir lahu warhamhu wa \'afihi wa\'fu \'anhu, wa akrim nuzulahu, wa wassi\' mudkhalahu, waghsilhu bil-ma\'i wats-tsalji wal-barad.',
        translation:
            'Ya Allah, ampunilah dia, rahmatilah dia, selamatkanlah dia, maafkanlah kesalahannya, muliakanlah tempat tinggalnya, dan luaskanlah kuburnya.',
        translationEn:
            'O Allah, forgive him, have mercy on him, grant him peace, pardon him, honor his resting place, widen his grave, and wash him with water, snow, and hail.',
      ),
      FiqihStep(
        number: 4,
        title: 'Takbir Keempat & Salam',
        titleEn: 'Fourth Takbir & Closing Salam',
        ruling: 'Rukun',
        rulingEn: 'Pillar',
        description: 'Bertakbir keempat, membaca doa penutup sejenak, kemudian mengucapkan salam ke kanan (dan boleh ditambah ke kiri).',
        descriptionEn: 'Say the fourth Takbir, recite a brief closing supplication, and conclude with Salam to the right (and optionally to the left).',
        arabic: 'اللَّهُمَّ لَا تَحْرِمْنَا أَجْرَهُ وَلَا تَفْتِنَّا بَعْدَهُ وَاغْفِرْ لَنَا وَلَهُ',
        latin: 'Allahumma la tahrimna ajrahu wa la taftinna ba\'dahu waghfir lana wa lah.',
        translation: 'Ya Allah, janganlah Engkau halangi kami dari pahalanya, janganlah Engkau timpakan fitnah kepada kami sepeninggalnya, dan ampunilah kami serta dirinya.',
        translationEn: 'O Allah, do not deprive us of his reward, do not put us to trial after him, and forgive us and him.',
      ),
    ],
  ),
];
