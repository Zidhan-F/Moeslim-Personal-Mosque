import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/providers.dart';

/// Arah kompas perangkat (derajat dari utara). Di-override di test.
final headingProvider = StreamProvider<double?>((ref) {
  final events = FlutterCompass.events;
  if (events == null) return Stream.value(null);
  return events.map((e) => e.heading);
});

/// Format derajat gaya Indonesia: 295,1°.
String degreeId(double v) => '${v.toStringAsFixed(1).replaceAll('.', ',')}°';

class QiblaPage extends ConsumerWidget {
  const QiblaPage({super.key});

  void _calibrate(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(Icons.screen_rotation_alt),
      title: const Text('Kalibrasi Kompas'),
      content: const Text(
        'Putar ponsel membentuk angka 8 beberapa kali di udara. Jauhkan dari benda logam, magnet, atau perangkat '
        'elektronik. Setelah itu letakkan ponsel mendatar.',
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai'))],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bearing = qiblaBearing(settings.location.coordinates);
    final distance = distanceToKaabaKm(settings.location.coordinates);
    final heading = ref.watch(headingProvider).value;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SizedBox.square(
              dimension: 300,
              child: Semantics(
                label: 'Kompas kiblat, ${degreeId(bearing)} dari utara',
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CompassPainter(qibla: bearing, heading: heading),
                      ),
                    ),
                    // Ka'bah di ujung jarum (arah kiblat), ilustrasi brand.
                    Builder(
                      builder: (_) {
                        final a = (bearing - (heading ?? 0) - 90) * math.pi / 180;
                        const c = 150.0, r = 150.0 - 22 - 30;
                        return Positioned(
                          key: const Key('compass-kaaba'),
                          left: c + math.cos(a) * r - 22,
                          top: c + math.sin(a) * r - 24,
                          child: const BrandArt(BrandIllustration.kaaba, width: 44, height: 44),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (heading == null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Sensor kompas tidak tersedia. Gunakan sudut kiblat di bawah dengan kompas fisik.',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const BrandArt(BrandIllustration.kaaba, width: 52, height: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Arah Kiblat'),
                        Text(
                          degreeId(bearing),
                          key: const Key('qibla-bearing'),
                          style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: BrandColors.emerald),
                        ),
                        Text('dari utara sejati • ± ${distance.toStringAsFixed(0)} km', style: t.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: BrandColors.gold.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.place, size: 16, color: BrandColors.goldText),
                        SizedBox(width: 4),
                        Text("Ke Ka'bah\n(Makkah)", style: TextStyle(color: BrandColors.goldText, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.explore_outlined, color: BrandColors.emerald),
              title: const Text('Kalibrasi Kompas', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text(
                'Putar ponsel membentuk angka 8 untuk mengkalibrasi akurasi kompas. Akurasi sensor berbeda antar perangkat.',
              ),
              trailing: const BrandArt(BrandIllustration.calibrate, width: 72),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('calibrate'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
            onPressed: () => _calibrate(context),
            icon: const Icon(Icons.my_location),
            label: const Text('Kalibrasi Sekarang'),
          ),
        ],
      ),
    );
  }
}

/// Kompas: piringan hijau dengan cincin emas, mata angin U/T/S/B, penanda Ka'bah, dan jarum kiblat.
/// Bila [heading] tersedia, piringan berputar mengikuti arah perangkat.
class CompassPainter extends CustomPainter {
  final double qibla;
  final double? heading;
  const CompassPainter({required this.qibla, this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 22;
    final rot = -(heading ?? 0) * math.pi / 180;

    // Label mata angin di luar piringan (berputar bersama piringan).
    final labels = {'U': 0.0, 'T': 90.0, 'S': 180.0, 'B': 270.0};
    for (final e in labels.entries) {
      final a = rot + (e.value - 90) * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(
          text: e.key,
          style: const TextStyle(
            fontFamily: 'Inter',
            package: 'moeslim_brand',
            color: BrandColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c + Offset(math.cos(a), math.sin(a)) * (r + 14) - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.drawCircle(c, r, Paint()..color = BrandColors.gold);
    canvas.drawCircle(c, r - 6, Paint()..color = BrandColors.deep);
    canvas.drawCircle(c, r - 10, Paint()..color = BrandColors.emerald.withValues(alpha: .55));

    // Ornamen bintang delapan di tengah.
    final star = Paint()
      ..color = BrandColors.gold.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final off in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = rot + off + i * math.pi / 2;
        final p = c + Offset(math.cos(a), math.sin(a)) * r * .45;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), star);
    }

    // Garis skala.
    final tick = Paint()..color = BrandColors.cream;
    for (var d = 0; d < 360; d += 10) {
      final a = rot + (d - 90) * math.pi / 180;
      final len = d % 90 == 0 ? 14.0 : (d % 30 == 0 ? 9.0 : 5.0);
      tick.strokeWidth = d % 90 == 0 ? 2.4 : 1.2;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r - 12),
        c + Offset(math.cos(a), math.sin(a)) * (r - 12 - len),
        tick,
      );
    }

    // Jarum & penanda Ka'bah pada arah kiblat.
    final qa = rot + (qibla - 90) * math.pi / 180;
    final dir = Offset(math.cos(qa), math.sin(qa));
    final perp = Offset(-dir.dy, dir.dx);
    final needle = Path()
      ..moveTo((c + dir * (r - 44)).dx, (c + dir * (r - 44)).dy)
      ..lineTo((c + perp * 10).dx, (c + perp * 10).dy)
      ..lineTo((c - dir * 26).dx, (c - dir * 26).dy)
      ..lineTo((c - perp * 10).dx, (c - perp * 10).dy)
      ..close();
    canvas.drawPath(needle, Paint()..color = BrandColors.gold);
    canvas.drawCircle(c, 6, Paint()..color = BrandColors.cream);
  }

  @override
  bool shouldRepaint(CompassPainter old) => old.qibla != qibla || old.heading != heading;
}
