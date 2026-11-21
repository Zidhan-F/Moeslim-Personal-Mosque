// Mengisi anotasi tajwid (`tj`) di aset Al-Qur'an per surah dengan classifier tajwid bawaan.
//
//   dart run tool/annotate_tajweed.dart [../../apps/mobile/assets/quran]
//
// Teks & terjemahan tidak diubah; hanya kolom `tj` yang ditulis ulang. Jalankan ulang setiap kali
// classifier (lib/src/content/tajweed_classifier.dart) diperbarui.
import 'dart:convert';
import 'dart:io';

import 'package:personal_core/personal_core.dart';

void main(List<String> args) {
  final dir = Directory(
      args.isNotEmpty ? args.first : '../../apps/mobile/assets/quran');
  var ayat = 0, spans = 0;
  final perRule = <TajweedRule, int>{};
  for (var s = 1; s <= 114; s++) {
    final file = File('${dir.path}/$s.json');
    final list = (jsonDecode(file.readAsStringSync()) as List)
        .map((j) => Ayah.fromJson(j as Map<String, dynamic>));
    final out = <Map<String, Object?>>[];
    for (final a in list) {
      final tj = classifyTajweed(a.text);
      ayat++;
      spans += tj.length;
      for (final t in tj) {
        perRule[t.rule] = (perRule[t.rule] ?? 0) + 1;
      }
      out.add(Ayah(a.surah, a.number, a.text,
              translation: a.translation, tajweed: tj)
          .toJson());
    }
    file.writeAsStringSync(jsonEncode(out));
  }
  stdout.writeln('$ayat ayat, $spans anotasi tajwid ditulis ke ${dir.path}');
  for (final r in TajweedRule.values) {
    stdout.writeln('  ${r.label.padRight(24)} ${perRule[r] ?? 0}');
  }
}
