import 'naghom.dart';
import 'quran.dart' as quran;

/// Kunci pilihan bacaan untuk rekaman murattal (tanpa label irama).
const murattalKey = 'murattal';

/// Jenis rekaman: murattal (bacaan tartil standar) atau tilawah dengan satu irama naghom.
enum RecitationKind { murattal, naghom }

/// Satu rekaman tilawah lengkap per ayat oleh satu qari: murattal, atau satu irama (naghom).
///
/// Berkas audio per ayat diletakkan di `<baseUrl>/<SSS><AAA>.mp3` (mis. `001007.mp3`)
/// sehingga pemutaran per ayat maupun per surah memakai sumber yang sama.
/// Setiap rekaman WAJIB memiliki lisensi dan atribusi; entri tanpa lisensi diabaikan.
class Recitation {
  final String id;
  final String qari;
  final RecitationKind kind;

  /// Slug irama bila [kind] = naghom; null untuk murattal.
  final String? naghom;
  final String baseUrl;
  final String license;
  final String attribution;

  /// null = mencakup seluruh 114 surah.
  final Set<int>? surahs;

  const Recitation({
    required this.id,
    required this.qari,
    this.kind = RecitationKind.naghom,
    this.naghom,
    required this.baseUrl,
    required this.license,
    required this.attribution,
    this.surahs,
  });

  bool get isMurattal => kind == RecitationKind.murattal;

  /// Kunci pilihan bacaan di pemutar: `murattal` atau slug irama.
  String get optionKey => naghom ?? murattalKey;

  bool covers(int surah) => surahs == null || surahs!.contains(surah);

  String fileName(int surah, int ayah) =>
      '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}.mp3';

  String ayahUrl(int surah, int ayah) => '$baseUrl/${fileName(surah, ayah)}';

  List<AudioTrack> playlist(int surah, {int fromAyah = 1, int? toAyah}) {
    if (!covers(surah)) throw ArgumentError('Rekaman $id tidak mencakup surah $surah');
    final count = quran.surahs[surah - 1].ayahCount;
    final to = toAyah ?? count;
    if (fromAyah < 1 || to > count || fromAyah > to) throw RangeError('Rentang ayat $fromAyah-$to tidak valid');
    return [for (var a = fromAyah; a <= to; a++) AudioTrack(this, surah, a)];
  }

  static Recitation? tryParse(Map<String, dynamic> j) {
    final naghom = j['naghom'];
    final license = (j['license'] as String?)?.trim() ?? '';
    final kindRaw = j['kind'] ?? (naghom == murattalKey ? murattalKey : 'naghom');
    final kind = RecitationKind.values.where((k) => k.name == kindRaw).firstOrNull;
    if (kind == null || license.isEmpty) return null;
    if (kind == RecitationKind.naghom && !naghomStyles.any((s) => s.slug == naghom)) return null;
    final rawSurahs = j['surahs'];
    return Recitation(
      id: j['id'] as String,
      qari: j['qari'] as String? ?? '',
      kind: kind,
      naghom: kind == RecitationKind.naghom ? naghom as String : null,
      baseUrl: (j['base_url'] as String).replaceAll(RegExp(r'/+$'), ''),
      license: license,
      attribution: j['attribution'] as String? ?? '',
      surahs: rawSurahs is List ? rawSurahs.map((e) => (e as num).toInt()).toSet() : null,
    );
  }
}

class AudioTrack {
  final Recitation recitation;
  final int surah;
  final int ayah;
  const AudioTrack(this.recitation, this.surah, this.ayah);

  String get url => recitation.ayahUrl(surah, ayah);
  String get fileName => recitation.fileName(surah, ayah);
}

/// Satu dari 7 pilihan irama saat memutar surah tertentu.
class NaghomOption {
  final NaghomStyle style;
  final List<Recitation> recitations;
  const NaghomOption(this.style, this.recitations);

  bool get available => recitations.isNotEmpty;
}

/// Satu pilihan bacaan di pemutar: Murattal atau salah satu dari 7 irama.
class RecitationOption {
  final String key;
  final String label;
  final String description;

  /// null untuk Murattal.
  final NaghomStyle? style;
  final List<Recitation> recitations;

  const RecitationOption({
    required this.key,
    required this.label,
    required this.description,
    required this.style,
    required this.recitations,
  });

  bool get available => recitations.isNotEmpty;
}

/// Katalog rekaman (JSON berversi, dibundel di aplikasi dan/atau diunduh dari CDN).
class AudioManifest {
  final int version;
  final List<Recitation> recitations;
  const AudioManifest(this.version, this.recitations);

  static const empty = AudioManifest(0, []);

  factory AudioManifest.fromJson(Map<String, dynamic> j) => AudioManifest(
        (j['version'] as num?)?.toInt() ?? 0,
        (j['recitations'] as List? ?? const [])
            .whereType<Map>()
            .map((r) => Recitation.tryParse(Map<String, dynamic>.from(r)))
            .whereType<Recitation>()
            .toList(),
      );

  /// Selalu mengembalikan 7 opsi sesuai urutan modul Naghom, beserta rekaman yang tersedia.
  List<NaghomOption> naghomOptionsFor(int surah) => [
        for (final style in naghomStyles)
          NaghomOption(style, recitations.where((r) => r.naghom == style.slug && r.covers(surah)).toList()),
      ];

  /// Pilihan bacaan untuk surah: Murattal lebih dulu, lalu 7 irama sesuai urutan modul Naghom.
  List<RecitationOption> optionsFor(int surah) => [
        RecitationOption(
          key: murattalKey,
          label: 'Murattal',
          description: 'Bacaan tartil standar, tempo sedang tanpa irama tertentu.',
          style: null,
          recitations: recitations.where((r) => r.isMurattal && r.covers(surah)).toList(),
        ),
        for (final o in naghomOptionsFor(surah))
          RecitationOption(
            key: o.style.slug,
            label: o.style.name,
            description: o.style.character,
            style: o.style,
            recitations: o.recitations,
          ),
      ];

  bool murattalCovers(int surah) => recitations.any((r) => r.isMurattal && r.covers(surah));

  /// Irama yang belum tersedia di seluruh 114 surah → daftar surah yang belum tercakup.
  Map<String, List<int>> coverageGaps() => {
        for (final style in naghomStyles)
          if (quran.surahs.any((s) => !recitations.any((r) => r.naghom == style.slug && r.covers(s.number))))
            style.slug: [
              for (final s in quran.surahs)
                if (!recitations.any((r) => r.naghom == style.slug && r.covers(s.number))) s.number,
            ],
      };

  /// Target produk: ketujuh irama tersedia untuk setiap ayat di setiap surah.
  bool get allNaghomForAllSurahs => coverageGaps().isEmpty;
}
