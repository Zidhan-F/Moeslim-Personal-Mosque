import 'key_value_store.dart';

class KhatamPlan {
  static const int totalMushafPages = 604;

  final int targetDays;
  final DateTime startDate;
  final int completedPages;

  const KhatamPlan({
    required this.targetDays,
    required this.startDate,
    this.completedPages = 0,
  });

  int get remainingPages => (totalMushafPages - completedPages).clamp(0, totalMushafPages);

  double get progressRatio => (completedPages / totalMushafPages).clamp(0.0, 1.0);

  int get currentPageToRead => (completedPages + 1).clamp(1, totalMushafPages);

  int get currentJuz => ((completedPages ~/ 20) + 1).clamp(1, 30);

  double get dailyTargetPages => totalMushafPages / targetDays.clamp(1, 3650);

  int get pagesPerPrayer => (dailyTargetPages / 5.0).ceil();

  int elapsedDaysAt(DateTime now) {
    final startClean = DateTime(startDate.year, startDate.month, startDate.day);
    final nowClean = DateTime(now.year, now.month, now.day);
    return (nowClean.difference(startClean).inDays + 1).clamp(1, targetDays);
  }

  int expectedPagesAt(DateTime now) {
    final elapsed = elapsedDaysAt(now);
    return (elapsed * dailyTargetPages).round().clamp(0, totalMushafPages);
  }

  int deltaPagesAt(DateTime now) => completedPages - expectedPagesAt(now);

  String statusLabelAt(DateTime now) {
    if (completedPages >= totalMushafPages) {
      return 'Alhamdulillah, Khatam 604 Halaman!';
    }
    final delta = deltaPagesAt(now);
    if (delta > 2) return 'Lebih cepat $delta halaman dari jadwal';
    if (delta < -2) return 'Tertinggal ${delta.abs()} halaman dari jadwal';
    return 'Sesuai jadwal target harian';
  }

  KhatamPlan copyWith({
    int? targetDays,
    DateTime? startDate,
    int? completedPages,
  }) =>
      KhatamPlan(
        targetDays: (targetDays ?? this.targetDays).clamp(1, 3650),
        startDate: startDate ?? this.startDate,
        completedPages: (completedPages ?? this.completedPages).clamp(0, totalMushafPages),
      );

  Map<String, Object> toJson() => {
        'targetDays': targetDays,
        'startDate': startDate.toUtc().toIso8601String(),
        'completedPages': completedPages,
      };

  factory KhatamPlan.fromJson(Map<String, dynamic> j) => KhatamPlan(
        targetDays: ((j['targetDays'] as num?)?.toInt() ?? 30).clamp(1, 3650),
        startDate: DateTime.tryParse(j['startDate'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        completedPages: ((j['completedPages'] as num?)?.toInt() ?? 0).clamp(0, totalMushafPages),
      );
}

class KhatamPlannerRepository {
  static const _key = 'khatam_plan';
  final KeyValueStore _store;

  const KhatamPlannerRepository(this._store);

  Future<KhatamPlan> load({DateTime? defaultStart}) async {
    final raw = await _store.readJson(_key);
    if (raw is! Map) {
      return KhatamPlan(targetDays: 30, startDate: defaultStart ?? DateTime.now(), completedPages: 0);
    }
    return KhatamPlan.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<KhatamPlan> save(KhatamPlan plan) async {
    await _store.writeJson(_key, plan.toJson());
    return plan;
  }

  Future<KhatamPlan> addPages(int deltaPages) async {
    final current = await load();
    final updated = current.copyWith(completedPages: current.completedPages + deltaPages);
    return save(updated);
  }
}
