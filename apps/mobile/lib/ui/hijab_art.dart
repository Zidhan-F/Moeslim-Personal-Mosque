import 'package:material_ui/material_ui.dart';

/// Ilustrasi muslimah berhijab (tanpa wajah detail) untuk ikon Mode Muslimah.
/// Digambar dengan vektor agar tajam di semua ukuran dan mengikuti palet merek.
class HijabWomanArt extends StatelessWidget {
  final double size;
  const HijabWomanArt({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(width: size, height: size, child: CustomPaint(painter: _HijabPainter())),
      );
}

class _HijabPainter extends CustomPainter {
  static const _mint = Color(0xFFE6F5EC);
  static const _emerald = Color(0xFF087E65);
  static const _deep = Color(0xFF065A49);
  static const _gold = Color(0xFFD9AB36);
  static const _skin = Color(0xFFF3D2B3);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.clipRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 100, 100), const Radius.circular(26)));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), Paint()..color = _mint);

    // Bahu / gamis.
    final body = Path()
      ..moveTo(14, 104)
      ..cubicTo(14, 86, 30, 76, 50, 76)
      ..cubicTo(70, 76, 86, 86, 86, 104)
      ..close();
    canvas.drawPath(body, Paint()..color = _deep);

    // Hijab menjuntai menutupi dada.
    final hijab = Path()
      ..moveTo(50, 12)
      ..cubicTo(72, 12, 82, 30, 80, 52)
      ..cubicTo(79, 66, 76, 76, 70, 88)
      ..cubicTo(62, 84, 38, 84, 30, 88)
      ..cubicTo(24, 76, 21, 66, 20, 52)
      ..cubicTo(18, 30, 28, 12, 50, 12)
      ..close();
    canvas.drawPath(hijab, Paint()..color = _emerald);

    // Wajah (oval) dengan garis tepi emas.
    final face = Rect.fromCenter(center: const Offset(50, 46), width: 32, height: 38);
    canvas.drawOval(face, Paint()..color = _skin);
    canvas.drawOval(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _gold,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
