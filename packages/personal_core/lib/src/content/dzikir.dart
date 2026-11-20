class Dzikir {
  final String id;
  final String name;
  final String arabic;
  final String latin;
  final String meaning;
  final int defaultTarget;

  const Dzikir(this.id, this.name, this.arabic, this.latin, this.meaning, this.defaultTarget);
}

/// Dzikir dasar untuk penghitung tasbih. Teks perlu ditinjau ulang
/// (harakat) oleh penelaah konten sebelum rilis.
const List<Dzikir> dzikirList = [
  Dzikir('tasbih', 'Tasbih', 'سُبْحَانَ اللّٰهِ', 'Subhanallah', 'Mahasuci Allah', 33),
  Dzikir('tahmid', 'Tahmid', 'اَلْحَمْدُ لِلّٰهِ', 'Alhamdulillah', 'Segala puji bagi Allah', 33),
  Dzikir('takbir', 'Takbir', 'اَللّٰهُ أَكْبَرُ', 'Allahu akbar', 'Allah Mahabesar', 33),
  Dzikir('tahlil', 'Tahlil', 'لَا إِلٰهَ إِلَّا اللّٰهُ', 'La ilaha illallah', 'Tiada tuhan selain Allah', 100),
  Dzikir('istighfar', 'Istighfar', 'أَسْتَغْفِرُ اللّٰهَ', 'Astaghfirullah', 'Aku memohon ampun kepada Allah', 100),
];
