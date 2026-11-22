import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';

enum GuidedDzikirTime {
  pagi('Dzikir Pagi', 'Dibaca setelah Salat Subuh hingga matahari terbit atau waktu Dhuha.'),
  petang('Dzikir Petang', 'Dibaca setelah Salat Ashar hingga menjelang Maghrib atau malam hari.'),
  badaSalat('Wirid Ba\'da Salat', 'Dibaca setiap selesai menunaikan salat fardhu lima waktu.');

  final String label;
  final String timeHint;
  const GuidedDzikirTime(this.label, this.timeHint);
}

class GuidedDzikirItem {
  final String id;
  final GuidedDzikirTime time;
  final int order;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final int targetCount;
  final String source;
  final String virtue;

  const GuidedDzikirItem({
    required this.id,
    required this.time,
    required this.order,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.targetCount,
    required this.source,
    required this.virtue,
  });
}

const List<GuidedDzikirItem> guidedDzikirCatalog = [
  // ================= DZIKIR PAGI =================
  GuidedDzikirItem(
    id: 'pagi_ayat_kursi',
    time: GuidedDzikirTime.pagi,
    order: 1,
    title: 'Membaca Ayat Kursi',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    latin:
        'Allahu la ilaha illa Huwal Hayyul Qayyum, la ta\'khudzuhu sinatun wa la naum, lahu ma fis-samawati wa ma fil-ardh, man dzalladzi yasyfa\'u \'indahu illa bi-idznih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhithuna bisyay\'im min \'ilmihi illa bima sya\', wasi\'a kursiyyuhus-samawati wal-ardh, wa la ya\'uduhu hifzhuhuma, wa Huwal \'Aliyyul \'Azhim.',
    translation:
        'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan di bumi.',
    targetCount: 1,
    source: 'QS. Al-Baqarah: 255 · HR. An-Nasa\'i & Ath-Thabrani (Shahih)',
    virtue: 'Barang siapa membacanya di pagi hari, ia akan dilindungi dari gangguan jin hingga petang hari.',
  ),
  GuidedDzikirItem(
    id: 'pagi_ikhlas',
    time: GuidedDzikirTime.pagi,
    order: 2,
    title: 'Surah Al-Ikhlas',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
    latin: 'Qul Huwallahu Ahad. Allahush-Shamad. Lam yalid wa lam yulad. Wa lam yakul-lahu kufuwan ahad.',
    translation:
        'Katakanlah (Muhammad), Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu yang setara dengan Dia.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575 (Hasan Shahih)',
    virtue: 'Membaca Al-Ikhlas, Al-Falaq, dan An-Nas masing-masing 3 kali di waktu pagi dan petang mencukupi dari segala sesuatu.',
  ),
  GuidedDzikirItem(
    id: 'pagi_falaq',
    time: GuidedDzikirTime.pagi,
    order: 3,
    title: 'Surah Al-Falaq',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    latin:
        'Qul a\'udzu birabbil-falaq. Min syarri ma khalaq. Wa min syarri ghasiqin idza waqab. Wa min syarrin-naffatsati fil-\'uqad. Wa min syarri hasidin idza hasad.',
    translation:
        'Katakanlah, Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    virtue: 'Perlindungan kepada Allah dari segala kejahatan makhluk, kegelapan malam, sihir, dan kedengkian.',
  ),
  GuidedDzikirItem(
    id: 'pagi_nas',
    time: GuidedDzikirTime.pagi,
    order: 4,
    title: 'Surah An-Nas',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    latin:
        'Qul a\'udzu birabbin-nas. Malikin-nas. Ilahin-nas. Min syarril-waswasil-khannas. Alladzi yuwaswisu fi shudurin-nas. Minal-jinnati wan-nas.',
    translation:
        'Katakanlah, Aku berlindung kepada Tuhannya manusia, Raja manusia, sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari golongan jin dan manusia.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    virtue: 'Benteng penjagaan hati dari bisikan waswas setan dari golongan jin maupun manusia.',
  ),
  GuidedDzikirItem(
    id: 'pagi_asbahna_mulku',
    time: GuidedDzikirTime.pagi,
    order: 5,
    title: 'Dzikir Memasuki Waktu Pagi',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'Ashbahna wa ashbahal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation:
        'Kami telah memasuki waktu pagi dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada ilah yang berhak disembah kecuali Allah semata, tiada sekutu bagi-Nya.',
    targetCount: 1,
    source: 'HR. Muslim no. 2723',
    virtue: 'Memohon kebaikan hari ini dan berlindung dari keburukan hari ini serta hari sesudahnya.',
  ),
  GuidedDzikirItem(
    id: 'pagi_sayyidul_istighfar',
    time: GuidedDzikirTime.pagi,
    order: 6,
    title: 'Sayyidul Istighfar (Penghulu Istighfar)',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        'Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastatha\'tu, a\'udzu bika min syarri ma shana\'tu, abu\'u laka bini\'matika \'alayya, wa abu\'u laka bidzanbi faghfir li fa innahu la yaghfirudz-dzunuba illa Anta.',
    translation:
        'Ya Allah, Engkau adalah Rabbku, tidak ada ilah yang berhak disembah kecuali Engkau. Engkaulah yang menciptakanku dan aku adalah hamba-Mu. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, maka ampunilah aku.',
    targetCount: 1,
    source: 'HR. Bukhari no. 6306',
    virtue: 'Barang siapa membacanya dengan yakin di waktu pagi lalu wafat sebelum petang, maka ia termasuk penghuni surga.',
  ),
  GuidedDzikirItem(
    id: 'pagi_bika_asbahna',
    time: GuidedDzikirTime.pagi,
    order: 7,
    title: 'Tawakal Memulai Pagi',
    arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    latin: 'Allahumma bika ashbahna, wa bika amsayna, wa bika nahya, wa bika namutu, wa ilaykan-nusyur.',
    translation:
        'Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu pagi dan waktu petang. Dengan rahmat-Mu kami hidup dan kami mati, dan kepada-Mu kebangkitan.',
    targetCount: 1,
    source: 'HR. Tirmidzi no. 3391 & Abu Dawud no. 5068 (Shahih)',
    virtue: 'Meneguhkan kesadaran bahwa hidup, mati, dan kebangkitan seluruhnya berada dalam genggaman Allah.',
  ),
  GuidedDzikirItem(
    id: 'pagi_afiyah',
    time: GuidedDzikirTime.pagi,
    order: 8,
    title: 'Doa Keselamatan Agama, Dunia & Keluarga',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي',
    latin:
        'Allahumma inni as\'alukal-\'afwa wal-\'afiyah fid-dunya wal-akhirah. Allahumma inni as\'alukal-\'afwa wal-\'afiyah fi dini wa dunyaya wa ahli wa mali. Allahummastur \'awrati wa amin raw\'ati.',
    translation:
        'Ya Allah, sesungguhnya aku memohon ampunan dan keselamatan di dunia dan akhirat. Ya Allah, aku memohon ampunan dan keselamatan dalam agamaku, duniaku, keluargaku, dan hartaku.',
    targetCount: 1,
    source: 'HR. Abu Dawud no. 5074 & Ibnu Majah no. 3871 (Shahih)',
    virtue: 'Doa yang tidak pernah ditinggalkan Rasulullah SAW setiap pagi dan petang untuk penjagaan menyeluruh.',
  ),
  GuidedDzikirItem(
    id: 'pagi_bismillah_layadhurru',
    time: GuidedDzikirTime.pagi,
    order: 9,
    title: 'Perlindungan dari Bahaya Mendadak',
    arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latin: 'Bismillahilladzi la yadhurru ma\'asmihi syay\'un fil-ardhi wa la fis-sama\'i wa Huwas-Sami\'ul \'Alim.',
    translation:
        'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan di langit tidak akan berbahaya, dan Dialah Yang Maha Mendengar lagi Maha Mengetahui.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5088 & Tirmidzi no. 3388 (Shahih)',
    virtue: 'Barang siapa membacanya 3 kali di pagi dan petang hari, tidak ada sesuatu pun yang membahayakannya.',
  ),
  GuidedDzikirItem(
    id: 'pagi_radhitu',
    time: GuidedDzikirTime.pagi,
    order: 10,
    title: 'Ikrar Ridha kepada Allah, Islam & Rasul',
    arabic: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    latin: 'Radhitu billahi Rabba, wa bil-Islami dina, wa bi Muhammadin shallallahu \'alayhi wa sallama nabiyya.',
    translation: 'Aku ridha Allah sebagai Rabb, Islam sebagai agama, dan Muhammad SAW sebagai nabi.',
    targetCount: 3,
    source: 'HR. Ahmad IV/337 & Tirmidzi no. 3389 (Hasan)',
    virtue: 'Barang siapa membacanya 3 kali saat pagi dan petang, Allah pasti meridhai dirinya pada hari Kiamat.',
  ),
  GuidedDzikirItem(
    id: 'pagi_ya_hayyu',
    time: GuidedDzikirTime.pagi,
    order: 11,
    title: 'Memohon Perbaikan Seluruh Urusan',
    arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    latin: 'Ya Hayyu ya Qayyum birahmatika astaghits, ashlih li sya\'ni kullahu, wa la takilni ila nafsi tharfata \'ayn.',
    translation:
        'Wahai Rabb Yang Mahahidup, wahai Rabb Yang Berdiri Sendiri, dengan rahmat-Mu aku meminta pertolongan. Perbaikilah segala urusanku dan jangan diserahkan kepadaku walau sekejap mata.',
    targetCount: 1,
    source: 'HR. Al-Hakim I/545 & An-Nasa\'i dalam Amalul Yaum wal Lailah no. 575 (Hasan)',
    virtue: 'Wasiat Rasulullah SAW kepada Fathimah RA untuk ketenangan hati dan pertolongan dalam segala urusan.',
  ),
  GuidedDzikirItem(
    id: 'pagi_subhanallah_wabihamdih',
    time: GuidedDzikirTime.pagi,
    order: 12,
    title: 'Tasbih & Tahmid Pagi',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhanallahi wa bihamdih.',
    translation: 'Mahasuci Allah, aku memuji-Nya.',
    targetCount: 100,
    source: 'HR. Muslim no. 2692',
    virtue: 'Dihapuskan dosa-dosanya walaupun sebanyak buih di lautan dan tidak ada yang datang pada hari Kiamat dengan amalan lebih utama kecuali yang membaca semisalnya.',
  ),

  // ================= DZIKIR PETANG =================
  GuidedDzikirItem(
    id: 'petang_ayat_kursi',
    time: GuidedDzikirTime.petang,
    order: 1,
    title: 'Membaca Ayat Kursi',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    latin:
        'Allahu la ilaha illa Huwal Hayyul Qayyum, la ta\'khudzuhu sinatun wa la naum, lahu ma fis-samawati wa ma fil-ardh...',
    translation:
        'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur.',
    targetCount: 1,
    source: 'QS. Al-Baqarah: 255 · HR. An-Nasa\'i (Shahih)',
    virtue: 'Barang siapa membacanya di waktu petang, ia akan dilindungi dari gangguan jin hingga waktu pagi.',
  ),
  GuidedDzikirItem(
    id: 'petang_ikhlas',
    time: GuidedDzikirTime.petang,
    order: 2,
    title: 'Surah Al-Ikhlas',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
    latin: 'Qul Huwallahu Ahad. Allahush-Shamad. Lam yalid wa lam yulad. Wa lam yakul-lahu kufuwan ahad.',
    translation: 'Katakanlah (Muhammad), Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    virtue: 'Mencukupi perlindungan seorang mukmin dari segala keburukan di malam hari.',
  ),
  GuidedDzikirItem(
    id: 'petang_falaq',
    time: GuidedDzikirTime.petang,
    order: 3,
    title: 'Surah Al-Falaq',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    latin:
        'Qul a\'udzu birabbil-falaq. Min syarri ma khalaq. Wa min syarri ghasiqin idza waqab. Wa min syarrin-naffatsati fil-\'uqad. Wa min syarri hasidin idza hasad.',
    translation: 'Katakanlah, Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    virtue: 'Perlindungan dari kejahatan malam apabila telah gelap gulita.',
  ),
  GuidedDzikirItem(
    id: 'petang_nas',
    time: GuidedDzikirTime.petang,
    order: 4,
    title: 'Surah An-Nas',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    latin:
        'Qul a\'udzu birabbin-nas. Malikin-nas. Ilahin-nas. Min syarril-waswasil-khannas. Alladzi yuwaswisu fi shudurin-nas. Minal-jinnati wan-nas.',
    translation: 'Katakanlah, Aku berlindung kepada Tuhannya manusia, Raja manusia, sembahan manusia.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    virtue: 'Perlindungan dari bisikan waswas setan di waktu petang dan malam.',
  ),
  GuidedDzikirItem(
    id: 'petang_amsayna_mulku',
    time: GuidedDzikirTime.petang,
    order: 5,
    title: 'Dzikir Memasuki Waktu Petang',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'Amsayna wa amsal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation:
        'Kami telah memasuki waktu petang dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada ilah yang berhak disembah kecuali Allah semata.',
    targetCount: 1,
    source: 'HR. Muslim no. 2723',
    virtue: 'Memohon kebaikan malam ini dan berlindung dari keburukan malam ini serta malam sesudahnya.',
  ),
  GuidedDzikirItem(
    id: 'petang_sayyidul_istighfar',
    time: GuidedDzikirTime.petang,
    order: 6,
    title: 'Sayyidul Istighfar Petang',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        'Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastatha\'tu...',
    translation:
        'Ya Allah, Engkau adalah Rabbku, tidak ada ilah yang berhak disembah kecuali Engkau. Engkaulah yang menciptakanku dan aku adalah hamba-Mu.',
    targetCount: 1,
    source: 'HR. Bukhari no. 6306',
    virtue: 'Barang siapa membacanya dengan yakin di waktu petang lalu wafat pada malam itu, maka ia masuk surga.',
  ),
  GuidedDzikirItem(
    id: 'petang_bismillah_layadhurru',
    time: GuidedDzikirTime.petang,
    order: 7,
    title: 'Perlindungan Malam dari Bahaya',
    arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latin: 'Bismillahilladzi la yadhurru ma\'asmihi syay\'un fil-ardhi wa la fis-sama\'i wa Huwas-Sami\'ul \'Alim.',
    translation:
        'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan di langit tidak akan berbahaya, dan Dialah Yang Maha Mendengar lagi Maha Mengetahui.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5088 & Tirmidzi no. 3388',
    virtue: 'Perlindungan dari mudarat mendadak sepanjang malam hingga subuh.',
  ),
  GuidedDzikirItem(
    id: 'petang_audzu_bikalimatillah',
    time: GuidedDzikirTime.petang,
    order: 8,
    title: 'Perlindungan dengan Kalimat Allah yang Sempurna',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    latin: 'A\'udzu bikalimatillahit-tammati min syarri ma khalaq.',
    translation: 'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang diciptakan-Nya.',
    targetCount: 3,
    source: 'HR. Muslim no. 2709',
    virtue: 'Melindungi dari sengatan binatang berbisa dan gangguan buruk di malam hari.',
  ),
  GuidedDzikirItem(
    id: 'petang_subhanallah_wabihamdih',
    time: GuidedDzikirTime.petang,
    order: 9,
    title: 'Tasbih & Tahmid Petang',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhanallahi wa bihamdih.',
    translation: 'Mahasuci Allah, aku memuji-Nya.',
    targetCount: 100,
    source: 'HR. Muslim no. 2692',
    virtue: 'Penggugur dosa harian dan pemberat timbangan amal kebaikan.',
  ),

  // ================= WIRID BA'DA SALAT =================
  GuidedDzikirItem(
    id: 'salat_istighfar_salam',
    time: GuidedDzikirTime.badaSalat,
    order: 1,
    title: 'Istighfar 3x & Pujian السلام',
    arabic:
        'أَسْتَغْفِرُ اللَّهَ (٣×) اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    latin:
        'Astaghfirullah (3x). Allahumma Antas-Salam, wa minkas-salam, tabarakta ya Dzal-Jalali wal-Ikram.',
    translation:
        'Aku memohon ampun kepada Allah (3x). Ya Allah, Engkau pemberi keselamatan, dan dari-Mu keselamatan. Mahasuci Engkau, wahai Pemilik keagungan dan kemuliaan.',
    targetCount: 1,
    source: 'HR. Muslim no. 591',
    virtue: 'Bacaan pertama yang langsung diucapkan Rasulullah SAW begitu selesai salam dari salat fardhu.',
  ),
  GuidedDzikirItem(
    id: 'salat_tahlil_wahdah',
    time: GuidedDzikirTime.badaSalat,
    order: 2,
    title: 'Tahlil & Pengakuan Kuasa Allah',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
    latin:
        'La ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir. Allahumma la mani\'a lima a\'thayta, wa la mu\'thiya lima mana\'ta, wa la yanfa\'u dzal-jaddi minkal-jadd.',
    translation:
        'Tiada Tuhan yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Ya Allah, tidak ada yang dapat menghalangi apa yang Engkau berikan, dan tidak ada yang dapat memberi apa yang Engkau tahan.',
    targetCount: 1,
    source: 'HR. Bukhari no. 844 & Muslim no. 593',
    virtue: 'Menanamkan tauhid murni setiap selesai menghadap Allah dalam salat.',
  ),
  GuidedDzikirItem(
    id: 'salat_ainni_ala_dzikrika',
    time: GuidedDzikirTime.badaSalat,
    order: 3,
    title: 'Doa Mohon Pertolongan Berdzikir & Bersyukur',
    arabic: 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
    latin: 'Allahumma a\'inni \'ala dzikrika, wa syukrika, wa husni \'ibadatik.',
    translation: 'Ya Allah, tolonglah aku untuk senantiasa mengingat-Mu, bersyukur kepada-Mu, dan memperbagus ibadahku kepada-Mu.',
    targetCount: 1,
    source: 'HR. Abu Dawud no. 1522 & An-Nasa\'i no. 1303 (Shahih)',
    virtue: 'Wasiat cinta Rasulullah SAW kepada Mu\'adz bin Jabal RA agar jangan pernah ditinggalkan setiap selesai salat.',
  ),
  GuidedDzikirItem(
    id: 'salat_ayat_kursi',
    time: GuidedDzikirTime.badaSalat,
    order: 4,
    title: 'Ayat Kursi Ba\'da Salat',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...',
    latin: 'Allahu la ilaha illa Huwal Hayyul Qayyum, la ta\'khudzuhu sinatun wa la naum...',
    translation: 'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus makhluk-Nya.',
    targetCount: 1,
    source: 'HR. An-Nasa\'i dalam Amalul Yaum wal Lailah no. 100 (Shahih)',
    virtue: 'Barang siapa membaca Ayat Kursi setiap selesai salat fardhu, tidak ada yang menghalanginya masuk surga selain kematian.',
  ),
  GuidedDzikirItem(
    id: 'salat_tasbih_33',
    time: GuidedDzikirTime.badaSalat,
    order: 5,
    title: 'Tasbih (Subhanallah) 33 Kali',
    arabic: 'سُبْحَانَ اللَّهِ',
    latin: 'Subhanallah.',
    translation: 'Mahasuci Allah.',
    targetCount: 33,
    source: 'HR. Muslim no. 597',
    virtue: 'Bagian pertama dari rangkaian 99 dzikir ba\'da salat penggugur dosa.',
  ),
  GuidedDzikirItem(
    id: 'salat_tahmid_33',
    time: GuidedDzikirTime.badaSalat,
    order: 6,
    title: 'Tahmid (Alhamdulillah) 33 Kali',
    arabic: 'الْحَمْدُ لِلَّهِ',
    latin: 'Alhamdulillah.',
    translation: 'Segala puji bagi Allah.',
    targetCount: 33,
    source: 'HR. Muslim no. 597',
    virtue: 'Bagian kedua dari rangkaian 99 dzikir ba\'da salat.',
  ),
  GuidedDzikirItem(
    id: 'salat_takbir_33',
    time: GuidedDzikirTime.badaSalat,
    order: 7,
    title: 'Takbir (Allahu Akbar) 33 Kali',
    arabic: 'اللَّهُ أَكْبَرُ',
    latin: 'Allahu Akbar.',
    translation: 'Allah Mahabesar.',
    targetCount: 33,
    source: 'HR. Muslim no. 597',
    virtue: 'Bagian ketiga dari rangkaian 99 dzikir ba\'da salat.',
  ),
  GuidedDzikirItem(
    id: 'salat_penggenap_100',
    time: GuidedDzikirTime.badaSalat,
    order: 8,
    title: 'Tahlil Penggenap Seratus',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'La ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation:
        'Tidak ada Tuhan yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Mahakuasa atas segala sesuatu.',
    targetCount: 1,
    source: 'HR. Muslim no. 597',
    virtue: 'Menggenapkan 99 tasbih-tahmid-takbir menjadi 100; diampuni kesalahan-kesalahannya walau sebanyak buih di lautan.',
  ),
];

