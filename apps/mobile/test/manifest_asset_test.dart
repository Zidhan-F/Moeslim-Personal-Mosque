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
    await tester.tap(find.text('Quran').last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('naghom-entry')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('coverage-bayyati'))).data, endsWith('Audio: 114/114 surah'));
    expect(tester.widget<Text>(find.byKey(const Key('coverage-rast'))).data, endsWith('Audio: 2/114 surah'));
  });
}
