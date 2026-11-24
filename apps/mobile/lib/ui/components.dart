import 'dart:math' as math;

import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n.dart';
import '../core/theme.dart';

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

/// Banner bermotif islami bernuansa kaya (kontras tinggi untuk teks putih) untuk header fitur.
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
  Widget build(BuildContext context) {
    final visual = AppThemeVisual.of(context);
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: visual.bannerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomPaint(
          painter: IslamicPatternPainter(color: Colors.white.withValues(alpha: .08), cell: 34),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Banner hero atmosferik untuk Beranda dan Profil, menyesuaikan langit & ornamen tiap 10 tema.
class HomeHeroBanner extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final AppThemeVisual? visualOverride;

  const HomeHeroBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 36),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.visualOverride,
  });

  @override
  Widget build(BuildContext context) {
    final visual = visualOverride ?? AppThemeVisual.of(context);
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: visual.heroGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _HeroAtmospherePainter(visual)),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _HeroAtmospherePainter extends CustomPainter {
  final AppThemeVisual visual;
  const _HeroAtmospherePainter(this.visual);

  void _drawCrescent(Canvas canvas, Offset center, double radius, Color color) {
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Path()..addOval(Rect.fromCircle(center: center + Offset(radius * .46, -radius * .22), radius: radius * .86)),
    );
    canvas.drawPath(moon, Paint()..color = color);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * .3, c.dy - r * .3)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + r * .3, c.dy + r * .3)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * .3, c.dy + r * .3)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - r * .3, c.dy - r * .3)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  void _drawCloud(Canvas canvas, Offset base, double s, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(base, s * .42, p);
    canvas.drawCircle(base + Offset(s * .42, -s * .14), s * .5, p);
    canvas.drawCircle(base + Offset(s * .88, 0), s * .38, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(base.dx - s * .32, base.dy - s * .05, s * 1.48, s * .46), Radius.circular(s)),
      p,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final accent = visual.heroAccentColor;
    if (visual.heroSunsetGlow != null) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.75, 0.72),
          radius: 0.85,
          colors: [visual.heroSunsetGlow!, visual.heroSunsetGlow!.withValues(alpha: 0)],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, glowPaint);
    }

    switch (visual.motif) {
      case HeroMotif.geometric:
        IslamicPatternPainter(color: accent.withValues(alpha: .09), cell: 32).paint(canvas, size);
      case HeroMotif.nightStars:
        IslamicPatternPainter(color: accent.withValues(alpha: .07), cell: 36).paint(canvas, size);
        _drawCrescent(canvas, Offset(size.width * .78, size.height * .26), 9, accent.withValues(alpha: .85));
        _drawStar(canvas, Offset(size.width * .68, size.height * .18), 3.6, accent.withValues(alpha: .75));
        _drawStar(canvas, Offset(size.width * .88, size.height * .19), 2.8, accent.withValues(alpha: .6));
        _drawStar(canvas, Offset(size.width * .61, size.height * .32), 2.2, Colors.white.withValues(alpha: .45));
      case HeroMotif.natureLeaves:
        final leafPaint = Paint()..color = accent.withValues(alpha: .18);
        for (final (dx, dy, rx, ry, rot) in [
          (.86, .12, 18.0, 8.0, -0.5),
          (.93, .22, 16.0, 7.0, -0.9),
          (.77, .09, 14.0, 6.5, -0.25),
          (.96, .08, 13.0, 6.0, -1.2),
        ]) {
          canvas.save();
          canvas.translate(size.width * dx, size.height * dy);
          canvas.rotate(rot);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), leafPaint);
          canvas.restore();
        }
      case HeroMotif.skyClouds:
        _drawCloud(canvas, Offset(size.width * .62, size.height * .25), 18, Colors.white.withValues(alpha: .22));
        _drawCloud(canvas, Offset(size.width * .82, size.height * .19), 15, Colors.white.withValues(alpha: .28));
        _drawCrescent(canvas, Offset(size.width * .73, size.height * .22), 7.5, Colors.white.withValues(alpha: .72));
      case HeroMotif.twilightMoon:
        _drawCrescent(canvas, Offset(size.width * .75, size.height * .26), 9.5, accent.withValues(alpha: .9));
        _drawStar(canvas, Offset(size.width * .65, size.height * .20), 3.2, Colors.white.withValues(alpha: .65));
        _drawStar(canvas, Offset(size.width * .86, size.height * .18), 2.6, Colors.white.withValues(alpha: .55));
        _drawStar(canvas, Offset(size.width * .58, size.height * .33), 2.0, accent.withValues(alpha: .55));
      case HeroMotif.desertSun:
        final sunPaint = Paint()
          ..shader = RadialGradient(
            colors: [accent.withValues(alpha: .22), accent.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: Offset(size.width * .82, size.height * .28), radius: 52));
        canvas.drawCircle(Offset(size.width * .82, size.height * .28), 52, sunPaint);
        final dunePaint = Paint()..color = accent.withValues(alpha: .10);
        final dune = Path()
          ..moveTo(0, size.height)
          ..quadraticBezierTo(size.width * .35, size.height * .72, size.width * .7, size.height * .88)
          ..quadraticBezierTo(size.width * .88, size.height * .95, size.width, size.height * .82)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(dune, dunePaint);
      case HeroMotif.midnightMoon:
        _drawCrescent(canvas, Offset(size.width * .77, size.height * .24), 10, accent.withValues(alpha: .92));
        for (final (dx, dy, r) in [
          (.62, .18, 3.2),
          (.69, .31, 2.2),
          (.87, .16, 2.8),
          (.92, .30, 2.0),
          (.55, .24, 1.9),
          (.82, .38, 1.8),
        ]) {
          _drawStar(canvas, Offset(size.width * dx, size.height * dy), r, accent.withValues(alpha: .72));
        }
      case HeroMotif.lavenderBlossoms:
        final blossom = Paint()..color = accent.withValues(alpha: .16);
        for (final (dx, dy, r) in [(.82, .16, 7.0), (.89, .24, 8.5), (.94, .12, 6.0), (.75, .11, 5.5)]) {
          canvas.drawCircle(Offset(size.width * dx, size.height * dy), r, blossom);
        }
        IslamicPatternPainter(color: accent.withValues(alpha: .06), cell: 36).paint(canvas, size);
      case HeroMotif.tealArch:
        IslamicPatternPainter(color: accent.withValues(alpha: .11), cell: 32).paint(canvas, size);
        final archStroke = Paint()
          ..color = accent.withValues(alpha: .38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        final arch = Path()
          ..moveTo(size.width * .62, size.height)
          ..lineTo(size.width * .62, size.height * .36)
          ..quadraticBezierTo(size.width * .78, size.height * .06, size.width * .94, size.height * .36)
          ..lineTo(size.width * .94, size.height);
        canvas.drawPath(arch, archStroke);
      case HeroMotif.rosePetals:
        final petal = Paint()..color = accent.withValues(alpha: .17);
        for (final (dx, dy, rx, ry, rot) in [
          (.82, .14, 10.0, 5.5, 0.4),
          (.90, .20, 12.0, 6.0, -0.35),
          (.75, .24, 8.0, 4.5, 0.7),
          (.94, .10, 9.0, 5.0, -0.8),
          (.68, .15, 7.5, 4.0, 0.2),
        ]) {
          canvas.save();
          canvas.translate(size.width * dx, size.height * dy);
          canvas.rotate(rot);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), petal);
          canvas.restore();
        }
    }
  }

  @override
  bool shouldRepaint(_HeroAtmospherePainter old) => old.visual != visual;
}

