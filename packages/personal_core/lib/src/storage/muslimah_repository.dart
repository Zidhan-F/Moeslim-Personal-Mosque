import 'package:shared_prayer/shared_prayer.dart';

import 'fasting_repository.dart';
import 'key_value_store.dart';
import 'tracker_repository.dart';

class HaidCycleRecord {
  final String startDateKey;
  final String? endDateKey;
  final String note;

  const HaidCycleRecord({
    required this.startDateKey,
    this.endDateKey,
    this.note = '',
  });

  bool get isActive => endDateKey == null;

  int get durationDays {
    final start = DateTime.tryParse(startDateKey);
    if (start == null) return 1;
    final end = endDateKey != null ? DateTime.tryParse(endDateKey!) : DateTime.now();
    if (end == null) return 1;
    return (end.difference(start).inDays + 1).clamp(1, 30);
  }

  Map<String, Object> toJson() => {
        'startDateKey': startDateKey,
        if (endDateKey != null) 'endDateKey': endDateKey!,
        'note': note,
      };

  factory HaidCycleRecord.fromJson(Map<String, dynamic> j) => HaidCycleRecord(
        startDateKey: j['startDateKey'] as String? ?? '',
        endDateKey: j['endDateKey'] as String?,
        note: j['note'] as String? ?? '',
      );
}

class MuslimahRepository {
  static const _cyclesKey = 'muslimah_cycles';
  static const uzurDaysKey = 'muslimah_uzur_days';
  final KeyValueStore _store;

  const MuslimahRepository(this._store);

  Future<Set<String>> uzurDayKeys() async {
    final raw = await _store.readJson(uzurDaysKey);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is String) x,
    };
  }

  Future<bool> isUzurDay(DateTime date) async {
    final set = await uzurDayKeys();
    return set.contains(TrackerRepository.dayKey(date));
  }

  Future<Set<String>> toggleUzurDay(
    DateTime date, {
    int hijriOffset = 0,
    FastingRepository? fastingRepo,
  }) async {
    final key = TrackerRepository.dayKey(date);
    final set = await uzurDayKeys();
    final added = set.add(key);
    if (!added) {
      set.remove(key);
    }
    await _store.writeJson(uzurDaysKey, set.toList()..sort());

    // Automatic Ramadan Qadha calculation when marking a Ramadan day as Haid/Uzur
    if (fastingRepo != null) {
      final hijri = HijriDate.fromGregorian(date, offsetDays: hijriOffset);
      if (hijri.month == 9) {
        final q = await fastingRepo.qadhaSummary();
        final nextDebt = added ? q.totalDebtDays + 1 : (q.totalDebtDays - 1).clamp(0, 3650);
        await fastingRepo.saveQadhaSummary(
          totalDebtDays: nextDebt,
          completedQadhaDays: q.completedQadhaDays,
          fidyahDaysPaid: q.fidyahDaysPaid,
        );
      }
    }
    return set;
  }

  Future<List<HaidCycleRecord>> allCycles() async {
    final raw = await _store.readJson(_cyclesKey);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) HaidCycleRecord.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<void> startCycle(DateTime startDate, {String note = ''}) async {
    final key = TrackerRepository.dayKey(startDate);
    final list = (await allCycles()).toList();
    list.insert(0, HaidCycleRecord(startDateKey: key, note: note));
    await _store.writeJson(_cyclesKey, [for (final c in list) c.toJson()]);
  }

  Future<void> endActiveCycle(DateTime endDate) async {
    final endKey = TrackerRepository.dayKey(endDate);
    final list = (await allCycles()).toList();
    final idx = list.indexWhere((c) => c.isActive);
    if (idx >= 0) {
      final active = list[idx];
      list[idx] = HaidCycleRecord(startDateKey: active.startDateKey, endDateKey: endKey, note: active.note);
      await _store.writeJson(_cyclesKey, [for (final c in list) c.toJson()]);
    }
  }
}
