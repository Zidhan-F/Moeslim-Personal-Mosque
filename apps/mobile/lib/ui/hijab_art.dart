import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

class HijabWomanArt extends StatelessWidget {
  final double size;
  const HijabWomanArt({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => SoftArt(SoftAsset.muslimah, width: size, height: size, thumbnail: size <= 64);
}
