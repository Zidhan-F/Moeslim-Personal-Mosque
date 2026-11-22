import 'package:shared_prayer/shared_prayer.dart';

enum ShareCardThemeStyle {
  emeraldGold('Zamrud & Emas Moeslim', 'Moeslim Emerald & Gold'),
  creamManuscript('Manuskrip Krem Hangat', 'Warm Cream Manuscript'),
  midnightDeep('Malam Khusyuk', 'Quiet Midnight'),
  sandDhuha('Pasir Dhuha', 'Morning Duha Sand'),
  tealLagoon('Teal Samudra', 'Ocean Teal'),
  roseSakinah('Mawar Sakinah', 'Sakinah Rose'),
  pearlWhite('Mutiara Putih', 'Pearl White'),
  royalGold('Emas Kerajaan', 'Royal Gold'),
  oliveMadinah('Zaitun Madinah', 'Madinah Olive'),
  indigoFajr('Fajar Nila', 'Fajr Indigo'),
  obsidianInk('Tinta Obsidian', 'Obsidian Ink'),
  terracottaAndalus('Terakota Andalusia', 'Andalusian Clay');

  final String label;
  final String labelEn;
  const ShareCardThemeStyle(this.label, this.labelEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
}

class ShareCardTemplate {
  final String id;
  final String category;
  final String? categoryEn;
  final String arabic;
  final String? latin;
  final String translation;
  final String? translationEn;
  final String source;
  final String? sourceEn;

  const ShareCardTemplate({
    required this.id,
    required this.category,
    this.categoryEn,
    required this.arabic,
    this.latin,
    required this.translation,
    this.translationEn,
    required this.source,
    this.sourceEn,
  });

  String categoryFor(AppLanguage lang) =>
      lang == AppLanguage.en && (categoryEn?.isNotEmpty ?? false) ? categoryEn! : category;
  String translationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (translationEn?.isNotEmpty ?? false) ? translationEn! : translation;
  String sourceFor(AppLanguage lang) =>
      lang == AppLanguage.en && (sourceEn?.isNotEmpty ?? false) ? sourceEn! : source;
}

const List<ShareCardTemplate> defaultShareCardTemplates = [
  ShareCardTemplate(
    id: 'rad_28',
    category: 'Al-Qur\'an',
    categoryEn: 'Al-Quran',
    arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    latin: 'Ala bidzikrillahi tathma\'innul-qulub.',
    translation: 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
    translationEn: 'Unquestionably, by the remembrance of Allah hearts are assured.',
    source: 'QS. Ar-Ra\'d: 28',
    sourceEn: 'Quran 13:28 (Ar-Ra\'d)',
  ),
  ShareCardTemplate(
    id: 'insyirah_5',
    category: 'Al-Qur\'an',
    categoryEn: 'Al-Quran',
    arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    latin: 'Fa inna ma\'al-\'usri yusra. Inna ma\'al-\'usri yusra.',
    translation: 'Maka sesungguhnya beserta kesulitan ada kemudahan. Sesungguhnya beserta kesulitan itu ada kemudahan.',
    translationEn: 'For indeed, with hardship will be ease. Indeed, with hardship will be ease.',
    source: 'QS. Al-Insyirah: 5-6',
    sourceEn: 'Quran 94:5-6 (Ash-Sharh)',
  ),
  ShareCardTemplate(
    id: 'baqarah_201',
    category: 'Doa Al-Qur\'an',
    categoryEn: 'Quranic Dua',
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    latin: 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adzaban-nar.',
    translation: 'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka.',
    translationEn: 'Our Lord, give us in this world that which is good and in the Hereafter that which is good and protect us from the punishment of the Fire.',
    source: 'QS. Al-Baqarah: 201',
    sourceEn: 'Quran 2:201 (Al-Baqarah)',
  ),
  ShareCardTemplate(
    id: 'thaha_114',
    category: 'Doa Ilmu',
    categoryEn: 'Dua for Knowledge',
    arabic: 'رَبِّ زِدْنِي عِلْمًا',
    latin: 'Rabbi zidni \'ilma.',
    translation: 'Ya Tuhanku, tambahkanlah ilmu yang bermanfaat kepadaku.',
    translationEn: 'My Lord, increase me in knowledge.',
    source: 'QS. Thaha: 114',
    sourceEn: 'Quran 20:114 (Ta-Ha)',
  ),
  ShareCardTemplate(
    id: 'hadits_niat',
    category: 'Hadits Shahih',
    categoryEn: 'Authentic Hadith',
    arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
    latin: 'Innamal-a\'malu bin-niyyat.',
    translation: 'Sesungguhnya setiap amalan tergantung pada niatnya.',
    translationEn: 'Actions are judged solely by intentions.',
    source: 'HR. Bukhari & Muslim',
    sourceEn: 'Sahih al-Bukhari & Sahih Muslim',
  ),
  ShareCardTemplate(
    id: 'baqarah_152',
    category: 'Al-Qur\'an',
    categoryEn: 'Al-Quran',
    arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    latin: 'Fadzkuruni adzkurkum wasykuru li wa la takfurun.',
    translation: 'Maka ingatlah kepada-Ku, niscaya Aku akan ingat kepadamu. Bersyukurlah kepada-Ku, dan janganlah kamu ingkar kepada-Ku.',
    translationEn: 'So remember Me; I will remember you. And be grateful to Me and do not deny Me.',
    source: 'QS. Al-Baqarah: 152',
    sourceEn: 'Quran 2:152 (Al-Baqarah)',
  ),
  ShareCardTemplate(
    id: 'ibrahim_7',
    category: 'Al-Qur\'an',
    categoryEn: 'Al-Quran',
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    latin: 'La\'in syakartum la\'azidannakum.',
    translation: 'Sesungguhnya jika kamu bersyukur, niscaya Aku akan menambah nikmat kepadamu.',
    translationEn: 'If you are grateful, I will surely increase you in favor.',
    source: 'QS. Ibrahim: 7',
    sourceEn: 'Quran 14:7 (Ibrahim)',
  ),
  ShareCardTemplate(
    id: 'hadits_senyum',
    category: 'Hadits Shahih',
    categoryEn: 'Authentic Hadith',
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
    latin: 'Tabassumuka fi wajhi akhika laka shadaqah.',
    translation: 'Senyummu di hadapan saudaramu adalah sedekah bagimu.',
    translationEn: 'Your smiling in the face of your brother is charity.',
    source: 'HR. Tirmidzi no. 1956',
    sourceEn: 'Jami\' at-Tirmidhi 1956',
  ),
  ShareCardTemplate(
    id: 'hadits_terbaik_quran',
    category: 'Hadits Shahih',
    categoryEn: 'Authentic Hadith',
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    latin: 'Khayrukum man ta\'allamal-Qur\'ana wa \'allamah.',
    translation: 'Sebaik-baik kalian adalah orang yang belajar Al-Qur\'an dan mengajarkannya.',
    translationEn: 'The best among you are those who learn the Quran and teach it.',
    source: 'HR. Bukhari no. 5027',
    sourceEn: 'Sahih al-Bukhari 5027',
  ),
  ShareCardTemplate(
    id: 'hadits_manfaat',
    category: 'Hadits Pilihan',
    categoryEn: 'Selected Hadith',
    arabic: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
    latin: 'Khayrun-nasi anfa\'uhum lin-nas.',
    translation: 'Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia lainnya.',
    translationEn: 'The best of people are those who are most beneficial to people.',
    source: 'HR. Ahmad & Thabrani (Hasan)',
    sourceEn: 'Musnad Ahmad & at-Tabarani (Hasan)',
  ),
];
