import '../sirah_library.dart';

/// Sirah Nabawiyah: perjalanan hidup Rasulullah SAW secara berurutan.
///
/// Format `narrative`: paragraf dipisah baris kosong; baris berawalan `## ` adalah subjudul.
/// Tanggal & angka mengikuti riwayat masyhur dalam kitab sirah yang dirujuk; bila ulama
/// berbeda pendapat, perbedaannya disebutkan.
const List<SirahChapter> sirahNabawiyahChapters = [
  SirahChapter(
    id: 'sirah_01_jazirah_arab',
    section: SirahSection.sirahNabawiyah,
    order: 1,
    title: 'Jazirah Arab Sebelum Islam & Nasab Rasulullah SAW',
    periodOrTitle: 'Latar Belakang (sebelum 571 M)',
    narrative: '''## Keadaan Jazirah Arab
Sebelum Islam datang, sebagian besar penduduk Jazirah Arab hidup dalam suku-suku yang saling bersaing. Ka'bah yang dibangun Nabi Ibrahim AS dan Nabi Isma'il AS untuk menyembah Allah Yang Maha Esa sudah dipenuhi berhala. Masa ini disebut masa jahiliyah: banyak orang menyembah patung, minum khamar, berjudi, dan sebagian kabilah mengubur anak perempuan hidup-hidup karena malu atau takut miskin (QS. An-Nahl: 58-59, QS. At-Takwir: 8-9).

Meski begitu, masih ada sisa-sisa ajaran Nabi Ibrahim AS. Ada orang-orang yang disebut hanif, yang menolak berhala dan mencari agama yang lurus, seperti Zaid bin 'Amr bin Nufail. Orang Arab juga menjunjung kemuliaan menjamu tamu, menepati janji, dan keberanian.

## Makkah dan Suku Quraisy
Makkah berada di lembah tandus, tetapi menjadi pusat ziarah karena Ka'bah. Suku Quraisy mengurus Ka'bah, memberi minum dan makan para peziarah, dan menjalankan dua perjalanan dagang besar: ke Yaman pada musim dingin dan ke Syam pada musim panas (QS. Quraisy: 1-4).

## Nasab yang Mulia
Rasulullah SAW adalah Muhammad bin Abdullah bin Abdul Muthalib bin Hasyim bin Abdu Manaf dari suku Quraisy. Nasab beliau bersambung kepada 'Adnan, keturunan Nabi Isma'il AS putra Nabi Ibrahim AS. Kakek beliau, Abdul Muthalib, adalah pemuka Quraisy yang menggali kembali sumur Zamzam.

Rasulullah SAW bersabda bahwa Allah memilih Kinanah dari keturunan Isma'il, memilih Quraisy dari Kinanah, memilih Bani Hasyim dari Quraisy, dan memilih beliau dari Bani Hasyim (HR. Muslim).''',
    hikmah:
        'Allah menyiapkan Rasul-Nya dari keturunan yang terjaga dan menurunkan petunjuk tepat ketika manusia paling membutuhkannya.',
    reference: 'HR. Muslim no. 2276 · Sirah Ibnu Hisyam · Ar-Rahiqul Makhtum (Al-Mubarakfuri)',
  ),
  SirahChapter(
    id: 'sirah_02_kelahiran',
    section: SirahSection.sirahNabawiyah,
    order: 2,
    title: 'Tahun Gajah & Kelahiran Rasulullah SAW',
    periodOrTitle: 'Tahun Gajah (sekitar 571 M)',
    narrative: '''## Peristiwa Tahun Gajah
Abrahah, penguasa Yaman, membangun gereja besar di Shan'a dan ingin mengalihkan peziarah dari Ka'bah. Ia berangkat ke Makkah dengan pasukan bergajah untuk menghancurkan Ka'bah. Abdul Muthalib berkata kepada Abrahah bahwa ia hanya pemilik unta-untanya, sedangkan Ka'bah memiliki Pemilik yang akan menjaganya.

Allah mengirim burung-burung yang berbondong-bondong melempari pasukan itu dengan batu dari tanah yang terbakar, hingga mereka hancur seperti daun yang dimakan ulat (QS. Al-Fil: 1-5).

## Kelahiran
Pada tahun itu juga Rasulullah SAW lahir di Makkah pada hari Senin. Menurut pendapat yang masyhur, beliau lahir tanggal 12 Rabi'ul Awwal; sebagian ulama berpendapat tanggal 9 atau tanggal lainnya. Hari Senin sebagai hari kelahiran beliau disebutkan sendiri oleh Rasulullah SAW ketika ditanya tentang puasa hari Senin (HR. Muslim).

Ayah beliau, Abdullah, wafat ketika beliau masih dalam kandungan. Ibunda beliau, Aminah binti Wahb, melahirkan beliau dan kakeknya, Abdul Muthalib, memberinya nama Muhammad, yang berarti orang yang terpuji.

## Disusui di Bani Sa'd
Sesuai kebiasaan bangsawan Makkah, bayi disusukan di pedalaman agar tumbuh sehat dan fasih berbahasa Arab. Beliau disusui oleh Halimah As-Sa'diyah dari Bani Sa'd. Halimah menceritakan bahwa keluarganya mendapat keberkahan besar sejak mengasuh beliau: susu dan ternak mereka bertambah.

Ketika beliau tinggal di Bani Sa'd, terjadi peristiwa pembelahan dada: Malaikat Jibril membelah dada beliau, mengeluarkan bagian yang merupakan bagian setan, lalu mencucinya dengan air Zamzam (HR. Muslim).

## Menjadi Yatim Piatu
Pada usia sekitar enam tahun, ibunda beliau wafat di Abwa' dalam perjalanan pulang dari Madinah. Beliau kemudian diasuh kakeknya, Abdul Muthalib, yang sangat menyayanginya. Dua tahun kemudian Abdul Muthalib wafat, dan beliau diasuh pamannya, Abu Thalib.''',
    hikmah:
        'Allah sendiri yang mendidik Rasul-Nya melalui ujian menjadi yatim, sehingga beliau paling memahami perasaan anak yatim dan orang yang lemah (QS. Adh-Dhuha: 6).',
    reference: 'QS. Al-Fil · QS. Adh-Dhuha: 6 · HR. Muslim no. 1162 & 162 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_03_masa_muda',
    section: SirahSection.sirahNabawiyah,
    order: 3,
    title: 'Masa Muda: Penggembala, Pedagang & Al-Amin',
    periodOrTitle: 'Masa Remaja dan Dewasa (sekitar 579-595 M)',
    narrative: '''## Menggembala Kambing
Sejak kecil Rasulullah SAW terbiasa bekerja. Beliau menggembala kambing milik penduduk Makkah dengan upah beberapa qirath. Beliau bersabda bahwa tidak ada seorang nabi pun kecuali pernah menggembala kambing (HR. Bukhari). Menggembala melatih kesabaran, kasih sayang, dan kepemimpinan.

## Perjalanan ke Syam
Ketika masih remaja, beliau ikut pamannya, Abu Thalib, berdagang ke Syam. Kitab-kitab sirah meriwayatkan bahwa di Bushra seorang rahib bernama Bahira melihat tanda-tanda kenabian pada diri beliau dan menasihati Abu Thalib agar menjaga keponakannya. Riwayat ini dicantumkan oleh At-Tirmidzi; sebagian ahli hadits membahas beberapa rincian redaksinya.

## Harbul Fijar dan Hilful Fudhul
Pada masa muda beliau terjadi Perang Fijar antara Quraisy dan Qais 'Ailan. Beliau ikut membantu pamannya dengan mengumpulkan anak panah.

Setelah itu beberapa kabilah Quraisy berkumpul di rumah Abdullah bin Jud'an dan berjanji membela setiap orang yang dizalimi di Makkah, baik penduduk asli maupun pendatang. Perjanjian ini disebut Hilful Fudhul. Setelah menjadi nabi, Rasulullah SAW berkata bahwa seandainya beliau diajak kepada perjanjian semacam itu di masa Islam, beliau akan memenuhinya.

## Gelar Al-Amin
Beliau dikenal jujur, menjaga diri dari berhala dan perbuatan jahiliyah, dan tidak pernah berdusta. Penduduk Makkah menjulukinya Al-Amin (orang yang terpercaya) dan menitipkan barang berharga kepadanya. Kepercayaan ini tetap mereka akui bahkan setelah mereka memusuhi dakwah beliau.''',
    hikmah:
        'Kejujuran dan kerja keras sejak muda membangun kepercayaan masyarakat, dan kepercayaan itulah modal utama seorang pendakwah.',
    reference: 'HR. Bukhari no. 2262 · Sunan At-Tirmidzi no. 3620 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_04_khadijah_hajar_aswad',
    section: SirahSection.sirahNabawiyah,
    order: 4,
    title: 'Pernikahan dengan Khadijah & Peletakan Hajar Aswad',
    periodOrTitle: 'Usia 25 sampai 35 Tahun',
    narrative: '''## Berdagang untuk Khadijah
Khadijah binti Khuwailid adalah perempuan Quraisy yang terhormat dan kaya. Ia mempekerjakan orang untuk membawa barang dagangannya. Mendengar kejujuran Muhammad, ia meminta beliau membawa dagangannya ke Syam bersama pembantunya, Maisarah. Perdagangan itu menghasilkan keuntungan besar, dan Maisarah menceritakan akhlak beliau yang mulia selama perjalanan.

## Pernikahan
Khadijah tertarik dengan akhlak beliau dan menyampaikan keinginannya untuk menikah. Pernikahan pun berlangsung. Menurut riwayat yang masyhur, Rasulullah SAW saat itu berusia 25 tahun dan Khadijah 40 tahun; sebagian riwayat menyebut usia Khadijah lebih muda.

Dari pernikahan ini lahir putra-putri beliau: Al-Qasim, Zainab, Ruqayyah, Ummu Kultsum, Fathimah, dan Abdullah. Putra-putra beliau wafat ketika masih kecil. Selama Khadijah hidup, Rasulullah SAW tidak menikah dengan perempuan lain.

## Renovasi Ka'bah dan Hajar Aswad
Ketika beliau berusia sekitar 35 tahun, banjir merusak Ka'bah dan Quraisy membangunnya kembali. Setiap kabilah ikut mengerjakan satu bagian. Saat tiba waktu meletakkan Hajar Aswad, mereka berselisih tentang siapa yang paling berhak, hingga hampir terjadi pertumpahan darah.

Mereka sepakat bahwa orang yang pertama masuk melalui pintu masjid akan menjadi penengah. Ternyata yang pertama masuk adalah Muhammad. Mereka berkata, "Ini Al-Amin, kami rela." Beliau meminta sehelai kain, meletakkan Hajar Aswad di tengahnya, lalu meminta pemimpin setiap kabilah memegang ujung kain dan mengangkatnya bersama. Setelah sampai di tempatnya, beliau sendiri yang meletakkan batu itu. Semua kabilah merasa terhormat dan perselisihan selesai.''',
    hikmah:
        'Kebijaksanaan menyatukan orang yang berselisih: solusi terbaik adalah yang membuat semua pihak ikut memikul tanggung jawab.',
    reference: 'Sirah Ibnu Hisyam · Al-Bidayah wan Nihayah (Ibnu Katsir) · Ar-Rahiqul Makhtum',
  ),
  SirahChapter(
    id: 'sirah_05_wahyu_pertama',
    section: SirahSection.sirahNabawiyah,
    order: 5,
    title: 'Turunnya Wahyu Pertama di Gua Hira',
    periodOrTitle: 'Usia 40 Tahun (610 M)',
    narrative: '''## Menyendiri di Gua Hira
Menjelang usia 40 tahun, Rasulullah SAW suka menyendiri (tahannuts) di Gua Hira, di Jabal Nur, beberapa malam berturut-turut. Beliau membawa bekal, merenungkan keadaan kaumnya, dan beribadah. Sebelum wahyu turun, beliau sering bermimpi dan mimpinya selalu menjadi kenyataan seperti terangnya waktu subuh.

## Iqra'
Pada bulan Ramadan, Malaikat Jibril datang dan berkata, "Bacalah!" Beliau menjawab, "Aku tidak bisa membaca." Jibril mendekapnya dengan kuat hingga beliau merasa sangat berat, lalu melepaskannya dan berkata lagi, "Bacalah!" Hal ini terjadi tiga kali. Kemudian Jibril membacakan ayat pertama: "Bacalah dengan nama Tuhanmu yang menciptakan. Dia telah menciptakan manusia dari segumpal darah. Bacalah, dan Tuhanmulah Yang Maha Mulia. Yang mengajar dengan pena. Dia mengajarkan manusia apa yang tidak diketahuinya" (QS. Al-'Alaq: 1-5).

## Khadijah Meneguhkan Hati
Rasulullah SAW pulang dengan hati bergetar dan berkata, "Selimutilah aku, selimutilah aku." Setelah tenang, beliau menceritakan apa yang terjadi dan berkata bahwa beliau khawatir terhadap dirinya. Khadijah menjawab, "Tidak, demi Allah, Allah tidak akan menghinakanmu selamanya. Engkau menyambung silaturahmi, menanggung orang yang lemah, membantu orang yang tidak punya, memuliakan tamu, dan menolong orang yang tertimpa musibah karena kebenaran."

## Waraqah bin Naufal
Khadijah membawa beliau kepada sepupunya, Waraqah bin Naufal, seorang yang memeluk agama Nasrani dan menulis Injil dalam bahasa Ibrani. Setelah mendengar cerita beliau, Waraqah berkata bahwa yang datang itu adalah Namus (Jibril) yang dahulu diutus kepada Musa. Ia berkata bahwa kaum beliau akan mengusirnya, sebab tidak ada seorang pun yang membawa ajaran seperti ini kecuali dimusuhi. Tidak lama kemudian Waraqah wafat.

## Jeda Wahyu dan Perintah Berdakwah
Setelah itu wahyu sempat terhenti beberapa waktu. Kemudian Jibril datang lagi dan turunlah ayat: "Wahai orang yang berselimut, bangunlah, lalu berilah peringatan" (QS. Al-Muddatstsir: 1-5). Sejak itu beliau mulai berdakwah.''',
    hikmah:
        'Wahyu pertama memerintahkan membaca dan belajar, dan dukungan keluarga yang tulus menjadi kekuatan besar di awal perjuangan.',
    reference: 'HR. Bukhari no. 3 & 4 · HR. Muslim no. 160 · QS. Al-\'Alaq: 1-5 · QS. Al-Muddatstsir: 1-5',
  ),
  SirahChapter(
    id: 'sirah_06_dakwah_sembunyi',
    section: SirahSection.sirahNabawiyah,
    order: 6,
    title: 'Dakwah Sembunyi-sembunyi & Assabiqunal Awwalun',
    periodOrTitle: 'Tiga Tahun Pertama Kenabian (610-613 M)',
    narrative: '''## Dimulai dari Orang Terdekat
Rasulullah SAW memulai dakwah secara diam-diam kepada keluarga dan sahabat yang paling beliau percaya. Orang-orang pertama yang beriman disebut Assabiqunal Awwalun. Di antara mereka:

• Khadijah binti Khuwailid RA, istri beliau, orang pertama yang beriman.
• Ali bin Abi Thalib RA, sepupu beliau yang masih anak-anak dan tinggal di rumah beliau.
• Zaid bin Haritsah RA, bekas budak yang beliau merdekakan dan beliau angkat sebagai anak.
• Abu Bakar Ash-Shiddiq RA, sahabat dekat beliau, orang dewasa merdeka pertama yang beriman.

## Dakwah Abu Bakar
Abu Bakar RA dikenal ramah dan dihormati. Melalui dakwahnya masuk Islam Utsman bin Affan, Az-Zubair bin Al-'Awwam, Abdurrahman bin 'Auf, Sa'd bin Abi Waqqash, dan Thalhah bin 'Ubaidillah. Setelah itu menyusul Abu 'Ubaidah bin Al-Jarrah, Al-Arqam bin Abil Arqam, Bilal bin Rabah, Abdullah bin Mas'ud, keluarga Yasir, dan lainnya.

## Darul Arqam
Kaum muslimin berkumpul secara diam-diam di rumah Al-Arqam bin Abil Arqam di dekat Bukit Shafa. Di sana Rasulullah SAW mengajarkan Al-Qur'an, tauhid, dan akhlak. Salat pada masa itu dilakukan dengan sembunyi-sembunyi di lembah-lembah sekitar Makkah.

Ayat-ayat yang turun pada masa ini kebanyakan pendek, menanamkan iman kepada Allah, hari akhir, dan akhlak mulia, serta membersihkan jiwa.''',
    hikmah:
        'Dakwah dimulai dari lingkaran terdekat dengan teladan dan kepercayaan, lalu tumbuh melalui orang-orang yang tulus.',
    reference: 'Sirah Ibnu Hisyam · Ar-Rahiqul Makhtum · Fiqhus Sirah (Al-Buthi)',
  ),
  SirahChapter(
    id: 'sirah_07_dakwah_terang',
    section: SirahSection.sirahNabawiyah,
    order: 7,
    title: 'Dakwah Terang-terangan & Penindasan Quraisy',
    periodOrTitle: 'Tahun ke-4 Kenabian dan Sesudahnya',
    narrative: '''## Seruan di Bukit Shafa
Turunlah perintah: "Berilah peringatan kepada kerabat-kerabatmu yang terdekat" (QS. Asy-Syu'ara: 214). Rasulullah SAW naik ke Bukit Shafa dan memanggil kabilah-kabilah Quraisy. Beliau bertanya, "Jika aku kabarkan ada pasukan berkuda di balik bukit ini yang akan menyerang kalian, apakah kalian percaya?" Mereka menjawab, "Kami tidak pernah mendapatimu berdusta." Beliau berkata, "Sesungguhnya aku memberi peringatan kepada kalian akan azab yang pedih."

Abu Lahab, paman beliau, berkata, "Celakalah engkau, apakah hanya untuk ini engkau mengumpulkan kami?" Lalu turunlah Surah Al-Lahab (HR. Bukhari).

## Cara Quraisy Melawan
Para pemuka Quraisy menolak karena dakwah ini menyerang berhala yang menjadi sumber kedudukan mereka. Mereka mengejek, menuduh beliau penyihir, penyair, atau orang gila, menawarkan harta dan kekuasaan agar beliau berhenti, dan menekan Abu Thalib. Rasulullah SAW menjawab bahwa seandainya matahari diletakkan di tangan kanannya dan bulan di tangan kirinya, beliau tidak akan meninggalkan urusan ini (riwayat Ibnu Ishaq).

## Siksaan terhadap Kaum Lemah
Kaum muslimin yang tidak memiliki pelindung disiksa dengan kejam:

• Bilal bin Rabah dijemur di padang pasir dengan batu besar di dadanya oleh majikannya, Umayyah bin Khalaf. Ia hanya mengucapkan, "Ahad, Ahad." Abu Bakar RA kemudian membelinya dan memerdekakannya.
• Keluarga Yasir disiksa. Sumayyah binti Khayyath dibunuh oleh Abu Jahal dan menjadi syahidah pertama dalam Islam. Rasulullah SAW melewati mereka dan berkata, "Bersabarlah wahai keluarga Yasir, tempat kalian adalah surga."
• Khabbab bin Al-Aratt disiksa dengan besi panas.

Rasulullah SAW sendiri dilempari kotoran unta saat sujud di dekat Ka'bah (HR. Bukhari), tetapi beliau tetap bersabar dan terus berdakwah.''',
    hikmah:
        'Kebenaran pasti diuji. Keteguhan Bilal dan keluarga Yasir menunjukkan bahwa iman yang tertanam dalam hati lebih kuat daripada siksaan.',
    reference: 'QS. Asy-Syu\'ara: 214 · QS. Al-Lahab · HR. Bukhari no. 4770 & 240 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_08_hijrah_habasyah',
    section: SirahSection.sirahNabawiyah,
    order: 8,
    title: 'Hijrah ke Habasyah',
    periodOrTitle: 'Tahun ke-5 Kenabian (615 M)',
    narrative: '''## Mencari Tempat yang Aman
Karena siksaan semakin berat, Rasulullah SAW mengizinkan sebagian sahabat berhijrah ke Habasyah (Etiopia). Beliau menyebut bahwa di sana ada raja yang tidak menzalimi siapa pun, yaitu An-Najasyi. Rombongan pertama berjumlah kecil, di antaranya Utsman bin Affan RA dan istrinya, Ruqayyah binti Rasulullah SAW. Kemudian menyusul rombongan kedua yang lebih besar, dipimpin Ja'far bin Abi Thalib RA.

## Utusan Quraisy
Quraisy mengutus 'Amr bin Al-'Ash dan Abdullah bin Abi Rabi'ah dengan membawa hadiah untuk Najasyi dan para pendetanya. Mereka meminta agar kaum muslimin dikembalikan ke Makkah dengan alasan mereka meninggalkan agama nenek moyang.

## Pembelaan Ja'far bin Abi Thalib
Najasyi tidak mau memutuskan sebelum mendengar pihak muslimin. Ja'far berbicara di hadapannya: dahulu mereka menyembah berhala, memakan bangkai, berbuat keji, memutus silaturahmi, dan yang kuat menindas yang lemah, hingga Allah mengutus seorang rasul dari kalangan mereka yang mereka kenal kejujurannya. Rasul itu mengajak menyembah Allah saja, jujur, menepati amanah, menyambung silaturahmi, dan berbuat baik kepada tetangga.

Najasyi meminta dibacakan sebagian wahyu. Ja'far membacakan awal Surah Maryam. Najasyi menangis hingga janggutnya basah, dan berkata bahwa ajaran ini dan ajaran yang dibawa Musa berasal dari sumber yang sama.

Keesokan harinya utusan Quraisy berkata bahwa kaum muslimin mengucapkan sesuatu yang buruk tentang 'Isa. Ja'far menjawab sesuai Al-Qur'an bahwa 'Isa adalah hamba Allah, rasul-Nya, dan kalimat-Nya yang disampaikan kepada Maryam. Najasyi mengambil sebatang ranting dan berkata bahwa 'Isa tidak lebih dari yang dikatakan Ja'far walaupun sebesar ranting ini. Ia menolak hadiah Quraisy dan melindungi kaum muslimin.

Ketika Najasyi wafat, Rasulullah SAW melaksanakan salat gaib untuknya (HR. Bukhari).''',
    hikmah:
        'Hijrah adalah ikhtiar menyelamatkan iman. Kejujuran dan argumen yang jelas mampu meluluhkan hati penguasa yang adil.',
    reference: 'Musnad Ahmad no. 1740 (kisah Ummu Salamah) · HR. Bukhari no. 1245 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_09_hamzah_umar',
    section: SirahSection.sirahNabawiyah,
    order: 9,
    title: 'Islamnya Hamzah dan Umar bin Khattab',
    periodOrTitle: 'Tahun ke-6 Kenabian (616 M)',
    narrative: '''## Hamzah bin Abdul Muthalib
Suatu hari Abu Jahal mencaci dan menyakiti Rasulullah SAW di dekat Bukit Shafa. Hamzah, paman beliau yang dikenal pemberani dan pemburu, mendengar kabar itu sepulang berburu. Ia mendatangi Abu Jahal di dekat Ka'bah, memukul kepalanya dengan busur, lalu berkata, "Apakah engkau mencacinya, padahal aku berada di atas agamanya?" Setelah itu Hamzah benar-benar memeluk Islam dan menjadi pembela dakwah yang kuat.

## Umar bin Khattab
Umar dikenal keras dan disegani. Rasulullah SAW pernah berdoa agar Islam dikuatkan dengan salah satu dari dua orang yang paling beliau harapkan, yaitu Umar bin Khattab atau Abu Jahal (HR. At-Tirmidzi).

Riwayat yang masyhur dalam kitab sirah menceritakan bahwa Umar keluar dengan pedang untuk membunuh Rasulullah SAW. Di tengah jalan ia diberi tahu bahwa adiknya, Fathimah binti Khattab, dan suaminya, Sa'id bin Zaid, sudah masuk Islam. Ia mendatangi rumah mereka dan mendengar bacaan Al-Qur'an. Setelah emosinya reda, ia membaca lembaran berisi awal Surah Thaha, lalu hatinya luluh. Ia pergi ke Darul Arqam dan menyatakan keislamannya di hadapan Rasulullah SAW.

## Islam Semakin Kuat
Abdullah bin Mas'ud RA berkata, "Kami terus menjadi mulia sejak Umar masuk Islam" (HR. Bukhari). Setelah itu kaum muslimin berani salat di dekat Ka'bah secara terbuka. Rasulullah SAW menjuluki Umar Al-Faruq, pembeda antara yang hak dan yang batil.''',
    hikmah:
        'Hati manusia berada di tangan Allah. Orang yang paling keras menentang bisa menjadi pembela kebenaran yang paling gigih.',
    reference: 'HR. Bukhari no. 3684 · Sunan At-Tirmidzi no. 3681 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_10_pemboikotan',
    section: SirahSection.sirahNabawiyah,
    order: 10,
    title: 'Pemboikotan Bani Hasyim di Syi\'ib Abi Thalib',
    periodOrTitle: 'Tahun ke-7 sampai ke-10 Kenabian',
    narrative: '''## Piagam Pemboikotan
Quraisy gagal menghentikan dakwah dengan ejekan, tawaran, maupun siksaan. Mereka lalu sepakat memboikot Bani Hasyim dan Bani Muthalib, keluarga yang melindungi Rasulullah SAW. Isinya: tidak boleh menikah dengan mereka, berjual beli dengan mereka, bergaul, atau berbicara dengan mereka sampai mereka menyerahkan Muhammad untuk dibunuh. Piagam itu ditulis dan digantung di dalam Ka'bah.

## Tiga Tahun Kelaparan
Bani Hasyim dan Bani Muthalib, baik yang muslim maupun yang belum, bertahan di lembah milik Abu Thalib (Syi'ib Abi Thalib). Hanya Abu Lahab dari Bani Hasyim yang memilih berpihak kepada Quraisy. Selama sekitar tiga tahun mereka menderita kelaparan hebat hingga terpaksa memakan dedaunan dan kulit kering. Tangis anak-anak terdengar dari luar lembah. Beberapa orang Quraisy yang masih punya belas kasihan, seperti Hakim bin Hizam, diam-diam mengirim makanan.

Abu Thalib sangat khawatir keponakannya dibunuh pada malam hari. Kitab-kitab sirah meriwayatkan bahwa ia sering menyuruh Rasulullah SAW tidur di tempat tidurnya sendiri, lalu memindahkan salah seorang putranya ke tempat tidur beliau, agar tidak ada yang tahu di mana beliau tidur.

## Dakwah Tidak Berhenti
Walaupun terkepung, Rasulullah SAW tetap keluar pada musim haji dan musim-musim pasar untuk menyampaikan Islam kepada kabilah-kabilah yang datang ke Makkah, karena pada bulan-bulan haram orang tidak boleh diganggu. Kaum muslimin di dalam lembah juga tetap salat dan saling menguatkan.

## Berakhirnya Pemboikotan
Sejumlah tokoh Quraisy, di antaranya Hisyam bin 'Amr, Zuhair bin Abi Umayyah, dan Al-Muth'im bin 'Adi, merasa malu dengan kezaliman ini dan sepakat membatalkan piagam. Kitab-kitab sirah meriwayatkan bahwa Rasulullah SAW memberi tahu Abu Thalib bahwa rayap telah memakan seluruh isi piagam kecuali tulisan nama Allah. Ketika piagam diturunkan, ternyata benar demikian. Pemboikotan pun berakhir.''',
    hikmah:
        'Kesabaran bersama dalam kesulitan menguatkan ukhuwah, dan Allah membuka jalan keluar melalui cara yang tidak disangka.',
    reference: 'Sirah Ibnu Hisyam · Zadul Ma\'ad (Ibnul Qayyim) · Ar-Rahiqul Makhtum',
  ),
  SirahChapter(
    id: 'sirah_11_amul_huzni_thaif',
    section: SirahSection.sirahNabawiyah,
    order: 11,
    title: 'Tahun Kesedihan & Dakwah ke Thaif',
    periodOrTitle: 'Tahun ke-10 Kenabian (619 M)',
    narrative: '''## 'Amul Huzni
Tidak lama setelah pemboikotan berakhir, Abu Thalib wafat. Ia melindungi Rasulullah SAW sepanjang hidupnya tetapi wafat tanpa mengucapkan syahadat (HR. Bukhari). Beberapa waktu kemudian Khadijah RA juga wafat. Karena kehilangan dua orang yang paling menopang beliau, tahun ini dikenal sebagai Tahun Kesedihan ('Amul Huzni). Sejak itu gangguan Quraisy terhadap beliau semakin berani.

## Perjalanan ke Thaif
Rasulullah SAW berjalan kaki ke Thaif bersama Zaid bin Haritsah RA, berharap Bani Tsaqif mau menerima dakwah dan menolong beliau. Para pemuka Thaif menolak dengan kasar, lalu menyuruh anak-anak dan budak mereka melempari beliau dengan batu hingga kaki beliau berdarah. Zaid melindungi beliau sampai kepalanya terluka.

Beliau berteduh di sebuah kebun milik 'Utbah dan Syaibah bin Rabi'ah. Seorang budak Nasrani bernama 'Addas membawakan anggur, lalu mendengar beliau mengucapkan basmalah. Setelah berbincang tentang Nabi Yunus AS, 'Addas mencium tangan beliau.

## Malaikat Penjaga Gunung
Dalam perjalanan pulang, Jibril datang bersama malaikat penjaga gunung. Malaikat itu menawarkan untuk menimpakan dua gunung kepada penduduk Makkah yang menolak. Rasulullah SAW menjawab, "Tidak, aku berharap Allah mengeluarkan dari keturunan mereka orang yang menyembah Allah saja dan tidak menyekutukan-Nya dengan apa pun" (HR. Bukhari dan Muslim). Beliau kemudian masuk kembali ke Makkah dengan perlindungan Al-Muth'im bin 'Adi.

Dalam perjalanan ini pula, menurut ahli tafsir, sekelompok jin mendengar bacaan Al-Qur'an beliau dan beriman (QS. Al-Ahqaf: 29-31).''',
    hikmah:
        'Di titik paling berat, Rasulullah SAW memilih mendoakan kebaikan daripada membalas. Kesabaran dan harapan beliau terbukti ketika banyak keturunan penentang dakwah kelak memeluk Islam.',
    reference: 'HR. Bukhari no. 3231 & 1360 · HR. Muslim no. 1795 · QS. Al-Ahqaf: 29-31 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_12_isra_miraj',
    section: SirahSection.sirahNabawiyah,
    order: 12,
    title: 'Isra\' Mi\'raj & Perintah Salat Lima Waktu',
    periodOrTitle: 'Sebelum Hijrah (waktunya diperselisihkan ulama)',
    narrative: '''## Waktu Peristiwa
Para ulama berbeda pendapat tentang kapan Isra' Mi'raj terjadi; yang disepakati adalah terjadinya sebelum hijrah. Di Indonesia peristiwa ini masyhur diperingati pada 27 Rajab.

## Isra': Makkah ke Baitul Maqdis
Allah berfirman: "Mahasuci Allah yang telah memperjalankan hamba-Nya pada suatu malam dari Masjidil Haram ke Masjidil Aqsa yang telah Kami berkahi sekelilingnya, agar Kami perlihatkan kepadanya sebagian tanda-tanda kebesaran Kami" (QS. Al-Isra': 1). Rasulullah SAW mengendarai Buraq, hewan putih yang langkahnya sejauh mata memandang, bersama Jibril. Di Baitul Maqdis beliau salat menjadi imam para nabi.

## Mi'raj: Naik ke Langit
Kemudian beliau naik ke langit. Di setiap langit beliau bertemu para nabi: Adam di langit pertama, Yahya dan 'Isa di langit kedua, Yusuf di langit ketiga, Idris di langit keempat, Harun di langit kelima, Musa di langit keenam, dan Ibrahim di langit ketujuh bersandar di Baitul Ma'mur. Beliau sampai di Sidratul Muntaha (QS. An-Najm: 13-18).

## Perintah Salat
Allah mewajibkan salat lima puluh kali sehari semalam. Dalam perjalanan turun, Nabi Musa AS menyarankan beliau memohon keringanan karena umat tidak akan sanggup. Beliau kembali beberapa kali hingga menjadi lima waktu. Allah berfirman bahwa lima waktu itu bernilai pahala lima puluh (HR. Bukhari dan Muslim).

## Ujian Iman
Keesokan harinya beliau menceritakan peristiwa ini. Kaum musyrikin mengejek dan sebagian orang yang lemah imannya goyah. Ketika mereka menyampaikan kabar itu kepada Abu Bakar, ia berkata, "Jika beliau yang mengatakannya, maka itu benar." Sejak itu Abu Bakar dijuluki Ash-Shiddiq.''',
    hikmah:
        'Salat adalah satu-satunya ibadah yang diwajibkan langsung di langit tanpa perantara, tanda betapa agungnya kedudukan salat bagi seorang mukmin.',
    reference: 'QS. Al-Isra\': 1 · QS. An-Najm: 13-18 · HR. Bukhari no. 3887 · HR. Muslim no. 162',
  ),
  SirahChapter(
    id: 'sirah_13_baiat_aqabah',
    section: SirahSection.sirahNabawiyah,
    order: 13,
    title: 'Bai\'at Aqabah Pertama dan Kedua',
    periodOrTitle: 'Tahun ke-11 sampai ke-13 Kenabian',
    narrative: '''## Bertemu Orang-orang Yatsrib
Pada musim haji, Rasulullah SAW menawarkan Islam kepada kabilah-kabilah yang datang ke Makkah. Beliau bertemu sekelompok orang dari suku Khazraj dari Yatsrib (kemudian disebut Madinah). Mereka pernah mendengar dari orang Yahudi di kota mereka tentang akan datangnya seorang nabi. Mereka pun beriman dan berjanji menyampaikan Islam kepada kaumnya.

## Bai'at Aqabah Pertama
Musim haji berikutnya datang dua belas orang dari Aus dan Khazraj. Di bukit Aqabah di Mina mereka berbai'at untuk tidak menyekutukan Allah, tidak mencuri, tidak berzina, tidak membunuh anak, tidak berdusta, dan tidak mendurhakai beliau dalam kebaikan (HR. Bukhari). Rasulullah SAW mengutus Mush'ab bin Umair RA bersama mereka untuk mengajarkan Al-Qur'an. Melalui Mush'ab, banyak pemuka Madinah memeluk Islam, di antaranya Sa'd bin Mu'adz dan Usaid bin Hudhair.

## Bai'at Aqabah Kedua
Setahun kemudian, lebih dari tujuh puluh laki-laki dan dua perempuan dari Madinah datang. Pada malam hari di Aqabah mereka berbai'at untuk mendengar dan taat, berinfak dalam keadaan lapang maupun sempit, menyeru kebaikan, dan melindungi Rasulullah SAW sebagaimana mereka melindungi diri dan keluarga mereka sendiri. Rasulullah SAW memilih dua belas orang sebagai pemimpin (naqib) mereka.

Bai'at ini membuka jalan hijrah. Sejak itu Rasulullah SAW mengizinkan para sahabat berhijrah ke Madinah secara diam-diam.''',
    hikmah:
        'Dakwah yang sabar menemukan tanah yang subur di tempat yang tidak terduga. Janji setia yang tulus menjadi dasar berdirinya masyarakat Islam.',
    reference: 'HR. Bukhari no. 18 · Musnad Ahmad (riwayat Jabir) · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_14_hijrah_madinah',
    section: SirahSection.sirahNabawiyah,
    order: 14,
    title: 'Hijrah Rasulullah SAW ke Madinah',
    periodOrTitle: 'Rabi\'ul Awwal, Tahun 1 Hijriah (622 M)',
    narrative: '''## Makar di Darun Nadwah
Melihat kaum muslimin satu per satu berhijrah, para pemuka Quraisy berkumpul di Darun Nadwah. Mereka sepakat mengambil seorang pemuda dari setiap kabilah untuk membunuh Rasulullah SAW secara bersamaan, agar Bani Hasyim tidak sanggup menuntut balas kepada semua kabilah (QS. Al-Anfal: 30).

## Malam Hijrah
Allah memberi izin hijrah. Rasulullah SAW meminta Ali bin Abi Thalib RA tidur di tempat tidurnya dengan selimut beliau dan menitipkan barang-barang amanah penduduk Makkah untuk dikembalikan. Beliau keluar melewati para pemuda yang mengepung rumah sambil membaca awal Surah Yasin, dan menaburkan pasir di kepala mereka.

## Gua Tsur
Bersama Abu Bakar RA, beliau bersembunyi di Gua Tsur, ke arah selatan, berlawanan dengan arah Madinah, selama tiga malam. Abdullah bin Abu Bakar membawa kabar dari Makkah, Asma' binti Abu Bakar membawa makanan, dan 'Amir bin Fuhairah menggembalakan kambing untuk menghapus jejak. Para pengejar sampai di mulut gua. Abu Bakar berbisik bahwa seandainya mereka melihat ke bawah kaki mereka, mereka akan melihat kita. Rasulullah SAW menjawab, "Apa pendapatmu tentang dua orang yang Allah adalah yang ketiganya?" (HR. Bukhari dan Muslim). Allah berfirman: "Janganlah engkau bersedih, sesungguhnya Allah bersama kita" (QS. At-Taubah: 40).

## Perjalanan dan Suraqah
Mereka berangkat dipandu Abdullah bin Uraiqith menyusuri jalan pantai. Quraisy menjanjikan seratus unta bagi yang dapat menangkap beliau. Suraqah bin Malik mengejar mereka, tetapi kaki kudanya terbenam ke pasir berkali-kali. Ia akhirnya meminta jaminan keamanan dan berbalik menghalau para pengejar lain.

## Tiba di Madinah
Rasulullah SAW singgah di Quba dan membangun Masjid Quba, masjid pertama dalam Islam. Kemudian beliau memasuki Madinah disambut kaum Anshar dengan penuh suka cita. Unta beliau berhenti di tanah milik dua anak yatim, dan di sanalah dibangun Masjid Nabawi. Beliau tinggal sementara di rumah Abu Ayyub Al-Anshari RA. Di masa Umar bin Khattab RA, peristiwa hijrah ini dijadikan awal penanggalan Hijriah.''',
    hikmah:
        'Tawakal yang benar adalah menyusun rencana sebaik mungkin lalu menyerahkan hasilnya kepada Allah. Allah selalu bersama orang yang memperjuangkan agama-Nya.',
    reference: 'QS. Al-Anfal: 30 · QS. At-Taubah: 40 · HR. Bukhari no. 3905 & 3653 · HR. Muslim no. 2381',
  ),
  SirahChapter(
    id: 'sirah_15_membangun_madinah',
    section: SirahSection.sirahNabawiyah,
    order: 15,
    title: 'Membangun Masyarakat Madinah',
    periodOrTitle: 'Tahun 1-2 Hijriah',
    narrative: '''## Masjid Nabawi
Langkah pertama Rasulullah SAW adalah membangun masjid. Beliau ikut mengangkut batu bata bersama para sahabat. Masjid Nabawi menjadi tempat salat, belajar, bermusyawarah, menerima tamu, dan tempat tinggal Ahlush Shuffah, para sahabat miskin yang tinggal di serambi masjid dan menimba ilmu.

## Mempersaudarakan Muhajirin dan Anshar
Kaum Muhajirin datang dari Makkah meninggalkan harta dan rumah. Rasulullah SAW mempersaudarakan setiap Muhajir dengan seorang Anshar. Abdurrahman bin 'Auf dipersaudarakan dengan Sa'd bin Ar-Rabi'. Sa'd menawarkan separuh hartanya, tetapi Abdurrahman berkata, "Semoga Allah memberkahi keluarga dan hartamu. Tunjukkan saja aku letak pasar" (HR. Bukhari). Allah memuji kaum Anshar yang mengutamakan saudaranya walaupun mereka sendiri membutuhkan (QS. Al-Hasyr: 9).

## Piagam Madinah
Rasulullah SAW menyusun perjanjian tertulis yang mengatur hubungan kaum muslimin, kabilah-kabilah Madinah, dan kaum Yahudi. Isinya antara lain: semua pihak bersama-sama mempertahankan Madinah dari serangan, setiap kelompok bebas menjalankan agamanya, perselisihan dikembalikan kepada Rasulullah SAW, dan tidak boleh ada pihak yang membantu musuh.

## Peristiwa Penting Lainnya
• Azan disyariatkan setelah Abdullah bin Zaid RA bermimpi tentang lafaz azan, dan Bilal RA ditunjuk sebagai muadzin (HR. Abu Dawud).
• Kiblat dipindahkan dari Baitul Maqdis ke Ka'bah setelah sekitar enam belas atau tujuh belas bulan (QS. Al-Baqarah: 144, HR. Bukhari).
• Puasa Ramadan dan zakat fitrah diwajibkan pada tahun 2 Hijriah.''',
    hikmah:
        'Tiga dasar masyarakat yang kokoh: masjid sebagai pusat pembinaan, persaudaraan yang tulus, dan aturan bersama yang adil.',
    reference: 'QS. Al-Hasyr: 9 · QS. Al-Baqarah: 144 · HR. Bukhari no. 2049 & 399 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_16_badar',
    section: SirahSection.sirahNabawiyah,
    order: 16,
    title: 'Perang Badar Al-Kubra',
    periodOrTitle: '17 Ramadan, Tahun 2 Hijriah (624 M)',
    narrative: '''## Latar Belakang
Kafilah dagang besar Quraisy yang dipimpin Abu Sufyan kembali dari Syam. Rasulullah SAW keluar bersama para sahabat untuk mencegatnya, sebagai balasan atas harta kaum Muhajirin yang dirampas di Makkah. Abu Sufyan mengubah rute dan meminta bantuan Quraisy. Quraisy berangkat dengan pasukan besar dipimpin Abu Jahal, meskipun kafilah sudah selamat.

## Musyawarah
Rasulullah SAW bermusyawarah. Kaum Muhajirin menyatakan kesiapan. Beliau terus bertanya karena ingin mendengar pendapat kaum Anshar, yang bai'atnya adalah melindungi beliau di Madinah. Sa'd bin Mu'adz RA berkata bahwa seandainya beliau mengajak mereka menyeberangi lautan, mereka akan ikut menyeberanginya.

## Jalannya Pertempuran
Menurut riwayat masyhur, kaum muslimin berjumlah sekitar 313 orang dengan sedikit kuda dan unta, sedangkan pasukan Quraisy sekitar seribu orang. Rasulullah SAW mengatur barisan, lalu berdoa dengan sungguh-sungguh hingga selendangnya terjatuh: "Ya Allah, jika pasukan kecil ini binasa, Engkau tidak akan disembah lagi di bumi" (HR. Muslim). Allah menurunkan bantuan para malaikat (QS. Al-Anfal: 9).

Pertempuran dimulai dengan duel: Hamzah, Ali, dan 'Ubaidah bin Al-Harits menghadapi 'Utbah, Syaibah, dan Al-Walid. Kemudian terjadi pertempuran umum. Abu Jahal terbunuh di tangan dua pemuda Anshar, Mu'adz dan Mu'awwidz, dan dihabisi oleh Abdullah bin Mas'ud. Kaum muslimin menang. Sekitar empat belas sahabat gugur sebagai syuhada, sementara tujuh puluh orang Quraisy terbunuh dan tujuh puluh lainnya ditawan.

## Perlakuan terhadap Tawanan
Rasulullah SAW memerintahkan agar tawanan diperlakukan dengan baik. Sebagian tawanan dibebaskan dengan tebusan, dan tawanan yang pandai menulis dibebaskan dengan syarat mengajari sepuluh anak Madinah membaca dan menulis.''',
    hikmah:
        'Kemenangan datang dari Allah bagi orang yang beriman, bermusyawarah, berikhtiar, dan berdoa dengan sungguh-sungguh, bukan karena banyaknya jumlah (QS. Ali Imran: 123).',
    reference: 'QS. Al-Anfal: 5-19 · QS. Ali Imran: 123 · HR. Muslim no. 1763 · Sirah Ibnu Hisyam · Ar-Rahiqul Makhtum',
  ),
  SirahChapter(
    id: 'sirah_17_uhud',
    section: SirahSection.sirahNabawiyah,
    order: 17,
    title: 'Perang Uhud',
    periodOrTitle: 'Syawal, Tahun 3 Hijriah (625 M)',
    narrative: '''## Quraisy Menuntut Balas
Setelah kekalahan di Badar, Quraisy menghimpun pasukan besar sekitar tiga ribu orang dan bergerak ke Madinah. Rasulullah SAW bermusyawarah. Beliau sempat berpendapat bertahan di dalam kota, tetapi banyak sahabat, terutama yang tidak ikut Badar, ingin menyongsong musuh di luar. Beliau mengikuti pendapat mayoritas dan keluar dengan sekitar seribu orang. Di tengah jalan Abdullah bin Ubay, pemimpin orang munafik, kembali bersama sekitar tiga ratus pengikutnya.

## Pesan kepada Pasukan Pemanah
Rasulullah SAW menempatkan lima puluh pemanah di sebuah bukit kecil (Jabal Rumat) dipimpin Abdullah bin Jubair RA. Beliau berpesan agar mereka tidak meninggalkan tempat itu apa pun yang terjadi, baik kaum muslimin menang maupun kalah (HR. Bukhari).

## Jalannya Pertempuran
Pada awalnya kaum muslimin unggul dan pasukan Quraisy mundur. Melihat itu, sebagian besar pemanah turun untuk mengumpulkan rampasan perang meski sudah diingatkan pemimpinnya. Khalid bin Walid, yang saat itu masih di pihak Quraisy, melihat bukit yang kosong dan menyerang dari belakang. Barisan muslimin kacau.

Tersebar kabar bahwa Rasulullah SAW terbunuh. Beliau terluka: gigi geraham beliau patah dan dua keping rantai topi besi menancap di pipi beliau. Para sahabat seperti Thalhah bin 'Ubaidillah, Abu Dujanah, Sa'd bin Abi Waqqash, dan Nusaibah binti Ka'ab membela beliau dengan tubuh mereka.

## Para Syuhada
Sekitar tujuh puluh sahabat gugur, di antaranya Hamzah bin Abdul Muthalib RA, paman beliau, yang dibunuh oleh Wahsyi, dan Mush'ab bin Umair RA, pembawa bendera. Mush'ab dikafani dengan kain yang jika ditarik ke kepala kakinya terbuka, dan jika ditarik ke kaki kepalanya terbuka (HR. Bukhari). Rasulullah SAW sangat berduka atas Hamzah dan menyebutnya pemimpin para syuhada.''',
    hikmah:
        'Satu pelanggaran perintah dapat mengubah kemenangan menjadi musibah. Allah menguji agar tampak siapa yang benar-benar beriman, dan mengajarkan agar tidak terlena oleh dunia (QS. Ali Imran: 152-155).',
    reference: 'QS. Ali Imran: 121-175 · HR. Bukhari no. 3039 & 1274 · Sirah Ibnu Hisyam · Zadul Ma\'ad',
  ),
  SirahChapter(
    id: 'sirah_18_khandaq',
    section: SirahSection.sirahNabawiyah,
    order: 18,
    title: 'Perang Khandaq (Ahzab)',
    periodOrTitle: 'Syawal, Tahun 5 Hijriah (627 M)',
    narrative: '''## Pasukan Sekutu
Para pemuka Yahudi Bani Nadhir yang telah diusir dari Madinah karena berkhianat menghasut Quraisy, Ghathafan, dan kabilah-kabilah lain untuk menyerang Madinah bersama-sama. Terkumpul pasukan sekutu (Ahzab) yang sangat besar, menurut riwayat sekitar sepuluh ribu orang.

## Gagasan Menggali Parit
Rasulullah SAW bermusyawarah. Salman Al-Farisi RA mengusulkan menggali parit (khandaq) di sisi utara Madinah yang terbuka, cara bertahan yang dikenal di negeri Persia. Usul ini diterima. Rasulullah SAW ikut menggali, mengangkut tanah hingga debu menutupi kulit perut beliau, sambil melantunkan syair bersama para sahabat.

Ketika para sahabat menemukan batu yang sangat keras, Rasulullah SAW memukulnya dengan cangkul hingga hancur. Pada masa itu para sahabat sangat lapar; ada yang mengikatkan batu di perutnya. Jabir bin Abdillah RA mengundang beliau makan, lalu makanan yang sedikit itu cukup untuk seluruh penggali parit dengan izin Allah (HR. Bukhari).

## Pengepungan
Pasukan sekutu terkejut melihat parit dan mengepung Madinah selama hampir sebulan. Keadaan semakin genting ketika Yahudi Bani Quraizhah di dalam Madinah membatalkan perjanjian. Allah menggambarkan keadaan itu: "ketika penglihatan tidak tetap lagi dan hati naik sampai ke tenggorokan" (QS. Al-Ahzab: 10).

## Pertolongan Allah
Nu'aim bin Mas'ud RA, yang baru masuk Islam secara diam-diam, berhasil memecah kepercayaan antara Quraisy, Ghathafan, dan Bani Quraizhah. Kemudian Allah mengirim angin kencang yang dingin pada malam hari, merobohkan kemah dan memadamkan api mereka (QS. Al-Ahzab: 9). Pasukan sekutu pun pulang tanpa hasil. Setelah itu Rasulullah SAW bersabda, "Sekarang kitalah yang akan mendatangi mereka, bukan mereka yang mendatangi kita" (HR. Bukhari).

Setelah perang, Bani Quraizhah dikepung karena pengkhianatan mereka, dan keputusan atas mereka diserahkan kepada Sa'd bin Mu'adz RA.''',
    hikmah:
        'Musyawarah dan mau menerima gagasan yang baik dari siapa pun adalah bagian dari ikhtiar; di puncak kesulitan, pertolongan Allah datang dengan cara yang tidak terduga.',
    reference: 'QS. Al-Ahzab: 9-27 · HR. Bukhari no. 4101 & 4110 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_19_hudaibiyah',
    section: SirahSection.sirahNabawiyah,
    order: 19,
    title: 'Perjanjian Hudaibiyah & Bai\'atur Ridhwan',
    periodOrTitle: 'Dzulqa\'dah, Tahun 6 Hijriah (628 M)',
    narrative: '''## Berangkat untuk Umrah
Rasulullah SAW bermimpi memasuki Masjidil Haram dalam keadaan aman. Beliau berangkat bersama sekitar seribu empat ratus sahabat dengan pakaian ihram, membawa hewan kurban, tanpa senjata perang kecuali pedang dalam sarungnya. Quraisy menghalangi mereka di Hudaibiyah, dekat Makkah.

## Bai'atur Ridhwan
Rasulullah SAW mengutus Utsman bin Affan RA ke Makkah untuk menjelaskan bahwa kaum muslimin hanya ingin berumrah. Utsman tertahan dan tersiar kabar bahwa ia dibunuh. Rasulullah SAW lalu membai'at para sahabat di bawah sebuah pohon untuk tidak lari dan siap membela. Allah meridai mereka: "Sungguh Allah telah meridai orang-orang mukmin ketika mereka berjanji setia kepadamu di bawah pohon" (QS. Al-Fath: 18). Ternyata kabar itu tidak benar.

## Isi Perjanjian
Quraisy mengutus Suhail bin 'Amr untuk berunding. Isi perjanjian antara lain:
• Kaum muslimin kembali tahun ini dan baru boleh berumrah tahun depan selama tiga hari.
• Gencatan senjata selama sepuluh tahun.
• Orang Makkah yang datang ke Madinah tanpa izin walinya harus dikembalikan, sedangkan orang Madinah yang datang ke Makkah tidak dikembalikan.
• Setiap kabilah bebas bersekutu dengan pihak mana pun.

Saat penulisan, Suhail menolak kalimat "Bismillahir Rahmanir Rahim" dan "Muhammad Rasulullah". Rasulullah SAW menerimanya dan meminta ditulis "Muhammad bin Abdullah".

## Kemenangan yang Nyata
Banyak sahabat merasa berat, termasuk Umar RA. Namun dalam perjalanan pulang turun Surah Al-Fath: "Sesungguhnya Kami telah memberikan kepadamu kemenangan yang nyata" (QS. Al-Fath: 1). Dengan perdamaian, orang dapat bergaul dan mendengar Islam tanpa rasa takut. Dalam dua tahun setelahnya, jumlah orang yang masuk Islam lebih banyak daripada tahun-tahun sebelumnya. Khalid bin Walid dan 'Amr bin Al-'Ash termasuk yang masuk Islam pada masa ini.''',
    hikmah:
        'Mengalah dalam hal yang tampak merugikan bisa menjadi jalan kemenangan yang lebih besar. Ketaatan kepada Rasulullah SAW harus didahulukan walaupun belum dipahami hikmahnya.',
    reference: 'QS. Al-Fath: 1-29 · HR. Bukhari no. 2731-2732 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_20_surat_raja_khaibar',
    section: SirahSection.sirahNabawiyah,
    order: 20,
    title: 'Surat kepada Para Raja & Pembebasan Khaibar',
    periodOrTitle: 'Tahun 7 Hijriah (628-629 M)',
    narrative: '''## Dakwah kepada Para Penguasa
Setelah perdamaian Hudaibiyah, Rasulullah SAW mengirim surat ajakan masuk Islam kepada para raja, dibubuhi stempel cincin perak bertuliskan "Muhammad Rasulullah". Di antaranya:
• Heraklius, Kaisar Romawi, yang menanyai Abu Sufyan tentang sifat-sifat beliau. Heraklius mengakui tanda-tanda kenabian, tetapi takut kehilangan kekuasaan (HR. Bukhari).
• Kisra, Raja Persia, yang merobek surat beliau. Rasulullah SAW mendoakan agar kerajaannya tercabik-cabik.
• Al-Muqauqis, penguasa Mesir, yang menjawab dengan baik dan mengirim hadiah.
• An-Najasyi, Raja Habasyah.

## Khaibar
Khaibar adalah benteng-benteng Yahudi di utara Madinah yang menjadi pusat penghasutan, termasuk dalam Perang Ahzab. Pada awal tahun 7 Hijriah Rasulullah SAW mengepung benteng-benteng itu. Benteng terakhir sangat kuat. Beliau bersabda, "Besok aku akan menyerahkan bendera kepada seseorang yang dicintai Allah dan Rasul-Nya, dan Allah akan memberikan kemenangan melalui tangannya." Keesokan harinya bendera diserahkan kepada Ali bin Abi Thalib RA, yang saat itu sakit mata lalu disembuhkan dengan tiupan Rasulullah SAW (HR. Bukhari dan Muslim). Benteng itu pun dibuka.

Penduduk Khaibar diizinkan tetap mengolah kebun kurma dengan bagi hasil separuh panen. Pada masa inilah Ja'far bin Abi Thalib dan para muhajir Habasyah tiba di Madinah. Rasulullah SAW bersabda bahwa beliau tidak tahu mana yang lebih menggembirakan, kemenangan Khaibar atau kedatangan Ja'far.

## Umrah Qadha'
Pada Dzulqa'dah 7 Hijriah, sesuai perjanjian Hudaibiyah, Rasulullah SAW dan para sahabat menunaikan umrah di Makkah selama tiga hari.''',
    hikmah:
        'Islam disampaikan kepada semua manusia tanpa memandang kedudukan, dengan cara yang santun dan jelas, dan kemenangan diberikan kepada orang yang dicintai Allah.',
    reference: 'HR. Bukhari no. 7 & 4210 · HR. Muslim no. 2406 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_21_mutah_fathu_makkah',
    section: SirahSection.sirahNabawiyah,
    order: 21,
    title: 'Perang Mu\'tah & Fathu Makkah',
    periodOrTitle: 'Tahun 8 Hijriah (629-630 M)',
    narrative: '''## Perang Mu'tah
Utusan Rasulullah SAW kepada penguasa Bushra dibunuh oleh seorang pejabat Romawi. Rasulullah SAW mengirim pasukan sekitar tiga ribu orang dan menunjuk tiga panglima berurutan: Zaid bin Haritsah, lalu Ja'far bin Abi Thalib, lalu Abdullah bin Rawahah. Di Mu'tah mereka berhadapan dengan pasukan Romawi dan sekutunya yang jauh lebih besar.

Ketiga panglima itu gugur satu per satu. Kemudian Khalid bin Walid RA memegang bendera dan berhasil menarik pasukan dengan selamat. Di Madinah, sebelum kabar datang, Rasulullah SAW mengabarkan gugurnya ketiga panglima dengan air mata berlinang dan menyebut Khalid sebagai salah satu pedang Allah (HR. Bukhari).

## Pelanggaran Perjanjian
Bani Bakr, sekutu Quraisy, menyerang Bani Khuza'ah, sekutu kaum muslimin, dibantu sebagian orang Quraisy. Dengan pelanggaran ini, perjanjian Hudaibiyah batal.

## Memasuki Makkah
Pada bulan Ramadan 8 Hijriah, Rasulullah SAW berangkat dengan sekitar sepuluh ribu pasukan. Abu Sufyan datang dan masuk Islam. Rasulullah SAW mengumumkan: siapa yang masuk rumah Abu Sufyan aman, siapa yang menutup pintu rumahnya aman, dan siapa yang masuk Masjidil Haram aman.

Beliau memasuki Makkah dengan menundukkan kepala di atas untanya karena tawadhu' kepada Allah. Hampir tidak ada pertumpahan darah. Beliau menghancurkan berhala-berhala di sekitar Ka'bah sambil membaca: "Kebenaran telah datang dan kebatilan telah lenyap" (QS. Al-Isra': 81). Bilal RA naik ke atas Ka'bah dan mengumandangkan azan.

## Pengampunan
Rasulullah SAW berdiri di hadapan penduduk Makkah yang dahulu mengusir dan memerangi beliau. Beliau bertanya apa yang mereka kira akan beliau lakukan. Mereka menjawab, "Kebaikan, engkau saudara yang mulia dan putra saudara yang mulia." Menurut riwayat dalam kitab sirah, beliau berkata, "Pergilah, kalian semua bebas." Banyak penduduk Makkah kemudian berbondong-bondong masuk Islam (QS. An-Nashr).''',
    hikmah:
        'Puncak kemenangan disambut dengan tawadhu\' dan pengampunan. Akhlak mulia membuka hati yang tidak bisa ditaklukkan dengan kekuatan.',
    reference: 'QS. Al-Isra\': 81 · QS. An-Nashr · HR. Bukhari no. 4262 & 4287 · Sirah Ibnu Hisyam',
  ),
  SirahChapter(
    id: 'sirah_22_hunain_tabuk',
    section: SirahSection.sirahNabawiyah,
    order: 22,
    title: 'Perang Hunain, Thaif & Tabuk',
    periodOrTitle: 'Tahun 8-9 Hijriah (630 M)',
    narrative: '''## Perang Hunain
Tak lama setelah Fathu Makkah, kabilah Hawazin dan Tsaqif menghimpun pasukan. Rasulullah SAW keluar dengan sekitar dua belas ribu orang. Sebagian kaum muslimin merasa bangga dengan jumlah yang besar. Di lembah Hunain, musuh menyerang tiba-tiba dari tempat persembunyian dan banyak pasukan muslim lari.

Rasulullah SAW tetap teguh di atas bighalnya dan berseru, "Aku adalah nabi, tidak berdusta. Aku adalah putra Abdul Muthalib." Al-'Abbas memanggil para sahabat yang ikut Bai'atur Ridhwan, dan mereka kembali. Allah menurunkan ketenangan dan bala tentara yang tidak terlihat, hingga kaum muslimin menang (QS. At-Taubah: 25-26).

## Pengepungan Thaif dan Pembagian Rampasan
Sisa pasukan Tsaqif bertahan di Thaif. Setelah pengepungan beberapa waktu, Rasulullah SAW memutuskan pulang dan mendoakan mereka mendapat hidayah. Tak lama kemudian mereka datang ke Madinah dan masuk Islam.

Rampasan Hunain banyak dibagikan kepada orang-orang yang baru masuk Islam untuk melunakkan hati mereka. Sebagian pemuda Anshar merasa kecewa. Rasulullah SAW mengumpulkan mereka dan bertanya, "Tidakkah kalian rela orang-orang pulang membawa kambing dan unta, sementara kalian pulang membawa Rasulullah ke rumah kalian?" Mereka menangis dan berkata, "Kami rela" (HR. Bukhari dan Muslim).

## Perang Tabuk
Pada musim panas tahun 9 Hijriah, tersiar kabar Romawi bersiap menyerang. Rasulullah SAW menyeru perang secara terbuka meskipun cuaca sangat panas, jaraknya jauh, dan masa panen tiba. Pasukan ini disebut Jaisyul 'Usrah (pasukan masa sulit). Utsman bin Affan RA menyumbang dalam jumlah besar, Umar RA menyerahkan separuh hartanya, dan Abu Bakar RA menyerahkan seluruh hartanya.

Pasukan sekitar tiga puluh ribu orang sampai di Tabuk, tetapi pasukan Romawi tidak datang. Beberapa kabilah di perbatasan menyatakan tunduk. Orang-orang munafik yang mencari alasan untuk tidak ikut terbongkar dalam Surah At-Taubah. Tiga sahabat yang jujur mengakui kesalahannya karena tertinggal, yaitu Ka'ab bin Malik, Hilal bin Umayyah, dan Murarah bin Ar-Rabi', diampuni Allah setelah lima puluh hari (QS. At-Taubah: 118, HR. Bukhari).''',
    hikmah:
        'Jumlah yang banyak tidak menjamin kemenangan bila hati bergantung pada selain Allah. Kejujuran mengakui kesalahan membawa ampunan, sedangkan kebohongan membinasakan.',
    reference: 'QS. At-Taubah: 25-26, 38-118 · HR. Bukhari no. 4337 & 4418 · HR. Muslim no. 1061',
  ),
  SirahChapter(
    id: 'sirah_23_wufud_haji_wada',
    section: SirahSection.sirahNabawiyah,
    order: 23,
    title: 'Tahun Delegasi & Haji Wada\'',
    periodOrTitle: 'Tahun 9-10 Hijriah (631-632 M)',
    narrative: '''## 'Amul Wufud
Setelah Fathu Makkah dan Tabuk, kabilah-kabilah dari seluruh Jazirah Arab mengirim utusan ke Madinah untuk menyatakan keislaman atau mempelajari Islam. Karena banyaknya delegasi, tahun 9 Hijriah disebut tahun delegasi. Rasulullah SAW menyambut mereka dengan ramah, mengajarkan agama, dan mengutus para sahabat ke berbagai daerah, seperti Mu'adz bin Jabal dan Abu Musa Al-Asy'ari ke Yaman.

Pada tahun yang sama Abu Bakar RA memimpin jamaah haji, dan diumumkan bahwa sejak tahun berikutnya orang musyrik tidak boleh lagi berhaji dan tidak ada yang boleh tawaf tanpa busana.

## Haji Wada'
Pada tahun 10 Hijriah Rasulullah SAW menunaikan haji, satu-satunya haji beliau setelah hijrah. Puluhan ribu kaum muslimin ikut bersama beliau. Beliau mengajarkan tata cara haji secara langsung dan bersabda, "Ambillah dariku tata cara manasik kalian" (HR. Muslim).

## Khutbah di Arafah
Di Arafah beliau menyampaikan khutbah yang agung. Di antara isinya:
• Darah, harta, dan kehormatan kaum muslimin haram dilanggar, seperti haramnya hari, bulan, dan negeri itu.
• Riba jahiliyah dan tuntutan balas darah jahiliyah dihapuskan.
• Bertakwalah kepada Allah dalam urusan perempuan, karena mereka adalah amanah Allah.
• Beliau meninggalkan sesuatu yang membuat umat tidak akan tersesat jika berpegang kepadanya, yaitu Kitabullah (HR. Muslim).

Beliau bertanya, "Apakah aku telah menyampaikan?" Mereka menjawab, "Ya." Beliau mengangkat jari ke langit dan berkata, "Ya Allah, saksikanlah."

Pada hari Arafah itu turun ayat: "Pada hari ini telah Aku sempurnakan untukmu agamamu, telah Aku cukupkan nikmat-Ku bagimu, dan telah Aku ridai Islam sebagai agamamu" (QS. Al-Ma'idah: 3).''',
    hikmah:
        'Agama telah sempurna. Tugas umat adalah menjaga kehormatan sesama, berlaku adil, dan berpegang teguh kepada Al-Qur\'an dan Sunnah.',
    reference: 'QS. Al-Ma\'idah: 3 · HR. Muslim no. 1218 & 1297 · HR. Bukhari no. 4406',
  ),
  SirahChapter(
    id: 'sirah_24_wafat',
    section: SirahSection.sirahNabawiyah,
    order: 24,
    title: 'Sakit dan Wafatnya Rasulullah SAW',
    periodOrTitle: 'Rabi\'ul Awwal, Tahun 11 Hijriah (632 M)',
    narrative: '''## Tanda-tanda Perpisahan
Beberapa waktu setelah Haji Wada' turun Surah An-Nashr, yang dipahami Ibnu 'Abbas RA sebagai isyarat dekatnya ajal Rasulullah SAW (HR. Bukhari). Beliau memperbanyak tasbih dan istighfar.

## Sakit Terakhir
Pada akhir bulan Shafar 11 Hijriah, beliau mulai sakit kepala dan demam tinggi. Beliau meminta izin kepada istri-istrinya untuk dirawat di rumah Aisyah RA. Meski sakit, beliau tetap keluar ke masjid selama masih mampu. Dalam salah satu khutbah terakhirnya beliau bersabda bahwa Allah memberi pilihan kepada seorang hamba antara dunia dan apa yang ada di sisi-Nya, lalu hamba itu memilih yang ada di sisi Allah. Abu Bakar RA menangis karena memahami maksudnya.

Ketika sakit semakin berat, beliau memerintahkan Abu Bakar RA mengimami salat. Beliau berwasiat agar menjaga salat dan berbuat baik kepada hamba sahaya.

## Hari Senin
Pada Senin pagi, beliau menyingkap tirai rumahnya dan tersenyum melihat kaum muslimin bersaf salat Subuh di belakang Abu Bakar (HR. Bukhari). Menjelang siang, beliau wafat di pangkuan Aisyah RA. Kalimat terakhir yang beliau ucapkan adalah, "Allahumma fir-rafiqil a'la" (Ya Allah, bersama teman yang tertinggi) (HR. Bukhari). Menurut pendapat masyhur, beliau wafat pada 12 Rabi'ul Awwal 11 H dalam usia 63 tahun.

## Keteguhan Abu Bakar
Para sahabat sangat terguncang. Umar RA bahkan tidak mau menerima kabar itu. Abu Bakar RA masuk, mencium kening beliau, lalu keluar dan berkata, "Barang siapa menyembah Muhammad, sesungguhnya Muhammad telah wafat. Barang siapa menyembah Allah, sesungguhnya Allah Maha Hidup dan tidak akan mati." Lalu ia membaca: "Muhammad hanyalah seorang rasul, sebelumnya telah berlalu beberapa rasul..." (QS. Ali Imran: 144). Para sahabat seakan baru mendengar ayat itu.

Rasulullah SAW dimakamkan di kamar Aisyah RA, tempat beliau wafat, yang kini berada di dalam Masjid Nabawi.''',
    hikmah:
        'Setiap jiwa akan merasakan kematian, termasuk manusia termulia. Yang kekal adalah Allah dan ajaran yang beliau tinggalkan, maka cinta kepada Rasulullah SAW dibuktikan dengan mengikuti sunnahnya.',
    reference: 'QS. Ali Imran: 144 · QS. An-Nashr · HR. Bukhari no. 4454, 4463, 680 & 3668',
  ),
];
