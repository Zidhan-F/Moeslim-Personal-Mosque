import '../storage/key_value_store.dart';
import 'quran.dart';

class QuranWordGlossaryEntry {
  final String normalized;
  final String arabic;
  final String latin;
  final String meaning;
  final String root;

  const QuranWordGlossaryEntry({
    required this.normalized,
    required this.arabic,
    required this.latin,
    required this.meaning,
    required this.root,
  });
}

class AnalyzedAyahWord {
  final int position;
  final String arabicWord;
  final String latin;
  final String meaning;
  final String root;

  const AnalyzedAyahWord({
    required this.position,
    required this.arabicWord,
    required this.latin,
    required this.meaning,
    required this.root,
  });
}

String normalizeArabicWord(String input) {
  return input
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ٱ', 'ا')
      .trim();
}

const List<QuranWordGlossaryEntry> coreQuranVocabulary = [
  QuranWordGlossaryEntry(normalized: 'بسم', arabic: 'بِسْمِ', latin: 'Bismi', meaning: 'Dengan nama', root: 'س م و'),
  QuranWordGlossaryEntry(normalized: 'الله', arabic: 'اللَّهِ', latin: 'Allah', meaning: 'Allah (Tuhan Yang Maha Esa)', root: 'أ ل ه'),
  QuranWordGlossaryEntry(normalized: 'الرحمن', arabic: 'الرَّحْمَٰنِ', latin: 'Ar-Rahman', meaning: 'Yang Maha Pengasih', root: 'ر ح م'),
  QuranWordGlossaryEntry(normalized: 'الرحيم', arabic: 'الرَّحِيمِ', latin: 'Ar-Rahim', meaning: 'Yang Maha Penyayang', root: 'ر ح م'),
  QuranWordGlossaryEntry(normalized: 'الحمد', arabic: 'الْحَمْدُ', latin: 'Al-Hamdu', meaning: 'Segala puji', root: 'ح م د'),
  QuranWordGlossaryEntry(normalized: 'لله', arabic: 'لِلَّهِ', latin: 'Lillahi', meaning: 'Milik / bagi Allah', root: 'أ ل ه'),
  QuranWordGlossaryEntry(normalized: 'رب', arabic: 'رَبِّ', latin: 'Rabbi', meaning: 'Tuhan Pemelihara', root: 'ر ب ب'),
  QuranWordGlossaryEntry(normalized: 'العالمين', arabic: 'الْعَالَمِينَ', latin: 'Al-\'Alamin', meaning: 'Seluruh alam', root: 'ع ل م'),
  QuranWordGlossaryEntry(normalized: 'مالك', arabic: 'مَالِكِ', latin: 'Maliki', meaning: 'Pemilik / Penguasa', root: 'م ل ك'),
  QuranWordGlossaryEntry(normalized: 'يوم', arabic: 'يَوْمِ', latin: 'Yawmi', meaning: 'Hari', root: 'ي و م'),
  QuranWordGlossaryEntry(normalized: 'الدين', arabic: 'الدِّينِ', latin: 'Ad-Din', meaning: 'Pembalasan / Agama', root: 'د ي ن'),
  QuranWordGlossaryEntry(normalized: 'اياك', arabic: 'إِيَّاكَ', latin: 'Iyyaka', meaning: 'Hanya kepada Engkau', root: 'أ ي ي'),
  QuranWordGlossaryEntry(normalized: 'نعبد', arabic: 'نَعْبُدُ', latin: 'Na\'budu', meaning: 'Kami menyembah', root: 'ع ب د'),
  QuranWordGlossaryEntry(normalized: 'نستعين', arabic: 'نَسْتَعِينُ', latin: 'Nasta\'in', meaning: 'Kami memohon pertolongan', root: 'ع و ن'),
  QuranWordGlossaryEntry(normalized: 'اهدنا', arabic: 'اهْدِنَا', latin: 'Ihdina', meaning: 'Tunjukilah kami', root: 'ه د ي'),
  QuranWordGlossaryEntry(normalized: 'الصراط', arabic: 'الصِّرَاطَ', latin: 'Ash-Shirath', meaning: 'Jalan yang jelas', root: 'ص ر ط'),
  QuranWordGlossaryEntry(normalized: 'المستقيم', arabic: 'الْمُسْتَقِيمَ', latin: 'Al-Mustaqim', meaning: 'Yang lurus', root: 'ق و م'),
  QuranWordGlossaryEntry(normalized: 'قل', arabic: 'قُلْ', latin: 'Qul', meaning: 'Katakanlah', root: 'ق و ل'),
  QuranWordGlossaryEntry(normalized: 'هو', arabic: 'هُوَ', latin: 'Huwa', meaning: 'Dia', root: 'ه و'),
  QuranWordGlossaryEntry(normalized: 'احد', arabic: 'أَحَدٌ', latin: 'Ahad', meaning: 'Maha Esa / Satu', root: 'أ ح د'),
  QuranWordGlossaryEntry(normalized: 'الصمد', arabic: 'الصَّمَدُ', latin: 'Ash-Shamad', meaning: 'Tempat bergantung segala sesuatu', root: 'ص م د'),
  QuranWordGlossaryEntry(normalized: 'اعوذ', arabic: 'أَعُوذُ', latin: 'A\'udzu', meaning: 'Aku berlindung', root: 'ع و ذ'),
  QuranWordGlossaryEntry(normalized: 'الفلق', arabic: 'الْفَلَقِ', latin: 'Al-Falaq', meaning: 'Waktu subuh / fajar', root: 'ف ل ق'),
  QuranWordGlossaryEntry(normalized: 'الناس', arabic: 'النَّاسِ', latin: 'An-Nas', meaning: 'Manusia', root: 'أ ن س'),
  QuranWordGlossaryEntry(normalized: 'شر', arabic: 'شَرِّ', latin: 'Syarri', meaning: 'Kejahatan / keburukan', root: 'ش ر ر'),
  QuranWordGlossaryEntry(normalized: 'خلق', arabic: 'خَلَقَ', latin: 'Khalaqa', meaning: 'Dia telah menciptakan', root: 'خ ل ق'),
  QuranWordGlossaryEntry(normalized: 'الحي', arabic: 'الْحَيُّ', latin: 'Al-Hayyu', meaning: 'Yang Mahahidup', root: 'ح ي ي'),
  QuranWordGlossaryEntry(normalized: 'القيوم', arabic: 'الْقَيُّومُ', latin: 'Al-Qayyum', meaning: 'Yang terus-menerus mengurus makhluk', root: 'ق و م'),
  QuranWordGlossaryEntry(normalized: 'السماوات', arabic: 'السَّمَاوَاتِ', latin: 'As-Samawat', meaning: 'Langit-langit', root: 'س م و'),
  QuranWordGlossaryEntry(normalized: 'الارض', arabic: 'الْأَرْضِ', latin: 'Al-Ardh', meaning: 'Bumi', root: 'أ ر ض'),
  QuranWordGlossaryEntry(normalized: 'علم', arabic: 'عِلْمًا', latin: '\'Ilman', meaning: 'Ilmu pengetahuan', root: 'ع ل م'),
  QuranWordGlossaryEntry(normalized: 'الصبر', arabic: 'الصَّبْرِ', latin: 'Ash-Shabr', meaning: 'Kesabaran', root: 'ص ب ر'),
  QuranWordGlossaryEntry(normalized: 'الصلاة', arabic: 'الصَّلَاةِ', latin: 'Ash-Shalah', meaning: 'Salat', root: 'ص ل و'),
  QuranWordGlossaryEntry(normalized: 'القلوب', arabic: 'الْقُلُوبُ', latin: 'Al-Qulub', meaning: 'Hati-hati manusia', root: 'ق ل ب'),
  QuranWordGlossaryEntry(normalized: 'يسرا', arabic: 'يُسْرًا', latin: 'Yusran', meaning: 'Kemudahan', root: 'ي س ر'),
  QuranWordGlossaryEntry(normalized: 'العسر', arabic: 'الْعُسْرِ', latin: 'Al-\'Usr', meaning: 'Kesulitan', root: 'ع س ر'),
];

