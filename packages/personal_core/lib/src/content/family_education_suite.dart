import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';

// ================= 41. KATALOG NAMA BAYI ISLAMI + PERANGKAI NAMA =================

class IslamicBabyName {
  final String id;
  final String name;
  final String arabic;
  final String gender; // 'Laki-laki' | 'Perempuan'
  final String? genderEn;
  final String meaning;
  final String? meaningEn;
  final String theme;
  final String? themeEn;

  const IslamicBabyName({
    required this.id,
    required this.name,
    required this.arabic,
    required this.gender,
    this.genderEn,
    required this.meaning,
    this.meaningEn,
    required this.theme,
    this.themeEn,
  });

  String genderFor(AppLanguage lang) =>
      lang == AppLanguage.en && (genderEn?.isNotEmpty ?? false) ? genderEn! : gender;
  String meaningFor(AppLanguage lang) =>
      lang == AppLanguage.en && (meaningEn?.isNotEmpty ?? false) ? meaningEn! : meaning;
  String themeFor(AppLanguage lang) =>
      lang == AppLanguage.en && (themeEn?.isNotEmpty ?? false) ? themeEn! : theme;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        (meaningEn?.toLowerCase().contains(q) ?? false) ||
        theme.toLowerCase().contains(q) ||
        (themeEn?.toLowerCase().contains(q) ?? false) ||
        arabic.contains(q);
  }
}

