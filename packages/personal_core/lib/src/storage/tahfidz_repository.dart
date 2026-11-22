import '../content/quran.dart';
import 'key_value_store.dart';

enum TahfidzMaskMode {
  fullVisible('Tampil Penuh', 'Seluruh kata Arab ditampilkan untuk mulai menghafal.'),
  firstWordsOnly('Awal Ayat', 'Hanya 2 kata pertama yang ditampilkan sebagai pancingan hafalan.'),
  hideAlternate('Sembunyikan Sebagian', 'Menyembunyikan kata secara bergantian untuk uji sambung ayat.'),
  blind('Tutup Penuh', 'Seluruh teks Arab disembunyikan; ketuk kartu untuk mengintip ayat.');

  final String label;
  final String description;
  const TahfidzMaskMode(this.label, this.description);
}

enum SurahHafalanStatus {
  belum('Belum Mulai'),
  menghafal('Sedang Menghafal'),
  lancar('Hafal Lancar'),
  murajaah('Perlu Muraja\'ah');

  final String label;
  const SurahHafalanStatus(this.label);
}

class SurahTahfidzEntry {
  final int surah;
  final int memorizedAyahs;
  final SurahHafalanStatus status;
  final DateTime? lastMurajaahAt;
  final int targetRepeat;

  const SurahTahfidzEntry({
    required this.surah,
    this.memorizedAyahs = 0,
    this.status = SurahHafalanStatus.belum,
    this.lastMurajaahAt,
    this.targetRepeat = 3,
  });

  Surah get surahMeta => surahs[surah - 1];

  double get ratio => (memorizedAyahs / surahMeta.ayahCount).clamp(0.0, 1.0);

  bool isDueForMurajaah(DateTime now) {
    if (memorizedAyahs <= 0) return false;
    if (status == SurahHafalanStatus.murajaah) return true;
    if (lastMurajaahAt == null) return true;
    return now.difference(lastMurajaahAt!).inDays >= 3;
  }

  SurahTahfidzEntry copyWith({
    int? memorizedAyahs,
    SurahHafalanStatus? status,
    DateTime? lastMurajaahAt,
    int? targetRepeat,
  }) =>
      SurahTahfidzEntry(
        surah: surah,
        memorizedAyahs: memorizedAyahs ?? this.memorizedAyahs,
        status: status ?? this.status,
        lastMurajaahAt: lastMurajaahAt ?? this.lastMurajaahAt,
        targetRepeat: targetRepeat ?? this.targetRepeat,
      );

  Map<String, Object> toJson() => {
        'surah': surah,
        'memorizedAyahs': memorizedAyahs,
        'status': status.name,
        if (lastMurajaahAt != null) 'lastMurajaahAt': lastMurajaahAt!.toUtc().toIso8601String(),
        'targetRepeat': targetRepeat,
      };

  factory SurahTahfidzEntry.fromJson(Map<String, dynamic> j) {
    final sNum = ((j['surah'] as num?)?.toInt() ?? 1).clamp(1, 114);
    final maxAyah = surahs[sNum - 1].ayahCount;
    final stName = j['status'] as String?;
    final st = SurahHafalanStatus.values.where((e) => e.name == stName).firstOrNull ?? SurahHafalanStatus.belum;
    return SurahTahfidzEntry(
      surah: sNum,
      memorizedAyahs: ((j['memorizedAyahs'] as num?)?.toInt() ?? 0).clamp(0, maxAyah),
      status: st,
      lastMurajaahAt: DateTime.tryParse(j['lastMurajaahAt'] as String? ?? '')?.toLocal(),
      targetRepeat: ((j['targetRepeat'] as num?)?.toInt() ?? 3).clamp(1, 20),
    );
  }
}

String maskArabicForTahfidz(
  String arabic,
  TahfidzMaskMode mode, {
  bool revealed = false,
}) {
  if (revealed || mode == TahfidzMaskMode.fullVisible) return arabic;
  final words = arabic.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return arabic;

  switch (mode) {
    case TahfidzMaskMode.fullVisible:
      return arabic;
    case TahfidzMaskMode.firstWordsOnly:
      final visibleCount = words.length <= 2 ? 1 : 2;
      final head = words.take(visibleCount).join(' ');
      final hiddenCount = words.length - visibleCount;
      if (hiddenCount <= 0) return head;
      return '$head ${List.filled(hiddenCount, '•••').join(' ')}';
    case TahfidzMaskMode.hideAlternate:
      return [
        for (var i = 0; i < words.length; i++) i.isEven ? words[i] : '•••',
      ].join(' ');
    case TahfidzMaskMode.blind:
      return List.filled(words.length.clamp(3, 8), '•••').join(' ');
  }
}

class TahfidzRepository {
  static const _key = 'tahfidz_progress';
  final KeyValueStore _store;

  const TahfidzRepository(this._store);

  Future<Map<int, SurahTahfidzEntry>> allEntries() async {
    final raw = await _store.readJson(_key);
    final map = <int, SurahTahfidzEntry>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value is Map) {
          final entry = SurahTahfidzEntry.fromJson(Map<String, dynamic>.from(e.value as Map));
          map[entry.surah] = entry;
        }
      }
    }
    return map;
  }

  Future<SurahTahfidzEntry> entryFor(int surah) async {
    final all = await allEntries();
    return all[surah] ?? SurahTahfidzEntry(surah: surah);
  }

  Future<SurahTahfidzEntry> updateMemorized({
    required int surah,
    required int memorizedAyahs,
    SurahHafalanStatus? status,
    int? targetRepeat,
  }) async {
    final all = await allEntries();
    final current = all[surah] ?? SurahTahfidzEntry(surah: surah);
    final maxAyah = surahs[surah - 1].ayahCount;
    final clamped = memorizedAyahs.clamp(0, maxAyah);
    final nextStatus = status ??
        (clamped == 0
            ? SurahHafalanStatus.belum
            : (clamped >= maxAyah ? SurahHafalanStatus.lancar : SurahHafalanStatus.menghafal));
    final updated = current.copyWith(
      memorizedAyahs: clamped,
      status: nextStatus,
      targetRepeat: targetRepeat ?? current.targetRepeat,
    );
    all[surah] = updated;
    await _saveAll(all);
    return updated;
  }

  Future<SurahTahfidzEntry> markMurajaahDone(int surah, {DateTime? now}) async {
    final all = await allEntries();
    final current = all[surah] ?? SurahTahfidzEntry(surah: surah);
    final maxAyah = surahs[surah - 1].ayahCount;
    final memorized = current.memorizedAyahs == 0 ? maxAyah : current.memorizedAyahs;
    final updated = current.copyWith(
      memorizedAyahs: memorized,
      status: memorized >= maxAyah ? SurahHafalanStatus.lancar : SurahHafalanStatus.menghafal,
      lastMurajaahAt: now ?? DateTime.now(),
    );
    all[surah] = updated;
    await _saveAll(all);
    return updated;
  }

  Future<void> _saveAll(Map<int, SurahTahfidzEntry> all) async {
    await _store.writeJson(_key, {
      for (final e in all.entries) '${e.key}': e.value.toJson(),
    });
  }
}