List<AnalyzedAyahWord> analyzeAyahWordByWord(Ayah ayah) {
  final rawWords = ayah.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !RegExp(r'^[۝۞۩]+$').hasMatch(w))
      .toList();
  final translationTokens = (ayah.translation ?? '')
      .split(RegExp(r'[,.;]\s*|\s+'))
      .where((t) => t.trim().isNotEmpty)
      .toList();

  final out = <AnalyzedAyahWord>[];
  for (var i = 0; i < rawWords.length; i++) {
    final w = rawWords[i];
    final norm = normalizeArabicWord(w);
    final match = coreQuranVocabulary
        .where((e) => e.normalized == norm || (norm.length >= 3 && norm.contains(e.normalized)))
        .firstOrNull;
    if (match != null) {
      out.add(
        AnalyzedAyahWord(
          position: i + 1,
          arabicWord: w,
          latin: match.latin,
          meaning: match.meaning,
          root: match.root,
        ),
      );
    } else {
      final approxMeaning = translationTokens.isEmpty
          ? 'Bagian kata ayat ${ayah.number}'
          : translationTokens[(i * translationTokens.length ~/ rawWords.length).clamp(0, translationTokens.length - 1)];
      final rootChars = norm.replaceAll(RegExp(r'^ال|^و|^ف|^ب|^ل'), '').split('').take(3).join(' ');
      out.add(
        AnalyzedAyahWord(
          position: i + 1,
          arabicWord: w,
          latin: 'Kata ke-${i + 1}',
          meaning: approxMeaning,
          root: rootChars.isEmpty ? '-' : rootChars,
        ),
      );
    }
  }
  return out;
}

