import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

void main() {
  test('setiap aset asset kit yang dirujuk enum ada di paket', () {
    final paths = [
      for (final t in BrandTile.values) t.assetPath,
      for (final e in BrandEmptyArt.values) e.assetPath,
      for (final e in BrandElement.values) e.assetPath,
      for (final b in BrandBackground.values) b.assetPath,
      for (final p in BrandPattern.values) p.assetPath,
    ];
    for (final p in paths) {
      expect(File(p).existsSync(), isTrue, reason: p);
    }
    // Pastikan ubin fitur tidak saling duplikat (mis. jadwal_sholat ≠ masjid, display ≠ iqamah).
    final tileBodies = <String, String>{};
    for (final t in BrandTile.values) {
      final raw = File(t.assetPath).readAsStringSync().replaceAll(RegExp(r'aria-label="[^"]*"'), '');
      expect(tileBodies.containsValue(raw), isFalse, reason: '${t.name} duplikat dengan ubin lain');
      tileBodies[t.name] = raw;
    }
    // Pastikan 4 empty state memiliki ilustrasi berbeda sesuai konteksnya.
    final emptyBodies = <String, String>{};
    for (final e in BrandEmptyArt.values) {
      final raw = File(e.assetPath).readAsStringSync().replaceAll(RegExp(r'aria-label="[^"]*"'), '');
      expect(emptyBodies.containsValue(raw), isFalse, reason: '${e.name} duplikat dengan empty state lain');
      emptyBodies[e.name] = raw;
    }
  });

  test('SVG asset kit bebas teks statis (teks dirender Flutter agar aksesibel)', () {
    for (final f in Directory('assets/kit').listSync(recursive: true).whereType<File>()) {
      expect(f.readAsStringSync().contains('<text'), isFalse, reason: f.path);
    }
  });

  test('font MoeslimIcons: 139 ikon, titik kode unik, ikon kunci tersedia', () {
    expect(File('fonts/MoeslimIcons.ttf').existsSync(), isTrue);
    final all = MoeslimIcons.all;
    expect(all.length, 139);
    expect(all.values.map((i) => i.codePoint).toSet().length, all.length);
    for (final i in all.values) {
      expect(i.fontFamily, 'MoeslimIcons');
      expect(i.fontPackage, 'moeslim_brand');
    }
    for (final name in ['beranda', 'masjid', 'tasbih', 'kiblat', 'quran_terbuka', 'sholat_subuh']) {
      expect(all.containsKey(name), isTrue, reason: name);
    }
  });

  testWidgets('ubin, empty state, elemen & ikon terender di tema terang dan gelap', (tester) async {
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(MoeslimIcons.masjid),
                  for (final t in BrandTile.values) FeatureTileArt(t),
                  const BrandEmptyState(
                      art: BrandEmptyArt.transaksi, title: 'Belum ada transaksi', message: 'Catat kas'),
                  for (final e in BrandElement.values) BrandElementArt(e, width: 120),
                  Container(
                      height: 40,
                      decoration: BoxDecoration(image: BrandPattern.anyaman.decoration(color: Colors.green))),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Belum ada transaksi'), findsOneWidget);
    }
  });
}
