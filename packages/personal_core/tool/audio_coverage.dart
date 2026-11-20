// Memeriksa kelengkapan 7 irama untuk setiap ayat dan membuat katalog audio.
//
// Struktur folder produksi:
//   <root>/<id-qari>/qari.json            {"qari": "...", "license": "...", "attribution": "..."}
//   <root>/<id-qari>/<jenis>/SSSAAA.mp3   jenis = murattal|bayyati|hijaz|shaba|rast|jiharkah|sika|nahawand
//
//   dart run tool/audio_coverage.dart <root> [--base-url URL] [--manifest out.json] [--version N] [--require-all]
//
// --require-all : keluar dengan kode 1 bila ada irama yang belum lengkap di seluruh 6.236 ayat
//                 (dipakai sebagai gerbang sebelum rilis "7 irama di semua surah").
import 'dart:convert';
import 'dart:io';

import 'package:personal_core/personal_core.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Pemakaian: dart run tool/audio_coverage.dart <root> [--base-url URL] [--manifest out.json] [--version N] [--require-all]');
    exit(64);
  }
  String? opt(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final root = Directory(args.first);
  final baseUrl = (opt('--base-url') ?? 'https://cdn.example.com/audio').replaceAll(RegExp(r'/+$'), '');
  final recitations = <Map<String, Object>>[];
  final perNaghomComplete = {for (final n in naghomStyles) n.slug: false};
  var murattalComplete = false;

  stdout.writeln('${'Qari/Irama'.padRight(32)} Ayat           Surah lengkap');
  for (final qariDir in root.listSync().whereType<Directory>().toList()..sort((a, b) => a.path.compareTo(b.path))) {
    final id = qariDir.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final metaFile = File('${qariDir.path}/qari.json');
    if (!metaFile.existsSync()) {
      stderr.writeln('Lewati $id: qari.json tidak ada');
      continue;
    }
    final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
    if ((meta['license'] as String? ?? '').trim().isEmpty) {
      stderr.writeln('Lewati $id: lisensi kosong');
      continue;
    }
    for (final key in [murattalKey, ...naghomStyles.map((n) => n.slug)]) {
      final dir = Directory('${qariDir.path}/$key');
      if (!dir.existsSync()) continue;
      final names = dir.listSync().whereType<File>().map((f) => f.uri.pathSegments.last);
      final report = CoverageReport.fromFileNames(names);
      stdout.writeln('${'$id/$key'.padRight(32)} '
          '${'${report.totalPresent}/${CoverageReport.totalAyat}'.padRight(14)} ${report.completeSurahs.length}/114'
          '${report.unexpected.isNotEmpty ? '  (berkas asing: ${report.unexpected.take(3).join(', ')})' : ''}');
      if (report.complete && key != murattalKey) perNaghomComplete[key] = true;
      if (report.complete && key == murattalKey) murattalComplete = true;
      if (report.completeSurahs.isEmpty) continue;
      recitations.add({
        'id': '$id-$key',
        'qari': meta['qari'] as String? ?? id,
        if (key == murattalKey) 'kind': murattalKey else 'naghom': key,
        'base_url': '$baseUrl/$id/$key',
        'license': meta['license'] as String,
        'attribution': meta['attribution'] as String? ?? '',
        'surahs': report.manifestSurahs,
      });
    }
  }

  stdout.writeln(murattalComplete ? '\n✔ Murattal lengkap untuk seluruh 114 surah.' : '\n✘ Murattal belum lengkap di seluruh mushaf.');
  final missingNaghom = [for (final e in perNaghomComplete.entries) if (!e.value) e.key];
  stdout.writeln(missingNaghom.isEmpty
      ? '\n✔ Ketujuh irama lengkap untuk seluruh 114 surah.'
      : '\n✘ Irama belum lengkap di seluruh mushaf: ${missingNaghom.join(', ')}');

  final manifestPath = opt('--manifest');
  if (manifestPath != null) {
    final manifest = {'version': int.tryParse(opt('--version') ?? '') ?? 1, 'recitations': recitations};
    File(manifestPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
    stdout.writeln('Katalog ditulis: $manifestPath (${recitations.length} rekaman)');
  }
  if (args.contains('--require-all') && missingNaghom.isNotEmpty) exit(1);
}
