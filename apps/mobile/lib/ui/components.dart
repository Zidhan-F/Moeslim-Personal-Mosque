import 'dart:math' as math;

import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../core/l10n.dart';

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
      decoration: BoxDecoration(
        image: BrandBackground.bannerGelap.decoration(),
        gradient: LinearGradient(
          colors: [BrandColors.emerald, BrandColors.deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(padding: padding, child: child),
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
        image: (dark ? BrandBackground.bannerGelap : BrandBackground.alquranKrem).decoration(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), child: child),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: dark
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: BrandColors.nightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BrandColors.gold.withValues(alpha: .45)),
                      image: BrandBackground.bannerGelap.decoration(),
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