const List<IslamicBabyName> islamicBabyNamesCatalog = [
  IslamicBabyName(id: 'muhammad', name: 'Muhammad', arabic: 'مُحَمَّد', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Yang sangat terpuji dan mulia akhlaknya', meaningEn: 'The deeply praiseworthy and noble in character', theme: 'Nabi & Rasul', themeEn: 'Prophets & Messengers'),
  IslamicBabyName(id: 'ahmad', name: 'Ahmad', arabic: 'أَحْمَد', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Yang paling banyak memuji Allah dan terpuji', meaningEn: 'Most commendable and foremost in praising Allah', theme: 'Nabi & Rasul', themeEn: 'Prophets & Messengers'),
  IslamicBabyName(id: 'ibrahim', name: 'Ibrahim', arabic: 'إِبْرَاهِيم', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Ayah yang penyayang dan teladan tauhid', meaningEn: 'Compassionate father and exemplar of pure monotheism', theme: 'Nabi & Rasul', themeEn: 'Prophets & Messengers'),
  IslamicBabyName(id: 'yusuf', name: 'Yusuf', arabic: 'يُوسُف', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Allah menambahkan kebaikan, ketampanan, dan kesabaran', meaningEn: 'Allah increases in goodness, grace, and patience', theme: 'Nabi & Rasul', themeEn: 'Prophets & Messengers'),
  IslamicBabyName(id: 'zayd', name: 'Zaidan', arabic: 'زَيْدَان', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Pertumbuhan dan kelebihan dalam ilmu serta kebaikan', meaningEn: 'Growth and abundance in knowledge and virtue', theme: 'Sahabat & Ulama', themeEn: 'Companions & Scholars'),
  IslamicBabyName(id: 'fatih', name: 'Al-Fatih', arabic: 'الفَاتِح', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Pembuka jalan kebaikan dan kemenangan', meaningEn: 'Opener of pathways to goodness and victory', theme: 'Kemuliaan & Ilmu', themeEn: 'Nobility & Knowledge'),
  IslamicBabyName(id: 'rayyan', name: 'Ar-Rayyan', arabic: 'الرَّيَّان', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Pintu surga khusus bagi ahli puasa yang segar dan penuh berkah', meaningEn: 'The gate of Paradise reserved for those who fast', theme: 'Al-Qur\'an', themeEn: 'Quranic'),
  IslamicBabyName(id: 'furqan', name: 'Furqan', arabic: 'فُرْقَان', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Pembeda yang tegas antara kebenaran dan kebatilan', meaningEn: 'Clear criterion distinguishing truth from falsehood', theme: 'Al-Qur\'an', themeEn: 'Quranic'),
  IslamicBabyName(id: 'haidar', name: 'Haidar', arabic: 'حَيْدَر', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Pemberani dalam membela kebenaran', meaningEn: 'Courageous lion in defending truth', theme: 'Sahabat & Ulama', themeEn: 'Companions & Scholars'),
  IslamicBabyName(id: 'aliim', name: 'Halim', arabic: 'حَلِيم', gender: 'Laki-laki', genderEn: 'Boy', meaning: 'Penyantun, sabar, dan berlapang dada', meaningEn: 'Gentle, forbearing, and open-hearted', theme: 'Akhlak & Cahaya', themeEn: 'Character & Light'),
  IslamicBabyName(id: 'aisyah', name: 'Aisyah', arabic: 'عَائِشَة', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Perempuan yang hidup bahagia, cerdas, dan berilmu luas', meaningEn: 'Woman of vibrant life, sharp intellect, and deep knowledge', theme: 'Sahabat & Ulama', themeEn: 'Companions & Scholars'),
  IslamicBabyName(id: 'khadijah', name: 'Khadijah', arabic: 'خَدِيجَة', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Perempuan mulia yang teguh, dermawan, dan dapat dipercaya', meaningEn: 'Noble woman of steadfastness, generosity, and trust', theme: 'Sahabat & Ulama', themeEn: 'Companions & Scholars'),
  IslamicBabyName(id: 'fathimah', name: 'Fathimah', arabic: 'فَاطِمَة', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Yang terjaga dari keburukan dan penuh kasih sayang', meaningEn: 'Sheltered from harm and filled with tender care', theme: 'Sahabat & Ulama', themeEn: 'Companions & Scholars'),
  IslamicBabyName(id: 'maryam', name: 'Maryam', arabic: 'مَرْيَم', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Wanita suci yang tekun beribadah dan mengabdi kepada Allah', meaningEn: 'Pure, devout woman dedicated to the worship of Allah', theme: 'Al-Qur\'an', themeEn: 'Quranic'),
  IslamicBabyName(id: 'zahra', name: 'Az-Zahra', arabic: 'الزَّهْرَاء', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Yang bercahaya terang dan berseri-seri', meaningEn: 'Radiant, luminous, and blooming with light', theme: 'Akhlak & Cahaya', themeEn: 'Character & Light'),
  IslamicBabyName(id: 'humaira', name: 'Humaira', arabic: 'حُمَيْرَاء', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Yang pipinya kemerahan, panggilan sayang Rasulullah kepada Aisyah RA', meaningEn: 'Rosy-cheeked, the affectionate nickname of the Prophet for Aisha (RA)', theme: 'Sahabat & Ulama', themeEn: 'Companions & Scholars'),
  IslamicBabyName(id: 'nadhira', name: 'Nadhira', arabic: 'نَاضِرَة', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Wajah yang berseri-seri penuh kebahagiaan (QS. Al-Qiyamah: 22)', meaningEn: 'Radiant face filled with joy (Quran 75:22)', theme: 'Al-Qur\'an', themeEn: 'Quranic'),
  IslamicBabyName(id: 'salma', name: 'Salma', arabic: 'سَلْمَى', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Yang selamat, damai, dan menenteramkan hati', meaningEn: 'Safe, serene, and calming to the heart', theme: 'Akhlak & Cahaya', themeEn: 'Character & Light'),
  IslamicBabyName(id: 'aliyah', name: 'Aliyah', arabic: 'عَالِيَة', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Perempuan yang tinggi derajat dan kemuliaannya', meaningEn: 'Exalted in dignity, grace, and noble rank', theme: 'Kemuliaan & Ilmu', themeEn: 'Nobility & Knowledge'),
  IslamicBabyName(id: 'syifa', name: 'Asy-Syifa', arabic: 'الشِّفَاء', gender: 'Perempuan', genderEn: 'Girl', meaning: 'Penawar dan penyembuh yang menenangkan jiwa', meaningEn: 'Healing remedy that brings peace to the soul', theme: 'Al-Qur\'an', themeEn: 'Quranic'),
];

({String fullLatin, String fullArabic, String combinedMeaning}) combineIslamicBabyNames(
  IslamicBabyName first,
  IslamicBabyName second, {
  AppLanguage lang = AppLanguage.id,
}) {
  final m1 = first.meaningFor(lang);
  final m2 = second.meaningFor(lang);
  final lowerSecond = m2.isEmpty ? m2 : m2[0].toLowerCase() + m2.substring(1);
  return (
    fullLatin: '${first.name} ${second.name}',
    fullArabic: '${first.arabic} ${second.arabic}',
    combinedMeaning: lang == AppLanguage.en ? '$m1, and $lowerSecond.' : '$m1, serta ${m2.toLowerCase()}.',
  );
}

class BabyNamesRepository {
  static const _favKey = 'baby_names_favorites';
  final KeyValueStore _store;

  const BabyNamesRepository(this._store);

  Future<Set<String>> favoriteIds() async {
    final raw = await _store.readJson(_favKey);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is String) x,
    };
  }

  Future<Set<String>> toggleFavorite(String id) async {
    final set = await favoriteIds();
    if (!set.remove(id)) set.add(id);
    await _store.writeJson(_favKey, set.toList());
    return set;
  }
}

// ================= 42. BELAJAR 29 HURUF HIJAIYAH & HARAKAT DASAR =================

class HijaiyahLetterItem {
  final int order;
  final String isolated;
  final String name;
  final String? nameEn;
  final String latinSound;
  final String? latinSoundEn;
  final String connectedForms; // Akhir - Tengah - Awal
  final String harakatSample; // Fathah - Kasrah - Dhammah
  final String makhrajNote;
  final String? makhrajNoteEn;

  const HijaiyahLetterItem(
    this.order,
    this.isolated,
    this.name,
    this.latinSound,
    this.connectedForms,
    this.harakatSample,
    this.makhrajNote, {
    this.nameEn,
    this.latinSoundEn,
    this.makhrajNoteEn,
  });

  String nameFor(AppLanguage lang) =>
      lang == AppLanguage.en && (nameEn?.isNotEmpty ?? false) ? nameEn! : name;
  String latinSoundFor(AppLanguage lang) =>
      lang == AppLanguage.en && (latinSoundEn?.isNotEmpty ?? false) ? latinSoundEn! : latinSound;
  String makhrajNoteFor(AppLanguage lang) =>
      lang == AppLanguage.en && (makhrajNoteEn?.isNotEmpty ?? false) ? makhrajNoteEn! : makhrajNote;
}

const List<HijaiyahLetterItem> hijaiyah29Catalog = [
  HijaiyahLetterItem(1, 'ا', 'Alif', 'a / i / u', 'ـا · ـا · ا', 'أَ (A) · إِ (I) · أُ (U)', 'Rongga mulut / pangkal tenggorokan (Hamzah)', makhrajNoteEn: 'Oral cavity / deepest throat (Hamzah)'),
  HijaiyahLetterItem(2, 'ب', 'Ba', 'b', 'ـب · ـبـ · بـ', 'بَ (Ba) · بِ (Bi) · بُ (Bu)', 'Merapatkan kedua bibir (Qalqalah saat sukun)', makhrajNoteEn: 'Closing both lips together (Qalqalah when sakin)'),
  HijaiyahLetterItem(3, 'ت', 'Ta', 't', 'ـت · ـتـ · تـ', 'تَ (Ta) · تِ (Ti) · تُ (Tu)', 'Ujung lidah bertemu pangkal gigi seri atas', makhrajNoteEn: 'Tip of the tongue against the base of the upper front teeth'),
  HijaiyahLetterItem(4, 'ث', 'Tsa', 'ts', 'ـث · ـثـ · ثـ', 'ثَ (Tsa) · ثِ (Tsi) · ثُ (Tsu)', 'Ujung lidah bertemu ujung gigi seri atas (tipis)', nameEn: 'Tha', latinSoundEn: 'th (as in think)', makhrajNoteEn: 'Tip of the tongue against the edges of the upper front teeth (light)'),
  HijaiyahLetterItem(5, 'ج', 'Jim', 'j', 'ـج · ـجـ · جـ', 'جَ (Ja) · جِ (Ji) · جُ (Ju)', 'Tengah lidah bertemu langit-langit atas (Qalqalah)', makhrajNoteEn: 'Middle of the tongue against the hard palate (Qalqalah)'),
  HijaiyahLetterItem(6, 'ح', 'Ha', 'h (bersih)', 'ـح · ـحـ · حـ', 'حَ (Ha) · حِ (Hi) · حُ (Hu)', 'Tengah tenggorokan (halus dan bersih)', latinSoundEn: 'h (crisp throat)', makhrajNoteEn: 'Middle of the throat (smooth and clear)'),
  HijaiyahLetterItem(7, 'خ', 'Kha', 'kh', 'ـخ · ـخـ · خـ', 'خَ (Kha) · خِ (Khi) · خُ (Khu)', 'Ujung tenggorokan dekat mulut', makhrajNoteEn: 'Upper throat nearest the mouth'),
  HijaiyahLetterItem(8, 'د', 'Dal', 'd', 'ـد · ـد · د', 'دَ (Da) · دِ (Di) · دُ (Du)', 'Ujung lidah ke pangkal gigi seri atas (Qalqalah)', makhrajNoteEn: 'Tip of the tongue at the base of the upper front teeth (Qalqalah)'),
  HijaiyahLetterItem(9, 'ذ', 'Dzal', 'dz', 'ـذ · ـذ · ذ', 'ذَ (Dza) · ذِ (Dzi) · ذُ (Dzu)', 'Ujung lidah bertemu ujung gigi seri atas', nameEn: 'Dhal', latinSoundEn: 'dh (as in this)', makhrajNoteEn: 'Tip of the tongue at the edges of the upper front teeth'),
  HijaiyahLetterItem(10, 'ر', 'Ra', 'r', 'ـر · ـر · ر', 'رَ (Ra) · رِ (Ri) · رُ (Ru)', 'Ujung lidah dekat gusi gigi seri atas', makhrajNoteEn: 'Tip of the tongue near the gums of the upper front teeth'),
  HijaiyahLetterItem(11, 'ز', 'Zai', 'z', 'ـز · ـز · ز', 'زَ (Za) · زِ (Zi) · زُ (Zu)', 'Ujung lidah dekat gigi seri bawah (berdesis)', nameEn: 'Zay', makhrajNoteEn: 'Tip of the tongue near the lower front teeth (sibilant buzz)'),
  HijaiyahLetterItem(12, 'س', 'Sin', 's', 'ـس · ـسـ · سـ', 'سَ (Sa) · سِ (Si) · سُ (Su)', 'Ujung lidah di antara gigi seri atas & bawah (tipis)', makhrajNoteEn: 'Tip of the tongue between upper and lower front teeth (light)'),
  HijaiyahLetterItem(13, 'ش', 'Syin', 'sy', 'ـش · ـشـ · شـ', 'شَ (Sya) · شِ (Syi) · شُ (Syu)', 'Tengah lidah dengan hembusan angin menyebar', nameEn: 'Shin', latinSoundEn: 'sh', makhrajNoteEn: 'Middle of the tongue with spreading airflow'),
  HijaiyahLetterItem(14, 'ص', 'Shad', 'sh (tebal)', 'ـص · ـصـ · صـ', 'صَ (Sha) · صِ (Shi) · صُ (Shu)', 'Ujung lidah disertai pangkal lidah terangkat (Isti\'la)', nameEn: 'Sad', latinSoundEn: 's (heavy)', makhrajNoteEn: 'Tip of the tongue with elevated back of the tongue (heavy/Isti\'la)'),
  HijaiyahLetterItem(15, 'ض', 'Dhad', 'dh', 'ـض · ـضـ · ضـ', 'ضَ (Dha) · ضِ (Dhi) · ضُ (Dhu)', 'Salah satu atau kedua tepi lidah bertemu gigi geraham atas', nameEn: 'Dad', latinSoundEn: 'd (heavy)', makhrajNoteEn: 'One or both sides of the tongue pressing against the upper molars'),
  HijaiyahLetterItem(16, 'ط', 'Tha', 'th (tebal)', 'ـط · ـطـ · طـ', 'طَ (Tha) · طِ (Thi) · طُ (Thu)', 'Ujung lidah ke pangkal gigi seri atas dengan tebal (Qalqalah)', nameEn: 'Ta (Heavy)', latinSoundEn: 't (heavy)', makhrajNoteEn: 'Tip of the tongue at the upper gum ridge with heaviness (Qalqalah)'),
  HijaiyahLetterItem(17, 'ظ', 'Zha', 'zh (tebal)', 'ـظ · ـظـ · ظـ', 'ظَ (Zha) · ظِ (Zhi) · ظُ (Zhu)', 'Ujung lidah ke ujung gigi seri atas dengan tebal', nameEn: 'Za (Heavy)', latinSoundEn: 'dh (heavy)', makhrajNoteEn: 'Tip of the tongue at the edges of the upper front teeth with heaviness'),
  HijaiyahLetterItem(18, 'ع', '\'Ain', '\'', 'ـع · ـعـ · عـ', 'عَ (\'A) · عِ (\'I) · عُ (\'U)', 'Tengah tenggorokan', nameEn: '\'Ayn', makhrajNoteEn: 'Middle of the throat'),
  HijaiyahLetterItem(19, 'غ', 'Ghain', 'gh', 'ـغ · ـغـ · غـ', 'غَ (Gha) · غِ (Ghi) · غُ (Ghu)', 'Ujung tenggorokan dekat mulut', nameEn: 'Ghayn', makhrajNoteEn: 'Upper throat nearest the mouth'),
  HijaiyahLetterItem(20, 'ف', 'Fa', 'f', 'ـف · ـفـ · فـ', 'فَ (Fa) · فِ (Fi) · فُ (Fu)', 'Perut bibir bawah bertemu ujung gigi seri atas', makhrajNoteEn: 'Inner lower lip meeting the edges of the upper front teeth'),
  HijaiyahLetterItem(21, 'ق', 'Qaf', 'q', 'ـق · ـقـ · قـ', 'قَ (Qa) · قِ (Qi) · قُ (Qu)', 'Pangkal lidah dekat anak tekak (Qalqalah)', makhrajNoteEn: 'Back of the tongue against the soft palate near the uvula (Qalqalah)'),
  HijaiyahLetterItem(22, 'ك', 'Kaf', 'k', 'ـك · ـكـ · كـ', 'كَ (Ka) · كِ (Ki) · كُ (Ku)', 'Pangkal lidah sedikit di depan Qaf', makhrajNoteEn: 'Back of the tongue slightly forward of Qaf'),
  HijaiyahLetterItem(23, 'ل', 'Lam', 'l', 'ـل · ـلـ · لـ', 'لَ (La) · لِ (Li) · لُ (Lu)', 'Ujung tepi lidah bertemu gusi gigi depan atas', makhrajNoteEn: 'Front edge of the tongue touching the gums of the upper front teeth'),
  HijaiyahLetterItem(24, 'م', 'Mim', 'm', 'ـم · ـمـ · مـ', 'مَ (Ma) · مِ (Mi) · مُ (Mu)', 'Merapatkan kedua bibir disertai sifat ghunnah', makhrajNoteEn: 'Closing both lips with natural nasal resonance (ghunnah)'),
  HijaiyahLetterItem(25, 'ن', 'Nun', 'n', 'ـن · ـنـ · نـ', 'نَ (Na) · نِ (Ni) · نُ (Nu)', 'Ujung lidah bertemu gusi atas disertai ghunnah', makhrajNoteEn: 'Tip of the tongue against the upper gums with nasal resonance'),
  HijaiyahLetterItem(26, 'و', 'Wawu', 'w', 'ـو · ـو · و', 'وَ (Wa) · وِ (Wi) · وُ (Wu)', 'Membulatkan kedua bibir ke depan', nameEn: 'Waw', makhrajNoteEn: 'Rounding both lips forward'),
  HijaiyahLetterItem(27, 'هـ', 'Ha Besar', 'h (dalam)', 'ـه · ـهـ · هـ', 'هَ (Ha) · هِ (Hi) · هُ (Hu)', 'Pangkal tenggorokan terdalam', nameEn: 'Ha (Deep)', latinSoundEn: 'h (deep)', makhrajNoteEn: 'Deepest part of the throat'),
  HijaiyahLetterItem(28, 'ء', 'Hamzah', '\' (hamzah)', 'ء · أ · إ · ؤ · ئ', 'أَ (A) · إِ (I) · أُ (U)', 'Pangkal tenggorokan terdalam', latinSoundEn: '\' (glottal stop)', makhrajNoteEn: 'Deepest part of the throat'),
  HijaiyahLetterItem(29, 'ي', 'Ya', 'y', 'ـي · ـيـ · يـ', 'يَ (Ya) · يِ (Yi) · يُ (Yu)', 'Tengah lidah bertemu langit-langit atas', makhrajNoteEn: 'Middle of the tongue raised toward the hard palate'),
];

// ================= 43. KUIS WAWASAN ISLAM HARIAN (OFFLINE) =================

class IslamicKnowledgeQuestion {
  final int id;
  final String category;
  final String? categoryEn;
  final String question;
  final String? questionEn;
  final List<String> options;
  final List<String>? optionsEn;
  final int correctIndex;
  final String explanation;
  final String? explanationEn;

  const IslamicKnowledgeQuestion({
    required this.id,
    required this.category,
    this.categoryEn,
    required this.question,
    this.questionEn,
    required this.options,
    this.optionsEn,
    required this.correctIndex,
    required this.explanation,
    this.explanationEn,
  });

  String categoryFor(AppLanguage lang) =>
      lang == AppLanguage.en && (categoryEn?.isNotEmpty ?? false) ? categoryEn! : category;
  String questionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (questionEn?.isNotEmpty ?? false) ? questionEn! : question;
  List<String> optionsFor(AppLanguage lang) =>
      lang == AppLanguage.en && (optionsEn?.isNotEmpty ?? false) ? optionsEn! : options;
  String explanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (explanationEn?.isNotEmpty ?? false) ? explanationEn! : explanation;
}

const List<IslamicKnowledgeQuestion> islamicKnowledgeQuizBank = [
  IslamicKnowledgeQuestion(
    id: 1,
    category: 'Al-Qur\'an',
    categoryEn: 'Al-Quran',
    question: 'Surah apakah dalam Al-Qur\'an yang tidak diawali dengan lafaz Basmalah?',
    questionEn: 'Which surah in the Quran does not begin with the Basmalah?',
    options: ['Surah Al-Anfal', 'Surah At-Taubah', 'Surah Al-Kahfi', 'Surah Yasin'],
    optionsEn: ['Surah Al-Anfal', 'Surah At-Tawbah', 'Surah Al-Kahf', 'Surah Ya-Sin'],
    correctIndex: 1,
    explanation: 'Surah At-Taubah (Surah ke-9) adalah satu-satunya surah dalam mushaf yang tidak diawali dengan Basmalah.',
    explanationEn: 'Surah At-Tawbah (Surah 9) is the only surah in the Quran that does not open with the Basmalah.',
  ),
  IslamicKnowledgeQuestion(
    id: 2,
    category: 'Sirah Nabawiyah',
    categoryEn: 'Prophetic Biography',
    question: 'Masjid pertama yang dibangun oleh Rasulullah SAW ketika tiba dalam perjalanan Hijrah adalah...',
    questionEn: 'What was the first mosque built by the Prophet (peace be upon him) during the Hijrah?',
    options: ['Masjidil Haram', 'Masjid Quba', 'Masjid Nabawi', 'Masjid Qiblatain'],
    optionsEn: ['Al-Masjid al-Haram', 'Quba Mosque', 'The Prophet\'s Mosque', 'Masjid al-Qiblatayn'],
    correctIndex: 1,
    explanation: 'Masjid Quba didirikan saat Rasulullah SAW singgah di Quba sebelum memasuki pusat kota Madinah (QS. At-Taubah: 108).',
    explanationEn: 'Quba Mosque was built when the Prophet (peace be upon him) stayed at Quba on the outskirts of Madinah (Quran 9:108).',
  ),
  IslamicKnowledgeQuestion(
    id: 3,
    category: 'Fiqih Ibadah',
    categoryEn: 'Worship Fiqh',
    question: 'Berapakah batas nisab Zakat Maal untuk simpanan emas yang telah mencapai haul 1 tahun Hijriah?',
    questionEn: 'What is the Nisab threshold for Zakat on gold savings held for one full Hijri year (Hawl)?',
    options: ['50 gram emas', '85 gram emas', '100 gram emas', '200 gram emas'],
    optionsEn: ['50 grams of gold', '85 grams of gold', '100 grams of gold', '200 grams of gold'],
    correctIndex: 1,
    explanation: 'Nisab zakat emas adalah 20 dinar atau setara 85 gram emas murni dengan kadar zakat 2,5%.',
    explanationEn: 'The Nisab for gold is 20 dinars, equivalent to 85 grams of pure gold, with a Zakat rate of 2.5%.',
  ),
  IslamicKnowledgeQuestion(
    id: 4,
    category: 'Hadits & Sunnah',
    categoryEn: 'Hadith & Sunnah',
    question: 'Berapa jumlah total rakaat Salat Sunnah Rawatib Muakkadah yang dijanjikan rumah di surga dalam HR. Muslim no. 728?',
    questionEn: 'How many daily confirmed Rawatib Sunnah rak\'ah carry the promise of a house in Paradise (Sahih Muslim 728)?',
    options: ['8 rakaat', '10 rakaat', '12 rakaat', '14 rakaat'],
    optionsEn: ['8 rak\'ah', '10 rak\'ah', '12 rak\'ah', '14 rak\'ah'],
    correctIndex: 2,
    explanation: '12 rakaat Rawatib: 2 sebelum Subuh, 4 sebelum Dzuhur, 2 sesudah Dzuhur, 2 sesudah Maghrib, dan 2 sesudah Isya.',
    explanationEn: '12 Rawatib rak\'ah: 2 before Fajr, 4 before Dhuhr, 2 after Dhuhr, 2 after Maghrib, and 2 after Isha.',
  ),
  IslamicKnowledgeQuestion(
    id: 5,
    category: 'Al-Qur\'an',
    categoryEn: 'Al-Quran',
    question: 'Ayat paling agung dalam Al-Qur\'an (Ayat Kursi) terdapat pada Surah dan ayat ke berapa?',
    questionEn: 'Which surah and verse is the greatest verse in the Quran (Ayat al-Kursi)?',
    options: ['QS. Al-Baqarah: 185', 'QS. Al-Baqarah: 255', 'QS. Al-Baqarah: 286', 'QS. Ali \'Imran: 18'],
    optionsEn: ['Quran 2:185 (Al-Baqarah)', 'Quran 2:255 (Al-Baqarah)', 'Quran 2:286 (Al-Baqarah)', 'Quran 3:18 (Ali \'Imran)'],
    correctIndex: 1,
    explanation: 'Ayat Kursi adalah QS. Al-Baqarah ayat 255 yang menegaskan kemahahidupan dan kepengurusan mutlak Allah SWT.',
    explanationEn: 'Ayat al-Kursi is Surah Al-Baqarah verse 255, proclaiming Allah\'s eternal life and absolute sovereignty.',
  ),
];

// ================= 44. GLOSARIUM / ENSIKLOPEDIA MINI ISTILAH ISLAM =================

class IslamicGlossaryTerm {
  final String term;
  final String category;
  final String? categoryEn;
  final String definition;
  final String? definitionEn;

  const IslamicGlossaryTerm(
    this.term,
    this.category,
    this.definition, {
    this.categoryEn,
    this.definitionEn,
  });

  String categoryFor(AppLanguage lang) =>
      lang == AppLanguage.en && (categoryEn?.isNotEmpty ?? false) ? categoryEn! : category;
  String definitionFor(AppLanguage lang) =>
      lang == AppLanguage.en && (definitionEn?.isNotEmpty ?? false) ? definitionEn! : definition;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return term.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        (categoryEn?.toLowerCase().contains(q) ?? false) ||
        definition.toLowerCase().contains(q) ||
        (definitionEn?.toLowerCase().contains(q) ?? false);
  }
}

const List<IslamicGlossaryTerm> islamicGlossaryCatalog = [
  IslamicGlossaryTerm('Tuma\'ninah', 'Fiqih Salat', 'Tenang dan diam sejenak setelah seluruh anggota tubuh berada sempurna pada posisi rukun salat (seperti ruku\', i\'tidal, dan sujud).', categoryEn: 'Prayer Fiqh', definitionEn: 'Pausing calmly in stillness once the limbs settle into each pillar of prayer (such as bowing, rising, and prostrating).'),
  IslamicGlossaryTerm('Sujud Sahwi', 'Fiqih Salat', 'Dua sujud di akhir salat (sebelum atau sesudah salam) untuk menambal kelupaan jumlah rakaat atau tertinggalnya sunnah ab\'adh.', categoryEn: 'Prayer Fiqh', definitionEn: 'Two prostrations of forgetfulness at the end of prayer (before or after the salam) to mend an unintentional omission or addition.'),
  IslamicGlossaryTerm('Sujud Tilawah', 'Fiqih Al-Qur\'an', 'Satu kali sujud yang disunnahkan ketika membaca atau mendengar salah satu dari 15 Ayat Sajdah dalam Al-Qur\'an.', categoryEn: 'Quran Fiqh', definitionEn: 'A single recommended prostration performed upon reciting or hearing one of the 15 verses of prostration in the Quran.'),
  IslamicGlossaryTerm('Nisab & Haul', 'Zakat & Muamalah', 'Nisab adalah batas minimal harta yang wajib dizakati; Haul adalah berlalunya masa kepemilikan selama 1 tahun penuh kalender Hijriah (354 hari).', categoryEn: 'Zakat & Finance', definitionEn: 'Nisab is the minimum wealth threshold for Zakat; Hawl is the passage of one full lunar Hijri year (354 days) of ownership.'),
  IslamicGlossaryTerm('Masafatul Qashr', 'Fiqih Safar', 'Batas jarak minimal perjalanan safar (±81–89 km / 2 Marhalah) yang memperbolehkan keringanan meringkas (Qashar) dan menjama\' salat.', categoryEn: 'Travel Fiqh', definitionEn: 'The minimum travel distance (about 81 to 89 km / 2 Marhalah) that permits shortening (Qasr) and combining (Jam\') prayers.'),
  IslamicGlossaryTerm('Ashabul Furudh & Ashabah', 'Faraid (Waris)', 'Ashabul Furudh adalah ahli waris yang bagiannya ditentukan pasti dalam Al-Qur\'an (1/2, 1/4, 1/8, 2/3, 1/3, 1/6); Ashabah adalah ahli waris yang menerima sisa harta.', categoryEn: 'Inheritance (Faraid)', definitionEn: 'Ashab al-Furud receive fixed Quranic shares (1/2, 1/4, 1/8, 2/3, 1/3, 1/6); \'Asabah are residuary heirs who receive the remainder.'),
  IslamicGlossaryTerm('\'Aul & Radd', 'Faraid (Waris)', '\'Aul adalah menaikkan penyebut ketika total bagian ahli waris melebihi 100%; Radd adalah mengembalikan sisa harta secara proporsional kepada ahli waris nasab saat tidak ada Ashabah.', categoryEn: 'Inheritance (Faraid)', definitionEn: '\'Awl increases the common denominator when fixed shares exceed 100%; Radd returns surplus estate proportionally to bloodline fixed heirs when no residuary heir exists.'),
  IslamicGlossaryTerm('Gharar & Riba', 'Muamalah', 'Gharar adalah ketidakpastian/spekulasi terlarang dalam akad jual beli; Riba adalah tambahan yang disyaratkan atas pokok utang atau pertukaran barang ribawi yang tidak setara.', categoryEn: 'Islamic Finance', definitionEn: 'Gharar is excessive uncertainty or speculation in contracts; Riba is stipulated interest on loans or unequal exchange of usurious commodities.'),
  IslamicGlossaryTerm('Mahram', 'Keluarga', 'Kerabat dekat (karena nasab, persusuan, atau pernikahan) yang haram dinikahi selamanya dan diperbolehkan melakukan safar bersama.', categoryEn: 'Family', definitionEn: 'A close relative (by blood, nursing, or marriage) whom one is permanently forbidden to marry and may travel with.'),
  IslamicGlossaryTerm('Tabayyun', 'Akhlak', 'Meneliti dan memverifikasi kebenaran suatu berita sebelum menyebarkan atau mengambil sikap (QS. Al-Hujurat: 6).', categoryEn: 'Ethics & Character', definitionEn: 'Carefully verifying the accuracy of news before spreading it or acting upon it (Quran 49:6).'),
  IslamicGlossaryTerm('Ihsan & Muraqabah', 'Aqidah & Akhlak', 'Beribadah kepada Allah seolah-olah melihat-Nya, dan menyadari penuh bahwa Allah senantiasa mengawasi setiap gerak-gerik hamba.', categoryEn: 'Creed & Spirituality', definitionEn: 'Worshiping Allah as though you see Him, with deep awareness that He continually watches over every action.'),
  IslamicGlossaryTerm('Istidraj', 'Aqidah', 'Limpahan kesenangan duniawi yang diberikan kepada pelaku maksiat yang terus berpaling dari Allah sebagai bentuk ujian yang melalaikan.', categoryEn: 'Creed', definitionEn: 'Ongoing worldly ease granted to one who persists in disobedience, serving as a gradual test that deepens heedlessness.'),
];

// ================= 45. PENCATAT UTANG-PIUTANG PRIBADI (QS. AL-BAQARAH: 282) =================

enum DebtRecordKind {
  utangSaya('Utang Saya (Wajib Dibayar)', 'My Debt (Owed by Me)'),
  piutangSaya('Piutang Saya (Dipinjam Orang)', 'My Receivable (Owed to Me)');

  final String label;
  final String labelEn;
  const DebtRecordKind(this.label, this.labelEn);

  String labelFor(AppLanguage lang) => lang == AppLanguage.en ? labelEn : label;
}

class DebtLedgerEntry {
  final String id;
  final DebtRecordKind kind;
  final String personName;
  final int totalAmount;
  final int paidAmount;
  final String dueDateKey;
  final String note;

  const DebtLedgerEntry({
    required this.id,
    required this.kind,
    required this.personName,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.dueDateKey,
    this.note = '',
  });

  int get remainingAmount => (totalAmount - paidAmount).clamp(0, 1000000000);
  bool get isPaidOff => remainingAmount == 0;

  DebtLedgerEntry copyWith({int? paidAmount}) => DebtLedgerEntry(
        id: id,
        kind: kind,
        personName: personName,
        totalAmount: totalAmount,
        paidAmount: (paidAmount ?? this.paidAmount).clamp(0, totalAmount),
        dueDateKey: dueDateKey,
        note: note,
      );

  Map<String, Object> toJson() => {
        'id': id,
        'kind': kind.name,
        'personName': personName,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'dueDateKey': dueDateKey,
        'note': note,
      };

  factory DebtLedgerEntry.fromJson(Map<String, dynamic> j) {
    final kName = j['kind'] as String?;
    final kind = DebtRecordKind.values.where((e) => e.name == kName).firstOrNull ?? DebtRecordKind.utangSaya;
    return DebtLedgerEntry(
      id: j['id'] as String? ?? 'd',
      kind: kind,
      personName: j['personName'] as String? ?? '',
      totalAmount: ((j['totalAmount'] as num?)?.toInt() ?? 0).clamp(0, 1000000000),
      paidAmount: ((j['paidAmount'] as num?)?.toInt() ?? 0).clamp(0, 1000000000),
      dueDateKey: j['dueDateKey'] as String? ?? '',
      note: j['note'] as String? ?? '',
    );
  }
}

class DebtLedgerRepository {
  static const _key = 'debt_ledger_entries';
  final KeyValueStore _store;

  const DebtLedgerRepository(this._store);

  Future<List<DebtLedgerEntry>> allEntries() async {
    final raw = await _store.readJson(_key);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) DebtLedgerEntry.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<List<DebtLedgerEntry>> addEntry({
    required DebtRecordKind kind,
    required String personName,
    required int totalAmount,
    required DateTime dueDate,
    String note = '',
  }) async {
    final list = (await allEntries()).toList();
    list.insert(
      0,
      DebtLedgerEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        kind: kind,
        personName: personName.trim(),
        totalAmount: totalAmount.clamp(0, 1000000000),
        dueDateKey: TrackerRepository.dayKey(dueDate),
        note: note.trim(),
      ),
    );
    await _store.writeJson(_key, [for (final i in list) i.toJson()]);
    return list;
  }

  Future<List<DebtLedgerEntry>> markPaidOff(String id) async {
    final list = [
      for (final i in await allEntries()) i.id == id ? i.copyWith(paidAmount: i.totalAmount) : i,
    ];
    await _store.writeJson(_key, [for (final i in list) i.toJson()]);
    return list;
  }

  Future<List<DebtLedgerEntry>> deleteEntry(String id) async {
    final list = (await allEntries()).where((i) => i.id != id).toList();
    await _store.writeJson(_key, [for (final i in list) i.toJson()]);
    return list;
  }
}
