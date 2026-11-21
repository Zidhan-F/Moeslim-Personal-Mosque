import 'quran.dart' as quran;

/// Jenis rekaman yang didukung: murattal (bacaan tartil per ayat oleh satu qari).
const murattalKey = 'murattal';

/// Satu rekaman murattal lengkap per ayat oleh satu qari.
///
/// Berkas audio per ayat diletakkan di `<baseUrl>/<SSS><AAA>.mp3` (mis. `001007.mp3`)
/// sehingga pemutaran per ayat maupun per surah memakai sumber yang sama.
/// Setiap rekaman WAJIB memiliki lisensi dan atribusi; entri tanpa lisensi diabaikan.
class Recitation {
  final String id;
  final String qari;
  final String baseUrl;
  final String license;
  final String attribution;

  /// null = mencakup seluruh 114 surah.
  final Set<int>? surahs;

  const Recitation({
    required this.id,
    required this.qari,
    required this.baseUrl,
    required this.license,
    required this.attribution,
    this.surahs,
  });

  bool covers(int surah) => surahs == null || surahs!.contains(surah);

  String fileName(int surah, int ayah) =>
      '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}.mp3';

  String ayahUrl(int surah, int ayah) => '$baseUrl/${fileName(surah, ayah)}';

  List<AudioTrack> playlist(int surah, {int fromAyah = 1, int? toAyah}) {
    if (!covers(surah)) {
      throw ArgumentError('Rekaman $id tidak mencakup surah $surah');
    }
    final count = quran.surahs[surah - 1].ayahCount;
    final to = toAyah ?? count;
    if (fromAyah < 1 || to > count || fromAyah > to) {
      throw RangeError('Rentang ayat $fromAyah-$to tidak valid');
    }
    return [for (var a = fromAyah; a <= to; a++) AudioTrack(this, surah, a)];
  }

  /// Hanya entri `kind: murattal` berlisensi yang diterima; entri lain (mis. katalog lama) diabaikan.
  static Recitation? tryParse(Map<String, dynamic> j) {
    final license = (j['license'] as String?)?.trim() ?? '';
    if (j['kind'] != murattalKey || license.isEmpty) return null;
    final rawSurahs = j['surahs'];
    return Recitation(
      id: j['id'] as String,
      qari: j['qari'] as String? ?? '',
      baseUrl: (j['base_url'] as String).replaceAll(RegExp(r'/+$'), ''),
      license: license,
      attribution: j['attribution'] as String? ?? '',
      surahs: rawSurahs is List
          ? rawSurahs.map((e) => (e as num).toInt()).toSet()
          : null,
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

/// Katalog rekaman murattal (JSON berversi, dibundel di aplikasi dan/atau diunduh dari CDN).
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

  /// Qari yang tersedia untuk surah ini.
  List<Recitation> recitationsFor(int surah) =>
      recitations.where((r) => r.covers(surah)).toList();

  bool murattalCovers(int surah) => recitations.any((r) => r.covers(surah));
}
