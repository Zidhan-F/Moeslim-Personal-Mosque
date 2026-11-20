// Mengubah berkas teks Tanzil (format `sura|aya|teks`) yang sudah diunduh
// secara sah menjadi aset JSON per surah untuk aplikasi Moeslim Personal.
//
//   dart run tool/import_quran.dart <quran-uthmani.txt> <output-dir> [terjemahan.txt]
//
// Sumber teks dan terjemahan WAJIB memiliki izin distribusi dan telah
// diverifikasi terhadap Mushaf Standar Indonesia (Lajnah Pentashihan Kemenag).
// Simpan atribusi sumber di <output-dir>/SOURCE.md.
import 'dart:convert';
import 'dart:io';

import 'package:personal_core/personal_core.dart';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Pemakaian: dart run tool/import_quran.dart <teks.txt> <output-dir> [terjemahan.txt]');
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
  final out = Directory(args[1])..createSync(recursive: true);
  for (final s in surahs) {
    final trList = tr[s.number];
    final list = [
      for (final (i, a) in text[s.number]!.indexed)
        Ayah(a.surah, a.number, a.text, translation: trList != null && i < trList.length ? trList[i].text : null).toJson(),
    ];
    File('${out.path}/${s.number}.json').writeAsStringSync(jsonEncode(list));
  }
  stdout.writeln('Selesai: $total ayat ditulis ke ${out.path}');
}
