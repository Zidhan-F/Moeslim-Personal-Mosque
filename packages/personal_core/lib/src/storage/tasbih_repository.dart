import '../content/dzikir.dart';
import 'key_value_store.dart';

class TasbihRepository {
  static const _key = 'tasbih';
  final KeyValueStore _store;

  TasbihRepository(this._store);

  Future<Map<String, dynamic>> _all() async {
    final j = await _store.readJson(_key);
    return j is Map ? Map<String, dynamic>.from(j) : {};
  }

  Future<int> count(String id) async => ((await _all())['$id.count'] as num?)?.toInt() ?? 0;

  Future<int> target(String id) async =>
      ((await _all())['$id.target'] as num?)?.toInt() ??
      dzikirList.where((d) => d.id == id).firstOrNull?.defaultTarget ??
      33;

  Future<int> increment(String id) async {
    final all = await _all();
    final next = ((all['$id.count'] as num?)?.toInt() ?? 0) + 1;
    all['$id.count'] = next;
    await _store.writeJson(_key, all);
    return next;
  }

  Future<void> reset(String id) async {
    final all = await _all()..['$id.count'] = 0;
    await _store.writeJson(_key, all);
  }

  Future<void> setTarget(String id, int target) async {
    final all = await _all()..['$id.target'] = target;
    await _store.writeJson(_key, all);
  }
}
