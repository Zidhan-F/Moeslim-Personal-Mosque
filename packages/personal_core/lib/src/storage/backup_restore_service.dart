import 'dart:convert';

import 'key_value_store.dart';

class BackupRestoreSummary {
  final int exportedKeysCount;
  final DateTime timestamp;
  final String jsonPayload;

  const BackupRestoreSummary({
    required this.exportedKeysCount,
    required this.timestamp,
    required this.jsonPayload,
  });
}

class BackupRestoreService {
  static const List<String> managedKeys = [
    'settings',
    'tracker',
    'tilawah',
    'tasbih',
    'tasbih_target',
    'quran_bookmarks',
    'quran_last_read',
    'audio_pref',
    'favorite_mosques',
    'ayah_notes',
    'tahfidz_progress',
    'hadith_bookmarks',
    'fasting_logs',
    'fasting_qadha',
    'home_widget_payload',
    'asmaul_husna_memorized',
    'khatam_plan',
    'auto_dnd_config',
    'custom_nearby_mosques',
    'manasik_counter',
    'sedekah_entries',
    'sedekah_monthly_target',
    'muhasabah_entries',
    'sirah_read_chapters',
    'sirah_last_chapter',
    'muslimah_cycles',
    'muslimah_uzur_days',
    'friday_sunnah_checks',
    'ramadan_dashboard_state',
    'eid_checklist_state',
    'shalawat_counter_state',
    'hajat_prayer_list',
    'sunnah_habit_logs',
    'baby_names_favorites',
    'quiz_high_score',
    'debt_ledger_entries',
    'senior_mode_enabled',
    'worship_timer_logs',
    'contextual_reminder_prefs',
  ];

  final KeyValueStore _store;

  const BackupRestoreService(this._store);

  Future<BackupRestoreSummary> createBackup({DateTime? now}) async {
    final ts = (now ?? DateTime.now()).toUtc();
    final data = <String, String>{};
    for (final key in managedKeys) {
      final val = await _store.read(key);
      if (val != null) {
        data[key] = val;
      }
    }
    final payload = const JsonEncoder.withIndent('  ').convert({
      'format': 'moeslim_pm_personal_backup',
      'version': 1,
      'createdAt': ts.toIso8601String(),
      'data': data,
    });
    return BackupRestoreSummary(
      exportedKeysCount: data.length,
      timestamp: ts.toLocal(),
      jsonPayload: payload,
    );
  }

  Future<int> restoreFromJson(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map || decoded['format'] != 'moeslim_pm_personal_backup') {
      throw const FormatException('Format berkas cadangan Moeslim PM tidak valid.');
    }
    final data = decoded['data'];
    if (data is! Map) {
      throw const FormatException('Berkas cadangan tidak memuat objek data.');
    }
    var restored = 0;
    for (final entry in data.entries) {
      final k = entry.key;
      final v = entry.value;
      if (k is String && v is String && managedKeys.contains(k)) {
        await _store.write(k, v);
        restored++;
      }
    }
    return restored;
  }
}