// ================= 22. ASBABUN NUZUL OFFLINE =================

class AsbabunNuzulEntry {
  final int surah;
  final String ayahRange;
  final String title;
  final String contextNarrative;
  final String source;
  final String hikmah;

  const AsbabunNuzulEntry({
    required this.surah,
    required this.ayahRange,
    required this.title,
    required this.contextNarrative,
    required this.source,
    required this.hikmah,
  });
}

const List<AsbabunNuzulEntry> asbabunNuzulCatalog = [
  AsbabunNuzulEntry(
    surah: 2,
    ayahRange: '144',
    title: 'Perpindahan Arah Kiblat ke Masjidil Haram',
    contextNarrative:
        'Saat di Madinah, Rasulullah SAW salat menghadap Baitul Maqdis selama 16 atau 17 bulan sambil sering menengadahkan wajah ke langit berharap kiblat diarahkan ke Ka\'bah (kiblat Nabi Ibrahim AS). Maka Allah menurunkan QS. Al-Baqarah: 144 yang memerintahkan memalingkan wajah ke arah Masjidil Haram.',
    source: 'HR. Bukhari no. 40 & Muslim no. 525 (Dari Al-Bara\' bin \'Azib RA)',
    hikmah: 'Ketaatan penuh para sahabat yang langsung memutar arah barisan salat begitu mendengar perintah wahyu.',
  ),
  AsbabunNuzulEntry(
    surah: 2,
    ayahRange: '186',
    title: 'Kedekatan Allah dalam Menjawab Doa Hamba',
    contextNarrative:
        'Seorang sahabat bertanya kepada Rasulullah SAW: "Wahai Rasulullah, apakah Rabb kita itu dekat sehingga kami cukup berbisik ketika berdoa, ataukah jauh sehingga kami perlu berseru keras?" Maka turunlah ayat: "Dan apabila hamba-hamba-Ku bertanya kepadamu tentang Aku, maka sesungguhnya Aku adalah dekat..."',
    source: 'HR. Ibnu Jarir Ath-Thabari & Ibnu Abi Hatim · Lubabun Nuqul As-Suyuthi',
    hikmah: 'Berdoa dilakukan dengan suara lembut, penuh adab, dan keyakinan bahwa Allah Maha Mendengar.',
  ),
  AsbabunNuzulEntry(
    surah: 18,
    ayahRange: '1–26',
    title: 'Pertanyaan tentang Pemuda Ashabul Kahfi',
    contextNarrative:
        'Kaum Quraisy mengutus An-Nadhr bin Al-Harits dan \'Uqbah bin Abi Mu\'ith kepada para pendeta di Madinah, lalu menanyakan tiga hal kepada Nabi SAW: kisah para pemuda di masa silam (Ashabul Kahfi), pengembara yang mencapai timur dan barat (Dzulqarnain), serta hakikat Ruh. Setelah sempat tertunda karena belum mengucapkan Insya Allah, turunlah Surah Al-Kahfi.',
    source: 'Tafsir Ibnu Katsir & Sirah Ibnu Hisyam',
    hikmah: 'Adab mengucapkan "Insya Allah" pada setiap rencana masa depan serta keteguhan iman para pemuda Ashabul Kahfi.',
  ),
  AsbabunNuzulEntry(
    surah: 49,
    ayahRange: '6',
    title: 'Perintah Tabayyun (Klarifikasi Berita)',
    contextNarrative:
        'Ayat ini turun berkaitan dengan utusan pemungut zakat yang menyangka Bani Musthaliq hendak menyerang, padahal mereka keluar untuk menyambut kedatangan utusan Rasulullah SAW. Khalid bin Walid RA kemudian memeriksa keadaan malam hari dan mendapati mereka mengumandangkan adzan serta mendirikan salat.',
    source: 'HR. Ahmad IV/279 · Lubabun Nuqul As-Suyuthi',
    hikmah: 'Kewajiban melakukan tabayyun (verifikasi fakta) sebelum mengambil keputusan agar tidak menzalimi orang lain lalu menyesal.',
  ),
  AsbabunNuzulEntry(
    surah: 80,
    ayahRange: '1–10',
    title: 'Teguran Lembut kepada Nabi terkait Abdullah bin Ummi Maktum RA',
    contextNarrative:
        'Ketika Rasulullah SAW sedang serius berdakwah kepada para pemuka Quraisy dengan harapan mereka masuk Islam, datanglah sahabat tunanetra Abdullah bin Ummi Maktum RA meminta diajarkan Al-Qur\'an. Turunlah awal Surah \'Abasa yang memuliakan penuntut ilmu yang datang dengan rasa takut kepada Allah.',
    source: 'HR. Tirmidzi no. 3331 & Al-Muwaththa\' Malik',
    hikmah: 'Islam memuliakan setiap penuntut ilmu yang tulus tanpa memandang kedudukan sosial atau fisik.',
  ),
  AsbabunNuzulEntry(
    surah: 93,
    ayahRange: '1–3',
    title: 'Penghiburan Allah pada Surah Adh-Dhuha',
    contextNarrative:
        'Ketika Rasulullah SAW sempat sakit sehingga tidak bangun malam selama dua atau tiga malam dan wahyu jeda turun sementara waktu, sebagian kaum musyrikin mengejek bahwa Tuhannya telah meninggalkannya. Maka Allah menurunkan Surah Adh-Dhuha: "Tuhanmu tidak meninggalkan engkau dan tidak pula membencimu."',
    source: 'HR. Bukhari no. 4950 & Muslim no. 1797 (Dari Jundub bin Sufyan RA)',
    hikmah: 'Saat seorang hamba melewati masa sulit dan sunyi, kasih sayang serta pertolongan Allah tidak pernah meninggalkannya.',
  ),
  AsbabunNuzulEntry(
    surah: 108,
    ayahRange: '1–3',
    title: 'Anugerah Telaga Al-Kautsar',
    contextNarrative:
        'Ketika putra Rasulullah SAW wafat saat masih kecil, Al-\'Ash bin Wa\'il menyebut beliau sebagai "abtar" (terputus keturunan dan sebutannya). Maka Allah menurunkan Surah Al-Kautsar yang menganugerahkan kebaikan melimpah di dunia-akhirat dan menegaskan bahwa pembenci beliaulah yang sebenarnya terputus.',
    source: 'HR. Muslim no. 400 & Ibnu Jarir Ath-Thabari',
    hikmah: 'Membalas celaan dengan memperbanyak syukur, salat karena Allah, dan berkurban.',
  ),
  AsbabunNuzulEntry(
    surah: 112,
    ayahRange: '1–4',
    title: 'Jawaban Tauhid Murni pada Surah Al-Ikhlas',
    contextNarrative:
        'Kaum musyrikin bertanya kepada Rasulullah SAW: "Wahai Muhammad, sebutkanlah nasab/sifat Tuhanmu kepada kami!" Maka Allah menurunkan Surah Al-Ikhlas: "Katakanlah, Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan..."',
    source: 'HR. Tirmidzi no. 3364 & Ahmad V/133 (Dari Ubay bin Ka\'ab RA)',
    hikmah: 'Surah Al-Ikhlas setara dengan sepertiga Al-Qur\'an karena merangkum pemurnian sifat-sifat Allah SWT.',
  ),
];

