import '../models/settings.dart';
import 'key_value_store.dart';

class SettingsRepository {
  static const _key = 'settings';
  final KeyValueStore _store;

  SettingsRepository(this._store);

  Future<PersonalSettings> load() async {
    final j = await _store.readJson(_key);
    if (j is! Map) return PersonalSettings.defaults;
    try {
      return PersonalSettings.fromJson(Map<String, dynamic>.from(j));
    } catch (_) {
      return PersonalSettings.defaults;
    }
  }

  Future<void> save(PersonalSettings s) => _store.writeJson(_key, s.toJson());
}
