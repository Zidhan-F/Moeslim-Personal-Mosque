/// Modul edukasi 7 irama (naghom) tilawah. Uraian mengikuti masukan pada
/// Product Blueprint v1.0 dan WAJIB ditelaah qari/guru tilawah sebelum rilis.
/// Irama bukan pengganti tajwid, makhraj, dan bimbingan guru.
class NaghomStyle {
  final String slug;
  final String name;
  final String character;
  final int? toneLevels;
  final String usage;
  final bool needsExpertReview;

  const NaghomStyle({
    required this.slug,
    required this.name,
    required this.character,
    required this.toneLevels,
    required this.usage,
    this.needsExpertReview = true,
  });
}

const naghomDisclaimer =
    'Materi irama bersifat pengenalan dasar dan sedang ditelaah oleh qari. '
    'Latihan irama tidak boleh mengorbankan ketepatan tajwid dan makhraj.';

const List<NaghomStyle> naghomStyles = [
  NaghomStyle(
    slug: 'bayyati',
    name: 'Bayyati',
    character: 'Lembut dan meliuk.',
    toneLevels: 4,
    usage: 'Sering digunakan pada awal atau akhir bacaan.',
  ),
  NaghomStyle(
    slug: 'hijaz',
    name: 'Hijaz',
    character: 'Cepat dan lincah (allegro), dengan variasi nada yang tajam.',
    toneLevels: null,
    usage: 'Variasi di tengah bacaan.',
  ),
  NaghomStyle(
    slug: 'shaba',
    name: 'Shaba',
    character: 'Cepat, cenderung mendayu atau menggugah rasa haru.',
    toneLevels: 4,
    usage: 'Ayat-ayat yang menyentuh perasaan.',
  ),
  NaghomStyle(
    slug: 'rast',
    name: 'Rast',
    character: 'Ringan dan cepat.',
    toneLevels: 6,
    usage: 'Sering dipakai untuk azan atau imam shalat.',
  ),
  NaghomStyle(
    slug: 'jiharkah',
    name: 'Jiharkah',
    character: 'Dimulai dengan suara lembut lalu meninggi.',
    toneLevels: 2,
    usage: 'Sering dipakai saat takbiran.',
  ),
  NaghomStyle(
    slug: 'sika',
    name: 'Sika',
    character: 'Tenang, lembut, dan khusyuk.',
    toneLevels: 4,
    usage: 'Bacaan yang menuntut ketenangan.',
  ),
  NaghomStyle(
    slug: 'nahawand',
    name: 'Nahawand',
    character: 'Cocok untuk ayat bernuansa sedih atau penuh perenungan.',
    toneLevels: 5,
    usage: 'Ayat-ayat perenungan.',
  ),
];
