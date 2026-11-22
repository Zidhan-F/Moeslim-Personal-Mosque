import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import 'l10n_core.dart';
import 'quran.dart';

class QuranWordGlossaryEntry {
  final String normalized;
  final String arabic;
  final String latin;
  final String meaning;
  final String? meaningEn;
  final String root;

  const QuranWordGlossaryEntry({
    required this.normalized,
    required this.arabic,
    required this.latin,
    required this.meaning,
    this.meaningEn,
    required this.root,
  });

  String meaningFor(AppLanguage lang) =>
      lang == AppLanguage.en && (meaningEn?.isNotEmpty ?? false) ? meaningEn! : meaning;
}

class AnalyzedAyahWord {
  final int position;
  final String arabicWord;
  final String latin;
  final String? latinEn;
  final String meaning;
  final String? meaningEn;
  final String root;

  const AnalyzedAyahWord({
    required this.position,
    required this.arabicWord,
    required this.latin,
    this.latinEn,
    required this.meaning,
    this.meaningEn,
    required this.root,
  });

  String latinFor(AppLanguage lang) =>
      lang == AppLanguage.en && (latinEn?.isNotEmpty ?? false) ? latinEn! : latin;
  String meaningFor(AppLanguage lang) =>
      lang == AppLanguage.en && (meaningEn?.isNotEmpty ?? false) ? meaningEn! : meaning;
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
  QuranWordGlossaryEntry(normalized: 'بسم', arabic: 'بِسْمِ', latin: 'Bismi', meaning: 'Dengan nama', meaningEn: 'In the name of', root: 'س م و'),
  QuranWordGlossaryEntry(normalized: 'الله', arabic: 'اللَّهِ', latin: 'Allah', meaning: 'Allah (Tuhan Yang Maha Esa)', meaningEn: 'Allah (The One God)', root: 'أ ل ه'),
  QuranWordGlossaryEntry(normalized: 'الرحمن', arabic: 'الرَّحْمَٰنِ', latin: 'Ar-Rahman', meaning: 'Yang Maha Pengasih', meaningEn: 'The Entirely Merciful', root: 'ر ح م'),
  QuranWordGlossaryEntry(normalized: 'الرحيم', arabic: 'الرَّحِيمِ', latin: 'Ar-Rahim', meaning: 'Yang Maha Penyayang', meaningEn: 'The Especially Merciful', root: 'ر ح م'),
  QuranWordGlossaryEntry(normalized: 'الحمد', arabic: 'الْحَمْدُ', latin: 'Al-Hamdu', meaning: 'Segala puji', meaningEn: 'All praise', root: 'ح م د'),
  QuranWordGlossaryEntry(normalized: 'لله', arabic: 'لِلَّهِ', latin: 'Lillahi', meaning: 'Milik / bagi Allah', meaningEn: 'Belongs to Allah', root: 'أ ل ه'),
  QuranWordGlossaryEntry(normalized: 'رب', arabic: 'رَبِّ', latin: 'Rabbi', meaning: 'Tuhan Pemelihara', meaningEn: 'Lord & Sustainer', root: 'ر ب ب'),
  QuranWordGlossaryEntry(normalized: 'العالمين', arabic: 'الْعَالَمِينَ', latin: 'Al-\'Alamin', meaning: 'Seluruh alam', meaningEn: 'All the worlds', root: 'ع ل م'),
  QuranWordGlossaryEntry(normalized: 'مالك', arabic: 'مَالِكِ', latin: 'Maliki', meaning: 'Pemilik / Penguasa', meaningEn: 'Master / Sovereign', root: 'م ل ك'),
  QuranWordGlossaryEntry(normalized: 'يوم', arabic: 'يَوْمِ', latin: 'Yawmi', meaning: 'Hari', meaningEn: 'Day', root: 'ي و م'),
  QuranWordGlossaryEntry(normalized: 'الدين', arabic: 'الدِّينِ', latin: 'Ad-Din', meaning: 'Pembalasan / Agama', meaningEn: 'Recompense / Religion', root: 'د ي ن'),
  QuranWordGlossaryEntry(normalized: 'اياك', arabic: 'إِيَّاكَ', latin: 'Iyyaka', meaning: 'Hanya kepada Engkau', meaningEn: 'You alone', root: 'أ ي ي'),
  QuranWordGlossaryEntry(normalized: 'نعبد', arabic: 'نَعْبُدُ', latin: 'Na\'budu', meaning: 'Kami menyembah', meaningEn: 'We worship', root: 'ع ب د'),
  QuranWordGlossaryEntry(normalized: 'نستعين', arabic: 'نَسْتَعِينُ', latin: 'Nasta\'in', meaning: 'Kami memohon pertolongan', meaningEn: 'We seek help', root: 'ع و ن'),
  QuranWordGlossaryEntry(normalized: 'اهدنا', arabic: 'اهْدِنَا', latin: 'Ihdina', meaning: 'Tunjukilah kami', meaningEn: 'Guide us', root: 'ه د ي'),
  QuranWordGlossaryEntry(normalized: 'الصراط', arabic: 'الصِّرَاطَ', latin: 'Ash-Shirath', meaning: 'Jalan yang jelas', meaningEn: 'The clear path', root: 'ص ر ط'),
  QuranWordGlossaryEntry(normalized: 'المستقيم', arabic: 'الْمُسْتَقِيمَ', latin: 'Al-Mustaqim', meaning: 'Yang lurus', meaningEn: 'The straight', root: 'ق و م'),
  QuranWordGlossaryEntry(normalized: 'قل', arabic: 'قُلْ', latin: 'Qul', meaning: 'Katakanlah', meaningEn: 'Say', root: 'ق و ل'),
  QuranWordGlossaryEntry(normalized: 'هو', arabic: 'هُوَ', latin: 'Huwa', meaning: 'Dia', meaningEn: 'He', root: 'ه و'),
  QuranWordGlossaryEntry(normalized: 'احد', arabic: 'أَحَدٌ', latin: 'Ahad', meaning: 'Maha Esa / Satu', meaningEn: 'The One / Indivisible', root: 'أ ح د'),
  QuranWordGlossaryEntry(normalized: 'الصمد', arabic: 'الصَّمَدُ', latin: 'Ash-Shamad', meaning: 'Tempat bergantung segala sesuatu', meaningEn: 'The Eternal Refuge', root: 'ص م د'),
  QuranWordGlossaryEntry(normalized: 'اعوذ', arabic: 'أَعُوذُ', latin: 'A\'udzu', meaning: 'Aku berlindung', meaningEn: 'I seek refuge', root: 'ع و ذ'),
  QuranWordGlossaryEntry(normalized: 'الفلق', arabic: 'الْفَلَقِ', latin: 'Al-Falaq', meaning: 'Waktu subuh / fajar', meaningEn: 'The daybreak / dawn', root: 'ف ل ق'),
  QuranWordGlossaryEntry(normalized: 'الناس', arabic: 'النَّاسِ', latin: 'An-Nas', meaning: 'Manusia', meaningEn: 'Mankind', root: 'أ ن س'),
  QuranWordGlossaryEntry(normalized: 'شر', arabic: 'شَرِّ', latin: 'Syarri', meaning: 'Kejahatan / keburukan', meaningEn: 'Evil / harm', root: 'ش ر ر'),
  QuranWordGlossaryEntry(normalized: 'خلق', arabic: 'خَلَقَ', latin: 'Khalaqa', meaning: 'Dia telah menciptakan', meaningEn: 'He created', root: 'خ ل ق'),
  QuranWordGlossaryEntry(normalized: 'الحي', arabic: 'الْحَيُّ', latin: 'Al-Hayyu', meaning: 'Yang Mahahidup', meaningEn: 'The Ever-Living', root: 'ح ي ي'),
  QuranWordGlossaryEntry(normalized: 'القيوم', arabic: 'الْقَيُّومُ', latin: 'Al-Qayyum', meaning: 'Yang terus-menerus mengurus makhluk', meaningEn: 'The Sustainer of all existence', root: 'ق و م'),
  QuranWordGlossaryEntry(normalized: 'السماوات', arabic: 'السَّمَاوَاتِ', latin: 'As-Samawat', meaning: 'Langit-langit', meaningEn: 'The heavens', root: 'س م و'),
  QuranWordGlossaryEntry(normalized: 'الارض', arabic: 'الْأَرْضِ', latin: 'Al-Ardh', meaning: 'Bumi', meaningEn: 'The earth', root: 'أ ر ض'),
  QuranWordGlossaryEntry(normalized: 'علم', arabic: 'عِلْمًا', latin: '\'Ilman', meaning: 'Ilmu pengetahuan', meaningEn: 'Knowledge', root: 'ع ل م'),
  QuranWordGlossaryEntry(normalized: 'الصبر', arabic: 'الصَّبْرِ', latin: 'Ash-Shabr', meaning: 'Kesabaran', meaningEn: 'Patience', root: 'ص ب ر'),
  QuranWordGlossaryEntry(normalized: 'الصلاة', arabic: 'الصَّلَاةِ', latin: 'Ash-Shalah', meaning: 'Salat', meaningEn: 'Prayer', root: 'ص ل و'),
  QuranWordGlossaryEntry(normalized: 'القلوب', arabic: 'الْقُلُوبُ', latin: 'Al-Qulub', meaning: 'Hati-hati manusia', meaningEn: 'Hearts', root: 'ق ل ب'),
  QuranWordGlossaryEntry(normalized: 'يسرا', arabic: 'يُسْرًا', latin: 'Yusran', meaning: 'Kemudahan', meaningEn: 'Ease', root: 'ي س ر'),
  QuranWordGlossaryEntry(normalized: 'العسر', arabic: 'الْعُسْرِ', latin: 'Al-\'Usr', meaning: 'Kesulitan', meaningEn: 'Hardship', root: 'ع س ر'),
];

