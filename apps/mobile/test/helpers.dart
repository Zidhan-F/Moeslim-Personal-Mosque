import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:moeslim_mobile/app.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/quran/quran_source.dart';
import 'package:personal_core/personal_core.dart';

class FakeQuranSource implements QuranTextSource {
  final Map<int, List<Ayah>> data;
  FakeQuranSource([this.data = const {}]);

  @override
  Future<List<Ayah>?> load(int surah) async => data[surah];
}

/// 1 Jan 2025 05:00 UTC = 12:00 WIB (Jakarta).
final fixedNow = DateTime.utc(2025, 1, 1, 5, 0, 0);

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  KeyValueStore? store,
  DateTime? now,
  http.Client? client,
  TokenStore? tokens,
  QuranTextSource? quran,
}) async {
  final container = ProviderContainer(overrides: [
    storeProvider.overrideWithValue(store ?? InMemoryStore()),
    nowProvider.overrideWith((ref) => Stream.value(now ?? fixedNow)),
    headingProvider.overrideWith((ref) => Stream.value(null)),
    quranSourceProvider.overrideWithValue(quran ?? FakeQuranSource()),
    if (client != null) httpClientProvider.overrideWithValue(client),
    tokenStoreProvider.overrideWithValue(tokens ?? MemoryTokenStore()),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MoeslimApp()));
  await tester.pump();
  await tester.pump();
  return container;
}
