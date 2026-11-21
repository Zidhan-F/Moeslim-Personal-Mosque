import 'quran.dart';

String ayahFileName(int surah, int ayah) => '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}.mp3';

/// Laporan kelengkapan berkas per ayat (`SSSAAA.mp3`) untuk satu qari.
class CoverageReport {
  /// surah → daftar ayat yang belum ada berkasnya.
  final Map<int, List<int>> missing;
  final List<String> unexpected;
  final int totalPresent;

  const CoverageReport(this.missing, this.unexpected, this.totalPresent);

  static final int totalAyat = surahs.fold(0, (s, e) => s + e.ayahCount);

  factory CoverageReport.fromFileNames(Iterable<String> names) {
    final expected = <String>{
      for (final s in surahs)
        for (var a = 1; a <= s.ayahCount; a++) ayahFileName(s.number, a),
    };
    final present = names.toSet();
    final missing = <int, List<int>>{};
    for (final s in surahs) {
      for (var a = 1; a <= s.ayahCount; a++) {
        if (!present.contains(ayahFileName(s.number, a))) missing.putIfAbsent(s.number, () => []).add(a);
      }
    }
    final unexpected = present.where((n) => !expected.contains(n)).toList()..sort();
    return CoverageReport(missing, unexpected, present.where(expected.contains).length);
  }

  bool get complete => missing.isEmpty;

  List<int> get completeSurahs => [
        for (final s in surahs)
          if (!missing.containsKey(s.number)) s.number
      ];

  /// Nilai `surahs` untuk katalog: hanya surah yang lengkap per ayat yang boleh dicantumkan.
  Object get manifestSurahs => complete ? 'all' : completeSurahs;
}

/// Potongan satu ayat dari rekaman satu surah.
class AyahSegment {
  final int surah;
  final int ayah;
  final double start;
  final double end;
  const AyahSegment(this.surah, this.ayah, this.start, this.end);

  String get fileName => ayahFileName(surah, ayah);

  /// Argumen ffmpeg: potong [start, end] lalu encode MP3 mono 96 kbps (ringan untuk unduh offline).
  List<String> ffmpegArgs(String input, String outDir) => [
        '-y',
        '-hide_banner',
        '-loglevel',
        'error',
        '-i',
        input,
        '-ss',
        start.toStringAsFixed(3),
        '-to',
        end.toStringAsFixed(3),
        '-ac',
        '1',
        '-ar',
        '44100',
        '-b:a',
        '96k',
        '$outDir/$fileName',
      ];
}

/// Parse label Audacity (`start<TAB>end<TAB>nomor ayat`) yang ditandai editor audio per ayat.
/// Wajib: jumlah label = jumlah ayat surah, nomor urut 1..n, dan waktu valid.
List<AyahSegment> parseAyahLabels(String text, int surah) {
  final count = surahs[surah - 1].ayahCount;
  final segs = <AyahSegment>[];
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('\\')) continue; // baris frekuensi Audacity diawali '\'
    final parts = line.split(RegExp(r'\t+'));
    if (parts.length < 3) throw FormatException('Label tidak valid: $line');
    final start = double.parse(parts[0]), end = double.parse(parts[1]);
    final ayah = int.parse(parts[2].trim());
    if (ayah != segs.length + 1) {
      throw FormatException('Label ayat harus berurutan; ditemukan $ayah, seharusnya ${segs.length + 1}');
    }
    if (end <= start || (segs.isNotEmpty && start < segs.last.start)) {
      throw FormatException('Waktu label ayat $ayah tidak valid');
    }
    segs.add(AyahSegment(surah, ayah, start, end));
  }
  if (segs.length != count) throw FormatException('Surah $surah memiliki $count ayat, label berisi ${segs.length}');
  return segs;
}