List<AnalyzedAyahWord> analyzeAyahWordByWord(
  Ayah ayah, {
  AppLanguage lang = AppLanguage.id,
}) {
  final rawWords = ayah.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !RegExp(r'^[۝۞۩]+$').hasMatch(w))
      .toList();
  final translationTokensId = (ayah.translation ?? '')
      .split(RegExp(r'[,.;]\s*|\s+'))
      .where((t) => t.trim().isNotEmpty)
      .toList();
  final translationTokensEn = (ayah.translationFor(AppLanguage.en) ?? '')
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
          latinEn: match.latin,
          meaning: match.meaningFor(lang),
          meaningEn: match.meaningEn ?? match.meaning,
          root: match.root,
        ),
      );
    } else {
      final approxMeaningId = translationTokensId.isEmpty
          ? 'Bagian kata ayat ${ayah.number}'
          : translationTokensId[(i * translationTokensId.length ~/ rawWords.length).clamp(0, translationTokensId.length - 1)];
      final approxMeaningEn = translationTokensEn.isEmpty
          ? 'Word in verse ${ayah.number}'
          : translationTokensEn[(i * translationTokensEn.length ~/ rawWords.length).clamp(0, translationTokensEn.length - 1)];
      final rootChars = norm.replaceAll(RegExp(r'^ال|^و|^ف|^ب|^ل'), '').split('').take(3).join(' ');
      out.add(
        AnalyzedAyahWord(
          position: i + 1,
          arabicWord: w,
          latin: tr(lang, 'Kata ke-${i + 1}', 'Word #${i + 1}'),
          latinEn: 'Word #${i + 1}',
          meaning: tr(lang, approxMeaningId, approxMeaningEn),
          meaningEn: approxMeaningEn,
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
  final String? titleEn;
  final String contextNarrative;
  final String? contextNarrativeEn;
  final String source;
  final String? sourceEn;
  final String hikmah;
  final String? hikmahEn;

  const AsbabunNuzulEntry({
    required this.surah,
    required this.ayahRange,
    required this.title,
    this.titleEn,
    required this.contextNarrative,
    this.contextNarrativeEn,
    required this.source,
    this.sourceEn,
    required this.hikmah,
    this.hikmahEn,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String contextNarrativeFor(AppLanguage lang) =>
      lang == AppLanguage.en && (contextNarrativeEn?.isNotEmpty ?? false)
          ? contextNarrativeEn!
          : contextNarrative;
  String sourceFor(AppLanguage lang) =>
      lang == AppLanguage.en && (sourceEn?.isNotEmpty ?? false) ? sourceEn! : source;
  String hikmahFor(AppLanguage lang) =>
      lang == AppLanguage.en && (hikmahEn?.isNotEmpty ?? false) ? hikmahEn! : hikmah;
}

const List<AsbabunNuzulEntry> asbabunNuzulCatalog = [
  AsbabunNuzulEntry(
    surah: 2,
    ayahRange: '144',
    title: 'Perpindahan Arah Kiblat ke Masjidil Haram',
    titleEn: 'Change of the Qibla Toward Al-Masjid al-Haram',
    contextNarrative:
        'Saat di Madinah, Rasulullah SAW salat menghadap Baitul Maqdis selama 16 atau 17 bulan sambil sering menengadahkan wajah ke langit berharap kiblat diarahkan ke Ka\'bah (kiblat Nabi Ibrahim AS). Maka Allah menurunkan QS. Al-Baqarah: 144 yang memerintahkan memalingkan wajah ke arah Masjidil Haram.',
    contextNarrativeEn:
        'In Madinah, the Prophet (peace be upon him) prayed facing Jerusalem for 16 or 17 months while frequently turning his gaze heavenward, longing for the Qibla of Prophet Abraham (the Ka\'bah). Allah then revealed Quran 2:144 commanding him to turn toward Al-Masjid al-Haram.',
    source: 'HR. Bukhari no. 40 & Muslim no. 525 (Dari Al-Bara\' bin \'Azib RA)',
    sourceEn: 'Sahih al-Bukhari 40 & Sahih Muslim 525 (Narrated by Al-Bara\' ibn \'Azib RA)',
    hikmah: 'Ketaatan penuh para sahabat yang langsung memutar arah barisan salat begitu mendengar perintah wahyu.',
    hikmahEn: 'The prompt obedience of the Companions, who turned their prayer rows immediately upon hearing the revelation.',
  ),
  AsbabunNuzulEntry(
    surah: 2,
    ayahRange: '186',
    title: 'Kedekatan Allah dalam Menjawab Doa Hamba',
    titleEn: 'Allah\'s Nearness in Answering Supplications',
    contextNarrative:
        'Seorang sahabat bertanya kepada Rasulullah SAW: "Wahai Rasulullah, apakah Rabb kita itu dekat sehingga kami cukup berbisik ketika berdoa, ataukah jauh sehingga kami perlu berseru keras?" Maka turunlah ayat: "Dan apabila hamba-hamba-Ku bertanya kepadamu tentang Aku, maka sesungguhnya Aku adalah dekat..."',
    contextNarrativeEn:
        'A Companion asked the Prophet (peace be upon him), "O Messenger of Allah, is our Lord near so we should whisper to Him, or far so we should call aloud?" Allah then revealed: "And when My servants ask you concerning Me, indeed I am near..."',
    source: 'HR. Ibnu Jarir Ath-Thabari & Ibnu Abi Hatim · Lubabun Nuqul As-Suyuthi',
    sourceEn: 'Narrated by At-Tabari & Ibn Abi Hatim · Lubab an-Nuqul by As-Suyuti',
    hikmah: 'Berdoa dilakukan dengan suara lembut, penuh adab, dan keyakinan bahwa Allah Maha Mendengar.',
    hikmahEn: 'Supplication is offered with a gentle voice, humility, and certainty that Allah hears every call.',
  ),
  AsbabunNuzulEntry(
    surah: 18,
    ayahRange: '1–26',
    title: 'Pertanyaan tentang Pemuda Ashabul Kahfi',
    titleEn: 'The Inquiry About the Youths of the Cave',
    contextNarrative:
        'Kaum Quraisy mengutus An-Nadhr bin Al-Harits dan \'Uqbah bin Abi Mu\'ith kepada para pendeta di Madinah, lalu menanyakan tiga hal kepada Nabi SAW: kisah para pemuda di masa silam (Ashabul Kahfi), pengembara yang mencapai timur dan barat (Dzulqarnain), serta hakikat Ruh. Setelah sempat tertunda karena belum mengucapkan Insya Allah, turunlah Surah Al-Kahfi.',
    contextNarrativeEn:
        'The Quraysh sent An-Nadr ibn al-Harith and \'Uqbah ibn Abi Mu\'ayt to scholars in Madinah and tested the Prophet with three questions: the youths of ancient times (People of the Cave), the traveler who reached east and west (Dhul-Qarnayn), and the reality of the soul. After a brief pause for omitting "In sha\' Allah," Surah Al-Kahf was revealed.',
    source: 'Tafsir Ibnu Katsir & Sirah Ibnu Hisyam',
    sourceEn: 'Tafsir Ibn Kathir & Sirah Ibn Hisham',
    hikmah: 'Adab mengucapkan "Insya Allah" pada setiap rencana masa depan serta keteguhan iman para pemuda Ashabul Kahfi.',
    hikmahEn: 'The etiquette of saying "In sha\' Allah" for future plans and the steadfast faith of the Youths of the Cave.',
  ),
  AsbabunNuzulEntry(
    surah: 49,
    ayahRange: '6',
    title: 'Perintah Tabayyun (Klarifikasi Berita)',
    titleEn: 'The Command to Verify News (Tabayyun)',
    contextNarrative:
        'Ayat ini turun berkaitan dengan utusan pemungut zakat yang menyangka Bani Musthaliq hendak menyerang, padahal mereka keluar untuk menyambut kedatangan utusan Rasulullah SAW. Khalid bin Walid RA kemudian memeriksa keadaan malam hari dan mendapati mereka mengumandangkan adzan serta mendirikan salat.',
    contextNarrativeEn:
        'This verse was revealed after a Zakat envoy mistakenly reported that Banu al-Mustaliq were preparing to attack, when they had actually come out to welcome him. Khalid ibn al-Walid (RA) investigated at night and found them calling the Adhan and establishing prayer.',
    source: 'HR. Ahmad IV/279 · Lubabun Nuqul As-Suyuthi',
    sourceEn: 'Musnad Ahmad 4/279 · Lubab an-Nuqul by As-Suyuti',
    hikmah: 'Kewajiban melakukan tabayyun (verifikasi fakta) sebelum mengambil keputusan agar tidak menzalimi orang lain lalu menyesal.',
    hikmahEn: 'The duty to verify reports before acting, preventing injustice to innocent people and subsequent regret.',
  ),
  AsbabunNuzulEntry(
    surah: 80,
    ayahRange: '1–10',
    title: 'Teguran Lembut kepada Nabi terkait Abdullah bin Ummi Maktum RA',
    titleEn: 'Gentle Reminder Regarding Abdullah ibn Umm Maktum (RA)',
    contextNarrative:
        'Ketika Rasulullah SAW sedang serius berdakwah kepada para pemuka Quraisy dengan harapan mereka masuk Islam, datanglah sahabat tunanetra Abdullah bin Ummi Maktum RA meminta diajarkan Al-Qur\'an. Turunlah awal Surah \'Abasa yang memuliakan penuntut ilmu yang datang dengan rasa takut kepada Allah.',
    contextNarrativeEn:
        'While the Prophet (peace be upon him) was earnestly inviting Quraysh leaders to Islam, the blind Companion Abdullah ibn Umm Maktum (RA) arrived seeking Quran instruction. The opening verses of Surah \'Abasa were revealed, honoring the sincere seeker who comes with reverence for Allah.',
    source: 'HR. Tirmidzi no. 3331 & Al-Muwaththa\' Malik',
    sourceEn: 'Jami\' at-Tirmidhi 3331 & Muwatta Malik',
    hikmah: 'Islam memuliakan setiap penuntut ilmu yang tulus tanpa memandang kedudukan sosial atau fisik.',
    hikmahEn: 'Islam honors every sincere seeker of knowledge regardless of social rank or physical ability.',
  ),
  AsbabunNuzulEntry(
    surah: 93,
    ayahRange: '1–3',
    title: 'Penghiburan Allah pada Surah Adh-Dhuha',
    titleEn: 'Divine Consolation in Surah Ad-Duha',
    contextNarrative:
        'Ketika Rasulullah SAW sempat sakit sehingga tidak bangun malam selama dua atau tiga malam dan wahyu jeda turun sementara waktu, sebagian kaum musyrikin mengejek bahwa Tuhannya telah meninggalkannya. Maka Allah menurunkan Surah Adh-Dhuha: "Tuhanmu tidak meninggalkan engkau dan tidak pula membencimu."',
    contextNarrativeEn:
        'When the Prophet (peace be upon him) fell briefly ill and revelation paused for a few nights, some polytheists mocked that his Lord had forsaken him. Allah revealed Surah Ad-Duha: "Your Lord has not taken leave of you, nor has He detested you."',
    source: 'HR. Bukhari no. 4950 & Muslim no. 1797 (Dari Jundub bin Sufyan RA)',
    sourceEn: 'Sahih al-Bukhari 4950 & Sahih Muslim 1797 (Narrated by Jundub ibn Sufyan RA)',
    hikmah: 'Saat seorang hamba melewati masa sulit dan sunyi, kasih sayang serta pertolongan Allah tidak pernah meninggalkannya.',
    hikmahEn: 'Even through seasons of quiet hardship, Allah\'s love and care never abandon His faithful servant.',
  ),
  AsbabunNuzulEntry(
    surah: 108,
    ayahRange: '1–3',
    title: 'Anugerah Telaga Al-Kautsar',
    titleEn: 'The Gift of Abundance (Al-Kawthar)',
    contextNarrative:
        'Ketika putra Rasulullah SAW wafat saat masih kecil, Al-\'Ash bin Wa\'il menyebut beliau sebagai "abtar" (terputus keturunan dan sebutannya). Maka Allah menurunkan Surah Al-Kautsar yang menganugerahkan kebaikan melimpah di dunia-akhirat dan menegaskan bahwa pembenci beliaulah yang sebenarnya terputus.',
    contextNarrativeEn:
        'When the Prophet\'s young son passed away, Al-\'As ibn Wa\'il derided him as "abtar" (cut off with no legacy). Allah revealed Surah Al-Kawthar, bestowing abundant goodness in this life and the next and declaring that his detractor is the one truly cut off.',
    source: 'HR. Muslim no. 400 & Ibnu Jarir Ath-Thabari',
    sourceEn: 'Sahih Muslim 400 & Tafsir at-Tabari',
    hikmah: 'Membalas celaan dengan memperbanyak syukur, salat karena Allah, dan berkurban.',
    hikmahEn: 'Respond to mockery with deepened gratitude, devoted prayer, and charitable sacrifice for Allah.',
  ),
  AsbabunNuzulEntry(
    surah: 112,
    ayahRange: '1–4',
    title: 'Jawaban Tauhid Murni pada Surah Al-Ikhlas',
    titleEn: 'Pure Monotheism Answered in Surah Al-Ikhlas',
    contextNarrative:
        'Kaum musyrikin bertanya kepada Rasulullah SAW: "Wahai Muhammad, sebutkanlah nasab/sifat Tuhanmu kepada kami!" Maka Allah menurunkan Surah Al-Ikhlas: "Katakanlah, Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan..."',
    contextNarrativeEn:
        'The polytheists challenged the Prophet (peace be upon him), "Tell us the lineage and nature of your Lord!" Allah revealed Surah Al-Ikhlas: "Say, He is Allah, the One; Allah, the Eternal Refuge. He neither begets nor is born..."',
    source: 'HR. Tirmidzi no. 3364 & Ahmad V/133 (Dari Ubay bin Ka\'ab RA)',
    sourceEn: 'Jami\' at-Tirmidhi 3364 & Musnad Ahmad 5/133 (Narrated by Ubayy ibn Ka\'b RA)',
    hikmah: 'Surah Al-Ikhlas setara dengan sepertiga Al-Qur\'an karena merangkum pemurnian sifat-sifat Allah SWT.',
    hikmahEn: 'Surah Al-Ikhlas equals one-third of the Quran because it crystallizes pure monotheism and Allah\'s transcendent nature.',
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
  standard('Mushaf Standar', 'Standard Mushaf'),
  sepiaPaper('Kertas Sepia Hangat', 'Warm Sepia Paper'),
  amoledBlack('AMOLED Hitam Pekat', 'True Black AMOLED');

  final String label;
  final String labelEn;
  const TilawahSurfaceTheme(this.label, this.labelEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
}

// ================= 25. PINTASAN SURAH RUTIN & 15 AYAT SAJDAH =================

class RoutineQuranShortcut {
  final String id;
  final String title;
  final String? titleEn;
  final String timingAndVirtue;
  final String? timingAndVirtueEn;
  final int surah;
  final int? ayah;

  const RoutineQuranShortcut({
    required this.id,
    required this.title,
    this.titleEn,
    required this.timingAndVirtue,
    this.timingAndVirtueEn,
    required this.surah,
    this.ayah,
  });

  String titleFor(AppLanguage lang) =>
      lang == AppLanguage.en && (titleEn?.isNotEmpty ?? false) ? titleEn! : title;
  String timingAndVirtueFor(AppLanguage lang) =>
      lang == AppLanguage.en && (timingAndVirtueEn?.isNotEmpty ?? false)
          ? timingAndVirtueEn!
          : timingAndVirtue;
}

const List<RoutineQuranShortcut> routineQuranShortcuts = [
  RoutineQuranShortcut(
    id: 'al_kahfi',
    title: 'Surah Al-Kahfi',
    titleEn: 'Surah Al-Kahf',
    timingAndVirtue: 'Sunnah Malam & Hari Jumat · Cahaya di antara dua Jumat (HR. Al-Hakim)',
    timingAndVirtueEn: 'Friday & Thursday Night Sunnah · A light shining between two Fridays (Al-Hakim)',
    surah: 18,
  ),
  RoutineQuranShortcut(
    id: 'al_mulk',
    title: 'Surah Al-Mulk (Tabarak)',
    titleEn: 'Surah Al-Mulk (Tabarak)',
    timingAndVirtue: 'Sunnah Sebelum Tidur · Penyelamat dari siksa kubur (HR. Tirmidzi)',
    timingAndVirtueEn: 'Nightly Sunnah Before Sleep · Protector from the torment of the grave (Tirmidhi)',
    surah: 67,
  ),
  RoutineQuranShortcut(
    id: 'al_waqiah',
    title: 'Surah Al-Waqi\'ah',
    titleEn: 'Surah Al-Waqi\'ah',
    timingAndVirtue: 'Pengingat Hari Kiamat, Syukur & Tawakal Rezeki',
    timingAndVirtueEn: 'Reminder of the Day of Judgment, gratitude, and reliance on Allah for provision',
    surah: 56,
  ),
  RoutineQuranShortcut(
    id: 'yasin',
    title: 'Surah Yasin',
    titleEn: 'Surah Ya-Sin',
    timingAndVirtue: 'Peneguh Tauhid, Risalah & Kebangkitan Akhirat',
    timingAndVirtueEn: 'Affirms pure monotheism, prophethood, and the certainty of Resurrection',
    surah: 36,
  ),
  RoutineQuranShortcut(
    id: 'ar_rahman',
    title: 'Surah Ar-Rahman',
    titleEn: 'Surah Ar-Rahman',
    timingAndVirtue: 'Tadabbur Nikmat-Nikmat Allah yang Tak Terhitung',
    timingAndVirtueEn: 'Contemplation of Allah\'s countless mercies and favors',
    surah: 55,
  ),
  RoutineQuranShortcut(
    id: 'ayat_kursi',
    title: 'Ayat Kursi (QS. Al-Baqarah: 255)',
    titleEn: 'Ayat al-Kursi (Quran 2:255)',
    timingAndVirtue: 'Ayat paling agung dalam Al-Qur\'an; dibaca pagi, petang, ba\'da salat & sebelum tidur',
    timingAndVirtueEn: 'The greatest verse of the Quran; recited morning, evening, after prayers, and before sleep',
    surah: 2,
    ayah: 255,
  ),
  RoutineQuranShortcut(
    id: 'akhir_baqarah',
    title: '2 Ayat Terakhir Al-Baqarah (285–286)',
    titleEn: 'Last 2 Verses of Al-Baqarah (2:285-286)',
    timingAndVirtue: 'Barang siapa membacanya di malam hari, maka keduanya mencukupinya (HR. Bukhari & Muslim)',
    timingAndVirtueEn: 'Whoever recites them at night, they will suffice and protect them (Bukhari & Muslim)',
    surah: 2,
    ayah: 285,
  ),
];

class SajdahVerseInfo {
  final int number;
  final int surah;
  final int ayah;
  final String excerptMeaning;
  final String? excerptMeaningEn;

  const SajdahVerseInfo(
    this.number,
    this.surah,
    this.ayah,
    this.excerptMeaning, {
    this.excerptMeaningEn,
  });

  String excerptMeaningFor(AppLanguage lang) =>
      lang == AppLanguage.en && (excerptMeaningEn?.isNotEmpty ?? false)
          ? excerptMeaningEn!
          : excerptMeaning;
}

const List<SajdahVerseInfo> sajdahVersesCatalog = [
  SajdahVerseInfo(1, 7, 206, 'Malaikat di sisi Tuhan tidak merasa enggan menyembah Allah dan mereka bersujud kepada-Nya.', excerptMeaningEn: 'Those near your Lord are not too arrogant to worship Him, and to Him they prostrate.'),
  SajdahVerseInfo(2, 13, 15, 'Hanya kepada Allah bersujud segala apa yang di langit dan di bumi.', excerptMeaningEn: 'To Allah prostrates whoever is within the heavens and the earth.'),
  SajdahVerseInfo(3, 16, 50, 'Mereka takut kepada Tuhan mereka yang di atas mereka dan melaksanakan apa yang diperintahkan.', excerptMeaningEn: 'They fear their Lord above them, and they do what they are commanded.'),
  SajdahVerseInfo(4, 17, 109, 'Mereka menyungkur atas muka mereka sambil menangis dan mereka bertambah khusyuk.', excerptMeaningEn: 'They fall upon their faces weeping, and the Quran increases them in humility.'),
  SajdahVerseInfo(5, 19, 58, 'Apabila dibacakan ayat-ayat Allah Yang Maha Pemurah kepada mereka, mereka menyungkur bersujud.', excerptMeaningEn: 'When the verses of the Most Merciful were recited to them, they fell in prostration and weeping.'),
  SajdahVerseInfo(6, 22, 18, 'Apakah kamu tiada mengetahui bahwa kepada Allah bersujud apa yang ada di langit dan di bumi.', excerptMeaningEn: 'Do you not see that to Allah prostrates whoever is in the heavens and whoever is on the earth?'),
  SajdahVerseInfo(7, 22, 77, 'Wahai orang-orang yang beriman, ruku\'lah kamu, sujudlah kamu, dan sembahlah Tuhanmu.', excerptMeaningEn: 'O you who have believed, bow and prostrate and worship your Lord.'),
  SajdahVerseInfo(8, 25, 60, 'Dan apabila dikatakan kepada mereka: Sujudlah kamu sekalian kepada Yang Maha Penyayang.', excerptMeaningEn: 'And when it is said to them, "Prostrate to the Most Merciful..."'),
  SajdahVerseInfo(9, 27, 26, 'Allah, tiada Tuhan Yang disembah kecuali Dia, Tuhan Yang mempunyai \'Arsy yang agung.', excerptMeaningEn: 'Allah, there is no deity except Him, Lord of the Great Throne.'),
  SajdahVerseInfo(10, 32, 15, 'Sesungguhnya orang yang beriman kepada ayat-ayat Kami adalah mereka yang apabila diperingatkan, menyungkur sujud.', excerptMeaningEn: 'Only those believe in Our verses who, when reminded by them, fall down in prostration.'),
  SajdahVerseInfo(11, 38, 24, 'Dan Dawud mengetahui bahwa Kami mengujinya; maka ia meminta ampun kepada Tuhannya lalu menyungkur sujud.', excerptMeaningEn: 'David became certain that We had tried him, so he asked forgiveness of his Lord and fell down bowing.'),
  SajdahVerseInfo(12, 41, 38, 'Jika mereka menyombongkan diri, maka mereka yang di sisi Tuhanmu bertasbih kepada-Nya di malam dan siang hari.', excerptMeaningEn: 'Even if they are arrogant, those near your Lord exalt Him by night and day without wearying.'),
  SajdahVerseInfo(13, 53, 62, 'Maka bersujudlah kepada Allah dan sembahlah (Dia).', excerptMeaningEn: 'So prostrate to Allah and worship Him.'),
  SajdahVerseInfo(14, 84, 21, 'Dan apabila Al-Qur\'an dibacakan kepada mereka, mereka tidak bersujud.', excerptMeaningEn: 'And when the Quran is recited to them, they do not prostrate.'),
  SajdahVerseInfo(15, 96, 19, 'Sekali-kali jangan, janganlah kamu patuh kepadanya; dan sujudlah serta dekatkanlah dirimu kepada Tuhan.', excerptMeaningEn: 'No! Do not obey him; rather prostrate and draw near to Allah.'),
];
