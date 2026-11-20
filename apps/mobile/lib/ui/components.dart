import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

/// Pola geometris islami (bintang delapan) yang halus untuk latar header/kartu.
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double cell;
  const IslamicPatternPainter({required this.color, this.cell = 36});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var y = -cell; y < size.height + cell; y += cell) {
      for (var x = -cell; x < size.width + cell; x += cell) {
        final c = Offset(x + cell / 2, y + cell / 2);
        final r = cell * 0.42;
        // Dua persegi diputar 45° membentuk bintang delapan.
        for (final rot in [0.0, math.pi / 4]) {
          final path = Path();
          for (var i = 0; i < 4; i++) {
            final a = rot + i * math.pi / 2;
            final pt = c + Offset(math.cos(a), math.sin(a)) * r;
            i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
          }
          path.close();
          canvas.drawPath(path, p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(IslamicPatternPainter old) => old.color != color || old.cell != cell;
}

/// Header hijau bergradasi dengan pola islami (sapaan Beranda, banner fitur).
class PatternBanner extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  const PatternBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BrandColors.emerald, BrandColors.deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: IslamicPatternPainter(color: Colors.white.withValues(alpha: .06)),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

/// Kartu ornamen krem dengan bingkai emas tipis (judul surah, detail doa).
class OrnamentCard extends StatelessWidget {
  final Widget child;
  const OrnamentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? BrandColors.nightCard : const Color(0xFFFFFDF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.gold.withValues(alpha: .55)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: IslamicPatternPainter(color: BrandColors.gold.withValues(alpha: dark ? .08 : .12), cell: 28),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), child: child),
        ),
      ),
    );
  }
}

/// Nomor dalam bingkai oktagon emas (nomor surah/ayat).
class OctagonNumber extends StatelessWidget {
  final int number;
  final double size;
  const OctagonNumber(this.number, {super.key, this.size = 36});

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _OctagonPainter(BrandColors.gold),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(fontSize: size * (number > 99 ? .28 : .34), fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

class _OctagonPainter extends CustomPainter {
  final Color color;
  _OctagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.shortestSide / 2 - 1.5;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = math.pi / 8 + i * math.pi / 4;
      final pt = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(_OctagonPainter old) => old.color != color;
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text(actionLabel!), const Icon(Icons.chevron_right, size: 18)],
            ),
          ),
      ],
    ),
  );
}

/// Tombol menu cepat: kartu putih, ikon emerald, label dua baris (target sentuh ≥ 48dp).
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const MenuTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.primary, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab bergaya pil (Mushaf/Surah/Juz, Tasbih/Dzikir, Ringkasan/Riwayat).
class PillTabs extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const PillTabs({super.key, required this.labels, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final (i, l) in labels.indexed)
            Expanded(
              child: Semantics(
                selected: i == index,
                button: true,
                child: GestureDetector(
                  key: Key('tab-$l'),
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(minHeight: 40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? scheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: i == index ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum AppCore { personal, mosque }

/// Pengalih core di AppBar: "Moeslim Personal ▾" / "Moeslim Mosque ▾".
class CoreSwitcher extends StatelessWidget {
  final AppCore current;
  final ValueChanged<AppCore> onSelected;
  const CoreSwitcher({super.key, required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = current == AppCore.personal ? 'Moeslim Personal' : 'Moeslim Mosque';
    return PopupMenuButton<AppCore>(
      key: const Key('core-switcher'),
      tooltip: 'Ganti mode',
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final c in AppCore.values)
          PopupMenuItem(
            value: c,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(c == AppCore.personal ? Icons.person_outline : Icons.mosque_outlined),
              title: Text(c == AppCore.personal ? 'Moeslim Personal' : 'Moeslim Mosque'),
              subtitle: Text(c == AppCore.personal ? 'Ibadah harian pribadi' : 'Fitur tambahan pengurus masjid'),
              trailing: c == current ? Icon(Icons.check_circle, color: scheme.primary) : null,
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(current == AppCore.personal ? Icons.person : Icons.mosque, color: scheme.primary, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary, fontSize: 17),
            ),
            Icon(Icons.keyboard_arrow_down, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
