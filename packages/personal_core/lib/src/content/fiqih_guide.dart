enum FiqihCategory {
  thaharah('Thaharah & Bersuci'),
  salatFardhu('Salat Fardhu'),
  salatSunnah('Salat Sunnah'),
  salatSafar('Salat Safar (Jama\' & Qashar)'),
  salatJenazah('Salat Jenazah');

  final String label;
  const FiqihCategory(this.label);
}

class FiqihStep {
  final int number;
  final String title;
  final String ruling;
  final String description;
  final String? arabic;
  final String? latin;
  final String? translation;

  const FiqihStep({
    required this.number,
    required this.title,
    required this.ruling,
    required this.description,
    this.arabic,
    this.latin,
    this.translation,
  });
}

class FiqihGuideTopic {
  final String id;
  final FiqihCategory category;
  final String title;
  final String summary;
  final String dalil;
  final List<FiqihStep> steps;

  const FiqihGuideTopic({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.dalil,
    required this.steps,
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        summary.toLowerCase().contains(q) ||
        category.label.toLowerCase().contains(q) ||
        dalil.toLowerCase().contains(q) ||
        steps.any((s) => s.title.toLowerCase().contains(q) || s.description.toLowerCase().contains(q));
  }
}

const List<FiqihGuideTopic> fiqihGuideCatalog = [
  FiqihGuideTopic(
    id: 'wudhu',
    category: FiqihCategory.thaharah,
    title: 'Tata Cara Wudhu Sesuai Sunnah',
    summary: 'Urutan rukun dan sunnah wudhu dari niat hingga doa setelah wudhu.',
    dalil: 'QS. Al-Ma\'idah: 6 · HR. Bukhari no. 159 & Muslim no. 226 (Hadits Utsman bin Affan RA)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Niat di dalam Hati & Membaca Basmalah',
        ruling: 'Rukun & Sunnah',
        description: 'Berniat di dalam hati untuk menghilangkan hadats kecil karena Allah, lalu mengucapkan Bismillah.',
        arabic: 'بِسْمِ اللَّهِ',
        latin: 'Bismillah.',
        translation: 'Dengan menyebut nama Allah.',
      ),
      FiqihStep(
        number: 2,
        title: 'Mencuci Kedua Telapak Tangan (3x) & Berkumur-Istinsyaq (3x)',
        ruling: 'Sunnah Muakkadah',
        description:
            'Membasuh kedua telapak tangan hingga pergelangan 3 kali, lalu berkumur (madhmadhah) dan menghirup air ke hidung (istinsyaq) dengan tangan kanan serta mengeluarkannya (istintsar) dengan tangan kiri 3 kali.',
      ),
      FiqihStep(
        number: 3,
        title: 'Membasuh Seluruh Wajah (3x)',
        ruling: 'Rukun',
        description:
            'Membasuh wajah dari batas tumbuh rambut kepala hingga dagu, dan dari tepi telinga kanan hingga telinga kiri, disertai menyela-nyela jenggot yang tebal.',
      ),
      FiqihStep(
        number: 4,
        title: 'Membasuh Kedua Tangan hingga Siku (3x)',
        ruling: 'Rukun',
        description:
            'Membasuh tangan kanan dari ujung jari hingga melewati siku 3 kali, kemudian tangan kiri dengan cara yang sama sambil menyela jari-jemari.',
      ),
      FiqihStep(
        number: 5,
        title: 'Mengusap Kepala & Kedua Telinga (1x)',
        ruling: 'Rukun & Sunnah',
        description:
            'Mengusap seluruh kepala dengan kedua tangan yang basah dari depan ke tengkuk lalu kembali ke depan, dilanjutkan mengusap bagian dalam telinga dengan jari telunjuk dan bagian luar dengan ibu jari.',
      ),
      FiqihStep(
        number: 6,
        title: 'Membasuh Kedua Kaki hingga Mata Kaki (3x) & Tertib',
        ruling: 'Rukun',
        description: 'Membasuh kaki kanan hingga melewati kedua mata kaki 3 kali sambil menyela jari kaki, lalu kaki kiri, dan ditutup dengan doa ba\'da wudhu.',
        arabic: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        latin: 'Asyhadu an la ilaha illallahu wahdahu la syarika lah, wa asyhadu anna Muhammadan \'abduhu wa rasuluh.',
        translation: 'Aku bersaksi bahwa tiada Tuhan yang berhak disembah selain Allah semata, dan Muhammad adalah hamba serta utusan-Nya.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'tayammum',
    category: FiqihCategory.thaharah,
    title: 'Tata Cara Tayammum (Saat Tidak Ada Air / Sakit)',
    summary: 'Keringanan bersuci menggunakan debu yang suci saat tidak mendapati air atau uzur medis terkena air.',
    dalil: 'QS. Al-Ma\'idah: 6 · HR. Bukhari no. 338 & Muslim no. 368 (Hadits Ammar bin Yasir RA)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Niat & Menepukkan Kedua Telapak Tangan ke Permukaan Berdebu Suci',
        ruling: 'Rukun',
        description: 'Berniat tayammum untuk diperbolehkan salat, membaca Bismillah, lalu menepukkan kedua telapak tangan satu kali pada permukaan tanah/dinding berdebu suci dan meniup debu yang terlalu tebal.',
      ),
      FiqihStep(
        number: 2,
        title: 'Mengusap Wajah dan Kedua Punggung/Telapak Tangan',
        ruling: 'Rukun',
        description: 'Mengusap seluruh wajah satu kali, kemudian mengusap punggung dan telapak tangan kanan dengan tangan kiri serta tangan kiri dengan tangan kanan hingga pergelangan tangan.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_fardhu',
    category: FiqihCategory.salatFardhu,
    title: 'Panduan Lengkap Rukun & Bacaan Salat Fardhu',
    summary: 'Urutan gerakan dan bacaan salat fardhu dari Takbiratul Ihram hingga Salam dengan tuma\'ninah.',
    dalil: 'HR. Bukhari no. 631 ("Salatlah kalian sebagaimana kalian melihat aku salat") & HR. Muslim no. 397',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Berdiri Menghadap Kiblat, Niat & Takbiratul Ihram',
        ruling: 'Rukun',
        description: 'Berdiri tegak menghadap kiblat (bagi yang mampu), berniat di dalam hati, mengangkat kedua tangan sejajar bahu atau telinga sambil mengucapkan Allahu Akbar.',
        arabic: 'اللَّهُ أَكْبَرُ',
        latin: 'Allahu Akbar.',
        translation: 'Allah Mahabesar.',
      ),
      FiqihStep(
        number: 2,
        title: 'Membaca Doa Iftitah & Surah Al-Fatihah',
        ruling: 'Sunnah & Rukun',
        description: 'Membaca doa iftitah secara sirr (pelan), ta\'awudz, basmalah, lalu membaca Surah Al-Fatihah ayat demi ayat (Rukun salat) dan ditutup dengan ucapan Amin.',
        arabic: 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
        latin: 'Allahumma ba\'id bayni wa bayna khathayaya kama ba\'adta baynal-masyriqi wal-maghrib.',
        translation: 'Ya Allah, jauhkanlah antara aku dan kesalahan-kesalahanku sebagaimana Engkau menjauhkan antara timur dan barat.',
      ),
      FiqihStep(
        number: 3,
        title: 'Ruku\' dengan Tuma\'ninah',
        ruling: 'Rukun',
        description: 'Bertakbir sambil mengangkat tangan, lalu membungkuk hingga punggung rata dengan kepala dan kedua telapak tangan memegang lutut disertai tuma\'ninah.',
        arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ (٣×)',
        latin: 'Subhana Rabbiyal-\'Azhim (3x).',
        translation: 'Mahasuci Rabbku Yang Mahaagung.',
      ),
      FiqihStep(
        number: 4,
        title: 'I\'tidal (Bangkit dari Ruku\') dengan Tuma\'ninah',
        ruling: 'Rukun',
        description: 'Bangkit tegak sambil mengucapkan Sami\'allahu liman hamidah, dan setelah berdiri tegak membaca Rabbana wa lakal-hamd.',
        arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۚ رَبَّنَا وَلَكَ الْحَمْدُ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
        latin: 'Sami\'allahu liman hamidah. Rabbana wa lakal-hamdu hamdan katsiran thayyiban mubarakan fih.',
        translation: 'Allah mendengar orang yang memuji-Nya. Wahai Rabb kami, bagi-Mu segala puji dengan pujian yang banyak, baik, dan penuh berkah.',
      ),
      FiqihStep(
        number: 5,
        title: 'Sujud di Atas Tujuh Anggota Tubuh & Duduk di Antara Dua Sujud',
        ruling: 'Rukun',
        description: 'Bersujud dengan menempelkan dahi bersama hidung, dua telapak tangan, dua lutut, dan ujung jari kedua kaki. Lalu bangkit duduk iftirasy di antara dua sujud.',
        arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى (٣×) ۝ رَبِّ اغْفِرْ لِي وَارْحَمْنِي وَاجْبُرْنِي وَارْفَعْنِي وَارْزُقْنِي وَاهْدِنِي وَعَافِنِي',
        latin: 'Subhana Rabbiyal-A\'la (3x). Rabbighfir li warhamni wajburni warfa\'ni warzuqni wahdini wa \'afini.',
        translation: 'Mahasuci Rabbku Yang Mahatinggi. Ya Rabbku, ampunilah aku, rahmatilah aku, cukupilah kekuranganku, angkatlah derajatku, berilah aku rezeki, tunjukilah aku, dan sehatkanlah aku.',
      ),
      FiqihStep(
        number: 6,
        title: 'Tasyahud Akhir, Shalawat Ibrahimiyah & Salam',
        ruling: 'Rukun',
        description: 'Duduk tawarruk pada rakaat terakhir, membaca tahiyat/tasyahud, shalawat Nabi, berlindung dari 4 fitnah, lalu menoleh ke kanan dan ke kiri sambil mengucapkan salam.',
        arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        latin: 'Assalamu\'alaykum wa rahmatullah.',
        translation: 'Semoga keselamatan dan rahmat Allah tercurah atas kalian.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_sunnah_dhuha_tahajud_istikharah',
    category: FiqihCategory.salatSunnah,
    title: 'Salat Dhuha, Tahajud (Witir) & Istikharah',
    summary: 'Waktu pelaksanaan, jumlah rakaat, dan doa khusus salat sunnah harian utama.',
    dalil: 'HR. Muslim no. 720 (Dhuha), HR. Bukhari no. 1145 (Tahajud), HR. Bukhari no. 1166 (Istikharah)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Salat Sunnah Dhuha (2 s.d. 8 Rakaat)',
        ruling: 'Sunnah Muakkadah',
        description:
            'Dikerjakan sejak matahari naik setinggi tombak (±15 menit setelah Syuruq) hingga menjelang zawal (±10 menit sebelum Dzuhur), dikerjakan 2 rakaat salam. Menggantikan sedekah bagi 360 persendian tubuh.',
      ),
      FiqihStep(
        number: 2,
        title: 'Salat Tahajud & Penutup Witir',
        ruling: 'Sunnah Muakkadah',
        description:
            'Dikerjakan setelah bangun tidur di malam hari (utama di sepertiga malam terakhir), 2 rakaat salam, lalu ditutup dengan Salat Witir ganjil (1 atau 3 rakaat).',
      ),
      FiqihStep(
        number: 3,
        title: 'Salat & Doa Istikharah (Memohon Pilihan Terbaik)',
        ruling: 'Sunnah',
        description: 'Melaksanakan 2 rakaat salat sunnah, lalu setelah salam membaca doa Istikharah dengan menyebutkan urusan yang sedang dipertimbangkan.',
        arabic:
            'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ',
        latin:
            'Allahumma inni astakhiruka bi\'ilmika, wa astaqdiruka biqudratika, wa as\'aluka min fadhlika-l\'azhim, fa innaka taqdiru wa la aqdiru, wa ta\'lamu wa la a\'lamu, wa Anta \'Allamul-ghuyub.',
        translation:
            'Ya Allah, sesungguhnya aku memohon pilihan yang terbaik kepada-Mu dengan ilmu-Mu, memohon ketetapan dengan kekuasaan-Mu, dan memohon karunia-Mu yang agung.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_id_dan_gerhana',
    category: FiqihCategory.salatSunnah,
    title: 'Salat Hari Raya (Id) & Salat Gerhana (Kusuf/Khusuf)',
    summary: 'Tata cara takbir tambahan pada Salat Id (7 & 5 takbir) serta 2 ruku per rakaat pada Salat Gerhana.',
    dalil: 'HR. Abu Dawud no. 1149 (Salat Id) & HR. Bukhari no. 1044 (Salat Gerhana)',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Salat Idul Fitri & Idul Adha (2 Rakaat Tanpa Adzan/Iqamah)',
        ruling: 'Sunnah Muakkadah / Fardhu Kifayah',
        description:
            'Rakaat pertama: setelah Takbiratul Ihram dan doa iftitah, bertakbir 7 kali sebelum Al-Fatihah. Rakaat kedua: setelah takbir bangkit berdiri, bertakbir 5 kali sebelum Al-Fatihah. Di sela tiap takbir dianjurkan memuji Allah.',
        arabic: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
        latin: 'Subhanallahi walhamdu lillahi wa la ilaha illallahu wallahu Akbar.',
        translation: 'Mahasuci Allah, segala puji bagi Allah, tiada Tuhan selain Allah, dan Allah Mahabesar.',
      ),
      FiqihStep(
        number: 2,
        title: 'Salat Gerhana Matahari (Kusuf) & Bulan (Khusuf)',
        ruling: 'Sunnah Muakkadah',
        description:
            'Dikerjakan 2 rakaat dengan setiap rakaat memiliki 2 kali berdiri (membaca Al-Fatihah & surah panjang), 2 kali ruku\', dan 2 kali sujud, kemudian diikuti khutbah pengingat kebesaran Allah.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_safar_jama_qashar',
    category: FiqihCategory.salatSafar,
    title: 'Panduan Salat Safar: Qashar & Jama\' (Taqdim / Takhir)',
    summary: 'Aturan meringkas salat 4 rakaat menjadi 2 rakaat dan menggabungkan dua waktu salat saat bepergian jauh.',
    dalil: 'QS. An-Nisa: 101 · HR. Muslim no. 686 & no. 705',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Syarat Jarak Safar & Salat yang Dapat Di-Qashar',
        ruling: 'Rukhshah (Keringanan Syariat)',
        description:
            'Perjalanan mencapai jarak masafatul qashr (±81–89 km) dan telah keluar dari batas kota domisili. Salat 4 rakaat (Dzuhur, Ashar, Isya) diringkas menjadi 2 rakaat. Adapun Subuh (2 rakaat) dan Maghrib (3 rakaat) tidak di-qashar.',
      ),
      FiqihStep(
        number: 2,
        title: 'Pasangan Salat Jama\' (Dzuhur-Ashar & Maghrib-Isya)',
        ruling: 'Rukhshah',
        description:
            'Jama\' Taqdim: mengerjakan Dzuhur & Ashar di waktu Dzuhur (atau Maghrib & Isya di waktu Maghrib). Jama\' Takhir: mengerjakan Dzuhur & Ashar di waktu Ashar (atau Maghrib & Isya di waktu Isya). Subuh selalu dikerjakan pada waktunya sendiri.',
      ),
    ],
  ),
  FiqihGuideTopic(
    id: 'salat_jenazah',
    category: FiqihCategory.salatJenazah,
    title: 'Tata Cara Salat Jenazah (4 Takbir Lengkap)',
    summary: 'Panduan berdiri tanpa ruku\' dan sujud, 4 takbir beserta bacaan Al-Fatihah, shalawat, dan doa jenazah.',
    dalil: 'HR. Bukhari no. 1335 & Muslim no. 963',
    steps: [
      FiqihStep(
        number: 1,
        title: 'Takbir Pertama: Membaca Surah Al-Fatihah',
        ruling: 'Rukun',
        description: 'Berdiri menghadap kiblat (imam berdiri sejajar kepala jenazah laki-laki atau bagian tengah jenazah perempuan), Takbiratul Ihram, lalu membaca Surah Al-Fatihah.',
      ),
      FiqihStep(
        number: 2,
        title: 'Takbir Kedua: Membaca Shalawat Ibrahimiyah',
        ruling: 'Rukun',
        description: 'Bertakbir kedua lalu membaca Shalawat kepada Nabi Muhammad SAW sebagaimana shalawat pada tasyahud akhir.',
        arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
        latin: 'Allahumma shalli \'ala Muhammad wa \'ala ali Muhammad, kama shallayta \'ala Ibrahim wa \'ala ali Ibrahim, innaka Hamidum Majid.',
        translation: 'Ya Allah, limpahkanlah rahmat kepada Muhammad dan keluarga Muhammad, sebagaimana Engkau melimpahkan rahmat kepada Ibrahim dan keluarga Ibrahim.',
      ),
      FiqihStep(
        number: 3,
        title: 'Takbir Ketiga: Doa Khusus untuk Jenazah',
        ruling: 'Rukun',
        description: 'Bertakbir ketiga lalu mendoakan ampunan dan kelapangan kubur bagi jenazah.',
        arabic:
            'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ',
        latin:
            'Allahummaghfir lahu warhamhu wa \'afihi wa\'fu \'anhu, wa akrim nuzulahu, wa wassi\' mudkhalahu, waghsilhu bil-ma\'i wats-tsalji wal-barad.',
        translation:
            'Ya Allah, ampunilah dia, rahmatilah dia, selamatkanlah dia, maafkanlah kesalahannya, muliakanlah tempat tinggalnya, dan luaskanlah kuburnya.',
      ),
      FiqihStep(
        number: 4,
        title: 'Takbir Keempat & Salam',
        ruling: 'Rukun',
        description: 'Bertakbir keempat, membaca doa penutup sejenak, kemudian mengucapkan salam ke kanan (dan boleh ditambah ke kiri).',
        arabic: 'اللَّهُمَّ لَا تَحْرِمْنَا أَجْرَهُ وَلَا تَفْتِنَّا بَعْدَهُ وَاغْفِرْ لَنَا وَلَهُ',
        latin: 'Allahumma la tahrimna ajrahu wa la taftinna ba\'dahu waghfir lana wa lah.',
        translation: 'Ya Allah, janganlah Engkau halangi kami dari pahalanya, janganlah Engkau timpakan fitnah kepada kami sepeninggalnya, dan ampunilah kami serta dirinya.',
      ),
    ],
  ),
];
