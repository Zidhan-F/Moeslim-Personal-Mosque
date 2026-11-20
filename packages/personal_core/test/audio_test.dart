import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

const manifestJson = {
  'version': 1,
  'recitations': [
    {
      'id': 'qari-a-bayyati',
      'qari': 'Qari A',
      'naghom': 'bayyati',
      'base_url': 'https://cdn.test/a/bayyati',
      'license': 'Izin tertulis 2026',
      'attribution': 'Rekaman Qari A',
      'surahs': [1, 112],
    },
    {
      'id': 'qari-b-bayyati',
      'qari': 'Qari B',
      'naghom': 'bayyati',
      'base_url': 'https://cdn.test/b/bayyati',
      'license': 'CC BY-ND',
      'attribution': 'Rekaman Qari B',
      'surahs': 'all',
    },
    {
      'id': 'qari-a-rast',
      'qari': 'Qari A',
      'naghom': 'rast',
      'base_url': 'https://cdn.test/a/rast',
      'license': 'Izin tertulis 2026',
      'attribution': 'Rekaman Qari A',
      'surahs': [1],
    },
    {
      'id': 'rusak',
      'naghom': 'tidak-dikenal',
      'base_url': 'x',
      'license': 'x',
      'attribution': 'x',
      'surahs': 'all',
      'qari': 'x'
    },
    {
      'id': 'tanpa-lisensi',
      'naghom': 'hijaz',
      'base_url': 'x',
      'license': '',
      'attribution': 'x',
      'surahs': 'all',
      'qari': 'x'
    },
  ],
};

void main() {
  final manifest = AudioManifest.fromJson(manifestJson);

  test('entri naghom tidak dikenal atau tanpa lisensi diabaikan', () {
    expect(manifest.recitations.map((r) => r.id), ['qari-a-bayyati', 'qari-b-bayyati', 'qari-a-rast']);
  });

  test('pilihan 7 naghom per surah beserta ketersediaannya', () {
    final options = manifest.naghomOptionsFor(1);
    expect(options.map((o) => o.style.slug), naghomStyles.map((s) => s.slug));
    expect(options.firstWhere((o) => o.style.slug == 'bayyati').recitations.length, 2);
    expect(options.firstWhere((o) => o.style.slug == 'rast').available, isTrue);
    expect(options.firstWhere((o) => o.style.slug == 'hijaz').available, isFalse);

    final s2 = manifest.naghomOptionsFor(2);
    expect(s2.firstWhere((o) => o.style.slug == 'rast').available, isFalse);
    expect(s2.firstWhere((o) => o.style.slug == 'bayyati').recitations.single.id, 'qari-b-bayyati');
  });

  test('URL per ayat berformat SSSAAA.mp3', () {
    final r = manifest.recitations.first;
    expect(r.ayahUrl(1, 7), 'https://cdn.test/a/bayyati/001007.mp3');
    expect(r.ayahUrl(112, 4), 'https://cdn.test/a/bayyati/112004.mp3');
  });

  test('playlist surah penuh dan rentang ayat', () {
    final r = manifest.recitations[1];
    final full = r.playlist(112);
    expect(full.map((t) => t.ayah), [1, 2, 3, 4]);
    final range = r.playlist(2, fromAyah: 255, toAyah: 257);
    expect(range.map((t) => t.ayah), [255, 256, 257]);
    expect(() => r.playlist(1, fromAyah: 8), throwsRangeError);
    expect(() => manifest.recitations.first.playlist(2), throwsArgumentError); // tidak mencakup surah 2
  });

  test('preferensi naghom & qari tersimpan lokal', () async {
    final repo = AudioPreferenceRepository(InMemoryStore());
    expect(await repo.naghom(), isNull);
    await repo.save(naghom: 'rast', recitationId: 'qari-a-rast');
    expect(await repo.naghom(), 'rast');
    expect(await repo.recitationId(), 'qari-a-rast');
  });

  test('manifest kosong tetap memberi 7 opsi tidak tersedia', () {
    final empty = AudioManifest.fromJson({'version': 1, 'recitations': []});
    final o = empty.naghomOptionsFor(1);
    expect(o.length, 7);
    expect(o.every((x) => !x.available), isTrue);
  });
}
