// Pratinjau hasil classifier tajwid: dart run tool/tajweed_preview.dart <surah> [ayat]
import 'dart:convert';
import 'dart:io';

import 'package:personal_core/personal_core.dart';

void main(List<String> args) {
  final s = int.parse(args.first);
  final only = args.length > 1 ? int.parse(args[1]) : null;
  final ayat = (jsonDecode(
              File('../../apps/mobile/assets/quran/$s.json').readAsStringSync())
          as List)
      .map((j) => Ayah.fromJson(j as Map<String, dynamic>));
  for (final a in ayat) {
    if (only != null && a.number != only) continue;
    stdout.writeln('$s:${a.number} ${a.text}');
    for (final sp in classifyTajweed(a.text)) {
      stdout.writeln(
          '   ${sp.start}-${sp.end} ${sp.rule.name.padRight(20)} «${a.text.substring(sp.start, sp.end)}»');
    }
  }
}
