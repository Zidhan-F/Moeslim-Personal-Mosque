import 'key_value_store.dart';

/// Irama & qari terakhir yang dipilih pengguna (lokal, tanpa akun).
class AudioPreferenceRepository {
  final KeyValueStore _store;
  AudioPreferenceRepository(this._store);

  Future<String?> naghom() => _store.read('audio.naghom');
  Future<String?> recitationId() => _store.read('audio.recitation');

  Future<void> save({required String naghom, required String recitationId}) async {
    await _store.write('audio.naghom', naghom);
    await _store.write('audio.recitation', recitationId);
  }
}
