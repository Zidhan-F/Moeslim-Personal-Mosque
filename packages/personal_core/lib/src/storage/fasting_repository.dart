import 'package:shared_prayer/shared_prayer.dart';

import 'key_value_store.dart';
import 'tracker_repository.dart';

enum FastingType {
  ramadan('Puasa Ramadan', 'Fardhu bagi setiap muslim yang mukallaf di bulan Ramadan.'),
  qadha('Qadha Ramadan', 'Mengganti utang puasa wajib Ramadan di hari lain.'),
  seninKamis('Puasa Senin-Kamis', 'Sunnah rutin setiap hari Senin dan Kamis.'),
  ayyamulBidh('Puasa Ayyamul Bidh', 'Sunnah tanggal 13, 14, dan 15 setiap bulan Hijriah.'),
  arafah('Puasa Arafah (9 Dzulhijjah)', 'Menghapus dosa setahun yang lalu dan setahun yang akan datang (bagi yang tidak wukuf).'),
  asyura('Puasa Tasu\'a & Asyura', 'Sunnah tanggal 9 dan 10 Muharram; menghapus dosa setahun yang lalu.'),
  syawal('Puasa 6 Hari Syawal', 'Berpuasa Ramadan lalu diikuti 6 hari di bulan Syawal senilai puasa setahun penuh.'),
  daud('Puasa Sunnah Daud / Mutlak', 'Puasa sunnah selang-seling sehari puasa sehari berbuka atau sunnah mutlak.');

  final String label;
  final String description;
  const FastingType(this.label, this.description);
}

class FastingDayStatus {
  final DateTime gregorian;
  final HijriDate hijri;
  final bool isForbidden;
  final String? forbiddenReason;
  final List<FastingType> recommended;

  const FastingDayStatus({
    required this.gregorian,
    required this.hijri,
    required this.isForbidden,
    this.forbiddenReason,
    required this.recommended,
  });
}

FastingDayStatus evaluateFastingDate(DateTime date, {int hijriOffset = 0}) {
  final cleanDate = DateTime(date.year, date.month, date.day);
  final h = HijriDate.fromGregorian(cleanDate, offsetDays: hijriOffset);

  // Hari haram berpuasa: 1 Syawal, 10 Dzulhijjah, dan Hari Tasyrik (11, 12, 13 Dzulhijjah)
  if (h.month == 10 && h.day == 1) {
    return FastingDayStatus(
      gregorian: cleanDate,
      hijri: h,
      isForbidden: true,
      forbiddenReason: 'Hari Raya Idul Fitri (1 Syawal): diharamkan berpuasa.',
      recommended: const [],
    );
  }
  if (h.month == 12 && h.day == 10) {
    return FastingDayStatus(
      gregorian: cleanDate,
      hijri: h,
      isForbidden: true,
      forbiddenReason: 'Hari Raya Idul Adha (10 Dzulhijjah): diharamkan berpuasa.',
      recommended: const [],
    );
  }
  if (h.month == 12 && (h.day == 11 || h.day == 12 || h.day == 13)) {
    return FastingDayStatus(
      gregorian: cleanDate,
      hijri: h,
      isForbidden: true,
      forbiddenReason: 'Hari Tasyrik (${h.day} Dzulhijjah): hari makan, minum, dan berdzikir kepada Allah.',
      recommended: const [],
    );
  }

  if (h.month == 9) {
    return FastingDayStatus(
      gregorian: cleanDate,
      hijri: h,
      isForbidden: false,
      recommended: const [FastingType.ramadan],
    );
  }

  final recs = <FastingType>[];
  if (h.month == 12 && h.day == 9) {
    recs.add(FastingType.arafah);
  }
  if (h.month == 1 && (h.day == 9 || h.day == 10)) {
    recs.add(FastingType.asyura);
  }
  if (h.day == 13 || h.day == 14 || h.day == 15) {
    recs.add(FastingType.ayyamulBidh);
  }
  if (cleanDate.weekday == DateTime.monday || cleanDate.weekday == DateTime.thursday) {
    recs.add(FastingType.seninKamis);
  }
  if (h.month == 10 && h.day >= 2) {
    recs.add(FastingType.syawal);
  }

  return FastingDayStatus(
    gregorian: cleanDate,
    hijri: h,
    isForbidden: false,
    recommended: recs,
  );
}

class FastingLogEntry {
  final String dateKey;
  final FastingType type;
  final String? note;

