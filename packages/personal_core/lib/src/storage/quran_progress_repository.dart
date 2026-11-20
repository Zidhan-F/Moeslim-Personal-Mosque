import 'key_value_store.dart';

class AyahRef {
  final int surah;
  final int ayah;
  const AyahRef(this.surah, this.ayah);

  @override
  bool operator ==(Object other) => other is AyahRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => '$surah:$ayah';

  static AyahRef? parse(Object? s) {
    if (s is! String) return null;
    final p = s.split(':');
    if (p.length != 2) return null;
    final a = int.tryParse(p[0]), b = int.tryParse(p[1]);
    return a == null || b == null ? null : AyahRef(a, b);
  }
}

class QuranProgressRepository {
  final KeyValueStore _store;
  QuranProgressRepository(this._store);

  Future<List<AyahRef>> bookmarks() async {
    final j = await _store.readJson('quran.bookmarks');
    if (j is! List) return [];
    return j.map(AyahRef.parse).whereType<AyahRef>().toList();
  }

  Future<bool> toggleBookmark(int surah, int ayah) async {
    final list = await bookmarks();
    final ref = AyahRef(surah, ayah);
    final added = !list.remove(ref);
    if (added) list.add(ref);
    await _store.writeJson('quran.bookmarks', list.map((e) => e.toString()).toList());
    return added;
  }

  Future<AyahRef?> lastRead() async => AyahRef.parse(await _store.read('quran.lastRead'));

  Future<void> setLastRead(AyahRef ref) => _store.write('quran.lastRead', ref.toString());
}
