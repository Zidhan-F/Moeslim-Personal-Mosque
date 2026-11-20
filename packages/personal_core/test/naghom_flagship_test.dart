import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  test('ringkasan 7 irama persis sesuai materi pemilik produk', () {
    expect({
      for (final s in naghomStyles) s.name: s.summary
    }, {
      'Bayyati':
          'Memiliki 4 tingkat nada, berkarakter lembut, meliuk, dan sering digunakan pada awal atau akhir bacaan.',
      'Hijaz': 'Berkarakter cepat, lincah (allegro), dengan variasi nada yang tajam.',
      'Shaba': 'Berkarakter cepat, cenderung mendayu atau menggugah rasa haru, memiliki 4 tingkat nada.',
      'Rast': 'Memiliki 6 tingkat nada yang ringan dan cepat, sering dipakai untuk azan atau imam shalat.',
      'Jiharkah': 'Dimulai dengan suara lembut lalu meninggi (2 tingkat nada), sering dipakai saat takbiran.',
      'Sika': 'Berkarakter tenang, lembut, dan khusyuk dengan 4 jenis nada.',
      'Nahawand': 'Memiliki 5 tingkat nada yang cocok untuk ayat-ayat bernuansa sedih atau penuh perenungan.',
    });
  });

  test('label nada mengikuti istilah materi (tingkat / jenis)', () {
    String label(String slug) => naghomStyles.firstWhere((s) => s.slug == slug).toneLabel;
    expect(label('bayyati'), '4 tingkat nada');
    expect(label('sika'), '4 jenis nada');
    expect(label('jiharkah'), '2 tingkat nada');
    expect(label('hijaz'), 'Variasi nada tajam');
  });

  final m = AudioManifest.fromJson({
    'version': 1,
    'recitations': [
      {
        'id': 'm',
        'qari': 'M',
        'kind': 'murattal',
        'base_url': 'https://c/m',
        'license': 'L',
        'attribution': 'A',
        'surahs': 'all'
      },
      {
        'id': 'r',
        'qari': 'R',
        'naghom': 'rast',
        'base_url': 'https://c/r',
        'license': 'L',
        'attribution': 'A',
        'surahs': [1, 112]
      },
    ],
  });

  test('pilihan bacaan: 7 irama didahulukan, Murattal sebagai cadangan di akhir', () {
    final o = m.optionsFor(1);
    expect(o.map((x) => x.key), [...naghomStyles.map((s) => s.slug), murattalKey]);
    expect(o.last.label, 'Murattal (tanpa irama)');
  });

  test('daftar surah yang tersedia untuk satu irama', () {
    expect(m.surahsWithNaghom('rast'), [1, 112]);
    expect(m.surahsWithNaghom('sika'), isEmpty);
  });
}