List<AsbabunNuzulEntry> asbabunNuzulForSurah(int surah) =>
    asbabunNuzulCatalog.where((e) => e.surah == surah).toList();

// ================= 23. FLASHCARD KOSAKATA AL-QUR'AN =================

class QuranVocabRepository {
  static const _masteredKey = 'quran_vocab_mastered';
  final KeyValueStore _store;

  const QuranVocabRepository(this._store);

  Future<Set<String>> masteredWords() async {
    final raw = await _store.readJson(_masteredKey);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is String) x,
    };
  }

  Future<Set<String>> toggleMastered(String normalizedWord) async {
    final set = await masteredWords();
    if (!set.remove(normalizedWord)) {
      set.add(normalizedWord);
    }
    await _store.writeJson(_masteredKey, set.toList());
    return set;
  }
}

// ================= 24. TEMA FOKUS TILAWAH =================

enum TilawahSurfaceTheme {
  standard('Mushaf Standar'),
  sepiaPaper('Kertas Sepia Hangat'),
  amoledBlack('AMOLED Hitam Pekat');

  final String label;
  const TilawahSurfaceTheme(this.label);
}

// ================= 25. PINTASAN SURAH RUTIN & 15 AYAT SAJDAH =================

class RoutineQuranShortcut {
  final String id;
  final String title;
  final String timingAndVirtue;
  final int surah;
  final int? ayah;

