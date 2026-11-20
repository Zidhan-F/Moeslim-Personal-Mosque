import 'package:material_ui/material_ui.dart';

/// Ilustrasi brand (digambar ulang dari paket visualisasi UI; sumber SVG di `tools/illustrations/`).
enum BrandIllustration {
  /// Masjid & pepohonan dalam jendela lengkung + Al-Qur'an di rehal (onboarding, daftar surah, doa).
  heroQuran('hero_quran'),

  /// Masjid dalam lingkaran langit dengan pepohonan (pilih peran).
  mosqueCircle('mosque_circle'),

  /// Masjid putih berkubah emas + palem, latar transparan (banner hijau Mosque).
  mosqueBanner('mosque_banner'),

  /// Siluet masjid hijau tua (banner sapaan Beranda).
  skyline('skyline'),

  /// Lengkung emas, lentera, Al-Qur'an (banner 7 Irama).
  naghomLantern('naghom_lantern'),
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
  calibrate('calibrate');

  final String file;
  const BrandIllustration(this.file);

  String get assetPath => 'assets/illustrations/$file.webp';
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
  Widget build(BuildContext context) => Image.asset(
    art.assetPath,
    package: 'moeslim_brand',
    width: width,
    height: height,
    fit: fit,
    alignment: alignment,
    opacity: opacity == 1 ? null : AlwaysStoppedAnimation(opacity),
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
    gaplessPlayback: true,
  );
}
