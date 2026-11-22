import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';

class HadithItem {
  final int id;
  final String collection;
  final String? collectionEn;
  final int number;
  final String title;
  final String? titleEn;
  final String topic;
  final String? topicEn;
  final String arabic;
  final String latin;
  final String translation;
  final String? translationEn;
  final String narrator;
  final String? narratorEn;
  final String fiqhPoints;
  final String? fiqhPointsEn;

  const HadithItem({
    required this.id,
    required this.collection,
    this.collectionEn,
    required this.number,
    required this.title,
    this.titleEn,
    required this.topic,
    this.topicEn,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.translationEn,
    required this.narrator,
    this.narratorEn,
    required this.fiqhPoints,
    this.fiqhPointsEn,
  });

  String collectionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (collectionEn?.isNotEmpty ?? false) ? collectionEn! : collection;
  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String topicFor(AppLanguage lang) =>
      lang == AppLanguage.en && (topicEn?.isNotEmpty ?? false) ? topicEn! : topic;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
  String narratorFor(AppLanguage lang) =>
      lang == AppLanguage.en && (narratorEn?.isNotEmpty ?? false) ? narratorEn! : narrator;
  String fiqhPointsFor(AppLanguage lang) =>
      lang == AppLanguage.en && (fiqhPointsEn?.isNotEmpty ?? false) ? fiqhPointsEn! : fiqhPoints;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        (titleEn?.toLowerCase().contains(q) ?? false) ||
        topic.toLowerCase().contains(q) ||
        (topicEn?.toLowerCase().contains(q) ?? false) ||
        collection.toLowerCase().contains(q) ||
        (collectionEn?.toLowerCase().contains(q) ?? false) ||
        translation.toLowerCase().contains(q) ||
        (translationEn?.toLowerCase().contains(q) ?? false) ||
        latin.toLowerCase().contains(q) ||
        narrator.toLowerCase().contains(q) ||
        (narratorEn?.toLowerCase().contains(q) ?? false) ||
        fiqhPoints.toLowerCase().contains(q) ||
        (fiqhPointsEn?.toLowerCase().contains(q) ?? false) ||
        '$number' == q;
  }
}