  const RoutineQuranShortcut({
    required this.id,
    required this.title,
    required this.timingAndVirtue,
    required this.surah,
    this.ayah,
  });
}

const List<RoutineQuranShortcut> routineQuranShortcuts = [
  RoutineQuranShortcut(
    id: 'al_kahfi',
    title: 'Surah Al-Kahfi',
    timingAndVirtue: 'Sunnah Malam & Hari Jumat · Cahaya di antara dua Jumat (HR. Al-Hakim)',
    surah: 18,
  ),
  RoutineQuranShortcut(
    id: 'al_mulk',
    title: 'Surah Al-Mulk (Tabarak)',
    timingAndVirtue: 'Sunnah Sebelum Tidur · Penyelamat dari siksa kubur (HR. Tirmidzi)',
    surah: 67,
  ),
  RoutineQuranShortcut(
    id: 'al_waqiah',
    title: 'Surah Al-Waqi\'ah',
    timingAndVirtue: 'Pengingat Hari Kiamat, Syukur & Tawakal Rezeki',
    surah: 56,
  ),
  RoutineQuranShortcut(
    id: 'yasin',
    title: 'Surah Yasin',
    timingAndVirtue: 'Peneguh Tauhid, Risalah & Kebangkitan Akhirat',
    surah: 36,
  ),
  RoutineQuranShortcut(
    id: 'ar_rahman',
    title: 'Surah Ar-Rahman',
    timingAndVirtue: 'Tadabbur Nikmat-Nikmat Allah yang Tak Terhitung',
    surah: 55,
  ),
  RoutineQuranShortcut(
    id: 'ayat_kursi',
    title: 'Ayat Kursi (QS. Al-Baqarah: 255)',
    timingAndVirtue: 'Ayat paling agung dalam Al-Qur\'an; dibaca pagi, petang, ba\'da salat & sebelum tidur',
    surah: 2,
    ayah: 255,
  ),
  RoutineQuranShortcut(
    id: 'akhir_baqarah',
    title: '2 Ayat Terakhir Al-Baqarah (285–286)',
    timingAndVirtue: 'Barang siapa membacanya di malam hari, maka keduanya mencukupinya (HR. Bukhari & Muslim)',
    surah: 2,
    ayah: 285,
  ),
];

