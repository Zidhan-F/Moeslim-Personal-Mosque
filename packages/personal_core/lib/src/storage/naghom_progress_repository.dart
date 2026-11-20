import 'key_value_store.dart';

class NaghomProgressRepository {
  final KeyValueStore _store;
  NaghomProgressRepository(this._store);

  Future<Set<String>> _set(String key) async {
    final j = await _store.readJson(key);
    return j is List ? j.whereType<String>().toSet() : {};
  }

  Future<Set<String>> completed() => _set('naghom.completed');
  Future<Set<String>> favorites() => _set('naghom.favorites');

  Future<void> markCompleted(String slug, {bool done = true}) async {
    final s = await completed();
    done ? s.add(slug) : s.remove(slug);
    await _store.writeJson('naghom.completed', s.toList());
  }

  Future<bool> toggleFavorite(String slug) async {
    final s = await favorites();
    final added = !s.remove(slug);
    if (added) s.add(slug);
    await _store.writeJson('naghom.favorites', s.toList());
    return added;
  }

  Future<String?> note(String slug) => _store.read('naghom.note.$slug');
  Future<void> saveNote(String slug, String note) => _store.write('naghom.note.$slug', note);
}
