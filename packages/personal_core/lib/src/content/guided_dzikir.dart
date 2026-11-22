import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';

enum GuidedDzikirTime {
  pagi(
    'Dzikir Pagi',
    'Dibaca setelah Salat Subuh hingga matahari terbit atau waktu Dhuha.',
    'Morning Dhikr',
    'Recited after Fajr prayer until sunrise or the forenoon Duha window.',
  ),
  petang(
    'Dzikir Petang',
    'Dibaca setelah Salat Ashar hingga menjelang Maghrib atau malam hari.',
    'Evening Dhikr',
    'Recited after Asr prayer until Maghrib or early evening.',
  ),
  badaSalat(
    'Wirid Ba\'da Salat',
    'Dibaca setiap selesai menunaikan salat fardhu lima waktu.',
    'After-Prayer Dhikr',
    'Recited immediately after completing each of the five obligatory prayers.',
  );

  final String label;
  final String timeHint;
  final String labelEn;
  final String timeHintEn;
  const GuidedDzikirTime(this.label, this.timeHint, this.labelEn, this.timeHintEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
  String timeHintFor(AppLanguage lang) => lang == AppLanguage.en ? timeHintEn : timeHint;
}

class GuidedDzikirItem {
  final String id;
  final GuidedDzikirTime time;
  final int order;
  final String title;
  final String? titleEn;
  final String arabic;
  final String latin;
  final String translation;
  final String? translationEn;
  final int targetCount;
  final String source;
  final String? sourceEn;
  final String virtue;
  final String? virtueEn;

