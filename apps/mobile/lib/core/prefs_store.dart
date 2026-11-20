import 'package:personal_core/personal_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal berbasis SharedPreferences (data Personal tetap di perangkat).
class PrefsStore implements KeyValueStore {
  final SharedPreferences _prefs;
  PrefsStore(this._prefs);

  @override
  Future<String?> read(String key) async => _prefs.getString('moeslim.$key');

  @override
  Future<void> write(String key, String value) => _prefs.setString('moeslim.$key', value);

  @override
  Future<void> delete(String key) => _prefs.remove('moeslim.$key');
}
