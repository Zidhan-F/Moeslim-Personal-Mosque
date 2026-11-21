import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_core/personal_core.dart';

/// Sumber teks ayat lokal. Aset `assets/quran/<n>.json` dihasilkan oleh
/// `packages/personal_core/tool/import_quran.dart` dari sumber berlisensi.
abstract class QuranTextSource {
  Future<List<Ayah>?> load(int surah);
}

class AssetQuranSource implements QuranTextSource {
  @override
  Future<List<Ayah>?> load(int surah) async {
    try {
      final raw = await rootBundle.loadString('assets/quran/$surah.json', cache: false);
      return await compute(_parseAyat, raw);
    } catch (_) {
      return null; // dataset belum diimpor
    }
  }
}

List<Ayah> _parseAyat(String raw) =>
    (jsonDecode(raw) as List).map((e) => Ayah.fromJson(Map<String, dynamic>.from(e as Map))).toList();

final quranSourceProvider = Provider<QuranTextSource>((ref) => AssetQuranSource());

final surahTextProvider = FutureProvider.autoDispose.family<List<Ayah>?, int>(
  (ref, n) => ref.watch(quranSourceProvider).load(n),
);
