import 'package:material_ui/material_ui.dart';

enum SoftAsset {
  mosque,
  quran,
  tasbih,
  lantern,
  kaaba,
  calendar,
  prayerMat,
  compass,
  headphones,
  shield,
  finance,
  clock,
  journal,
  display,
  profile,
  home,
  location,
  apps,
  offline,
  search,
  receipt,
  management,
  dua,
  prayerTime,
  phone,
  scene,
  relief,
  reliefDark;

  String get assetPath => 'assets/3d/$name.webp';
  String get thumbnailPath => 'assets/3d/thumbs/$name.webp';
}

class SoftArt extends StatelessWidget {
  final SoftAsset asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final double opacity;
  final bool thumbnail;

  const SoftArt(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.opacity = 1,
    this.thumbnail = false,
  });

  @override
  Widget build(BuildContext context) => Image.asset(
        thumbnail ? asset.thumbnailPath : asset.assetPath,
        package: 'moeslim_brand',
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        opacity: opacity == 1 ? null : AlwaysStoppedAnimation(opacity),
        excludeFromSemantics: true,
        filterQuality: FilterQuality.medium,
      );
}