class SajdahVerseInfo {
  final int number;
  final int surah;
  final int ayah;
  final String excerptMeaning;

  const SajdahVerseInfo(this.number, this.surah, this.ayah, this.excerptMeaning);
}

const List<SajdahVerseInfo> sajdahVersesCatalog = [
  SajdahVerseInfo(1, 7, 206, 'Malaikat di sisi Tuhan tidak merasa enggan menyembah Allah dan mereka bersujud kepada-Nya.'),
  SajdahVerseInfo(2, 13, 15, 'Hanya kepada Allah bersujud segala apa yang di langit dan di bumi.'),
  SajdahVerseInfo(3, 16, 50, 'Mereka takut kepada Tuhan mereka yang di atas mereka dan melaksanakan apa yang diperintahkan.'),
  SajdahVerseInfo(4, 17, 109, 'Mereka menyungkur atas muka mereka sambil menangis dan mereka bertambah khusyuk.'),
  SajdahVerseInfo(5, 19, 58, 'Apabila dibacakan ayat-ayat Allah Yang Maha Pemurah kepada mereka, mereka menyungkur bersujud.'),
  SajdahVerseInfo(6, 22, 18, 'Apakah kamu tiada mengetahui bahwa kepada Allah bersujud apa yang ada di langit dan di bumi.'),
  SajdahVerseInfo(7, 22, 77, 'Wahai orang-orang yang beriman, ruku\'lah kamu, sujudlah kamu, dan sembahlah Tuhanmu.'),
  SajdahVerseInfo(8, 25, 60, 'Dan apabila dikatakan kepada mereka: Sujudlah kamu sekalian kepada Yang Maha Penyayang.'),
  SajdahVerseInfo(9, 27, 26, 'Allah, tiada Tuhan Yang disembah kecuali Dia, Tuhan Yang mempunyai \'Arsy yang agung.'),
  SajdahVerseInfo(10, 32, 15, 'Sesungguhnya orang yang beriman kepada ayat-ayat Kami adalah mereka yang apabila diperingatkan, menyungkur sujud.'),
  SajdahVerseInfo(11, 38, 24, 'Dan Dawud mengetahui bahwa Kami mengujinya; maka ia meminta ampun kepada Tuhannya lalu menyungkur sujud.'),
  SajdahVerseInfo(12, 41, 38, 'Jika mereka menyombongkan diri, maka mereka yang di sisi Tuhanmu bertasbih kepada-Nya di malam dan siang hari.'),
  SajdahVerseInfo(13, 53, 62, 'Maka bersujudlah kepada Allah dan sembahlah (Dia).'),
  SajdahVerseInfo(14, 84, 21, 'Dan apabila Al-Qur\'an dibacakan kepada mereka, mereka tidak bersujud.'),
  SajdahVerseInfo(15, 96, 19, 'Sekali-kali jangan, janganlah kamu patuh kepadanya; dan sujudlah serta dekatkanlah dirimu kepada Tuhan.'),
];
