import 'dart:async';

import 'package:display_ui/display_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

/// Konten TV untuk pratinjau pengurus (sama dengan yang diterima perangkat TV).
final displayPreviewProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(masjidApiProvider).displayPreview(id),
);

/// Pilihan warna siap pakai untuk tema "Warna Sendiri".
const tvColorChoices = <Color>[
  Color(0xFF087E65),
  Color(0xFF07372F),
  Color(0xFF0B5D4B),
  Color(0xFF123A63),
  Color(0xFF061A30),
  Color(0xFF1F4E79),
  Color(0xFF6B1F2A),
  Color(0xFF2E0B12),
  Color(0xFF4A2C17),
  Color(0xFF3B2F6B),
  Color(0xFF1C1C1C),
  Color(0xFF37474F),
  Color(0xFFF7F7F1),
  Color(0xFFEFEBDD),
  Color(0xFFFFFFFF),
  Color(0xFFD9AB36),
  Color(0xFFF2D88B),
  Color(0xFFE0A030),
  Color(0xFFC0392B),
  Color(0xFF2E86C1),
];

enum _PreviewMode { main, info, iqamah }

/// Desain TV Display: pratinjau langsung di ponsel + atur tema warna & widget, lalu simpan ke TV.
class TvDesignPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> device;

  /// Semua perangkat aktif (untuk opsi terapkan ke semua TV).
  final List<Map<String, dynamic>> devices;

  /// Waktu tetap untuk pratinjau (test); null = jam berjalan.
  final DateTime Function()? clock;

  const TvDesignPage({super.key, required this.ctx, required this.device, this.devices = const [], this.clock});

  @override
  ConsumerState<TvDesignPage> createState() => _TvDesignPageState();
}

class _TvDesignPageState extends ConsumerState<TvDesignPage> {
  late TvDisplayConfig _saved = TvDisplayConfig.fromJson(
    Map<String, dynamic>.from((widget.device['config'] as Map?) ?? const {}),
  );
  late TvDisplayConfig _config = _saved;
  late final _ticker = TextEditingController(text: _config.tickerText);
  _PreviewMode _mode = _PreviewMode.main;
  bool _applyAll = false;
  bool _busy = false;
  Timer? _timer;

  bool get _dirty => _config.toJson().toString() != _saved.toJson().toString();
  bool get _canManage => widget.ctx.can('display.manage');

