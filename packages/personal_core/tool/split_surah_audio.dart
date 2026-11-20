// Memotong rekaman SATU surah menjadi berkas per ayat (SSSAAA.mp3) berdasarkan
// label Audacity yang ditandai editor audio (start<TAB>end<TAB>nomor ayat).
//
//   dart run tool/split_surah_audio.dart <rekaman.wav|mp3> <label.txt> <nomor-surah> <folder-output>
//
// Contoh folder output: produksi/qari-fulan/bayyati  (satu folder per qari per irama)
import 'dart:io';

import 'package:personal_core/personal_core.dart';

Future<void> main(List<String> args) async {
  if (args.length != 4) {
    stderr.writeln('Pemakaian: dart run tool/split_surah_audio.dart <audio> <label.txt> <surah> <output-dir>');
    exit(64);
  }
  final surah = int.parse(args[2]);
  if (surah < 1 || surah > 114) {
    stderr.writeln('Nomor surah harus 1-114');
    exit(64);
  }
  final List<AyahSegment> segs;
  try {
    segs = parseAyahLabels(File(args[1]).readAsStringSync(), surah);
  } on FormatException catch (e) {
    stderr.writeln('Label tidak valid: ${e.message}');
    exit(65);
  }
  final out = Directory(args[3])..createSync(recursive: true);
  for (final s in segs) {
    final r = await Process.run('ffmpeg', s.ffmpegArgs(args[0], out.path));
    if (r.exitCode != 0) {
      stderr.writeln('ffmpeg gagal pada ${s.fileName}: ${r.stderr}');
      exit(1);
    }
  }
  stdout.writeln('Selesai: ${segs.length} ayat surah ${surahs[surah - 1].name} → ${out.path}');
}
