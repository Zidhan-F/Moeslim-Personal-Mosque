import '../storage/key_value_store.dart';

class HadithItem {
  final int id;
  final String collection;
  final int number;
  final String title;
  final String topic;
  final String arabic;
  final String latin;
  final String translation;
  final String narrator;
  final String fiqhPoints;

  const HadithItem({
    required this.id,
    required this.collection,
    required this.number,
    required this.title,
    required this.topic,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.narrator,
    required this.fiqhPoints,
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        topic.toLowerCase().contains(q) ||
        collection.toLowerCase().contains(q) ||
        translation.toLowerCase().contains(q) ||
        latin.toLowerCase().contains(q) ||
        narrator.toLowerCase().contains(q) ||
        fiqhPoints.toLowerCase().contains(q) ||
        '$number' == q;
  }
}

const List<HadithItem> hadithCatalog = [
  HadithItem(
    id: 1,
    collection: 'Arba\'in Nawawi',
    number: 1,
    title: 'Segala Amal Tergantung pada Niat',
    topic: 'Niat & Ikhlas',
    arabic:
        'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
    latin:
        'Innamal a\'malu bin-niyyat, wa innama likulli imri\'in ma nawa, faman kanat hijratuhu ilallahi wa rasulihi fahijratuhu ilallahi wa rasulih...',
    translation:
        'Sesungguhnya setiap amalan tergantung pada niatnya. Dan sesungguhnya setiap orang akan mendapatkan apa yang ia niatkan. Barang siapa berhijrah karena Allah dan Rasul-Nya, maka hijrahnya kepada Allah dan Rasul-Nya.',
    narrator: 'HR. Bukhari no. 1 & Muslim no. 1907 · Dari Umar bin Khattab RA (Muttafaqun \'Alaih)',
    fiqhPoints: 'Niat adalah syarat sah sekaligus penentu pahala amal ibadah; membedakan ibadah dari kebiasaan biasa.',
  ),
  HadithItem(
    id: 2,
    collection: 'Arba\'in Nawawi',
    number: 2,
    title: 'Tingkatan Agama: Islam, Iman, dan Ihsan',
    topic: 'Iman & Aqidah',
    arabic:
        'الإِسْلامُ أَنْ تَشْهَدَ أَنْ لا إِلَهَ إِلا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَتُقِيمَ الصَّلاةَ، وَتُؤْتِيَ الزَّكَاةَ، وَتَصُومَ رَمَضَانَ، وَتَحُجَّ الْبَيْتَ إِنِ اسْتَطَعْتَ إِلَيْهِ سَبِيلا',
    latin:
        'Al-Islamu an tasyhada an la ilaha illallah wa anna Muhammadar Rasulullah, wa tuqimash-shalah, wa tu\'tiyaz-zakah, wa tashuma Ramadhan, wa tahujjal-bayta inistatha\'ta ilayhi sabila.',
    translation:
        'Islam adalah engkau bersaksi bahwa tiada ilah yang berhak disembah selain Allah dan Muhammad adalah utusan Allah, mendirikan salat, menunaikan zakat, berpuasa Ramadan, dan berhaji ke Baitullah jika mampu. Ihsan adalah engkau beribadah kepada Allah seakan-akan melihat-Nya.',
    narrator: 'HR. Muslim no. 8 · Dari Umar bin Khattab RA (Hadits Jibril)',
    fiqhPoints: 'Merangkum 5 rukun Islam, 6 rukun Iman, dan puncak kualitas ibadah (Ihsan / muraqabah).',
  ),
  HadithItem(
    id: 3,
    collection: 'Arba\'in Nawawi',
    number: 3,
    title: 'Lima Fondasi Bangunan Islam',
    topic: 'Iman & Aqidah',
    arabic:
        'بُنِيَ الإِسْلامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لا إِلَهَ إِلا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلاةِ، وَإِيتَاءِ الزَّكَاةِ، وَحَجِّ الْبَيْتِ، وَصَوْمِ رَمَضَانَ',
    latin:
        'Buniyal-Islamu \'ala khamsin: syahadati an la ilaha illallah wa anna Muhammadar Rasulullah, wa iqamish-shalah, wa ita\'iz-zakah, wa hajjil-bayti, wa shawmi Ramadhan.',
    translation:
        'Islam dibangun di atas lima perkara: persaksian bahwa tiada Tuhan yang berhak disembah selain Allah dan Muhammad adalah utusan Allah, mendirikan salat, menunaikan zakat, haji ke Baitullah, dan puasa Ramadan.',
    narrator: 'HR. Bukhari no. 8 & Muslim no. 16 · Dari Ibnu Umar RA',
    fiqhPoints: 'Syahadat dan salat merupakan tiang utama yang tidak boleh ditinggalkan oleh seorang muslim.',
  ),
  HadithItem(
    id: 4,
    collection: 'Arba\'in Nawawi',
    number: 5,
    title: 'Menolak Perkara Baru yang Mengada-ada dalam Agama',
    topic: 'Ibadah & Ilmu',
    arabic: 'مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ',
    latin: 'Man ahdatsa fi amrina hadza ma laysa minhu fahuwa raddun.',
    translation: 'Barang siapa membuat suatu perkara baru dalam urusan (agama) kami ini yang tidak ada asalnya, maka perkara tersebut tertolak.',
    narrator: 'HR. Bukhari no. 2697 & Muslim no. 1718 · Dari Aisyah RA',
    fiqhPoints: 'Syarat diterimanya ibadah ada dua: ikhlas karena Allah dan mengikuti tuntunan (ittiba\') Rasulullah SAW.',
  ),
  HadithItem(
    id: 5,
    collection: 'Arba\'in Nawawi',
    number: 6,
    title: 'Halal dan Haram Telah Jelas, Menjauhi Syubhat',
    topic: 'Muamalah & Ukhuwah',
    arabic:
        'إِنَّ الْحَلالَ بَيِّنٌ وَإِنَّ الْحَرَامَ بَيِّنٌ وَبَيْنَهُمَا مُشْتَبِهَاتٌ لا يَعْلَمُهُنَّ كَثِيرٌ مِنَ النَّاسِ، فَمَنِ اتَّقَى الشُّبُهَاتِ اسْتَبْرَأَ لِدِينِهِ وَعِرْضِهِ',
    latin:
        'Innal-halala bayyinun wa innal-harama bayyinun wa baynahuma musytabihatun la ya\'lamuhunna katsirum minan-nas, famanittaqasy-syubuhat istabra\'a lidinihi wa \'irdhih.',
    translation:
        'Sesungguhnya yang halal itu jelas dan yang haram itu jelas. Di antara keduanya terdapat perkara-perkara syubhat (samar) yang tidak diketahui oleh banyak orang. Barang siapa menjaga diri dari syubhat, maka ia telah menyelamatkan agama dan kehormatannya.',
    narrator: 'HR. Bukhari no. 52 & Muslim no. 1599 · Dari Nu\'man bin Basyir RA',
    fiqhPoints: 'Menjaga kehalalan makanan, penghasilan, dan memperbaiki hati karena hati adalah raja bagi seluruh anggota tubuh.',
  ),
  HadithItem(
    id: 6,
    collection: 'Arba\'in Nawawi',
    number: 7,
    title: 'Agama adalah Nasihat (Ketulusan)',
    topic: 'Akhlak & Adab',
    arabic: 'الدِّينُ النَّصِيحَةُ. قُلْنَا: لِمَنْ؟ قَالَ: لِلَّهِ وَلِكِتَابِهِ وَلِرَسُولِهِ وَلِأَئِمَّةِ الْمُسْلِمِينَ وَعَامَّتِهِمْ',
    latin: 'Ad-dinun-nashihah. Qulna: liman? Qala: Lillahi wa likitabihi wa lirasulihi wa li-a\'immatil-muslimina wa \'ammatihim.',
    translation:
        'Agama adalah nasihat (ketulusan). Kami bertanya: Untuk siapa? Beliau menjawab: Untuk Allah, Kitab-Nya, Rasul-Nya, para pemimpin kaum muslimin, dan kaum muslimin pada umumnya.',
    narrator: 'HR. Muslim no. 55 · Dari Tamim Ad-Dari RA',
    fiqhPoints: 'Ketulusan beragama diwujudkan dengan memurnikan ketaatan kepada Allah dan saling menasihati dalam kebaikan.',
  ),
  HadithItem(
    id: 7,
    collection: 'Arba\'in Nawawi',
    number: 12,
    title: 'Meninggalkan Hal yang Tidak Bermanfaat',
    topic: 'Akhlak & Adab',
    arabic: 'مِنْ حُسْنِ إِسْلامِ الْمَرْءِ تَرْكُهُ مَا لا يَعْنِيهِ',
    latin: 'Min husni islamil-mar\'i tarkuhu ma la ya\'nih.',
    translation: 'Di antara tanda kebaikan Islam seseorang adalah meninggalkan hal-hal yang tidak bermanfaat baginya.',
    narrator: 'HR. Tirmidzi no. 2317 & Ibnu Majah no. 3976 · Dari Abu Hurairah RA (Hasan)',
    fiqhPoints: 'Menjaga waktu, lisan, dan perhatian agar terfokus pada amal yang membawa manfaat dunia maupun akhirat.',
  ),
  HadithItem(
    id: 8,
    collection: 'Arba\'in Nawawi',
    number: 13,
    title: 'Mencintai Saudara Sebagaimana Mencintai Diri Sendiri',
    topic: 'Muamalah & Ukhuwah',
    arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    latin: 'La yu\'minu ahadukum hatta yuhibba li-akhihi ma yuhibbu linafsih.',
    translation: 'Tidak sempurna iman salah seorang di antara kalian hingga ia mencintai untuk saudaranya kebaikan yang ia cintai untuk dirinya sendiri.',
    narrator: 'HR. Bukhari no. 13 & Muslim no. 45 · Dari Anas bin Malik RA',
    fiqhPoints: 'Ukhuwah Islamiyah menuntut bersihnya hati dari hasad (dengki) dan senang melihat saudara mendapat kebaikan.',
  ),
  HadithItem(
    id: 9,
    collection: 'Arba\'in Nawawi',
    number: 15,
    title: 'Berkata Baik atau Diam, Memuliakan Tetangga & Tamu',
    topic: 'Akhlak & Adab',
    arabic:
        'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ جَارَهُ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ ضَيْفَهُ',
    latin:
        'Man kana yu\'minu billahi wal-yawmil-akhiri falyaqul khayran aw liyashmut, wa man kana yu\'minu billahi wal-yawmil-akhiri falyukrim jarahu, wa man kana yu\'minu billahi wal-yawmil-akhiri falyukrim dhayfah.',
    translation:
        'Barang siapa beriman kepada Allah dan hari akhir, hendaklah ia berkata yang baik atau diam. Barang siapa beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tetangganya. Dan barang siapa beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tamunya.',
    narrator: 'HR. Bukhari no. 6018 & Muslim no. 47 · Dari Abu Hurairah RA',
    fiqhPoints: 'Adab lisan dan adab bertetangga adalah bukti nyata keimanan seseorang.',
  ),
  HadithItem(
    id: 10,
    collection: 'Arba\'in Nawawi',
    number: 16,
    title: 'Wasiat Ringkas Rasulullah: Jangan Marah',
    topic: 'Akhlak & Adab',
    arabic: 'أَوْصِنِي، قَالَ: لا تَغْضَبْ. فَرَدَّدَ مِرَارًا، قَالَ: لا تَغْضَبْ',
    latin: 'Awshini, qala: La taghdhab. Faraddada miraran, qala: La taghdhab.',
    translation: 'Seorang sahabat berkata kepada Nabi SAW: Berilah aku wasiat. Beliau menjawab: Janganlah engkau marah. Orang itu mengulangi permintaannya, dan beliau tetap menjawab: Janganlah engkau marah.',
    narrator: 'HR. Bukhari no. 6116 · Dari Abu Hurairah RA',
    fiqhPoints: 'Menahan amarah mencegah kerusakan hubungan, penyesalan, dan kezaliman.',
  ),
  HadithItem(
    id: 11,
    collection: 'Arba\'in Nawawi',
    number: 18,
    title: 'Bertakwa di Mana Saja dan Mengiringi Kesalahan dengan Kebaikan',
    topic: 'Dzikir & Taubat',
    arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
    latin: 'Ittaqillaha haytsuma kunta, wa atbi\'is-sayyi\'atal-hasanata tamhuha, wa khaliqin-nasa bikhuluqin hasan.',
    translation:
        'Bertakwalah kepada Allah di mana pun engkau berada. Iringilah perbuatan buruk dengan perbuatan baik, niscaya kebaikan itu akan menghapusnya. Dan pergaulilah manusia dengan akhlak yang mulia.',
    narrator: 'HR. Tirmidzi no. 1987 · Dari Abu Dzar & Mu\'adz bin Jabal RA (Hasan Shahih)',
    fiqhPoints: 'Menyatukan hak Allah (takwa & taubat) dengan hak sesama manusia (akhlak mulia).',
  ),
  HadithItem(
    id: 12,
    collection: 'Arba\'in Nawawi',
    number: 19,
    title: 'Jagalah Allah, Niscaya Allah Menjagamu',
    topic: 'Iman & Aqidah',
    arabic:
        'يَا غُلامُ إِنِّي أُعَلِّمُكَ كَلِمَاتٍ: احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجَاهَكَ، إِذَا سَأَلْتَ فَاسْأَلِ اللَّهَ، وَإِذَا اسْتَعَنْتَ فَاسْتَعِنْ بِاللَّهِ',
    latin:
        'Ya ghulamu inni u\'allimuka kalimat: Ihfazhillaha yahfazhka, ihfazhillaha tajidhu tujahaka, idza sa\'alta fas\'alillah, wa idzasta\'anta fasta\'in billah.',
    translation:
        'Wahai anak muda, sesungguhnya aku akan mengajarkan kepadamu beberapa kalimat: Jagalah (batasan) Allah, niscaya Allah akan menjagamu. Jagalah Allah, niscaya engkau mendapati-Nya selalu menolongmu. Jika engkau meminta, mintalah kepada Allah; dan jika engkau memohon pertolongan, mohonlah kepada Allah.',
    narrator: 'HR. Tirmidzi no. 2516 · Dari Ibnu Abbas RA (Hasan Shahih)',
    fiqhPoints: 'Menanamkan tawakal, keyakinan akan takdir, dan ketergantungan penuh hanya kepada Allah.',
  ),
  HadithItem(
    id: 13,
    collection: 'Arba\'in Nawawi',
    number: 21,
    title: 'Katakanlah Aku Beriman kepada Allah, Lalu Istiqamahlah',
    topic: 'Iman & Aqidah',
    arabic: 'قُلْ آمَنْتُ بِاللَّهِ ثُمَّ اسْتَقِمْ',
    latin: 'Qul amantu billahi tsummastaqim.',
    translation: 'Katakanlah: Aku beriman kepada Allah, kemudian istiqamahlah (teguh di atas ketaatan).',
    narrator: 'HR. Muslim no. 38 · Dari Sufyan bin Abdullah Ats-Tsaqafi RA',
    fiqhPoints: 'Inti keberhasilan seorang mukmin adalah keteguhan (istiqamah) menjaga iman dan amal hingga akhir hayat.',
  ),
  HadithItem(
    id: 14,
    collection: 'Arba\'in Nawawi',
    number: 23,
    title: 'Bersuci Sebagian dari Iman & Al-Qur\'an Hujjah Bagimu',
    topic: 'Ibadah & Ilmu',
    arabic:
        'الطُّهُورُ شَطْرُ الإِيمَانِ، وَالْحَمْدُ لِلَّهِ تَمْلأُ الْمِيزَانَ، وَسُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ تَمْلآَنِ مَا بَيْنَ السَّمَاوَاتِ وَالأَرْضِ، وَالصَّلاةُ نُورٌ، وَالصَّدَقَةُ بُرْهَانٌ، وَالصَّبْرُ ضِيَاءٌ، وَالْقُرْآنُ حُجَّةٌ لَكَ أَوْ عَلَيْكَ',
    latin:
        'Ath-thuhuru syathrul-iman, walhamdu lillahi tamla\'ul-mizan, wa subhanallahi walhamdu lillahi tamla\'ani ma baynas-samawati wal-ardh, wash-shalatu nurun, wash-shadaqatu burhanun, wash-shabru dhiya\'un, wal-Qur\'anu hujjatun laka aw \'alayk.',
    translation:
        'Bersuci adalah separuh dari iman. Ucapan Alhamdulillah memenuhi timbangan. Subhanallah dan Alhamdulillah memenuhi ruang antara langit dan bumi. Salat adalah cahaya, sedekah adalah bukti keimanan, sabar adalah sinar, dan Al-Qur\'an adalah pembela bagimu atau penuntut atasmu.',
    narrator: 'HR. Muslim no. 223 · Dari Abu Malik Al-Asy\'ari RA',
    fiqhPoints: 'Keutamaan wudhu, dzikir, salat, sedekah, sabar, dan mengamalkan Al-Qur\'an.',
  ),
  HadithItem(
    id: 15,
    collection: 'Arba\'in Nawawi',
    number: 32,
    title: 'Tidak Boleh Membahayakan Diri Sendiri maupun Orang Lain',
    topic: 'Muamalah & Ukhuwah',
    arabic: 'لا ضَرَرَ وَلا ضِرَارَ',
    latin: 'La dharara wa la dhirar.',
    translation: 'Tidak boleh melakukan perbuatan yang membahayakan diri sendiri dan tidak boleh pula membahayakan orang lain.',
    narrator: 'HR. Ibnu Majah no. 2340 & Ahmad V/326 · Dari Abu Sa\'id Al-Khudri RA (Hasan)',
    fiqhPoints: 'Kaidah besar fiqih Islam (Adh-Dhararu Yuzal): segala bentuk mudarat dan kezaliman wajib dihilangkan.',
  ),
  HadithItem(
    id: 16,
    collection: 'Riyadus Shalihin',
    number: 1388,
    title: 'Keutamaan Menempuh Jalan Menuntut Ilmu',
    topic: 'Ibadah & Ilmu',
    arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
    latin: 'Man salaka thariqan yaltamisu fihi \'ilman sahhalallahu lahu bihi thariqan ilal-jannah.',
    translation: 'Barang siapa menempuh suatu jalan untuk mencari ilmu, maka Allah akan memudahkan baginya jalan menuju surga.',
    narrator: 'HR. Muslim no. 2699 · Dari Abu Hurairah RA',
    fiqhPoints: 'Setiap langkah, bacaan, dan waktu yang dicurahkan untuk mempelajari ilmu agama bernilai ibadah menuju surga.',
  ),
  HadithItem(
    id: 17,
    collection: 'Riyadus Shalihin',
    number: 999,
    title: 'Bacalah Al-Qur\'an karena Ia Akan Datang Memberi Syafaat',
    topic: 'Ibadah & Ilmu',
    arabic: 'اقْرَءُوا الْقُرْآنَ فَإِنَّهُ يَأْتِي يَوْمَ الْقِيَامَةِ شَفِيعًا لِأَصْحَابِهِ',
    latin: 'Iqra\'ul-Qur\'ana fa innahu ya\'ti yawmal-qiyamati syafi\'an li-ashhabih.',
    translation: 'Bacalah Al-Qur\'an, karena sesungguhnya ia akan datang pada hari Kiamat sebagai pemberi syafaat bagi para pembacanya.',
    narrator: 'HR. Muslim no. 804 · Dari Abu Umamah Al-Bahili RA',
    fiqhPoints: 'Rutin membaca dan mentadabburi Al-Qur\'an menjadikannya sahabat pembela di akhirat.',
  ),
  HadithItem(
    id: 18,
    collection: 'Riyadus Shalihin',
    number: 1384,
    title: 'Tiga Amal yang Tidak Terputus Setelah Wafat',
    topic: 'Ibadah & Ilmu',
    arabic:
        'إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَمَلُهُ إِلا مِنْ ثَلاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ',
    latin:
        'Idza matal-insanu inqatha\'a \'amaluhu illa min tsalatsin: shadaqatin jariyatin, aw \'ilmin yuntafa\'u bihi, aw waladin shalihin yad\'u lah.',
    translation:
        'Apabila manusia wafat, terputuslah amalnya kecuali dari tiga perkara: sedekah jariyah, ilmu yang bermanfaat, atau anak shalih yang mendoakannya.',
    narrator: 'HR. Muslim no. 1631 · Dari Abu Hurairah RA',
    fiqhPoints: 'Investasi akhirat terbaik adalah wakaf/sedekah jariyah, menyebarkan ilmu bermanfaat, dan mendidik keluarga shalih.',
  ),
  HadithItem(
    id: 19,
    collection: 'Riyadus Shalihin',
    number: 1409,
    title: 'Dua Kalimat yang Ringan di Lisan dan Berat di Timbangan',
    topic: 'Dzikir & Taubat',
    arabic: 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    latin:
        'Kalimatani khafifatani \'alal-lisan, tsaqilatani fil-mizan, habibatani ilar-Rahman: Subhanallahi wa bihamdih, Subhanallahil-\'Azhim.',
    translation:
        'Dua kalimat yang ringan diucapkan di lisan, berat dalam timbangan amal, dan sangat dicintai oleh Ar-Rahman: Subhanallahi wa bihamdih, Subhanallahil-\'Azhim.',
    narrator: 'HR. Bukhari no. 6406 & Muslim no. 2694 · Dari Abu Hurairah RA',
    fiqhPoints: 'Dzikir singkat yang dapat diamalkan kapan saja untuk memperberat timbangan amal kebaikan.',
  ),
  HadithItem(
    id: 20,
    collection: 'Riyadus Shalihin',
    number: 244,
    title: 'Meringankan Kesulitan Sesama Muslim',
    topic: 'Muamalah & Ukhuwah',
    arabic: 'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ، وَاللَّهُ فِي عَوْنِ الْعَبْدِ مَا كَانَ الْعَبْدُ فِي عَوْنِ أَخِيهِ',
    latin:
        'Man naffasa \'an mu\'minin kurbatan min kurabid-dunya naffasallahu \'anhu kurbatan min kurabi yawmil-qiyamah, wallahu fi \'awnil-\'abdi ma kanal-\'abdu fi \'awni akhih.',
    translation:
        'Barang siapa melapangkan satu kesusahan dunia dari seorang mukmin, niscaya Allah akan melapangkan darinya satu kesusahan pada hari Kiamat. Dan Allah senantiasa menolong hamba-Nya selama hamba itu menolong saudaranya.',
    narrator: 'HR. Muslim no. 2699 · Dari Abu Hurairah RA',
    fiqhPoints: 'Pertolongan Allah turun seiring kepedulian kita membantu sesama yang sedang kesulitan.',
  ),
];

HadithItem dailyHadithFor(DateTime date) {
  final days = date.difference(DateTime(2024, 1, 1)).inDays.abs();
  return hadithCatalog[days % hadithCatalog.length];
}

class HadithRepository {
  static const _bookmarksKey = 'hadith_bookmarks';
  final KeyValueStore _store;

  const HadithRepository(this._store);

  Future<Set<int>> bookmarkedIds() async {
    final raw = await _store.readJson(_bookmarksKey);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is num) x.toInt(),
    };
  }

  Future<Set<int>> toggleBookmark(int id) async {
    final set = await bookmarkedIds();
    if (!set.remove(id)) {
      set.add(id);
    }
    await _store.writeJson(_bookmarksKey, set.toList()..sort());
    return set;
  }
}
