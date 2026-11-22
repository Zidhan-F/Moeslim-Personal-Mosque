import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_core/personal_core.dart';
import 'package:share_plus/share_plus.dart';

import '../../ui/components.dart';

/// Rasio kartu yang bisa dipilih (Story untuk WhatsApp/Instagram, Persegi untuk feed).
enum _CardRatio {
  bebas('Menyesuaikan', null),
  persegi('Persegi 1:1', 1.0),
  story('Story 9:16', 9 / 16);

  final String label;
  final double? ratio;
  const _CardRatio(this.label, this.ratio);
}

class _Palette {
  final Color bg;
  final Color bg2;
  final Color fg;
  final Color accent;
  const _Palette(this.bg, this.bg2, this.fg, this.accent);
}

_Palette _paletteOf(ShareCardThemeStyle s) => switch (s) {
      ShareCardThemeStyle.emeraldGold => const _Palette(BrandColors.deep, Color(0xFF0B4A3F), Colors.white, BrandColors.gold),
      ShareCardThemeStyle.creamManuscript =>
        const _Palette(BrandColors.cream, Color(0xFFF1E6CC), BrandColors.deep, BrandColors.emerald),
      ShareCardThemeStyle.midnightDeep =>
        const _Palette(BrandColors.nightSurface, Color(0xFF06201B), BrandColors.cream, BrandColors.emeraldLight),
      ShareCardThemeStyle.sandDhuha =>
        const _Palette(Color(0xFFF6E3B4), Color(0xFFEFC97A), Color(0xFF4A3410), Color(0xFF8A5A12)),
      ShareCardThemeStyle.tealLagoon =>
        const _Palette(Color(0xFF0E5C63), Color(0xFF0A3F4A), Colors.white, Color(0xFF8FE3D0)),
      ShareCardThemeStyle.roseSakinah =>
        const _Palette(Color(0xFFFCE9EC), Color(0xFFF4CDD5), Color(0xFF5B1F2E), Color(0xFFB04A62)),
      ShareCardThemeStyle.pearlWhite =>
        const _Palette(Colors.white, Color(0xFFEAF3EF), BrandColors.deep, BrandColors.emerald),
      ShareCardThemeStyle.royalGold =>
        const _Palette(Color(0xFF2B1B0A), Color(0xFF4A3010), Color(0xFFFBEFD2), Color(0xFFE8B94A)),
    };

class ShareCardPage extends StatefulWidget {
  final String? initialArabic;
  final String? initialTranslation;
  final String? initialSource;

  const ShareCardPage({
    super.key,
    this.initialArabic,
    this.initialTranslation,
    this.initialSource,
  });

  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  ShareCardThemeStyle _themeStyle = ShareCardThemeStyle.emeraldGold;
  _CardRatio _ratio = _CardRatio.bebas;
  final _cardKey = GlobalKey();
  bool _busy = false;
  late final TextEditingController _arabicCtrl;
  late final TextEditingController _translationCtrl;
  late final TextEditingController _sourceCtrl;

  @override
  void initState() {
    super.initState();
    final first = defaultShareCardTemplates.first;
    _arabicCtrl = TextEditingController(text: widget.initialArabic ?? first.arabic);
    _translationCtrl = TextEditingController(text: widget.initialTranslation ?? first.translation);
    _sourceCtrl = TextEditingController(text: widget.initialSource ?? first.source);
  }

