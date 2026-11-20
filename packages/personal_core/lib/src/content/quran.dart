/// Metadata surah Al-Qur'an. Teks ayat TIDAK disertakan di repo: teks dan
/// terjemahan harus diimpor dari sumber berlisensi yang telah ditashih
/// (lihat `tool/import_quran.dart`).
class Surah {
  final int number;
  final String name;
  final int ayahCount;
  final bool makkiyah;

  const Surah(this.number, this.name, this.ayahCount, this.makkiyah);

  String get revelation => makkiyah ? 'Makkiyah' : 'Madaniyah';
}

class Ayah {
  final int surah;
  final int number;
  final String text;
  final String? translation;

  const Ayah(this.surah, this.number, this.text, {this.translation});

  Map<String, Object?> toJson() => {'s': surah, 'a': number, 't': text, if (translation != null) 'tr': translation};

  factory Ayah.fromJson(Map<String, dynamic> j) =>
      Ayah(j['s'] as int, j['a'] as int, j['t'] as String, translation: j['tr'] as String?);
}

/// Parser format teks Tanzil: satu ayat per baris `sura|aya|teks`.
Map<int, List<Ayah>> parseTanzil(String raw) {
  final out = <int, List<Ayah>>{};
  for (final line in raw.split('\n')) {
    final l = line.trim();
    if (l.isEmpty || l.startsWith('#')) continue;
    final parts = l.split('|');
    if (parts.length < 3) throw FormatException('Baris tidak valid: $l');
    final s = int.parse(parts[0]);
    final a = int.parse(parts[1]);
    out.putIfAbsent(s, () => []).add(Ayah(s, a, parts.sublist(2).join('|')));
  }
  return out;
}

