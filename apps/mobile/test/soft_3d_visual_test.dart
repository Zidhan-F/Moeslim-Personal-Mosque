import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:moeslim_mobile/app.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/ibadah/qibla_page.dart';
import 'package:moeslim_mobile/features/masjid/masjid_home_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/ui/components.dart';
import 'package:personal_core/personal_core.dart';

import 'helpers.dart';
import 'fake_mosque_backend.dart';

void main() {
  testWidgets('3D art remains readable across themes, phone sizes and navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      for (final entry in {
        'Inter': 'Inter-Regular.ttf',
        'MoeslimIcons': 'MoeslimIcons.ttf',
        'AmiriQuran': 'AmiriQuran-Regular.ttf',
      }.entries) {
        await (FontLoader(
          'packages/moeslim_brand/${entry.key}',
        )..addFont(rootBundle.load('packages/moeslim_brand/fonts/${entry.value}'))).load();
      }
      await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final container = await pumpApp(tester, client: fakeMosqueBackend(
        [],
        role: 'admin',
        permissions: const [
          'finance.view', 'finance.write', 'events.view', 'events.write', 'members.view', 'staff.view',
          'inventory.view', 'display.view', 'zakat.view', 'qurban.view',
        ],
      ), tokens: MemoryTokenStore('t0k3n'));
    final frame = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: frame, child: const MoeslimApp()),
      ),
    );

    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: name);
      if (const bool.fromEnvironment('WRITE_3D_PREVIEWS')) {
        await tester.runAsync(() async {
          final boundary = frame.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          const subdirectory = String.fromEnvironment('PREVIEW_SUBDIR', defaultValue: '');
          final file = File('../../docs/brand/screenshots/soft-3d/$subdirectory/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    }

    await capture('home-light');
    await tester.tap(find.text("Al-Qur'an").last);
    await capture('quran-light');
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Semua'));
    await capture('features-light');
    await tester.enterText(find.byType(TextField).first, 'Muslimah');
    await capture('muslimah-feature');
    expect(tester.widgetList<SoftArt>(find.byType(SoftArt)).any((art) => art.asset == SoftAsset.muslimah), isTrue);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.pop();
    await tester.pumpAndSettle();
    nav.push(MaterialPageRoute(builder: (_) => const QiblaPage()));
    await capture('qibla-light');
    nav.pop();
    await tester.pumpAndSettle();
    nav.push(MaterialPageRoute(builder: (_) => const MosqueLandingPage()));
    await capture('mosque-light');
    nav.pop();
    await tester.pumpAndSettle();
    final settings = await container.read(settingsProvider.future);
    await container.read(settingsProvider.notifier).save(settings.copyWith(themeMode: AppThemeMode.dark));
    await capture('home-dark');
    tester.view.physicalSize = const Size(360, 800);
    await container.read(settingsProvider.notifier).save(settings.copyWith(fontScale: 1.3));
    await capture('home-small-large-text');
    tester.view.physicalSize = const Size(390, 844);
    await container.read(settingsProvider.notifier).save(settings);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('masjid-entry')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('masjid-entry')));
    await tester.pumpAndSettle();
    for (final entry in {
      'Catat Kas': SoftAsset.finance,
      'Buat Kegiatan': SoftAsset.calendar,
      'Kelola Pengurus': SoftAsset.committee,
      'Kelola Petugas': SoftAsset.staffDuty,
      'Inventaris': SoftAsset.inventory,
      'TV Display': SoftAsset.display,
      'Konten TV': SoftAsset.announcement,
      'Laporan': SoftAsset.barChart,
      'Zakat': SoftAsset.zakat,
      'Kurban & QR': SoftAsset.qurban,
      'Profil Web': SoftAsset.webGlobe,
    }.entries) {
      final tile = find.widgetWithText(MenuTile, entry.key);
      final art = find.descendant(of: tile, matching: find.byType(SoftArt));
      await tester.scrollUntilVisible(tile, 200, scrollable: find.byType(Scrollable).first);
      expect(tester.widget<SoftArt>(art).asset, entry.value, reason: entry.key);
    }
    await tester.ensureVisible(find.text('Ringkasan Masjid'));
    await capture('mosque-dashboard');
    await container.read(settingsProvider.notifier).save(settings.copyWith(themeMode: AppThemeMode.dark));
    await capture('mosque-dashboard-dark');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
