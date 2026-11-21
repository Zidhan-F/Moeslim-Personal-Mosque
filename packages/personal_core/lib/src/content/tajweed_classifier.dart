import 'tajweed.dart';

/// Pengklasifikasi tajwid berbasis aturan untuk teks **Tanzil Uthmani** (dipakai saat build, bukan di
/// perangkat). Semantik disamakan dengan classifier cpfair/quran-tajweed (CC BY 4.0 untuk datanya):
/// nama aturan, model huruf (huruf dasar + tanda Mn; spasi dihitung sebagai "huruf"; alif kecil U+0670
/// berdiri sendiri), dan cakupan rentang tiap aturan. Implementasi ini ditulis ulang — bukan salinan
/// pohon keputusan cpfair.
///
/// Konvensi Tanzil yang dimanfaatkan: huruf yang melebur (idgham/ikhfa) ditulis TANPA sukun, iqlab
/// ditandai mim kecil (U+06E2/U+06ED), huruf tak dibaca ditandai U+06DF, mad panjang ditandai U+0653.
///
/// Hasil: rentang [start, end) dalam unit kode string ayat (teks ayat 1 tanpa basmalah).
List<TajweedSpan> classifyTajweed(String text) => _Classifier(text).run();

const _sukun = 0x0652;
const _shadda = 0x0651;
const _maddah = 0x0653;
const _dagger = 0x0670;
const _silentCircle = 0x06DF;
const _tatweel = 0x0640;
const _space = 0x20;

const _qalqalah = 'بدجطق';
const _ikhfaLetters = 'تثجدذزسشصضطظفقك';
const _idghamGhunnah = 'يمون';
const _idghamNoGhunnah = 'لر';
const _heavy = 'هءحعخغ';

/// Lafaz Allah (ل ل ّ َ ه + harakat akhir) — lam-nya bukan lam syamsiyah.
final _allahForms = [
  for (final h in [0x0650, 0x064F, 0x064E])
    String.fromCharCodes([0x0644, 0x0644, _shadda, 0x064E, 0x0647, h])
];

/// Tanda non-spasi (kategori Unicode Mn) yang muncul di teks Tanzil.
bool _isMark(int c) =>
    (c >= 0x064B && c <= 0x065F) ||
    c == _dagger ||
    (c >= 0x06D6 && c <= 0x06DC) ||
    (c >= 0x06DF && c <= 0x06E4) ||
    (c >= 0x06E7 && c <= 0x06E8) ||
    (c >= 0x06EA && c <= 0x06ED);

bool _isTanween(int c) => c >= 0x064B && c <= 0x064D;
bool _isVowelInclTanween(int c) => (c >= 0x064B && c <= 0x0650) || c == _sukun;
bool _isVowelNoTanween(int c) => (c >= 0x064E && c <= 0x0650) || c == _sukun;

class _Letter {
  final int start, end; // [start, end)
  final String base;
  final List<int> cps;
  _Letter(this.start, this.end, this.base, this.cps);

  bool has(int c) => cps.contains(c);
  bool get shadda => has(_shadda);
  bool get tanween => cps.any(_isTanween);
  bool get vowelIncl => cps.any(_isVowelInclTanween);
  bool get vowelNoTanween => cps.any(_isVowelNoTanween);
  bool get fatha => has(0x064E);
  bool get explicitSukoon => has(_silentCircle) || has(_sukun);

  /// Tanpa harakat & tanpa sukun (syaddah boleh) — di Tanzil menandai huruf yang melebur.
  bool get implicitSukoon => !vowelIncl;
  bool get procSukoon => explicitSukoon || !vowelIncl;
  bool get maddah => has(_maddah);
  bool get hamza => cps.any((c) =>
      const [0x0624, 0x0626, 0x0655, 0x0625, 0x0623, 0x0654].contains(c));
  bool get nonInitialHamza =>
      cps.any((c) => const [0x0624, 0x0626, 0x0655, 0x0654].contains(c));
  bool get initialHamza =>
      cps.any((c) => const [0x0655, 0x0625, 0x0623].contains(c));
  bool get silentCircle => has(_silentCircle);
  bool get smallMeem => has(0x06E2) || has(0x06ED);
  bool get highNoon => has(0x06E8);
  bool get noDiacritics => cps.length == 1;
  bool get isSpace => base == ' ';
  bool baseIn(String set) => set.contains(base);
}

