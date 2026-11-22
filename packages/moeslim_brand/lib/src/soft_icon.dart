import 'package:material_ui/material_ui.dart' as material;

import 'icons.dart';
import 'soft_art.dart';

class Icon extends material.Icon {
  const Icon(
    super.icon, {
    super.key,
    super.size,
    super.fill,
    super.weight,
    super.grade,
    super.opticalSize,
    super.color,
    super.shadows,
    super.semanticLabel,
    super.textDirection,
    super.applyTextScaling,
    super.blendMode,
    super.fontWeight,
  });

  static final _objects = <material.IconData, SoftAsset>{
    MoeslimIcons.beranda: SoftAsset.home,
    MoeslimIcons.rumah: SoftAsset.home,
    MoeslimIcons.masjid: SoftAsset.mosque,
    MoeslimIcons.alquran: SoftAsset.quran,
    MoeslimIcons.quranTerbuka: SoftAsset.quran,
    MoeslimIcons.buku: SoftAsset.quran,
    MoeslimIcons.tasbih: SoftAsset.tasbih,
    MoeslimIcons.kiblat: SoftAsset.compass,
    MoeslimIcons.kompas: SoftAsset.compass,
    MoeslimIcons.kalender: SoftAsset.calendar,
    MoeslimIcons.kegiatan: SoftAsset.calendar,
    MoeslimIcons.jam: SoftAsset.clock,
    MoeslimIcons.waktuSholat: SoftAsset.clock,
    MoeslimIcons.ponsel: SoftAsset.phone,
    MoeslimIcons.audio: SoftAsset.headphones,
    MoeslimIcons.musik: SoftAsset.headphones,
    MoeslimIcons.profil: SoftAsset.profile,
    MoeslimIcons.admin: SoftAsset.profile,
    MoeslimIcons.pengurus: SoftAsset.profile,
    MoeslimIcons.petugas: SoftAsset.profile,
    MoeslimIcons.jamaah: SoftAsset.profile,
    MoeslimIcons.jemaah: SoftAsset.profile,
    MoeslimIcons.peta: SoftAsset.location,
    MoeslimIcons.lokasi: SoftAsset.location,
    MoeslimIcons.keuangan: SoftAsset.finance,
    MoeslimIcons.saldo: SoftAsset.finance,
    MoeslimIcons.donasi: SoftAsset.finance,
    MoeslimIcons.anggaran: SoftAsset.finance,
    MoeslimIcons.layarTv: SoftAsset.display,
    MoeslimIcons.komputer: SoftAsset.display,
    MoeslimIcons.shield: SoftAsset.shield,
    MoeslimIcons.pengaman: SoftAsset.shield,
    MoeslimIcons.laporan: SoftAsset.receipt,
    MoeslimIcons.report: SoftAsset.receipt,
    MoeslimIcons.inventaris: SoftAsset.management,
    MoeslimIcons.grid: SoftAsset.apps,
    MoeslimIcons.bulan: SoftAsset.lantern,
    MoeslimIcons.zikr: SoftAsset.dua,
    MoeslimIcons.sajadah: SoftAsset.prayerMat,
    MoeslimIcons.kubah: SoftAsset.mosque,
    MoeslimIcons.pencarian: SoftAsset.search,
    MoeslimIcons.keterangan: SoftAsset.journal,
    MoeslimIcons.histori: SoftAsset.clock,
    MoeslimIcons.edit: SoftAsset.journal,
    MoeslimIcons.pengingat: SoftAsset.calendar,
    MoeslimIcons.sholatSubuh: SoftAsset.prayerTime,
    MoeslimIcons.sholatDzuhur: SoftAsset.prayerTime,
    MoeslimIcons.sholatAshar: SoftAsset.prayerTime,
    MoeslimIcons.sholatMaghrib: SoftAsset.prayerTime,
    MoeslimIcons.sholatIsya: SoftAsset.prayerTime,
    material.Icons.menu_book: SoftAsset.quran,
    material.Icons.calendar_month: SoftAsset.calendar,
    material.Icons.account_balance_wallet: SoftAsset.finance,
    material.Icons.headphones: SoftAsset.headphones,
    material.Icons.mosque: SoftAsset.mosque,
    material.Icons.person: SoftAsset.profile,
    material.Icons.home: SoftAsset.home,
  };

  @override
  material.Widget build(material.BuildContext context) {
    if (icon == null) return super.build(context);
    final theme = material.IconTheme.of(context);
    var dimension = size ?? theme.size ?? 24;
    if (applyTextScaling ?? theme.applyTextScaling ?? false) {
      dimension = material.MediaQuery.textScalerOf(context).scale(dimension);
    }
    final tint = color ?? theme.color ?? material.Theme.of(context).colorScheme.onSurface;
    final opacity = (theme.opacity ?? 1) * tint.a;
    final asset = _objects[icon];
    if (asset != null && opacity >= .6) {
      return material.Semantics(
        label: semanticLabel,
        child: SoftArt(asset, width: dimension, height: dimension, thumbnail: dimension <= 64, opacity: opacity),
      );
    }
    // A short extruded edge preserves the exact glyph and state color on small controls.
    return material.Icon(
      icon,
      size: size,
      color: color,
      fill: fill,
      weight: weight,
      grade: grade,
      opticalSize: opticalSize,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      applyTextScaling: applyTextScaling,
      blendMode: blendMode,
      fontWeight: fontWeight,
      shadows: shadows ??
          [
            material.Shadow(
                color: material.Colors.black.withValues(alpha: .18 * opacity),
                offset: const material.Offset(.7, 1.1),
                blurRadius: .6),
            material.Shadow(
                color: material.Colors.white.withValues(alpha: .22 * opacity),
                offset: const material.Offset(-.35, -.4)),
          ],
    ).build(context);
  }
}