  const FastingLogEntry({
    required this.dateKey,
    required this.type,
    this.note,
  });

  Map<String, Object> toJson() => {
        'dateKey': dateKey,
        'type': type.name,
        if (note != null && note!.isNotEmpty) 'note': note!,
      };

  factory FastingLogEntry.fromJson(Map<String, dynamic> j) {
    final tName = j['type'] as String?;
    final type = FastingType.values.where((e) => e.name == tName).firstOrNull ?? FastingType.seninKamis;
    return FastingLogEntry(
      dateKey: j['dateKey'] as String? ?? '',
      type: type,
      note: j['note'] as String?,
    );
  }
}

class QadhaSummary {
  final int totalDebtDays;
  final int completedQadhaDays;
  final int fidyahDaysPaid;

  const QadhaSummary({
    required this.totalDebtDays,
    required this.completedQadhaDays,
    required this.fidyahDaysPaid,
  });

  int get remainingDays => (totalDebtDays - completedQadhaDays - fidyahDaysPaid).clamp(0, 3650);
}

class FastingRepository {
  static const _logsKey = 'fasting_logs';
  static const _qadhaKey = 'fasting_qadha';
  final KeyValueStore _store;

  const FastingRepository(this._store);

  Future<List<FastingLogEntry>> allLogs() async {
    final raw = await _store.readJson(_logsKey);
    if (raw is! List) return const [];
    final list = <FastingLogEntry>[];
    for (final item in raw) {
      if (item is Map) {
        list.add(FastingLogEntry.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return list;
  }

  Future<FastingLogEntry?> logForDate(DateTime date) async {
    final key = TrackerRepository.dayKey(date);
    for (final e in await allLogs()) {
      if (e.dateKey == key) return e;
    }
    return null;
  }

  Future<void> setFastingForDate(DateTime date, FastingType? type, {String? note}) async {
    final key = TrackerRepository.dayKey(date);
    final prev = await logForDate(date);
    final list = (await allLogs()).where((e) => e.dateKey != key).toList();
    if (type != null) {
      list.insert(0, FastingLogEntry(dateKey: key, type: type, note: note));
    }
    await _store.writeJson(_logsKey, [for (final e in list) e.toJson()]);

    // Synchronize completed Qadha count when a Qadha log is added or removed
    if (prev?.type != FastingType.qadha && type == FastingType.qadha) {
      final q = await qadhaSummary();
      await saveQadhaSummary(
        totalDebtDays: q.totalDebtDays,
        completedQadhaDays: q.completedQadhaDays + 1,
        fidyahDaysPaid: q.fidyahDaysPaid,
      );
    } else if (prev?.type == FastingType.qadha && type != FastingType.qadha) {
      final q = await qadhaSummary();
      await saveQadhaSummary(
        totalDebtDays: q.totalDebtDays,
        completedQadhaDays: (q.completedQadhaDays - 1).clamp(0, 3650),
        fidyahDaysPaid: q.fidyahDaysPaid,
      );
    }
  }

  Future<QadhaSummary> qadhaSummary() async {
    final raw = await _store.readJson(_qadhaKey);
    if (raw is! Map) {
      return const QadhaSummary(totalDebtDays: 0, completedQadhaDays: 0, fidyahDaysPaid: 0);
    }
    return QadhaSummary(
      totalDebtDays: ((raw['totalDebtDays'] as num?)?.toInt() ?? 0).clamp(0, 3650),
      completedQadhaDays: ((raw['completedQadhaDays'] as num?)?.toInt() ?? 0).clamp(0, 3650),
      fidyahDaysPaid: ((raw['fidyahDaysPaid'] as num?)?.toInt() ?? 0).clamp(0, 3650),
    );
  }

  Future<QadhaSummary> saveQadhaSummary({
    required int totalDebtDays,
    required int completedQadhaDays,
    required int fidyahDaysPaid,
  }) async {
    final next = QadhaSummary(
      totalDebtDays: totalDebtDays.clamp(0, 3650),
      completedQadhaDays: completedQadhaDays.clamp(0, 3650),
      fidyahDaysPaid: fidyahDaysPaid.clamp(0, 3650),
    );
    await _store.writeJson(_qadhaKey, {
      'totalDebtDays': next.totalDebtDays,
      'completedQadhaDays': next.completedQadhaDays,
      'fidyahDaysPaid': next.fidyahDaysPaid,
    });
    return next;
  }
}
