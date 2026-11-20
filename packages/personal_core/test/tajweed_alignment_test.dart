import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  test('kedua ejaan nama aturan idgham diterima', () {
    expect(TajweedRule.fromSource('idghaam_mutajanisayn'), TajweedRule.idghamMutajanisain);
    expect(TajweedRule.fromSource('idghaam_mutajaanisain'), TajweedRule.idghamMutajanisain);
    expect(TajweedRule.fromSource('idghaam_mutaqaribayn'), TajweedRule.idghamMutaqaribain);
    expect(TajweedRule.fromSource('idghaam_mutaqaaribain'), TajweedRule.idghamMutaqaribain);
  });

  test('anotasi yang sejajar dengan teks lolos pemeriksaan isi', () {
    // ٱلْحَمْدُ : hamzah washal di indeks 0, lam syamsiyah... (contoh sederhana)
    final text = {(1, 2): 'ٱلْح'};
    final spans = {
      (1, 2): const [TajweedSpan(0, 1, TajweedRule.hamzatWasl), TajweedSpan(1, 2, TajweedRule.lamSyamsiyah)],
    };
    final r = checkTajweedAlignment(text, spans);
    expect(r.anchorsChecked, 2);
    expect(r.ratio, 1.0);
    expect(r.misalignedAyat, isEmpty);
  });

  test('anotasi yang bergeser (edisi teks berbeda) terdeteksi', () {
    final text = {(2, 5): 'xٱل', (2, 6): 'ٱ'};
    final spans = {
      (2, 5): const [TajweedSpan(0, 1, TajweedRule.hamzatWasl)], // bergeser 1 karakter
      (2, 6): const [TajweedSpan(0, 1, TajweedRule.hamzatWasl)],
    };
    final r = checkTajweedAlignment(text, spans);
    expect(r.ratio, 0.5);
    expect(r.misalignedAyat, [(2, 5)]);
  });
}
