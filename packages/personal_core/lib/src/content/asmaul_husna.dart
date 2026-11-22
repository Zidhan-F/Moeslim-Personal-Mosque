import '../storage/key_value_store.dart';

class AsmaulHusnaItem {
  final int number;
  final String arabic;
  final String latin;
  final String meaning;
  final String explanation;

  const AsmaulHusnaItem(
    this.number,
    this.arabic,
    this.latin,
    this.meaning,
    this.explanation,
  );

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '$number' == q ||
        latin.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        explanation.toLowerCase().contains(q) ||
        arabic.contains(q);
  }
}

const List<AsmaulHusnaItem> asmaulHusnaCatalog = [
  AsmaulHusnaItem(1, 'الرَّحْمَٰنُ', 'Ar-Rahman', 'Yang Maha Pengasih', 'Melimpahkan kasih sayang dan nikmat kepada seluruh makhluk di dunia tanpa terkecuali.'),
  AsmaulHusnaItem(2, 'الرَّحِيمُ', 'Ar-Rahim', 'Yang Maha Penyayang', 'Melimpahkan rahmat khusus yang kekal bagi hamba-hamba yang beriman di akhirat.'),
  AsmaulHusnaItem(3, 'الْمَلِكُ', 'Al-Malik', 'Yang Maharaja / Menguasai', 'Pemilik kekuasaan mutlak atas seluruh kerajaan langit dan bumi.'),
  AsmaulHusnaItem(4, 'الْقُدُّوسُ', 'Al-Quddus', 'Yang Mahasuci', 'Mahasuci dari segala sifat kekurangan, aib, dan penyerupaan makhluk.'),
  AsmaulHusnaItem(5, 'السَّلَامُ', 'As-Salam', 'Yang Maha Memberi Kesejahteraan', 'Sumber keselamatan, kedamaian, dan bebas dari segala cacat.'),
  AsmaulHusnaItem(6, 'الْمُؤْمِنُ', 'Al-Mu\'min', 'Yang Maha Memberi Keamanan', 'Memberikan rasa aman kepada makhluk-Nya dan membenarkan janji-Nya.'),
  AsmaulHusnaItem(7, 'الْمُهَيْمِنُ', 'Al-Muhaimin', 'Yang Maha Pemelihara & Pengawas', 'Mengawasi, menjaga, dan mengatur seluruh urusan makhluk dengan sempurna.'),
  AsmaulHusnaItem(8, 'الْعَزِيزُ', 'Al-\'Aziz', 'Yang Mahaperkasa', 'Memiliki kemuliaan dan keperkasaan yang tidak terkalahkan oleh siapa pun.'),
  AsmaulHusnaItem(9, 'الْجَبَّارُ', 'Al-Jabbar', 'Yang Mahakuasa & Memperbaiki', 'Berkuasa menundukkan segalanya sekaligus menyembuhkan hati yang hancur dan lemah.'),
  AsmaulHusnaItem(10, 'الْمُتَكَبِّرُ', 'Al-Mutakabbir', 'Yang Memiliki Segala Kebesaran', 'Hanya Dia yang berhak menyandang kebesaran dan keagungan di atas seluruh makhluk.'),
  AsmaulHusnaItem(11, 'الْخَالِقُ', 'Al-Khaliq', 'Yang Maha Pencipta', 'Menciptakan seluruh alam semesta dari ketiadaan dengan ukuran yang tepat.'),
  AsmaulHusnaItem(12, 'الْبَارِئُ', 'Al-Bari\'', 'Yang Maha Melepaskan & Membentuk', 'Mewujudkan ciptaan dengan selaras dan bebas dari ketimpangan.'),
  AsmaulHusnaItem(13, 'الْمُصَوِّرُ', 'Al-Mushawwir', 'Yang Maha Membentuk Rupa', 'Memberi rupa dan ciri khas yang unik pada setiap makhluk-Nya.'),
  AsmaulHusnaItem(14, 'الْغَفَّارُ', 'Al-Ghaffar', 'Yang Maha Pengampun', 'Berulang kali menutupi dosa dan mengampuni hamba yang bertaubat.'),
  AsmaulHusnaItem(15, 'الْقَهَّارُ', 'Al-Qahhar', 'Yang Maha Menundukkan', 'Menundukkan seluruh makhluk di bawah ketetapan dan kekuasaan-Nya.'),
  AsmaulHusnaItem(16, 'الْوَهَّابُ', 'Al-Wahhab', 'Yang Maha Pemberi Karunia', 'Memberi anugerah tanpa pamrih dan tanpa mengharap imbalan.'),
  AsmaulHusnaItem(17, 'الرَّزَّاقُ', 'Ar-Razzaq', 'Yang Maha Pemberi Rezeki', 'Menjamin dan mengalirkan rezeki lahir maupun batin bagi setiap makhluk.'),
  AsmaulHusnaItem(18, 'الْفَتَّاحُ', 'Al-Fattah', 'Yang Maha Pembuka Rahmat', 'Membukakan pintu rahmat, jalan keluar, ilmu, dan keputusan yang adil.'),
  AsmaulHusnaItem(19, 'الْعَلِيمُ', 'Al-\'Alim', 'Yang Maha Mengetahui', 'Mengetahui segala yang tampak maupun tersembunyi di langit dan bumi.'),
  AsmaulHusnaItem(20, 'الْقَابِضُ', 'Al-Qabidh', 'Yang Maha Menyempitkan', 'Menahan atau menyempitkan rezeki dan mencabut nyawa sesuai hikmah-Nya.'),
  AsmaulHusnaItem(21, 'الْبَاسِطُ', 'Al-Basith', 'Yang Maha Melapangkan', 'Meluaskan rezeki, rahmat, dan kelapangan dada bagi hamba-Nya.'),
  AsmaulHusnaItem(22, 'الْخَافِضُ', 'Al-Khafidh', 'Yang Maha Merendahkan', 'Merendahkan derajat orang-orang yang sombong dan durhaka.'),
  AsmaulHusnaItem(23, 'الرَّافِعُ', 'Ar-Rafi\'', 'Yang Maha Meninggikan', 'Mengangkat derajat orang-orang yang beriman dan berilmu.'),
  AsmaulHusnaItem(24, 'الْمُعِزُّ', 'Al-Mu\'izz', 'Yang Maha Memuliakan', 'Menganugerahkan kemuliaan sejati kepada siapa yang Dia kehendaki.'),
  AsmaulHusnaItem(25, 'الْمُذِلُّ', 'Al-Mudzill', 'Yang Maha Menghinakan', 'Menghinakan siapa saja yang menentang kebenaran dan keadilan-Nya.'),
  AsmaulHusnaItem(26, 'السَّمِيعُ', 'As-Sami\'', 'Yang Maha Mendengar', 'Mendengar setiap doa, rintihan, dan bisikan paling lirih sekalipun.'),
  AsmaulHusnaItem(27, 'الْبَصِيرُ', 'Al-Bashir', 'Yang Maha Melihat', 'Melihat setiap gerak-gerik dan amal perbuatan makhluk tanpa terhalang.'),
  AsmaulHusnaItem(28, 'الْحَكَمُ', 'Al-Hakam', 'Yang Maha Menetapkan Hukum', 'Pembuat ketetapan dan pengadil tertinggi yang tidak pernah keliru.'),
  AsmaulHusnaItem(29, 'الْعَدْلُ', 'Al-\'Adl', 'Yang Mahaadil', 'Menempatkan segala sesuatu secara adil tanpa menzalimi sedikit pun.'),
  AsmaulHusnaItem(30, 'اللَّطِيفُ', 'Al-Lathif', 'Yang Mahalembut', 'Menyantuni hamba-Nya dengan kelembutan dan cara yang halus tak terduga.'),
  AsmaulHusnaItem(31, 'الْخَبِيرُ', 'Al-Khabir', 'Yang Mahateliti', 'Mengetahui hakikat terdalam dan rahasia batin segala sesuatu.'),
  AsmaulHusnaItem(32, 'الْحَلِيمُ', 'Al-Halim', 'Yang Maha Penyantun', 'Tidak tergesa-gesa menghukum hamba yang berdosa dan memberi waktu bertaubat.'),
  AsmaulHusnaItem(33, 'الْعَظِيمُ', 'Al-\'Azhim', 'Yang Mahaagung', 'Memiliki keagungan zat dan sifat yang tidak terjangkau akal manusia.'),
  AsmaulHusnaItem(34, 'الْغَفُورُ', 'Al-Ghafur', 'Yang Maha Pengampun', 'Mengampuni dosa-dosa besar maupun kecil bagi yang memohon ampunan.'),
  AsmaulHusnaItem(35, 'الشَّكُورُ', 'Asy-Syakur', 'Yang Maha Menghargai Syukur', 'Membalas amal yang sedikit dengan pahala yang berlipat ganda.'),
  AsmaulHusnaItem(36, 'الْعَلِيُّ', 'Al-\'Aliyy', 'Yang Mahatinggi', 'Mahatinggi kedudukan, kekuasaan, dan kemuliaan-Nya di atas segalanya.'),
  AsmaulHusnaItem(37, 'الْكَبِيرُ', 'Al-Kabir', 'Yang Mahabesar', 'Segala sesuatu selain-Nya kecil di hadapan kebesaran Allah.'),
  AsmaulHusnaItem(38, 'الْحَفِيظُ', 'Al-Hafizh', 'Yang Maha Memelihara', 'Menjaga langit, bumi, dan hamba-Nya serta mencatat seluruh amal.'),
  AsmaulHusnaItem(39, 'الْمُقِيتُ', 'Al-Muqit', 'Yang Maha Pemberi Kecukupan', 'Menyediakan kecukupan makanan dan kekuatan bagi setiap makhluk.'),
  AsmaulHusnaItem(40, 'الْحَسِيبُ', 'Al-Hasib', 'Yang Maha Membuat Perhitungan', 'Mencukupi siapa yang bertawakal kepada-Nya dan memperhitungkan amal dengan teliti.'),
  AsmaulHusnaItem(41, 'الْجَلِيلُ', 'Al-Jalil', 'Yang Mahamulia & Luhur', 'Pemilik sifat-sifat keagungan, kemuliaan, dan kesempurnaan.'),
  AsmaulHusnaItem(42, 'الْكَرِيمُ', 'Al-Karim', 'Yang Maha Pemurah', 'Maha Dermawan yang memberi sebelum diminta dan memaafkan saat mampu menghukum.'),
  AsmaulHusnaItem(43, 'الرَّقِيبُ', 'Ar-Raqib', 'Yang Maha Mengawasi', 'Tidak pernah lengah mengawasi setiap lintasan hati dan perbuatan.'),
  AsmaulHusnaItem(44, 'الْمُجِيبُ', 'Al-Mujib', 'Yang Maha Mengabulkan', 'Menjawab doa dan permohonan hamba yang berseru kepada-Nya.'),
  AsmaulHusnaItem(45, 'الْوَاسِعُ', 'Al-Wasi\'', 'Yang Mahaluas', 'Ilmu, rahmat, dan karunia-Nya meliputi segala sesuatu.'),
  AsmaulHusnaItem(46, 'الْحَكِيمُ', 'Al-Hakim', 'Yang Mahabijaksana', 'Setiap ciptaan dan takdir-Nya penuh hikmah serta tepat pada tempatnya.'),
  AsmaulHusnaItem(47, 'الْوَدُودُ', 'Al-Wadud', 'Yang Maha Mengasihi & Mencintai', 'Mencintai hamba-hamba-Nya yang taat dan bertaubat serta dicintai oleh mereka.'),
  AsmaulHusnaItem(48, 'الْمَجِيدُ', 'Al-Majid', 'Yang Mahamulia', 'Mulia dalam zat-Nya dan indah dalam segala perbuatan serta pemberian-Nya.'),
  AsmaulHusnaItem(49, 'الْبَاعِثُ', 'Al-Ba\'its', 'Yang Maha Membangkitkan', 'Membangkitkan manusia dari kubur pada hari Kiamat dan mengutus para rasul.'),
  AsmaulHusnaItem(50, 'الشَّهِيدُ', 'Asy-Syahid', 'Yang Maha Menyaksikan', 'Menyaksikan secara langsung segala peristiwa tanpa ada yang luput.'),
  AsmaulHusnaItem(51, 'الْحَقُّ', 'Al-Haqq', 'Yang Mahabenar', 'Kebenaran mutlak dalam zat, firman, janji, dan perjumpaan dengan-Nya.'),
  AsmaulHusnaItem(52, 'الْوَكِيلُ', 'Al-Wakil', 'Yang Maha Memelihara Urusan', 'Tempat bersandar terbaik yang mengurus segala keperluan hamba yang bertawakal.'),
  AsmaulHusnaItem(53, 'الْقَوِيُّ', 'Al-Qawiyy', 'Yang Mahakuat', 'Memiliki kekuatan sempurna yang tidak pernah disentuh kelemahan.'),
  AsmaulHusnaItem(54, 'الْمَتِينُ', 'Al-Matin', 'Yang Mahakokoh', 'Sangat kukuh kekuasaan-Nya tanpa membutuhkan bantuan siapa pun.'),
  AsmaulHusnaItem(55, 'الْوَلِيُّ', 'Al-Waliyy', 'Yang Maha Melindungi', 'Penolong dan pelindung setia bagi orang-orang yang beriman.'),
  AsmaulHusnaItem(56, 'الْحَمِيدُ', 'Al-Hamid', 'Yang Maha Terpuji', 'Terpuji dalam setiap nikmat, syariat, dan ketetapan takdir-Nya.'),
  AsmaulHusnaItem(57, 'الْمُحْصِي', 'Al-Muhshi', 'Yang Maha Menghitung', 'Menghitung setiap makhluk, napas, dan butiran amal secara eksak.'),
  AsmaulHusnaItem(58, 'الْمُبْدِئُ', 'Al-Mubdi\'', 'Yang Maha Memulai', 'Memulai penciptaan segala sesuatu dari awal tanpa contoh sebelumnya.'),
  AsmaulHusnaItem(59, 'الْمُعِيدُ', 'Al-Mu\'id', 'Yang Maha Mengembalikan Kehidupan', 'Mengembalikan makhluk hidup setelah mati pada hari kebangkitan.'),
  AsmaulHusnaItem(60, 'الْمُحْيِي', 'Al-Muhyi', 'Yang Maha Menghidupkan', 'Meniupkan kehidupan pada jasad dan menghidupkan hati dengan iman.'),
  AsmaulHusnaItem(61, 'الْمُمِيتُ', 'Al-Mumit', 'Yang Maha Mematikan', 'Menetapkan ajal dan kematian bagi setiap makhluk yang bernyawa.'),
  AsmaulHusnaItem(62, 'الْحَيُّ', 'Al-Hayyu', 'Yang Mahahidup', 'Hidup kekal abadi tanpa awal dan tanpa akhir.'),
  AsmaulHusnaItem(63, 'الْقَيُّومُ', 'Al-Qayyum', 'Yang Maha Mandiri', 'Berdiri sendiri dan menegakkan seluruh urusan langit serta bumi.'),
  AsmaulHusnaItem(64, 'الْوَاجِدُ', 'Al-Wajid', 'Yang Maha Penemu & Kaya', 'Memiliki segala sesuatu dan tidak pernah kekurangan apa pun.'),
  AsmaulHusnaItem(65, 'الْمَاجِدُ', 'Al-Majid', 'Yang Mahamulia & Agung', 'Memiliki kemuliaan yang sempurna dan kedermawanan yang luas.'),
  AsmaulHusnaItem(66, 'الْوَاحِدُ', 'Al-Wahid', 'Yang Maha Tunggal', 'Tunggal dalam zat, sifat, dan hak untuk disembah.'),
  AsmaulHusnaItem(67, 'الْأَحَدُ', 'Al-Ahad', 'Yang Maha Esa', 'Maha Esa secara mutlak, tidak terbagi dan tiada sekutu bagi-Nya.'),
  AsmaulHusnaItem(68, 'الصَّمَدُ', 'Ash-Shamad', 'Yang Maha Dibutuhkan', 'Tempat bergantung dan memohon segala makhluk dalam setiap hajat.'),
  AsmaulHusnaItem(69, 'الْقَادِرُ', 'Al-Qadir', 'Yang Mahakuasa', 'Mampu mewujudkan apa saja yang dikehendaki-Nya tanpa kesulitan.'),
  AsmaulHusnaItem(70, 'الْمُقْتَدِرُ', 'Al-Muqtadir', 'Yang Maha Berkuasa Penuh', 'Menampakkan kekuasaan-Nya yang sempurna atas seluruh ciptaan.'),
  AsmaulHusnaItem(71, 'الْمُقَدِّمُ', 'Al-Muqaddim', 'Yang Maha Mendahulukan', 'Mendahulukan siapa dan apa saja sesuai hikmah serta kehendak-Nya.'),
  AsmaulHusnaItem(72, 'الْمُؤَخِّرُ', 'Al-Mu\'akhkhir', 'Yang Maha Mengakhirkan', 'Menunda atau mengakhirkan sesuatu tepat pada waktu yang terbaik.'),
  AsmaulHusnaItem(73, 'الْأَوَّلُ', 'Al-Awwal', 'Yang Mahaawal', 'Ada sebelum segala sesuatu ada, tanpa permulaan.'),
  AsmaulHusnaItem(74, 'الْآخِرُ', 'Al-Akhir', 'Yang Mahaakhir', 'Tetap kekal setelah seluruh makhluk binasa, tanpa kesudahan.'),
  AsmaulHusnaItem(75, 'الظَّاهِرُ', 'Azh-Zhahir', 'Yang Mahanyata', 'Nyata tanda-tanda keberadaan dan kekuasaan-Nya di seluruh penjuru alam.'),
  AsmaulHusnaItem(76, 'الْبَاطِنُ', 'Al-Bathin', 'Yang Maha Ghaib', 'Tidak dapat dijangkau hakikat zat-Nya oleh penglihatan mata di dunia.'),
  AsmaulHusnaItem(77, 'الْوَالِي', 'Al-Wali', 'Yang Maha Memerintah', 'Mengatur dan mengendalikan seluruh kejadian di alam semesta.'),
  AsmaulHusnaItem(78, 'الْمُتَعَالِي', 'Al-Muta\'ali', 'Yang Mahatinggi', 'Mahatinggi dari segala tuduhan dan sifat yang tidak layak bagi-Nya.'),
  AsmaulHusnaItem(79, 'الْبَرُّ', 'Al-Barr', 'Yang Maha Penderma & Baik', 'Berbuat baik, menepati janji, dan melimpahkan kebajikan kepada hamba-Nya.'),
  AsmaulHusnaItem(80, 'التَّوَّابُ', 'At-Tawwab', 'Yang Maha Penerima Taubat', 'Membuka pintu taubat dan menerima kembalinya hamba yang menyesali dosa.'),
  AsmaulHusnaItem(81, 'الْمُنْتَقِمُ', 'Al-Muntaqim', 'Yang Maha Pemberi Balasan', 'Menjatuhkan balasan yang adil kepada para pelaku kezaliman yang membangkang.'),
  AsmaulHusnaItem(82, 'الْعَفُوُّ', 'Al-\'Afuww', 'Yang Maha Pemaaf', 'Menghapus jejak dosa dan memaafkan kesalahan hamba hingga bersih.'),
  AsmaulHusnaItem(83, 'الرَّءُوفُ', 'Ar-Ra\'uf', 'Yang Maha Pengasih & Belas Kasih', 'Memiliki kasih sayang yang sangat mendalam dan lembut kepada hamba-Nya.'),
  AsmaulHusnaItem(84, 'مَالِكُ الْمُلْكِ', 'Malikul-Mulk', 'Penguasa Kerajaan Semesta', 'Memberikan dan mencabut kekuasaan dunia kepada siapa yang dikehendaki-Nya.'),
  AsmaulHusnaItem(85, 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'Dzul-Jalali wal-Ikram', 'Pemilik Keagungan & Kemuliaan', 'Berhak diagungkan dan selalu memuliakan hamba-hamba-Nya yang ikhlas.'),
  AsmaulHusnaItem(86, 'الْمُقْسِطُ', 'Al-Muqsith', 'Yang Maha Pemberi Keadilan', 'Menegakkan keadilan dan memenangkan pihak yang terzalimi.'),
  AsmaulHusnaItem(87, 'الْجَامِعُ', 'Al-Jami\'', 'Yang Maha Mengumpulkan', 'Mengumpulkan seluruh manusia pada hari Kiamat dan menyatukan hati orang beriman.'),
  AsmaulHusnaItem(88, 'الْغَنِيُّ', 'Al-Ghaniyy', 'Yang Mahakaya', 'Mahakaya dan sama sekali tidak membutuhkan ibadah maupun makhluk-Nya.'),
  AsmaulHusnaItem(89, 'الْمُغْنِي', 'Al-Mughni', 'Yang Maha Memberi Kekayaan', 'Mencukupkan dan memperkaya hati serta kehidupan siapa yang Dia kehendaki.'),
  AsmaulHusnaItem(90, 'الْمَانِعُ', 'Al-Mani\'', 'Yang Maha Mencegah', 'Mencegah mudarat atau menahan sesuatu demi kebaikan dan perlindungan hamba.'),
  AsmaulHusnaItem(91, 'الضَّارُّ', 'Adh-Dharr', 'Yang Maha Menimpakan Kemudaratan', 'Menetapkan ujian atau kesulitan sebagai peringatan dan hikmah bagi manusia.'),
  AsmaulHusnaItem(92, 'النَّافِعُ', 'An-Nafi\'', 'Yang Maha Memberi Manfaat', 'Satu-satunya pemberi manfaat hakiki dalam obat, ilmu, dan ikhtiar.'),
  AsmaulHusnaItem(93, 'النُّورُ', 'An-Nur', 'Yang Maha Bercahaya', 'Cahaya langit dan bumi yang menerangi hati orang-orang beriman dengan petunjuk.'),
  AsmaulHusnaItem(94, 'الْهَادِي', 'Al-Hadi', 'Yang Maha Pemberi Petunjuk', 'Membimbing makhluk-Nya mengenal jalan keselamatan dan kebenaran.'),
  AsmaulHusnaItem(95, 'الْبَدِيعُ', 'Al-Badi\'', 'Yang Maha Pencipta Tanpa Contoh', 'Menciptakan keindahan semesta yang menakjubkan tanpa ada yang mendahului.'),
  AsmaulHusnaItem(96, 'الْبَاقِي', 'Al-Baqi', 'Yang Mahakekal', 'Tetap abadi selama-lamanya tanpa pernah mengalami kebinasaan.'),
  AsmaulHusnaItem(97, 'الْوَارِثُ', 'Al-Warits', 'Yang Maha Pewaris', 'Kembali kepada-Nya seluruh kepemilikan setelah semua makhluk tiada.'),
  AsmaulHusnaItem(98, 'الرَّشِيدُ', 'Ar-Rasyid', 'Yang Maha Pandai & Tepat', 'Membimbing segala urusan menuju tujuan yang paling benar dan lurus.'),
  AsmaulHusnaItem(99, 'الصَّبُورُ', 'Ash-Shabur', 'Yang Mahasabar', 'Tidak tergesa-gesa menyiksa pendosa dan memberi kesempatan luas untuk kembali.'),
];

