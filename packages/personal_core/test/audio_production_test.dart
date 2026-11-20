import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

Set<String> allFiles({Set<String> except = const {}}) => {
      for (final s in surahs)
        for (var a = 1; a <= s.ayahCount; a++)
          '${s.number.toString().padLeft(3, '0')}${a.toString().padLeft(3, '0')}.mp3',
    }..removeAll(except);

void main() {
  group('CoverageReport', () {
    test('lengkap bila 6236 berkas ayat ada', () {
      final r = CoverageReport.fromFileNames(allFiles());
      expect(r.totalPresent, 6236);
      expect(r.complete, isTrue);
      expect(r.completeSurahs.length, 114);
    });

    test('melaporkan ayat yang hilang per surah dan mengabaikan berkas asing', () {
      final r = CoverageReport.fromFileNames(
          allFiles(except: {'002255.mp3', '114006.mp3'})..addAll({'cover.jpg', '115001.mp3', '001008.mp3'}));
      expect(r.complete, isFalse);
      expect(r.missing, {
        2: [255],
        114: [6]
      });
      expect(r.completeSurahs, isNot(contains(2)));
      expect(r.completeSurahs.length, 112);
      expect(r.unexpected, containsAll(['cover.jpg', '115001.mp3', '001008.mp3']));
    });

    test('ke manifest: "all" bila lengkap, daftar surah lengkap bila sebagian', () {
      final full = CoverageReport.fromFileNames(allFiles());
      expect(full.manifestSurahs, 'all');
      final part = CoverageReport.fromFileNames({'112001.mp3', '112002.mp3', '112003.mp3', '112004.mp3', '113001.mp3'});
      expect(part.manifestSurahs, [112]);
    });
  });

  group('Label Audacity → segmen ayat', () {
    test('parse label berurutan untuk Al-Ikhlas', () {
      const labels = '0.000000\t5.250000\t1\n5.250000\t9.100000\t2\n9.100000\t13.000000\t3\n13.000000\t18.400000\t4\n';
      final segs = parseAyahLabels(labels, 112);
      expect(segs.map((s) => s.ayah), [1, 2, 3, 4]);
      expect(segs[1].start, 5.25);
      expect(segs.last.end, 18.4);
      expect(segs.first.fileName, '112001.mp3');
    });

    test('jumlah label harus sama dengan jumlah ayat', () {
      expect(() => parseAyahLabels('0\t1\t1\n', 112), throwsFormatException);
    });

    test('label ayat harus urut 1..n dan waktu valid', () {
      expect(() => parseAyahLabels('0\t1\t1\n1\t2\t3\n2\t3\t2\n3\t4\t4\n', 112), throwsFormatException);
      expect(() => parseAyahLabels('0\t1\t1\n1\t0.5\t2\n2\t3\t3\n3\t4\t4\n', 112), throwsFormatException);
    });

    test('argumen ffmpeg memotong tanpa re-encode ulang yang tidak perlu', () {
      final seg = parseAyahLabels('0\t5.25\t1\n5.25\t9.1\t2\n9.1\t13\t3\n13\t18.4\t4\n', 112)[1];
      expect(seg.ffmpegArgs('in.wav', 'out'), [
        '-y',
        '-hide_banner',
        '-loglevel',
        'error',
        '-i',
        'in.wav',
        '-ss',
        '5.250',
        '-to',
        '9.100',
        '-ac',
        '1',
        '-ar',
        '44100',
        '-b:a',
        '96k',
        'out/112002.mp3',
      ]);
    });
  });

  test('cakupan katalog per irama untuk seluruh mushaf', () {
    final m = AudioManifest.fromJson({
      'version': 1,
      'recitations': [
        for (final n in naghomStyles)
          {
            'id': 'q-${n.slug}',
            'qari': 'Q',
            'naghom': n.slug,
            'base_url': 'u',
            'license': 'L',
            'attribution': 'A',
            'surahs': n.slug == 'sika' ? [1] : 'all'
          },
      ],
    });
    final gaps = m.coverageGaps();
    expect(gaps.keys, ['sika']);
    expect(gaps['sika']!.length, 113);
    expect(m.allNaghomForAllSurahs, isFalse);
  });
}
