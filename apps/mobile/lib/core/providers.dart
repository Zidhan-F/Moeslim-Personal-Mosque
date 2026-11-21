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
  final now = wallClock(deviceNow, s.effectiveUtcOffset);
  return _statusFor(now, s.timesFor(now), () => s.timesFor(DateTime(now.year, now.month, now.day + 1)));
}

PrayerStatus _statusFor(DateTime now, PrayerTimes today, PrayerTimes Function() tomorrowTimes) {
  final next = today.nextAfter(now);
  if (next != null) {
    return PrayerStatus(now, today, next, today.timeOf(next), today.currentAt(now));
  }
  final tomorrow = tomorrowTimes();
  return PrayerStatus(now, today, Prayer.fajr, tomorrow.fajr, Prayer.isha);
}

// Recalculate astronomical times only when the local day or settings change.
final _dailyPrayerTimesProvider = Provider<({PrayerTimes today, PrayerTimes tomorrow})?>((ref) {
  final settings = ref.watch(settingsProvider).value;
  if (settings == null) return null;
  final date = ref.watch(
    nowProvider.select((value) {
      final deviceNow = value.value;
      if (deviceNow == null) return null;
      final local = wallClock(deviceNow, settings.effectiveUtcOffset);
      return DateTime(local.year, local.month, local.day);
    }),
  );
  if (date == null) return null;
  return (today: settings.timesFor(date), tomorrow: settings.timesFor(date.add(const Duration(days: 1))));
});

final prayerStatusProvider = Provider<AsyncValue<PrayerStatus>>((ref) {
  final settings = ref.watch(settingsProvider);
  final now = ref.watch(nowProvider);
  final times = ref.watch(_dailyPrayerTimesProvider);
  return switch ((settings, now)) {
    (AsyncData(value: final s), AsyncData(value: final n)) =>
      times == null
          ? const AsyncLoading()
          : AsyncData(_statusFor(wallClock(n, s.effectiveUtcOffset), times.today, () => times.tomorrow)),
    (AsyncError(:final error, :final stackTrace), _) => AsyncError(error, stackTrace),
    _ => const AsyncLoading(),
  };
});
