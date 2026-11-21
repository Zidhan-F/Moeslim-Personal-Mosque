import 'key_value_store.dart';

/// Qari murattal terakhir yang dipilih pengguna (lokal, tanpa akun).
class AudioPreferenceRepository {
  final KeyValueStore _store;
  AudioPreferenceRepository(this._store);

  Future<String?> recitationId() => _store.read('audio.recitation');

  Future<void> save({required String recitationId}) =>
      _store.write('audio.recitation', recitationId);
}