/// Kartu ornamen krem dengan bingkai emas tipis (judul surah, detail doa).
class OrnamentCard extends StatelessWidget {
  final Widget child;
  const OrnamentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final visual = AppThemeVisual.of(context);
    return Container(
      decoration: BoxDecoration(
        color: dark ? (theme.cardTheme.color ?? BrandColors.nightCard) : (theme.cardTheme.color ?? const Color(0xFFFFFDF6)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? visual.heroAccentColor.withValues(alpha: .42) : BrandColors.gold.withValues(alpha: .55),
        ),
        image: dark
            ? null
            : (visual.mode == AppThemeMode.light ? BrandBackground.alquranKrem.decoration() : null),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: dark ? IslamicPatternPainter(color: visual.heroAccentColor.withValues(alpha: .06), cell: 34) : null,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), child: child),
        ),
      ),
    );
  }
}

/// Kepala halaman berornamen: lengkung krem berbingkai emas di atas kisi hijau, siluet masjid emas tipis
/// (Jadwal Salat, Detail Doa, Mushaf), sesuai visualisasi.
class ArchHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const ArchHeader({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(28, 46, 28, 22)});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final visual = AppThemeVisual.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: dark
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? BrandColors.nightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: visual.heroAccentColor.withValues(alpha: .42)),
                    ),
                    child: CustomPaint(
                      painter: IslamicPatternPainter(color: visual.heroAccentColor.withValues(alpha: .07), cell: 34),
                    ),
                  )
                : const BrandArt(BrandIllustration.archHeader, fit: BoxFit.fill),
          ),
          Padding(
            padding: padding,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

/// Nomor dalam medali bintang delapan Rub el Hizb emas (nomor surah/ayat/doa).
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
          style: TextStyle(fontSize: size * (number > 99 ? .28 : .34), fontWeight: FontWeight.w700),
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
    final r = s.shortestSide / 2 - 2.2;
    final fill = Paint()
      ..color = color.withValues(alpha: .10)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeJoin = StrokeJoin.round;
    // Dua persegi diputar 45° membentuk medali Rub el Hizb (bintang 8 sudut khas mushaf).
    for (final rot in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = rot + math.pi / 4 + i * math.pi / 2;
        final pt = c + Offset(math.cos(a), math.sin(a)) * r;
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
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

/// Tombol menu cepat: kartu putih, ubin fitur asset kit (atau ikon emerald), label dua baris
/// (target sentuh ≥ 48dp).
class MenuTile extends StatelessWidget {
  final IconData? icon;
  final BrandTile? tile;
  final Widget? art;
  final String label;
  final VoidCallback onTap;
  const MenuTile({super.key, this.icon, this.tile, this.art, required this.label, required this.onTap})
    : assert(icon != null || tile != null || art != null);

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
              if (art != null)
                art!
              else if (tile != null)
                FeatureTileArt(tile!, size: 40)
              else
                Icon(icon, color: scheme.primary, size: 40),
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
///
/// Sampai 3 tab: lebar dibagi rata. Lebih dari itu: tiap tab selebar isinya
/// (satu baris), bar bisa digeser menyamping dan tab aktif otomatis terlihat.
class PillTabs extends StatefulWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const PillTabs({super.key, required this.labels, required this.index, required this.onChanged});

  @override
  State<PillTabs> createState() => _PillTabsState();
}

class _PillTabsState extends State<PillTabs> {
  late List<GlobalKey> _keys = _makeKeys();

  List<GlobalKey> _makeKeys() => List.generate(widget.labels.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(PillTabs old) {
    super.didUpdateWidget(old);
    if (old.labels.length != widget.labels.length) _keys = _makeKeys();
    if (old.index != widget.index) _reveal();
  }

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  final _scroll = ScrollController();
  final _viewportKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Hanya menggulir bar tab ini, bukan scroll induk halaman.
  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients || widget.index >= _keys.length) return;
      final tab = _keys[widget.index].currentContext?.findRenderObject();
      final viewport = _viewportKey.currentContext?.findRenderObject();
      if (tab is! RenderBox || viewport is! RenderBox) return;
      final left = tab.localToGlobal(Offset.zero, ancestor: viewport).dx + _scroll.offset;
      final target = (left + tab.size.width / 2 - viewport.size.width / 2).clamp(
        _scroll.position.minScrollExtent,
        _scroll.position.maxScrollExtent,
      );
      _scroll.animateTo(target, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    });
  }

  Widget _tab(BuildContext context, int i, {required bool scrollable}) {
    final scheme = Theme.of(context).colorScheme;
    final l = widget.labels[i];
    final selected = i == widget.index;
    final text = Text(
      l,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w600, color: selected ? scheme.onPrimary : scheme.onSurface),
    );
    return Semantics(
      key: _keys[i],
      selected: selected,
      button: true,
      child: GestureDetector(
        key: Key('tab-$l'),
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: scrollable ? text : FittedBox(fit: BoxFit.scaleDown, child: text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scrollable = widget.labels.length > 3;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: scrollable
          ? SingleChildScrollView(
              key: _viewportKey,
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < widget.labels.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    _tab(context, i, scrollable: true),
                  ],
                ],
              ),
            )
          : Row(
              children: [
                for (var i = 0; i < widget.labels.length; i++) Expanded(child: _tab(context, i, scrollable: false)),
              ],
            ),
    );
  }
}

