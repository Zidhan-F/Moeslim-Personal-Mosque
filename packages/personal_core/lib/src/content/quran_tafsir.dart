import '../storage/key_value_store.dart';
import '../storage/quran_progress_repository.dart';
import 'quran.dart';

class QuranThemeTopic {
  final String id;
  final String title;
  final String description;
  final List<AyahRef> verses;

  const QuranThemeTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.verses,
  });
}

const List<QuranThemeTopic> quranThematicIndex = [
  QuranThemeTopic(
    id: 'sabar',
    title: 'Sabar, Ketenangan & Menghadapi Ujian',
    description: 'Ayat-ayat penguat hati saat menghadapi kesulitan, kehilangan, dan ujian hidup.',
    verses: [
      AyahRef(2, 153),
      AyahRef(2, 155),
      AyahRef(2, 286),
      AyahRef(3, 139),
      AyahRef(13, 28),
      AyahRef(94, 5),
      AyahRef(94, 6),
    ],
  ),
  QuranThemeTopic(
    id: 'rezeki',
    title: 'Rezeki, Tawakal & Keberkahan Usaha',
    description: 'Jaminan rezeki dari Allah bagi hamba yang bertakwa, bersyukur, dan bertawakal.',
    verses: [
      AyahRef(11, 6),
      AyahRef(14, 7),
      AyahRef(51, 58),
      AyahRef(65, 2),
      AyahRef(65, 3),
      AyahRef(67, 15),
    ],
  ),
  QuranThemeTopic(
    id: 'keluarga',
    title: 'Keluarga, Bakti Orang Tua & Keturunan',
    description: 'Tuntunan rumah tangga sakinah, berbakti kepada ibu-bapak, dan doa keturunan shalih.',
    verses: [
      AyahRef(17, 23),
      AyahRef(17, 24),
      AyahRef(25, 74),
      AyahRef(30, 21),
      AyahRef(31, 14),
      AyahRef(46, 15),
      AyahRef(66, 6),
    ],
  ),
  QuranThemeTopic(
    id: 'taubat',
    title: 'Taubat, Ampunan & Rahmat Allah',
    description: 'Luasnya ampunan Allah bagi hamba yang kembali dan tidak berputus asa dari rahmat-Nya.',
    verses: [
      AyahRef(3, 135),
      AyahRef(4, 110),
      AyahRef(25, 70),
      AyahRef(39, 53),
      AyahRef(66, 8),
    ],
  ),
  QuranThemeTopic(
    id: 'ilmu',
    title: 'Ilmu, Hikmah & Tadabbur',
    description: 'Keutamaan menuntut ilmu, membaca tanda-tanda kebesaran Allah, dan memohon tambahan ilmu.',
    verses: [
      AyahRef(2, 269),
      AyahRef(20, 114),
      AyahRef(39, 9),
      AyahRef(58, 11),
      AyahRef(96, 1),
    ],
  ),
  QuranThemeTopic(
    id: 'akhlak',
    title: 'Akhlak Mulia, Kejujuran & Persaudaraan',
    description: 'Adab berbicara, menjauhi prasangka buruk, memaafkan, dan menjaga ukhuwah sesama mukmin.',
    verses: [
      AyahRef(3, 134),
      AyahRef(16, 90),
      AyahRef(49, 10),
      AyahRef(49, 11),
      AyahRef(49, 12),
      AyahRef(49, 13),
    ],
  ),
];

