import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  test('katalog audio bawaan valid: tidak ada entri yang diabaikan diam-diam', () {
    final raw = jsonDecode(File('assets/audio/manifest.json').readAsStringSync()) as Map<String, dynamic>;
    final parsed = AudioManifest.fromJson(raw);
    expect(
      parsed.recitations.length,
      (raw['recitations'] as List).length,
      reason: 'Setiap rekaman wajib punya naghom valid dan lisensi',
    );
    for (final r in parsed.recitations) {
      expect(Uri.tryParse(r.baseUrl)?.isScheme('https'), isTrue, reason: '${r.id}: base_url harus https');
    }
  });

  test('katalog bawaan: murattal tersedia untuk seluruh 114 surah', () {
    final m = AudioManifest.fromJson(
      jsonDecode(File('assets/audio/manifest.json').readAsStringSync()) as Map<String, dynamic>,
    );
    final murattal = m.recitations.where((r) => r.isMurattal).toList();
    expect(murattal.length, greaterThanOrEqualTo(1));
    for (var s = 1; s <= 114; s++) {
      expect(m.murattalCovers(s), isTrue, reason: 'surah $s');
    }
    expect(murattal.every((r) => r.attribution.isNotEmpty), isTrue);
    expect(murattal.first.ayahUrl(1, 1), endsWith('/001001.mp3'));
  });

  testWidgets('katalog Naghom menampilkan cakupan audio per irama', (tester) async {
    await pumpApp(
      tester,
      manifest: AudioManifest.fromJson({
        'version': 1,
        'recitations': [
          {
            'id': 'a',
            'qari': 'Q',
            'naghom': 'bayyati',
            'base_url': 'https://c/a',
            'license': 'L',
            'attribution': 'A',
            'surahs': 'all',
          },
          {
            'id': 'b',
            'qari': 'Q',
            'naghom': 'rast',
            'base_url': 'https://c/b',
            'license': 'L',
            'attribution': 'A',
            'surahs': [1, 112],
          },
        ],
      }),
    );
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('naghom-entry')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('coverage-bayyati'))).data, endsWith('Audio: 114/114 surah'));
    await tester.scrollUntilVisible(
      find.byKey(const Key('coverage-rast')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<Text>(find.byKey(const Key('coverage-rast'))).data, endsWith('Audio: 2/114 surah'));
  });
}
