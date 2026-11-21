import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

void main() {
  test('setiap ilustrasi brand punya berkas aset (dan sumber SVG untuk yang digambar ulang)', () {
    for (final a in BrandIllustration.values) {
      expect(File(a.assetPath).existsSync(), isTrue, reason: a.assetPath);
      if (!a.fromKit) {
        expect(File('../../tools/illustrations/svg/${a.file}.svg').existsSync(), isTrue, reason: a.file);
      }
    }
  });
}
