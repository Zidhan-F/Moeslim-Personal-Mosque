import '../storage/key_value_store.dart';
import 'sirah/kisah_nabi.dart';
import 'sirah/sahabat.dart';
import 'sirah/sirah_nabawiyah.dart';

enum SirahSection {
  sirahNabawiyah('Sirah Nabawiyah'),
  kisah25Nabi('Kisah 25 Nabi'),
  biografiSahabat('Biografi Sahabat');

  final String label;
  const SirahSection(this.label);
}

class SirahChapter {
  final String id;
  final SirahSection section;
  final int order;
  final String title;
  final String periodOrTitle;
  final String narrative;
  final String hikmah;
  final String reference;

  const SirahChapter({
    required this.id,
    required this.section,
    required this.order,
    required this.title,
    required this.periodOrTitle,
    required this.narrative,
    required this.hikmah,
    required this.reference,
  });

  /// Isi bab per blok: baris `## ` = subjudul, baris `• ` = poin, selain itu paragraf.
  List<SirahBlock> get blocks => [
        for (final raw in narrative.split('\n'))
          if (raw.trim().isNotEmpty)
            raw.startsWith('## ')
                ? SirahBlock(SirahBlockKind.heading, raw.substring(3).trim())
                : raw.startsWith('• ')
                    ? SirahBlock(SirahBlockKind.bullet, raw.substring(2).trim())
                    : SirahBlock(SirahBlockKind.paragraph, raw.trim()),
      ];

  /// Perkiraan waktu baca (200 kata per menit).
  int get readingMinutes => (narrative.split(RegExp(r'\s+')).length / 200).ceil().clamp(1, 60);

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        periodOrTitle.toLowerCase().contains(q) ||
        narrative.toLowerCase().contains(q) ||
        hikmah.toLowerCase().contains(q);
  }
}

/// Seluruh bab: Sirah Nabawiyah (24), Kisah 25 Nabi (25), Biografi Sahabat (25).
const List<SirahChapter> sirahLibraryCatalog = [
  ...sirahNabawiyahChapters,
  ...kisahNabiChapters,
  ...sahabatChapters,
];

/// Satu blok isi bab untuk ditampilkan: subjudul, paragraf, atau poin.
enum SirahBlockKind { heading, paragraph, bullet }

class SirahBlock {
  final SirahBlockKind kind;
  final String text;
  const SirahBlock(this.kind, this.text);
}

class SirahRepository {
  static const _readKey = 'sirah_read_chapters';
  static const _lastKey = 'sirah_last_chapter';
  final KeyValueStore _store;

  const SirahRepository(this._store);

  Future<Set<String>> completedChapters() async {
    final raw = await _store.readJson(_readKey);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is String) x,
    };
  }

  Future<String?> lastReadChapterId() => _store.read(_lastKey);

  Future<Set<String>> markRead(String chapterId) async {
    await _store.write(_lastKey, chapterId);
    final set = await completedChapters();
    set.add(chapterId);
    await _store.writeJson(_readKey, set.toList());
    return set;
  }
}
