import 'package:material_ui/material_ui.dart';
import 'soft_art.dart';

/// Nama ilustrasi lama dipertahankan agar rute aplikasi memakai koleksi 3D yang sama.
enum BrandIllustration {
  /// Masjid & pepohonan dalam jendela lengkung + Al-Qur'an di rehal (onboarding, daftar surah, doa).
  heroQuran('hero_quran'),

  /// Masjid dalam lingkaran langit dengan pepohonan (pilih peran).
  mosqueCircle('mosque_circle'),

  /// Masjid putih berkubah emas + palem, latar transparan (banner hijau Mosque).
  mosqueBanner('mosque_banner'),

  /// Siluet masjid hijau tua (banner sapaan Beranda).
  skyline('skyline'),

  kaaba('kaaba'),

  /// Perisai bergembok di atas laptop (login admin).
  loginShield('login_shield'),

  /// Pemandangan masjid lebar (TV Display).
  tvMosque('tv_mosque'),

  /// Lengkung berkisi hijau + siluet masjid emas (kepala Jadwal Salat, Detail Doa, Mushaf).
  archHeader('arch_header'),

  /// Menara & pohon pucat di sisi cincin tasbih.
  tasbihSide('tasbih_side'),

  /// Ornamen kisi di sudut halaman.
  cornerLattice('corner_lattice'),

  /// Lencana qari generik (tanpa wajah orang sungguhan).
  qariBadge('qari_badge'),

  /// Panduan kalibrasi kompas (angka 8).
  calibrate('calibrate'),

  // --- Asset kit (raster, latar dibuat transparan; 768×512) ---
  /// Masjid putih berkubah hijau, matahari pagi & pepohonan (onboarding, Beranda).
  masjidPagi1('masjid_pagi_1', fromKit: true),
  masjidPagi2('masjid_pagi_2', fromKit: true),
  masjidPagi3('masjid_pagi_3', fromKit: true),
  masjidPagi4('masjid_pagi_4', fromKit: true),

  /// Al-Qur'an terbuka di rehal dalam lengkung hijau-emas.
  alquranRehal1('alquran_rehal_1', fromKit: true),
  alquranRehal2('alquran_rehal_2', fromKit: true),
  alquranRehal3('alquran_rehal_3', fromKit: true),
  alquranRehal4('alquran_rehal_4', fromKit: true),

  /// Masjid malam dengan bulan sabit & lentera (Ramadan, mode malam).
  ramadanMalam1('ramadan_malam_1', fromKit: true),
  ramadanMalam2('ramadan_malam_2', fromKit: true),
  ramadanMalam3('ramadan_malam_3', fromKit: true),
  ramadanMalam4('ramadan_malam_4', fromKit: true),

  /// Masjid + kalender, kas, buku, daftar periksa, jamaah (Moeslim Mosque).
  manajemenMasjid1('manajemen_masjid_1', fromKit: true),
  manajemenMasjid2('manajemen_masjid_2', fromKit: true),
  manajemenMasjid3('manajemen_masjid_3', fromKit: true),
  manajemenMasjid4('manajemen_masjid_4', fromKit: true);

  final String file;

  /// true = dari asset kit (raster); false = digambar ulang dari `tools/illustrations/svg/`.
  final bool fromKit;
  const BrandIllustration(this.file, {this.fromKit = false});

  SoftAsset get softAsset => switch (this) {
        heroQuran || alquranRehal1 || alquranRehal2 || alquranRehal3 || alquranRehal4 => SoftAsset.quran,
        mosqueCircle ||
        mosqueBanner ||
        skyline ||
        masjidPagi1 ||
        masjidPagi2 ||
        masjidPagi3 ||
        masjidPagi4 =>
          SoftAsset.mosque,
        ramadanMalam1 || ramadanMalam2 || ramadanMalam3 || ramadanMalam4 => SoftAsset.lantern,
        manajemenMasjid1 || manajemenMasjid2 || manajemenMasjid3 || manajemenMasjid4 => SoftAsset.management,
        kaaba => SoftAsset.kaaba,
        loginShield => SoftAsset.shield,
        tvMosque => SoftAsset.scene,
        archHeader || cornerLattice => SoftAsset.relief,
        tasbihSide => SoftAsset.tasbih,
        qariBadge => SoftAsset.headphones,
        calibrate => SoftAsset.phone,
      };

  String get assetPath => softAsset.assetPath;
}

/// Gambar ilustrasi dekoratif (tidak dibacakan pembaca layar).
class BrandArt extends StatelessWidget {
  final BrandIllustration art;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final double opacity;

  const BrandArt(
    this.art, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) => SoftArt(
        art.softAsset,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        opacity: opacity,
        thumbnail: width != null && width! <= 64 && (height == null || height! <= 64),
      );
}