const List<HadithItem> hadithCatalog = [
  HadithItem(
    id: 1,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 1,
    title: 'Segala Amal Tergantung pada Niat',
    titleEn: 'Actions Are Judged by Intentions',
    topic: 'Niat & Ikhlas',
    topicEn: 'Intention & Sincerity',
    arabic:
        'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
    latin:
        'Innamal a\'malu bin-niyyat, wa innama likulli imri\'in ma nawa, faman kanat hijratuhu ilallahi wa rasulihi fahijratuhu ilallahi wa rasulih...',
    translation:
        'Sesungguhnya setiap amalan tergantung pada niatnya. Dan sesungguhnya setiap orang akan mendapatkan apa yang ia niatkan. Barang siapa berhijrah karena Allah dan Rasul-Nya, maka hijrahnya kepada Allah dan Rasul-Nya.',
    translationEn:
        'Actions are solely by intentions, and every person shall have only what they intended. Whoever emigrates for Allah and His Messenger, their emigration is for Allah and His Messenger.',
    narrator: 'HR. Bukhari no. 1 & Muslim no. 1907 · Dari Umar bin Khattab RA (Muttafaqun \'Alaih)',
    narratorEn: 'Sahih al-Bukhari 1 & Sahih Muslim 1907 · Narrated by Umar ibn al-Khattab (RA)',
    fiqhPoints: 'Niat adalah syarat sah sekaligus penentu pahala amal ibadah; membedakan ibadah dari kebiasaan biasa.',
    fiqhPointsEn: 'Intention validates worship and determines its reward, distinguishing devotion from everyday habit.',
  ),
  HadithItem(
    id: 2,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 2,
    title: 'Tingkatan Agama: Islam, Iman, dan Ihsan',
    titleEn: 'Levels of Faith: Islam, Iman, and Ihsan',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic:
        'الإِسْلامُ أَنْ تَشْهَدَ أَنْ لا إِلَهَ إِلا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَتُقِيمَ الصَّلاةَ، وَتُؤْتِيَ الزَّكَاةَ، وَتَصُومَ رَمَضَانَ، وَتَحُجَّ الْبَيْتَ إِنِ اسْتَطَعْتَ إِلَيْهِ سَبِيلا',
    latin:
        'Al-Islamu an tasyhada an la ilaha illallah wa anna Muhammadar Rasulullah, wa tuqimash-shalah, wa tu\'tiyaz-zakah, wa tashuma Ramadhan, wa tahujjal-bayta inistatha\'ta ilayhi sabila.',
    translation:
        'Islam adalah engkau bersaksi bahwa tiada ilah yang berhak disembah selain Allah dan Muhammad adalah utusan Allah, mendirikan salat, menunaikan zakat, berpuasa Ramadan, dan berhaji ke Baitullah jika mampu. Ihsan adalah engkau beribadah kepada Allah seakan-akan melihat-Nya.',
    translationEn:
        'Islam is to testify that there is no deity worthy of worship except Allah and Muhammad is the Messenger of Allah, to establish prayer, give Zakat, fast Ramadan, and make pilgrimage to the House if able. Ihsan is to worship Allah as though you see Him.',
    narrator: 'HR. Muslim no. 8 · Dari Umar bin Khattab RA (Hadits Jibril)',
    narratorEn: 'Sahih Muslim 8 · Narrated by Umar ibn al-Khattab (RA) (Hadith of Jibril)',
    fiqhPoints: 'Merangkum 5 rukun Islam, 6 rukun Iman, dan puncak kualitas ibadah (Ihsan / muraqabah).',
    fiqhPointsEn: 'Summarizes the 5 pillars of Islam, 6 articles of Iman, and the highest level of devotion (Ihsan).',
  ),
  HadithItem(
    id: 3,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 3,
    title: 'Lima Fondasi Bangunan Islam',
    titleEn: 'The Five Pillars of Islam',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic:
        'بُنِيَ الإِسْلامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لا إِلَهَ إِلا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلاةِ، وَإِيتَاءِ الزَّكَاةِ، وَحَجِّ الْبَيْتِ، وَصَوْمِ رَمَضَانَ',
    latin:
        'Buniyal-Islamu \'ala khamsin: syahadati an la ilaha illallah wa anna Muhammadar Rasulullah, wa iqamish-shalah, wa ita\'iz-zakah, wa hajjil-bayti, wa shawmi Ramadhan.',
    translation:
        'Islam dibangun di atas lima perkara: persaksian bahwa tiada Tuhan yang berhak disembah selain Allah dan Muhammad adalah utusan Allah, mendirikan salat, menunaikan zakat, haji ke Baitullah, dan puasa Ramadan.',
    translationEn:
        'Islam is built upon five pillars: testifying that there is no deity except Allah and Muhammad is His Messenger, establishing prayer, paying Zakat, pilgrimage to the House, and fasting Ramadan.',
    narrator: 'HR. Bukhari no. 8 & Muslim no. 16 · Dari Ibnu Umar RA',
    narratorEn: 'Sahih al-Bukhari 8 & Sahih Muslim 16 · Narrated by Ibn Umar (RA)',
    fiqhPoints: 'Syahadat dan salat merupakan tiang utama yang tidak boleh ditinggalkan oleh seorang muslim.',
    fiqhPointsEn: 'The testimony of faith and daily prayer form the core foundation of a Muslim\'s devotion.',
  ),
  HadithItem(
    id: 4,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 5,
    title: 'Menolak Perkara Baru yang Mengada-ada dalam Agama',
    titleEn: 'Rejecting Baseless Innovations in Religion',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic: 'مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ',
    latin: 'Man ahdatsa fi amrina hadza ma laysa minhu fahuwa raddun.',
    translation: 'Barang siapa membuat suatu perkara baru dalam urusan (agama) kami ini yang tidak ada asalnya, maka perkara tersebut tertolak.',
    translationEn: 'Whoever introduces into this affair of ours something that does not belong to it will have it rejected.',
    narrator: 'HR. Bukhari no. 2697 & Muslim no. 1718 · Dari Aisyah RA',
    narratorEn: 'Sahih al-Bukhari 2697 & Sahih Muslim 1718 · Narrated by Aisha (RA)',
    fiqhPoints: 'Syarat diterimanya ibadah ada dua: ikhlas karena Allah dan mengikuti tuntunan (ittiba\') Rasulullah SAW.',
    fiqhPointsEn: 'Accepted worship requires two conditions: sincerity solely for Allah and adherence to Prophetic guidance.',
  ),
  HadithItem(
    id: 5,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 6,
    title: 'Halal dan Haram Telah Jelas, Menjauhi Syubhat',
    titleEn: 'The Lawful and Unlawful Are Clear; Guard Against Doubtful Matters',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic:
        'إِنَّ الْحَلالَ بَيِّنٌ وَإِنَّ الْحَرَامَ بَيِّنٌ وَبَيْنَهُمَا مُشْتَبِهَاتٌ لا يَعْلَمُهُنَّ كَثِيرٌ مِنَ النَّاسِ، فَمَنِ اتَّقَى الشُّبُهَاتِ اسْتَبْرَأَ لِدِينِهِ وَعِرْضِهِ',
    latin:
        'Innal-halala bayyinun wa innal-harama bayyinun wa baynahuma musytabihatun la ya\'lamuhunna katsirum minan-nas, famanittaqasy-syubuhat istabra\'a lidinihi wa \'irdhih.',
    translation:
        'Sesungguhnya yang halal itu jelas dan yang haram itu jelas. Di antara keduanya terdapat perkara-perkara syubhat (samar) yang tidak diketahui oleh banyak orang. Barang siapa menjaga diri dari syubhat, maka ia telah menyelamatkan agama dan kehormatannya.',
    translationEn:
        'The lawful is clear and the unlawful is clear, and between them are doubtful matters unknown to many people. Whoever avoids doubtful matters protects their religion and honor.',
    narrator: 'HR. Bukhari no. 52 & Muslim no. 1599 · Dari Nu\'man bin Basyir RA',
    narratorEn: 'Sahih al-Bukhari 52 & Sahih Muslim 1599 · Narrated by An-Nu\'man ibn Bashir (RA)',
    fiqhPoints: 'Menjaga kehalalan makanan, penghasilan, dan memperbaiki hati karena hati adalah raja bagi seluruh anggota tubuh.',
    fiqhPointsEn: 'Guard lawful livelihood and purify the heart, for when the heart is sound, all actions follow.',
  ),
  HadithItem(
    id: 6,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 7,
    title: 'Agama adalah Nasihat (Ketulusan)',
    titleEn: 'Religion Is Sincere Counsel',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'الدِّينُ النَّصِيحَةُ. قُلْنَا: لِمَنْ؟ قَالَ: لِلَّهِ وَلِكِتَابِهِ وَلِرَسُولِهِ وَلِأَئِمَّةِ الْمُسْلِمِينَ وَعَامَّتِهِمْ',
    latin: 'Ad-dinun-nashihah. Qulna: liman? Qala: Lillahi wa likitabihi wa lirasulihi wa li-a\'immatil-muslimina wa \'ammatihim.',
    translation:
        'Agama adalah nasihat (ketulusan). Kami bertanya: Untuk siapa? Beliau menjawab: Untuk Allah, Kitab-Nya, Rasul-Nya, para pemimpin kaum muslimin, dan kaum muslimin pada umumnya.',
    translationEn:
        'Religion is sincere counsel. We asked, "To whom?" He replied, "To Allah, His Book, His Messenger, the leaders of the Muslims, and their common folk."',
    narrator: 'HR. Muslim no. 55 · Dari Tamim Ad-Dari RA',
    narratorEn: 'Sahih Muslim 55 · Narrated by Tamim ad-Dari (RA)',
    fiqhPoints: 'Ketulusan beragama diwujudkan dengan memurnikan ketaatan kepada Allah dan saling menasihati dalam kebaikan.',
    fiqhPointsEn: 'Sincerity in faith is lived through pure devotion to Allah and gentle, truthful care for the community.',
  ),
  HadithItem(
    id: 7,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 12,
    title: 'Meninggalkan Hal yang Tidak Bermanfaat',
    titleEn: 'Leaving What Does Not Concern One',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'مِنْ حُسْنِ إِسْلامِ الْمَرْءِ تَرْكُهُ مَا لا يَعْنِيهِ',
    latin: 'Min husni islamil-mar\'i tarkuhu ma la ya\'nih.',
    translation: 'Di antara tanda kebaikan Islam seseorang adalah meninggalkan hal-hal yang tidak bermanfaat baginya.',
    translationEn: 'Part of the perfection of a person\'s Islam is leaving alone that which does not concern them.',
    narrator: 'HR. Tirmidzi no. 2317 & Ibnu Majah no. 3976 · Dari Abu Hurairah RA (Hasan)',
    narratorEn: 'Jami\' at-Tirmidhi 2317 & Sunan Ibn Majah 3976 · Narrated by Abu Hurayrah (RA) (Hasan)',
    fiqhPoints: 'Menjaga waktu, lisan, dan perhatian agar terfokus pada amal yang membawa manfaat dunia maupun akhirat.',
    fiqhPointsEn: 'Guard your time, speech, and focus for pursuits that benefit this life and the Hereafter.',
  ),
  HadithItem(
    id: 8,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 13,
    title: 'Mencintai Saudara Sebagaimana Mencintai Diri Sendiri',
    titleEn: 'Loving for Your Brother What You Love for Yourself',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    latin: 'La yu\'minu ahadukum hatta yuhibba li-akhihi ma yuhibbu linafsih.',
    translation: 'Tidak sempurna iman salah seorang di antara kalian hingga ia mencintai untuk saudaranya kebaikan yang ia cintai untuk dirinya sendiri.',
    translationEn: 'None of you truly believes until they love for their brother what they love for themselves.',
    narrator: 'HR. Bukhari no. 13 & Muslim no. 45 · Dari Anas bin Malik RA',
    narratorEn: 'Sahih al-Bukhari 13 & Sahih Muslim 45 · Narrated by Anas ibn Malik (RA)',
    fiqhPoints: 'Ukhuwah Islamiyah menuntut bersihnya hati dari hasad (dengki) dan senang melihat saudara mendapat kebaikan.',
    fiqhPointsEn: 'True brotherhood cleanses the heart of envy and rejoices whenever goodness reaches others.',
  ),
  HadithItem(
    id: 9,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 15,
    title: 'Berkata Baik atau Diam, Memuliakan Tetangga & Tamu',
    titleEn: 'Speak Good or Remain Silent; Honor Neighbor & Guest',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic:
        'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ جَارَهُ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ ضَيْفَهُ',
    latin:
        'Man kana yu\'minu billahi wal-yawmil-akhiri falyaqul khayran aw liyashmut, wa man kana yu\'minu billahi wal-yawmil-akhiri falyukrim jarahu, wa man kana yu\'minu billahi wal-yawmil-akhiri falyukrim dhayfah.',
    translation:
        'Barang siapa beriman kepada Allah dan hari akhir, hendaklah ia berkata yang baik atau diam. Barang siapa beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tetangganya. Dan barang siapa beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tamunya.',
    translationEn:
        'Whoever believes in Allah and the Last Day should speak good or remain silent; whoever believes in Allah and the Last Day should honor their neighbor; and whoever believes in Allah and the Last Day should honor their guest.',
    narrator: 'HR. Bukhari no. 6018 & Muslim no. 47 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 6018 & Sahih Muslim 47 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Adab lisan dan adab bertetangga adalah bukti nyata keimanan seseorang.',
    fiqhPointsEn: 'Restrained speech, kindness to neighbors, and hospitality are living proof of sincere faith.',
  ),
  HadithItem(
    id: 10,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 16,
    title: 'Wasiat Ringkas Rasulullah: Jangan Marah',
    titleEn: 'The Prophet\'s Concise Counsel: Do Not Become Angry',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'أَوْصِنِي، قَالَ: لا تَغْضَبْ. فَرَدَّدَ مِرَارًا، قَالَ: لا تَغْضَبْ',
    latin: 'Awshini, qala: La taghdhab. Faraddada miraran, qala: La taghdhab.',
    translation: 'Seorang sahabat berkata kepada Nabi SAW: Berilah aku wasiat. Beliau menjawab: Janganlah engkau marah. Orang itu mengulangi permintaannya, dan beliau tetap menjawab: Janganlah engkau marah.',
    translationEn: 'A man said to the Prophet (peace be upon him), "Advise me." He replied, "Do not become angry." The man repeated his request several times, and each time he replied, "Do not become angry."',
    narrator: 'HR. Bukhari no. 6116 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 6116 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Menahan amarah mencegah kerusakan hubungan, penyesalan, dan kezaliman.',
    fiqhPointsEn: 'Controlling anger prevents broken relationships, regret, and unjust words or actions.',
  ),
  HadithItem(
    id: 11,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 18,
    title: 'Bertakwa di Mana Saja dan Mengiringi Kesalahan dengan Kebaikan',
    titleEn: 'Be Mindful of Allah Everywhere & Follow Bad with Good',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
    latin: 'Ittaqillaha haytsuma kunta, wa atbi\'is-sayyi\'atal-hasanata tamhuha, wa khaliqin-nasa bikhuluqin hasan.',
    translation:
        'Bertakwalah kepada Allah di mana pun engkau berada. Iringilah perbuatan buruk dengan perbuatan baik, niscaya kebaikan itu akan menghapusnya. Dan pergaulilah manusia dengan akhlak yang mulia.',
    translationEn:
        'Be mindful of Allah wherever you are, follow a bad deed with a good deed and it will erase it, and treat people with good character.',
    narrator: 'HR. Tirmidzi no. 1987 · Dari Abu Dzar & Mu\'adz bin Jabal RA (Hasan Shahih)',
    narratorEn: 'Jami\' at-Tirmidhi 1987 · Narrated by Abu Dharr & Mu\'adh ibn Jabal (RA) (Hasan Sahih)',
    fiqhPoints: 'Menyatukan hak Allah (takwa & taubat) dengan hak sesama manusia (akhlak mulia).',
    fiqhPointsEn: 'Unites Allah\'s rights (taqwa and repentance) with people\'s rights (noble character).',
  ),
  HadithItem(
    id: 12,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 19,
    title: 'Jagalah Allah, Niscaya Allah Menjagamu',
    titleEn: 'Be Mindful of Allah, and He Will Protect You',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic:
        'يَا غُلامُ إِنِّي أُعَلِّمُكَ كَلِمَاتٍ: احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجَاهَكَ، إِذَا سَأَلْتَ فَاسْأَلِ اللَّهَ، وَإِذَا اسْتَعَنْتَ فَاسْتَعِنْ بِاللَّهِ',
    latin:
        'Ya ghulamu inni u\'allimuka kalimat: Ihfazhillaha yahfazhka, ihfazhillaha tajidhu tujahaka, idza sa\'alta fas\'alillah, wa idzasta\'anta fasta\'in billah.',
    translation:
        'Wahai anak muda, sesungguhnya aku akan mengajarkan kepadamu beberapa kalimat: Jagalah (batasan) Allah, niscaya Allah akan menjagamu. Jagalah Allah, niscaya engkau mendapati-Nya selalu menolongmu. Jika engkau meminta, mintalah kepada Allah; dan jika engkau memohon pertolongan, mohonlah kepada Allah.',
    translationEn:
        'Young man, I shall teach you some words: Be mindful of Allah, and He will protect you. Be mindful of Allah, and you will find Him before you. When you ask, ask Allah; and when you seek help, seek help from Allah.',
    narrator: 'HR. Tirmidzi no. 2516 · Dari Ibnu Abbas RA (Hasan Shahih)',
    narratorEn: 'Jami\' at-Tirmidhi 2516 · Narrated by Ibn Abbas (RA) (Hasan Sahih)',
    fiqhPoints: 'Menanamkan tawakal, keyakinan akan takdir, dan ketergantungan penuh hanya kepada Allah.',
    fiqhPointsEn: 'Instills trust in Allah, serenity in divine decree, and reliance on Him alone.',
  ),
  HadithItem(
    id: 13,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 21,
    title: 'Katakanlah Aku Beriman kepada Allah, Lalu Istiqamahlah',
    titleEn: 'Say "I Believe in Allah," Then Remain Steadfast',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic: 'قُلْ آمَنْتُ بِاللَّهِ ثُمَّ اسْتَقِمْ',
    latin: 'Qul amantu billahi tsummastaqim.',
    translation: 'Katakanlah: Aku beriman kepada Allah, kemudian istiqamahlah (teguh di atas ketaatan).',
    translationEn: 'Say, "I believe in Allah," and then be steadfast.',
    narrator: 'HR. Muslim no. 38 · Dari Sufyan bin Abdullah Ats-Tsaqafi RA',
    narratorEn: 'Sahih Muslim 38 · Narrated by Sufyan ibn Abdullah ath-Thaqafi (RA)',
    fiqhPoints: 'Inti keberhasilan seorang mukmin adalah keteguhan (istiqamah) menjaga iman dan amal hingga akhir hayat.',
    fiqhPointsEn: 'Lasting success rests on quiet, steady constancy in faith and righteous action.',
  ),
  HadithItem(
    id: 14,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 23,
    title: 'Bersuci Sebagian dari Iman & Al-Qur\'an Hujjah Bagimu',
    titleEn: 'Purity Is Half of Faith & the Quran Is a Proof',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic:
        'الطُّهُورُ شَطْرُ الإِيمَانِ، وَالْحَمْدُ لِلَّهِ تَمْلأُ الْمِيزَانَ، وَسُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ تَمْلآَنِ مَا بَيْنَ السَّمَاوَاتِ وَالأَرْضِ، وَالصَّلاةُ نُورٌ، وَالصَّدَقَةُ بُرْهَانٌ، وَالصَّبْرُ ضِيَاءٌ، وَالْقُرْآنُ حُجَّةٌ لَكَ أَوْ عَلَيْكَ',
    latin:
        'Ath-thuhuru syathrul-iman, walhamdu lillahi tamla\'ul-mizan, wa subhanallahi walhamdu lillahi tamla\'ani ma baynas-samawati wal-ardh, wash-shalatu nurun, wash-shadaqatu burhanun, wash-shabru dhiya\'un, wal-Qur\'anu hujjatun laka aw \'alayk.',
    translation:
        'Bersuci adalah separuh dari iman. Ucapan Alhamdulillah memenuhi timbangan. Subhanallah dan Alhamdulillah memenuhi ruang antara langit dan bumi. Salat adalah cahaya, sedekah adalah bukti keimanan, sabar adalah sinar, dan Al-Qur\'an adalah pembela bagimu atau penuntut atasmu.',
    translationEn:
        'Purity is half of faith. Alhamdulillah fills the scales. Subhanallah and Alhamdulillah fill what is between the heavens and the earth. Prayer is light, charity is proof, patience is radiance, and the Quran is a proof for you or against you.',
    narrator: 'HR. Muslim no. 223 · Dari Abu Malik Al-Asy\'ari RA',
    narratorEn: 'Sahih Muslim 223 · Narrated by Abu Malik al-Ash\'ari (RA)',
    fiqhPoints: 'Keutamaan wudhu, dzikir, salat, sedekah, sabar, dan mengamalkan Al-Qur\'an.',
    fiqhPointsEn: 'Highlights the immense value of purity, dhikr, prayer, charity, patience, and living by the Quran.',
  ),
  HadithItem(
    id: 15,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 32,
    title: 'Tidak Boleh Membahayakan Diri Sendiri maupun Orang Lain',
    titleEn: 'Neither Harm Nor Reciprocate Harm',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'لا ضَرَرَ وَلا ضِرَارَ',
    latin: 'La dharara wa la dhirar.',
    translation: 'Tidak boleh melakukan perbuatan yang membahayakan diri sendiri dan tidak boleh pula membahayakan orang lain.',
    translationEn: 'There should be neither harming nor reciprocating harm.',
    narrator: 'HR. Ibnu Majah no. 2340 & Ahmad V/326 · Dari Abu Sa\'id Al-Khudri RA (Hasan)',
    narratorEn: 'Sunan Ibn Majah 2340 & Musnad Ahmad 5/326 · Narrated by Abu Sa\'id al-Khudri (RA) (Hasan)',
    fiqhPoints: 'Kaidah besar fiqih Islam (Adh-Dhararu Yuzal): segala bentuk mudarat dan kezaliman wajib dihilangkan.',
    fiqhPointsEn: 'A core maxim of Islamic jurisprudence (Harm must be removed): every form of harm and injustice must be eliminated.',
  ),
  HadithItem(
    id: 16,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 1388,
    title: 'Keutamaan Menempuh Jalan Menuntut Ilmu',
    titleEn: 'Virtue of Walking the Path of Seeking Knowledge',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
    latin: 'Man salaka thariqan yaltamisu fihi \'ilman sahhalallahu lahu bihi thariqan ilal-jannah.',
    translation: 'Barang siapa menempuh suatu jalan untuk mencari ilmu, maka Allah akan memudahkan baginya jalan menuju surga.',
    translationEn: 'Whoever treads a path in pursuit of knowledge, Allah will make easy for them a path to Paradise.',
    narrator: 'HR. Muslim no. 2699 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 2699 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Setiap langkah, bacaan, dan waktu yang dicurahkan untuk mempelajari ilmu agama bernilai ibadah menuju surga.',
    fiqhPointsEn: 'Every step and moment devoted to learning beneficial sacred knowledge counts as worship leading to Paradise.',
  ),
  HadithItem(
    id: 17,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 999,
    title: 'Bacalah Al-Qur\'an karena Ia Akan Datang Memberi Syafaat',
    titleEn: 'Recite the Quran, for It Will Intercede for Its Companions',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic: 'اقْرَءُوا الْقُرْآنَ فَإِنَّهُ يَأْتِي يَوْمَ الْقِيَامَةِ شَفِيعًا لِأَصْحَابِهِ',
    latin: 'Iqra\'ul-Qur\'ana fa innahu ya\'ti yawmal-qiyamati syafi\'an li-ashhabih.',
    translation: 'Bacalah Al-Qur\'an, karena sesungguhnya ia akan datang pada hari Kiamat sebagai pemberi syafaat bagi para pembacanya.',
    translationEn: 'Recite the Quran, for indeed it will come on the Day of Resurrection as an intercessor for its companions.',
    narrator: 'HR. Muslim no. 804 · Dari Abu Umamah Al-Bahili RA',
    narratorEn: 'Sahih Muslim 804 · Narrated by Abu Umamah al-Bahili (RA)',
    fiqhPoints: 'Rutin membaca dan mentadabburi Al-Qur\'an menjadikannya sahabat pembela di akhirat.',
    fiqhPointsEn: 'Regular recitation and reflection make the Quran a loyal advocate in the Hereafter.',
  ),
  HadithItem(
    id: 18,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 1384,
    title: 'Tiga Amal yang Tidak Terputus Setelah Wafat',
    titleEn: 'Three Deeds That Endure After Death',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic:
        'إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَمَلُهُ إِلا مِنْ ثَلاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ',
    latin:
        'Idza matal-insanu inqatha\'a \'amaluhu illa min tsalatsin: shadaqatin jariyatin, aw \'ilmin yuntafa\'u bihi, aw waladin shalihin yad\'u lah.',
    translation:
        'Apabila manusia wafat, terputuslah amalnya kecuali dari tiga perkara: sedekah jariyah, ilmu yang bermanfaat, atau anak shalih yang mendoakannya.',
    translationEn:
        'When a person passes away, their deeds come to an end except for three: ongoing charity, beneficial knowledge, or a righteous child who prays for them.',
    narrator: 'HR. Muslim no. 1631 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 1631 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Investasi akhirat terbaik adalah wakaf/sedekah jariyah, menyebarkan ilmu bermanfaat, dan mendidik keluarga shalih.',
    fiqhPointsEn: 'The most enduring investments are ongoing charity (waqf), sharing beneficial knowledge, and raising righteous children.',
  ),
  HadithItem(
    id: 19,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 1409,
    title: 'Dua Kalimat yang Ringan di Lisan dan Berat di Timbangan',
    titleEn: 'Two Phrases Light on the Tongue, Heavy on the Scale',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    latin:
        'Kalimatani khafifatani \'alal-lisan, tsaqilatani fil-mizan, habibatani ilar-Rahman: Subhanallahi wa bihamdih, Subhanallahil-\'Azhim.',
    translation:
        'Dua kalimat yang ringan diucapkan di lisan, berat dalam timbangan amal, dan sangat dicintai oleh Ar-Rahman: Subhanallahi wa bihamdih, Subhanallahil-\'Azhim.',
    translationEn:
        'Two phrases are light on the tongue, heavy on the scale, and beloved to the Most Merciful: Subhanallahi wa bihamdih, Subhanallahil-\'Azim.',
    narrator: 'HR. Bukhari no. 6406 & Muslim no. 2694 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 6406 & Sahih Muslim 2694 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Dzikir singkat yang dapat diamalkan kapan saja untuk memperberat timbangan amal kebaikan.',
    fiqhPointsEn: 'A brief, effortless dhikr to weave into any moment of the day to enrich one\'s scale of good deeds.',
  ),
  HadithItem(
    id: 20,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 244,
    title: 'Meringankan Kesulitan Sesama Muslim',
    titleEn: 'Relieving the Hardship of a Fellow Believer',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ، وَاللَّهُ فِي عَوْنِ الْعَبْدِ مَا كَانَ الْعَبْدُ فِي عَوْنِ أَخِيهِ',
    latin:
        'Man naffasa \'an mu\'minin kurbatan min kurabid-dunya naffasallahu \'anhu kurbatan min kurabi yawmil-qiyamah, wallahu fi \'awnil-\'abdi ma kanal-\'abdu fi \'awni akhih.',
    translation:
        'Barang siapa melapangkan satu kesusahan dunia dari seorang mukmin, niscaya Allah akan melapangkan darinya satu kesusahan pada hari Kiamat. Dan Allah senantiasa menolong hamba-Nya selama hamba itu menolong saudaranya.',
    translationEn:
        'Whoever relieves a believer of a distress of this world, Allah will relieve them of a distress on the Day of Resurrection. And Allah remains in the aid of the servant so long as the servant is in the aid of their brother.',
    narrator: 'HR. Muslim no. 2699 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 2699 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Pertolongan Allah turun seiring kepedulian kita membantu sesama yang sedang kesulitan.',
    fiqhPointsEn: 'Allah\'s direct support accompanies those who step forward to ease the burdens of others.',
  ),
  HadithItem(
    id: 21,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 9,
    title: 'Laksanakan Perintah Sesuai Kemampuan & Jauhi Larangan',
    titleEn: 'Perform Commands as You Are Able & Avoid Prohibitions',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic: 'مَا نَهَيْتُكُمْ عَنْهُ فَاجْتَنِبُوهُ، وَمَا أَمَرْتُكُمْ بِهِ فَأْتُوا مِنْهُ مَا اسْتَطَعْتُمْ',
    latin: 'Ma nahaytukum \'anhu fajtanibuhu, wa ma amartukum bihi fa\'tu minhu mastatha\'tum.',
    translation:
        'Apa yang aku larang kepada kalian maka jauhilah, dan apa yang aku perintahkan kepada kalian maka kerjakanlah semampu kalian.',
    translationEn:
        'What I have forbidden to you, avoid; and what I have commanded you, do as much of it as you are able.',
    narrator: 'HR. Bukhari no. 7288 & Muslim no. 1337 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 7288 & Sahih Muslim 1337 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Syariat Islam penuh kemudahan dalam ketaatan sesuai kesanggupan, namun tegas dalam menjauhi larangan.',
    fiqhPointsEn: 'Islamic law grants ease in fulfilling commands according to ability while firmly guarding against what is forbidden.',
  ),
  HadithItem(
    id: 22,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 10,
    title: 'Allah Maha Baik dan Hanya Menerima yang Baik',
    titleEn: 'Allah Is Pure and Accepts Only What Is Pure',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'إِنَّ اللَّهَ طَيِّبٌ لا يَقْبَلُ إِلا طَيِّبًا',
    latin: 'Innallaha thayyibun la yaqbalu illa thayyiba.',
    translation: 'Sesungguhnya Allah Maha Baik dan tidak menerima kecuali sesuatu yang baik dan halal.',
    translationEn: 'Indeed, Allah is Pure and accepts only that which is pure and lawful.',
    narrator: 'HR. Muslim no. 1015 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 1015 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Makanan, harta, dan rezeki yang halal menjadi salah satu sebab utama terkabulnya doa.',
    fiqhPointsEn: 'Lawful earnings and wholesome sustenance are essential causes for prayers to be answered.',
  ),
  HadithItem(
    id: 23,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 11,
    title: 'Tinggalkan yang Meragukan Menuju yang Meyakinkan',
    titleEn: 'Leave What Makes You Doubt for What Does Not',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'دَعْ مَا يَرِيبُكَ إِلَى مَا لا يَرِيبُكَ',
    latin: 'Da\' ma yaribuka ila ma la yaribuk.',
    translation: 'Tinggalkanlah sesuatu yang meragukanmu menuju sesuatu yang tidak meragukanmu.',
    translationEn: 'Leave that which makes you doubt for that which does not make you doubt.',
    narrator: 'HR. Tirmidzi no. 2518 & Nasa\'i no. 5711 · Dari Hasan bin Ali RA (Shahih)',
    narratorEn: 'Jami\' at-Tirmidhi 2518 & Sunan an-Nasa\'i 5711 · Narrated by Al-Hasan ibn Ali (RA)',
    fiqhPoints: 'Kejujuran membawa ketenangan hati, sedangkan keraguan dan sikap hati-hati (wara\') melindungi iman.',
    fiqhPointsEn: 'Truthfulness brings peace to the heart, and caution in doubtful matters preserves integrity.',
  ),
  HadithItem(
    id: 24,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 17,
    title: 'Allah Mewajibkan Berbuat Ihsan dalam Segala Sesuatu',
    titleEn: 'Allah Prescribed Excellence in Everything',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'إِنَّ اللَّهَ كَتَبَ الإِحْسَانَ عَلَى كُلِّ شَيْءٍ',
    latin: 'Innallaha katabal-ihsana \'ala kulli syay\'.',
    translation: 'Sesungguhnya Allah telah menetapkan sikap ihsan (berbuat sebaik-baiknya) atas segala sesuatu.',
    translationEn: 'Indeed, Allah has prescribed excellence (ihsan) in all things.',
    narrator: 'HR. Muslim no. 1955 · Dari Syaddad bin Aus RA',
    narratorEn: 'Sahih Muslim 1955 · Narrated by Shaddad ibn Aws (RA)',
    fiqhPoints: 'Seorang muslim dituntut bekerja, beribadah, dan memperlakukan makhluk dengan kasih sayang serta mutu terbaik.',
    fiqhPointsEn: 'A Muslim strives for care, mercy, and high quality in worship, work, and treatment of all creation.',
  ),
  HadithItem(
    id: 25,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 20,
    title: 'Malu Merupakan Ajaran Para Nabi Terdahulu',
    titleEn: 'Modesty Is Part of Early Prophetic Wisdom',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'إِنَّ مِمَّا أَدْرَكَ النَّاسُ مِنْ كَلامِ النُّبُوَّةِ الأُولَى: إِذَا لَمْ تَسْتَحِ فَاصْنَعْ مَا شِئْتَ',
    latin: 'Inna mimma adrakan-nasu min kalamin-nubuwwatil-ula: Idza lam tastahi fashna\' ma syi\'t.',
    translation:
        'Sesungguhnya di antara perkataan kenabian terdahulu yang sampai kepada manusia adalah: Jika engkau tidak memiliki rasa malu, berbuatlah sesukamu.',
    translationEn:
        'Among the words people obtained from earlier prophecy is: If you feel no shame, then do as you wish.',
    narrator: 'HR. Bukhari no. 3483 · Dari Abu Mas\'ud Al-Anshari RA',
    narratorEn: 'Sahih al-Bukhari 3483 · Narrated by Abu Mas\'ud al-Ansari (RA)',
    fiqhPoints: 'Rasa malu kepada Allah adalah benteng akhlak yang mencegah seseorang dari keburukan.',
    fiqhPointsEn: 'Modesty before Allah acts as an inner safeguard that restrains a person from wrongdoing.',
  ),
  HadithItem(
    id: 26,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 24,
    title: 'Hadits Qudsi: Haramnya Kezaliman atas Sesama',
    titleEn: 'Hadith Qudsi: Prohibition of Oppression',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'يَا عِبَادِي إِنِّي حَرَّمْتُ الظُّلْمَ عَلَى نَفْسِي وَجَعَلْتُهُ بَيْنَكُمْ مُحَرَّمًا فَلا تَظَالَمُوا',
    latin: 'Ya \'ibadi inni harramtuzh-zhulma \'ala nafsi wa ja\'altuhu baynakum muharraman fala tazhalamu.',
    translation:
        'Wahai hamba-hamba-Ku, sesungguhnya Aku telah mengharamkan kezaliman atas diri-Ku dan Aku menjadikannya haram di antara kalian, maka janganlah kalian saling menzalimi.',
    translationEn:
        'O My servants, I have forbidden oppression for Myself and have made it forbidden amongst you, so do not oppress one another.',
    narrator: 'HR. Muslim no. 2577 · Dari Abu Dzar Al-Ghifari RA (Hadits Qudsi)',
    narratorEn: 'Sahih Muslim 2577 · Narrated by Abu Dharr al-Ghifari (RA) (Hadith Qudsi)',
    fiqhPoints: 'Keadilan adalah asas kehidupan bermasyarakat; setiap bentuk kezaliman akan dimintai pertanggungjawaban.',
    fiqhPointsEn: 'Justice underpins community life, and every form of unfairness or harm is strictly forbidden.',
  ),
  HadithItem(
    id: 27,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 26,
    title: 'Setiap Persendian Memiliki Sedekah Setiap Hari',
    titleEn: 'Charity Is Due for Every Joint Each Day',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic:
        'كُلُّ سُلامَى مِنَ النَّاسِ عَلَيْهِ صَدَقَةٌ كُلَّ يَوْمٍ تَطْلُعُ فِيهِ الشَّمْسُ: تَعْدِلُ بَيْنَ الاثْنَيْنِ صَدَقَةٌ، وَالْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
    latin:
        'Kullu sulama minan-nasi \'alayhi shadaqatun kulla yawmin tathlu\'u fihisy-syams: ta\'dilu baynal-itsnayni shadaqah, wal-kalimatuth-thayyibatu shadaqah.',
    translation:
        'Setiap persendian manusia memiliki kewajiban sedekah setiap hari saat matahari terbit: mendamaikan dua orang dengan adil adalah sedekah, dan ucapan yang baik adalah sedekah.',
    translationEn:
        'Every joint of a person must perform a charity each day the sun rises: acting justly between two people is charity, and a good word is charity.',
    narrator: 'HR. Bukhari no. 2989 & Muslim no. 1009 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 2989 & Sahih Muslim 1009 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Sedekah tidak terbatas pada harta; kata-kata baik, membantu sesama, dan salat Dhuha bernilai sedekah.',
    fiqhPointsEn: 'Charity extends beyond wealth to kind speech, peacemaking, helping others, and Dhuha prayer.',
  ),
  HadithItem(
    id: 28,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 27,
    title: 'Kebaikan adalah Akhlak Mulia, Dosa Meresahkan Jiwa',
    titleEn: 'Righteousness Is Good Character; Sin Troubles the Heart',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'الْبِرُّ حُسْنُ الْخُلُقِ، وَالإِثْمُ مَا حَاكَ فِي صَدْرِكَ وَكَرِهْتَ أَنْ يَطَّلِعَ عَلَيْهِ النَّاسُ',
    latin: 'Al-birru husnul-khuluq, wal-itsmu ma haka fi shadrika wa karihta an yaththali\'a \'alayhin-nas.',
    translation:
        'Kebaikan adalah akhlak yang mulia, sedangkan dosa adalah apa yang menggelisahkan hatimu dan engkau tidak suka jika diketahui oleh orang lain.',
    translationEn:
        'Righteousness is good character, and sin is whatever wavers in your chest and you dislike for people to discover.',
    narrator: 'HR. Muslim no. 2553 · Dari An-Nawwas bin Sam\'an RA',
    narratorEn: 'Sahih Muslim 2553 · Narrated by An-Nawwas ibn Sam\'an (RA)',
    fiqhPoints: 'Hati mukmin yang bersih memiliki kepekaan alami membedakan kebaikan yang menenangkan dan dosa yang meresahkan.',
    fiqhPointsEn: 'A sound believing heart senses tranquility in good deeds and unease in wrongful conduct.',
  ),
  HadithItem(
    id: 29,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 31,
    title: 'Zuhud di Dunia Dicintai Allah dan Manusia',
    titleEn: 'Detachment from Worldly Excess Brings Love of Allah and People',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'ازْهَدْ فِي الدُّنْيَا يُحِبَّكَ اللَّهُ، وَازْهَدْ فِيمَا عِنْدَ النَّاسِ يُحِبَّكَ النَّاسُ',
    latin: 'Izhad fid-dunya yuhibbakallah, wazhad fima \'indan-nasi yuhibbakan-nas.',
    translation:
        'Zuhudlah terhadap dunia niscaya Allah mencintaimu, dan zuhudlah terhadap apa yang dimiliki manusia niscaya manusia mencintaimu.',
    translationEn:
        'Be detached from the world and Allah will love you; be detached from what is in people\'s hands and people will love you.',
    narrator: 'HR. Ibnu Majah no. 4102 · Dari Sahl bin Sa\'ad As-Sa\'idi RA (Hasan)',
    narratorEn: 'Sunan Ibn Majah 4102 · Narrated by Sahl ibn Sa\'d as-Sa\'idi (RA) (Hasan)',
    fiqhPoints: 'Zuhud berarti meletakkan dunia di tangan, bukan di hati, dan menjaga kehormatan diri dari meminta-minta.',
    fiqhPointsEn: 'Zuhd means holding worldly blessings in one\'s hand rather than one\'s heart, living with dignity and contentment.',
  ),
  HadithItem(
    id: 30,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 35,
    title: 'Persaudaraan Muslim: Jangan Dengki dan Saling Membenci',
    titleEn: 'Muslim Brotherhood: Avoid Envy and Hatred',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'لا تَحَاسَدُوا، وَلا تَبَاغَضُوا، وَلا تَدَابَرُوا، وَكُونُوا عِبَادَ اللَّهِ إِخْوَانًا. الْمُسْلِمُ أَخُو الْمُسْلِمِ لا يَظْلِمُهُ وَلا يَخْذُلُهُ وَلا يَحْقِرُهُ',
    latin:
        'La tahasadu, wa la tabaghadhu, wa la tadabaru, wa kunu \'ibadallahi ikhwana. Al-muslimu akhul-muslimi la yazhlimuhu wa la yakhdzuluhu wa la yahqiruh.',
    translation:
        'Janganlah kalian saling dengki, saling membenci, dan saling membelakangi. Jadilah hamba-hamba Allah yang bersaudara. Seorang muslim adalah saudara bagi muslim lainnya; ia tidak menzaliminya, tidak menelantarkannya, dan tidak merendahkannya.',
    translationEn:
        'Do not envy one another, do not hate one another, and do not turn away from one another; be servants of Allah as brothers. A Muslim is the brother of a Muslim: he does not wrong him, forsake him, or despise him.',
    narrator: 'HR. Muslim no. 2564 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 2564 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Menjaga hati dari hasad serta menghormati kehormatan, jiwa, dan harta sesama muslim.',
    fiqhPointsEn: 'Protects social harmony by uprooting envy and safeguarding the honor, safety, and rights of every fellow believer.',
  ),
  HadithItem(
    id: 31,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 37,
    title: 'Luasnya Rahmat Allah dalam Melipatgandakan Kebaikan',
    titleEn: 'Allah Multiplies Good Deeds Out of Pure Mercy',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'فَمَنْ هَمَّ بِحَسَنَةٍ فَلَمْ يَعْمَلْهَا كَتَبَهَا اللَّهُ عِنْدَهُ حَسَنَةً كَامِلَةً، وَإِنْ هَمَّ بِهَا فَعَمِلَهَا كَتَبَهَا اللَّهُ عَشْرَ حَسَنَاتٍ إِلَى سَبْعِمِائَةِ ضِعْفٍ',
    latin:
        'Faman hamma bihasanatin falam ya\'malha katabahallahu \'indahu hasanatan kamilah, wa in hamma biha fa\'amilaha katabahallahu \'asyra hasanatin ila sab\'imi\'ati dhi\'f.',
    translation:
        'Barang siapa berniat melakukan satu kebaikan lalu belum sempat mengerjakannya, Allah mencatatnya sebagai satu kebaikan penuh. Jika ia mengerjakannya, Allah mencatat sepuluh hingga tujuh ratus kali lipat.',
    translationEn:
        'Whoever intends a good deed and does not carry it out, Allah records it as a complete good deed; if they carry it out, Allah records ten to seven hundred times its reward.',
    narrator: 'HR. Bukhari no. 6491 & Muslim no. 131 · Dari Ibnu Abbas RA',
    narratorEn: 'Sahih al-Bukhari 6491 & Sahih Muslim 131 · Narrated by Ibn Abbas (RA)',
    fiqhPoints: 'Menumbuhkan optimisme beribadah karena niat baik saja sudah bernilai pahala di sisi Allah.',
    fiqhPointsEn: 'Inspires hope and eagerness for good, since even a sincere intention to do good is rewarded.',
  ),
  HadithItem(
    id: 32,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 40,
    title: 'Jadilah di Dunia Seperti Orang Asing atau Musafir',
    titleEn: 'Be in This World Like a Stranger or Traveler',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic: 'كُنْ فِي الدُّنْيَا كَأَنَّكَ غَرِيبٌ أَوْ عَابِرُ سَبِيلٍ',
    latin: 'Kun fid-dunya ka\'annaka gharibun aw \'abiru sabil.',
    translation: 'Jadilah engkau di dunia ini seakan-akan orang asing atau seorang pengembara yang sedang melintas.',
    translationEn: 'Be in this world as though you were a stranger or a traveler passing through.',
    narrator: 'HR. Bukhari no. 6416 · Dari Ibnu Umar RA',
    narratorEn: 'Sahih al-Bukhari 6416 · Narrated by Ibn Umar (RA)',
    fiqhPoints: 'Mengingatkan agar tidak menunda amal saleh serta selalu menyiapkan bekal terbaik untuk akhirat.',
    fiqhPointsEn: 'Reminds believers not to procrastinate righteous deeds and to prepare steadily for the eternal home.',
  ),
  HadithItem(
    id: 33,
    collection: 'Arba\'in Nawawi',
    collectionEn: '40 Hadith Nawawi',
    number: 42,
    title: 'Hadits Qudsi: Luasnya Ampunan Allah bagi yang Memohon',
    titleEn: 'Hadith Qudsi: Vastness of Allah\'s Forgiveness',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'يَا ابْنَ آدَمَ إِنَّكَ مَا دَعَوْتَنِي وَرَجَوْتَنِي غَفَرْتُ لَكَ عَلَى مَا كَانَ فِيكَ وَلا أُبَالِي',
    latin: 'Yabna Adama innaka ma da\'awtani wa rajawtani ghafartu laka \'ala ma kana fika wa la ubali.',
    translation:
        'Wahai anak Adam, selama engkau berdoa kepada-Ku dan berharap kepada-Ku, niscaya Aku ampuni segala dosa yang ada padamu dan Aku tidak peduli seberapa besar dosa itu.',
    translationEn:
        'O son of Adam, so long as you call upon Me and hope in Me, I shall forgive you for whatever you have done, and I shall not mind.',
    narrator: 'HR. Tirmidzi no. 3540 · Dari Anas bin Malik RA (Hasan)',
    narratorEn: 'Jami\' at-Tirmidhi 3540 · Narrated by Anas ibn Malik (RA) (Hasan)',
    fiqhPoints: 'Pintu taubat dan ampunan Allah selalu terbuka luas bagi hamba yang kembali dengan tauhid dan istighfar.',
    fiqhPointsEn: 'The door of repentance and forgiveness remains ever open to anyone who turns back to Allah with sincere hope.',
  ),
  HadithItem(
    id: 34,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 5027,
    title: 'Sebaik-baik Manusia: Mempelajari dan Mengajarkan Al-Qur\'an',
    titleEn: 'The Best Among You Learn and Teach the Quran',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    latin: 'Khayrukum man ta\'allamal-Qur\'ana wa \'allamah.',
    translation: 'Sebaik-baik kalian adalah orang yang mempelajari Al-Qur\'an dan mengajarkannya.',
    translationEn: 'The best among you are those who learn the Quran and teach it.',
    narrator: 'HR. Bukhari no. 5027 · Dari Utsman bin Affan RA',
    narratorEn: 'Sahih al-Bukhari 5027 · Narrated by Uthman ibn Affan (RA)',
    fiqhPoints: 'Kemuliaan terbesar di sisi Allah diraih oleh orang yang akrab dengan Al-Qur\'an dan menyebarkan ilmunya.',
    fiqhPointsEn: 'Learning and sharing the Quran holds the highest rank of honor among believers.',
  ),
  HadithItem(
    id: 35,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 6464,
    title: 'Amal yang Paling Dicintai Allah: Kontinu Walau Sedikit',
    titleEn: 'Most Beloved Deeds to Allah: Consistent Even If Small',
    topic: 'Ibadah & Ilmu',
    topicEn: 'Worship & Knowledge',
    arabic: 'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
    latin: 'Ahabbul-a\'mali ilallahi adwamuha wa in qall.',
    translation: 'Amalan yang paling dicintai oleh Allah adalah amalan yang dilakukan terus-menerus (istiqamah) meskipun sedikit.',
    translationEn: 'The deeds most beloved to Allah are those done consistently, even if they are small.',
    narrator: 'HR. Bukhari no. 6464 & Muslim no. 783 · Dari Aisyah RA',
    narratorEn: 'Sahih al-Bukhari 6464 & Sahih Muslim 783 · Narrated by Aisha (RA)',
    fiqhPoints: 'Konsistensi ibadah harian jauh lebih utama daripada semangat sesaat yang cepat terputus.',
    fiqhPointsEn: 'Steady daily devotion outlasts bursts of enthusiasm that soon fade.',
  ),
  HadithItem(
    id: 36,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 2999,
    title: 'Menakjubkannya Urusan Orang Beriman: Syukur dan Sabar',
    titleEn: 'Wondrous Affair of the Believer: Gratitude and Patience',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic:
        'عَجَبًا لِأَمْرِ الْمُؤْمِنِ إِنَّ أَمْرَهُ كُلَّهُ خَيْرٌ، إِنْ أَصَابَتْهُ سَرَّاءُ شَكَرَ فَكَانَ خَيْرًا لَهُ، وَإِنْ أَصَابَتْهُ ضَرَّاءُ صَبَرَ فَكَانَ خَيْرًا لَهُ',
    latin:
        '\'Ajaban li-amril-mu\'mini inna amrahu kullahu khayr: in ashabathu sarra\'u syakara fakana khayran lah, wa in ashabathu dharra\'u shabara fakana khayran lah.',
    translation:
        'Sungguh menakjubkan urusan orang beriman, seluruh urusannya adalah kebaikan. Jika mendapat kelapangan ia bersyukur, maka itu baik baginya; jika ditimpa ujian ia bersabar, maka itu pun baik baginya.',
    translationEn:
        'Wondrous is the affair of the believer, for all of it is good: if ease comes, they give thanks and it is good for them; if hardship strikes, they endure patiently and it is good for them.',
    narrator: 'HR. Muslim no. 2999 · Dari Shuhaib Ar-Rumi RA',
    narratorEn: 'Sahih Muslim 2999 · Narrated by Suhayb ar-Rumi (RA)',
    fiqhPoints: 'Syukur saat lapang dan sabar saat sempit menjadikan seluruh fase kehidupan bernilai pahala.',
    fiqhPointsEn: 'Gratitude in ease and patience in trial turn every season of life into spiritual gain.',
  ),
  HadithItem(
    id: 37,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 6114,
    title: 'Orang Kuat adalah yang Mampu Mengendalikan Amarahnya',
    titleEn: 'True Strength Is Controlling Oneself in Anger',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
    latin: 'Laysasy-syadidu bish-shura\'ah, innamasy-syadidul-ladzi yamliku nafsahu \'indal-ghadhab.',
    translation: 'Orang yang kuat bukanlah yang pandai bergulat, melainkan orang yang mampu mengendalikan dirinya ketika marah.',
    translationEn: 'The strong person is not the one who overcomes others in wrestling; rather, the strong one is he who controls himself when angry.',
    narrator: 'HR. Bukhari no. 6114 & Muslim no. 2609 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 6114 & Sahih Muslim 2609 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Kekuatan sejati diukur dari ketenangan jiwa dan penguasaan emosi di saat terprovokasi.',
    fiqhPointsEn: 'True inner strength is measured by composure and self-restraint under provocation.',
  ),
  HadithItem(
    id: 38,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 69,
    title: 'Mudahkanlah dan Jangan Mempersulit, Berilah Kabar Gembira',
    titleEn: 'Make Things Easy, Not Difficult; Give Glad Tidings',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'يَسِّرُوا وَلا تُعَسِّرُوا، وَبَشِّرُوا وَلا تُنَفِّرُوا',
    latin: 'Yassiru wa la tu\'assiru, wa basysyiru wa la tunaffiru.',
    translation: 'Permudahlah dan jangan mempersulit, berilah kabar gembira dan jangan membuat orang lari menjauh.',
    translationEn: 'Make things easy and do not make them difficult; give glad tidings and do not drive people away.',
    narrator: 'HR. Bukhari no. 69 & Muslim no. 1734 · Dari Anas bin Malik RA',
    narratorEn: 'Sahih al-Bukhari 69 & Sahih Muslim 1734 · Narrated by Anas ibn Malik (RA)',
    fiqhPoints: 'Prinsip dakwah, pengajaran, dan kepemimpinan Islam dibangun di atas kelembutan dan harapan.',
    fiqhPointsEn: 'Islamic teaching, guidance, and leadership rest on gentleness, ease, and encouraging hope.',
  ),
  HadithItem(
    id: 39,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 2588,
    title: 'Sedekah Tidak Mengurangi Harta, Pemaaf Dimuliakan Allah',
    titleEn: 'Charity Never Decreases Wealth; Forgiveness Elevates Honor',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ، وَمَا زَادَ اللَّهُ عَبْدًا بِعَفْوٍ إِلا عِزًّا، وَمَا تَوَاضَعَ أَحَدٌ لِلَّهِ إِلا رَفَعَهُ اللَّهُ',
    latin: 'Ma naqashat shadaqatun min mal, wa ma zadallahu \'abdan bi-\'afwin illa \'izza, wa ma tawadha\'a ahadun lillahi illa rafa\'ahullah.',
    translation:
        'Sedekah tidak akan mengurangi harta. Tidaklah Allah menambah kepada seorang hamba yang pemaaf kecuali kemuliaan. Dan tidaklah seseorang merendahkan hati karena Allah kecuali Allah mengangkat derajatnya.',
    translationEn:
        'Charity does not decrease wealth; Allah increases a forgiving servant only in honor; and no one humbles themselves for Allah except that Allah elevates them.',
    narrator: 'HR. Muslim no. 2588 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 2588 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Tiga kunci keberkahan hidup: dermawan bersedekah, lapang dada memaafkan, dan tawadhu karena Allah.',
    fiqhPointsEn: 'Three keys to lasting blessing: generous charity, readiness to forgive, and sincere humility.',
  ),
  HadithItem(
    id: 40,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 5971,
    title: 'Kedudukan Mulia Ibu dan Berbakti kepada Orang Tua',
    titleEn: 'Honoring One\'s Mother and Caring for Parents',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'مَنْ أَحَقُّ النَّاسِ بِحُسْنِ صَحَابَتِي؟ قَالَ: أُمُّكَ. قَالَ: ثُمَّ مَنْ؟ قَالَ: ثُمَّ أُمُّكَ. قَالَ: ثُمَّ مَنْ؟ قَالَ: ثُمَّ أُمُّكَ. قَالَ: ثُمَّ مَنْ؟ قَالَ: ثُمَّ أَبُوكَ',
    latin: 'Man ahaqqun-nasi bihusni shahabati? Qala: Ummuk. Qala: Tsumma man? Qala: Tsumma ummuk. Qala: Tsumma man? Qala: Tsumma ummuk. Qala: Tsumma man? Qala: Tsumma abuk.',
    translation:
        'Siapakah orang yang paling berhak aku perlakukan dengan baik? Nabi menjawab: Ibumu. Lalu siapa? Beliau menjawab: Ibumu. Lalu siapa? Beliau menjawab: Ibumu. Lalu siapa? Beliau menjawab: Ayahmu.',
    translationEn:
        '"Who is most deserving of my good companionship?" He replied, "Your mother." "Then who?" "Your mother." "Then who?" "Your mother." "Then who?" "Then your father."',
    narrator: 'HR. Bukhari no. 5971 & Muslim no. 2548 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih al-Bukhari 5971 & Sahih Muslim 2548 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Birrul walidain adalah amal paling utama setelah tauhid dan salat, dengan prioritas penghormatan khusus kepada ibu.',
    fiqhPointsEn: 'Devotion to parents ranks among the highest acts of worship, with special honor given to one\'s mother.',
  ),
  HadithItem(
    id: 41,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 2564,
    title: 'Allah Melihat Hati dan Amal, Bukan Rupa dan Harta',
    titleEn: 'Allah Looks at Hearts and Deeds, Not Form or Wealth',
    topic: 'Niat & Ikhlas',
    topicEn: 'Intention & Sincerity',
    arabic: 'إِنَّ اللَّهَ لا يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ، وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ',
    latin: 'Innallaha la yanzhuru ila shuwarikum wa amwalikum, walakin yanzhuru ila qulubikum wa a\'malikum.',
    translation:
        'Sesungguhnya Allah tidak melihat kepada rupa dan harta kalian, tetapi Dia melihat kepada hati dan amal perbuatan kalian.',
    translationEn:
        'Indeed, Allah does not look at your outward appearance or your wealth, but rather He looks at your hearts and your deeds.',
    narrator: 'HR. Muslim no. 2564 · Dari Abu Hurairah RA',
    narratorEn: 'Sahih Muslim 2564 · Narrated by Abu Hurayrah (RA)',
    fiqhPoints: 'Kemuliaan manusia di hadapan Allah ditentukan oleh kebersihan hati, keikhlasan, dan amal salehnya.',
    fiqhPointsEn: 'True worth before Allah rests on purity of heart, sincerity, and righteous action.',
  ),
  HadithItem(
    id: 42,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 7405,
    title: 'Hadits Qudsi: Allah Sesuai Prasangka Hamba-Nya',
    titleEn: 'Hadith Qudsi: Allah Is as His Servant Thinks of Him',
    topic: 'Iman & Aqidah',
    topicEn: 'Faith & Creed',
    arabic: 'أَنَا عِنْدَ ظَنِّ عَبْدِي بِي، وَأَنَا مَعَهُ إِذَا ذَكَرَنِي',
    latin: 'Ana \'inda zhanni \'abdi bi, wa ana ma\'ahu idza dzakarani.',
    translation: 'Aku sesuai dengan prasangka baik hamba-Ku kepada-Ku, dan Aku bersamanya apabila ia mengingat-Ku.',
    translationEn: 'I am as My servant expects of Me, and I am with them whenever they remember Me.',
    narrator: 'HR. Bukhari no. 7405 & Muslim no. 2675 · Dari Abu Hurairah RA (Hadits Qudsi)',
    narratorEn: 'Sahih al-Bukhari 7405 & Sahih Muslim 2675 · Narrated by Abu Hurayrah (RA) (Hadith Qudsi)',
    fiqhPoints: 'Husnuzhan (berprasangka baik kepada Allah) dan memperbanyak dzikir menenangkan jiwa dalam segala keadaan.',
    fiqhPointsEn: 'Maintaining good expectations of Allah and constant remembrance brings reassurance in every circumstance.',
  ),
  HadithItem(
    id: 43,
    collection: 'Shahih Bukhari & Muslim',
    collectionEn: 'Sahih al-Bukhari & Muslim',
    number: 6094,
    title: 'Kejujuran Membimbing ke Kebaikan dan Surga',
    titleEn: 'Truthfulness Leads to Righteousness and Paradise',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'إِنَّ الصِّدْقَ يَهْدِي إِلَى الْبِرِّ، وَإِنَّ الْبِرَّ يَهْدِي إِلَى الْجَنَّةِ',
    latin: 'Innash-shidqa yahdi ilal-birr, wa innal-birra yahdi ilal-jannah.',
    translation: 'Sesungguhnya kejujuran itu membimbing kepada kebaikan, dan sesungguhnya kebaikan itu membimbing menuju surga.',
    translationEn: 'Indeed, truthfulness leads to righteousness, and righteousness leads to Paradise.',
    narrator: 'HR. Bukhari no. 6094 & Muslim no. 2607 · Dari Abdullah bin Mas\'ud RA',
    narratorEn: 'Sahih al-Bukhari 6094 & Sahih Muslim 2607 · Narrated by Abdullah ibn Mas\'ud (RA)',
    fiqhPoints: 'Membiasakan jujur dalam ucapan, janji, dan transaksi membentuk karakter shiddiq yang dicintai Allah.',
    fiqhPointsEn: 'Practicing honesty in speech, promises, and trade builds a trustworthy character beloved to Allah.',
  ),
  HadithItem(
    id: 44,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 121,
    title: 'Senyummu di Hadapan Saudaramu adalah Sedekah',
    titleEn: 'Smiling in the Face of Your Brother Is Charity',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
    latin: 'Tabassumuka fi wajhi akhika laka shadaqah.',
    translation: 'Senyummu di hadapan saudaramu bernilai sedekah bagimu.',
    translationEn: 'Your smiling in the face of your brother is an act of charity for you.',
    narrator: 'HR. Tirmidzi no. 1956 · Dari Abu Dzar RA (Hasan Gharib / Shahih)',
    narratorEn: 'Jami\' at-Tirmidhi 1956 · Narrated by Abu Dharr (RA) (Sahih)',
    fiqhPoints: 'Wajah ceria dan keramahan sederhana adalah sedekah termudah yang mempererat silaturahmi.',
    fiqhPointsEn: 'A warm smile and gentle manner are effortless acts of charity that strengthen kinship.',
  ),
  HadithItem(
    id: 45,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 173,
    title: 'Menunjukkan Jalan Kebaikan Mendapat Pahala Pelakunya',
    titleEn: 'Guiding Someone to Good Earns the Same Reward',
    topic: 'Muamalah & Ukhuwah',
    topicEn: 'Dealings & Brotherhood',
    arabic: 'مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ',
    latin: 'Man dalla \'ala khayrin falahu mitslu ajri fa\'ilih.',
    translation: 'Barang siapa menunjukkan kepada suatu kebaikan, maka ia memperoleh pahala seperti pahala orang yang mengerjakannya.',
    translationEn: 'Whoever guides someone to goodness will have a reward like that of the one who does it.',
    narrator: 'HR. Muslim no. 1893 · Dari Abu Mas\'ud Al-Anshari RA',
    narratorEn: 'Sahih Muslim 1893 · Narrated by Abu Mas\'ud al-Ansari (RA)',
    fiqhPoints: 'Berbagi ilmu, ayat, doa, dan pengingat baik membuka aliran pahala tanpa mengurangi pahala pelakunya.',
    fiqhPointsEn: 'Sharing beneficial reminders, verses, and duas multiplies reward without diminishing anyone else\'s.',
  ),
  HadithItem(
    id: 46,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 1465,
    title: 'Doa adalah Inti Ibadah',
    titleEn: 'Supplication Is the Essence of Worship',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
    latin: 'Ad-du\'a\'u huwal-\'ibadah.',
    translation: 'Doa itu sendiri adalah ibadah.',
    translationEn: 'Supplication is itself worship.',
    narrator: 'HR. Abu Dawud no. 1479 & Tirmidzi no. 2969 · Dari Nu\'man bin Basyir RA (Shahih)',
    narratorEn: 'Sunan Abi Dawud 1479 & Jami\' at-Tirmidhi 2969 · Narrated by An-Nu\'man ibn Bashir (RA)',
    fiqhPoints: 'Mengangkat tangan memohon kepada Allah merupakan bentuk pengakuan kefakiran hamba dan tauhid yang tulus.',
    fiqhPointsEn: 'Calling upon Allah expresses humble dependence on Him and is rewarded as worship in its own right.',
  ),
  HadithItem(
    id: 47,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 224,
    title: 'Kasih Sayang di Bumi Mendatangkan Rahmat dari Langit',
    titleEn: 'Show Mercy on Earth and Receive Mercy from Above',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'الرَّاحِمُونَ يَرْحَمُهُمُ الرَّحْمَنُ، ارْحَمُوا مَنْ فِي الأَرْضِ يَرْحَمْكُمْ مَنْ فِي السَّمَاءِ',
    latin: 'Ar-rahimuna yarhamuhumur-Rahman, irhamu man fil-ardhi yarhamkum man fis-sama\'.',
    translation:
        'Orang-orang yang penyayang akan disayangi oleh Ar-Rahman. Sayangilah makhluk yang ada di bumi, niscaya Zat yang di langit akan menyayangi kalian.',
    translationEn:
        'The merciful are shown mercy by the Most Merciful. Be merciful to those on earth, and the One above the heavens will have mercy upon you.',
    narrator: 'HR. Abu Dawud no. 4941 & Tirmidzi no. 1924 · Dari Abdullah bin Amr RA (Shahih)',
    narratorEn: 'Sunan Abi Dawud 4941 & Jami\' at-Tirmidhi 1924 · Narrated by Abdullah ibn Amr (RA)',
    fiqhPoints: 'Menebarkan kasih sayang kepada keluarga, sesama manusia, hingga hewan adalah kunci turunnya rahmat Allah.',
    fiqhPointsEn: 'Extending compassion to family, neighbors, and all living creatures invites Allah\'s mercy.',
  ),
  HadithItem(
    id: 48,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 628,
    title: 'Mukmin Paling Sempurna Imannya adalah yang Terbaik Akhlaknya',
    titleEn: 'Most Complete Faith Belongs to Those Best in Character',
    topic: 'Akhlak & Adab',
    topicEn: 'Character & Etiquette',
    arabic: 'أَكْمَلُ الْمُؤْمِنِينَ إِيمَانًا أَحْسَنُهُمْ خُلُقًا، وَخِيَارُكُمْ خِيَارُكُمْ لِنِسَائِهِمْ',
    latin: 'Akmalul-mu\'minina imanan ahsanuhum khuluqa, wa khiyarukum khiyarukum linisa\'ihim.',
    translation:
        'Orang mukmin yang paling sempurna imannya adalah yang paling baik akhlaknya. Dan sebaik-baik kalian adalah yang paling baik sikapnya kepada keluarganya.',
    translationEn:
        'The most complete of believers in faith are those with the best character, and the best of you are those best to their families.',
    narrator: 'HR. Tirmidzi no. 1162 & Ahmad · Dari Abu Hurairah RA (Hasan Shahih)',
    narratorEn: 'Jami\' at-Tirmidhi 1162 & Musnad Ahmad · Narrated by Abu Hurayrah (RA) (Hasan Sahih)',
    fiqhPoints: 'Ukuran kualitas iman paling jujur terlihat dari kelembutan akhlak di dalam rumah tangga.',
    fiqhPointsEn: 'The truest measure of faith is reflected in kindness and patience within one\'s own home.',
  ),
  HadithItem(
    id: 49,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 1870,
    title: 'Tiga Waktu Doa yang Tidak Tertolak',
    titleEn: 'Three Supplications That Are Never Rejected',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'ثَلاثُ دَعَوَاتٍ مُسْتَجَابَاتٌ لا شَكَّ فِيهِنَّ: دَعْوَةُ الْمَظْلُومِ، وَدَعْوَةُ الْمُسَافِرِ، وَدَعْوَةُ الْوَالِدِ عَلَى وَلَدِهِ',
    latin: 'Tsalatsu da\'awatin mustajabatun la syakka fihinna: da\'watul-mazhlumi, wa da\'watul-musafiri, wa da\'watul-walidi \'ala waladih.',
    translation:
        'Tiga doa yang mustajab tanpa diragukan lagi: doa orang yang terzalimi, doa musafir, dan doa orang tua untuk anaknya.',
    translationEn:
        'Three supplications are answered without doubt: the prayer of the oppressed, the prayer of the traveler, and the prayer of a parent for their child.',
    narrator: 'HR. Abu Dawud no. 1536 & Tirmidzi no. 1905 · Dari Abu Hurairah RA (Hasan)',
    narratorEn: 'Sunan Abi Dawud 1536 & Jami\' at-Tirmidhi 1905 · Narrated by Abu Hurayrah (RA) (Hasan)',
    fiqhPoints: 'Menjauhi kezaliman, memanfaatkan safar untuk berdoa, serta menjaga lisan orang tua agar selalu mendoakan kebaikan anak.',
    fiqhPointsEn: 'Avoid wronging anyone, use travel time for heartfelt prayer, and always speak words of blessing over children.',
  ),
  HadithItem(
    id: 50,
    collection: 'Riyadus Shalihin',
    collectionEn: 'Riyad as-Salihin',
    number: 1419,
    title: 'Perumpamaan Orang yang Berdzikir dan yang Tidak Berdzikir',
    titleEn: 'Likeness of One Who Remembers Allah and One Who Does Not',
    topic: 'Dzikir & Taubat',
    topicEn: 'Dhikr & Repentance',
    arabic: 'مَثَلُ الَّذِي يَذْكُرُ رَبَّهُ وَالَّذِي لا يَذْكُرُ رَبَّهُ مَثَلُ الْحَيِّ وَالْمَيِّتِ',
    latin: 'Matsalul-ladzi yadzkuru rabbahu wal-ladzi la yadzkuru rabbahu matsalul-hayyi wal-mayyit.',
    translation:
        'Perumpamaan orang yang mengingat Rabb-nya dan orang yang tidak mengingat Rabb-nya bagaikan orang yang hidup dan orang yang mati.',
    translationEn:
        'The likeness of the one who remembers their Lord and the one who does not is like that of the living and the dead.',
    narrator: 'HR. Bukhari no. 6407 · Dari Abu Musa Al-Asy\'ari RA',
    narratorEn: 'Sahih al-Bukhari 6407 · Narrated by Abu Musa al-Ash\'ari (RA)',
    fiqhPoints: 'Dzikir menghidupkan hati yang lelah, menjaga kesadaran rohani, dan menumbuhkan ketenangan batin.',
    fiqhPointsEn: 'Remembrance of Allah revives a weary heart, sustains spiritual awareness, and nurtures inner peace.',
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