const List<Surah> surahs = [
  Surah(1, 'Al-Fatihah', 7, true), Surah(2, 'Al-Baqarah', 286, false),
  Surah(3, "Ali 'Imran", 200, false), Surah(4, "An-Nisa'", 176, false),
  Surah(5, "Al-Ma'idah", 120, false), Surah(6, "Al-An'am", 165, true),
  Surah(7, "Al-A'raf", 206, true), Surah(8, 'Al-Anfal', 75, false),
  Surah(9, 'At-Taubah', 129, false), Surah(10, 'Yunus', 109, true),
  Surah(11, 'Hud', 123, true), Surah(12, 'Yusuf', 111, true),
  Surah(13, "Ar-Ra'd", 43, false), Surah(14, 'Ibrahim', 52, true),
  Surah(15, 'Al-Hijr', 99, true), Surah(16, 'An-Nahl', 128, true),
  Surah(17, "Al-Isra'", 111, true), Surah(18, 'Al-Kahf', 110, true),
  Surah(19, 'Maryam', 98, true), Surah(20, 'Taha', 135, true),
  Surah(21, "Al-Anbiya'", 112, true), Surah(22, 'Al-Hajj', 78, false),
  Surah(23, "Al-Mu'minun", 118, true), Surah(24, 'An-Nur', 64, false),
  Surah(25, 'Al-Furqan', 77, true), Surah(26, "Asy-Syu'ara'", 227, true),
  Surah(27, 'An-Naml', 93, true), Surah(28, 'Al-Qasas', 88, true),
  Surah(29, "Al-'Ankabut", 69, true), Surah(30, 'Ar-Rum', 60, true),
  Surah(31, 'Luqman', 34, true), Surah(32, 'As-Sajdah', 30, true),
  Surah(33, 'Al-Ahzab', 73, false), Surah(34, "Saba'", 54, true),
  Surah(35, 'Fatir', 45, true), Surah(36, 'Yasin', 83, true),
  Surah(37, 'As-Saffat', 182, true), Surah(38, 'Sad', 88, true),
  Surah(39, 'Az-Zumar', 75, true), Surah(40, 'Gafir', 85, true),
  Surah(41, 'Fussilat', 54, true), Surah(42, 'Asy-Syura', 53, true),
  Surah(43, 'Az-Zukhruf', 89, true), Surah(44, 'Ad-Dukhan', 59, true),
  Surah(45, 'Al-Jasiyah', 37, true), Surah(46, 'Al-Ahqaf', 35, true),
  Surah(47, 'Muhammad', 38, false), Surah(48, 'Al-Fath', 29, false),
  Surah(49, 'Al-Hujurat', 18, false), Surah(50, 'Qaf', 45, true),
  Surah(51, 'Az-Zariyat', 60, true), Surah(52, 'At-Tur', 49, true),
  Surah(53, 'An-Najm', 62, true), Surah(54, 'Al-Qamar', 55, true),
  Surah(55, 'Ar-Rahman', 78, false), Surah(56, "Al-Waqi'ah", 96, true),
  Surah(57, 'Al-Hadid', 29, false), Surah(58, 'Al-Mujadilah', 22, false),
  Surah(59, 'Al-Hasyr', 24, false), Surah(60, 'Al-Mumtahanah', 13, false),
  Surah(61, 'As-Saff', 14, false), Surah(62, "Al-Jumu'ah", 11, false),
  Surah(63, 'Al-Munafiqun', 11, false), Surah(64, 'At-Tagabun', 18, false),
  Surah(65, 'At-Talaq', 12, false), Surah(66, 'At-Tahrim', 12, false),
  Surah(67, 'Al-Mulk', 30, true), Surah(68, 'Al-Qalam', 52, true),
  Surah(69, 'Al-Haqqah', 52, true), Surah(70, "Al-Ma'arij", 44, true),
  Surah(71, 'Nuh', 28, true), Surah(72, 'Al-Jinn', 28, true),
  Surah(73, 'Al-Muzzammil', 20, true), Surah(74, 'Al-Muddassir', 56, true),
  Surah(75, 'Al-Qiyamah', 40, true), Surah(76, 'Al-Insan', 31, false),
  Surah(77, 'Al-Mursalat', 50, true), Surah(78, "An-Naba'", 40, true),
  Surah(79, "An-Nazi'at", 46, true), Surah(80, "'Abasa", 42, true),
  Surah(81, 'At-Takwir', 29, true), Surah(82, 'Al-Infitar', 19, true),
  Surah(83, 'Al-Mutaffifin', 36, true), Surah(84, 'Al-Insyiqaq', 25, true),
  Surah(85, 'Al-Buruj', 22, true), Surah(86, 'At-Tariq', 17, true),
  Surah(87, "Al-A'la", 19, true), Surah(88, 'Al-Gasyiyah', 26, true),
  Surah(89, 'Al-Fajr', 30, true), Surah(90, 'Al-Balad', 20, true),
  Surah(91, 'Asy-Syams', 15, true), Surah(92, 'Al-Lail', 21, true),
  Surah(93, 'Ad-Duha', 11, true), Surah(94, 'Asy-Syarh', 8, true),
  Surah(95, 'At-Tin', 8, true), Surah(96, "Al-'Alaq", 19, true),
  Surah(97, 'Al-Qadr', 5, true), Surah(98, 'Al-Bayyinah', 8, false),
  Surah(99, 'Az-Zalzalah', 8, false), Surah(100, "Al-'Adiyat", 11, true),
  Surah(101, "Al-Qari'ah", 11, true), Surah(102, 'At-Takasur', 8, true),
  Surah(103, "Al-'Asr", 3, true), Surah(104, 'Al-Humazah', 9, true),
  Surah(105, 'Al-Fil', 5, true), Surah(106, 'Quraisy', 4, true),
  Surah(107, "Al-Ma'un", 7, true), Surah(108, 'Al-Kausar', 3, true),
  Surah(109, 'Al-Kafirun', 6, true), Surah(110, 'An-Nasr', 3, false),
  Surah(111, 'Al-Lahab', 5, true), Surah(112, 'Al-Ikhlas', 4, true),
  Surah(113, 'Al-Falaq', 5, true), Surah(114, 'An-Nas', 6, true),
];
