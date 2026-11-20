// Mengubah berkas teks Tanzil (format `sura|aya|teks`) yang sudah diunduh secara sah
// menjadi aset JSON per surah untuk aplikasi Moeslim Personal.
//
//   dart run tool/import_quran.dart <teks.txt> <output-dir> [terjemahan.txt] [--tajweed anotasi.json]
//
// --tajweed : dataset anotasi tajwid `[{surah, ayah, annotations:[{rule,start,end}]}]` yang dibuat
//             untuk EDISI TEKS YANG SAMA. Posisi anotasi diverifikasi terhadap panjang teks tiap ayat;
//             impor dibatalkan bila ada yang di luar batas (tanda edisi teks tidak cocok).
//
// Sumber teks, terjemahan, dan anotasi WAJIB memiliki izin distribusi dan telah diverifikasi
// terhadap mushaf yang ditetapkan penelaah. Simpan atribusi sumber di <output-dir>/SOURCE.md.
import 'dart:convert';
import 'dart:io';

import 'package:personal_core/personal_core.dart';

void main(List<String> argv) {
  final args = [...argv];
  String? tajweedPath;
  final ti = args.indexOf('--tajweed');
  if (ti >= 0) {
    tajweedPath = args[ti + 1];
    args.removeRange(ti, ti + 2);
  }
  if (args.length < 2) {
    stderr.writeln('Pemakaian: dart run tool/import_quran.dart <teks.txt> <output-dir> [terjemahan.txt] [--tajweed anotasi.json]');
    exit(64);
  }
  final text = parseTanzil(File(args[0]).readAsStringSync());
  final tr = args.length > 2 ? parseTanzil(File(args[2]).readAsStringSync()) : <int, List<Ayah>>{};

  var total = 0;
  for (final s in surahs) {
    final ayat = text[s.number] ?? [];
    if (ayat.length != s.ayahCount) {
      stderr.writeln('Surah ${s.number} (${s.name}): ${ayat.length} ayat, seharusnya ${s.ayahCount}');
      exit(1);
    }
    total += ayat.length;
  }

  var tajweed = <(int, int), List<TajweedSpan>>{};
  if (tajweedPath != null) {
    final parsed = parseTajweedAnnotations(jsonDecode(File(tajweedPath).readAsStringSync()) as List);
    if (parsed.unknownRules.isNotEmpty) {
      stderr.writeln('Peringatan: aturan tajwid tidak dikenal diabaikan: ${parsed.unknownRules.join(', ')}');
    }
    var outOfBounds = 0;
    for (final e in parsed.spans.entries) {
      final (s, a) = e.key;
      final len = (s >= 1 && s <= 114 && a >= 1 && a <= text[s]!.length) ? text[s]![a - 1].text.length : -1;
      outOfBounds += e.value.where((x) => len < 0 || x.start < 0 || x.end > len || x.start >= x.end).length;
    }
    if (outOfBounds > 0) {
      stderr.writeln('Dibatalkan: $outOfBounds anotasi tajwid di luar batas teks. Pastikan anotasi dibuat untuk edisi teks yang sama.');
      exit(1);
    }
    tajweed = parsed.spans;
    stdout.writeln('Anotasi tajwid: ${tajweed.values.fold<int>(0, (n, l) => n + l.length)} rentang pada ${tajweed.length} ayat');
  }

  final out = Directory(args[1])..createSync(recursive: true);
  for (final s in surahs) {
    final trList = tr[s.number];
    final list = [
      for (final (i, a) in text[s.number]!.indexed)
        Ayah(
          a.surah,
          a.number,
          a.text,
          translation: trList != null && i < trList.length ? trList[i].text : null,
          tajweed: tajweed[(a.surah, a.number)] ?? const [],
        ).toJson(),
    ];
    File('${out.path}/${s.number}.json').writeAsStringSync(jsonEncode(list));
  }
  stdout.writeln('Selesai: $total ayat ditulis ke ${out.path}');
}