class _Classifier {
  final String text;
  late final List<int> cp = text.codeUnits;
  final letters = <_Letter>[];
  late final List<int> letterOf = List.filled(text.length, 0);

  _Classifier(this.text) {
    var i = 0;
    while (i < cp.length) {
      final start = i;
      i++;
      // U+0670 berdiri sendiri (kecuali menempel pada tatwil) dan tidak menyerap tanda sesudahnya.
      if (cp[start] != _dagger) {
        while (i < cp.length &&
            _isMark(cp[i]) &&
            !(cp[i] == _dagger && cp[i - 1] != _tatweel)) {
          i++;
        }
      }
      letters.add(_Letter(
          start, i, String.fromCharCode(cp[start]), cp.sublist(start, i)));
      for (var k = start; k < i; k++) {
        letterOf[k] = letters.length - 1;
      }
    }
  }

  _Letter? at(int i, int k) {
    final j = letterOf[i] + k;
    return j >= 0 && j < letters.length ? letters[j] : null;
  }

  bool isBase(int i) =>
      (!_isMark(cp[i]) && cp[i] != _tatweel) || cp[i] == _dagger;
  bool isFinal(_Letter l) => l.end >= cp.length || cp[l.end] == _space;
  bool finalInAyah(_Letter? l) => l != null && l.end >= cp.length;
  bool isInitial(int i) => i == 0 || cp[i - 1] == _space;
  bool lastCpInLetter(int i) => letters[letterOf[i]].end == i + 1;
  bool baseIs(_Letter? l, String set) => l != null && l.baseIn(set);

  bool isAllahStart(_Letter l) {
    for (final f in _allahForms) {
      final end = l.start + f.length;
      if (end <= text.length &&
          text.substring(l.start, end) == f &&
          (end == text.length || cp[end] == _space)) {
        return true;
      }
    }
    return false;
  }

  // ---------------------------------------------------------------- aturan: awal rentang