  @override
  void dispose() {
    _arabicCtrl.dispose();
    _translationCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  void _applyTemplate(ShareCardTemplate t) {
    setState(() {
      _arabicCtrl.text = t.arabic;
      _translationCtrl.text = t.translation;
      _sourceCtrl.text = t.source;
    });
  }

  String get _plainText => '${_arabicCtrl.text.trim()}\n\n'
      '"${_translationCtrl.text.trim()}"\n'
      '(${_sourceCtrl.text.trim()} · Moeslim PM)';

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _copyFormattedCard() {
    Clipboard.setData(ClipboardData(text: _plainText));
    _toast('Kutipan kartu siap bagikan telah disalin ke papan klip.');
  }

  /// Merender kartu menjadi PNG beresolusi tinggi.
  Future<Uint8List> _renderPng() async {
    final boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      _toast('Gagal memproses kartu. Coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareImage() => _run(() async {
        final bytes = await _renderPng();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/kartu_moeslim_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'image/png')],
            text: '${_sourceCtrl.text.trim()} · Moeslim PM',
          ),
        );
      });

  Future<void> _shareText() => _run(() async {
        await SharePlus.instance.share(ShareParams(text: _plainText));
      });

  Future<void> _saveToGallery() => _run(() async {
        final bytes = await _renderPng();
        if (!await Gal.hasPermission(toAlbum: true) && !await Gal.requestPermission(toAlbum: true)) {
          _toast('Izin penyimpanan ditolak. Aktifkan lewat pengaturan perangkat.');
          return;
        }
        await Gal.putImageBytes(bytes, album: 'Moeslim PM', name: 'kartu_moeslim_${DateTime.now().millisecondsSinceEpoch}');
        _toast('Kartu tersimpan di galeri (album Moeslim PM).');
      });

  Widget _cardBody(_Palette p, double width) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MOESLIM PM',
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text(
            _arabicCtrl.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: quranTextStyle(fontSize: 28, color: p.fg),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(p.accent, BlendMode.srcIn),
              child: const BrandElementArt(BrandElement.ayahDivider, width: 130, height: 22),
            ),
          ),
          Text(
            '"${_translationCtrl.text}"',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.fg, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            _sourceCtrl.text,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _card(_Palette p) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.bg, p.bg2]),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: p.accent, width: 2),
    );
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        key: const Key('share-card-preview'),
        decoration: decoration,
        child: _ratio.ratio == null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(builder: (_, c) => _cardBody(p, c.maxWidth)),
              )
            : AspectRatio(
                aspectRatio: _ratio.ratio!,
                child: LayoutBuilder(
                  builder: (_, c) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: FittedBox(fit: BoxFit.scaleDown, child: _cardBody(p, c.maxWidth - 48)),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _paletteOf(_themeStyle);

    return Scaffold(
      appBar: AppBar(title: const Text('Pembuat Kartu Bagikan Ayat & Doa'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Pratinjau Kartu Dakwah'),
          _card(palette),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('share-image-btn'),
            onPressed: _busy ? null : _shareImage,
            icon: const Icon(MoeslimIcons.bagikan),
            label: const Text('Bagikan Gambar (WhatsApp, Instagram, dll.)'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('save-card-btn'),
                onPressed: _busy ? null : _saveToGallery,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Simpan ke Galeri'),
              ),
              OutlinedButton.icon(
                key: const Key('share-text-btn'),
                onPressed: _busy ? null : _shareText,
                icon: const Icon(Icons.text_snippet_outlined),
                label: const Text('Bagikan Teks'),
              ),
              OutlinedButton.icon(
                key: const Key('copy-share-card-btn'),
                onPressed: _copyFormattedCard,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Salin Teks'),
              ),
            ],
          ),
          const SectionHeader('Pilih Tema Kartu'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final st in ShareCardThemeStyle.values)
                ChoiceChip(
                  key: Key('share-theme-${st.name}'),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  avatar: CircleAvatar(backgroundColor: _paletteOf(st).bg2, radius: 8),
                  label: Text(st.label),
                  selected: _themeStyle == st,
                  onSelected: (_) => setState(() => _themeStyle = st),
                ),
            ],
          ),
          const SectionHeader('Ukuran Kartu'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in _CardRatio.values)
                ChoiceChip(
                  key: Key('share-ratio-${r.name}'),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  label: Text(r.label),
                  selected: _ratio == r,
                  onSelected: (_) => setState(() => _ratio = r),
                ),
            ],
          ),
          const SectionHeader('Pilih Templat Ayat / Doa / Hadits'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final tpl in defaultShareCardTemplates)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      key: Key('share-tpl-${tpl.id}'),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text('${tpl.category}: ${tpl.source}'),
                      onPressed: () => _applyTemplate(tpl),
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader('Kustomisasi Teks Kartu'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _arabicCtrl,
                    decoration: const InputDecoration(labelText: 'Teks Arab'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('share-translation-field'),
                    controller: _translationCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Terjemahan / Kutipan'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _sourceCtrl,
                    decoration: const InputDecoration(labelText: 'Sumber (Surah / Hadits)'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
