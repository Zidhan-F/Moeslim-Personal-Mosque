import 'key_value_store.dart';

class FollowedMosque {
  final String slug;
  final String name;
  const FollowedMosque({required this.slug, required this.name});

  Map<String, String> toJson() => {'slug': slug, 'name': name};
}

class CachedMosqueContent {
  final Map<String, dynamic> data;
  final DateTime fetchedAt;
  const CachedMosqueContent(this.data, this.fetchedAt);
}

/// Masjid yang diikuti disimpan lokal (tanpa akun), beserta cache konten
/// publik terakhir dan waktu pengambilannya.
class FavoriteMosqueRepository {
  final KeyValueStore _store;
  FavoriteMosqueRepository(this._store);

  Future<List<FollowedMosque>> all() async {
    final j = await _store.readJson('mosques.followed');
    if (j is! List) return [];
    return [
      for (final m in j.whereType<Map>()) FollowedMosque(slug: m['slug'] as String, name: m['name'] as String),
    ];
  }

  Future<void> follow(FollowedMosque m) async {
    final list = await all();
    if (list.any((e) => e.slug == m.slug)) return;
    await _store.writeJson('mosques.followed', [...list, m].map((e) => e.toJson()).toList());
  }

  Future<void> unfollow(String slug) async {
    final list = (await all()).where((e) => e.slug != slug).toList();
    await _store.writeJson('mosques.followed', list.map((e) => e.toJson()).toList());
    await _store.delete('mosques.cache.$slug');
  }

  Future<void> saveCache(String slug, Map<String, dynamic> data, DateTime fetchedAt) =>
      _store.writeJson('mosques.cache.$slug', {'data': data, 'at': fetchedAt.toUtc().toIso8601String()});

  Future<CachedMosqueContent?> cache(String slug) async {
    final j = await _store.readJson('mosques.cache.$slug');
    if (j is! Map) return null;
    final at = DateTime.tryParse(j['at'] as String? ?? '');
    if (at == null) return null;
    return CachedMosqueContent(Map<String, dynamic>.from(j['data'] as Map), at);
  }
}