class AsmaulHusnaQuizQuestion {
  final AsmaulHusnaItem target;
  final List<AsmaulHusnaItem> options;

  const AsmaulHusnaQuizQuestion({
    required this.target,
    required this.options,
  });
}

AsmaulHusnaQuizQuestion buildAsmaulHusnaQuizQuestion(int index) {
  final safeIndex = index.abs() % asmaulHusnaCatalog.length;
  final target = asmaulHusnaCatalog[safeIndex];
  final d1 = asmaulHusnaCatalog[(safeIndex + 7) % asmaulHusnaCatalog.length];
  final d2 = asmaulHusnaCatalog[(safeIndex + 19) % asmaulHusnaCatalog.length];
  final d3 = asmaulHusnaCatalog[(safeIndex + 43) % asmaulHusnaCatalog.length];
  final opts = <AsmaulHusnaItem>[target, d1, d2, d3];
  // Deterministic rotation based on index so quiz options vary position cleanly
  final shift = safeIndex % 4;
  final rotated = [
    for (var i = 0; i < 4; i++) opts[(i + shift) % 4],
  ];
  return AsmaulHusnaQuizQuestion(target: target, options: rotated);
}

class AsmaulHusnaRepository {
  static const _memorizedKey = 'asmaul_husna_memorized';
  final KeyValueStore _store;

  const AsmaulHusnaRepository(this._store);

  Future<Set<int>> memorizedNumbers() async {
    final raw = await _store.readJson(_memorizedKey);
    if (raw is! List) return {};
    return {
      for (final x in raw)
        if (x is num) x.toInt(),
    };
  }

  Future<Set<int>> toggleMemorized(int number) async {
    final set = await memorizedNumbers();
    if (!set.remove(number)) {
      set.add(number);
    }
    await _store.writeJson(_memorizedKey, set.toList()..sort());
    return set;
  }
}
