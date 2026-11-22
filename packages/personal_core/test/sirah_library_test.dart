import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

List<SirahChapter> of(SirahSection s) => [
      for (final c in sirahLibraryCatalog)
        if (c.section == s) c,
    ];

void main() {
  test('jumlah bab: 24 sirah, 25 nabi, 25 sahabat; id unik; urutan berurutan', () {
    expect(of(SirahSection.sirahNabawiyah).length, 24);
    expect(of(SirahSection.kisah25Nabi).length, 25);
    expect(of(SirahSection.biografiSahabat).length, 25);
    expect(sirahLibraryCatalog.map((c) => c.id).toSet().length, sirahLibraryCatalog.length);
    for (final s in SirahSection.values) {
      expect(of(s).map((c) => c.order), [for (var i = 1; i <= of(s).length; i++) i], reason: s.label);
    }
  });

  test('25 nabi lengkap, satu bab per nabi, sesuai urutan', () {
    const names = [
      'Adam', 'Idris', 'Nuh', 'Hud', 'Shalih', 'Ibrahim', 'Luth', "Isma'il", 'Ishaq', "Ya'qub", 'Yusuf', 'Ayyub',
      "Syu'aib", 'Musa', 'Harun', 'Dzulkifli', 'Dawud', 'Sulaiman', 'Ilyas', "Ilyasa'", 'Yunus', 'Zakariya', 'Yahya',
      "'Isa", 'Muhammad',
    ];
    final nabi = of(SirahSection.kisah25Nabi);
    for (var i = 0; i < 25; i++) {
      expect(nabi[i].title, startsWith('Nabi ${names[i]} '), reason: 'nabi ke-${i + 1}');
      expect(nabi[i].periodOrTitle, startsWith('Nabi ke-${i + 1} '));
    }
  });

  test('setiap bab detail: bersubjudul, cukup panjang, ada hikmah & rujukan, tanpa em dash', () {
    for (final c in sirahLibraryCatalog) {
      final headings = c.blocks.where((b) => b.kind == SirahBlockKind.heading);
      expect(headings.length, greaterThanOrEqualTo(2), reason: c.id);
      expect(c.narrative.split(RegExp(r'\s+')).length, greaterThan(130), reason: c.id);
      expect(c.hikmah, isNotEmpty);
      expect(c.reference, isNotEmpty);
      for (final t in [c.title, c.periodOrTitle, c.narrative, c.hikmah, c.reference]) {
        expect(t.contains('\u2014') || t.contains('\u2013'), isFalse, reason: c.id);
      }
    }
  });

  test('pencarian menemukan kisah dari isi bab', () {
    expect(sirahLibraryCatalog.where((c) => c.matches('Gua Tsur')).map((c) => c.id), contains('sirah_14_hijrah_madinah'));
    expect(sirahLibraryCatalog.where((c) => c.matches('hud-hud')).map((c) => c.id), contains('nabi_18_sulaiman'));
    expect(sirahLibraryCatalog.where((c) => c.matches('Dzatun Nithaqain')).single.id, 'sahabat_25_asma');
  });
}
