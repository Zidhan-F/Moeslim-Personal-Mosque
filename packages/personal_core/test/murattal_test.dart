import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

final manifest = AudioManifest.fromJson({
  'version': 2,
  'recitations': [
    {
      'id': 'qari-m',
      'qari': 'Qari M',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/m',
      'license': 'Izin tertulis',
      'attribution': 'Qari M',
      'surahs': 'all'
    },
    {
      'id': 'qari-b',
      'qari': 'Qari B',
      'naghom': 'bayyati',
      'base_url': 'https://cdn.test/b',
      'license': 'Izin',
      'attribution': 'Qari B',
      'surahs': [1]
    },
    {
      'id': 'tanpa-lisensi',
      'qari': 'X',
      'kind': 'murattal',
      'base_url': 'https://cdn.test/x',
      'license': '',
      'attribution': 'X',
      'surahs': 'all'
    },
    {
      'id': 'jenis-salah',
      'qari': 'X',
      'kind': 'mujawwad',
      'base_url': 'https://cdn.test/y',
      'license': 'L',
      'attribution': 'X',
      'surahs': 'all'
    },
  ],
});

void main() {
  test('rekaman murattal terbaca; tanpa lisensi / jenis tak dikenal diabaikan', () {
    expect(manifest.recitations.map((r) => r.id), ['qari-m', 'qari-b']);
    expect(manifest.recitations.first.isMurattal, isTrue);
    expect(manifest.recitations.first.optionKey, murattalKey);
    expect(manifest.recitations.last.optionKey, 'bayyati');
  });

  test('pilihan bacaan: 7 irama lalu Murattal sebagai cadangan', () {
    final o = manifest.optionsFor(2);
    expect(o.length, 8);
    expect(o.last.key, murattalKey);
    expect(o.last.style, isNull);
    expect(o.last.available, isTrue);
    expect(o.take(7).map((x) => x.key), naghomStyles.map((s) => s.slug));
    expect(o.first.available, isFalse); // bayyati hanya surah 1
  });

  test('naghomOptionsFor tetap hanya 7 irama & murattal tidak dihitung sebagai irama', () {
    expect(manifest.naghomOptionsFor(1).length, 7);
    expect(manifest.coverageGaps().containsKey(murattalKey), isFalse);
  });

  test('cakupan murattal untuk seluruh mushaf', () {
    expect(manifest.murattalCovers(114), isTrue);
    expect(AudioManifest.empty.murattalCovers(1), isFalse);
  });
}