List<GuidedDzikirItem> guidedDzikirFor(GuidedDzikirTime time) =>
    guidedDzikirCatalog.where((e) => e.time == time).toList()..sort((a, b) => a.order.compareTo(b.order));

class GuidedDzikirRepository {
  static const _prefix = 'guided_dzikir_';
  final KeyValueStore _store;

  const GuidedDzikirRepository(this._store);

  String _dayKey(DateTime day) => '$_prefix${TrackerRepository.dayKey(day)}';

  Future<Map<String, int>> countsForDay(DateTime day) async {
    final raw = await _store.readJson(_dayKey(day));
    if (raw is! Map) return {};
    return {
      for (final e in raw.entries)
        if (e.key is String && e.value is num) e.key as String: (e.value as num).toInt(),
    };
  }

  Future<int> setCount(DateTime day, GuidedDzikirItem item, int count) async {
    final all = await countsForDay(day);
    final clamped = count.clamp(0, item.targetCount);
    all[item.id] = clamped;
    await _store.writeJson(_dayKey(day), all);
    return clamped;
  }

  Future<int> increment(DateTime day, GuidedDzikirItem item) async {
    final all = await countsForDay(day);
    final current = all[item.id] ?? 0;
    final next = (current + 1).clamp(0, item.targetCount);
    all[item.id] = next;
    await _store.writeJson(_dayKey(day), all);
    return next;
  }

  Future<void> resetSession(DateTime day, GuidedDzikirTime time) async {
    final all = await countsForDay(day);
    for (final item in guidedDzikirFor(time)) {
      all.remove(item.id);
    }
    await _store.writeJson(_dayKey(day), all);
  }
}
