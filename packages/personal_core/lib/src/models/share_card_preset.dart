enum ShareCardThemeStyle {
  emeraldGold('Zamrud & Emas Moeslim'),
  creamManuscript('Manuskrip Krem Hangat'),
  midnightDeep('Malam Khusyuk'),
  sandDhuha('Pasir Dhuha'),
  tealLagoon('Teal Samudra'),
  roseSakinah('Mawar Sakinah'),
  pearlWhite('Mutiara Putih'),
  royalGold('Emas Kerajaan');

  final String label;
  const ShareCardThemeStyle(this.label);
}

class ShareCardTemplate {
  final String id;
  final String category;
  final String arabic;
  final String translation;
  final String source;

  const ShareCardTemplate({
    required this.id,
    required this.category,
    required this.arabic,
    required this.translation,
    required this.source,
  });
}

const List<ShareCardTemplate> defaultShareCardTemplates = [
  ShareCardTemplate(
    id: 'rad_28',
    category: 'Al-Qur\'an',
    arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    translation: 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
    source: 'QS. Ar-Ra\'d: 28',
  ),
  ShareCardTemplate(
    id: 'insyirah_5',
    category: 'Al-Qur\'an',
    arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    translation: 'Maka sesungguhnya beserta kesulitan ada kemudahan. Sesungguhnya beserta kesulitan itu ada kemudahan.',
    source: 'QS. Al-Insyirah: 5–6',
  ),
  ShareCardTemplate(
    id: 'baqarah_201',
    category: 'Doa Al-Qur\'an',
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    translation: 'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka.',
    source: 'QS. Al-Baqarah: 201',
  ),
  ShareCardTemplate(
    id: 'thaha_114',
    category: 'Doa Ilmu',
    arabic: 'رَبِّ زِدْنِي عِلْمًا',
    translation: 'Ya Tuhanku, tambahkanlah ilmu yang bermanfaat kepadaku.',
    source: 'QS. Thaha: 114',
  ),
  ShareCardTemplate(
    id: 'hadits_niat',
    category: 'Hadits Shahih',
    arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
    translation: 'Sesungguhnya setiap amalan tergantung pada niatnya.',
    source: 'HR. Bukhari & Muslim',
  ),
];
