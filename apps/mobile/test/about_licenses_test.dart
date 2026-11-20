import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';

void main() {
  testWidgets('Tentang & Lisensi: pernyataan non-komersial dan atribusi tiap rekaman', (tester) async {
    await pumpApp(
      tester,
      manifest: AudioManifest.fromJson({
        'version': 1,
        'recitations': [
          {
            'id': 'a',
            'qari': 'Qari A',
            'naghom': 'rast',
            'base_url': 'https://c/a',
            'license': 'CC BY-NC 4.0',
            'attribution': 'Rekaman Qari A — sumber X',
            'surahs': [1],
          },
          {
            'id': 'b',
            'qari': 'Qari B',
            'kind': 'murattal',
            'base_url': 'https://c/b',
            'license': 'Izin non-komersial tertulis',
            'attribution': 'Qari B',
            'surahs': 'all',
          },
        ],
      }),
    );
    await tester.tap(find.text('Profil').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('about-licenses')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('about-licenses')));
    await tester.pumpAndSettle();

    expect(find.textContaining('non-komersial'), findsWidgets);
    expect(find.textContaining('tanpa iklan'), findsOneWidget);
    expect(find.text('Rekaman Qari A — sumber X'), findsOneWidget);
    expect(find.textContaining('CC BY-NC 4.0'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Qari B'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Izin non-komersial tertulis'), findsOneWidget);
  });
}
