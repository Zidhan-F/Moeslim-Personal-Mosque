import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_core/personal_core.dart';


void main() {
  test('katalog audio bawaan valid: tidak ada entri yang diabaikan diam-diam', () {
    final raw = jsonDecode(File('assets/audio/manifest.json').readAsStringSync()) as Map<String, dynamic>;
    final parsed = AudioManifest.fromJson(raw);
    expect(
      parsed.recitations.length,
      (raw['recitations'] as List).length,
      reason: 'Setiap rekaman wajib berjenis murattal dan berlisensi',
    );
    for (final r in parsed.recitations) {
      expect(Uri.tryParse(r.baseUrl)?.isScheme('https'), isTrue, reason: '${r.id}: base_url harus https');
    }
  });

  test('katalog bawaan: murattal tersedia untuk seluruh 114 surah', () {
    final m = AudioManifest.fromJson(
      jsonDecode(File('assets/audio/manifest.json').readAsStringSync()) as Map<String, dynamic>,
    );
    final murattal = m.recitations;
    expect(murattal.length, greaterThanOrEqualTo(1));
    for (var s = 1; s <= 114; s++) {
      expect(m.murattalCovers(s), isTrue, reason: 'surah $s');
    }
    expect(murattal.every((r) => r.attribution.isNotEmpty), isTrue);
    expect(murattal.first.ayahUrl(1, 1), endsWith('/001001.mp3'));
  });

  test('katalog doa harian & aktivitas lengkap (229 doa)', () {
    final raw = File('assets/doa/daily_duas.json').readAsStringSync();
    final duas = parseDailyDuasJson(raw);
    expect(duas.length, 229);
    for (final d in duas) {
      expect(d.title, isNotEmpty);
      expect(d.group, isNotEmpty);
      expect(d.arabic, isNotEmpty);
      expect(d.translation, isNotEmpty);
      expect(d.source, isNotEmpty);
    }
    expect(duas.any((d) => d.title.contains('Masuk Masjid')), isTrue);
    expect(duas.any((d) => d.title.contains('Bangun Tidur')), isTrue);
    expect(duas.any((d) => d.title.contains('Naik Kendaraan')), isTrue);
  });
}
