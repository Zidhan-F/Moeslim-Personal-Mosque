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

class TrackerDay {
  final DateTime day;
  final Set<TrackerItem> items;
  final int tilawahPages;
  const TrackerDay(this.day, this.items, this.tilawahPages);

  double get progress => items.length / TrackerItem.values.length;
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

  /// Jumlah hari berturut-turut (berakhir di [until]) dengan lima sholat lengkap
  /// (hari uzur haid pada Mode Muslimah dijeda otomatis sehingga tidak memutus streak).
  Future<int> prayerStreak(DateTime until) async {
    final uzurRaw = await _store.readJson('muslimah_uzur_days');
    final uzurSet = uzurRaw is List ? {for (final x in uzurRaw) if (x is String) x} : <String>{};
    var streak = 0;
    var d = DateTime(until.year, until.month, until.day);
    for (var guard = 0; guard < 730; guard++) {
      final key = dayKey(d);
      if (uzurSet.contains(key)) {
        d = d.subtract(const Duration(days: 1));
        continue;
      }
      final items = await day(d);
      if (!TrackerItem.prayers.every(items.contains)) break;
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<int> tilawahPages(DateTime d) async {
    final j = await _store.readJson('tilawah');
    return j is Map ? ((j[dayKey(d)] as num?)?.toInt() ?? 0) : 0;
  }

  Future<int> addTilawahPages(DateTime d, int pages) async {
    final j = await _store.readJson('tilawah');
    final all = j is Map ? Map<String, dynamic>.from(j) : <String, dynamic>{};
    final next = (((all[dayKey(d)] as num?)?.toInt() ?? 0) + pages).clamp(0, 604);
    all[dayKey(d)] = next;
    await _store.writeJson('tilawah', all);
    return next;
  }

  /// Tujuh hari terakhir (berakhir di [until]), dari terlama ke terbaru.
  Future<List<TrackerDay>> week(DateTime until) async {
    final end = DateTime(until.year, until.month, until.day);
    return [
      for (var i = 6; i >= 0; i--)
        await () async {
          final d = DateTime(end.year, end.month, end.day - i);
          return TrackerDay(d, await day(d), await tilawahPages(d));
        }(),
    ];
  }

  /// Rekor beruntun sholat lengkap dalam 365 hari terakhir.
  Future<int> bestPrayerStreak(DateTime until) async {
    var best = 0, run = 0;
    final end = DateTime(until.year, until.month, until.day);
    for (var i = 365; i >= 0; i--) {
      final items = await day(DateTime(end.year, end.month, end.day - i));
      if (TrackerItem.prayers.every(items.contains)) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    return best;
  }
}