  @override
  void initState() {
    super.initState();
    if (widget.clock == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  void _set(TvDisplayConfig c) => setState(() => _config = c);

  Future<void> _save() async {
    setState(() => _busy = true);
    final api = ref.read(masjidApiProvider);
    final targets = _applyAll && widget.devices.length > 1 ? widget.devices : [widget.device];
    final patch = _config.toJson();
    try {
      for (final d in targets) {
        await api.updateDisplay(widget.ctx.id, d['id'] as int, {'config': patch});
      }
      ref.invalidate(displaysProvider(widget.ctx.id));
      if (!mounted) return;
      setState(() => _saved = _config);
      showSnack(
        context,
        context.tr(
          'Tersimpan ke ${targets.length} TV. Layar memperbarui tampilan dalam 1 menit.',
          'Saved to ${targets.length} TV(s). Screens update within 1 minute.',
        ),
      );
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(context.tr('Buang perubahan?', 'Discard changes?')),
          content: Text(context.tr('Desain belum disimpan ke TV.', 'The design has not been saved to the TV.')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(context.tr('Lanjut edit', 'Keep editing')),
            ),
            TextButton(
              key: const Key('tv-design-discard'),
              onPressed: () => Navigator.pop(c, true),
              child: Text(context.tr('Buang', 'Discard')),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _pickColor(String title, Color current, ValueChanged<Color> onPicked) async {
    final hex = TextEditingController(text: TvDisplayConfig.toHex(current));
    final picked = await showModalBottomSheet<Color>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(c).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in tvColorChoices)
                  Semantics(
                    button: true,
                    selected: color.toARGB32() == current.toARGB32(),
                    label: TvDisplayConfig.toHex(color),
                    child: InkWell(
                      key: Key('tv-color-${TvDisplayConfig.toHex(color).substring(1)}'),
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(c, color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.toARGB32() == current.toARGB32()
                                ? Theme.of(c).colorScheme.primary
                                : Colors.black26,
                            width: color.toARGB32() == current.toARGB32() ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('tv-color-hex'),
              controller: hex,
              decoration: InputDecoration(
                labelText: context.tr('Kode warna (hex)', 'Color code (hex)'),
                hintText: '#087E65',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('tv-color-hex-apply'),
              onPressed: () {
                final c2 = TvDisplayConfig.parseHex(hex.text);
                if (c2 == null) {
                  showSnack(c, context.tr('Format: #RRGGBB, contoh #087E65', 'Format: #RRGGBB, e.g. #087E65'));
                  return;
                }
                Navigator.pop(c, c2);
              },
              child: Text(context.tr('Pakai kode warna', 'Use color code')),
            ),
          ],
        ),
      ),
    );
    hex.dispose();
    if (picked != null) onPicked(picked);
  }

  ScheduleStatus _status(DisplaySchedule schedule, DateTime now) {
    final live = schedule.statusAt(now);
    if (_mode != _PreviewMode.iqamah) return live;
    return ScheduleStatus(
      SchedulePhase.beforeIqamah,
      live.prayer,
      now.add(const Duration(minutes: 7)),
      const Duration(minutes: 7, seconds: 30),
    );
  }

  /// Kanvas TV 1920×1080 yang diskalakan ke ruang yang tersedia.
  Widget _stage(Map<String, dynamic> content, {Key? key}) {
    final api = ref.read(masjidApiProvider);
    final mosque = Map<String, dynamic>.from(content['mosque'] as Map);
    final schedule = DisplaySchedule.fromMosque(mosque);
    final now = schedule.wallClock(widget.clock?.call() ?? DateTime.now());
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1920,
        height: 1080,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(1920, 1080), textScaler: TextScaler.noScaling),
          child: Material(
            type: MaterialType.transparency,
            child: TvStage(
              key: key,
              content: content,
              config: _config,
              now: now,
              schedule: schedule,
              status: _status(schedule, now),
              screen: _mode == _PreviewMode.info ? TvScreen.info : TvScreen.main,
              lang: context.lang,
              syncText: context.tr('Pratinjau', 'Preview'),
              qrisImageUrl: content['qris'] == null
                  ? ''
                  : '${api.baseUrl}/mosques/${widget.ctx.id}/displays/qris-image',
              qrisHeaders: {if (api.token != null) 'Authorization': 'Bearer ${api.token}'},
            ),
          ),
        ),
      ),
    );
  }

  void _openFullPreview(Map<String, dynamic> content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullPreview(
          title: context.tr('Pratinjau layar penuh', 'Full-screen preview'),
          closeLabel: context.tr('Tutup pratinjau', 'Close preview'),
          build: () => _stage(content),
        ),
      ),
    );
  }

  Widget _preview(Map<String, dynamic> content) => Stack(
    children: [
      Semantics(
        label: context.tr('Pratinjau layar TV', 'TV screen preview'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _stage(content, key: const Key('tv-design-preview')),
          ),
        ),
      ),
      Positioned(
        right: 6,
        bottom: 6,
        child: Material(
          color: Colors.black.withValues(alpha: .55),
          shape: const CircleBorder(),
          child: IconButton(
            key: const Key('tv-preview-fullscreen'),
            tooltip: context.tr('Lihat layar penuh', 'View full screen'),
            color: Colors.white,
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _openFullPreview(content),
          ),
        ),
      ),
    ],
  );

  Widget _themeChip(TvThemePreset p) {
    final selected = _config.theme == p;
    final bg = p == TvThemePreset.custom ? [_config.customBackground, _config.customBackground2] : p.background;
    final accent = p == TvThemePreset.custom ? _config.customAccent : p.accent;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        key: Key('tv-theme-${p.id}'),
        borderRadius: BorderRadius.circular(14),
        onTap: _canManage ? () => _set(_config.copyWith(theme: p)) : null,
        child: Container(
          width: 104,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: bg),
                ),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(fontSize: 12.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorRow(String key, String label, Color color, ValueChanged<Color> onPicked) => ListTile(
    key: Key('tv-custom-$key'),
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(TvDisplayConfig.toHex(color)),
    trailing: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26),
      ),
    ),
    onTap: _canManage ? () => _pickColor(label, color, onPicked) : null,
  );

  Widget _switch(String key, String label, String help, bool value, TvDisplayConfig Function(bool) next) =>
      SwitchListTile(
        key: Key('tv-widget-$key'),
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(help),
        value: value,
        onChanged: _canManage ? (v) => _set(next(v)) : null,
      );

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final preview = ref.watch(displayPreviewProvider(widget.ctx.id));
    final palette = _config.palette;
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          setState(() => _config = _saved);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.tr('Desain Tampilan TV', 'TV Display Design')), centerTitle: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  preview.when(
                    loading: () => const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.tr('Pratinjau gagal dimuat', 'Preview failed to load')),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(displayPreviewProvider(widget.ctx.id)),
                              icon: const Icon(MoeslimIcons.refresh),
                              label: Text(context.tr('Coba lagi', 'Try again')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: _preview,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_PreviewMode>(
                    key: const Key('tv-preview-mode'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: _PreviewMode.main, label: Text(context.tr('Utama', 'Main'))),
                      ButtonSegment(value: _PreviewMode.info, label: Text(context.tr('Info Jamaah', 'Info'))),
                      ButtonSegment(value: _PreviewMode.iqamah, label: Text(context.tr('Iqamah', 'Iqamah'))),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (v) => setState(() => _mode = v.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                key: const Key('tv-design-controls'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  SectionHeader(context.tr('Tema Warna', 'Color Theme')),
                  SizedBox(
                    height: 108,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: TvThemePreset.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => _themeChip(TvThemePreset.values[i]),
                    ),
                  ),
                  if (_config.theme == TvThemePreset.custom) ...[
                    _colorRow(
                      'bg1',
                      context.tr('Latar (atas)', 'Background (top)'),
                      _config.customBackground,
                      (c) => _set(_config.copyWith(customBackground: c)),
                    ),
                    _colorRow(
                      'bg2',
                      context.tr('Latar (bawah)', 'Background (bottom)'),
                      _config.customBackground2,
                      (c) => _set(_config.copyWith(customBackground2: c)),
                    ),
                    _colorRow(
                      'accent',
                      context.tr('Aksen (bingkai & waktu aktif)', 'Accent (frames & active time)'),
                      _config.customAccent,
                      (c) => _set(_config.copyWith(customAccent: c)),
                    ),
                    Text(
                      [
                        if (palette.adjusted)
                          context.tr(
                            'Warna latar digeser sedikit agar teks tetap terbaca dari jauh (kontras minimal 4,5:1).',
                            'The background was shifted slightly so text stays readable from afar (contrast at least 4.5:1).',
                          ),
                        if (palette.accentText != _config.customAccent)
                          context.tr(
                            'Aksen terlalu mirip latar, jadi teks aksen memakai warna lain agar terbaca.',
                            'Accent is too close to the background, so accent text uses another color to stay readable.',
                          ),
                        if (!palette.adjusted && palette.accentText == _config.customAccent)
                          context.tr(
                            'Warna teks dipilih otomatis agar tetap terbaca dari jauh.',
                            'Text colors are chosen automatically to stay readable from afar.',
                          ),
                      ].join(' '),
                      key: const Key('tv-contrast-note'),
                      style: t.bodySmall,
                    ),
                  ],
                  SectionHeader(context.tr('Widget di Layar', 'On-screen Widgets')),
                  _switch(
                    'illustration',
                    context.tr('Ilustrasi masjid', 'Mosque illustration'),
                    context.tr(
                      'Gambar masjid di sisi kanan layar utama',
                      'Mosque artwork on the right of the main screen',
                    ),
                    _config.showIllustration,
                    (v) => _config.copyWith(showIllustration: v),
                  ),
                  _switch(
                    'pattern',
                    context.tr('Pola bintang di latar', 'Star pattern background'),
                    context.tr('Ornamen tipis di sisi kiri', 'Subtle ornament on the left'),
                    _config.showPattern,
                    (v) => _config.copyWith(showPattern: v),
                  ),
                  _switch(
                    'seconds',
                    context.tr('Detik pada jam', 'Seconds on the clock'),
                    context.tr('Jam tampil 12:04:30 atau 12:04', 'Clock shows 12:04:30 or 12:04'),
                    _config.showSeconds,
                    (v) => _config.copyWith(showSeconds: v),
                  ),
                  _switch(
                    'hijri',
                    context.tr('Tanggal Hijriah', 'Hijri date'),
                    context.tr('Di bawah tanggal Masehi', 'Below the Gregorian date'),
                    _config.showHijri,
                    (v) => _config.copyWith(showHijri: v),
                  ),
                  _switch(
                    'sunrise',
                    context.tr('Waktu Syuruq', 'Sunrise time'),
                    context.tr('Kartu Syuruq di deretan jadwal', 'Sunrise card in the schedule row'),
                    _config.showSunrise,
                    (v) => _config.copyWith(showSunrise: v),
                  ),
                  _switch(
                    'staff',
                    context.tr('Petugas hari ini & Jumat', "Today's & Friday duty roster"),
                    context.tr('Imam, muadzin, khatib, bilal', 'Imam, muezzin, khatib, bilal'),
                    _config.showStaff,
                    (v) => _config.copyWith(showStaff: v),
                  ),
                  _switch(
                    'ticker',
                    context.tr('Bilah pengumuman berjalan', 'Scrolling announcement bar'),
                    context.tr('Teks berjalan di bagian bawah', 'Scrolling text at the bottom'),
                    _config.showTicker,
                    (v) => _config.copyWith(showTicker: v),
                  ),
                  _switch(
                    'info',
                    context.tr('Layar Informasi Jamaah', 'Congregation info screen'),
                    context.tr(
                      'Agenda, kas/QRIS, dan pengumuman bergantian',
                      'Events, cash/QRIS and announcements in rotation',
                    ),
                    _config.showInfoScreen,
                    (v) => _config.copyWith(showInfoScreen: v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('Lama Layar Informasi per menit', 'Info screen duration per minute'),
                    style: t.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<int>(
                    key: const Key('tv-info-seconds'),
                    showSelectedIcon: false,
                    segments: [
                      for (final s in TvDisplayConfig.allowedInfoSeconds)
                        ButtonSegment(value: s, label: Text(context.tr('$s detik', '$s s'))),
                    ],
                    selected: {_config.infoSeconds},
                    onSelectionChanged: _canManage && _config.showInfoScreen
                        ? (v) => _set(_config.copyWith(infoSeconds: v.first))
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(context.tr('Ukuran jam', 'Clock size'), style: t.titleSmall),
                  const SizedBox(height: 6),
                  SegmentedButton<bool>(
                    key: const Key('tv-clock-size'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: false, label: Text(context.tr('Normal', 'Normal'))),
                      ButtonSegment(value: true, label: Text(context.tr('Besar', 'Large'))),
                    ],
                    selected: {_config.largeClock},
                    onSelectionChanged: _canManage ? (v) => _set(_config.copyWith(largeClock: v.first)) : null,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('tv-ticker-text'),
                    controller: _ticker,
                    enabled: _canManage,
                    maxLength: TvDisplayConfig.maxTickerLength,
                    decoration: InputDecoration(
                      labelText: context.tr('Teks berjalan tambahan', 'Extra scrolling text'),
                      helperMaxLines: 3,
                      helperText: context.tr(
                        'Tampil paling depan di bilah pengumuman, mis. "Mohon matikan ponsel".',
                        'Shown first in the announcement bar, e.g. "Please silence your phone".',
                      ),
                    ),
                    onChanged: (v) => _set(_config.copyWith(tickerText: v.trim())),
                  ),
                  if (widget.devices.length > 1)
                    CheckboxListTile(
                      key: const Key('tv-apply-all'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        context.tr(
                          'Terapkan ke semua TV (${widget.devices.length})',
                          'Apply to all TVs (${widget.devices.length})',
                        ),
                      ),
                      value: _applyAll,
                      onChanged: _canManage ? (v) => setState(() => _applyAll = v ?? false) : null,
                    ),
                  const SizedBox(height: 8),
                  if (_canManage)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          key: const Key('tv-design-save'),
                          onPressed: _busy || !_dirty ? null : _save,
                          icon: _busy
                              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(MoeslimIcons.simpan),
                          label: Text(context.tr('Simpan ke TV', 'Save to TV')),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          key: const Key('tv-design-reset'),
                          onPressed: () {
                            _ticker.clear();
                            _set(const TvDisplayConfig());
                          },
                          child: Text(context.tr('Kembalikan bawaan', 'Restore defaults')),
                        ),
                      ],
                    )
                  else
                    Text(
                      context.tr(
                        'Anda dapat melihat pratinjau. Mengubah desain memerlukan izin kelola TV Display.',
                        'You can view the preview. Changing the design requires TV Display manage permission.',
                      ),
                      style: t.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}

/// Pratinjau layar penuh: kanvas TV diputar lanskap memenuhi layar ponsel, jam ikut berjalan.
class _FullPreview extends StatefulWidget {
  final String title;
  final String closeLabel;
  final Widget Function() build;
  const _FullPreview({required this.title, required this.closeLabel, required this.build});

  @override
  State<_FullPreview> createState() => _FullPreviewState();
}

class _FullPreviewState extends State<_FullPreview> {
  late final Timer _timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (mounted) setState(() {});
  });

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              label: widget.title,
              child: LayoutBuilder(
                builder: (_, box) =>
                    box.maxHeight > box.maxWidth ? RotatedBox(quarterTurns: 1, child: widget.build()) : widget.build(),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              color: Colors.black.withValues(alpha: .55),
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('tv-preview-close'),
                tooltip: widget.closeLabel,
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
