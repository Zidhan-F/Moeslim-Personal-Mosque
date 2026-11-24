import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Ikon waktu salat yang menggambarkan posisi matahari/bulan, satu gaya garis untuk semua baris jadwal:
/// Subuh (fajar), Syuruq (matahari terbit), Dzuhur (matahari terik), Ashar (matahari sore berawan),
/// Maghrib (matahari terbenam), Isya (bulan sabit & bintang).
class PrayerSkyIcon extends StatelessWidget {
  final String prayer;
  final Color color;
  final double size;
  const PrayerSkyIcon(this.prayer, {super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SkyPainter(prayer, color)),
    ),
  );
}

class _SkyPainter extends CustomPainter {
  final String prayer;
  final Color color;
  _SkyPainter(this.prayer, this.color);

  Paint get _line => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  Paint get _fill => Paint()..color = color;

  void _rays(Canvas c, Offset o, double r1, double r2, Iterable<double> degrees) {
    for (final d in degrees) {
      final a = d * math.pi / 180;
      c.drawLine(o + Offset(math.cos(a), math.sin(a)) * r1, o + Offset(math.cos(a), math.sin(a)) * r2, _line);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    switch (prayer) {
      case 'Subuh': // fajar: setengah matahari di cakrawala, sinar ke atas, bintang kecil
        canvas.drawLine(const Offset(3, 17), const Offset(21, 17), _line);
        canvas.drawArc(Rect.fromCircle(center: const Offset(12, 17), radius: 5), math.pi, math.pi, false, _line);
        _rays(canvas, const Offset(12, 17), 8, 10.5, [200, 230, 270, 310, 340]);
        canvas.drawCircle(const Offset(4.5, 6.5), .9, _fill);
        canvas.drawCircle(const Offset(19.5, 5.5), .9, _fill);
        canvas.drawLine(const Offset(8, 20.5), const Offset(16, 20.5), _line);
      case 'Syuruq': // terbit: matahari naik di atas cakrawala, sinar menyebar, panah ke atas
        canvas.drawLine(const Offset(3, 16), const Offset(21, 16), _line);
        canvas.drawArc(Rect.fromCircle(center: const Offset(12, 16), radius: 5), math.pi, math.pi, false, _line);
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(12, 16), radius: 2.6),
          math.pi,
          math.pi,
          true,
          Paint()..color = color.withValues(alpha: .35),
        );
        _rays(canvas, const Offset(12, 16), 7.5, 10, [180, 215, 250, 290, 325, 360]);
        canvas.drawLine(const Offset(12, 22), const Offset(12, 18.5), _line);
        canvas.drawLine(const Offset(10, 20.3), const Offset(12, 18.5), _line);
        canvas.drawLine(const Offset(14, 20.3), const Offset(12, 18.5), _line);
      case 'Dzuhur': // terik: matahari penuh di puncak, sinar panjang
        canvas.drawCircle(const Offset(12, 12), 4.2, _fill);
        _rays(canvas, const Offset(12, 12), 7, 10.5, [for (var i = 0; i < 8; i++) i * 45.0]);
      case 'Ashar': // sore: matahari condong tertutup awan tipis
        canvas.drawCircle(const Offset(9, 9), 3.4, _line);
        _rays(canvas, const Offset(9, 9), 5.6, 7.6, [180, 225, 270, 315, 0]);
        final cloud = Path()
          ..moveTo(8, 20)
          ..cubicTo(4.5, 20, 4.5, 15, 8.5, 15)
          ..cubicTo(9.5, 11.5, 15.5, 11.5, 16.3, 15.2)
          ..cubicTo(20.5, 15, 21, 20, 17.5, 20)
          ..close();
        canvas.drawPath(cloud, Paint()..color = color.withValues(alpha: .22));
        canvas.drawPath(cloud, _line);
      case 'Maghrib': // terbenam: setengah matahari tenggelam, pantulan di bawah
        canvas.drawLine(const Offset(3, 14), const Offset(21, 14), _line);
        canvas.drawArc(Rect.fromCircle(center: const Offset(12, 14), radius: 5), math.pi, math.pi, false, _line);
        _rays(canvas, const Offset(12, 14), 8, 10.5, [215, 270, 325]);
        canvas.drawLine(const Offset(6, 17.5), const Offset(18, 17.5), _line);
        canvas.drawLine(const Offset(9, 21), const Offset(15, 21), _line);
      case 'Isya': // malam: bulan sabit & bintang
        final moon = Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: const Offset(11, 13), radius: 8)),
          Path()..addOval(Rect.fromCircle(center: const Offset(15.5, 10), radius: 7)),
        );
        canvas.drawPath(moon, _fill);
        final star = Path()
          ..moveTo(19, 3.5)
          ..lineTo(19.7, 5.3)
          ..lineTo(21.5, 6)
          ..lineTo(19.7, 6.7)
          ..lineTo(19, 8.5)
          ..lineTo(18.3, 6.7)
          ..lineTo(16.5, 6)
          ..lineTo(18.3, 5.3)
          ..close();
        canvas.drawPath(star, _fill);
      default:
        canvas.drawCircle(const Offset(12, 12), 4.2, _line);
        _rays(canvas, const Offset(12, 12), 7, 10, [for (var i = 0; i < 8; i++) i * 45.0]);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.prayer != prayer || old.color != color;
}
