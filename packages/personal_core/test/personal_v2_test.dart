import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  test('nama Arab surah & juz dari dataset', () {
    expect(surahs.first.arabicName, isNotEmpty);
    expect(surahArabicNames.length, 114);
    expect(juzStarts.length, 30);
    expect(juzStarts[0], (1, 1));
    expect(juzStarts[1], (2, 142));
    expect(juzOf(2, 141), 1);
    expect(juzOf(2, 142), 2);
    expect(juzOf(114, 6), 30);
  });

  test('doa Qur\'ani dikelompokkan per rentang ayat', () {
    expect(quranicDuaRanges, isNotEmpty);
    for (final (s, a, b) in quranicDuaRanges) {
      expect(a <= b && b <= surahs[s - 1].ayahCount, isTrue);
    }
  });

  test('profil: nama panggilan, onboarding, target tilawah tersimpan', () async {
    final store = InMemoryStore();
    final repo = SettingsRepository(store);
    final s = await repo.load();
    expect(s.onboardingDone, isFalse);
    expect(s.displayName, isNull);
    expect(s.tilawahTargetPages, 20);
    await repo.save(s.copyWith(onboardingDone: true, displayName: 'Ahmad', tilawahTargetPages: 10));
    final again = await repo.load();
    expect(again.onboardingDone, isTrue);
    expect(again.displayName, 'Ahmad');
    expect(again.tilawahTargetPages, 10);
  });

  test('tilawah halaman per hari & ringkasan mingguan', () async {
    final repo = TrackerRepository(InMemoryStore());
    final d = DateTime(2026, 11, 20);
    await repo.addTilawahPages(d, 5);
    await repo.addTilawahPages(d, 7);
    expect(await repo.tilawahPages(d), 12);
    for (final p in TrackerItem.values) {
      await repo.toggle(d, p);
    }
    final week = await repo.week(d);
    expect(week.length, 7);
    expect(week.last.day, d);
    expect(week.last.progress, 1.0);
    expect(week.first.progress, 0.0);
    expect(await repo.bestPrayerStreak(d), 1);
  });

  test('tasbih bisa dikurangi tanpa negatif', () async {
    final repo = TasbihRepository(InMemoryStore());
    await repo.increment('tasbih');
    expect(await repo.decrement('tasbih'), 0);
    expect(await repo.decrement('tasbih'), 0);
  });

  test('parser doa harian mendukung format objek data dan pencarian', () {
    const raw = '''
    {
      "data": [
        {
          "id": 1,
          "grup": "Doa Sebelum dan Sesudah Tidur",
          "nama": "Doa Bangun Tidur",
          "ar": "الْحَمْدُ لِلَّهِ",
          "tr": "Alhamdulillah",
          "idn": "Segala puji bagi Allah",
          "tentang": "HR. Bukhari",
          "tag": ["tidur", "pagi"]
        },
        {
          "id": 2,
          "grup": "Invalid",
          "nama": "",
          "ar": "",
          "idn": ""
        }
      ]
    }
    ''';
    final parsed = parseDailyDuasJson(raw);
    expect(parsed.length, 1);
    expect(parsed.first.title, 'Doa Bangun Tidur');
    expect(parsed.first.matches('tidur'), isTrue);
    expect(parsed.first.matches('alhamdulillah'), isTrue);
    expect(parsed.first.matches('makan'), isFalse);
  });
}
