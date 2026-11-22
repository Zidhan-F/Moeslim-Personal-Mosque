import 'package:shared_prayer/shared_prayer.dart';

import '../storage/key_value_store.dart';

class AsmaulHusnaItem {
  final int number;
  final String arabic;
  final String latin;
  final String meaning;
  final String explanation;
  final String? meaningEn;
  final String? explanationEn;

  const AsmaulHusnaItem(
    this.number,
    this.arabic,
    this.latin,
    this.meaning,
    this.explanation, {
    this.meaningEn,
    this.explanationEn,
  });

  String meaningFor(AppLanguage lang) =>
      lang == AppLanguage.en && (meaningEn?.isNotEmpty ?? false) ? meaningEn! : meaning;

  String explanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (explanationEn?.isNotEmpty ?? false) ? explanationEn! : explanation;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '$number' == q ||
        latin.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        (meaningEn?.toLowerCase().contains(q) ?? false) ||
        explanation.toLowerCase().contains(q) ||
        (explanationEn?.toLowerCase().contains(q) ?? false) ||
        arabic.contains(q);
  }
}

const List<AsmaulHusnaItem> asmaulHusnaCatalog = [
  AsmaulHusnaItem(1, 'الرَّحْمَٰنُ', 'Ar-Rahman', 'Yang Maha Pengasih', 'Melimpahkan kasih sayang dan nikmat kepada seluruh makhluk di dunia tanpa terkecuali.', meaningEn: 'The Most Compassionate', explanationEn: 'Pours mercy and blessings upon all creation in this world without exception.'),
  AsmaulHusnaItem(2, 'الرَّحِيمُ', 'Ar-Rahim', 'Yang Maha Penyayang', 'Melimpahkan rahmat khusus yang kekal bagi hamba-hamba yang beriman di akhirat.', meaningEn: 'The Most Merciful', explanationEn: 'Bestows special, enduring mercy upon the believers in the Hereafter.'),
  AsmaulHusnaItem(3, 'الْمَلِكُ', 'Al-Malik', 'Yang Maharaja / Menguasai', 'Pemilik kekuasaan mutlak atas seluruh kerajaan langit dan bumi.', meaningEn: 'The Absolute Sovereign', explanationEn: 'Holder of absolute authority over the entire dominion of the heavens and the earth.'),
  AsmaulHusnaItem(4, 'الْقُدُّوسُ', 'Al-Quddus', 'Yang Mahasuci', 'Mahasuci dari segala sifat kekurangan, aib, dan penyerupaan makhluk.', meaningEn: 'The Most Sacred', explanationEn: 'Pure and transcendent above every imperfection, flaw, or likeness to creation.'),
  AsmaulHusnaItem(5, 'السَّلَامُ', 'As-Salam', 'Yang Maha Memberi Kesejahteraan', 'Sumber keselamatan, kedamaian, dan bebas dari segala cacat.', meaningEn: 'The Source of Peace', explanationEn: 'The source of all safety and peace, completely free from any defect.'),
  AsmaulHusnaItem(6, 'الْمُؤْمِنُ', 'Al-Mu\'min', 'Yang Maha Memberi Keamanan', 'Memberikan rasa aman kepada makhluk-Nya dan membenarkan janji-Nya.', meaningEn: 'The Granter of Security', explanationEn: 'Grants safety and reassurance to His servants and fulfills every promise.'),
  AsmaulHusnaItem(7, 'الْمُهَيْمِنُ', 'Al-Muhaimin', 'Yang Maha Pemelihara & Pengawas', 'Mengawasi, menjaga, dan mengatur seluruh urusan makhluk dengan sempurna.', meaningEn: 'The Guardian & Overseer', explanationEn: 'Watches over, safeguards, and governs all affairs of creation with perfection.'),
  AsmaulHusnaItem(8, 'الْعَزِيزُ', 'Al-\'Aziz', 'Yang Mahaperkasa', 'Memiliki kemuliaan dan keperkasaan yang tidak terkalahkan oleh siapa pun.', meaningEn: 'The Almighty', explanationEn: 'Possesses supreme honor and invincible might that none can overcome.'),
  AsmaulHusnaItem(9, 'الْجَبَّارُ', 'Al-Jabbar', 'Yang Mahakuasa & Memperbaiki', 'Berkuasa menundukkan segalanya sekaligus menyembuhkan hati yang hancur dan lemah.', meaningEn: 'The Compeller & Restorer', explanationEn: 'Subdues all things by His will while gently mending broken and weary hearts.'),
  AsmaulHusnaItem(10, 'الْمُتَكَبِّرُ', 'Al-Mutakabbir', 'Yang Memiliki Segala Kebesaran', 'Hanya Dia yang berhak menyandang kebesaran dan keagungan di atas seluruh makhluk.', meaningEn: 'The Supreme in Majesty', explanationEn: 'Solely worthy of all greatness and majesty above everything in creation.'),
  AsmaulHusnaItem(11, 'الْخَالِقُ', 'Al-Khaliq', 'Yang Maha Pencipta', 'Menciptakan seluruh alam semesta dari ketiadaan dengan ukuran yang tepat.', meaningEn: 'The Creator', explanationEn: 'Brings the entire universe into existence from nothing in precise measure.'),
  AsmaulHusnaItem(12, 'الْبَارِئُ', 'Al-Bari\'', 'Yang Maha Melepaskan & Membentuk', 'Mewujudkan ciptaan dengan selaras dan bebas dari ketimpangan.', meaningEn: 'The Maker from Nothing', explanationEn: 'Fashions creation in complete harmony, free from any flaw or disparity.'),
  AsmaulHusnaItem(13, 'الْمُصَوِّرُ', 'Al-Mushawwir', 'Yang Maha Membentuk Rupa', 'Memberi rupa dan ciri khas yang unik pada setiap makhluk-Nya.', meaningEn: 'The Fashioner of Forms', explanationEn: 'Gives each creature its unique shape, form, and distinctive beauty.'),
  AsmaulHusnaItem(14, 'الْغَفَّارُ', 'Al-Ghaffar', 'Yang Maha Pengampun', 'Berulang kali menutupi dosa dan mengampuni hamba yang bertaubat.', meaningEn: 'The Ever-Forgiving', explanationEn: 'Repeatedly conceals faults and forgives servants who turn back in repentance.'),
  AsmaulHusnaItem(15, 'الْقَهَّارُ', 'Al-Qahhar', 'Yang Maha Menundukkan', 'Menundukkan seluruh makhluk di bawah ketetapan dan kekuasaan-Nya.', meaningEn: 'The All-Prevailing', explanationEn: 'Holds all of creation subdued beneath His decree and absolute dominion.'),
  AsmaulHusnaItem(16, 'الْوَهَّابُ', 'Al-Wahhab', 'Yang Maha Pemberi Karunia', 'Memberi anugerah tanpa pamrih dan tanpa mengharap imbalan.', meaningEn: 'The Supreme Bestower', explanationEn: 'Gives generously and continuously without expecting anything in return.'),
  AsmaulHusnaItem(17, 'الرَّزَّاقُ', 'Ar-Razzaq', 'Yang Maha Pemberi Rezeki', 'Menjamin dan mengalirkan rezeki lahir maupun batin bagi setiap makhluk.', meaningEn: 'The Provider', explanationEn: 'Guarantees and sustains both material and spiritual provision for every living being.'),
  AsmaulHusnaItem(18, 'الْفَتَّاحُ', 'Al-Fattah', 'Yang Maha Pembuka Rahmat', 'Membukakan pintu rahmat, jalan keluar, ilmu, dan keputusan yang adil.', meaningEn: 'The Opener & Judge', explanationEn: 'Opens doors of mercy, relief, knowledge, and just resolution.'),
  AsmaulHusnaItem(19, 'الْعَلِيمُ', 'Al-\'Alim', 'Yang Maha Mengetahui', 'Mengetahui segala yang tampak maupun tersembunyi di langit dan bumi.', meaningEn: 'The All-Knowing', explanationEn: 'Knows everything seen and unseen throughout the heavens and the earth.'),
  AsmaulHusnaItem(20, 'الْقَابِضُ', 'Al-Qabidh', 'Yang Maha Menyempitkan', 'Menahan atau menyempitkan rezeki dan mencabut nyawa sesuai hikmah-Nya.', meaningEn: 'The Withholder', explanationEn: 'Restricts provision and takes souls in accordance with His perfect wisdom.'),
  AsmaulHusnaItem(21, 'الْبَاسِطُ', 'Al-Basith', 'Yang Maha Melapangkan', 'Meluaskan rezeki, rahmat, dan kelapangan dada bagi hamba-Nya.', meaningEn: 'The Expander', explanationEn: 'Expands sustenance, mercy, and peace of heart for His servants.'),
  AsmaulHusnaItem(22, 'الْخَافِضُ', 'Al-Khafidh', 'Yang Maha Merendahkan', 'Merendahkan derajat orang-orang yang sombong dan durhaka.', meaningEn: 'The Abaser', explanationEn: 'Humbles and lowers the status of the arrogant and rebellious.'),
  AsmaulHusnaItem(23, 'الرَّافِعُ', 'Ar-Rafi\'', 'Yang Maha Meninggikan', 'Mengangkat derajat orang-orang yang beriman dan berilmu.', meaningEn: 'The Exalter', explanationEn: 'Elevates the rank and honor of those with faith and knowledge.'),
  AsmaulHusnaItem(24, 'الْمُعِزُّ', 'Al-Mu\'izz', 'Yang Maha Memuliakan', 'Menganugerahkan kemuliaan sejati kepada siapa yang Dia kehendaki.', meaningEn: 'The Bestower of Honor', explanationEn: 'Grants true dignity and honor to whomever He wills.'),
  AsmaulHusnaItem(25, 'الْمُذِلُّ', 'Al-Mudzill', 'Yang Maha Menghinakan', 'Menghinakan siapa saja yang menentang kebenaran dan keadilan-Nya.', meaningEn: 'The Humiliator', explanationEn: 'Brings low whoever opposes His truth and justice.'),
  AsmaulHusnaItem(26, 'السَّمِيعُ', 'As-Sami\'', 'Yang Maha Mendengar', 'Mendengar setiap doa, rintihan, dan bisikan paling lirih sekalipun.', meaningEn: 'The All-Hearing', explanationEn: 'Hears every prayer, plea, and even the faintest whisper of the heart.'),
  AsmaulHusnaItem(27, 'الْبَصِيرُ', 'Al-Bashir', 'Yang Maha Melihat', 'Melihat setiap gerak-gerik dan amal perbuatan makhluk tanpa terhalang.', meaningEn: 'The All-Seeing', explanationEn: 'Sees every movement and deed of creation without veil or obstacle.'),
  AsmaulHusnaItem(28, 'الْحَكَمُ', 'Al-Hakam', 'Yang Maha Menetapkan Hukum', 'Pembuat ketetapan dan pengadil tertinggi yang tidak pernah keliru.', meaningEn: 'The Impartial Judge', explanationEn: 'The supreme arbiter whose decrees and judgments never err.'),
  AsmaulHusnaItem(29, 'الْعَدْلُ', 'Al-\'Adl', 'Yang Mahaadil', 'Menempatkan segala sesuatu secara adil tanpa menzalimi sedikit pun.', meaningEn: 'The Utterly Just', explanationEn: 'Places everything in its rightful measure with zero injustice.'),
  AsmaulHusnaItem(30, 'اللَّطِيفُ', 'Al-Lathif', 'Yang Mahalembut', 'Menyantuni hamba-Nya dengan kelembutan dan cara yang halus tak terduga.', meaningEn: 'The Subtle & Kind', explanationEn: 'Cares for His servants with gentle grace and unseen kindness.'),
  AsmaulHusnaItem(31, 'الْخَبِيرُ', 'Al-Khabir', 'Yang Mahateliti', 'Mengetahui hakikat terdalam dan rahasia batin segala sesuatu.', meaningEn: 'The All-Aware', explanationEn: 'Knows the innermost realities and hidden subtleties of all things.'),
  AsmaulHusnaItem(32, 'الْحَلِيمُ', 'Al-Halim', 'Yang Maha Penyantun', 'Tidak tergesa-gesa menghukum hamba yang berdosa dan memberi waktu bertaubat.', meaningEn: 'The Most Forbearing', explanationEn: 'Never hastens punishment upon sinners and grants ample time to repent.'),
  AsmaulHusnaItem(33, 'الْعَظِيمُ', 'Al-\'Azhim', 'Yang Mahaagung', 'Memiliki keagungan zat dan sifat yang tidak terjangkau akal manusia.', meaningEn: 'The Magnificent', explanationEn: 'Possesses a grandeur of essence and attributes beyond human comprehension.'),
  AsmaulHusnaItem(34, 'الْغَفُورُ', 'Al-Ghafur', 'Yang Maha Pengampun', 'Mengampuni dosa-dosa besar maupun kecil bagi yang memohon ampunan.', meaningEn: 'The Great Forgiver', explanationEn: 'Forgives major and minor sins alike for everyone who seeks His pardon.'),
  AsmaulHusnaItem(35, 'الشَّكُورُ', 'Asy-Syakur', 'Yang Maha Menghargai Syukur', 'Membalas amal yang sedikit dengan pahala yang berlipat ganda.', meaningEn: 'The Most Appreciative', explanationEn: 'Rewards even small sincere deeds with multiplied, abundant grace.'),
  AsmaulHusnaItem(36, 'الْعَلِيُّ', 'Al-\'Aliyy', 'Yang Mahatinggi', 'Mahatinggi kedudukan, kekuasaan, dan kemuliaan-Nya di atas segalanya.', meaningEn: 'The Most High', explanationEn: 'Supremely exalted in rank, authority, and majesty above all things.'),
  AsmaulHusnaItem(37, 'الْكَبِيرُ', 'Al-Kabir', 'Yang Mahabesar', 'Segala sesuatu selain-Nya kecil di hadapan kebesaran Allah.', meaningEn: 'The Most Great', explanationEn: 'Everything besides Him is small beside His infinite greatness.'),
  AsmaulHusnaItem(38, 'الْحَفِيظُ', 'Al-Hafizh', 'Yang Maha Memelihara', 'Menjaga langit, bumi, dan hamba-Nya serta mencatat seluruh amal.', meaningEn: 'The Preserver', explanationEn: 'Protects the heavens, the earth, and His servants while preserving every deed.'),
  AsmaulHusnaItem(39, 'الْمُقِيتُ', 'Al-Muqit', 'Yang Maha Pemberi Kecukupan', 'Menyediakan kecukupan makanan dan kekuatan bagi setiap makhluk.', meaningEn: 'The Sustainer', explanationEn: 'Supplies nourishment and strength sufficient for every living creature.'),
  AsmaulHusnaItem(40, 'الْحَسِيبُ', 'Al-Hasib', 'Yang Maha Membuat Perhitungan', 'Mencukupi siapa yang bertawakal kepada-Nya dan memperhitungkan amal dengan teliti.', meaningEn: 'The Reckoner & Sufficer', explanationEn: 'Sufficient for all who rely on Him and exact in reckoning every deed.'),
  AsmaulHusnaItem(41, 'الْجَلِيلُ', 'Al-Jalil', 'Yang Mahamulia & Luhur', 'Pemilik sifat-sifat keagungan, kemuliaan, dan kesempurnaan.', meaningEn: 'The Majestic', explanationEn: 'Possessor of every attribute of awe, nobility, and perfection.'),
  AsmaulHusnaItem(42, 'الْكَرِيمُ', 'Al-Karim', 'Yang Maha Pemurah', 'Maha Dermawan yang memberi sebelum diminta dan memaafkan saat mampu menghukum.', meaningEn: 'The Most Generous', explanationEn: 'Gives freely even before being asked and pardons while holding full power.'),
  AsmaulHusnaItem(43, 'الرَّقِيبُ', 'Ar-Raqib', 'Yang Maha Mengawasi', 'Tidak pernah lengah mengawasi setiap lintasan hati dan perbuatan.', meaningEn: 'The Watchful', explanationEn: 'Never unmindful, observing every passing thought and outward action.'),
  AsmaulHusnaItem(44, 'الْمُجِيبُ', 'Al-Mujib', 'Yang Maha Mengabulkan', 'Menjawab doa dan permohonan hamba yang berseru kepada-Nya.', meaningEn: 'The Responsive', explanationEn: 'Answers the prayers and calls of every servant who turns to Him.'),
  AsmaulHusnaItem(45, 'الْوَاسِعُ', 'Al-Wasi\'', 'Yang Mahaluas', 'Ilmu, rahmat, dan karunia-Nya meliputi segala sesuatu.', meaningEn: 'The All-Encompassing', explanationEn: 'His knowledge, mercy, and bounty encompass all existence without limit.'),
  AsmaulHusnaItem(46, 'الْحَكِيمُ', 'Al-Hakim', 'Yang Mahabijaksana', 'Setiap ciptaan dan takdir-Nya penuh hikmah serta tepat pada tempatnya.', meaningEn: 'The All-Wise', explanationEn: 'Every creation and decree reflects flawless wisdom placed exactly right.'),
  AsmaulHusnaItem(47, 'الْوَدُودُ', 'Al-Wadud', 'Yang Maha Mengasihi & Mencintai', 'Mencintai hamba-hamba-Nya yang taat dan bertaubat serta dicintai oleh mereka.', meaningEn: 'The Most Loving', explanationEn: 'Deeply loves His obedient, repentant servants and is beloved by them.'),
  AsmaulHusnaItem(48, 'الْمَجِيدُ', 'Al-Majid', 'Yang Mahamulia', 'Mulia dalam zat-Nya dan indah dalam segala perbuatan serta pemberian-Nya.', meaningEn: 'The Most Glorious', explanationEn: 'Glorious in His essence and noble in every act and gift.'),
  AsmaulHusnaItem(49, 'الْبَاعِثُ', 'Al-Ba\'its', 'Yang Maha Membangkitkan', 'Membangkitkan manusia dari kubur pada hari Kiamat dan mengutus para rasul.', meaningEn: 'The Resurrector', explanationEn: 'Raises humanity from the graves on the Day of Judgment and sends messengers.'),
  AsmaulHusnaItem(50, 'الشَّهِيدُ', 'Asy-Syahid', 'Yang Maha Menyaksikan', 'Menyaksikan secara langsung segala peristiwa tanpa ada yang luput.', meaningEn: 'The Universal Witness', explanationEn: 'Directly witnesses every event across creation with nothing ever missed.'),
  AsmaulHusnaItem(51, 'الْحَقُّ', 'Al-Haqq', 'Yang Mahabenar', 'Kebenaran mutlak dalam zat, firman, janji, dan perjumpaan dengan-Nya.', meaningEn: 'The Absolute Truth', explanationEn: 'Absolute reality and truth in His being, word, promise, and meeting.'),
  AsmaulHusnaItem(52, 'الْوَكِيلُ', 'Al-Wakil', 'Yang Maha Memelihara Urusan', 'Tempat bersandar terbaik yang mengurus segala keperluan hamba yang bertawakal.', meaningEn: 'The Ultimate Trustee', explanationEn: 'The best disposer of affairs for every servant who entrusts their matters to Him.'),
  AsmaulHusnaItem(53, 'الْقَوِيُّ', 'Al-Qawiyy', 'Yang Mahakuat', 'Memiliki kekuatan sempurna yang tidak pernah disentuh kelemahan.', meaningEn: 'The All-Strong', explanationEn: 'Possesses complete strength untouched by fatigue or weakness.'),
  AsmaulHusnaItem(54, 'الْمَتِينُ', 'Al-Matin', 'Yang Mahakokoh', 'Sangat kukuh kekuasaan-Nya tanpa membutuhkan bantuan siapa pun.', meaningEn: 'The Firm & Steadfast', explanationEn: 'Unshakable in power and resolve, in need of no helper.'),
  AsmaulHusnaItem(55, 'الْوَلِيُّ', 'Al-Waliyy', 'Yang Maha Melindungi', 'Penolong dan pelindung setia bagi orang-orang yang beriman.', meaningEn: 'The Protecting Ally', explanationEn: 'The faithful guardian, helper, and close supporter of the believers.'),
  AsmaulHusnaItem(56, 'الْحَمِيدُ', 'Al-Hamid', 'Yang Maha Terpuji', 'Terpuji dalam setiap nikmat, syariat, dan ketetapan takdir-Nya.', meaningEn: 'The Praiseworthy', explanationEn: 'Worthy of all praise in every blessing, guidance, and decree.'),
  AsmaulHusnaItem(57, 'الْمُحْصِي', 'Al-Muhshi', 'Yang Maha Menghitung', 'Menghitung setiap makhluk, napas, dan butiran amal secara eksak.', meaningEn: 'The Accounter', explanationEn: 'Enumerates every creature, breath, and atom of action with exactness.'),
  AsmaulHusnaItem(58, 'الْمُبْدِئُ', 'Al-Mubdi\'', 'Yang Maha Memulai', 'Memulai penciptaan segala sesuatu dari awal tanpa contoh sebelumnya.', meaningEn: 'The Originator', explanationEn: 'Initiates all creation from the very beginning with no prior model.'),
  AsmaulHusnaItem(59, 'الْمُعِيدُ', 'Al-Mu\'id', 'Yang Maha Mengembalikan Kehidupan', 'Mengembalikan makhluk hidup setelah mati pada hari kebangkitan.', meaningEn: 'The Restorer', explanationEn: 'Restores creation back to life after death on the Day of Resurrection.'),
  AsmaulHusnaItem(60, 'الْمُحْيِي', 'Al-Muhyi', 'Yang Maha Menghidupkan', 'Meniupkan kehidupan pada jasad dan menghidupkan hati dengan iman.', meaningEn: 'The Giver of Life', explanationEn: 'Breaths life into bodies and revives dead hearts with faith.'),
  AsmaulHusnaItem(61, 'الْمُمِيتُ', 'Al-Mumit', 'Yang Maha Mematikan', 'Menetapkan ajal dan kematian bagi setiap makhluk yang bernyawa.', meaningEn: 'The Creator of Death', explanationEn: 'Decrees the appointed term and passing of every living soul.'),
  AsmaulHusnaItem(62, 'الْحَيُّ', 'Al-Hayyu', 'Yang Mahahidup', 'Hidup kekal abadi tanpa awal dan tanpa akhir.', meaningEn: 'The Ever-Living', explanationEn: 'Eternally alive with neither beginning nor end.'),
  AsmaulHusnaItem(63, 'الْقَيُّومُ', 'Al-Qayyum', 'Yang Maha Mandiri', 'Berdiri sendiri dan menegakkan seluruh urusan langit serta bumi.', meaningEn: 'The Self-Subsisting', explanationEn: 'Stands entirely independent while sustaining all the heavens and the earth.'),
  AsmaulHusnaItem(64, 'الْوَاجِدُ', 'Al-Wajid', 'Yang Maha Penemu & Kaya', 'Memiliki segala sesuatu dan tidak pernah kekurangan apa pun.', meaningEn: 'The Perceiver & Self-Sufficient', explanationEn: 'Lacks nothing and possesses everything in complete perfection.'),
  AsmaulHusnaItem(65, 'الْمَاجِدُ', 'Al-Majid', 'Yang Mahamulia & Agung', 'Memiliki kemuliaan yang sempurna dan kedermawanan yang luas.', meaningEn: 'The Illustrious & Noble', explanationEn: 'Endowed with consummate honor and boundless generosity.'),
  AsmaulHusnaItem(66, 'الْوَاحِدُ', 'Al-Wahid', 'Yang Maha Tunggal', 'Tunggal dalam zat, sifat, dan hak untuk disembah.', meaningEn: 'The One', explanationEn: 'Unique and singular in His essence, attributes, and right to worship.'),
  AsmaulHusnaItem(67, 'الْأَحَدُ', 'Al-Ahad', 'Yang Maha Esa', 'Maha Esa secara mutlak, tidak terbagi dan tiada sekutu bagi-Nya.', meaningEn: 'The Indivisible One', explanationEn: 'Absolutely One, indivisible, with no partner or peer.'),
  AsmaulHusnaItem(68, 'الصَّمَدُ', 'Ash-Shamad', 'Yang Maha Dibutuhkan', 'Tempat bergantung dan memohon segala makhluk dalam setiap hajat.', meaningEn: 'The Eternal Refuge', explanationEn: 'The One upon whom all creation depends for every need.'),
  AsmaulHusnaItem(69, 'الْقَادِرُ', 'Al-Qadir', 'Yang Mahakuasa', 'Mampu mewujudkan apa saja yang dikehendaki-Nya tanpa kesulitan.', meaningEn: 'The All-Capable', explanationEn: 'Able to bring about anything He wills without effort or difficulty.'),
  AsmaulHusnaItem(70, 'الْمُقْتَدِرُ', 'Al-Muqtadir', 'Yang Maha Berkuasa Penuh', 'Menampakkan kekuasaan-Nya yang sempurna atas seluruh ciptaan.', meaningEn: 'The Omnipotent', explanationEn: 'Exercises full, unhindered power over every single creation.'),
  AsmaulHusnaItem(71, 'الْمُقَدِّمُ', 'Al-Muqaddim', 'Yang Maha Mendahulukan', 'Mendahulukan siapa dan apa saja sesuai hikmah serta kehendak-Nya.', meaningEn: 'The Expediter', explanationEn: 'Brings forward whomever and whatever He chooses in perfect wisdom.'),
  AsmaulHusnaItem(72, 'الْمُؤَخِّرُ', 'Al-Mu\'akhkhir', 'Yang Maha Mengakhirkan', 'Menunda atau mengakhirkan sesuatu tepat pada waktu yang terbaik.', meaningEn: 'The Delayer', explanationEn: 'Holds back or defers matters until their wisest appointed time.'),
  AsmaulHusnaItem(73, 'الْأَوَّلُ', 'Al-Awwal', 'Yang Mahaawal', 'Ada sebelum segala sesuatu ada, tanpa permulaan.', meaningEn: 'The First', explanationEn: 'Existed before everything else came to be, without any beginning.'),
  AsmaulHusnaItem(74, 'الْآخِرُ', 'Al-Akhir', 'Yang Mahaakhir', 'Tetap kekal setelah seluruh makhluk binasa, tanpa kesudahan.', meaningEn: 'The Last', explanationEn: 'Remains eternally after all creation passes away, without any end.'),
  AsmaulHusnaItem(75, 'الظَّاهِرُ', 'Azh-Zhahir', 'Yang Mahanyata', 'Nyata tanda-tanda keberadaan dan kekuasaan-Nya di seluruh penjuru alam.', meaningEn: 'The Manifest', explanationEn: 'His signs of existence and power are unmistakably evident throughout the cosmos.'),
  AsmaulHusnaItem(76, 'الْبَاطِنُ', 'Al-Bathin', 'Yang Maha Ghaib', 'Tidak dapat dijangkau hakikat zat-Nya oleh penglihatan mata di dunia.', meaningEn: 'The Hidden', explanationEn: 'His essence lies beyond mortal sight, yet He is intimately close to all.'),
  AsmaulHusnaItem(77, 'الْوَالِي', 'Al-Wali', 'Yang Maha Memerintah', 'Mengatur dan mengendalikan seluruh kejadian di alam semesta.', meaningEn: 'The Sole Governor', explanationEn: 'Directs, manages, and oversees every event across the universe.'),
  AsmaulHusnaItem(78, 'الْمُتَعَالِي', 'Al-Muta\'ali', 'Yang Mahatinggi', 'Mahatinggi dari segala tuduhan dan sifat yang tidak layak bagi-Nya.', meaningEn: 'The Self-Exalted', explanationEn: 'Supremely above every attribute or description unworthy of Him.'),
  AsmaulHusnaItem(79, 'الْبَرُّ', 'Al-Barr', 'Yang Maha Penderma & Baik', 'Berbuat baik, menepati janji, dan melimpahkan kebajikan kepada hamba-Nya.', meaningEn: 'The Source of All Goodness', explanationEn: 'Kind, faithful to His promises, and abundant in benevolence toward His servants.'),
  AsmaulHusnaItem(80, 'التَّوَّابُ', 'At-Tawwab', 'Yang Maha Penerima Taubat', 'Membuka pintu taubat dan menerima kembalinya hamba yang menyesali dosa.', meaningEn: 'The Accepter of Repentance', explanationEn: 'Opens the door of return and warmly accepts every sincerely repentant servant.'),
  AsmaulHusnaItem(81, 'الْمُنْتَقِمُ', 'Al-Muntaqim', 'Yang Maha Pemberi Balasan', 'Menjatuhkan balasan yang adil kepada para pelaku kezaliman yang membangkang.', meaningEn: 'The Avenger of Wrongdoing', explanationEn: 'Metes out just retribution upon persistent oppressors and wrongdoers.'),
  AsmaulHusnaItem(82, 'الْعَفُوُّ', 'Al-\'Afuww', 'Yang Maha Pemaaf', 'Menghapus jejak dosa dan memaafkan kesalahan hamba hingga bersih.', meaningEn: 'The Effacer of Sins', explanationEn: 'Erases sins completely and pardons servants until no trace remains.'),
  AsmaulHusnaItem(83, 'الرَّءُوفُ', 'Ar-Ra\'uf', 'Yang Maha Pengasih & Belas Kasih', 'Memiliki kasih sayang yang sangat mendalam dan lembut kepada hamba-Nya.', meaningEn: 'The Most Tenderly Compassionate', explanationEn: 'Shows profound tenderness, clemency, and gentle compassion to His servants.'),
  AsmaulHusnaItem(84, 'مَالِكُ الْمُلْكِ', 'Malikul-Mulk', 'Penguasa Kerajaan Semesta', 'Memberikan dan mencabut kekuasaan dunia kepada siapa yang dikehendaki-Nya.', meaningEn: 'Owner of All Sovereignty', explanationEn: 'Grants earthly rule and withdraws it according to His supreme will.'),
  AsmaulHusnaItem(85, 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'Dzul-Jalali wal-Ikram', 'Pemilik Keagungan & Kemuliaan', 'Berhak diagungkan dan selalu memuliakan hamba-hamba-Nya yang ikhlas.', meaningEn: 'Lord of Majesty & Honor', explanationEn: 'Worthy of utmost reverence and ever generous in honoring sincere believers.'),
  AsmaulHusnaItem(86, 'الْمُقْسِطُ', 'Al-Muqsith', 'Yang Maha Pemberi Keadilan', 'Menegakkan keadilan dan memenangkan pihak yang terzalimi.', meaningEn: 'The Equitable', explanationEn: 'Upholds perfect equity and grants justice to the oppressed.'),
  AsmaulHusnaItem(87, 'الْجَامِعُ', 'Al-Jami\'', 'Yang Maha Mengumpulkan', 'Mengumpulkan seluruh manusia pada hari Kiamat dan menyatukan hati orang beriman.', meaningEn: 'The Gatherer', explanationEn: 'Gathers all humanity on the Day of Judgment and unites believing hearts.'),
  AsmaulHusnaItem(88, 'الْغَنِيُّ', 'Al-Ghaniyy', 'Yang Mahakaya', 'Mahakaya dan sama sekali tidak membutuhkan ibadah maupun makhluk-Nya.', meaningEn: 'The Completely Self-Sufficient', explanationEn: 'Rich beyond measure and utterly free of need from His creation.'),
  AsmaulHusnaItem(89, 'الْمُغْنِي', 'Al-Mughni', 'Yang Maha Memberi Kekayaan', 'Mencukupkan dan memperkaya hati serta kehidupan siapa yang Dia kehendaki.', meaningEn: 'The Enricher', explanationEn: 'Grants contentment, sufficiency, and richness of heart to whomever He wills.'),
  AsmaulHusnaItem(90, 'الْمَانِعُ', 'Al-Mani\'', 'Yang Maha Mencegah', 'Mencegah mudarat atau menahan sesuatu demi kebaikan dan perlindungan hamba.', meaningEn: 'The Preventer of Harm', explanationEn: 'Wards off harm and withholds things out of wisdom to protect His servants.'),
  AsmaulHusnaItem(91, 'الضَّارُّ', 'Adh-Dharr', 'Yang Maha Menimpakan Kemudaratan', 'Menetapkan ujian atau kesulitan sebagai peringatan dan hikmah bagi manusia.', meaningEn: 'The Decrier of Trials', explanationEn: 'Permits hardship or trials as a reminder, test, and hidden wisdom for humanity.'),
  AsmaulHusnaItem(92, 'النَّافِعُ', 'An-Nafi\'', 'Yang Maha Memberi Manfaat', 'Satu-satunya pemberi manfaat hakiki dalam obat, ilmu, dan ikhtiar.', meaningEn: 'The Creator of Benefit', explanationEn: 'The sole true giver of benefit behind every remedy, skill, and effort.'),
  AsmaulHusnaItem(93, 'النُّورُ', 'An-Nur', 'Yang Maha Bercahaya', 'Cahaya langit dan bumi yang menerangi hati orang-orang beriman dengan petunjuk.', meaningEn: 'The Light', explanationEn: 'The Light of the heavens and earth who illuminates believing hearts with guidance.'),
  AsmaulHusnaItem(94, 'الْهَادِي', 'Al-Hadi', 'Yang Maha Pemberi Petunjuk', 'Membimbing makhluk-Nya mengenal jalan keselamatan dan kebenaran.', meaningEn: 'The Guide', explanationEn: 'Directs creation toward the path of truth, peace, and salvation.'),
  AsmaulHusnaItem(95, 'الْبَدِيعُ', 'Al-Badi\'', 'Yang Maha Pencipta Tanpa Contoh', 'Menciptakan keindahan semesta yang menakjubkan tanpa ada yang mendahului.', meaningEn: 'The Incomparable Originator', explanationEn: 'Creates the breathtaking beauty of the universe with no precedent whatsoever.'),
  AsmaulHusnaItem(96, 'الْبَاقِي', 'Al-Baqi', 'Yang Mahakekal', 'Tetap abadi selama-lamanya tanpa pernah mengalami kebinasaan.', meaningEn: 'The Everlasting', explanationEn: 'Endures forever without ever fading or perishing.'),
  AsmaulHusnaItem(97, 'الْوَارِثُ', 'Al-Warits', 'Yang Maha Pewaris', 'Kembali kepada-Nya seluruh kepemilikan setelah semua makhluk tiada.', meaningEn: 'The Supreme Inheritor', explanationEn: 'To Him returns all ownership after every mortal owner has passed.'),
  AsmaulHusnaItem(98, 'الرَّشِيدُ', 'Ar-Rasyid', 'Yang Maha Pandai & Tepat', 'Membimbing segala urusan menuju tujuan yang paling benar dan lurus.', meaningEn: 'The Guide to the Right Path', explanationEn: 'Guides all affairs unerringly toward their wisest and soundest outcome.'),
  AsmaulHusnaItem(99, 'الصَّبُورُ', 'Ash-Shabur', 'Yang Mahasabar', 'Tidak tergesa-gesa menyiksa pendosa dan memberi kesempatan luas untuk kembali.', meaningEn: 'The Most Patient', explanationEn: 'Does not rush to punish wrongdoers, granting wide opportunity to return to Him.'),
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
