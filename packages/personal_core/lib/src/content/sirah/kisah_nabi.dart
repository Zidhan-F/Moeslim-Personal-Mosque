import '../sirah_library.dart';

/// Kisah 25 Nabi dan Rasul yang wajib diketahui, satu bab untuk setiap nabi.
///
/// Sumber utama adalah ayat Al-Qur'an dan hadits sahih; rincian dari kitab sejarah/tafsir
/// (misalnya nama tempat atau tokoh yang tidak disebut Al-Qur'an) ditandai sebagai riwayat.
const List<SirahChapter> kisahNabiChapters = [
  SirahChapter(
    id: 'nabi_01_adam',
    section: SirahSection.kisah25Nabi,
    order: 1,
    title: 'Nabi Adam AS',
    periodOrTitle: 'Nabi ke-1 · Manusia pertama · Abul Basyar',
    narrative: '''## Diciptakan sebagai Khalifah
Allah memberi tahu para malaikat bahwa Dia akan menjadikan seorang khalifah di bumi. Para malaikat bertanya apakah Allah akan menjadikan makhluk yang berbuat kerusakan, dan Allah menjawab bahwa Dia mengetahui apa yang tidak mereka ketahui (QS. Al-Baqarah: 30). Allah menciptakan Adam dari tanah, membentuknya, lalu meniupkan ruh ke dalamnya (QS. Shad: 71-72).

## Diajari Nama-nama
Allah mengajarkan kepada Adam nama-nama segala sesuatu, lalu memperlihatkannya kepada para malaikat. Para malaikat tidak mampu menyebutkannya dan berkata, "Mahasuci Engkau, tidak ada yang kami ketahui selain apa yang Engkau ajarkan kepada kami." Adam menyebutkan semuanya (QS. Al-Baqarah: 31-33). Ilmu menjadi kemuliaan manusia.

## Iblis Menolak Sujud
Allah memerintahkan para malaikat sujud kepada Adam sebagai penghormatan. Semua sujud kecuali Iblis, yang sombong dan berkata, "Aku lebih baik daripadanya. Engkau ciptakan aku dari api, sedangkan dia Engkau ciptakan dari tanah" (QS. Al-A'raf: 12). Iblis diusir dan bersumpah akan menyesatkan anak cucu Adam.

## Di Surga dan Tergelincir
Adam dan istrinya, Hawa, tinggal di surga dan boleh memakan apa saja kecuali dari satu pohon. Setan membisikkan bahwa pohon itu membuat mereka kekal. Keduanya memakannya, lalu aurat mereka tampak. Mereka segera menyesal dan berdoa: "Ya Tuhan kami, kami telah menzalimi diri kami sendiri. Jika Engkau tidak mengampuni kami dan tidak merahmati kami, niscaya kami termasuk orang-orang yang rugi" (QS. Al-A'raf: 23). Allah menerima taubat mereka (QS. Al-Baqarah: 37), lalu menurunkan mereka ke bumi untuk menjalani kehidupan sebagai khalifah.

## Habil dan Qabil
Di bumi, Adam dan Hawa dikaruniai keturunan. Dua putra Adam mempersembahkan kurban; kurban yang satu diterima dan yang lain tidak. Yang kurbannya ditolak membunuh saudaranya karena dengki, lalu menyesal ketika melihat seekor burung gagak menggali tanah untuk mengubur gagak lain (QS. Al-Ma'idah: 27-31). Nama Habil dan Qabil berasal dari riwayat ahli tafsir.''',
    hikmah:
        'Kesalahan Adam diikuti taubat yang segera, sedangkan dosa Iblis berakar dari kesombongan. Siapa pun bisa tergelincir, yang membedakan adalah kembali kepada Allah.',
    reference: 'QS. Al-Baqarah: 30-37 · QS. Al-A\'raf: 11-25 · QS. Al-Ma\'idah: 27-31 · Qashashul Anbiya (Ibnu Katsir)',
  ),
  SirahChapter(
    id: 'nabi_02_idris',
    section: SirahSection.kisah25Nabi,
    order: 2,
    title: 'Nabi Idris AS',
    periodOrTitle: 'Nabi ke-2 · Seorang yang sangat jujur dan sabar',
    narrative: '''## Disebut dalam Al-Qur'an
Al-Qur'an menyebut Nabi Idris AS dengan singkat tetapi mulia: "Dan ceritakanlah (Muhammad) kisah Idris di dalam Kitab (Al-Qur'an). Sesungguhnya dia seorang yang sangat membenarkan dan seorang nabi. Dan Kami telah mengangkatnya ke tempat (martabat) yang tinggi" (QS. Maryam: 56-57). Allah juga menyebutnya bersama Isma'il dan Dzulkifli sebagai orang-orang yang sabar (QS. Al-Anbiya: 85-86).

## Kehidupan dan Dakwahnya
Menurut kitab-kitab sejarah, Idris hidup setelah Nabi Adam AS dan Nabi Syits, dan sebelum Nabi Nuh AS. Ia menyeru kaumnya agar tetap di atas tauhid dan menjauhi perbuatan dosa yang mulai muncul di kalangan keturunan Adam. Sebagian riwayat menyebut bahwa ia orang pertama yang menulis dengan pena dan mengajarkan menjahit pakaian. Riwayat-riwayat rinci tentang kehidupannya tidak sampai pada derajat yang pasti, sehingga yang dipegang adalah yang disebutkan Al-Qur'an dan hadits.

## Bertemu Rasulullah SAW
Dalam peristiwa Mi'raj, Rasulullah SAW bertemu Nabi Idris AS di langit keempat. Idris menyambut beliau dengan ucapan, "Selamat datang, saudara yang saleh dan nabi yang saleh" (HR. Bukhari dan Muslim). Sebagian ulama menafsirkan "tempat yang tinggi" dalam QS. Maryam: 57 sebagai kedudukan dan martabat yang mulia.''',
    hikmah:
        'Kejujuran dan kesabaran mengangkat derajat seseorang di sisi Allah, walaupun kisah hidupnya tidak banyak diceritakan.',
    reference: 'QS. Maryam: 56-57 · QS. Al-Anbiya: 85-86 · HR. Bukhari no. 3887 · HR. Muslim no. 162',
  ),
  SirahChapter(
    id: 'nabi_03_nuh',
    section: SirahSection.kisah25Nabi,
    order: 3,
    title: 'Nabi Nuh AS',
    periodOrTitle: 'Nabi ke-3 · Rasul Ulul Azmi · Rasul pertama ke penduduk bumi',
    narrative: '''## Kaum Penyembah Berhala
Setelah masa Nabi Adam AS, manusia mulai menyembah berhala. Kaum Nuh menyembah patung-patung bernama Wadd, Suwa', Yaghuts, Ya'uq, dan Nasr (QS. Nuh: 23). Menurut penjelasan Ibnu 'Abbas RA, itu adalah nama orang-orang saleh yang patungnya dibuat untuk dikenang, lalu generasi berikutnya menyembahnya (HR. Bukhari).

## Dakwah 950 Tahun
Nuh berdakwah kepada kaumnya selama 950 tahun (QS. Al-'Ankabut: 14). Ia menyeru siang dan malam, secara terang-terangan maupun diam-diam. Kaumnya menutup telinga dengan jari, menutupi diri dengan pakaian, dan tetap sombong (QS. Nuh: 5-9). Ia menjanjikan ampunan, hujan yang lebat, harta, dan anak-anak bila mereka beristighfar (QS. Nuh: 10-12). Hanya sedikit yang beriman, kebanyakan dari kalangan miskin, dan para pembesar mengejek mereka.

## Membuat Bahtera
Allah mewahyukan bahwa tidak akan ada lagi yang beriman dari kaumnya kecuali yang sudah beriman. Nuh diperintah membuat bahtera di bawah pengawasan dan wahyu Allah. Setiap kali para pembesar lewat, mereka menertawakannya (QS. Hud: 36-38).

## Banjir Besar
Ketika ketetapan Allah datang, air memancar dari bumi dan turun dari langit. Nuh membawa orang-orang beriman dan sepasang dari setiap jenis hewan ke dalam bahtera (QS. Hud: 40). Ia memanggil anaknya yang berada di tempat terpisah agar ikut naik. Anaknya menjawab akan berlindung ke gunung. Nuh berkata, "Tidak ada yang melindungi hari ini dari ketetapan Allah selain yang Dia rahmati." Gelombang memisahkan keduanya dan anak itu tenggelam (QS. Hud: 42-43). Istri Nuh juga termasuk yang binasa karena mengkhianati dakwahnya (QS. At-Tahrim: 10).

Setelah air surut, bahtera berlabuh di Bukit Judi (QS. Hud: 44). Nuh berdoa untuk anaknya, lalu Allah menjelaskan bahwa anak itu bukan termasuk keluarga yang dijanjikan selamat karena amalnya tidak saleh (QS. Hud: 45-47).''',
    hikmah:
        'Kesabaran berdakwah tanpa lelah, dan keselamatan tidak ditentukan oleh hubungan darah, melainkan oleh iman dan amal.',
    reference: 'QS. Nuh · QS. Hud: 25-49 · QS. Al-\'Ankabut: 14 · QS. At-Tahrim: 10 · HR. Bukhari no. 4920',
  ),
  SirahChapter(
    id: 'nabi_04_hud',
    section: SirahSection.kisah25Nabi,
    order: 4,
    title: 'Nabi Hud AS',
    periodOrTitle: 'Nabi ke-4 · Diutus kepada kaum \'Ad',
    narrative: '''## Kaum 'Ad yang Perkasa
Kaum 'Ad tinggal di Al-Ahqaf, bukit-bukit pasir di selatan Jazirah Arab (QS. Al-Ahqaf: 21). Mereka bertubuh kuat dan membangun kota Iram yang memiliki bangunan-bangunan tinggi, yang belum pernah dibuat seperti itu di negeri lain (QS. Al-Fajr: 6-8). Kekuatan membuat mereka sombong dan berkata, "Siapakah yang lebih kuat daripada kami?" (QS. Fushshilat: 15).

## Dakwah Hud
Allah mengutus Hud, salah seorang dari kalangan mereka sendiri. Ia menyeru: "Wahai kaumku, sembahlah Allah, tidak ada tuhan bagimu selain Dia" (QS. Hud: 50). Ia mengingatkan bahwa ia tidak meminta upah, dan mengajak mereka beristighfar agar Allah menurunkan hujan dan menambah kekuatan mereka. Ia juga menegur kebiasaan mereka membangun bangunan megah di setiap tempat tinggi hanya untuk bermegah-megahan (QS. Asy-Syu'ara: 128-130).

Kaumnya menuduhnya kurang akal dan berkata bahwa sebagian tuhan mereka telah menimpakan penyakit gila kepadanya. Hud menjawab dengan tegas bahwa ia berlepas diri dari apa yang mereka sekutukan dan bertawakal kepada Allah (QS. Hud: 53-56).

## Azab Angin
Ketika mereka melihat awan yang datang ke lembah mereka, mereka gembira dan mengira akan turun hujan. Padahal itu adalah azab yang mereka minta untuk disegerakan (QS. Al-Ahqaf: 24). Allah mengirim angin yang sangat dingin dan kencang selama tujuh malam delapan hari berturut-turut, sehingga mereka bergelimpangan seperti batang-batang pohon kurma yang lapuk (QS. Al-Haqqah: 6-7). Hud dan orang-orang yang beriman diselamatkan.''',
    hikmah:
        'Kekuatan dan kemajuan tidak berarti tanpa iman. Kesombongan atas nikmat Allah mengundang kebinasaan.',
    reference: 'QS. Hud: 50-60 · QS. Al-Ahqaf: 21-25 · QS. Al-Haqqah: 6-8 · QS. Asy-Syu\'ara: 123-140',
  ),
  SirahChapter(
    id: 'nabi_05_shalih',
    section: SirahSection.kisah25Nabi,
    order: 5,
    title: 'Nabi Shalih AS',
    periodOrTitle: 'Nabi ke-5 · Diutus kepada kaum Tsamud',
    narrative: '''## Kaum Tsamud
Kaum Tsamud tinggal di Al-Hijr, di antara Hijaz dan Syam. Mereka memahat gunung-gunung menjadi rumah yang kokoh dan membangun istana di dataran (QS. Al-A'raf: 74, QS. Al-Fajr: 9). Peninggalan mereka dikenal sekarang sebagai Mada'in Shalih di wilayah Al-'Ula.

## Mukjizat Unta Betina
Nabi Shalih menyeru mereka menyembah Allah. Mereka meminta bukti. Allah mengeluarkan seekor unta betina sebagai mukjizat (QS. Asy-Syu'ara: 154-155). Shalih menetapkan pembagian air: satu hari untuk unta, satu hari untuk mereka, dan memperingatkan agar unta itu tidak diganggu (QS. Asy-Syams: 13).

## Menyembelih Unta
Para pembesar yang sombong merasa terganggu. Orang yang paling celaka di antara mereka bangkit dan menyembelih unta itu (QS. Asy-Syams: 12-14), disetujui kaumnya. Mereka menantang Shalih untuk mendatangkan azab. Shalih berkata, "Bersenang-senanglah kalian di rumah kalian selama tiga hari" (QS. Hud: 65). Sembilan orang perusak bahkan bersekongkol untuk membunuh Shalih dan keluarganya pada malam hari, tetapi Allah menggagalkan rencana mereka (QS. An-Naml: 48-51).

## Azab
Setelah tiga hari, datang suara yang sangat keras dan gempa yang dahsyat, sehingga mereka mati bergelimpangan di rumah-rumah mereka (QS. Hud: 67-68, QS. Al-A'raf: 78). Shalih dan orang-orang yang beriman diselamatkan. Ketika Rasulullah SAW melewati Al-Hijr dalam perjalanan ke Tabuk, beliau meminta para sahabat melewatinya sambil menangis dan tidak mengambil air dari sumur mereka (HR. Bukhari dan Muslim).''',
    hikmah:
        'Mukjizat tidak bermanfaat bagi hati yang sombong. Kezaliman yang dilakukan sebagian orang lalu didiamkan dan direstui kaumnya membawa azab bagi semuanya.',
    reference: 'QS. Hud: 61-68 · QS. Asy-Syams: 11-15 · QS. An-Naml: 45-53 · HR. Bukhari no. 3380',
  ),
  SirahChapter(
    id: 'nabi_06_ibrahim',
    section: SirahSection.kisah25Nabi,
    order: 6,
    title: 'Nabi Ibrahim AS',
    periodOrTitle: 'Nabi ke-6 · Rasul Ulul Azmi · Khalilullah · Bapak para nabi',
    narrative: '''## Mencari Tuhan yang Benar
Ibrahim hidup di tengah kaum penyembah berhala dan bintang. Ayahnya, Azar, adalah pembuat berhala (QS. Al-An'am: 74). Al-Qur'an menceritakan Ibrahim mengajak kaumnya berpikir: ketika melihat bintang, bulan, dan matahari terbenam, ia berkata bahwa ia tidak menyukai sesuatu yang terbenam, lalu menyatakan menghadapkan dirinya kepada Allah yang menciptakan langit dan bumi (QS. Al-An'am: 76-79).

## Menghancurkan Berhala
Ketika kaumnya pergi merayakan hari besar, Ibrahim menghancurkan berhala-berhala mereka kecuali yang terbesar. Saat ditanya, ia menjawab, "Tanyakanlah kepada berhala yang besar itu, jika mereka dapat berbicara." Mereka tertunduk karena tahu berhala tidak dapat berbicara (QS. Al-Anbiya: 57-65).

## Dibakar Api
Mereka memutuskan membakar Ibrahim. Allah berfirman: "Wahai api, jadilah dingin dan keselamatan bagi Ibrahim" (QS. Al-Anbiya: 69). Ia keluar dengan selamat. Ibrahim juga berdebat dengan seorang raja yang mengaku dapat menghidupkan dan mematikan; ketika Ibrahim berkata bahwa Allah menerbitkan matahari dari timur dan menantangnya menerbitkan dari barat, raja itu terdiam (QS. Al-Baqarah: 258). Menurut ahli tafsir, raja itu bernama Namrud.

## Hijrah dan Keluarga
Ibrahim berhijrah bersama istrinya, Sarah, dan keponakannya, Luth, ke Syam. Dari Hajar, Allah mengaruniainya Isma'il. Atas perintah Allah, Ibrahim meninggalkan Hajar dan Isma'il kecil di lembah Makkah yang tandus, lalu berdoa agar Allah menjadikan hati manusia cenderung kepada mereka (QS. Ibrahim: 37). Kemudian dari Sarah lahir Ishaq.

## Ujian Menyembelih Anak
Ibrahim bermimpi menyembelih anaknya. Ia menyampaikannya, dan Isma'il menjawab, "Wahai ayahku, lakukanlah apa yang diperintahkan kepadamu, insya Allah engkau akan mendapatiku termasuk orang yang sabar." Ketika keduanya berserah diri, Allah menggantinya dengan sembelihan yang besar (QS. Ash-Shaffat: 102-107). Peristiwa ini diabadikan dalam ibadah kurban.

## Membangun Ka'bah
Ibrahim dan Isma'il meninggikan fondasi Ka'bah sambil berdoa: "Ya Tuhan kami, terimalah dari kami, sesungguhnya Engkau Maha Mendengar lagi Maha Mengetahui" (QS. Al-Baqarah: 127). Ibrahim lalu menyeru manusia untuk berhaji (QS. Al-Hajj: 27). Allah menjadikannya kekasih-Nya (khalil) (QS. An-Nisa': 125).''',
    hikmah:
        'Tauhid yang murni menuntut keberanian, dan kepatuhan total kepada Allah, bahkan dalam ujian terberat, berbuah keberkahan bagi keturunan dan umat sesudahnya.',
    reference: 'QS. Al-An\'am: 74-83 · QS. Al-Anbiya: 51-73 · QS. Ash-Shaffat: 83-113 · QS. Al-Baqarah: 124-132, 258',
  ),
  SirahChapter(
    id: 'nabi_07_luth',
    section: SirahSection.kisah25Nabi,
    order: 7,
    title: 'Nabi Luth AS',
    periodOrTitle: 'Nabi ke-7 · Diutus kepada kaum Sodom',
    narrative: '''## Keponakan Nabi Ibrahim
Luth adalah keponakan Nabi Ibrahim AS yang beriman kepadanya dan ikut berhijrah (QS. Al-'Ankabut: 26). Allah mengutusnya kepada penduduk kota-kota di sekitar Laut Mati, yang dikenal dalam sejarah sebagai Sodom.

## Perbuatan Keji
Kaum Luth melakukan perbuatan keji yang belum pernah dilakukan siapa pun sebelum mereka: mendatangi laki-laki dengan syahwat, bukan perempuan. Mereka juga menyamun di jalan dan berbuat mungkar di tempat-tempat pertemuan (QS. Al-A'raf: 80-81, QS. Al-'Ankabut: 28-29). Luth menasihati mereka, tetapi mereka mengancam akan mengusirnya dan berkata, "Mereka adalah orang-orang yang menganggap dirinya suci" (QS. Al-A'raf: 82).

## Tamu Malaikat
Allah mengutus para malaikat dalam rupa pemuda tampan. Mereka singgah dahulu kepada Ibrahim dan mengabarkan kelahiran Ishaq, lalu menuju rumah Luth. Kaumnya datang bergegas ingin berbuat jahat kepada para tamu. Luth sangat sedih dan berkata, "Seandainya aku mempunyai kekuatan atau dapat berlindung kepada keluarga yang kuat" (QS. Hud: 80). Para malaikat menenangkannya dan menjelaskan bahwa mereka utusan Allah.

## Azab
Luth diperintahkan keluar bersama keluarganya pada akhir malam tanpa menoleh ke belakang, kecuali istrinya, yang termasuk orang-orang yang binasa karena berpihak kepada kaumnya (QS. Hud: 81, QS. At-Tahrim: 10). Pada waktu subuh, negeri mereka dijungkirbalikkan dan dihujani batu dari tanah yang terbakar secara bertubi-tubi (QS. Hud: 82-83).''',
    hikmah:
        'Menyeru kebaikan tetap wajib walaupun sendirian. Kemaksiatan yang dibanggakan secara terbuka mendatangkan murka Allah, dan iman tidak dapat diwariskan, bahkan kepada istri seorang nabi.',
    reference: 'QS. Hud: 69-83 · QS. Al-A\'raf: 80-84 · QS. Al-\'Ankabut: 26-35 · QS. At-Tahrim: 10',
  ),
  SirahChapter(
    id: 'nabi_08_ismail',
    section: SirahSection.kisah25Nabi,
    order: 8,
    title: 'Nabi Isma\'il AS',
    periodOrTitle: 'Nabi ke-8 · Putra Ibrahim dan Hajar · Leluhur bangsa Arab',
    narrative: '''## Di Lembah yang Tandus
Ibrahim membawa Hajar dan bayinya, Isma'il, ke lembah Makkah yang tidak berpenghuni, lalu meninggalkan mereka dengan sedikit kurma dan air. Hajar bertanya, "Apakah Allah yang memerintahkanmu?" Ibrahim menjawab, "Ya." Hajar berkata, "Kalau begitu Allah tidak akan menelantarkan kami" (HR. Bukhari).

## Mata Air Zamzam
Ketika air habis dan Isma'il menangis kehausan, Hajar berlari-lari antara Bukit Shafa dan Marwah tujuh kali mencari air atau orang yang lewat. Lalu Malaikat Jibril menghentakkan tanah dan memancarlah air Zamzam (HR. Bukhari). Lari kecil Hajar diabadikan dalam ibadah sa'i. Kabilah Jurhum kemudian menetap di sana, dan Isma'il tumbuh di tengah mereka, belajar bahasa Arab, dan menikah dengan perempuan dari kabilah itu.

## Anak yang Sabar
Ketika Isma'il beranjak dewasa, Ibrahim bermimpi menyembelihnya. Isma'il menjawab dengan penuh kesabaran, "Wahai ayahku, lakukanlah apa yang diperintahkan kepadamu, insya Allah engkau akan mendapatiku termasuk orang-orang yang sabar" (QS. Ash-Shaffat: 102). Allah menggantinya dengan seekor sembelihan yang besar.

## Membangun Ka'bah
Isma'il membantu ayahnya meninggikan fondasi Ka'bah. Ia mengangkut batu dan Ibrahim menyusunnya, sambil keduanya berdoa (QS. Al-Baqarah: 127-129). Doa mereka agar diutus seorang rasul dari keturunan mereka terkabul dengan diutusnya Nabi Muhammad SAW, keturunan Isma'il.

## Sifat Mulia
Allah memujinya: "Sesungguhnya dia adalah seorang yang benar janjinya, seorang rasul dan nabi. Ia menyuruh keluarganya untuk salat dan menunaikan zakat, dan ia seorang yang diridai di sisi Tuhannya" (QS. Maryam: 54-55).''',
    hikmah:
        'Bakti seorang anak lahir dari ketakwaan, dan keyakinan seorang ibu kepada Allah menghadirkan pertolongan yang menjadi berkah bagi umat sepanjang masa.',
    reference: 'QS. Ash-Shaffat: 100-107 · QS. Al-Baqarah: 125-129 · QS. Maryam: 54-55 · HR. Bukhari no. 3364',
  ),
  SirahChapter(
    id: 'nabi_09_ishaq',
    section: SirahSection.kisah25Nabi,
    order: 9,
    title: 'Nabi Ishaq AS',
    periodOrTitle: 'Nabi ke-9 · Putra Ibrahim dan Sarah',
    narrative: '''## Kabar Gembira di Usia Senja
Sarah, istri Nabi Ibrahim AS, lama tidak dikaruniai anak hingga usianya lanjut. Para malaikat yang diutus kepada kaum Luth singgah di rumah Ibrahim. Ibrahim menjamu mereka dengan anak sapi panggang, tetapi mereka tidak menyentuhnya, sehingga ia merasa takut. Mereka menenangkannya dan memberi kabar gembira tentang kelahiran Ishaq, dan sesudah Ishaq akan lahir Ya'qub (QS. Hud: 69-71).

Sarah tertawa dan heran: "Mungkinkah aku melahirkan anak, padahal aku sudah tua dan suamiku ini sudah sangat tua?" Para malaikat menjawab, "Apakah engkau merasa heran tentang ketetapan Allah? Rahmat dan keberkahan Allah tercurah kepada kalian, wahai ahlul bait" (QS. Hud: 72-73, QS. Adz-Dzariyat: 28-30).

## Nabi yang Saleh
Allah mengangkat Ishaq menjadi nabi yang saleh dan memberkahinya bersama ayahnya (QS. Ash-Shaffat: 112-113). Allah menjadikan Ishaq dan Ya'qub pemimpin yang memberi petunjuk dengan perintah Allah, dan mewahyukan kepada mereka untuk berbuat kebaikan, mendirikan salat, dan menunaikan zakat (QS. Al-Anbiya: 72-73).

## Leluhur Bani Israil
Dari Ishaq lahir Ya'qub (Israil), dan dari Ya'qub lahir dua belas putra yang menurunkan Bani Israil. Banyak nabi diutus dari keturunan ini, termasuk Yusuf, Musa, Harun, Dawud, Sulaiman, Zakariya, Yahya, dan 'Isa. Al-Qur'an tidak menceritakan rincian dakwah Ishaq secara panjang; ia disebut sebagai bagian dari rantai kenabian yang menjaga tauhid Ibrahim.''',
    hikmah:
        'Tidak ada yang mustahil bagi Allah. Doa yang lama belum dikabulkan bisa dijawab pada waktu terbaik menurut Allah, membawa keberkahan bagi banyak generasi.',
    reference: 'QS. Hud: 69-73 · QS. Adz-Dzariyat: 24-30 · QS. Ash-Shaffat: 112-113 · QS. Al-Anbiya: 72-73',
  ),
  SirahChapter(
    id: 'nabi_10_yaqub',
    section: SirahSection.kisah25Nabi,
    order: 10,
    title: 'Nabi Ya\'qub AS',
    periodOrTitle: 'Nabi ke-10 · Israil · Ayah dua belas suku Bani Israil',
    narrative: '''## Israil
Ya'qub adalah putra Ishaq dan cucu Ibrahim. Ia juga disebut Israil (QS. Ali Imran: 93), dan keturunannya dikenal sebagai Bani Israil. Ia memiliki dua belas putra, di antaranya Yusuf dan Bunyamin dari ibu yang sama.

## Kesabaran yang Indah
Ya'qub sangat menyayangi Yusuf. Ketika saudara-saudara Yusuf pulang membawa baju Yusuf berlumur darah palsu dan berkata Yusuf dimakan serigala, Ya'qub tahu mereka berdusta. Ia berkata, "Maka kesabaran yang baik itulah (kesabaranku). Dan Allah sajalah yang dimohon pertolongan-Nya" (QS. Yusuf: 18).

Bertahun-tahun ia menanggung kesedihan hingga matanya memutih karena banyak menangis, tetapi ia tidak mengeluh kepada manusia. Ia berkata, "Sesungguhnya hanya kepada Allah aku mengadukan kesusahan dan kesedihanku" (QS. Yusuf: 84-86). Ketika Bunyamin juga tertahan di Mesir, ia tetap berharap dan menyuruh anak-anaknya mencari Yusuf: "Jangan berputus asa dari rahmat Allah" (QS. Yusuf: 87).

## Bertemu Kembali dengan Yusuf
Yusuf mengirim bajunya untuk diusapkan ke wajah ayahnya, dan penglihatan Ya'qub kembali (QS. Yusuf: 93-96). Ya'qub dan keluarganya pindah ke Mesir. Mimpi Yusuf semasa kecil menjadi kenyataan.

## Wasiat kepada Anak-anak
Menjelang wafat, Ya'qub bertanya kepada anak-anaknya, "Apa yang kalian sembah sepeninggalku?" Mereka menjawab, "Kami akan menyembah Tuhanmu dan Tuhan nenek moyangmu, Ibrahim, Isma'il, dan Ishaq, yaitu Tuhan Yang Maha Esa" (QS. Al-Baqarah: 132-133).''',
    hikmah:
        'Kesabaran yang indah adalah tidak mengeluh kepada makhluk, tetap berharap kepada Allah, dan memastikan anak-anak berpegang pada tauhid.',
    reference: 'QS. Yusuf: 4-18, 83-100 · QS. Al-Baqarah: 132-133 · QS. Ali Imran: 93',
  ),
  SirahChapter(
    id: 'nabi_11_yusuf',
    section: SirahSection.kisah25Nabi,
    order: 11,
    title: 'Nabi Yusuf AS',
    periodOrTitle: 'Nabi ke-11 · Kisah terbaik dalam Al-Qur\'an',
    narrative: '''## Mimpi Masa Kecil
Allah menyebut kisah Yusuf sebagai kisah yang paling baik (QS. Yusuf: 3). Saat kecil Yusuf bermimpi melihat sebelas bintang, matahari, dan bulan bersujud kepadanya. Ayahnya, Ya'qub, memintanya merahasiakan mimpi itu dari saudara-saudaranya (QS. Yusuf: 4-5).

## Dibuang ke Sumur
Saudara-saudaranya iri karena ayah mereka lebih menyayangi Yusuf. Mereka membawanya bermain lalu memasukkannya ke dalam sumur, dan pulang membawa baju Yusuf berlumur darah palsu. Sekelompok musafir menemukan Yusuf dan menjualnya di Mesir dengan harga murah (QS. Yusuf: 8-20).

## Godaan di Rumah Al-Aziz
Yusuf dibeli seorang pejabat Mesir, Al-Aziz. Ketika Yusuf dewasa, istri Al-Aziz menggodanya. Yusuf menolak dan berkata, "Aku berlindung kepada Allah" (QS. Yusuf: 23). Ia berlari ke pintu dan bajunya robek di bagian belakang, menjadi bukti bahwa ia tidak bersalah. Nama Zulaikha bagi istri Al-Aziz berasal dari riwayat ahli tafsir. Karena tekanan para perempuan kota, Yusuf memilih penjara: "Wahai Tuhanku, penjara lebih aku sukai daripada memenuhi ajakan mereka" (QS. Yusuf: 33).

## Di Penjara
Di penjara Yusuf berdakwah tentang tauhid kepada dua pemuda dan menakwilkan mimpi mereka (QS. Yusuf: 36-41). Bertahun kemudian raja Mesir bermimpi melihat tujuh sapi gemuk dimakan tujuh sapi kurus. Yusuf menakwilkannya sebagai tujuh tahun subur diikuti tujuh tahun paceklik, dan memberi cara menyimpan gandum di tangkainya (QS. Yusuf: 43-49). Sebelum keluar, ia meminta namanya dibersihkan terlebih dahulu.

## Bendahara Mesir
Raja mengangkat Yusuf mengurus perbendaharaan negeri (QS. Yusuf: 54-56). Ketika paceklik melanda, saudara-saudaranya datang membeli bahan makanan tanpa mengenalinya. Melalui beberapa peristiwa, termasuk tertahannya Bunyamin, akhirnya Yusuf memperkenalkan diri.

## Memaafkan
Saudara-saudaranya mengakui kesalahan mereka. Yusuf berkata, "Pada hari ini tidak ada cercaan terhadap kalian. Mudah-mudahan Allah mengampuni kalian, dan Dia Maha Penyayang di antara para penyayang" (QS. Yusuf: 92). Keluarganya datang ke Mesir dan bersujud penghormatan kepadanya, sehingga mimpinya menjadi kenyataan (QS. Yusuf: 100).''',
    hikmah:
        'Menjaga kehormatan diri lebih utama daripada kenikmatan sesaat, kesabaran berbuah kemuliaan, dan memaafkan adalah akhlak orang yang kuat.',
    reference: 'QS. Yusuf: 1-101',
  ),
  SirahChapter(
    id: 'nabi_12_ayyub',
    section: SirahSection.kisah25Nabi,
    order: 12,
    title: 'Nabi Ayyub AS',
    periodOrTitle: 'Nabi ke-12 · Teladan kesabaran',
    narrative: '''## Hamba yang Diuji
Nabi Ayyub AS adalah hamba Allah yang taat dan, menurut kitab-kitab sejarah, memiliki harta yang banyak dan keluarga yang besar. Allah mengujinya dengan kehilangan harta dan anak-anak, lalu dengan penyakit yang sangat berat dan berlangsung lama. Riwayat-riwayat tentang jenis penyakit dan lamanya berbeda-beda; Al-Qur'an menyebutnya sebagai penderitaan dan kesusahan yang ditimpakan setan (QS. Shad: 41).

## Tidak Pernah Mengeluh
Di tengah ujian itu, Ayyub tetap bersabar dan bersyukur. Banyak orang menjauhinya, sementara istrinya tetap setia merawatnya. Doanya penuh adab, tidak menuntut dan tidak mengeluh: "Sesungguhnya aku telah ditimpa penyakit, padahal Engkau Tuhan Yang Maha Penyayang di antara semua penyayang" (QS. Al-Anbiya: 83).

## Kesembuhan
Allah mengabulkan doanya: "Hentakkanlah kakimu, inilah air yang sejuk untuk mandi dan minum" (QS. Shad: 42). Ayyub mandi dan minum dari air itu, lalu sembuh. Allah mengembalikan keluarganya dan melipatgandakan nikmatnya sebagai rahmat dan pelajaran bagi orang-orang yang berakal (QS. Shad: 43, QS. Al-Anbiya: 84).

Ayyub pernah bersumpah akan memukul istrinya karena suatu hal. Allah memberinya jalan keluar dengan memukulkan seikat rumput agar sumpahnya terpenuhi tanpa menyakiti (QS. Shad: 44). Allah memujinya: "Sesungguhnya Kami dapati dia seorang yang sabar. Dialah sebaik-baik hamba. Sungguh, dia sangat taat kepada Allah" (QS. Shad: 44).''',
    hikmah:
        'Sabar bukan berarti tidak berdoa, melainkan berdoa dengan adab tanpa keluh kesah. Setiap ujian yang dihadapi dengan sabar akan diganti dengan yang lebih baik.',
    reference: 'QS. Al-Anbiya: 83-84 · QS. Shad: 41-44 · Qashashul Anbiya (Ibnu Katsir)',
  ),
  SirahChapter(
    id: 'nabi_13_syuaib',
    section: SirahSection.kisah25Nabi,
    order: 13,
    title: 'Nabi Syu\'aib AS',
    periodOrTitle: 'Nabi ke-13 · Diutus kepada penduduk Madyan',
    narrative: '''## Penduduk Madyan
Nabi Syu'aib AS diutus kepada penduduk Madyan, wilayah di barat laut Jazirah Arab. Al-Qur'an juga menyebut Ashabul Aikah (penduduk hutan) yang didakwahi Syu'aib (QS. Asy-Syu'ara: 176-177). Para ulama berbeda pendapat apakah keduanya kaum yang sama atau dua kaum yang berbeda.

## Kecurangan dalam Perdagangan
Selain menyembah selain Allah, kaumnya biasa mengurangi takaran dan timbangan, merugikan hak orang lain, dan menghadang orang di jalan. Syu'aib berkata, "Sempurnakanlah takaran dan timbangan dengan adil, dan janganlah kalian merugikan manusia terhadap hak-hak mereka, dan janganlah kalian membuat kerusakan di bumi" (QS. Hud: 85). Ia mengingatkan bahwa sisa keuntungan yang halal dari Allah lebih baik bagi mereka.

Kaumnya mengejek: "Apakah salatmu yang menyuruhmu agar kami meninggalkan apa yang disembah nenek moyang kami, atau melarang kami mengelola harta kami sesuai kehendak kami?" (QS. Hud: 87). Syu'aib menjawab bahwa ia tidak ingin menyalahi mereka dengan mengerjakan apa yang ia larang, dan ia hanya ingin perbaikan sesuai kemampuannya (QS. Hud: 88).

## Azab
Mereka mengancam akan merajam Syu'aib dan mengusir orang-orang beriman. Akhirnya azab datang: penduduk Madyan dibinasakan dengan suara yang sangat keras dan gempa (QS. Hud: 94, QS. Al-A'raf: 91), sedangkan Ashabul Aikah ditimpa azab pada hari yang dinaungi awan (QS. Asy-Syu'ara: 189). Syu'aib dan orang-orang beriman diselamatkan.

## Hubungan dengan Nabi Musa
Al-Qur'an menceritakan bahwa Musa, ketika lari ke Madyan, menikahi putri seorang lelaki tua yang saleh (QS. Al-Qashash: 23-28). Sebagian ulama berpendapat lelaki itu adalah Nabi Syu'aib, sebagian lainnya berpendapat ia orang saleh lain dari Madyan.''',
    hikmah:
        'Kejujuran dalam takaran, timbangan, dan muamalah adalah bagian dari iman. Kecurangan ekonomi yang dianggap biasa adalah kerusakan di bumi.',
    reference: 'QS. Hud: 84-95 · QS. Al-A\'raf: 85-93 · QS. Asy-Syu\'ara: 176-191',
  ),
  SirahChapter(
    id: 'nabi_14_musa',
    section: SirahSection.kisah25Nabi,
    order: 14,
    title: 'Nabi Musa AS',
    periodOrTitle: 'Nabi ke-14 · Rasul Ulul Azmi · Kalimullah · Penerima Taurat',
    narrative: '''## Lahir di Masa Fir'aun
Fir'aun menindas Bani Israil di Mesir dan membunuh bayi laki-laki mereka. Allah mengilhamkan kepada ibu Musa untuk menyusuinya, lalu menghanyutkannya di sungai dalam sebuah peti bila ia khawatir (QS. Al-Qashash: 7). Peti itu dipungut keluarga Fir'aun, dan istri Fir'aun memintanya agar tidak dibunuh. Musa tidak mau menyusu kepada siapa pun hingga saudara perempuannya menunjukkan ibunya sendiri. Allah mengembalikan Musa kepada ibunya (QS. Al-Qashash: 8-13).

## Ke Madyan
Saat dewasa, Musa membela seorang Bani Israil dan memukul seorang lelaki Mesir hingga tewas tanpa sengaja. Ia memohon ampun kepada Allah, lalu lari ke Madyan. Di sana ia membantu dua perempuan memberi minum ternak, dan menikahi salah satunya setelah bekerja untuk ayah mereka selama delapan atau sepuluh tahun (QS. Al-Qashash: 15-28).

## Diangkat Menjadi Rasul
Dalam perjalanan kembali ke Mesir, Musa melihat api di lembah suci Thuwa. Allah berbicara langsung kepadanya dan mengangkatnya menjadi rasul (QS. Thaha: 9-14, QS. An-Nisa': 164). Ia diberi mukjizat tongkat yang menjadi ular dan tangan yang bersinar putih. Musa berdoa: "Ya Tuhanku, lapangkanlah dadaku, mudahkanlah urusanku, dan lepaskanlah kekakuan lidahku agar mereka mengerti perkataanku" (QS. Thaha: 25-28), dan meminta saudaranya, Harun, menjadi pendampingnya.

## Menghadapi Fir'aun
Musa dan Harun mendatangi Fir'aun dengan perkataan yang lemah lembut (QS. Thaha: 44). Fir'aun mengumpulkan para penyihir. Tongkat Musa menelan semua tipuan mereka, dan para penyihir justru bersujud beriman meski diancam disalib (QS. Thaha: 65-73). Mesir ditimpa berbagai azab, tetapi Fir'aun tetap ingkar (QS. Al-A'raf: 133).

## Laut Terbelah
Musa membawa Bani Israil keluar pada malam hari. Fir'aun mengejar. Ketika laut di depan mereka, para pengikut berkata, "Kita pasti tersusul." Musa menjawab, "Tidak, sesungguhnya Tuhanku bersamaku, Dia akan memberi petunjuk kepadaku" (QS. Asy-Syu'ara: 61-62). Ia memukulkan tongkat dan laut terbelah. Bani Israil selamat dan Fir'aun beserta pasukannya tenggelam. Saat tenggelam, Fir'aun menyatakan iman, tetapi sudah terlambat (QS. Yunus: 90-92).

## Taurat dan Ujian Bani Israil
Musa bermunajat di bukit Thur selama empat puluh malam dan menerima Taurat (QS. Al-A'raf: 142-145). Sementara itu Samiri membuat patung anak sapi dan banyak Bani Israil menyembahnya (QS. Thaha: 85-97). Bani Israil berkali-kali membangkang, termasuk dalam kisah penyembelihan sapi betina (QS. Al-Baqarah: 67-73), hingga mereka tersesat di padang pasir selama empat puluh tahun (QS. Al-Ma'idah: 26). Musa juga belajar kepada hamba Allah yang saleh, yang dikenal sebagai Khidir, dalam kisah perahu, anak muda, dan dinding (QS. Al-Kahfi: 60-82).''',
    hikmah:
        'Keberanian menyampaikan kebenaran kepada penguasa zalim dengan kata-kata yang lembut, tawakal penuh di saat terdesak, dan kerendahan hati untuk terus belajar.',
    reference: 'QS. Al-Qashash: 3-46 · QS. Thaha: 9-98 · QS. Asy-Syu\'ara: 10-68 · QS. Al-Kahfi: 60-82 · QS. Al-Baqarah: 49-74',
  ),
  SirahChapter(
    id: 'nabi_15_harun',
    section: SirahSection.kisah25Nabi,
    order: 15,
    title: 'Nabi Harun AS',
    periodOrTitle: 'Nabi ke-15 · Saudara dan pendamping Nabi Musa',
    narrative: '''## Doa Musa untuk Saudaranya
Harun adalah kakak Nabi Musa AS. Ketika diutus kepada Fir'aun, Musa memohon: "Jadikanlah untukku seorang pembantu dari keluargaku, yaitu Harun, saudaraku. Teguhkanlah kekuatanku dengannya, dan jadikanlah dia sekutu dalam urusanku" (QS. Thaha: 29-32). Musa juga berkata, "Saudaraku Harun lebih fasih lidahnya daripadaku" (QS. Al-Qashash: 34). Allah mengabulkannya dan mengangkat Harun sebagai nabi (QS. Maryam: 53).

## Bersama Menghadapi Fir'aun
Keduanya diperintahkan mendatangi Fir'aun: "Pergilah kamu berdua kepada Fir'aun, karena dia benar-benar telah melampaui batas. Maka berbicaralah kamu berdua kepadanya dengan kata-kata yang lemah lembut, mudah-mudahan dia ingat atau takut" (QS. Thaha: 43-44). Harun mendampingi Musa dalam seluruh perjuangan membebaskan Bani Israil.

## Peristiwa Anak Sapi
Ketika Musa pergi bermunajat ke bukit Thur, Harun memimpin Bani Israil. Samiri membuat patung anak sapi dari perhiasan, dan banyak yang menyembahnya. Harun menasihati mereka, "Wahai kaumku, kalian hanya sedang diuji dengan patung itu. Sesungguhnya Tuhan kalian adalah Yang Maha Pengasih, maka ikutilah aku dan taatilah perintahku" (QS. Thaha: 90). Mereka menolak.

Ketika Musa kembali dengan marah dan memegang janggut serta kepala Harun, Harun menjelaskan bahwa ia khawatir dituduh memecah belah Bani Israil (QS. Thaha: 92-94). Musa lalu mendoakan ampunan bagi dirinya dan saudaranya (QS. Al-A'raf: 151).

## Kedudukan Harun
Rasulullah SAW bersabda kepada Ali bin Abi Thalib RA, "Tidakkah engkau rela kedudukanmu di sisiku seperti kedudukan Harun di sisi Musa, hanya saja tidak ada nabi sesudahku?" (HR. Bukhari dan Muslim).''',
    hikmah:
        'Saling menguatkan dalam kebaikan, berbicara dengan lembut, dan menjaga persatuan umat adalah teladan dari persaudaraan Musa dan Harun.',
    reference: 'QS. Thaha: 29-36, 43-44, 90-94 · QS. Al-Qashash: 34-35 · QS. Maryam: 53 · HR. Bukhari no. 3706',
  ),
  SirahChapter(
    id: 'nabi_16_dzulkifli',
    section: SirahSection.kisah25Nabi,
    order: 16,
    title: 'Nabi Dzulkifli AS',
    periodOrTitle: 'Nabi ke-16 · Termasuk orang-orang yang sabar dan pilihan',
    narrative: '''## Disebut Bersama Para Nabi
Al-Qur'an menyebut Dzulkifli dua kali. "Dan (ingatlah) Isma'il, Idris, dan Dzulkifli. Semuanya termasuk orang-orang yang sabar. Dan Kami masukkan mereka ke dalam rahmat Kami. Sesungguhnya mereka termasuk orang-orang yang saleh" (QS. Al-Anbiya: 85-86). "Dan ingatlah Isma'il, Ilyasa', dan Dzulkifli. Semuanya termasuk orang-orang yang paling baik" (QS. Shad: 48).

## Siapakah Dzulkifli?
Karena Al-Qur'an menyebutnya bersama para nabi, mayoritas ulama memasukkannya ke dalam golongan nabi, dan di Indonesia ia termasuk 25 nabi yang wajib diketahui. Sebagian ulama lain berpendapat ia seorang hamba saleh yang bukan nabi. Al-Qur'an tidak menyebutkan kaum atau negeri tempat ia diutus.

## Makna Nama dan Riwayat tentang Dirinya
Dzulkifli berarti pemilik bagian atau orang yang sanggup menanggung. Kitab-kitab tafsir dan sejarah membawakan riwayat bahwa ia menyanggupi amanah dari pemimpin sebelumnya untuk berpuasa di siang hari, salat di malam hari, dan memutuskan perkara di antara manusia tanpa marah, lalu ia menepati semua itu walaupun diuji. Riwayat ini tidak berasal dari hadits sahih, sehingga dipahami sebagai kisah pelengkap, sedangkan yang pasti adalah pujian Allah atas kesabaran dan kebaikannya.''',
    hikmah:
        'Kesabaran dan menepati amanah adalah sifat yang membuat seseorang dimasukkan Allah ke dalam golongan orang-orang terbaik, walaupun kisahnya tidak dikenal banyak orang.',
    reference: 'QS. Al-Anbiya: 85-86 · QS. Shad: 48 · Tafsir Ibnu Katsir · Qashashul Anbiya',
  ),
  SirahChapter(
    id: 'nabi_17_dawud',
    section: SirahSection.kisah25Nabi,
    order: 17,
    title: 'Nabi Dawud AS',
    periodOrTitle: 'Nabi ke-17 · Raja dan nabi · Penerima Zabur',
    narrative: '''## Mengalahkan Jalut
Setelah masa Nabi Musa AS, Bani Israil meminta seorang raja untuk memimpin mereka berperang. Allah mengangkat Thalut sebagai raja. Pasukan Thalut diuji dengan larangan minum dari sebuah sungai, dan hanya sedikit yang lulus. Ketika berhadapan dengan pasukan Jalut yang besar, mereka berdoa memohon kesabaran. Dawud, seorang pemuda dalam pasukan itu, membunuh Jalut. Allah memberinya kerajaan dan hikmah (QS. Al-Baqarah: 246-251).

## Kitab Zabur dan Suara yang Merdu
Allah menurunkan kitab Zabur kepada Dawud (QS. An-Nisa': 163, QS. Al-Isra': 55). Dawud memiliki suara yang sangat indah. Gunung-gunung dan burung-burung bertasbih bersamanya pagi dan petang (QS. Shad: 18-19, QS. Saba': 10). Rasulullah SAW memuji bacaan Abu Musa Al-Asy'ari dengan menyebutnya diberi seruling dari seruling keluarga Dawud (HR. Bukhari dan Muslim).

## Melunakkan Besi
Allah melunakkan besi untuknya dan mengajarinya membuat baju besi untuk melindungi manusia dalam peperangan (QS. Saba': 10-11, QS. Al-Anbiya: 80). Rasulullah SAW bersabda bahwa Dawud makan dari hasil kerja tangannya sendiri (HR. Bukhari).

## Ibadah dan Keadilan
Rasulullah SAW bersabda bahwa puasa yang paling dicintai Allah adalah puasa Dawud, yaitu berpuasa sehari dan berbuka sehari, dan salat yang paling dicintai Allah adalah salat Dawud: tidur separuh malam, bangun sepertiganya, lalu tidur seperenamnya (HR. Bukhari dan Muslim).

Al-Qur'an menceritakan dua orang berselisih yang memanjat dinding mihrab Dawud untuk meminta keputusan tentang kambing. Setelah memutuskan, Dawud menyadari bahwa itu ujian baginya, lalu ia memohon ampun, tersungkur sujud, dan bertaubat (QS. Shad: 21-25). Allah berfirman: "Wahai Dawud, sesungguhnya Kami menjadikanmu khalifah di bumi, maka berilah keputusan di antara manusia dengan adil dan janganlah mengikuti hawa nafsu" (QS. Shad: 26).''',
    hikmah:
        'Kekuasaan adalah amanah untuk menegakkan keadilan. Seorang raja tetap bekerja dengan tangannya sendiri, rajin beribadah, dan cepat bertaubat.',
    reference: 'QS. Al-Baqarah: 246-251 · QS. Shad: 17-26 · QS. Saba\': 10-11 · HR. Bukhari no. 2072 & 1131',
  ),
  SirahChapter(
    id: 'nabi_18_sulaiman',
    section: SirahSection.kisah25Nabi,
    order: 18,
    title: 'Nabi Sulaiman AS',
    periodOrTitle: 'Nabi ke-18 · Raja yang diberi kerajaan tanpa tandingan',
    narrative: '''## Pewaris Dawud
Sulaiman mewarisi kenabian dan kerajaan ayahnya, Nabi Dawud AS. Ia berkata, "Wahai manusia, kami telah diajari bahasa burung dan kami diberi segala sesuatu" (QS. An-Naml: 16). Ia berdoa: "Ya Tuhanku, ampunilah aku dan anugerahkanlah kepadaku kerajaan yang tidak dimiliki oleh seorang pun sesudahku" (QS. Shad: 35). Allah menundukkan angin yang berhembus menurut perintahnya, serta jin yang bekerja membangun gedung, patung, dan bejana besar untuknya (QS. Saba': 12-13).

## Lembah Semut
Ketika Sulaiman dan pasukannya melewati lembah semut, seekor semut berkata, "Wahai semut-semut, masuklah ke sarang kalian, agar kalian tidak terinjak oleh Sulaiman dan bala tentaranya, sedangkan mereka tidak menyadari." Sulaiman tersenyum lalu berdoa: "Ya Tuhanku, anugerahkanlah aku ilham untuk tetap mensyukuri nikmat-Mu yang telah Engkau anugerahkan kepadaku dan kepada kedua orang tuaku, dan agar aku mengerjakan kebajikan yang Engkau ridai" (QS. An-Naml: 18-19).

## Burung Hud-hud dan Ratu Saba'
Sulaiman memeriksa burung-burung dan mendapati hud-hud tidak ada. Hud-hud datang membawa kabar tentang negeri Saba' yang dipimpin seorang ratu dan kaumnya menyembah matahari (QS. An-Naml: 20-26). Nama Bilqis bagi ratu itu berasal dari riwayat ahli sejarah. Sulaiman mengirim surat yang diawali "Bismillahir Rahmanir Rahim", mengajak mereka berserah diri kepada Allah (QS. An-Naml: 30-31). Ratu mengirim hadiah, tetapi Sulaiman menolaknya. Singgasana ratu dipindahkan ke istana Sulaiman dalam sekejap mata oleh seorang yang memiliki ilmu dari Kitab. Sulaiman berkata, "Ini termasuk karunia Tuhanku untuk mengujiku, apakah aku bersyukur atau kufur" (QS. An-Naml: 40). Akhirnya ratu berkata, "Aku berserah diri bersama Sulaiman kepada Allah, Tuhan seluruh alam" (QS. An-Naml: 44).

## Wafat Bersandar Tongkat
Sulaiman wafat dalam keadaan berdiri bersandar pada tongkatnya. Para jin tetap bekerja keras karena mengira ia masih hidup, sampai rayap memakan tongkat itu dan ia tersungkur. Barulah jin sadar bahwa mereka tidak mengetahui yang gaib (QS. Saba': 14).''',
    hikmah:
        'Kekuasaan dan kekayaan adalah ujian syukur. Raja terbesar pun tetap rendah hati, mendengar suara makhluk yang paling kecil, dan menisbatkan semua nikmat kepada Allah.',
    reference: 'QS. An-Naml: 15-44 · QS. Saba\': 12-14 · QS. Shad: 30-40 · QS. Al-Anbiya: 78-82',
  ),
  SirahChapter(
    id: 'nabi_19_ilyas',
    section: SirahSection.kisah25Nabi,
    order: 19,
    title: 'Nabi Ilyas AS',
    periodOrTitle: 'Nabi ke-19 · Diutus kepada penyembah berhala Ba\'l',
    narrative: '''## Seorang Rasul dari Keturunan Harun
Menurut ahli sejarah, Ilyas adalah keturunan Nabi Harun AS yang diutus kepada Bani Israil di negeri Syam setelah masa Nabi Sulaiman AS. Sebagian riwayat menyebut kotanya bernama Ba'labak, di Lebanon sekarang. Al-Qur'an menegaskan, "Dan sesungguhnya Ilyas benar-benar termasuk salah seorang rasul" (QS. Ash-Shaffat: 123).

## Dakwah Melawan Penyembahan Ba'l
Kaumnya menyembah berhala bernama Ba'l. Ilyas berkata kepada mereka, "Mengapa kalian tidak bertakwa? Patutkah kalian menyembah Ba'l dan meninggalkan sebaik-baik Pencipta, yaitu Allah, Tuhan kalian dan Tuhan nenek moyang kalian terdahulu?" (QS. Ash-Shaffat: 124-126).

Kaumnya mendustakannya, maka mereka akan diseret ke dalam azab, kecuali hamba-hamba Allah yang ikhlas (QS. Ash-Shaffat: 127-128). Allah mengabadikan pujian baginya di kalangan orang-orang yang datang kemudian: "Salam sejahtera bagi Ilyas" (QS. Ash-Shaffat: 129-130). Ia juga disebut bersama Zakariya, Yahya, dan 'Isa sebagai orang-orang saleh (QS. Al-An'am: 85).

## Kisah dalam Riwayat
Kitab-kitab sejarah memuat banyak cerita tentang Ilyas, misalnya tentang kemarau panjang dan kaumnya yang mengusirnya, tetapi riwayat-riwayat itu kebanyakan berasal dari Ahli Kitab dan tidak dapat dipastikan kebenarannya. Ilyasa' dikenal sebagai penerus dakwahnya.''',
    hikmah:
        'Keberanian mempertahankan tauhid di tengah kaum yang menyimpang. Allah mengabadikan nama baik hamba-Nya yang ikhlas walaupun kaumnya menolak.',
    reference: 'QS. Ash-Shaffat: 123-132 · QS. Al-An\'am: 85 · Qashashul Anbiya (Ibnu Katsir)',
  ),
  SirahChapter(
    id: 'nabi_20_ilyasa',
    section: SirahSection.kisah25Nabi,
    order: 20,
    title: 'Nabi Ilyasa\' AS',
    periodOrTitle: 'Nabi ke-20 · Penerus dakwah Nabi Ilyas',
    narrative: '''## Disebut dalam Al-Qur'an
Nama Ilyasa' disebut dua kali dalam Al-Qur'an, keduanya dalam deretan nabi-nabi yang dimuliakan: "Dan Isma'il, Ilyasa', Yunus, dan Luth. Masing-masing Kami lebihkan derajatnya di atas umat lain (pada masanya)" (QS. Al-An'am: 86). "Dan ingatlah Isma'il, Ilyasa', dan Dzulkifli. Semuanya termasuk orang-orang yang paling baik" (QS. Shad: 48).

## Melanjutkan Perjuangan Ilyas
Menurut ahli sejarah, Ilyasa' hidup bersama Nabi Ilyas AS dan menjadi muridnya. Setelah Ilyas, ia melanjutkan dakwah kepada Bani Israil di Syam, mengajak mereka tetap menyembah Allah dan meninggalkan berhala, serta menjalankan syariat Taurat. Rincian kehidupannya tidak diceritakan dalam Al-Qur'an maupun hadits sahih, dan cerita-cerita tentangnya dalam kitab sejarah berasal dari sumber Ahli Kitab.

## Kedudukannya
Walaupun kisahnya singkat, Allah menempatkannya di antara orang-orang pilihan dan paling baik. Ini menunjukkan bahwa kemuliaan seorang hamba tidak diukur dari terkenal atau tidaknya, melainkan dari keistiqamahannya menjalankan amanah.''',
    hikmah:
        'Meneruskan perjuangan guru dengan setia adalah bentuk dakwah yang mulia. Konsistensi lebih bernilai daripada popularitas.',
    reference: 'QS. Al-An\'am: 86 · QS. Shad: 48 · Qashashul Anbiya (Ibnu Katsir)',
  ),
  SirahChapter(
    id: 'nabi_21_yunus',
    section: SirahSection.kisah25Nabi,
    order: 21,
    title: 'Nabi Yunus AS',
    periodOrTitle: 'Nabi ke-21 · Dzun Nun (yang ditelan ikan)',
    narrative: '''## Meninggalkan Kaumnya
Nabi Yunus AS diutus kepada penduduk sebuah negeri yang, menurut ahli sejarah, bernama Ninawa (di Irak sekarang). Kaumnya menolak dakwahnya. Yunus pergi meninggalkan mereka dalam keadaan marah sebelum datang izin dari Allah, dan mengira Allah tidak akan menyempitkannya (QS. Al-Anbiya: 87).

## Ditelan Ikan Besar
Yunus naik ke sebuah kapal yang penuh muatan. Kapal itu terancam tenggelam, lalu para penumpang mengundi siapa yang harus dilemparkan ke laut. Undian jatuh kepada Yunus. Ia dilemparkan ke laut dan ditelan ikan yang besar dalam keadaan tercela (QS. Ash-Shaffat: 139-142).

## Doa dalam Kegelapan
Di dalam tiga kegelapan, yaitu kegelapan malam, laut, dan perut ikan, Yunus berdoa: "La ilaha illa Anta, subhanaka, inni kuntu minazh-zhalimin" (Tidak ada tuhan selain Engkau, Mahasuci Engkau, sungguh aku termasuk orang-orang yang zalim) (QS. Al-Anbiya: 87). Allah mengabulkan doanya dan menyelamatkannya dari kedukaan, dan begitulah Allah menyelamatkan orang-orang yang beriman (QS. Al-Anbiya: 88). Rasulullah SAW bersabda bahwa tidaklah seorang muslim berdoa dengan doa ini dalam suatu urusan kecuali Allah mengabulkannya (HR. At-Tirmidzi).

Seandainya Yunus tidak termasuk orang yang banyak bertasbih, ia akan tetap di perut ikan hingga hari kebangkitan (QS. Ash-Shaffat: 143-144).

## Kaumnya Beriman
Ikan itu memuntahkannya ke daratan yang tandus dalam keadaan sakit, dan Allah menumbuhkan sejenis pohon labu untuk menaunginya (QS. Ash-Shaffat: 145-146). Sementara itu kaumnya, ketika melihat tanda-tanda azab, bertaubat dan beriman. Mereka satu-satunya kaum yang azabnya diangkat setelah beriman (QS. Yunus: 98). Yunus kembali kepada mereka yang jumlahnya seratus ribu orang atau lebih, dan mereka beriman (QS. Ash-Shaffat: 147-148).''',
    hikmah:
        'Jangan berputus asa dalam berdakwah dan jangan tergesa-gesa. Pengakuan atas kesalahan dan tasbih yang tulus membuka jalan keluar dari kegelapan apa pun.',
    reference: 'QS. Al-Anbiya: 87-88 · QS. Ash-Shaffat: 139-148 · QS. Yunus: 98 · Sunan At-Tirmidzi no. 3505',
  ),
  SirahChapter(
    id: 'nabi_22_zakariya',
    section: SirahSection.kisah25Nabi,
    order: 22,
    title: 'Nabi Zakariya AS',
    periodOrTitle: 'Nabi ke-22 · Pengasuh Maryam · Ayah Nabi Yahya',
    narrative: '''## Mengasuh Maryam
Istri Imran bernazar bahwa anak yang dikandungnya akan dipersembahkan untuk berkhidmat di Baitul Maqdis. Yang lahir adalah Maryam. Allah menerimanya dengan penerimaan yang baik, dan Zakariya, suami bibi Maryam menurut riwayat, menjadi pengasuhnya (QS. Ali Imran: 35-37). Setiap kali Zakariya masuk ke mihrab, ia mendapati makanan di sisi Maryam. Ketika ditanya, Maryam menjawab, "Makanan itu dari sisi Allah. Sesungguhnya Allah memberi rezeki kepada siapa yang Dia kehendaki tanpa perhitungan" (QS. Ali Imran: 37).

## Doa yang Lembut
Melihat itu, Zakariya yang sudah tua dan istrinya mandul berdoa dengan suara yang lembut: "Ya Tuhanku, sungguh tulangku telah lemah dan kepalaku telah dipenuhi uban, dan aku belum pernah kecewa dalam berdoa kepada-Mu, ya Tuhanku" (QS. Maryam: 3-4). Ia memohon seorang anak yang akan mewarisi kenabian dan menjaga agama, karena khawatir terhadap kerabatnya sepeninggalnya (QS. Maryam: 5-6). Doanya yang lain: "Ya Tuhanku, janganlah Engkau biarkan aku hidup seorang diri, dan Engkaulah sebaik-baik waris" (QS. Al-Anbiya: 89).

## Kabar Gembira
Para malaikat memanggilnya ketika ia sedang salat di mihrab, memberi kabar gembira tentang kelahiran Yahya (QS. Ali Imran: 39). Zakariya heran bagaimana ia bisa memiliki anak dalam keadaan tua dan istrinya mandul. Allah menjawab bahwa hal itu mudah bagi-Nya. Sebagai tanda, Zakariya tidak dapat berbicara dengan manusia selama tiga malam padahal ia sehat, dan hanya memberi isyarat agar orang bertasbih pagi dan petang (QS. Maryam: 8-11).

Allah memuji keluarga ini: "Sesungguhnya mereka selalu bersegera dalam kebaikan, berdoa kepada Kami dengan penuh harap dan cemas, dan mereka orang-orang yang khusyuk kepada Kami" (QS. Al-Anbiya: 90).''',
    hikmah:
        'Jangan berhenti berdoa walaupun keadaan tampak mustahil. Doa yang dipanjatkan dengan rendah hati dan penuh harap dijawab Allah dengan cara-Nya.',
    reference: 'QS. Ali Imran: 35-41 · QS. Maryam: 2-11 · QS. Al-Anbiya: 89-90',
  ),
  SirahChapter(
    id: 'nabi_23_yahya',
    section: SirahSection.kisah25Nabi,
    order: 23,
    title: 'Nabi Yahya AS',
    periodOrTitle: 'Nabi ke-23 · Putra Zakariya · Penegas kedatangan \'Isa',
    narrative: '''## Nama yang Belum Pernah Ada
Allah memberi kabar gembira kepada Zakariya: "Wahai Zakariya, Kami memberi kabar gembira kepadamu dengan seorang anak laki-laki yang namanya Yahya, yang Kami belum pernah memberikan nama seperti itu kepada siapa pun sebelumnya" (QS. Maryam: 7).

## Hikmah Sejak Kecil
Allah berfirman: "Wahai Yahya, ambillah Kitab (Taurat) itu dengan sungguh-sungguh." Allah memberinya hikmah sejak masih kanak-kanak, rasa belas kasih dari sisi Allah, dan kesucian. Ia seorang yang bertakwa, berbakti kepada kedua orang tuanya, dan bukan orang yang sombong lagi durhaka (QS. Maryam: 12-14).

Allah juga menyebutnya sebagai orang yang membenarkan kalimat dari Allah, yaitu Nabi 'Isa AS, menjadi panutan, menahan diri dari hawa nafsu, dan seorang nabi dari kalangan orang saleh (QS. Ali Imran: 39). Yahya dan 'Isa adalah saudara sepupu menurut riwayat, dan Rasulullah SAW bertemu keduanya di langit kedua pada malam Mi'raj (HR. Bukhari dan Muslim).

## Salam pada Tiga Keadaan
Allah memberinya salam pada tiga keadaan yang paling menakutkan bagi manusia: "Kesejahteraan atas dirinya pada hari ia dilahirkan, pada hari ia wafat, dan pada hari ia dibangkitkan hidup kembali" (QS. Maryam: 15).

## Wafatnya
Banyak riwayat sejarah menyebutkan bahwa Yahya wafat terbunuh oleh seorang penguasa zalim karena menolak membenarkan perbuatan yang dilarang syariat. Rincian kisah ini berasal dari riwayat sejarah dan Ahli Kitab, sehingga tidak dipastikan rinciannya.''',
    hikmah:
        'Ilmu dan kesungguhan memegang agama bisa dimiliki sejak usia muda. Bakti kepada orang tua dan kerendahan hati adalah ciri orang yang dekat dengan Allah.',
    reference: 'QS. Maryam: 7, 12-15 · QS. Ali Imran: 38-41 · HR. Bukhari no. 3887 · HR. Muslim no. 162',
  ),
  SirahChapter(
    id: 'nabi_24_isa',
    section: SirahSection.kisah25Nabi,
    order: 24,
    title: 'Nabi \'Isa AS',
    periodOrTitle: 'Nabi ke-24 · Rasul Ulul Azmi · Al-Masih · Penerima Injil',
    narrative: '''## Maryam yang Suci
Maryam binti Imran tumbuh dalam ibadah di Baitul Maqdis. Allah memilihnya dan menyucikannya di atas perempuan seluruh alam (QS. Ali Imran: 42). Jibril datang dalam rupa manusia dan memberi kabar bahwa ia akan mengandung seorang anak laki-laki yang suci. Maryam heran karena tidak pernah disentuh laki-laki, dan Jibril menjawab bahwa hal itu mudah bagi Allah (QS. Maryam: 16-21). Penciptaan 'Isa seperti penciptaan Adam: Allah berfirman "Jadilah", maka jadilah ia (QS. Ali Imran: 59).

## Kelahiran dan Berbicara Saat Bayi
Saat hendak melahirkan, Maryam bersandar pada pangkal pohon kurma. Ia diperintahkan menggoyangkan pohon itu agar kurma matang berjatuhan, dan di bawahnya mengalir anak sungai (QS. Maryam: 23-26). Ketika ia membawa bayinya kepada kaumnya, mereka menuduhnya. Maryam menunjuk bayinya, lalu 'Isa berbicara: "Sesungguhnya aku hamba Allah. Dia memberiku Kitab dan menjadikan aku seorang nabi" (QS. Maryam: 27-33).

## Mukjizat dengan Izin Allah
'Isa diutus kepada Bani Israil dengan Injil dan membenarkan Taurat. Dengan izin Allah ia membuat bentuk burung dari tanah lalu meniupnya hingga menjadi burung, menyembuhkan orang buta sejak lahir dan penderita kusta, menghidupkan orang mati, dan memberitahukan apa yang mereka makan dan simpan di rumah mereka (QS. Ali Imran: 49). Atas permintaan para pengikutnya, Hawariyyun, Allah menurunkan hidangan dari langit (QS. Al-Ma'idah: 112-115).

## Tidak Disalib, Diangkat kepada Allah
Para pemuka yang ingkar bersekongkol untuk membunuhnya. Allah berfirman bahwa mereka tidak membunuhnya dan tidak menyalibnya, tetapi diserupakan bagi mereka, dan Allah mengangkatnya kepada-Nya (QS. An-Nisa': 157-158).

## Kabar tentang Ahmad
'Isa menyampaikan kabar gembira tentang seorang rasul sesudahnya yang bernama Ahmad (QS. Ash-Shaff: 6). Rasulullah SAW juga mengabarkan bahwa 'Isa akan turun kembali menjelang hari kiamat sebagai hakim yang adil yang mengikuti syariat Islam (HR. Bukhari dan Muslim). Di akhirat, 'Isa akan menegaskan bahwa ia tidak pernah menyuruh manusia menyembah dirinya dan ibunya (QS. Al-Ma'idah: 116-117).''',
    hikmah:
        'Mukjizat sebesar apa pun terjadi dengan izin Allah. \'Isa adalah hamba dan rasul Allah yang mulia, dan memuliakannya berarti meyakini apa yang dikatakan Al-Qur\'an tentang dirinya.',
    reference: 'QS. Ali Imran: 42-59 · QS. Maryam: 16-36 · QS. An-Nisa\': 157-159 · QS. Ash-Shaff: 6 · HR. Bukhari no. 3448',
  ),
  SirahChapter(
    id: 'nabi_25_muhammad',
    section: SirahSection.kisah25Nabi,
    order: 25,
    title: 'Nabi Muhammad SAW',
    periodOrTitle: 'Nabi ke-25 · Rasul Ulul Azmi · Khatamun Nabiyyin',
    narrative: '''## Penutup Para Nabi
Muhammad bin Abdullah SAW adalah nabi dan rasul terakhir. "Muhammad itu bukanlah bapak dari seorang laki-laki di antara kalian, tetapi dia adalah utusan Allah dan penutup para nabi" (QS. Al-Ahzab: 40). Rasulullah SAW mengumpamakan dirinya seperti batu bata terakhir yang menyempurnakan sebuah bangunan indah yang dibangun para nabi sebelumnya (HR. Bukhari dan Muslim).

## Diutus untuk Seluruh Manusia
Para nabi sebelumnya diutus khusus kepada kaumnya, sedangkan beliau diutus kepada seluruh manusia (QS. Saba': 28) sebagai rahmat bagi seluruh alam (QS. Al-Anbiya: 107). Doa Nabi Ibrahim AS dan kabar gembira Nabi 'Isa AS terwujud dengan diutusnya beliau (QS. Al-Baqarah: 129, QS. Ash-Shaff: 6).

## Mukjizat Terbesar: Al-Qur'an
Mukjizat para nabi terdahulu berakhir bersama wafatnya mereka, sedangkan mukjizat terbesar Rasulullah SAW, yaitu Al-Qur'an, tetap ada dan terjaga hingga akhir zaman (QS. Al-Hijr: 9). Allah menantang manusia untuk membuat satu surah saja yang serupa dengannya (QS. Al-Baqarah: 23). Mukjizat lain beliau di antaranya Isra' Mi'raj (QS. Al-Isra': 1), terbelahnya bulan (QS. Al-Qamar: 1-2), dan air yang memancar dari sela-sela jari beliau (HR. Bukhari).

## Akhlak yang Agung
Allah memuji beliau: "Sesungguhnya engkau benar-benar berbudi pekerti yang agung" (QS. Al-Qalam: 4). Ketika Aisyah RA ditanya tentang akhlak beliau, ia menjawab, "Akhlak beliau adalah Al-Qur'an" (HR. Muslim). Beliau penyayang kepada anak-anak, lembut kepada keluarga, adil kepada musuh, dan sangat peduli kepada umatnya (QS. At-Taubah: 128).

## Kisah Lengkap Beliau
Perjalanan hidup Rasulullah SAW dari kelahiran, masa kenabian di Makkah, hijrah, perjuangan di Madinah, hingga wafat diceritakan secara berurutan dalam 24 bab pada tab Sirah Nabawiyah.''',
    hikmah:
        'Seluruh nabi membawa risalah tauhid yang sama, dan risalah itu disempurnakan oleh Nabi Muhammad SAW. Mengikuti beliau adalah jalan mencintai Allah (QS. Ali Imran: 31).',
    reference: 'QS. Al-Ahzab: 21, 40 · QS. Al-Anbiya: 107 · QS. Al-Qalam: 4 · HR. Bukhari no. 3535 · HR. Muslim no. 746',
  ),
];