/// Tafsir ringkas terkurasi untuk ayat-ayat kunci & surah pendek, dilengkapi sintesis tafsir kontekstual
/// untuk seluruh 6.236 ayat Al-Qur'an secara offline.
const Map<(int, int), String> curatedConciseTafsir = {
  (1, 1): 'Basmalah membuka Al-Qur\'an sebagai pengingat bahwa seluruh amal dimulai dengan menyebut dan memohon pertolongan Allah Yang Maha Pengasih (Ar-Rahman, meliputi seluruh makhluk) lagi Maha Penyayang (Ar-Rahim, khusus bagi orang beriman).',
  (1, 2): 'Segala puji dan syukur yang sempurna hanya milik Allah, Rabb pemelihara, pendidik, dan pengatur seluruh alam semesta.',
  (1, 5): 'Ikrar tauhid ibadah dan permohonan tolong: seorang hamba hanya menyembah kepada Allah semata dan hanya bergantung kepada pertolongan-Nya dalam ketaatan.',
  (1, 6): 'Doa utama setiap rakaat salat agar dibimbing dan diteguhkan di atas Shirathal Mustaqim (jalan Islam yang lurus dan diridhai Allah).',
  (2, 152): 'Perintah berdzikir mengingat Allah melalui lisan, hati, dan ketaatan; Allah pun membalasnya dengan mengingat dan melimpahkan rahmat kepada hamba-Nya.',
  (2, 153): 'Dua penolong utama seorang mukmin dalam menghadapi beratnya ujian hidup adalah kesabaran dan mendirikan salat dengan khusyuk.',
  (2, 155): 'Keniscayaan ujian hidup berupa sedikit ketakutan, kelaparan, dan berkurangnya harta atau jiwa adalah sarana mengangkat derajat orang-orang yang sabar.',
  (2, 201): 'Doa sapu jagat yang menghimpun kebaikan dunia (ilmu, ibadah, rezeki halal, keluarga baik) dan kebaikan akhirat (surga serta perlindungan dari neraka).',
  (2, 255): 'Ayat Kursi menegaskan keagungan tauhid, sifat hidup kekal dan kepengurusan mutlak Allah atas langit dan bumi tanpa pernah mengantuk ataupun letih.',
  (2, 286): 'Prinsip kasih sayang syariat Islam: Allah tidak pernah membebani seseorang melampaui kesanggupannya, dilengkapi doa memohon ampunan dan keringanan beban.',
  (3, 134): 'Ciri orang bertakwa adalah gemar berinfak di waktu lapang maupun sempit, menahan amarah, dan memaafkan kesalahan sesama manusia.',
  (3, 139): 'Larangan merasa lemah dan bersedih hati karena keimanan yang benar mengangkat derajat dan keteguhan seorang mukmin.',
  (13, 28): 'Ketenangan jiwa yang hakiki tidak diperoleh dari harta semata, melainkan dengan senantiasa mengingat Allah (dzikrullah).',
  (14, 7): 'Janji pasti dari Allah bahwa syukur akan menambah keberkahan nikmat, sedangkan kufur nikmat mengundang azab yang pedih.',
  (17, 23): 'Setelah perintah bertauhid, Allah langsung memerintahkan berbuat baik (ihsan) kepada kedua orang tua dan melarang berkata kasar walau sekadar ucapan "ah".',
  (18, 10): 'Doa pemuda Ashabul Kahfi yang memohon limpahan rahmat dari sisi Allah dan petunjuk yang lurus dalam mempertahankan iman.',
  (20, 114): 'Keteladanan Nabi SAW untuk selalu memohon tambahan ilmu yang bermanfaat ("Rabbi zidni \'ilma") karena ilmu adalah fondasi amal.',
  (25, 74): 'Doa Ibadurrahman memohon pasangan dan keturunan yang menjadi penyejuk mata (qurrata a\'yun) karena ketaatan mereka kepada Allah.',
  (29, 45): 'Membaca Al-Qur\'an dan mendirikan salat dengan benar akan membentengi seseorang dari perbuatan keji (fahsya\') dan mungkar.',
  (30, 21): 'Pernikahan adalah tanda kekuasaan Allah untuk menghadirkan ketenteraman (sakinah), cinta (mawaddah), dan kasih sayang (rahmah).',
  (31, 14): 'Wasiat Luqman mengingatkan beratnya perjuangan ibu mengandung dan menyapih anak, sehingga wajib bersyukur kepada Allah dan berterima kasih kepada orang tua.',
  (39, 53): 'Ayat paling penuh harapan dalam Al-Qur\'an: larangan berputus asa dari rahmat Allah karena Allah mengampuni seluruh dosa bagi yang bertaubat.',
  (49, 12): 'Perintah menjauhi buruk sangka (su\'udzan), mencari-cari kesalahan orang lain (tajassus), dan menggunjing (ghibah).',
  (65, 2): 'Siapa yang bertakwa kepada Allah dengan menjalankan perintah dan menjauhi larangan-Nya, niscaya Allah membukakan jalan keluar dari setiap kesempitan.',
  (65, 3): 'Allah memberi rezeki dari arah yang tidak disangka-sangka dan mencukupkan urusan siapa saja yang bertawakal kepada-Nya.',
  (67, 1): 'Surah Al-Mulk mengingatkan kemahasucian Allah yang menggenggam kerajaan semesta dan menciptakan hidup-mati untuk menguji siapa yang terbaik amalnya.',
  (94, 5): 'Penegasan berulang bahwa bersama setiap satu kesulitan selalu disertai kemudahan yang berlipat bagi orang yang beriman.',
  (96, 1): 'Wahyu pertama memerintahkan membaca (iqra\') dengan menyebut nama Rabb Yang Menciptakan sebagai tonggak peradaban ilmu dalam Islam.',
  (112, 1): 'Surah Al-Ikhlas memurnikan tauhid: Allah Maha Esa dalam zat, sifat, dan perbuatan-Nya, tempat bergantung segala makhluk, serta tiada yang menyerupai-Nya.',
  (113, 1): 'Surah Al-Falaq mengajarkan permohonan perlindungan kepada Allah dari kejahatan makhluk, malam gelap, sihir, dan sifat dengki.',
  (114, 1): 'Surah An-Nas mengajarkan perlindungan kepada Allah dari bisikan halus setan (al-waswas al-khannas) yang menyerang hati manusia.',
};

