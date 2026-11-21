import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

const manifestJson = {
  'version': 1,
  'recitations': [
    {
      'id': 'qari-a',
      'qari': 'Qari A',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/a/',
      'license': 'Izin tertulis 2026',
      'attribution': 'Rekaman Qari A',
      'surahs': [1, 112],
    },
    {
      'id': 'qari-b',
      'qari': 'Qari B',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/b',
      'license': 'CC BY-ND',
      'attribution': 'Rekaman Qari B',
      'surahs': 'all',
    },
    // Katalog lama berisi entri irama: diabaikan.
    {
      'id': 'lama-irama',
      'qari': 'X',
      'naghom': 'bayyati',
      'base_url': 'x',
      'license': 'x',
      'attribution': 'x'
    },
    {
      'id': 'jenis-salah',
      'qari': 'X',
      'kind': 'mujawwad',
      'base_url': 'x',
      'license': 'L',
      'attribution': 'X'
    },
    {
      'id': 'tanpa-lisensi',
      'qari': 'X',
      'kind': 'murattal',
      'base_url': 'x',
      'license': '',
      'attribution': 'x'
    },
  ],
};

void main() {
  final manifest = AudioManifest.fromJson(manifestJson);

  test('hanya murattal berlisensi yang terbaca', () {
    expect(manifest.recitations.map((r) => r.id), ['qari-a', 'qari-b']);
  });

  test('qari per surah & cakupan mushaf', () {
    expect(manifest.recitationsFor(1).map((r) => r.id), ['qari-a', 'qari-b']);
    expect(manifest.recitationsFor(2).map((r) => r.id), ['qari-b']);
    expect(manifest.murattalCovers(114), isTrue);
    expect(AudioManifest.empty.murattalCovers(1), isFalse);
  });

  test('URL per ayat berformat SSSAAA.mp3 (garis miring akhir dibuang)', () {
    final r = manifest.recitations.first;
    expect(r.ayahUrl(1, 7), 'https://cdn.test/a/001007.mp3');
    expect(r.ayahUrl(112, 4), 'https://cdn.test/a/112004.mp3');
  });

  test('playlist surah penuh dan rentang ayat', () {
    final r = manifest.recitations[1];
    expect(r.playlist(112).map((t) => t.ayah), [1, 2, 3, 4]);
    expect(r.playlist(2, fromAyah: 255, toAyah: 257).map((t) => t.ayah),
        [255, 256, 257]);
    expect(() => r.playlist(1, fromAyah: 8), throwsRangeError);
    expect(() => manifest.recitations.first.playlist(2), throwsArgumentError);
  });

  test('preferensi qari tersimpan lokal', () async {
    final repo = AudioPreferenceRepository(InMemoryStore());
    expect(await repo.recitationId(), isNull);
    await repo.save(recitationId: 'qari-b');
    expect(await repo.recitationId(), 'qari-b');
  });
}
