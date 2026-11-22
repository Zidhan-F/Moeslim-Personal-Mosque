import 'package:moeslim_brand/material_3d.dart';

import '../features/masjid/masjid_home_page.dart';
import 'components.dart';

/// Berpindah core. Personal adalah aplikasi utama; Mosque adalah fitur tambahan opsional (ADR 0005).
void switchCore(BuildContext context, AppCore target, {required AppCore from}) {
  if (target == from) return;
  if (target == AppCore.mosque) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MasjidHomePage()));
  } else {
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}