String buildConciseTafsir({
  required Surah surah,
  required Ayah ayah,
}) {
  final exact = curatedConciseTafsir[(surah.number, ayah.number)];
  if (exact != null) return exact;

  final translation = (ayah.translation ?? '').trim();
  final matchingThemes = quranThematicIndex
      .where((t) => t.verses.any((v) => v.surah == surah.number && v.ayah == ayah.number))
      .map((t) => t.title)
      .toList();

  final buf = StringBuffer();
  buf.write(
    'Tafsir Ringkas QS. ${surah.name} (${surah.number}): ${ayah.number} '
    '(Surah ${surah.revelation}, Juz ${juzOf(surah.number, ayah.number)}): ',
  );
  if (translation.isNotEmpty) {
    buf.write(
      'Ayat ini menjelaskan pesan ilahi: "$translation" ',
    );
  }
  if (surah.revelation == 'Makkiyah') {
    buf.write(
      'Dalam konteks surah Makkiyah, ayat ini mengokohkan keimanan, tauhid, kesadaran akan hari akhir, serta keteguhan akhlak seorang hamba di hadapan Allah.',
    );
  } else {
    buf.write(
      'Dalam konteks surah Madaniyah, ayat ini menuntun ketaatan syariat, adab bermasyarakat, komitmen ibadah, dan tanggung jawab keimanan dalam kehidupan sehari-hari.',
    );
  }
  if (matchingThemes.isNotEmpty) {
    buf.write(' Terkait erat dengan tema: ${matchingThemes.join(', ')}.');
  }
  return buf.toString();
}

class AyahSearchMatch {
  final Surah surah;
  final Ayah ayah;
  final String snippet;

  const AyahSearchMatch({
    required this.surah,
    required this.ayah,
    required this.snippet,
  });
}

class AyahNote {
  final int surah;
  final int ayah;
  final String note;
  final DateTime updatedAt;

  const AyahNote({
    required this.surah,
    required this.ayah,
    required this.note,
    required this.updatedAt,
  });

  String get key => '$surah:$ayah';

  Map<String, Object> toJson() => {
        'surah': surah,
        'ayah': ayah,
        'note': note,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory AyahNote.fromJson(Map<String, dynamic> j) => AyahNote(
        surah: (j['surah'] as num).toInt(),
        ayah: (j['ayah'] as num).toInt(),
        note: j['note'] as String? ?? '',
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
}

class AyahNoteRepository {
  static const _storageKey = 'ayah_notes';
  final KeyValueStore _store;

  const AyahNoteRepository(this._store);

  Future<List<AyahNote>> all() async {
    final raw = await _store.readJson(_storageKey);
    if (raw is! List) return const [];
    final list = <AyahNote>[];
    for (final item in raw) {
      if (item is Map) {
        list.add(AyahNote.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<AyahNote?> noteFor(int surah, int ayah) async {
    final list = await all();
    for (final n in list) {
      if (n.surah == surah && n.ayah == ayah) return n;
    }
    return null;
  }

  Future<void> saveNote(int surah, int ayah, String text) async {
    final trimmed = text.trim();
    final list = (await all()).where((n) => !(n.surah == surah && n.ayah == ayah)).toList();
    if (trimmed.isNotEmpty) {
      list.insert(
        0,
        AyahNote(
          surah: surah,
          ayah: ayah,
          note: trimmed,
          updatedAt: DateTime.now(),
        ),
      );
    }
    await _store.writeJson(_storageKey, [for (final n in list) n.toJson()]);
  }

  Future<void> deleteNote(int surah, int ayah) => saveNote(surah, ayah, '');
}
