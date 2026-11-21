import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryStore store;
  setUp(() => store = InMemoryStore());

  test('settings default Jakarta + Kemenag, dapat disimpan', () async {
    final repo = SettingsRepository(store);
    final s = await repo.load();
    expect(s.location.name, 'Jakarta');
    expect(s.method, CalculationMethod.kemenag);
    await repo.save(s.copyWith(
      location: indonesianCities.firstWhere((c) => c.name == 'Makassar'),
      adjustments: {Prayer.isha: 2},
      hijriOffset: -1,
      fontScale: 1.2,
    ));
    final again = await SettingsRepository(store).load();
    expect(again.location.name, 'Makassar');
    expect(again.adjustments[Prayer.isha], 2);
    expect(again.hijriOffset, -1);
    expect(again.fontScale, 1.2);
  });

  test('settings tahan data rusak', () async {
    await store.write('settings', '{bukan json');
    final s = await SettingsRepository(store).load();
    expect(s.location.name, 'Jakarta');
  });

  test('tasbih menghitung, reset, dan menyimpan', () async {
    final repo = TasbihRepository(store);
    expect(await repo.increment('tasbih'), 1);
    expect(await repo.increment('tasbih'), 2);
    expect(await TasbihRepository(store).count('tasbih'), 2);
    await repo.reset('tasbih');
    expect(await repo.count('tasbih'), 0);
    await repo.setTarget('tasbih', 99);
    expect(await repo.target('tasbih'), 99);
  });

  test('tracker ibadah harian dan streak', () async {
    final repo = TrackerRepository(store);
    final d1 = DateTime(2026, 11, 18), d2 = DateTime(2026, 11, 19), d3 = DateTime(2026, 11, 20);
    for (final d in [d1, d2, d3]) {
      for (final p in TrackerItem.prayers) {
        await repo.toggle(d, p);
      }
    }
    await repo.toggle(d3, TrackerItem.tilawah);
    expect((await repo.day(d3)).contains(TrackerItem.tilawah), isTrue);
    expect(await repo.prayerStreak(d3), 3);
    await repo.toggle(d2, TrackerItem.subuh); // batalkan subuh hari ke-2
    expect(await repo.prayerStreak(d3), 1);
    expect(await repo.progress(d3), closeTo(6 / TrackerItem.values.length, 1e-9));
  });

  test('bookmark dan lanjut baca', () async {
    final repo = QuranProgressRepository(store);
    await repo.toggleBookmark(2, 255);
    await repo.toggleBookmark(36, 1);
    expect(await repo.bookmarks(), [const AyahRef(2, 255), const AyahRef(36, 1)]);
    await repo.toggleBookmark(2, 255);
    expect(await repo.bookmarks(), [const AyahRef(36, 1)]);
    await repo.setLastRead(const AyahRef(18, 10));
    expect(await repo.lastRead(), const AyahRef(18, 10));
  });

  test('masjid favorit dengan cache bertimestamp', () async {
    final repo = FavoriteMosqueRepository(store);
    await repo.follow(const FollowedMosque(slug: 'masjid-a', name: 'Masjid A'));
    await repo.follow(const FollowedMosque(slug: 'masjid-a', name: 'Masjid A'));
    expect((await repo.all()).length, 1);
    final at = DateTime.utc(2026, 11, 20, 1);
    await repo.saveCache('masjid-a', {'events': []}, at);
    final cache = await repo.cache('masjid-a');
    expect(cache!.fetchedAt, at);
    await repo.unfollow('masjid-a');
    expect(await repo.all(), isEmpty);
    expect(await repo.cache('masjid-a'), isNull);
  });

  test('pengaturan adzan per waktu salat dan pilihan muadzin tersimpan', () async {
    final repo = SettingsRepository(store);
    final initial = await repo.load();
    expect(initial.notificationsEnabled, isTrue);
    expect(initial.activeAdzanCount, 5);
    expect(initial.muadzin.id, 'makkah');
    expect(initial.isAdzanActiveFor(Prayer.fajr), isTrue);

    final updated = initial
        .setPrayerAdzan(Prayer.asr, false)
        .setPrayerAdzan(Prayer.isha, false)
        .copyWith(muadzinId: 'madinah');
    await repo.save(updated);

    final loaded = await SettingsRepository(store).load();
    expect(loaded.muadzin.id, 'madinah');
    expect(loaded.muadzin.name, contains('Essam Bukhari'));
    expect(loaded.isAdzanActiveFor(Prayer.fajr), isTrue);
    expect(loaded.isAdzanActiveFor(Prayer.asr), isFalse);
    expect(loaded.isAdzanActiveFor(Prayer.isha), isFalse);
    expect(loaded.activeAdzanCount, 3);

    final disabledAll = loaded.copyWith(notificationsEnabled: false);
    expect(disabledAll.isAdzanActiveFor(Prayer.fajr), isFalse);
    expect(disabledAll.activeAdzanCount, 0);
  });
}
