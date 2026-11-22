import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:personal_core/personal_core.dart';

/// Unduhan audio per ayat untuk diputar offline.
abstract class OfflineAudioStore {
  Future<Uri?> localUri(AudioTrack track);
  Future<bool> isSurahDownloaded(Recitation r, int surah);
  Future<void> downloadSurah(Recitation r, int surah, {void Function(int done, int total)? onProgress});
  Future<void> deleteSurah(Recitation r, int surah);
}

class FileOfflineAudioStore implements OfflineAudioStore {
  final http.Client client;
  Future<Directory>? _supportDir;
  FileOfflineAudioStore(this.client);

  Future<Directory> _dir(Recitation r) async {
    final base = await (_supportDir ??= getApplicationSupportDirectory());
    return Directory('${base.path}/audio/${r.id}');
  }

  Future<File> _file(AudioTrack t) async => File('${(await _dir(t.recitation)).path}/${t.fileName}');

  @override
  Future<Uri?> localUri(AudioTrack track) async {
    final f = await _file(track);
    return await f.exists() ? f.uri : null;
  }

  @override
  Future<bool> isSurahDownloaded(Recitation r, int surah) async {
    for (final t in r.playlist(surah)) {
      if (!await (await _file(t)).exists()) return false;
    }
    return true;
  }

  @override
  Future<void> downloadSurah(Recitation r, int surah, {void Function(int done, int total)? onProgress}) async {
    final tracks = r.playlist(surah);
    final dir = await _dir(r);
    await dir.create(recursive: true);
    for (final (i, t) in tracks.indexed) {
      final f = await _file(t);
      if (!await f.exists()) {
        final res = await client.get(Uri.parse(t.url));
        if (res.statusCode != 200) throw HttpException('Gagal mengunduh ${t.fileName} (${res.statusCode})');
        final tmp = File('${f.path}.part');
        await tmp.writeAsBytes(res.bodyBytes, flush: true);
        await tmp.rename(f.path); // atomik: berkas parsial tidak dianggap lengkap
      }
      onProgress?.call(i + 1, tracks.length);
    }
  }

  @override
  Future<void> deleteSurah(Recitation r, int surah) async {
    for (final t in r.playlist(surah)) {
      final f = await _file(t);
      if (await f.exists()) await f.delete();
    }
  }
}