  bool startOf(TajweedRule r, int i) {
    final c = cp[i];
    final l0 = at(i, 0)!,
        m1 = at(i, -1),
        p1 = at(i, 1),
        p2 = at(i, 2),
        p3 = at(i, 3);
    switch (r) {
      case TajweedRule.hamzatWasl:
        return c == 0x0671 && m1 != null;
      case TajweedRule.lamSyamsiyah:
        return c == 0x0644 &&
            !l0.vowelIncl &&
            (p1?.shadda ?? false) &&
            !isAllahStart(l0);
      case TajweedRule.madThabii:
        if (c == _dagger) {
          return !isFinal(l0) &&
              !l0.maddah &&
              p1 != null &&
              !finalInAyah(p1) &&
              !l0.hamza;
        }
        if (c == 0x06E5) {
          return l0.maddah
              ? (p1?.vowelIncl ?? false)
              : (p1 != null && !finalInAyah(p1));
        }
        if (c == 0x06E6) return !l0.maddah && l0.procSukoon && p1 != null;
        return false;
      case TajweedRule.madAridLissukun:
        // Hanya di dua huruf terakhir ayat (waqaf di akhir ayat).
        if (p2 != null || !(m1?.vowelNoTanween ?? false)) return false;
        if (l0.vowelNoTanween) return (c == 0x064A && m1!.fatha) || c == 0x0648;
        if (l0.tanween) return false;
        final nextVowel =
            (p1?.vowelNoTanween ?? false) || (p1?.tanween ?? false);
        if (m1!.fatha) return nextVowel && !l0.maddah;
        return p1 != null && !l0.maddah && nextVowel;
      case TajweedRule.madLazim:
        if (!l0.maddah) return false;
        if (p1?.shadda ?? false) return isBase(i);
        if (m1?.vowelIncl ?? false) {
          if (!isBase(i) || isFinal(l0)) return false;
          return (p1?.vowelIncl ?? false)
              ? (p1?.explicitSukoon ?? false)
              : !(p1?.explicitSukoon ?? false);
        }
        if (m1?.base == 'ى' || !isBase(i)) return false;
        if ((m1?.explicitSukoon ?? false) || (p1?.explicitSukoon ?? false)) {
          return false;
        }
        return true;
      case TajweedRule.madJaizMunfashil:
        if (l0.maddah) {
          if (!isBase(i)) return false;
          if (p1?.base == 'ء' || (p1?.nonInitialHamza ?? false)) return false;
          if (c == _dagger) {
            return (p1?.initialHamza ?? false) || (p1?.explicitSukoon ?? false);
          }
          if (p2?.initialHamza ?? false) return true;
          if (p1?.explicitSukoon ?? false) {
            return !(p2?.nonInitialHamza ?? false) && p2 != null;
          }
          if (p2?.base == 'ء') return true;
          return p1?.initialHamza ?? false;
        }
        if (c == 0x0649) {
          return (p1?.maddah ?? false) &&
              p2 != null &&
              !(m1?.explicitSukoon ?? false);
        }
        return false;
      case TajweedRule.madWajibMuttashil:
        if (!l0.maddah || !isBase(i) || isFinal(l0)) return false;
        if ((p1?.explicitSukoon ?? false) || (p1?.initialHamza ?? false)) {
          return false;
        }
        if (p1?.base == 'ء') return true;
        if (p1?.nonInitialHamza ?? false) {
          return (p3?.explicitSukoon ?? false)
              ? (c == 0x0627 || c == _dagger)
              : true;
        }
        return false;
      case TajweedRule.qalqalah:
        if (!_qalqalah.contains(String.fromCharCode(c))) return false;
        return l0.explicitSukoon || (p1 == null && !l0.maddah);
      case TajweedRule.silent:
        if (l0.silentCircle) {
          return const [0x0627, 0x0648, 0x064A, 0x0649].contains(c);
        }
        if (p1?.base == String.fromCharCode(_dagger)) {
          return c == 0x0648 && !l0.vowelIncl;
        }
        return i + 1 < cp.length && cp[i + 1] == 0x06DC;
      case TajweedRule.ghunnah:
        if ((c != 0x0646 && c != 0x0645) || !l0.shadda) return false;
        if (!isInitial(i)) return true;
        if (!baseIs(p1, _heavy)) return false;
        final m2 = at(i, -2), m3 = at(i, -3);
        if (baseIs(m2, 'نم') ||
            (m2?.tanween ?? false) ||
            (m3?.tanween ?? false)) {
          return false;
        }
        return m3 != null;
      case TajweedRule.idghamBighunnah:
      case TajweedRule.idghamBilaghunnah:
        final set = r == TajweedRule.idghamBighunnah
            ? _idghamGhunnah
            : _idghamNoGhunnah;
        if (_isTanween(c)) {
          return baseIs(p2, set) || (baseIs(p3, set) && !isFinal(l0));
        }
        if (c == 0x0646) {
          return baseIs(p2, set) &&
              l0.implicitSukoon &&
              isFinal(l0) &&
              (r == TajweedRule.idghamBilaghunnah || m1 != null);
        }
        return false;
      case TajweedRule.idghamMutajanisain:
        if (!isBase(i)) return false;
        if (l0.baseIn('تد')) {
          if (!l0.implicitSukoon) return false;
          if (baseIs(p2, 'تد')) {
            return l0.baseIn('تط') ? !baseIs(p2, 'تط') : baseIs(p2, 'تط');
          }
          return true;
        }
        if (baseIs(p2, 'ظذ')) {
          if (!(l0.baseIn('ثذ') && l0.implicitSukoon)) return false;
          return l0.baseIn('ظذ') ? !baseIs(p2, 'ثذ') : true;
        }
        return l0.base == 'ب' && l0.implicitSukoon && p2?.base == 'م';
      case TajweedRule.idghamMutaqaribain:
        if (!isBase(i)) return false;
        if (p2?.base == 'ر') {
          if (l0.base != 'ل') return false;
          if (baseIs(m1, 'كق')) return l0.implicitSukoon;
          return l0.noDiacritics && m1 != null && !m1.noDiacritics;
        }
        return l0.baseIn('كق') &&
            baseIs(p1, 'كق') &&
            l0.noDiacritics &&
            (p2?.noDiacritics ?? false);
      case TajweedRule.idghamMimi:
        return isBase(i) &&
            l0.base == 'م' &&
            l0.implicitSukoon &&
            p2?.base == 'م';
      case TajweedRule.ikhfa:
        if (c == 0x0646) {
          if (!l0.implicitSukoon) return false;
          return baseIs(p1, _ikhfaLetters) ||
              (baseIs(p2, _ikhfaLetters) && isFinal(l0));
        }
        if (_isTanween(c)) {
          return baseIs(p2, _ikhfaLetters) ||
              (baseIs(p3, _ikhfaLetters) && !isFinal(l0));
        }
        return c == 0x06E8;
      case TajweedRule.ikhfaSyafawi:
        return isBase(i) &&
            l0.base == 'م' &&
            l0.implicitSukoon &&
            p2 != null &&
            p2.base != 'م' &&
            !p2.noDiacritics;
      case TajweedRule.iqlab:
        if (!l0.smallMeem || isBase(i)) return false;
        // Edisi teks ini juga memakai mim kecil (U+06ED) pada tanwin non-izhar; iqlab hanya sebelum ب.
        final next = (p1?.isSpace ?? false) ? p2 : p1;
        if (next?.base != 'ب') return false;
        if (!l0.tanween) return true;
        return _isTanween(c) && p2 != null;
    }
  }

