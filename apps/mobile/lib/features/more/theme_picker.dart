import 'package:moeslim_brand/material_3d.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../ui/components.dart';

Future<AppThemeMode?> showThemePicker(BuildContext context, AppThemeMode selected) => showDialog<AppThemeMode>(
  context: context,
  builder: (dialogCtx) {
    final scheme = Theme.of(dialogCtx).colorScheme;
    final textTheme = Theme.of(dialogCtx).textTheme;
    const baseModes = [AppThemeMode.light, AppThemeMode.dark];
    final extraModes = [
      for (final mode in AppThemeMode.values)
        if (!baseModes.contains(mode)) mode,
    ];

    Widget buildGrid(List<AppThemeMode> modes, {required bool twoCols}) {
      if (!twoCols) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < modes.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ThemePreviewCard(
                mode: modes[i],
                selected: selected == modes[i],
                compact: true,
                onTap: () => Navigator.pop(dialogCtx, modes[i]),
              ),
            ],
          ],
        );
      }
      final rows = <Widget>[];
      for (var i = 0; i < modes.length; i += 2) {
        if (i > 0) rows.add(const SizedBox(height: 10));
        final left = modes[i];
        final right = i + 1 < modes.length ? modes[i + 1] : null;
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ThemePreviewCard(
                    mode: left,
                    selected: selected == left,
                    compact: false,
                    onTap: () => Navigator.pop(dialogCtx, left),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: right == null
                      ? const SizedBox.shrink()
                      : _ThemePreviewCard(
                          mode: right,
                          selected: selected == right,
                          compact: false,
                          onTap: () => Navigator.pop(dialogCtx, right),
                        ),
                ),
              ],
            ),
          ),
        );
      }
      return Column(mainAxisSize: MainAxisSize.min, children: rows);
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dialogCtx.tr('Pilih Tema Tampilan (10)', 'Choose Display Theme (10)'),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            dialogCtx.tr(
              'Sesuaikan tampilan dengan gayamu agar ibadah lebih nyaman dan fokus.',
              'Personalize the look for a calmer, more focused worship experience.',
            ),
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final textScale = MediaQuery.textScalerOf(ctx).scale(1);
            final twoCols = constraints.maxWidth >= 400 && textScale <= 1.25;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
                    child: Text(
                      dialogCtx.tr('Tema Utama', 'Core Themes'),
                      style: textTheme.labelLarge?.copyWith(color: scheme.primary),
                    ),
                  ),
                  buildGrid(baseModes, twoCols: twoCols),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
                    child: Text(
                      dialogCtx.tr('8 Tema Lainnya', '8 More Themes'),
                      style: textTheme.labelLarge?.copyWith(color: scheme.primary),
                    ),
                  ),
                  buildGrid(extraModes, twoCols: twoCols),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: Text(dialogCtx.tr('Batal', 'Cancel')),
        ),
      ],
    );
  },
);

class _ThemePreviewCard extends StatelessWidget {
  final AppThemeMode mode;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.mode,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewTheme = buildAppTheme(mode);
    final visual = mode.visual;
    final activeScheme = Theme.of(context).colorScheme;
    final titleText = context.isEn ? mode.labelEn : '${mode.labelId} (${mode.labelEn})';
    final subtitleText = context.tr(mode.subtitleId, mode.subtitleEn);

    return Material(
      key: Key('theme-${mode.name}'),
      color: selected ? activeScheme.primary.withValues(alpha: .08) : Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? activeScheme.primary : activeScheme.outlineVariant.withValues(alpha: .65),
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: compact
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: SizedBox(
                        width: 68,
                        child: _MiniPhonePreview(previewTheme: previewTheme, visual: visual),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeMeta(
                        mode: mode,
                        visual: visual,
                        previewTheme: previewTheme,
                        titleText: titleText,
                        subtitleText: subtitleText,
                        selected: selected,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: _MiniPhonePreview(previewTheme: previewTheme, visual: visual),
                    ),
                    const SizedBox(height: 10),
                    _ThemeMeta(
                      mode: mode,
                      visual: visual,
                      previewTheme: previewTheme,
                      titleText: titleText,
                      subtitleText: subtitleText,
                      selected: selected,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ThemeMeta extends StatelessWidget {
  final AppThemeMode mode;
  final AppThemeVisual visual;
  final ThemeData previewTheme;
  final String titleText;
  final String subtitleText;
  final bool selected;

  const _ThemeMeta({
    required this.mode,
    required this.visual,
    required this.previewTheme,
    required this.titleText,
    required this.subtitleText,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(visual.icon, size: 17, color: previewTheme.colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                titleText,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle_rounded, size: 18, color: scheme.primary),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          subtitleText,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.25),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final swatch in visual.swatches)
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: .7), width: .8),
                ),
              ),
            if (mode == AppThemeMode.light)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr('Default', 'Default'),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: scheme.primary),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniPhonePreview extends StatelessWidget {
  final ThemeData previewTheme;
  final AppThemeVisual visual;

  const _MiniPhonePreview({required this.previewTheme, required this.visual});

  @override
  Widget build(BuildContext context) {
    final bg = previewTheme.scaffoldBackgroundColor;
    final card = previewTheme.cardTheme.color ?? previewTheme.colorScheme.surface;
    final primary = previewTheme.colorScheme.primary;
    final onSurface = previewTheme.colorScheme.onSurface;

    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: .28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          HomeHeroBanner(
            visualOverride: visual,
            borderRadius: BorderRadius.zero,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: visual.heroTextColor.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 52,
                  height: 3,
                  decoration: BoxDecoration(
                    color: visual.heroSubtextColor.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 5,
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: .82),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 16,
                          height: 6,
                          decoration: BoxDecoration(
                            color: visual.countdownBg,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: visual.activePrayerBg,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 12,
            color: card,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 12,
                  height: 4,
                  decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2)),
                ),
                Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
