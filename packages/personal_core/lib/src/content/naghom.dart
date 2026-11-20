/// Modul andalan Moeslim: 7 Jenis Irama (Naghom) Al-Qur'an.
///
/// [summary] adalah materi resmi dari pemilik produk dan ditampilkan apa adanya.
/// Materi tetap ditelaah qari/guru tilawah sebelum rilis; irama tidak menggantikan
/// tajwid, makhraj, dan bimbingan guru.
class NaghomStyle {
  final String slug;
  final String name;

  /// Deskripsi resmi (verbatim).
  final String summary;
  final String character;
  final int? toneLevels;

  /// Istilah materi: "tingkat" (umum) atau "jenis" (Sika).
  final String toneTerm;
  final String usage;
  final bool needsExpertReview;

  const NaghomStyle({
    required this.slug,
    required this.name,
    required this.summary,
    required this.character,
    required this.toneLevels,
    required this.usage,
    this.toneTerm = 'tingkat',
    this.needsExpertReview = true,
  });

  String get toneLabel => toneLevels == null ? 'Variasi nada tajam' : '$toneLevels $toneTerm nada';
}

const naghomDisclaimer =
    'Materi irama sedang ditelaah oleh qari/guru tilawah. '
    'Latihan irama tidak boleh mengorbankan ketepatan tajwid dan makhraj.';

const List<NaghomStyle> naghomStyles = [
  NaghomStyle(
    slug: 'bayyati',
    name: 'Bayyati',
    summary: 'Memiliki 4 tingkat nada, berkarakter lembut, meliuk, dan sering digunakan pada awal atau akhir bacaan.',
    character: 'Lembut dan meliuk.',
    toneLevels: 4,
    usage: 'Sering digunakan pada awal atau akhir bacaan.',
  ),
  NaghomStyle(
    slug: 'hijaz',
    name: 'Hijaz',
    summary: 'Berkarakter cepat, lincah (allegro), dengan variasi nada yang tajam.',
    character: 'Cepat dan lincah (allegro), dengan variasi nada yang tajam.',
    toneLevels: null,
    usage: 'Memberi variasi dan semangat di tengah bacaan.',
  ),
  NaghomStyle(
    slug: 'shaba',
    name: 'Shaba',
    summary: 'Berkarakter cepat, cenderung mendayu atau menggugah rasa haru, memiliki 4 tingkat nada.',
    character: 'Cepat, cenderung mendayu atau menggugah rasa haru.',
    toneLevels: 4,
    usage: 'Ayat-ayat yang menyentuh perasaan.',
  ),
  NaghomStyle(
    slug: 'rast',
    name: 'Rast',
    summary: 'Memiliki 6 tingkat nada yang ringan dan cepat, sering dipakai untuk azan atau imam shalat.',
    character: 'Ringan dan cepat.',
    toneLevels: 6,
    usage: 'Sering dipakai untuk azan atau imam shalat.',
  ),
  NaghomStyle(
    slug: 'jiharkah',
    name: 'Jiharkah',
    summary: 'Dimulai dengan suara lembut lalu meninggi (2 tingkat nada), sering dipakai saat takbiran.',
    character: 'Dimulai dengan suara lembut lalu meninggi.',
    toneLevels: 2,
    usage: 'Sering dipakai saat takbiran.',
  ),
  NaghomStyle(
    slug: 'sika',
    name: 'Sika',
    summary: 'Berkarakter tenang, lembut, dan khusyuk dengan 4 jenis nada.',
    character: 'Tenang, lembut, dan khusyuk.',
    toneLevels: 4,
    toneTerm: 'jenis',
    usage: 'Bacaan yang menuntut ketenangan dan kekhusyukan.',
  ),
  NaghomStyle(
    slug: 'nahawand',
    name: 'Nahawand',
    summary: 'Memiliki 5 tingkat nada yang cocok untuk ayat-ayat bernuansa sedih atau penuh perenungan.',
    character: 'Cocok untuk ayat bernuansa sedih atau penuh perenungan.',
    toneLevels: 5,
    usage: 'Ayat-ayat bernuansa sedih atau perenungan.',
  ),
];
