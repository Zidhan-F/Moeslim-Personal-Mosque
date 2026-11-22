import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';

// ================= 41. KATALOG NAMA BAYI ISLAMI + PERANGKAI NAMA =================

class IslamicBabyName {
  final String id;
  final String name;
  final String arabic;
  final String gender; // 'Laki-laki' | 'Perempuan'
  final String meaning;
  final String theme;

  const IslamicBabyName({
    required this.id,
    required this.name,
    required this.arabic,
    required this.gender,
    required this.meaning,
    required this.theme,
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        theme.toLowerCase().contains(q) ||
        arabic.contains(q);
  }
}

const List<IslamicBabyName> islamicBabyNamesCatalog = [
  IslamicBabyName(id: 'muhammad', name: 'Muhammad', arabic: 'مُحَمَّد', gender: 'Laki-laki', meaning: 'Yang sangat terpuji dan mulia akhlaknya', theme: 'Nabi & Rasul'),
  IslamicBabyName(id: 'ahmad', name: 'Ahmad', arabic: 'أَحْمَد', gender: 'Laki-laki', meaning: 'Yang paling banyak memuji Allah dan terpuji', theme: 'Nabi & Rasul'),
  IslamicBabyName(id: 'ibrahim', name: 'Ibrahim', arabic: 'إِبْرَاهِيم', gender: 'Laki-laki', meaning: 'Ayah yang penyayang dan teladan tauhid', theme: 'Nabi & Rasul'),
  IslamicBabyName(id: 'yusuf', name: 'Yusuf', arabic: 'يُوسُف', gender: 'Laki-laki', meaning: 'Allah menambahkan kebaikan, ketampanan, dan kesabaran', theme: 'Nabi & Rasul'),
  IslamicBabyName(id: 'zayd', name: 'Zaidan', arabic: 'زَيْدَان', gender: 'Laki-laki', meaning: 'Pertumbuhan dan kelebihan dalam ilmu serta kebaikan', theme: 'Sahabat & Ulama'),
  IslamicBabyName(id: 'fatih', name: 'Al-Fatih', arabic: 'الفَاتِح', gender: 'Laki-laki', meaning: 'Pembuka jalan kebaikan dan kemenangan', theme: 'Kemuliaan & Ilmu'),
  IslamicBabyName(id: 'rayyan', name: 'Ar-Rayyan', arabic: 'الرَّيَّان', gender: 'Laki-laki', meaning: 'Pintu surga khusus bagi ahli puasa yang segar dan penuh berkah', theme: 'Al-Qur\'an'),
  IslamicBabyName(id: 'furqan', name: 'Furqan', arabic: 'فُرْقَان', gender: 'Laki-laki', meaning: 'Pembeda yang tegas antara kebenaran dan kebatilan', theme: 'Al-Qur\'an'),
  IslamicBabyName(id: 'haidar', name: 'Haidar', arabic: 'حَيْدَر', gender: 'Laki-laki', meaning: 'Pemberani dalam membela kebenaran', theme: 'Sahabat & Ulama'),
  IslamicBabyName(id: 'aliim', name: 'Halim', arabic: 'حَلِيم', gender: 'Laki-laki', meaning: 'Penyantun, sabar, dan berlapang dada', theme: 'Akhlak & Cahaya'),
  IslamicBabyName(id: 'aisyah', name: 'Aisyah', arabic: 'عَائِشَة', gender: 'Perempuan', meaning: 'Perempuan yang hidup bahagia, cerdas, dan berilmu luas', theme: 'Sahabat & Ulama'),
  IslamicBabyName(id: 'khadijah', name: 'Khadijah', arabic: 'خَدِيجَة', gender: 'Perempuan', meaning: 'Perempuan mulia yang teguh, dermawan, dan dapat dipercaya', theme: 'Sahabat & Ulama'),
  IslamicBabyName(id: 'fathimah', name: 'Fathimah', arabic: 'فَاطِمَة', gender: 'Perempuan', meaning: 'Yang terjaga dari keburukan dan penuh kasih sayang', theme: 'Sahabat & Ulama'),
  IslamicBabyName(id: 'maryam', name: 'Maryam', arabic: 'مَرْيَم', gender: 'Perempuan', meaning: 'Wanita suci yang tekun beribadah dan mengabdi kepada Allah', theme: 'Al-Qur\'an'),
  IslamicBabyName(id: 'zahra', name: 'Az-Zahra', arabic: 'الزَّهْرَاء', gender: 'Perempuan', meaning: 'Yang bercahaya terang dan berseri-seri', theme: 'Akhlak & Cahaya'),
  IslamicBabyName(id: 'humaira', name: 'Humaira', arabic: 'حُمَيْرَاء', gender: 'Perempuan', meaning: 'Yang pipinya kemerahan, panggilan sayang Rasulullah kepada Aisyah RA', theme: 'Sahabat & Ulama'),
  IslamicBabyName(id: 'nadhira', name: 'Nadhira', arabic: 'نَاضِرَة', gender: 'Perempuan', meaning: 'Wajah yang berseri-seri penuh kebahagiaan (QS. Al-Qiyamah: 22)', theme: 'Al-Qur\'an'),
  IslamicBabyName(id: 'salma', name: 'Salma', arabic: 'سَلْمَى', gender: 'Perempuan', meaning: 'Yang selamat, damai, dan menenteramkan hati', theme: 'Akhlak & Cahaya'),
  IslamicBabyName(id: 'aliyah', name: 'Aliyah', arabic: 'عَالِيَة', gender: 'Perempuan', meaning: 'Perempuan yang tinggi derajat dan kemuliaannya', theme: 'Kemuliaan & Ilmu'),
  IslamicBabyName(id: 'syifa', name: 'Asy-Syifa', arabic: 'الشِّفَاء', gender: 'Perempuan', meaning: 'Penawar dan penyembuh yang menenangkan jiwa', theme: 'Al-Qur\'an'),
];

({String fullLatin, String fullArabic, String combinedMeaning}) combineIslamicBabyNames(
  IslamicBabyName first,
  IslamicBabyName second,
) {
  return (
    fullLatin: '${first.name} ${second.name}',
    fullArabic: '${first.arabic} ${second.arabic}',
    combinedMeaning: '${first.meaning}, serta ${second.meaning.toLowerCase()}.',
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
  final String latinSound;
  final String connectedForms; // Akhir - Tengah - Awal
  final String harakatSample; // Fathah - Kasrah - Dhammah
  final String makhrajNote;

  const HijaiyahLetterItem(
    this.order,
    this.isolated,
    this.name,
    this.latinSound,
    this.connectedForms,
    this.harakatSample,
    this.makhrajNote,
  );
}

const List<HijaiyahLetterItem> hijaiyah29Catalog = [
  HijaiyahLetterItem(1, 'ا', 'Alif', 'a / i / u', 'ـا · ـا · ا', 'أَ (A) · إِ (I) · أُ (U)', 'Rongga mulut / pangkal tenggorokan (Hamzah)'),
  HijaiyahLetterItem(2, 'ب', 'Ba', 'b', 'ـب · ـبـ · بـ', 'بَ (Ba) · بِ (Bi) · بُ (Bu)', 'Merapatkan kedua bibir (Qalqalah saat sukun)'),
  HijaiyahLetterItem(3, 'ت', 'Ta', 't', 'ـت · ـتـ · تـ', 'تَ (Ta) · تِ (Ti) · تُ (Tu)', 'Ujung lidah bertemu pangkal gigi seri atas'),
  HijaiyahLetterItem(4, 'ث', 'Tsa', 'ts', 'ـث · ـثـ · ثـ', 'ثَ (Tsa) · ثِ (Tsi) · ثُ (Tsu)', 'Ujung lidah bertemu ujung gigi seri atas (tipis)'),
  HijaiyahLetterItem(5, 'ج', 'Jim', 'j', 'ـج · ـجـ · جـ', 'جَ (Ja) · جِ (Ji) · جُ (Ju)', 'Tengah lidah bertemu langit-langit atas (Qalqalah)'),
  HijaiyahLetterItem(6, 'ح', 'Ha', 'h (bersih)', 'ـح · ـحـ · حـ', 'حَ (Ha) · حِ (Hi) · حُ (Hu)', 'Tengah tenggorokan (halus dan bersih)'),
  HijaiyahLetterItem(7, 'خ', 'Kha', 'kh', 'ـخ · ـخـ · خـ', 'خَ (Kha) · خِ (Khi) · خُ (Khu)', 'Ujung tenggorokan dekat mulut'),
  HijaiyahLetterItem(8, 'د', 'Dal', 'd', 'ـد · ـد · د', 'دَ (Da) · دِ (Di) · دُ (Du)', 'Ujung lidah ke pangkal gigi seri atas (Qalqalah)'),
  HijaiyahLetterItem(9, 'ذ', 'Dzal', 'dz', 'ـذ · ـذ · ذ', 'ذَ (Dza) · ذِ (Dzi) · ذُ (Dzu)', 'Ujung lidah bertemu ujung gigi seri atas'),
  HijaiyahLetterItem(10, 'ر', 'Ra', 'r', 'ـر · ـر · ر', 'رَ (Ra) · رِ (Ri) · رُ (Ru)', 'Ujung lidah dekat gusi gigi seri atas'),
  HijaiyahLetterItem(11, 'ز', 'Zai', 'z', 'ـز · ـز · ز', 'زَ (Za) · زِ (Zi) · زُ (Zu)', 'Ujung lidah dekat gigi seri bawah (berdesis)'),
  HijaiyahLetterItem(12, 'س', 'Sin', 's', 'ـس · ـسـ · سـ', 'سَ (Sa) · سِ (Si) · سُ (Su)', 'Ujung lidah di antara gigi seri atas & bawah (tipis)'),
  HijaiyahLetterItem(13, 'ش', 'Syin', 'sy', 'ـش · ـشـ · شـ', 'شَ (Sya) · شِ (Syi) · شُ (Syu)', 'Tengah lidah dengan hembusan angin menyebar'),
  HijaiyahLetterItem(14, 'ص', 'Shad', 'sh (tebal)', 'ـص · ـصـ · صـ', 'صَ (Sha) · صِ (Shi) · صُ (Shu)', 'Ujung lidah disertai pangkal lidah terangkat (Isti\'la)'),
  HijaiyahLetterItem(15, 'ض', 'Dhad', 'dh', 'ـض · ـضـ · ضـ', 'ضَ (Dha) · ضِ (Dhi) · ضُ (Dhu)', 'Salah satu atau kedua tepi lidah bertemu gigi geraham atas'),
  HijaiyahLetterItem(16, 'ط', 'Tha', 'th (tebal)', 'ـط · ـطـ · طـ', 'طَ (Tha) · طِ (Thi) · طُ (Thu)', 'Ujung lidah ke pangkal gigi seri atas dengan tebal (Qalqalah)'),
  HijaiyahLetterItem(17, 'ظ', 'Zha', 'zh (tebal)', 'ـظ · ـظـ · ظـ', 'ظَ (Zha) · ظِ (Zhi) · ظُ (Zhu)', 'Ujung lidah ke ujung gigi seri atas dengan tebal'),
  HijaiyahLetterItem(18, 'ع', '\'Ain', '\'', 'ـع · ـعـ · عـ', 'عَ (\'A) · عِ (\'I) · عُ (\'U)', 'Tengah tenggorokan'),
  HijaiyahLetterItem(19, 'غ', 'Ghain', 'gh', 'ـغ · ـغـ · غـ', 'غَ (Gha) · غِ (Ghi) · غُ (Ghu)', 'Ujung tenggorokan dekat mulut'),
  HijaiyahLetterItem(20, 'ف', 'Fa', 'f', 'ـف · ـفـ · فـ', 'فَ (Fa) · فِ (Fi) · فُ (Fu)', 'Perut bibir bawah bertemu ujung gigi seri atas'),
  HijaiyahLetterItem(21, 'ق', 'Qaf', 'q', 'ـق · ـقـ · قـ', 'قَ (Qa) · قِ (Qi) · قُ (Qu)', 'Pangkal lidah dekat anak tekak (Qalqalah)'),
  HijaiyahLetterItem(22, 'ك', 'Kaf', 'k', 'ـك · ـكـ · كـ', 'كَ (Ka) · كِ (Ki) · كُ (Ku)', 'Pangkal lidah sedikit di depan Qaf'),
  HijaiyahLetterItem(23, 'ل', 'Lam', 'l', 'ـل · ـلـ · لـ', 'لَ (La) · لِ (Li) · لُ (Lu)', 'Ujung tepi lidah bertemu gusi gigi depan atas'),
  HijaiyahLetterItem(24, 'م', 'Mim', 'm', 'ـم · ـمـ · مـ', 'مَ (Ma) · مِ (Mi) · مُ (Mu)', 'Merapatkan kedua bibir disertai sifat ghunnah'),
  HijaiyahLetterItem(25, 'ن', 'Nun', 'n', 'ـن · ـنـ · نـ', 'نَ (Na) · نِ (Ni) · نُ (Nu)', 'Ujung lidah bertemu gusi atas disertai ghunnah'),
  HijaiyahLetterItem(26, 'و', 'Wawu', 'w', 'ـو · ـو · و', 'وَ (Wa) · وِ (Wi) · وُ (Wu)', 'Membulatkan kedua bibir ke depan'),
  HijaiyahLetterItem(27, 'هـ', 'Ha Besar', 'h (dalam)', 'ـه · ـهـ · هـ', 'هَ (Ha) · هِ (Hi) · هُ (Hu)', 'Pangkal tenggorokan terdalam'),
  HijaiyahLetterItem(28, 'ء', 'Hamzah', '\' (hamzah)', 'ء · أ · إ · ؤ · ئ', 'أَ (A) · إِ (I) · أُ (U)', 'Pangkal tenggorokan terdalam'),
  HijaiyahLetterItem(29, 'ي', 'Ya', 'y', 'ـي · ـيـ · يـ', 'يَ (Ya) · يِ (Yi) · يُ (Yu)', 'Tengah lidah bertemu langit-langit atas'),
];

// ================= 43. KUIS WAWASAN ISLAM HARIAN (OFFLINE) =================

class IslamicKnowledgeQuestion {
  final int id;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const IslamicKnowledgeQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

const List<IslamicKnowledgeQuestion> islamicKnowledgeQuizBank = [
  IslamicKnowledgeQuestion(
    id: 1,
    category: 'Al-Qur\'an',
    question: 'Surah apakah dalam Al-Qur\'an yang tidak diawali dengan lafaz Basmalah?',
    options: ['Surah Al-Anfal', 'Surah At-Taubah', 'Surah Al-Kahfi', 'Surah Yasin'],
    correctIndex: 1,
    explanation: 'Surah At-Taubah (Surah ke-9) adalah satu-satunya surah dalam mushaf yang tidak diawali dengan Basmalah.',
  ),
  IslamicKnowledgeQuestion(
    id: 2,
    category: 'Sirah Nabawiyah',
    question: 'Masjid pertama yang dibangun oleh Rasulullah SAW ketika tiba dalam perjalanan Hijrah adalah...',
    options: ['Masjidil Haram', 'Masjid Quba', 'Masjid Nabawi', 'Masjid Qiblatain'],
    correctIndex: 1,
    explanation: 'Masjid Quba didirikan saat Rasulullah SAW singgah di Quba sebelum memasuki pusat kota Madinah (QS. At-Taubah: 108).',
  ),
  IslamicKnowledgeQuestion(
    id: 3,
    category: 'Fiqih Ibadah',
    question: 'Berapakah batas nisab Zakat Maal untuk simpanan emas yang telah mencapai haul 1 tahun Hijriah?',
    options: ['50 gram emas', '85 gram emas', '100 gram emas', '200 gram emas'],
    correctIndex: 1,
    explanation: 'Nisab zakat emas adalah 20 dinar atau setara 85 gram emas murni dengan kadar zakat 2,5%.',
  ),
  IslamicKnowledgeQuestion(
    id: 4,
    category: 'Hadits & Sunnah',
    question: 'Berapa jumlah total rakaat Salat Sunnah Rawatib Muakkadah yang dijanjikan rumah di surga dalam HR. Muslim no. 728?',
    options: ['8 rakaat', '10 rakaat', '12 rakaat', '14 rakaat'],
    correctIndex: 2,
    explanation: '12 rakaat Rawatib: 2 sebelum Subuh, 4 sebelum Dzuhur, 2 sesudah Dzuhur, 2 sesudah Maghrib, dan 2 sesudah Isya.',
  ),
  IslamicKnowledgeQuestion(
    id: 5,
    category: 'Al-Qur\'an',
    question: 'Ayat paling agung dalam Al-Qur\'an (Ayat Kursi) terdapat pada Surah dan ayat ke berapa?',
    options: ['QS. Al-Baqarah: 185', 'QS. Al-Baqarah: 255', 'QS. Al-Baqarah: 286', 'QS. Ali \'Imran: 18'],
    correctIndex: 1,
    explanation: 'Ayat Kursi adalah QS. Al-Baqarah ayat 255 yang menegaskan kemahahidupan dan kepengurusan mutlak Allah SWT.',
  ),
];

// ================= 44. GLOSARIUM / ENSIKLOPEDIA MINI ISTILAH ISLAM =================

class IslamicGlossaryTerm {
  final String term;
  final String category;
  final String definition;

  const IslamicGlossaryTerm(this.term, this.category, this.definition);

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return term.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        definition.toLowerCase().contains(q);
  }
}

const List<IslamicGlossaryTerm> islamicGlossaryCatalog = [
  IslamicGlossaryTerm('Tuma\'ninah', 'Fiqih Salat', 'Tenang dan diam sejenak setelah seluruh anggota tubuh berada sempurna pada posisi rukun salat (seperti ruku\', i\'tidal, dan sujud).'),
  IslamicGlossaryTerm('Sujud Sahwi', 'Fiqih Salat', 'Dua sujud di akhir salat (sebelum atau sesudah salam) untuk menambal kelupaan jumlah rakaat atau tertinggalnya sunnah ab\'adh.'),
  IslamicGlossaryTerm('Sujud Tilawah', 'Fiqih Al-Qur\'an', 'Satu kali sujud yang disunnahkan ketika membaca atau mendengar salah satu dari 15 Ayat Sajdah dalam Al-Qur\'an.'),
  IslamicGlossaryTerm('Nisab & Haul', 'Zakat & Muamalah', 'Nisab adalah batas minimal harta yang wajib dizakati; Haul adalah berlalunya masa kepemilikan selama 1 tahun penuh kalender Hijriah (354 hari).'),
  IslamicGlossaryTerm('Masafatul Qashr', 'Fiqih Safar', 'Batas jarak minimal perjalanan safar (±81–89 km / 2 Marhalah) yang memperbolehkan keringanan meringkas (Qashar) dan menjama\' salat.'),
  IslamicGlossaryTerm('Ashabul Furudh & Ashabah', 'Faraid (Waris)', 'Ashabul Furudh adalah ahli waris yang bagiannya ditentukan pasti dalam Al-Qur\'an (1/2, 1/4, 1/8, 2/3, 1/3, 1/6); Ashabah adalah ahli waris yang menerima sisa harta.'),
  IslamicGlossaryTerm('\'Aul & Radd', 'Faraid (Waris)', '\'Aul adalah menaikkan penyebut ketika total bagian ahli waris melebihi 100%; Radd adalah mengembalikan sisa harta secara proporsional kepada ahli waris nasab saat tidak ada Ashabah.'),
  IslamicGlossaryTerm('Gharar & Riba', 'Muamalah', 'Gharar adalah ketidakpastian/spekulasi terlarang dalam akad jual beli; Riba adalah tambahan yang disyaratkan atas pokok utang atau pertukaran barang ribawi yang tidak setara.'),
  IslamicGlossaryTerm('Mahram', 'Keluarga', 'Kerabat dekat (karena nasab, persusuan, atau pernikahan) yang haram dinikahi selamanya dan diperbolehkan melakukan safar bersama.'),
  IslamicGlossaryTerm('Tabayyun', 'Akhlak', 'Meneliti dan memverifikasi kebenaran suatu berita sebelum menyebarkan atau mengambil sikap (QS. Al-Hujurat: 6).'),
  IslamicGlossaryTerm('Ihsan & Muraqabah', 'Aqidah & Akhlak', 'Beribadah kepada Allah seolah-olah melihat-Nya, dan menyadari penuh bahwa Allah senantiasa mengawasi setiap gerak-gerik hamba.'),
  IslamicGlossaryTerm('Istidraj', 'Aqidah', 'Limpahan kesenangan duniawi yang diberikan kepada pelaku maksiat yang terus berpaling dari Allah sebagai bentuk ujian yang melalaikan.'),
];

// ================= 45. PENCATAT UTANG-PIUTANG PRIBADI (QS. AL-BAQARAH: 282) =================

enum DebtRecordKind {
  utangSaya('Utang Saya (Wajib Dibayar)'),
  piutangSaya('Piutang Saya (Dipinjam Orang)');

  final String label;
  const DebtRecordKind(this.label);
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
