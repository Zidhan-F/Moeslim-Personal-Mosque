import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import 'colors.dart';

/// Aset dari *Moeslim PM Complete Asset Kit* (diimpor lewat `tools/asset_kit/import_kit.py`).
///
/// Semua gambar di sini dekoratif: tidak dibacakan pembaca layar. Teks (judul empty state,
/// huruf mata angin) dirender Flutter dengan Inter agar bisa diperbesar & dibaca.

const _pkg = 'moeslim_brand';

bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

/// Mengganti warna terang asset kit dengan padanan mode gelap saat SVG diurai.
class BrandDarkColorMapper extends ColorMapper {
  const BrandDarkColorMapper();

  static const _map = <int, Color>{
    0xE6F5EC: Color(0xFF103D35), // mint → hijau malam sedikit lebih terang dari kartu (latar ubin & empty state)
    0xFFFFFF: BrandColors.nightSurface, // lingkaran putih di ubin
    0x087E65: BrandColors.emeraldLight, // garis emerald
    0x07372F: BrandColors.cream, // tinta gelap
    0xF7F7F1: BrandColors.nightSurface, // krem (pintu siluet masjid)
    0xFFFDF6: BrandColors.nightCard,
  };

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    final sub = _map[color.toARGB32() & 0xFFFFFF];
    return sub == null ? color : sub.withValues(alpha: color.a);
  }
}

Widget _svg(
  BuildContext context,
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  bool themed = true,
}) =>
    SvgPicture.asset(
      path,
      package: _pkg,
      width: width,
      height: height,
      fit: fit,
      excludeFromSemantics: true,
      colorMapper: themed && _isDark(context) ? const BrandDarkColorMapper() : null,
    );

// ---------------------------------------------------------------- ubin fitur

/// Ubin fitur 96×96 (latar mint, lingkaran putih, ikon bergaris emerald).
enum BrandTile {
  alquran('alquran'),
  arahKiblat('arah_kiblat'),
  catatanIbadah('catatan_ibadah'),
  display('display'),
  doaDzikir('doa_dzikir'),
  imam('imams'),
  iqamah('iqamah'),
  jadwalSholat('jadwal_sholat'),
  kalenderHijriah('kalender_hijriah'),
  keuangan('keuangan'),
  masjid('masjid'),
  ramadan('ramadan'),
  sajadah('sajadah'),
  tasbih('tasbih');

  final String file;
  const BrandTile(this.file);
  String get assetPath => 'assets/kit/tiles/$file.svg';
}

class FeatureTileArt extends StatelessWidget {
  final BrandTile tile;
  final double size;
  const FeatureTileArt(this.tile, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => _svg(context, tile.assetPath, width: size, height: size);
}

// ---------------------------------------------------------------- empty state

enum BrandEmptyArt {
  agenda('kosong_agenda'),
  transaksi('kosong_transaksi'),
  tanpaInternet('tanpa_internet'),
  tidakAdaHasil('tidak_ada_hasil');

  final String file;
  const BrandEmptyArt(this.file);
  String get assetPath => 'assets/kit/empty/$file.svg';
}

/// Tampilan kosong: gambar asset kit + judul + pesan (+ aksi opsional).
class BrandEmptyState extends StatelessWidget {
  final BrandEmptyArt art;
  final String title;
  final String? message;
  final Widget? action;
  final double artSize;

  const BrandEmptyState({
    super.key,
    required this.art,
    required this.title,
    this.message,
    this.action,
    this.artSize = 132,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _svg(context, art.assetPath, width: artSize, height: artSize),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- elemen fitur

enum BrandElement {
  /// Kepala mushaf (bingkai lengkung emas) 700×180.
  mushafHeader('quran/header_mushaf.svg'),

  /// Bingkai ayat/doa 720×320.
  ayahFrame('quran/bingkai_ayat.svg'),

  /// Pemisah ayat (garis emas + belah ketupat) 300×70.
  ayahDivider('quran/pemisah_ayat.svg'),

  /// Bulan sabit & bintang 300×270.
  crescentStar('decor/bulan_bintang.svg'),

  /// Siluet masjid 400×260.
  mosqueSilhouette('decor/siluet_masjid.svg'),

  /// Dial kompas kiblat 440×440 (tanpa huruf; huruf U/T/S/B dirender Flutter).
  compassDial('qibla/dial_kompas.svg'),

  /// Jarum kompas 440×440 (pusat di tengah, menunjuk ke atas).
  compassNeedle('qibla/jarum_kompas.svg');

  final String file;
  const BrandElement(this.file);
  String get assetPath => 'assets/kit/$file';

  /// Elemen yang sudah gelap/berwarna tetap (dial & jarum kompas) tidak dipetakan ulang.
  bool get themed => this != compassDial && this != compassNeedle;
}

class BrandElementArt extends StatelessWidget {
  final BrandElement element;
  final double? width;
  final double? height;
  final BoxFit fit;
  const BrandElementArt(this.element, {super.key, this.width, this.height, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) =>
      _svg(context, element.assetPath, width: width, height: height, fit: fit, themed: element.themed);
}

// ---------------------------------------------------------------- latar & pola

enum BrandBackground {
  splashGelap('splash_gelap'),
  personalTerang('personal_terang'),
  masjidTerang('masjid_terang'),
  ramadanGelap('ramadan_gelap'),
  alquranKrem('alquran_krem'),
  bannerGelap('banner_gelap'),
  bannerTerang('banner_terang'),
  headerMasjid('header_masjid'),
  tvGelap('tv_gelap'),
  tvTerang('tv_terang');

  final String file;
  const BrandBackground(this.file);
  String get assetPath => 'assets/backgrounds/$file.webp';

  DecorationImage decoration({BoxFit fit = BoxFit.cover, Alignment alignment = Alignment.topCenter}) =>
      DecorationImage(image: AssetImage(assetPath, package: _pkg), fit: fit, alignment: alignment);
}

/// Latar layar penuh dari asset kit; [dark] dipakai bila tema gelap (opsional).
class BrandBackdrop extends StatelessWidget {
  final BrandBackground light;
  final BrandBackground? dark;
  final Widget child;
  const BrandBackdrop({super.key, required this.light, this.dark, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = _isDark(context) ? dark : light;
    if (bg == null) return child;
    return DecoratedBox(decoration: BoxDecoration(image: bg.decoration()), child: child);
  }
}

/// Pola geometris seamless (satu warna) dari asset kit.
enum BrandPattern {
  anyaman('anyaman'),
  bintangDelapan('bintang_delapan'),
  bungaGeometri('bunga_geometri'),
  crescent('crescent'),
  diamonds('diamonds'),
  gelombang('gelombang'),
  lingkarIslam('lingkar_islam'),
  mihrab('mihrab');

  final String file;
  const BrandPattern(this.file);
  String get assetPath => 'assets/patterns/$file.png';

  /// Ubin berulang berwarna [color] (gunakan alfa rendah, mis. 6–12%). [tile] = sisi ubin (dp).
  DecorationImage decoration({required Color color, double tile = 48}) => DecorationImage(
        image: AssetImage(assetPath, package: _pkg),
        repeat: ImageRepeat.repeat,
        scale: 384 / tile,
        alignment: Alignment.topLeft,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        filterQuality: FilterQuality.medium,
      );
}
