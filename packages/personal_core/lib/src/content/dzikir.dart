import 'package:shared_prayer/shared_prayer.dart';

class Dzikir {
  final String id;
  final String name;
  final String? nameEn;
  final String arabic;
  final String latin;
  final String meaning;
  final String? meaningEn;
  final int defaultTarget;

  const Dzikir(
    this.id,
    this.name,
    this.arabic,
    this.latin,
    this.meaning,
    this.defaultTarget, {
    this.nameEn,
    this.meaningEn,
  });

  String nameFor(AppLanguage lang) =>
      lang == AppLanguage.en && (nameEn?.isNotEmpty ?? false) ? nameEn! : name;
  String meaningFor(AppLanguage lang) =>
      lang == AppLanguage.en && (meaningEn?.isNotEmpty ?? false) ? meaningEn! : meaning;
}

/// Dzikir dasar untuk penghitung tasbih. Teks perlu ditinjau ulang
/// (harakat) oleh penelaah konten sebelum rilis.
const List<Dzikir> dzikirList = [
  Dzikir(
    'tasbih',
    'Tasbih',
    'سُبْحَانَ اللّٰهِ',
    'Subhanallah',
    'Mahasuci Allah',
    33,
    nameEn: 'Tasbih',
    meaningEn: 'Glory be to Allah',
  ),
  Dzikir(
    'tahmid',
    'Tahmid',
    'اَلْحَمْدُ لِلّٰهِ',
    'Alhamdulillah',
    'Segala puji bagi Allah',
    33,
    nameEn: 'Tahmid',
    meaningEn: 'All praise is due to Allah',
  ),
  Dzikir(
    'takbir',
    'Takbir',
    'اَللّٰهُ أَكْبَرُ',
    'Allahu akbar',
    'Allah Mahabesar',
    33,
    nameEn: 'Takbir',
    meaningEn: 'Allah is the Greatest',
  ),
  Dzikir(
    'tahlil',
    'Tahlil',
    'لَا إِلٰهَ إِلَّا اللّٰهُ',
    'La ilaha illallah',
    'Tiada tuhan selain Allah',
    100,
    nameEn: 'Tahlil',
    meaningEn: 'There is no deity worthy of worship except Allah',
  ),
  Dzikir(
    'istighfar',
    'Istighfar',
    'أَسْتَغْفِرُ اللّٰهَ',
    'Astaghfirullah',
    'Aku memohon ampun kepada Allah',
    100,
    nameEn: 'Istighfar',
    meaningEn: 'I seek the forgiveness of Allah',
  ),
];