/// Watermark pengembang yang halus dan dapat diketuk untuk membuka situs resmi.
class DeveloperWatermark extends StatelessWidget {
  final EdgeInsets padding;
  const DeveloperWatermark({super.key, this.padding = const EdgeInsets.symmetric(vertical: 16)});

  static final _siteUri = Uri.parse('https://zidhan.id');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            try {
              await launchUrl(_siteUri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary.withValues(alpha: .20)),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Develop by ',
                style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: 'zidhan.id',
                    style: t.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
      tooltip: context.tr('Ganti mode', 'Switch mode'),
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final c in AppCore.values)
          PopupMenuItem(
            value: c,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(c == AppCore.personal ? MoeslimIcons.profil : MoeslimIcons.masjid),
              title: Text(c == AppCore.personal ? 'Moeslim Personal' : 'Moeslim Mosque'),
              subtitle: Text(
                c == AppCore.personal
                    ? context.tr('Ibadah harian pribadi', 'Personal daily worship')
                    : context.tr('Fitur tambahan pengurus masjid', 'Optional tools for mosque managers'),
              ),
              trailing: c == current ? Icon(MoeslimIcons.berhasil, color: scheme.primary) : null,
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              current == AppCore.personal ? MoeslimIcons.profil : MoeslimIcons.masjid,
              color: scheme.primary,
              size: 22,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary, fontSize: 17),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
