import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'format.dart';

/// Di-override di main() dengan PrefsStore dan di test dengan InMemoryStore.
final storeProvider = Provider<KeyValueStore>((ref) => throw UnimplementedError('storeProvider belum di-override'));

/// Jam berjalan (detik). Di-override di test dengan waktu tetap.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

class SettingsNotifier extends AsyncNotifier<PersonalSettings> {
  late SettingsRepository _repo;

  @override
  Future<PersonalSettings> build() {
    _repo = SettingsRepository(ref.watch(storeProvider));
    return _repo.load();
  }

  Future<void> save(PersonalSettings s) async {
    state = AsyncData(s);
    await _repo.save(s);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, PersonalSettings>(SettingsNotifier.new);

final tasbihRepoProvider = Provider((ref) => TasbihRepository(ref.watch(storeProvider)));
final trackerRepoProvider = Provider((ref) => TrackerRepository(ref.watch(storeProvider)));
final quranProgressProvider = Provider((ref) => QuranProgressRepository(ref.watch(storeProvider)));
final naghomProgressProvider = Provider((ref) => NaghomProgressRepository(ref.watch(storeProvider)));
final favoriteMosqueRepoProvider = Provider((ref) => FavoriteMosqueRepository(ref.watch(storeProvider)));

/// Status jadwal hari ini untuk lokasi aktif: waktu sholat, sholat berikutnya, dan sisa waktu.
class PrayerStatus {
  final DateTime now;
  final PrayerTimes today;
  final Prayer nextPrayer;
  final DateTime nextTime;
  final Prayer? current;

  const PrayerStatus(this.now, this.today, this.nextPrayer, this.nextTime, this.current);

  Duration get remaining => nextTime.difference(now);
}

PrayerStatus computeStatus(PersonalSettings s, DateTime deviceNow) {
  final now = wallClock(deviceNow, s.location.utcOffset);
  final today = s.timesFor(now);
  final next = today.nextAfter(now);
  if (next != null) {
    return PrayerStatus(now, today, next, today.timeOf(next), today.currentAt(now));
  }
  final tomorrow = s.timesFor(DateTime(now.year, now.month, now.day + 1));
  return PrayerStatus(now, today, Prayer.fajr, tomorrow.fajr, Prayer.isha);
}

final prayerStatusProvider = Provider<AsyncValue<PrayerStatus>>((ref) {
  final settings = ref.watch(settingsProvider);
  final now = ref.watch(nowProvider);
  return switch ((settings, now)) {
    (AsyncData(value: final s), AsyncData(value: final n)) => AsyncData(computeStatus(s, n)),
    (AsyncError(:final error, :final stackTrace), _) => AsyncError(error, stackTrace),
    _ => const AsyncLoading(),
  };
});
