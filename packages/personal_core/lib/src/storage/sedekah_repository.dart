import 'key_value_store.dart';
import 'tracker_repository.dart';

enum SedekahCategory {
  sedekahSubuh('Sedekah Subuh'),
  infaqJumatMasjid('Infaq Jumat & Masjid'),
  santunanYatimDhuafa('Santunan Yatim & Dhuafa'),
  wakafAmalJariyah('Wakaf & Amal Jariyah'),
  kebaikanNonMateri('Sedekah Non-Materi & Bantuan');

  final String label;
  const SedekahCategory(this.label);
}

class SedekahEntry {
  final String id;
  final String dateKey;
  final SedekahCategory category;
  final int amountRupiah;
  final String note;

  const SedekahEntry({
    required this.id,
    required this.dateKey,
    required this.category,
    required this.amountRupiah,
    required this.note,
  });

  Map<String, Object> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'category': category.name,
        'amountRupiah': amountRupiah,
        'note': note,
      };

  factory SedekahEntry.fromJson(Map<String, dynamic> j) {
    final cName = j['category'] as String?;
    final cat = SedekahCategory.values.where((e) => e.name == cName).firstOrNull ?? SedekahCategory.sedekahSubuh;
    return SedekahEntry(
      id: j['id'] as String? ?? 's',
      dateKey: j['dateKey'] as String? ?? '',
      category: cat,
      amountRupiah: ((j['amountRupiah'] as num?)?.toInt() ?? 0).clamp(0, 1000000000),
      note: j['note'] as String? ?? '',
    );
  }
}

class SedekahRepository {
  static const _entriesKey = 'sedekah_entries';
  static const _targetKey = 'sedekah_monthly_target';
  final KeyValueStore _store;

  const SedekahRepository(this._store);

  Future<List<SedekahEntry>> allEntries() async {
    final raw = await _store.readJson(_entriesKey);
    if (raw is! List) return const [];
    final list = <SedekahEntry>[];
    for (final item in raw) {
      if (item is Map) {
        list.add(SedekahEntry.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return list;
  }

  Future<void> addEntry({
    required DateTime date,
    required SedekahCategory category,
    required int amountRupiah,
    required String note,
  }) async {
    final list = (await allEntries()).toList();
    final entry = SedekahEntry(
      id: '${date.microsecondsSinceEpoch}',
      dateKey: TrackerRepository.dayKey(date),
      category: category,
      amountRupiah: amountRupiah.clamp(0, 1000000000),
      note: note.trim(),
    );
    list.insert(0, entry);
    await _store.writeJson(_entriesKey, [for (final e in list) e.toJson()]);
  }

  Future<void> deleteEntry(String id) async {
    final list = (await allEntries()).where((e) => e.id != id).toList();
    await _store.writeJson(_entriesKey, [for (final e in list) e.toJson()]);
  }

  Future<int> monthlyTargetRupiah() async {
    final raw = await _store.read(_targetKey);
    return int.tryParse(raw ?? '') ?? 500000;
  }

  Future<void> setMonthlyTargetRupiah(int target) async {
    await _store.write(_targetKey, '${target.clamp(0, 1000000000)}');
  }
}
