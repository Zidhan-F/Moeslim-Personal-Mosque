import 'dart:convert';

/// Abstraksi penyimpanan string lokal. Aplikasi Flutter menyediakan
/// implementasi berbasis SharedPreferences; test memakai [InMemoryStore].
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class InMemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

/// Helper JSON yang tahan data rusak (mengembalikan null).
extension JsonStore on KeyValueStore {
  Future<Object?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String key, Object value) => write(key, jsonEncode(value));
}