  // ---------------------------------------------------------------- aturan: akhir rentang

  bool endOf(TajweedRule r, int i, {required bool prevInRule}) {
    final l0 = at(i, 0)!, m1 = at(i, -1);
    switch (r) {
      case TajweedRule.hamzatWasl:
      case TajweedRule.lamSyamsiyah:
      case TajweedRule.madThabii:
      case TajweedRule.madAridLissukun:
      case TajweedRule.idghamMutajanisain:
      case TajweedRule.idghamMutaqaribain:
        return true;
      case TajweedRule.madLazim:
      case TajweedRule.madJaizMunfashil:
      case TajweedRule.madWajibMuttashil:
      case TajweedRule.ikhfaSyafawi:
        return !isBase(i);
      case TajweedRule.qalqalah:
      case TajweedRule.silent:
        return lastCpInLetter(i) || !l0.explicitSukoon;
      case TajweedRule.ghunnah:
        return lastCpInLetter(i) || (finalInAyah(l0) && !isBase(i));
      case TajweedRule.idghamBighunnah:
      case TajweedRule.idghamBilaghunnah:
        return !isBase(i) && (m1?.isSpace ?? false) && lastCpInLetter(i);
      case TajweedRule.idghamMimi:
        return !isBase(i) && lastCpInLetter(i);
      case TajweedRule.ikhfa:
        if (isBase(i)) return false;
        return prevInRule
            ? (m1?.noDiacritics ?? false)
            : (m1?.highNoon ?? false);
      case TajweedRule.iqlab:
        if (m1?.isSpace ?? false) return true;
        return isBase(i) && !lastCpInLetter(i);
    }
  }

  List<TajweedSpan> run() {
    final out = <TajweedSpan>[];
    final queues = {for (final r in TajweedRule.values) r: <int>[]};
    int? letterStart, lastLetterStart;
    for (var i = 0; i < cp.length; i++) {
      if (isBase(i)) {
        lastLetterStart = letterStart;
        letterStart = i;
      }
      for (final r in TajweedRule.values) {
        final q = queues[r]!;
        if (startOf(r, i)) q.add(i);
        if (q.isEmpty) continue;
        final prevInRule =
            lastLetterStart != null && q.any((s) => s <= lastLetterStart!);
        if (endOf(r, i, prevInRule: prevInRule)) {
          out.add(TajweedSpan(q.removeAt(0), i + 1, r));
        }
      }
    }
    // Rentang yang tak tertutup sampai akhir ayat dibuang (pada cpfair memicu assert).
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }
}