  const GuidedDzikirItem({
    required this.id,
    required this.time,
    required this.order,
    required this.title,
    this.titleEn,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.translationEn,
    required this.targetCount,
    required this.source,
    this.sourceEn,
    required this.virtue,
    this.virtueEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
  String sourceFor(AppLanguage lang) =>
      lang == AppLanguage.en && (sourceEn?.isNotEmpty ?? false) ? sourceEn! : source;
  String virtueFor(AppLanguage lang) =>
      lang == AppLanguage.en && (virtueEn?.isNotEmpty ?? false) ? virtueEn! : virtue;
}

const List<GuidedDzikirItem> guidedDzikirCatalog = [
  // ================= DZIKIR PAGI =================
  GuidedDzikirItem(
    id: 'pagi_ayat_kursi',
    time: GuidedDzikirTime.pagi,
    order: 1,
    title: 'Membaca Ayat Kursi',
    titleEn: 'Reciting Ayat al-Kursi',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    latin:
        'Allahu la ilaha illa Huwal Hayyul Qayyum, la ta\'khudzuhu sinatun wa la naum, lahu ma fis-samawati wa ma fil-ardh, man dzalladzi yasyfa\'u \'indahu illa bi-idznih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhithuna bisyay\'im min \'ilmihi illa bima sya\', wasi\'a kursiyyuhus-samawati wal-ardh, wa la ya\'uduhu hifzhuhuma, wa Huwal \'Aliyyul \'Azhim.',
    translation:
        'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan di bumi.',
    translationEn:
        'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
    targetCount: 1,
    source: 'QS. Al-Baqarah: 255 · HR. An-Nasa\'i & Ath-Thabrani (Shahih)',
    sourceEn: 'Quran 2:255 · An-Nasa\'i & At-Tabarani (Sahih)',
    virtue: 'Barang siapa membacanya di pagi hari, ia akan dilindungi dari gangguan jin hingga petang hari.',
    virtueEn: 'Whoever recites it in the morning is protected from harmful jinn until evening.',
  ),
  GuidedDzikirItem(
    id: 'pagi_ikhlas',
    time: GuidedDzikirTime.pagi,
    order: 2,
    title: 'Surah Al-Ikhlas',
    titleEn: 'Surah Al-Ikhlas',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
    latin: 'Qul Huwallahu Ahad. Allahush-Shamad. Lam yalid wa lam yulad. Wa lam yakul-lahu kufuwan ahad.',
    translation:
        'Katakanlah (Muhammad), Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu yang setara dengan Dia.',
    translationEn:
        'Say, He is Allah, the One; Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575 (Hasan Shahih)',
    sourceEn: 'Sunan Abi Dawud 5082 & Jami\' at-Tirmidhi 3575 (Hasan Sahih)',
    virtue: 'Membaca Al-Ikhlas, Al-Falaq, dan An-Nas masing-masing 3 kali di waktu pagi dan petang mencukupi dari segala sesuatu.',
    virtueEn: 'Reciting Al-Ikhlas, Al-Falaq, and An-Nas three times each morning and evening suffices for protection from all harm.',
  ),
  GuidedDzikirItem(
    id: 'pagi_falaq',
    time: GuidedDzikirTime.pagi,
    order: 3,
    title: 'Surah Al-Falaq',
    titleEn: 'Surah Al-Falaq',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    latin:
        'Qul a\'udzu birabbil-falaq. Min syarri ma khalaq. Wa min syarri ghasiqin idza waqab. Wa min syarrin-naffatsati fil-\'uqad. Wa min syarri hasidin idza hasad.',
    translation:
        'Katakanlah, Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita.',
    translationEn:
        'Say, I seek refuge in the Lord of daybreak, from the evil of what He created, from the evil of darkness when it settles, from sorcery, and from the envier when he envies.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    sourceEn: 'Sunan Abi Dawud 5082 & Jami\' at-Tirmidhi 3575',
    virtue: 'Perlindungan kepada Allah dari segala kejahatan makhluk, kegelapan malam, sihir, dan kedengkian.',
    virtueEn: 'Seeking Allah\'s shelter from the harm of creation, nighttime danger, sorcery, and envy.',
  ),
  GuidedDzikirItem(
    id: 'pagi_nas',
    time: GuidedDzikirTime.pagi,
    order: 4,
    title: 'Surah An-Nas',
    titleEn: 'Surah An-Nas',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    latin:
        'Qul a\'udzu birabbin-nas. Malikin-nas. Ilahin-nas. Min syarril-waswasil-khannas. Alladzi yuwaswisu fi shudurin-nas. Minal-jinnati wan-nas.',
    translation:
        'Katakanlah, Aku berlindung kepada Tuhannya manusia, Raja manusia, sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari golongan jin dan manusia.',
    translationEn:
        'Say, I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer who whispers into the hearts of mankind, from among the jinn and mankind.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    sourceEn: 'Sunan Abi Dawud 5082 & Jami\' at-Tirmidhi 3575',
    virtue: 'Benteng penjagaan hati dari bisikan waswas setan dari golongan jin maupun manusia.',
    virtueEn: 'A spiritual shield protecting the heart from intrusive whispers of jinn and human tempters.',
  ),
  GuidedDzikirItem(
    id: 'pagi_asbahna_mulku',
    time: GuidedDzikirTime.pagi,
    order: 5,
    title: 'Dzikir Memasuki Waktu Pagi',
    titleEn: 'Remembrance Upon Entering the Morning',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'Ashbahna wa ashbahal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation:
        'Kami telah memasuki waktu pagi dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada ilah yang berhak disembah kecuali Allah semata, tiada sekutu bagi-Nya.',
    translationEn:
        'We have reached the morning and at this very time all sovereignty belongs to Allah, and all praise is for Allah. None has the right to be worshiped except Allah alone, without partner; to Him belong sovereignty and praise, and He is capable of all things.',
    targetCount: 1,
    source: 'HR. Muslim no. 2723',
    sourceEn: 'Sahih Muslim 2723',
    virtue: 'Memohon kebaikan hari ini dan berlindung dari keburukan hari ini serta hari sesudahnya.',
    virtueEn: 'Asking for the goodness of today and seeking refuge from the evil of today and what follows.',
  ),
  GuidedDzikirItem(
    id: 'pagi_sayyidul_istighfar',
    time: GuidedDzikirTime.pagi,
    order: 6,
    title: 'Sayyidul Istighfar (Penghulu Istighfar)',
    titleEn: 'Sayyidul Istighfar (Master Supplication of Forgiveness)',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        'Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastatha\'tu, a\'udzu bika min syarri ma shana\'tu, abu\'u laka bini\'matika \'alayya, wa abu\'u laka bidzanbi faghfir li fa innahu la yaghfirudz-dzunuba illa Anta.',
    translation:
        'Ya Allah, Engkau adalah Rabbku, tidak ada ilah yang berhak disembah kecuali Engkau. Engkaulah yang menciptakanku dan aku adalah hamba-Mu. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, maka ampunilah aku.',
    translationEn:
        'O Allah, You are my Lord; there is no deity worthy of worship except You. You created me and I am Your servant, upholding Your covenant and promise as best I can. I seek refuge in You from the evil I have done. I acknowledge Your blessings upon me and confess my sin, so forgive me, for none forgives sins except You.',
    targetCount: 1,
    source: 'HR. Bukhari no. 6306',
    sourceEn: 'Sahih al-Bukhari 6306',
    virtue: 'Barang siapa membacanya dengan yakin di waktu pagi lalu wafat sebelum petang, maka ia termasuk penghuni surga.',
    virtueEn: 'Whoever recites it with conviction in the morning and passes away before evening enters Paradise.',
  ),
  GuidedDzikirItem(
    id: 'pagi_bika_asbahna',
    time: GuidedDzikirTime.pagi,
    order: 7,
    title: 'Tawakal Memulai Pagi',
    titleEn: 'Trust in Allah at the Start of the Morning',
    arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    latin: 'Allahumma bika ashbahna, wa bika amsayna, wa bika nahya, wa bika namutu, wa ilaykan-nusyur.',
    translation:
        'Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu pagi dan waktu petang. Dengan rahmat-Mu kami hidup dan kami mati, dan kepada-Mu kebangkitan.',
    translationEn:
        'O Allah, by Your leave we have reached the morning and by Your leave we reach the evening, by Your leave we live and die, and unto You is our resurrection.',
    targetCount: 1,
    source: 'HR. Tirmidzi no. 3391 & Abu Dawud no. 5068 (Shahih)',
    sourceEn: 'Jami\' at-Tirmidhi 3391 & Sunan Abi Dawud 5068 (Sahih)',
    virtue: 'Meneguhkan kesadaran bahwa hidup, mati, dan kebangkitan seluruhnya berada dalam genggaman Allah.',
    virtueEn: 'Renews awareness that life, death, and resurrection rest entirely in Allah\'s care.',
  ),
  GuidedDzikirItem(
    id: 'pagi_afiyah',
    time: GuidedDzikirTime.pagi,
    order: 8,
    title: 'Doa Keselamatan Agama, Dunia & Keluarga',
    titleEn: 'Supplication for Well-Being in Faith, Life & Family',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي',
    latin:
        'Allahumma inni as\'alukal-\'afwa wal-\'afiyah fid-dunya wal-akhirah. Allahumma inni as\'alukal-\'afwa wal-\'afiyah fi dini wa dunyaya wa ahli wa mali. Allahummastur \'awrati wa amin raw\'ati.',
    translation:
        'Ya Allah, sesungguhnya aku memohon ampunan dan keselamatan di dunia dan akhirat. Ya Allah, aku memohon ampunan dan keselamatan dalam agamaku, duniaku, keluargaku, dan hartaku.',
    translationEn:
        'O Allah, I ask You for pardon and well-being in this life and the next. O Allah, I ask You for pardon and well-being in my religion, my worldly affairs, my family, and my wealth. O Allah, conceal my faults and calm my fears.',
    targetCount: 1,
    source: 'HR. Abu Dawud no. 5074 & Ibnu Majah no. 3871 (Shahih)',
    sourceEn: 'Sunan Abi Dawud 5074 & Sunan Ibn Majah 3871 (Sahih)',
    virtue: 'Doa yang tidak pernah ditinggalkan Rasulullah SAW setiap pagi dan petang untuk penjagaan menyeluruh.',
    virtueEn: 'A comprehensive supplication the Prophet (peace be upon him) never missed each morning and evening.',
  ),
  GuidedDzikirItem(
    id: 'pagi_bismillah_layadhurru',
    time: GuidedDzikirTime.pagi,
    order: 9,
    title: 'Perlindungan dari Bahaya Mendadak',
    titleEn: 'Protection from Sudden Harm',
    arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latin: 'Bismillahilladzi la yadhurru ma\'asmihi syay\'un fil-ardhi wa la fis-sama\'i wa Huwas-Sami\'ul \'Alim.',
    translation:
        'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan di langit tidak akan berbahaya, dan Dialah Yang Maha Mendengar lagi Maha Mengetahui.',
    translationEn:
        'In the name of Allah, with whose name nothing on earth or in the heavens can cause harm, and He is the All-Hearing, the All-Knowing.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5088 & Tirmidzi no. 3388 (Shahih)',
    sourceEn: 'Sunan Abi Dawud 5088 & Jami\' at-Tirmidhi 3388 (Sahih)',
    virtue: 'Barang siapa membacanya 3 kali di pagi dan petang hari, tidak ada sesuatu pun yang membahayakannya.',
    virtueEn: 'Whoever recites it three times each morning and evening will be safeguarded from sudden harm.',
  ),
  GuidedDzikirItem(
    id: 'pagi_radhitu',
    time: GuidedDzikirTime.pagi,
    order: 10,
    title: 'Ikrar Ridha kepada Allah, Islam & Rasul',
    titleEn: 'Declaration of Contentment with Allah, Islam & the Prophet',
    arabic: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    latin: 'Radhitu billahi Rabba, wa bil-Islami dina, wa bi Muhammadin shallallahu \'alayhi wa sallama nabiyya.',
    translation: 'Aku ridha Allah sebagai Rabb, Islam sebagai agama, dan Muhammad SAW sebagai nabi.',
    translationEn: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (peace be upon him) as my Prophet.',
    targetCount: 3,
    source: 'HR. Ahmad IV/337 & Tirmidzi no. 3389 (Hasan)',
    sourceEn: 'Musnad Ahmad 4/337 & Jami\' at-Tirmidhi 3389 (Hasan)',
    virtue: 'Barang siapa membacanya 3 kali saat pagi dan petang, Allah pasti meridhai dirinya pada hari Kiamat.',
    virtueEn: 'Whoever recites it three times morning and evening has a promise that Allah will please them on the Day of Judgment.',
  ),
  GuidedDzikirItem(
    id: 'pagi_ya_hayyu',
    time: GuidedDzikirTime.pagi,
    order: 11,
    title: 'Memohon Perbaikan Seluruh Urusan',
    titleEn: 'Seeking Allah\'s Help in All Affairs',
    arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    latin: 'Ya Hayyu ya Qayyum birahmatika astaghits, ashlih li sya\'ni kullahu, wa la takilni ila nafsi tharfata \'ayn.',
    translation:
        'Wahai Rabb Yang Mahahidup, wahai Rabb Yang Berdiri Sendiri, dengan rahmat-Mu aku meminta pertolongan. Perbaikilah segala urusanku dan jangan diserahkan kepadaku walau sekejap mata.',
    translationEn:
        'O Ever-Living, O Sustainer, in Your mercy I seek relief. Set right all of my affairs and do not leave me to myself even for the blink of an eye.',
    targetCount: 1,
    source: 'HR. Al-Hakim I/545 & An-Nasa\'i dalam Amalul Yaum wal Lailah no. 575 (Hasan)',
    sourceEn: 'Al-Hakim 1/545 & An-Nasa\'i, Amal al-Yawm wal-Laylah 575 (Hasan)',
    virtue: 'Wasiat Rasulullah SAW kepada Fathimah RA untuk ketenangan hati dan pertolongan dalam segala urusan.',
    virtueEn: 'Taught by the Prophet (peace be upon him) to his daughter Fatimah (RA) for serenity and divine support.',
  ),
  GuidedDzikirItem(
    id: 'pagi_subhanallah_wabihamdih',
    time: GuidedDzikirTime.pagi,
    order: 12,
    title: 'Tasbih & Tahmid Pagi',
    titleEn: 'Morning Glorification & Praise',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhanallahi wa bihamdih.',
    translation: 'Mahasuci Allah, aku memuji-Nya.',
    translationEn: 'Glory be to Allah and praise be to Him.',
    targetCount: 100,
    source: 'HR. Muslim no. 2692',
    sourceEn: 'Sahih Muslim 2692',
    virtue: 'Dihapuskan dosa-dosanya walaupun sebanyak buih di lautan dan tidak ada yang datang pada hari Kiamat dengan amalan lebih utama kecuali yang membaca semisalnya.',
    virtueEn: 'Sins are forgiven even if like the foam of the sea, and none will arrive on the Day of Judgment with a greater deed except one who recited similarly or more.',
  ),

  // ================= DZIKIR PETANG =================
  GuidedDzikirItem(
    id: 'petang_ayat_kursi',
    time: GuidedDzikirTime.petang,
    order: 1,
    title: 'Membaca Ayat Kursi',
    titleEn: 'Reciting Ayat al-Kursi',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    latin:
        'Allahu la ilaha illa Huwal Hayyul Qayyum, la ta\'khudzuhu sinatun wa la naum, lahu ma fis-samawati wa ma fil-ardh...',
    translation:
        'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur.',
    translationEn:
        'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep.',
    targetCount: 1,
    source: 'QS. Al-Baqarah: 255 · HR. An-Nasa\'i (Shahih)',
    sourceEn: 'Quran 2:255 · An-Nasa\'i (Sahih)',
    virtue: 'Barang siapa membacanya di waktu petang, ia akan dilindungi dari gangguan jin hingga waktu pagi.',
    virtueEn: 'Whoever recites it in the evening is protected from harmful jinn until morning.',
  ),
  GuidedDzikirItem(
    id: 'petang_ikhlas',
    time: GuidedDzikirTime.petang,
    order: 2,
    title: 'Surah Al-Ikhlas',
    titleEn: 'Surah Al-Ikhlas',
    arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
    latin: 'Qul Huwallahu Ahad. Allahush-Shamad. Lam yalid wa lam yulad. Wa lam yakul-lahu kufuwan ahad.',
    translation: 'Katakanlah (Muhammad), Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu.',
    translationEn: 'Say, He is Allah, the One; Allah, the Eternal Refuge. He neither begets nor is born.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    sourceEn: 'Sunan Abi Dawud 5082 & Jami\' at-Tirmidhi 3575',
    virtue: 'Mencukupi perlindungan seorang mukmin dari segala keburukan di malam hari.',
    virtueEn: 'Sufficient spiritual protection for a believer throughout the night.',
  ),
  GuidedDzikirItem(
    id: 'petang_falaq',
    time: GuidedDzikirTime.petang,
    order: 3,
    title: 'Surah Al-Falaq',
    titleEn: 'Surah Al-Falaq',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    latin:
        'Qul a\'udzu birabbil-falaq. Min syarri ma khalaq. Wa min syarri ghasiqin idza waqab. Wa min syarrin-naffatsati fil-\'uqad. Wa min syarri hasidin idza hasad.',
    translation: 'Katakanlah, Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan.',
    translationEn: 'Say, I seek refuge in the Lord of daybreak, from the evil of what He created and the darkness when it settles.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    sourceEn: 'Sunan Abi Dawud 5082 & Jami\' at-Tirmidhi 3575',
    virtue: 'Perlindungan dari kejahatan malam apabila telah gelap gulita.',
    virtueEn: 'Protection from the harms of the night once darkness settles.',
  ),
  GuidedDzikirItem(
    id: 'petang_nas',
    time: GuidedDzikirTime.petang,
    order: 4,
    title: 'Surah An-Nas',
    titleEn: 'Surah An-Nas',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    latin:
        'Qul a\'udzu birabbin-nas. Malikin-nas. Ilahin-nas. Min syarril-waswasil-khannas. Alladzi yuwaswisu fi shudurin-nas. Minal-jinnati wan-nas.',
    translation: 'Katakanlah, Aku berlindung kepada Tuhannya manusia, Raja manusia, sembahan manusia.',
    translationEn: 'Say, I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
    sourceEn: 'Sunan Abi Dawud 5082 & Jami\' at-Tirmidhi 3575',
    virtue: 'Perlindungan dari bisikan waswas setan di waktu petang dan malam.',
    virtueEn: 'Safeguards the heart from subtle temptations throughout the evening and night.',
  ),
  GuidedDzikirItem(
    id: 'petang_amsayna_mulku',
    time: GuidedDzikirTime.petang,
    order: 5,
    title: 'Dzikir Memasuki Waktu Petang',
    titleEn: 'Remembrance Upon Entering the Evening',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'Amsayna wa amsal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation:
        'Kami telah memasuki waktu petang dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada ilah yang berhak disembah kecuali Allah semata.',
    translationEn:
        'We have reached the evening and at this very time all sovereignty belongs to Allah, and all praise is for Allah. None has the right to be worshiped except Allah alone.',
    targetCount: 1,
    source: 'HR. Muslim no. 2723',
    sourceEn: 'Sahih Muslim 2723',
    virtue: 'Memohon kebaikan malam ini dan berlindung dari keburukan malam ini serta malam sesudahnya.',
    virtueEn: 'Asking for the goodness of tonight and seeking refuge from the evil of tonight and the nights ahead.',
  ),
  GuidedDzikirItem(
    id: 'petang_sayyidul_istighfar',
    time: GuidedDzikirTime.petang,
    order: 6,
    title: 'Sayyidul Istighfar Petang',
    titleEn: 'Evening Sayyidul Istighfar',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        'Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastatha\'tu...',
    translation:
        'Ya Allah, Engkau adalah Rabbku, tidak ada ilah yang berhak disembah kecuali Engkau. Engkaulah yang menciptakanku dan aku adalah hamba-Mu.',
    translationEn:
        'O Allah, You are my Lord; none has the right to be worshiped except You. You created me and I am Your servant... forgive me, for none forgives sins except You.',
    targetCount: 1,
    source: 'HR. Bukhari no. 6306',
    sourceEn: 'Sahih al-Bukhari 6306',
    virtue: 'Barang siapa membacanya dengan yakin di waktu petang lalu wafat pada malam itu, maka ia masuk surga.',
    virtueEn: 'Whoever recites it with certainty in the evening and passes away that night enters Paradise.',
  ),
  GuidedDzikirItem(
    id: 'petang_bismillah_layadhurru',
    time: GuidedDzikirTime.petang,
    order: 7,
    title: 'Perlindungan Malam dari Bahaya',
    titleEn: 'Evening Protection from Harm',
    arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latin: 'Bismillahilladzi la yadhurru ma\'asmihi syay\'un fil-ardhi wa la fis-sama\'i wa Huwas-Sami\'ul \'Alim.',
    translation:
        'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan di langit tidak akan berbahaya, dan Dialah Yang Maha Mendengar lagi Maha Mengetahui.',
    translationEn:
        'In the name of Allah, with whose name nothing on earth or in the heavens can cause harm, and He is the All-Hearing, the All-Knowing.',
    targetCount: 3,
    source: 'HR. Abu Dawud no. 5088 & Tirmidzi no. 3388',
    sourceEn: 'Sunan Abi Dawud 5088 & Jami\' at-Tirmidhi 3388',
    virtue: 'Perlindungan dari mudarat mendadak sepanjang malam hingga subuh.',
    virtueEn: 'Protection from sudden harm throughout the night until Fajr.',
  ),
  GuidedDzikirItem(
    id: 'petang_audzu_bikalimatillah',
    time: GuidedDzikirTime.petang,
    order: 8,
    title: 'Perlindungan dengan Kalimat Allah yang Sempurna',
    titleEn: 'Seeking Refuge in Allah\'s Perfect Words',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    latin: 'A\'udzu bikalimatillahit-tammati min syarri ma khalaq.',
    translation: 'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang diciptakan-Nya.',
    translationEn: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    targetCount: 3,
    source: 'HR. Muslim no. 2709',
    sourceEn: 'Sahih Muslim 2709',
    virtue: 'Melindungi dari sengatan binatang berbisa dan gangguan buruk di malam hari.',
    virtueEn: 'Shields against venomous stings and nighttime harm.',
  ),
  GuidedDzikirItem(
    id: 'petang_subhanallah_wabihamdih',
    time: GuidedDzikirTime.petang,
    order: 9,
    title: 'Tasbih & Tahmid Petang',
    titleEn: 'Evening Glorification & Praise',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhanallahi wa bihamdih.',
    translation: 'Mahasuci Allah, aku memuji-Nya.',
    translationEn: 'Glory be to Allah and praise be to Him.',
    targetCount: 100,
    source: 'HR. Muslim no. 2692',
    sourceEn: 'Sahih Muslim 2692',
    virtue: 'Penggugur dosa harian dan pemberat timbangan amal kebaikan.',
    virtueEn: 'Erases daily shortcomings and weighs heavily on the scale of good deeds.',
  ),

  // ================= WIRID BA'DA SALAT =================
  GuidedDzikirItem(
    id: 'salat_istighfar_salam',
    time: GuidedDzikirTime.badaSalat,
    order: 1,
    title: 'Istighfar 3x & Pujian السلام',
    titleEn: 'Istighfar (3x) & Praise of As-Salam',
    arabic:
        'أَسْتَغْفِرُ اللَّهَ (٣×) اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    latin:
        'Astaghfirullah (3x). Allahumma Antas-Salam, wa minkas-salam, tabarakta ya Dzal-Jalali wal-Ikram.',
    translation:
        'Aku memohon ampun kepada Allah (3x). Ya Allah, Engkau pemberi keselamatan, dan dari-Mu keselamatan. Mahasuci Engkau, wahai Pemilik keagungan dan kemuliaan.',
    translationEn:
        'I seek the forgiveness of Allah (3x). O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of majesty and honor.',
    targetCount: 1,
    source: 'HR. Muslim no. 591',
    sourceEn: 'Sahih Muslim 591',
    virtue: 'Bacaan pertama yang langsung diucapkan Rasulullah SAW begitu selesai salam dari salat fardhu.',
    virtueEn: 'The very first words the Prophet (peace be upon him) uttered upon concluding obligatory prayer.',
  ),
  GuidedDzikirItem(
    id: 'salat_tahlil_wahdah',
    time: GuidedDzikirTime.badaSalat,
    order: 2,
    title: 'Tahlil & Pengakuan Kuasa Allah',
    titleEn: 'Tahlil & Affirmation of Allah\'s Decree',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
    latin:
        'La ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir. Allahumma la mani\'a lima a\'thayta, wa la mu\'thiya lima mana\'ta, wa la yanfa\'u dzal-jaddi minkal-jadd.',
    translation:
        'Tiada Tuhan yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Ya Allah, tidak ada yang dapat menghalangi apa yang Engkau berikan, dan tidak ada yang dapat memberi apa yang Engkau tahan.',
    translationEn:
        'There is no deity worthy of worship except Allah alone, without partner. O Allah, none can withhold what You give, none can give what You withhold, and worldly fortune avails no one against Your decree.',
    targetCount: 1,
    source: 'HR. Bukhari no. 844 & Muslim no. 593',
    sourceEn: 'Sahih al-Bukhari 844 & Sahih Muslim 593',
    virtue: 'Menanamkan tauhid murni setiap selesai menghadap Allah dalam salat.',
    virtueEn: 'Anchors pure monotheism immediately after standing before Allah in prayer.',
  ),
  GuidedDzikirItem(
    id: 'salat_ainni_ala_dzikrika',
    time: GuidedDzikirTime.badaSalat,
    order: 3,
    title: 'Doa Mohon Pertolongan Berdzikir & Bersyukur',
    titleEn: 'Supplication for Help in Remembrance & Gratitude',
    arabic: 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
    latin: 'Allahumma a\'inni \'ala dzikrika, wa syukrika, wa husni \'ibadatik.',
    translation: 'Ya Allah, tolonglah aku untuk senantiasa mengingat-Mu, bersyukur kepada-Mu, dan memperbagus ibadahku kepada-Mu.',
    translationEn: 'O Allah, help me to remember You, to give thanks to You, and to worship You in the best manner.',
    targetCount: 1,
    source: 'HR. Abu Dawud no. 1522 & An-Nasa\'i no. 1303 (Shahih)',
    sourceEn: 'Sunan Abi Dawud 1522 & Sunan an-Nasa\'i 1303 (Sahih)',
    virtue: 'Wasiat cinta Rasulullah SAW kepada Mu\'adz bin Jabal RA agar jangan pernah ditinggalkan setiap selesai salat.',
    virtueEn: 'Loving counsel of the Prophet (peace be upon him) to Mu\'adh ibn Jabal (RA) never to omit after any prayer.',
  ),
  GuidedDzikirItem(
    id: 'salat_ayat_kursi',
    time: GuidedDzikirTime.badaSalat,
    order: 4,
    title: 'Ayat Kursi Ba\'da Salat',
    titleEn: 'Ayat al-Kursi After Prayer',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...',
    latin: 'Allahu la ilaha illa Huwal Hayyul Qayyum, la ta\'khudzuhu sinatun wa la naum...',
    translation: 'Allah, tidak ada Tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus makhluk-Nya.',
    translationEn: 'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence.',
    targetCount: 1,
    source: 'HR. An-Nasa\'i dalam Amalul Yaum wal Lailah no. 100 (Shahih)',
    sourceEn: 'An-Nasa\'i, Amal al-Yawm wal-Laylah 100 (Sahih)',
    virtue: 'Barang siapa membaca Ayat Kursi setiap selesai salat fardhu, tidak ada yang menghalanginya masuk surga selain kematian.',
    virtueEn: 'Whoever recites Ayat al-Kursi after every obligatory prayer has nothing standing between them and Paradise except death.',
  ),
  GuidedDzikirItem(
    id: 'salat_tasbih_33',
    time: GuidedDzikirTime.badaSalat,
    order: 5,
    title: 'Tasbih (Subhanallah) 33 Kali',
    titleEn: 'Tasbih (Subhanallah) 33 Times',
    arabic: 'سُبْحَانَ اللَّهِ',
    latin: 'Subhanallah.',
    translation: 'Mahasuci Allah.',
    translationEn: 'Glory be to Allah.',
    targetCount: 33,
    source: 'HR. Muslim no. 597',
    sourceEn: 'Sahih Muslim 597',
    virtue: 'Bagian pertama dari rangkaian 99 dzikir ba\'da salat penggugur dosa.',
    virtueEn: 'First part of the 99 post-prayer remembrances that expiate sins.',
  ),
  GuidedDzikirItem(
    id: 'salat_tahmid_33',
    time: GuidedDzikirTime.badaSalat,
    order: 6,
    title: 'Tahmid (Alhamdulillah) 33 Kali',
    titleEn: 'Tahmid (Alhamdulillah) 33 Times',
    arabic: 'الْحَمْدُ لِلَّهِ',
    latin: 'Alhamdulillah.',
    translation: 'Segala puji bagi Allah.',
    translationEn: 'All praise is due to Allah.',
    targetCount: 33,
    source: 'HR. Muslim no. 597',
    sourceEn: 'Sahih Muslim 597',
    virtue: 'Bagian kedua dari rangkaian 99 dzikir ba\'da salat.',
    virtueEn: 'Second part of the 99 post-prayer remembrances.',
  ),
  GuidedDzikirItem(
    id: 'salat_takbir_33',
    time: GuidedDzikirTime.badaSalat,
    order: 7,
    title: 'Takbir (Allahu Akbar) 33 Kali',
    titleEn: 'Takbir (Allahu Akbar) 33 Times',
    arabic: 'اللَّهُ أَكْبَرُ',
    latin: 'Allahu Akbar.',
    translation: 'Allah Mahabesar.',
    translationEn: 'Allah is the Greatest.',
    targetCount: 33,
    source: 'HR. Muslim no. 597',
    sourceEn: 'Sahih Muslim 597',
    virtue: 'Bagian ketiga dari rangkaian 99 dzikir ba\'da salat.',
    virtueEn: 'Third part of the 99 post-prayer remembrances.',
  ),
  GuidedDzikirItem(
    id: 'salat_penggenap_100',
    time: GuidedDzikirTime.badaSalat,
    order: 8,
    title: 'Tahlil Penggenap Seratus',
    titleEn: 'Completing the Hundred with Tahlil',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        'La ilaha illallahu wahdahu la syarika lah, lahul mulku wa lahul hamdu wa Huwa \'ala kulli syay\'in Qadir.',
    translation:
        'Tidak ada Tuhan yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Mahakuasa atas segala sesuatu.',
    translationEn:
        'There is no deity worthy of worship except Allah alone, without partner. To Him belong sovereignty and praise, and He is capable of all things.',
    targetCount: 1,
    source: 'HR. Muslim no. 597',
    sourceEn: 'Sahih Muslim 597',
    virtue: 'Menggenapkan 99 tasbih-tahmid-takbir menjadi 100; diampuni kesalahan-kesalahannya walau sebanyak buih di lautan.',
    virtueEn: 'Completes the count of 99 to 100; sins are forgiven even if abundant like the foam of the sea.',
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
