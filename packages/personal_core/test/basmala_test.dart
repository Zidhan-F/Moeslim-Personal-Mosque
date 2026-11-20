import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  const b = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  test('basmalah di awal ayat 1 dilepas (kecuali Al-Fatihah & At-Taubah)', () {
    expect(stripLeadingBasmala(2, 1, '$b الٓمٓ'), 'الٓمٓ');
    expect(stripLeadingBasmala(95, 1, 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلتِّينِ'), 'وَٱلتِّينِ');
    expect(stripLeadingBasmala(1, 1, b), b); // Al-Fatihah: basmalah adalah ayat 1
    expect(stripLeadingBasmala(2, 2, '$b x'), '$b x'); // hanya ayat 1
    expect(stripLeadingBasmala(9, 1, 'بَرَآءَةٌ'), 'بَرَآءَةٌ');
  });

  test('urutan harakat berbeda (syaddah sebelum/sesudah fathah) tetap dikenali', () {
    // Data sumber: lam + syaddah(0651) + fathah(064E); kanonik: fathah lalu syaddah.
    const dataOrder = '\u0628\u0650\u0633\u0652\u0645\u0650 \u0671\u0644\u0644\u0651\u064E\u0647\u0650 '
        '\u0671\u0644\u0631\u0651\u064E\u062D\u0652\u0645\u064E\u0670\u0646\u0650 '
        '\u0671\u0644\u0631\u0651\u064E\u062D\u0650\u064A\u0645\u0650 \u0627\u0644\u0653\u0645\u0653';
    expect(stripLeadingBasmala(2, 1, dataOrder), '\u0627\u0644\u0653\u0645\u0653');
    // Bukan basmalah (mis. "بِسْمِ" saja) tidak boleh terpotong.
    expect(
        stripLeadingBasmala(11, 1, '\u0628\u0650\u0633\u0652\u0645\u0650 \u0671\u0644\u0644\u0651\u064E\u0647\u0650'),
        '\u0628\u0650\u0633\u0652\u0645\u0650 \u0671\u0644\u0644\u0651\u064E\u0647\u0650');
  });

  test('basmalah ditampilkan sebagai pembuka surah kecuali Al-Fatihah & At-Taubah', () {
    expect(showsBasmalaHeader(1), isFalse);
    expect(showsBasmalaHeader(9), isFalse);
    expect(showsBasmalaHeader(2), isTrue);
    expect(basmala, b);
  });
}
