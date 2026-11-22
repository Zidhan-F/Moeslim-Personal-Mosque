import 'key_value_store.dart';
import 'tracker_repository.dart';

class MuhasabahEntry {
  final String dateKey;
  final String mood;
  final String gratitude;
  final String evaluation;
  final String hopeAndPrayer;

  const MuhasabahEntry({
    required this.dateKey,
    required this.mood,
    required this.gratitude,
    required this.evaluation,
    required this.hopeAndPrayer,
  });

  Map<String, Object> toJson() => {
        'dateKey': dateKey,
        'mood': mood,
        'gratitude': gratitude,
        'evaluation': evaluation,
        'hopeAndPrayer': hopeAndPrayer,
      };

  factory MuhasabahEntry.fromJson(Map<String, dynamic> j) => MuhasabahEntry(
        dateKey: j['dateKey'] as String? ?? '',
        mood: j['mood'] as String? ?? 'Tenang & Bersyukur',
        gratitude: j['gratitude'] as String? ?? '',
        evaluation: j['evaluation'] as String? ?? '',
        hopeAndPrayer: j['hopeAndPrayer'] as String? ?? '',
      );
}

class MuhasabahRepository {
  static const _entriesKey = 'muhasabah_entries';
  static const _pinKey = 'muhasabah_pin';
  final KeyValueStore _store;

  const MuhasabahRepository(this._store);

  Future<String?> savedPin() async {
    final pin = await _store.read(_pinKey);
    return (pin == null || pin.trim().isEmpty) ? null : pin.trim();
  }

  Future<void> setPin(String? pin) async {
    if (pin == null || pin.trim().isEmpty) {
      await _store.delete(_pinKey);
    } else {
      await _store.write(_pinKey, pin.trim());
    }
  }

  Future<bool> verifyPin(String input) async {
    final current = await savedPin();
    if (current == null) return true;
    return current == input.trim();
  }

  Future<List<MuhasabahEntry>> allEntries() async {
    final raw = await _store.readJson(_entriesKey);
    if (raw is! List) return const [];
    final list = <MuhasabahEntry>[];
    for (final e in raw) {
      if (e is Map) {
        list.add(MuhasabahEntry.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return list;
  }

  Future<void> saveEntry({
    required DateTime date,
    required String mood,
    required String gratitude,
    required String evaluation,
    required String hopeAndPrayer,
  }) async {
    final key = TrackerRepository.dayKey(date);
    final list = (await allEntries()).where((e) => e.dateKey != key).toList();
    list.insert(
      0,
      MuhasabahEntry(
        dateKey: key,
        mood: mood,
        gratitude: gratitude.trim(),
        evaluation: evaluation.trim(),
        hopeAndPrayer: hopeAndPrayer.trim(),
      ),
    );
    await _store.writeJson(_entriesKey, [for (final e in list) e.toJson()]);
  }

  Future<void> deleteEntry(String dateKey) async {
    final list = (await allEntries()).where((e) => e.dateKey != dateKey).toList();
    await _store.writeJson(_entriesKey, [for (final e in list) e.toJson()]);
  }
}
