import 'key_value_store.dart';

enum TrackerItem {
  subuh('Subuh'),
  dzuhur('Dzuhur'),
  ashar('Ashar'),
  maghrib('Maghrib'),
  isya('Isya'),
  tilawah('Tilawah'),
  dzikir('Dzikir pagi/petang');

  final String label;
  const TrackerItem(this.label);

  static const prayers = [subuh, dzuhur, ashar, maghrib, isya];
}

/// Checklist ibadah harian, disimpan per tanggal (yyyy-mm-dd).
class TrackerRepository {
  static const _key = 'tracker';
  final KeyValueStore _store;

  TrackerRepository(this._store);

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> _all() async {
    final j = await _store.readJson(_key);
    return j is Map ? Map<String, dynamic>.from(j) : {};
  }

  Future<Set<TrackerItem>> day(DateTime d) async {
    final list = (await _all())[dayKey(d)];
    if (list is! List) return {};
    return {for (final n in list) ...TrackerItem.values.where((t) => t.name == n)};
  }

  Future<Set<TrackerItem>> toggle(DateTime d, TrackerItem item) async {
    final all = await _all();
    final current = await day(d);
    current.contains(item) ? current.remove(item) : current.add(item);
    all[dayKey(d)] = current.map((e) => e.name).toList();
    await _store.writeJson(_key, all);
    return current;
  }

  Future<double> progress(DateTime d) async => (await day(d)).length / TrackerItem.values.length;

  /// Jumlah hari berturut-turut (berakhir di [until]) dengan lima sholat lengkap.
  Future<int> prayerStreak(DateTime until) async {
    var streak = 0;
    var d = DateTime(until.year, until.month, until.day);
    while (true) {
      final items = await day(d);
      if (!TrackerItem.prayers.every(items.contains)) break;
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
