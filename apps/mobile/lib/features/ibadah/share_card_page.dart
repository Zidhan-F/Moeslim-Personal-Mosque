import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_core/personal_core.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import '../home/home_page.dart' show dailyAyahRefs;
import '../quran/quran_source.dart';
import 'doa_pages.dart' show cleanDuaNote, dailyDuasProvider;

/// Rasio kanvas kartu untuk berbagai kebutuhan berbagi.
enum _CardRatio {
  bebas('Menyesuaikan', 'Auto Fit', null),
  persegi('Persegi 1:1', 'Square 1:1', 1.0),
  potret('Potret 4:5', 'Portrait 4:5', 4 / 5),
  story('Story 9:16', 'Story 9:16', 9 / 16),
  lanskap('Lanskap 16:9', 'Wide 16:9', 16 / 9);

  final String label;
  final String labelEn;
  final double? ratio;
  const _CardRatio(this.label, this.labelEn, this.ratio);
}

enum _GradientStyle {
  diagonal('Diagonal', 'Diagonal'),
  vertical('Vertikal', 'Vertical'),
  radial('Radial', 'Radial'),
  solid('Polos', 'Solid');

  final String label;
  final String labelEn;
  const _GradientStyle(this.label, this.labelEn);
}

enum _PatternStyle {
  none('Tanpa Pola', 'None'),
  eightPointStar('Bintang 8', '8-Point Star'),
  mushafLattice('Kisi Mushaf', 'Mushaf Lattice'),
  mihrabArch('Lengkung Mihrab', 'Mihrab Arch'),
  brandOrnament('Ornamen Moeslim', 'Moeslim Pattern');

  final String label;
  final String labelEn;
  const _PatternStyle(this.label, this.labelEn);
}

enum _FrameStyle {
  none('Tanpa Bingkai', 'None'),
  single('Garis Tunggal', 'Single Line'),
  doubleClassic('Bingkai Ganda', 'Double Frame'),
  cornerBrackets('Sudut Mushaf', 'Corner Ornaments'),
  archVault('Lengkung Kubah', 'Arch Frame');

  final String label;
  final String labelEn;
  const _FrameStyle(this.label, this.labelEn);
}

enum _DividerStyle {
  ornament('Ornamen Mushaf', 'Mushaf Divider'),
  diamondRule('Garis Ketupat', 'Diamond Rule'),
  rubElHizb('Bintang Rub el Hizb', 'Rub el Hizb'),
  none('Tanpa Pemisah', 'None');

  final String label;
  final String labelEn;
  const _DividerStyle(this.label, this.labelEn);
}

enum _CardLanguageMode {
  followApp('Ikuti Aplikasi', 'App'),
  indonesian('ID', 'ID'),
  english('EN', 'EN'),
  bilingual('ID + EN', 'ID + EN');

  final String label;
  final String labelEn;
  const _CardLanguageMode(this.label, this.labelEn);
}

enum _WatermarkPosition {
  top('Atas', 'Top'),
  bottom('Bawah', 'Bottom');

  final String label;
  final String labelEn;
  const _WatermarkPosition(this.label, this.labelEn);
}

class _Palette {
  final Color bg;
  final Color bg2;
  final Color fg;
  final Color accent;
  const _Palette(this.bg, this.bg2, this.fg, this.accent);
}

const _customBgSwatches = <Color>[
  Color(0xFF07372F),
  Color(0xFF0B4A3F),
  Color(0xFF102A43),
  Color(0xFF1C2B1E),
  Color(0xFF171717),
  Color(0xFF3E1F27),
  Color(0xFF2B1B0A),
  Color(0xFF5A2A1A),
  Color(0xFFF7F7F1),
  Color(0xFFF6E3B4),
  Color(0xFFFCE9EC),
  Color(0xFFFFFFFF),
];

const _customAccentSwatches = <Color>[
  BrandColors.gold,
  Color(0xFFE8B94A),
  BrandColors.emerald,
  BrandColors.emeraldLight,
  Color(0xFF8FE3D0),
  Color(0xFF8A6A14),
  Color(0xFFB04A62),
  Color(0xFFD97B4A),
  Color(0xFFCBD5E1),
  BrandColors.deep,
];

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
      ShareCardThemeStyle.oliveMadinah =>
        const _Palette(Color(0xFF233322), Color(0xFF394D33), Color(0xFFF6F4E8), Color(0xFFD9B45A)),
      ShareCardThemeStyle.indigoFajr =>
        const _Palette(Color(0xFF102038), Color(0xFF1E375C), Color(0xFFF5F7FB), Color(0xFFE5C472)),
      ShareCardThemeStyle.obsidianInk =>
        const _Palette(Color(0xFF151817), Color(0xFF262B29), Color(0xFFF4F3EE), Color(0xFFD9AB36)),
      ShareCardThemeStyle.terracottaAndalus =>
        const _Palette(Color(0xFF6B2D1E), Color(0xFF4A1D12), Color(0xFFFDF5EC), Color(0xFFF2C97D)),
    };

Color _deriveSecondaryBg(Color base) {
  final hsl = HSLColor.fromColor(base);
  final shifted = hsl.lightness < 0.45
      ? hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0))
      : hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0));
  return shifted.toColor();
}

Color _contrastFgFor(Color bg) {
  final whiteRatio = contrastRatio(Colors.white, bg);
  final darkRatio = contrastRatio(BrandColors.deep, bg);
  return whiteRatio >= darkRatio ? Colors.white : BrandColors.deep;
}

Color _contrastAccentFor(Color accent, Color bg) {
  if (contrastRatio(accent, bg) >= 3.2) return accent;
  return _contrastFgFor(bg);
}

String _toArabicIndicDigits(int n) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final s = '$n';
  final buf = StringBuffer();
  for (final code in s.codeUnits) {
    if (code >= 48 && code <= 57) {
      buf.write(digits[code - 48]);
    } else {
      buf.writeCharCode(code);
    }
  }
  return buf.toString();
}

sealed class _PickedContent {
  const _PickedContent();
}

class _PickedQuran extends _PickedContent {
  final Surah surah;
  final List<Ayah> ayahs;
  const _PickedQuran(this.surah, this.ayahs);
}

class _PickedHadith extends _PickedContent {
  final HadithItem hadith;
  const _PickedHadith(this.hadith);
}

class _PickedDua extends _PickedContent {
  final DailyDua dua;
  const _PickedDua(this.dua);
}

class _PickedTemplate extends _PickedContent {
  final ShareCardTemplate template;
  const _PickedTemplate(this.template);
}

class ShareCardPage extends ConsumerStatefulWidget {
  final String? initialArabic;
  final String? initialLatin;
  final String? initialTranslation;
  final String? initialSource;
  final String? initialBadge;

  const ShareCardPage({
    super.key,
    this.initialArabic,
    this.initialLatin,
    this.initialTranslation,
    this.initialSource,
    this.initialBadge,
  });

  @override
  ConsumerState<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends ConsumerState<ShareCardPage> {
  final _cardKey = GlobalKey();
  final _rng = math.Random();
  bool _busy = false;
  bool _userEdited = false;

  int _studioTab = 0;
  _PickedContent? _picked;
  _CardLanguageMode _cardLangMode = _CardLanguageMode.followApp;

  // Tema, kanvas & warna
  ShareCardThemeStyle _themeStyle = ShareCardThemeStyle.emeraldGold;
  _CardRatio _ratio = _CardRatio.bebas;
  _GradientStyle _gradientStyle = _GradientStyle.diagonal;
  Color? _customBg;
  Color? _customAccent;

  // Ornamen & bingkai
  _PatternStyle _patternStyle = _PatternStyle.eightPointStar;
  double _patternOpacity = 0.09;
  _FrameStyle _frameStyle = _FrameStyle.single;
  _DividerStyle _dividerStyle = _DividerStyle.ornament;
  double _borderRadius = 22;
  double _cardPadding = 24;

  // Tipografi & visibilitas
  double _arabicSize = 27;
  double _arabicLineHeight = 1.95;
  double _translationSize = 15;
  TextAlign _textAlign = TextAlign.center;
  bool _italicTranslation = false;
  bool _showQuotes = true;
  bool _showArabic = true;
  bool _showLatin = false;
  bool _showTranslation = true;
  bool _showSource = true;
  bool _showBadge = false;
  bool _showWatermark = true;
  _WatermarkPosition _watermarkPosition = _WatermarkPosition.top;

  late final TextEditingController _arabicCtrl;
  late final TextEditingController _latinCtrl;
  late final TextEditingController _translationCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _badgeCtrl;
  late final TextEditingController _watermarkCtrl;

  @override
  void initState() {
    super.initState();
    final hasInitial = widget.initialArabic != null ||
        widget.initialTranslation != null ||
        widget.initialSource != null;
    if (hasInitial) {
      _userEdited = true;
    }
    _arabicCtrl = TextEditingController(text: widget.initialArabic ?? '');
    _latinCtrl = TextEditingController(text: widget.initialLatin ?? '');
    _translationCtrl = TextEditingController(text: widget.initialTranslation ?? '');
    _sourceCtrl = TextEditingController(text: widget.initialSource ?? '');
    _badgeCtrl = TextEditingController(text: widget.initialBadge ?? '');
    _watermarkCtrl = TextEditingController();
    if (widget.initialLatin != null && widget.initialLatin!.trim().isNotEmpty) {
      _showLatin = true;
    }
    if (widget.initialBadge != null && widget.initialBadge!.trim().isNotEmpty) {
      _showBadge = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool get _hasAnyUserInput =>
      _userEdited ||
      _arabicCtrl.text.trim().isNotEmpty ||
      _latinCtrl.text.trim().isNotEmpty ||
      _translationCtrl.text.trim().isNotEmpty ||
      _sourceCtrl.text.trim().isNotEmpty;

  String _previewArabic() {
    if (_arabicCtrl.text.trim().isNotEmpty) return _arabicCtrl.text.trim();
    return _hasAnyUserInput ? '' : defaultShareCardTemplates.first.arabic;
  }

  String _previewLatin() {
    if (_latinCtrl.text.trim().isNotEmpty) return _latinCtrl.text.trim();
    return _hasAnyUserInput ? '' : (defaultShareCardTemplates.first.latin ?? '');
  }

  String _previewTranslation(AppLanguage appLang) {
    if (_translationCtrl.text.trim().isNotEmpty) return _translationCtrl.text.trim();
    if (_hasAnyUserInput) return '';
    final tpl = defaultShareCardTemplates.first;
    return _formatTranslation(tpl.translation, tpl.translationFor(AppLanguage.en), appLang);
  }

  String _previewSource(AppLanguage appLang) {
    if (_sourceCtrl.text.trim().isNotEmpty) return _sourceCtrl.text.trim();
    if (_hasAnyUserInput) return '';
    return defaultShareCardTemplates.first.sourceFor(_effectiveSingleLang(appLang));
  }

  String _previewBadge(AppLanguage appLang) {
    if (_badgeCtrl.text.trim().isNotEmpty) return _badgeCtrl.text.trim();
    if (_hasAnyUserInput) return '';
    return defaultShareCardTemplates.first.categoryFor(_effectiveSingleLang(appLang));
  }

  String _previewWatermark() =>
      _watermarkCtrl.text.trim().isEmpty ? 'MOESLIM PM' : _watermarkCtrl.text.trim();

  @override
  void dispose() {
    _arabicCtrl.dispose();
    _latinCtrl.dispose();
    _translationCtrl.dispose();
    _sourceCtrl.dispose();
    _badgeCtrl.dispose();
    _watermarkCtrl.dispose();
    super.dispose();
  }

  AppLanguage _effectiveSingleLang(AppLanguage appLang) => switch (_cardLangMode) {
        _CardLanguageMode.followApp => appLang,
        _CardLanguageMode.indonesian => AppLanguage.id,
        _CardLanguageMode.english => AppLanguage.en,
        _CardLanguageMode.bilingual => appLang,
      };

  String _formatTranslation(String idText, String enText, AppLanguage appLang) {
    final cleanId = idText.trim();
    final cleanEn = enText.trim();
    return switch (_cardLangMode) {
      _CardLanguageMode.followApp => appLang == AppLanguage.en ? (cleanEn.isNotEmpty ? cleanEn : cleanId) : cleanId,
      _CardLanguageMode.indonesian => cleanId.isNotEmpty ? cleanId : cleanEn,
      _CardLanguageMode.english => cleanEn.isNotEmpty ? cleanEn : cleanId,
      _CardLanguageMode.bilingual =>
        cleanId.isNotEmpty && cleanEn.isNotEmpty && cleanId != cleanEn ? '$cleanId\n\n$cleanEn' : (cleanId.isNotEmpty ? cleanId : cleanEn),
    };
  }

  void _syncPickedContent(AppLanguage appLang, {bool notify = true}) {
    final p = _picked;
    if (p == null) return;
    final singleLang = _effectiveSingleLang(appLang);

    void apply() {
      switch (p) {
        case _PickedTemplate(:final template):
          _arabicCtrl.text = template.arabic;
          _latinCtrl.text = template.latin ?? '';
          _translationCtrl.text = _formatTranslation(
            template.translation,
            template.translationFor(AppLanguage.en),
            appLang,
          );
          _sourceCtrl.text = template.sourceFor(singleLang);
          _badgeCtrl.text = template.categoryFor(singleLang);
        case _PickedQuran(:final surah, :final ayahs):
          if (ayahs.isEmpty) return;
          final single = ayahs.length == 1;
          _arabicCtrl.text = single
              ? ayahs.first.text
              : ayahs.map((a) => '${a.text} ۝${_toArabicIndicDigits(a.number)}').join(' ');
          _latinCtrl.text = '';
          final idTr = single
              ? (ayahs.first.translation ?? '')
              : ayahs.map((a) => '(${a.number}) ${a.translation ?? ''}').join(' ');
          final enTr = single
              ? (ayahs.first.translationEn ?? ayahs.first.translation ?? '')
              : ayahs.map((a) => '(${a.number}) ${a.translationEn ?? a.translation ?? ''}').join(' ');
          _translationCtrl.text = _formatTranslation(idTr, enTr, appLang);
          final rangeStr = single ? '${ayahs.first.number}' : '${ayahs.first.number}-${ayahs.last.number}';
          _sourceCtrl.text = singleLang == AppLanguage.en
              ? 'Quran ${surah.name} (${surah.number}): $rangeStr'
              : 'QS. ${surah.name}: $rangeStr';
          _badgeCtrl.text = singleLang == AppLanguage.en ? 'Al-Quran' : 'Al-Qur\'an';
        case _PickedHadith(:final hadith):
          _arabicCtrl.text = hadith.arabic;
          _latinCtrl.text = hadith.latin;
          _translationCtrl.text = _formatTranslation(
            hadith.translation,
            hadith.translationFor(AppLanguage.en),
            appLang,
          );
          _sourceCtrl.text = hadith.narratorFor(singleLang);
          _badgeCtrl.text = hadith.collectionFor(singleLang);
        case _PickedDua(:final dua):
          _arabicCtrl.text = dua.arabic;
          _latinCtrl.text = dua.latin;
          _translationCtrl.text = _formatTranslation(
            dua.translation,
            dua.translationFor(AppLanguage.en),
            appLang,
          );
          final title = dua.titleFor(singleLang);
          final src = cleanDuaNote(dua.sourceFor(singleLang));
          _sourceCtrl.text = src.isNotEmpty && src.length <= 64 ? '$title · $src' : title;
          _badgeCtrl.text = dua.groupFor(singleLang);
      }
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _applyPicked(_PickedContent content, {bool enableLatin = false}) {
    setState(() {
      _picked = content;
      _userEdited = true;
      _showArabic = true;
      _showTranslation = true;
      _showSource = true;
      if (enableLatin) _showLatin = true;
    });
    _syncPickedContent(context.lang);
  }

  Future<void> _pickRandomSource() async {
    final pickHadith = _rng.nextBool();
    if (pickHadith) {
      final h = hadithCatalog[_rng.nextInt(hadithCatalog.length)];
      _applyPicked(_PickedHadith(h));
      return;
    }
    final (s, a) = dailyAyahRefs[_rng.nextInt(dailyAyahRefs.length)];
    final ayat = await ref.read(quranSourceProvider).load(s);
    if (!mounted) return;
    if (ayat != null && a <= ayat.length) {
      _applyPicked(_PickedQuran(surahs[s - 1], [ayat[a - 1]]));
    } else {
      final h = hadithCatalog[_rng.nextInt(hadithCatalog.length)];
      _applyPicked(_PickedHadith(h));
    }
  }

  void _resetStyling() {
    setState(() {
      _themeStyle = ShareCardThemeStyle.emeraldGold;
      _ratio = _CardRatio.bebas;
      _gradientStyle = _GradientStyle.diagonal;
      _customBg = null;
      _customAccent = null;
      _patternStyle = _PatternStyle.eightPointStar;
      _patternOpacity = 0.09;
      _frameStyle = _FrameStyle.single;
      _dividerStyle = _DividerStyle.ornament;
      _borderRadius = 22;
      _cardPadding = 24;
      _arabicSize = 27;
      _arabicLineHeight = 1.95;
      _translationSize = 15;
      _textAlign = TextAlign.center;
      _italicTranslation = false;
      _showQuotes = true;
      _showArabic = true;
      _showLatin = false;
      _showTranslation = true;
      _showSource = true;
      _showBadge = false;
      _showWatermark = true;
      _watermarkPosition = _WatermarkPosition.top;
      _watermarkCtrl.clear();
    });
    _toast(context.tr('Gaya kartu dikembalikan ke standar.', 'Card style reset to defaults.'));
  }

  _Palette _activePalette() {
    final base = _paletteOf(_themeStyle);
    final bg = _customBg ?? base.bg;
    final bg2 = _customBg != null ? _deriveSecondaryBg(_customBg!) : base.bg2;
    final fg = _customBg != null ? _contrastFgFor(bg) : base.fg;
    final accent = _customAccent != null ? _contrastAccentFor(_customAccent!, bg) : (_customBg != null ? _contrastAccentFor(base.accent, bg) : base.accent);
    return _Palette(bg, bg2, fg, accent);
  }

  String _buildPlainText(AppLanguage appLang) {
    final arabic = _previewArabic();
    final latin = _previewLatin();
    final translation = _previewTranslation(appLang);
    final source = _previewSource(appLang);
    final watermark = _previewWatermark();
    final parts = <String>[
      if (_showArabic && arabic.isNotEmpty) arabic,
      if (_showLatin && latin.isNotEmpty) latin,
      if (_showTranslation && translation.isNotEmpty)
        _showQuotes ? '"$translation"' : translation,
      if (_showSource && source.isNotEmpty)
        '($source${_showWatermark && watermark.isNotEmpty ? ' · $watermark' : ''})',
    ];
    return parts.join('\n\n');
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _copyFormattedCard() {
    Clipboard.setData(ClipboardData(text: _buildPlainText(context.lang)));
    _toast(
      context.tr(
        'Kutipan kartu siap bagikan telah disalin ke papan klip.',
        'Shareable card quote copied to clipboard.',
      ),
    );
  }

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
      if (mounted) {
        _toast(context.tr('Gagal memproses kartu. Coba lagi.', 'Failed to process card. Please try again.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareImage() => _run(() async {
        final appLang = context.lang;
        final bytes = await _renderPng();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/kartu_moeslim_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'image/png')],
            text: '${_previewSource(appLang)} · ${_previewWatermark()}',
          ),
        );
      });

  Future<void> _shareText() => _run(() async {
        await SharePlus.instance.share(ShareParams(text: _buildPlainText(context.lang)));
      });

  Future<void> _saveToGallery() => _run(() async {
        final bytes = await _renderPng();
        if (!await Gal.hasPermission(toAlbum: true) && !await Gal.requestPermission(toAlbum: true)) {
          if (mounted) {
            _toast(
              context.tr(
                'Izin penyimpanan ditolak. Aktifkan lewat pengaturan perangkat.',
                'Storage permission denied. Enable it in device settings.',
              ),
            );
          }
          return;
        }
        await Gal.putImageBytes(bytes, album: 'Moeslim PM', name: 'kartu_moeslim_${DateTime.now().millisecondsSinceEpoch}');
        if (mounted) {
          _toast(
            context.tr(
              'Kartu tersimpan di galeri (album Moeslim PM).',
              'Card saved to gallery (Moeslim PM album).',
            ),
          );
        }
      });

  Future<void> _openQuranPicker() async {
    final result = await showModalBottomSheet<_PickedQuran>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _QuranPickerSheet(),
    );
    if (result != null && mounted) {
      _applyPicked(result);
    }
  }

  Future<void> _openHadithPicker() async {
    final result = await showModalBottomSheet<HadithItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _HadithPickerSheet(),
    );
    if (result != null && mounted) {
      _applyPicked(_PickedHadith(result));
    }
  }

  Future<void> _openDuaPicker() async {
    final result = await showModalBottomSheet<DailyDua>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _DuaPickerSheet(),
    );
    if (result != null && mounted) {
      _applyPicked(_PickedDua(result));
    }
  }

  CrossAxisAlignment get _crossAlign => switch (_textAlign) {
        TextAlign.left || TextAlign.start => CrossAxisAlignment.start,
        TextAlign.right || TextAlign.end => CrossAxisAlignment.end,
        _ => CrossAxisAlignment.center,
      };

  Widget _buildDivider(_Palette p) => switch (_dividerStyle) {
        _DividerStyle.none => const SizedBox(height: 10),
        _DividerStyle.ornament => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(p.accent, BlendMode.srcIn),
              child: const BrandElementArt(BrandElement.ayahDivider, width: 130, height: 22),
            ),
          ),
        _DividerStyle.diamondRule => Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 48, height: 1.3, color: p.accent.withValues(alpha: .75)),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(width: 7, height: 7, color: p.accent),
                ),
                const SizedBox(width: 8),
                Container(width: 48, height: 1.3, color: p.accent.withValues(alpha: .75)),
              ],
            ),
          ),
        _DividerStyle.rubElHizb => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _MiniRubElHizbPainter(p.accent)),
            ),
          ),
      };

  Widget _watermarkWidget(_Palette p) => Text(
        _previewWatermark(),
        textAlign: _textAlign,
        style: TextStyle(
          color: p.accent,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          fontSize: 11.5,
        ),
      );

  Widget _cardBody(_Palette p, double width, AppLanguage appLang) {
    final arabic = _previewArabic();
    final latin = _previewLatin();
    final translation = _previewTranslation(appLang);
    final source = _previewSource(appLang);
    final badge = _previewBadge(appLang);
    final hasArabic = _showArabic && arabic.isNotEmpty;
    final hasLatin = _showLatin && latin.isNotEmpty;
    final hasTranslation = _showTranslation && translation.isNotEmpty;
    final hasSource = _showSource && source.isNotEmpty;
    final hasBadge = _showBadge && badge.isNotEmpty;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _crossAlign,
        children: [
          if (_showWatermark && _watermarkPosition == _WatermarkPosition.top) ...[
            _watermarkWidget(p),
            const SizedBox(height: 12),
          ],
          if (hasBadge) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.accent.withValues(alpha: .45)),
              ),
              child: Text(
                badge,
                style: TextStyle(color: p.accent, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (hasArabic)
            Text(
              arabic,
              textAlign: _textAlign,
              textDirection: TextDirection.rtl,
              style: quranTextStyle(fontSize: _arabicSize, color: p.fg).copyWith(height: _arabicLineHeight),
            ),
          if (hasArabic && (hasLatin || hasTranslation)) _buildDivider(p),
          if (hasLatin) ...[
            Text(
              latin,
              textAlign: _textAlign,
              style: TextStyle(
                color: p.fg.withValues(alpha: .86),
                fontSize: (_translationSize - 1.5).clamp(11.0, 22.0),
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
            if (hasTranslation) const SizedBox(height: 10),
          ],
          if (hasTranslation)
            Text(
              _showQuotes ? '"$translation"' : translation,
              textAlign: _textAlign,
              style: TextStyle(
                color: p.fg,
                fontSize: _translationSize,
                fontStyle: _italicTranslation ? FontStyle.italic : FontStyle.normal,
                height: 1.52,
              ),
            ),
          if (hasSource) ...[
            const SizedBox(height: 12),
            Text(
              source,
              textAlign: _textAlign,
              style: TextStyle(color: p.accent, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
          if (_showWatermark && _watermarkPosition == _WatermarkPosition.bottom) ...[
            const SizedBox(height: 14),
            _watermarkWidget(p),
          ],
        ],
      ),
    );
  }

  Gradient? _gradientFor(_Palette p) => switch (_gradientStyle) {
        _GradientStyle.diagonal => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.bg, p.bg2],
          ),
        _GradientStyle.vertical => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.bg, p.bg2],
          ),
        _GradientStyle.radial => RadialGradient(
            center: Alignment.topCenter,
            radius: 1.25,
            colors: [p.bg2, p.bg],
          ),
        _GradientStyle.solid => null,
      };

  Widget _card(_Palette p, AppLanguage appLang) {
    final radius = BorderRadius.circular(_borderRadius);
    final isDarkCard = contrastRatio(Colors.white, p.bg) >= contrastRatio(BrandColors.deep, p.bg);
    final decoration = BoxDecoration(
      color: _gradientStyle == _GradientStyle.solid ? p.bg : null,
      gradient: _gradientFor(p),
      borderRadius: radius,
      border: _frameStyle == _FrameStyle.single ? Border.all(color: p.accent, width: 2) : null,
    );

    final innerPadding = EdgeInsets.all(_cardPadding);
    final content = _ratio.ratio == null
        ? Padding(
            padding: innerPadding,
            child: LayoutBuilder(builder: (_, c) => _cardBody(p, c.maxWidth, appLang)),
          )
        : AspectRatio(
            aspectRatio: _ratio.ratio!,
            child: LayoutBuilder(
              builder: (_, c) => Padding(
                padding: innerPadding,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _cardBody(p, math.max(120, c.maxWidth - _cardPadding * 2), appLang),
                  ),
                ),
              ),
            ),
          );

    return RepaintBoundary(
      key: _cardKey,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          key: const Key('share-card-preview'),
          decoration: decoration,
          child: Stack(
            children: [
              if (_patternStyle == _PatternStyle.brandOrnament)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (_patternOpacity * 2.5).clamp(0.08, 0.85),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: (isDarkCard ? BrandBackground.bannerGelap : BrandBackground.alquranKrem).decoration(),
                        ),
                      ),
                    ),
                  ),
                )
              else if (_patternStyle != _PatternStyle.none)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CardPatternPainter(
                        style: _patternStyle,
                        color: p.accent.withValues(alpha: _patternOpacity),
                      ),
                    ),
                  ),
                ),
              content,
              if (_frameStyle != _FrameStyle.none && _frameStyle != _FrameStyle.single)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CardFramePainter(
                        style: _frameStyle,
                        color: p.accent,
                        radius: _borderRadius,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentTab(BuildContext context, AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.tr('Templat Pilihan Cepat', 'Quick Curated Templates')),
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
                    label: Text('${tpl.categoryFor(lang)}: ${tpl.sourceFor(lang)}'),
                    onPressed: () => _applyPicked(_PickedTemplate(tpl)),
                  ),
                ),
            ],
          ),
        ),
        SectionHeader(context.tr('Bahasa Kutipan pada Kartu', 'Card Quote Language')),
        SegmentedButton<_CardLanguageMode>(
          key: const Key('share-lang-mode'),
          showSelectedIcon: false,
          segments: [
            for (final m in _CardLanguageMode.values)
              ButtonSegment(value: m, label: Text(context.tr(m.label, m.labelEn))),
          ],
          selected: {_cardLangMode},
          onSelectionChanged: (v) {
            setState(() => _cardLangMode = v.first);
            if (_picked != null) _syncPickedContent(context.lang);
          },
        ),
        SectionHeader(context.tr('Elemen yang Ditampilkan', 'Visible Elements')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              key: const Key('share-toggle-arabic'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              label: Text(context.tr('Teks Arab', 'Arabic')),
              selected: _showArabic,
              onSelected: (v) => setState(() => _showArabic = v),
            ),
            FilterChip(
              key: const Key('share-toggle-latin'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              label: Text(context.tr('Bacaan Latin', 'Transliteration')),
              selected: _showLatin,
              onSelected: (v) => setState(() => _showLatin = v),
            ),
            FilterChip(
              key: const Key('share-toggle-translation'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              label: Text(context.tr('Terjemahan', 'Translation')),
              selected: _showTranslation,
              onSelected: (v) => setState(() => _showTranslation = v),
            ),
            FilterChip(
              key: const Key('share-toggle-source'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              label: Text(context.tr('Sumber', 'Source')),
              selected: _showSource,
              onSelected: (v) => setState(() => _showSource = v),
            ),
            FilterChip(
              key: const Key('share-toggle-badge'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              label: Text(context.tr('Label Kategori', 'Category Label')),
              selected: _showBadge,
              onSelected: (v) => setState(() => _showBadge = v),
            ),
            FilterChip(
              key: const Key('share-toggle-watermark'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              label: Text(context.tr('Watermark', 'Watermark')),
              selected: _showWatermark,
              onSelected: (v) => setState(() => _showWatermark = v),
            ),
          ],
        ),
        SectionHeader(context.tr('Kustomisasi Teks Kartu', 'Customize Card Text')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  key: const Key('share-arabic-field'),
                  controller: _arabicCtrl,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: context.tr('Teks Arab', 'Arabic Text'),
                    hintText: defaultShareCardTemplates.first.arabic,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (_) => setState(() => _userEdited = true),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('share-latin-field'),
                  controller: _latinCtrl,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: context.tr('Bacaan Latin / Transliterasi (opsional)', 'Transliteration (optional)'),
                    hintText: context.tr(
                      'Contoh: ${defaultShareCardTemplates.first.latin ?? ''}',
                      'Example: ${defaultShareCardTemplates.first.latin ?? ''}',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (v) => setState(() {
                    _userEdited = true;
                    if (v.trim().isNotEmpty && !_showLatin) _showLatin = true;
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('share-translation-field'),
                  controller: _translationCtrl,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr('Terjemahan / Kutipan', 'Translation / Quote'),
                    hintText: context.tr(
                      'Contoh: ${defaultShareCardTemplates.first.translation}',
                      'Example: ${defaultShareCardTemplates.first.translationFor(AppLanguage.en)}',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (_) => setState(() => _userEdited = true),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('share-source-field'),
                  controller: _sourceCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('Sumber (Surah / Hadits / Doa)', 'Source (Surah / Hadith / Dua)'),
                    hintText: context.tr(
                      'Contoh: ${defaultShareCardTemplates.first.source}',
                      'Example: ${defaultShareCardTemplates.first.sourceFor(AppLanguage.en)}',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (_) => setState(() => _userEdited = true),
                ),
                if (_showBadge) ...[
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('share-badge-field'),
                    controller: _badgeCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr('Label Kategori', 'Category Label'),
                      hintText: context.tr('Contoh: Al-Qur\'an', 'Example: Al-Quran'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (_) => setState(() => _userEdited = true),
                  ),
                ],
                if (_showWatermark) ...[
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('share-watermark-field'),
                    controller: _watermarkCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr('Teks Watermark', 'Watermark Text'),
                      hintText: context.tr('Contoh: MOESLIM PM atau @namamasjid', 'Example: MOESLIM PM or @handle'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeTab(BuildContext context, AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.tr('Ukuran & Rasio Kartu', 'Card Size & Ratio')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in _CardRatio.values)
              ChoiceChip(
                key: Key('share-ratio-${r.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(context.tr(r.label, r.labelEn)),
                selected: _ratio == r,
                onSelected: (_) => setState(() => _ratio = r),
              ),
          ],
        ),
        SectionHeader(context.tr('Pilih Tema Kartu (12 Palet)', 'Choose Card Theme (12 Palettes)')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final st in ShareCardThemeStyle.values)
              ChoiceChip(
                key: Key('share-theme-${st.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                avatar: CircleAvatar(backgroundColor: _paletteOf(st).bg2, radius: 8),
                label: Text(st.labelFor(lang)),
                selected: _themeStyle == st && _customBg == null && _customAccent == null,
                onSelected: (_) => setState(() {
                  _themeStyle = st;
                  _customBg = null;
                  _customAccent = null;
                }),
              ),
          ],
        ),
        SectionHeader(context.tr('Gaya Gradien Latar', 'Background Gradient Style')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in _GradientStyle.values)
              ChoiceChip(
                key: Key('share-grad-${g.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(context.tr(g.label, g.labelEn)),
                selected: _gradientStyle == g,
                onSelected: (_) => setState(() => _gradientStyle = g),
              ),
          ],
        ),
        SectionHeader(context.tr('Warna Latar Kustom', 'Custom Background Color')),
        _ColorSwatchRow(
          selected: _customBg,
          colors: _customBgSwatches,
          resetLabel: context.tr('Ikuti Tema', 'Theme Default'),
          onSelected: (c) => setState(() => _customBg = c),
        ),
        SectionHeader(context.tr('Warna Aksen & Bingkai Kustom', 'Custom Accent & Frame Color')),
        _ColorSwatchRow(
          selected: _customAccent,
          colors: _customAccentSwatches,
          resetLabel: context.tr('Ikuti Tema', 'Theme Default'),
          onSelected: (c) => setState(() => _customAccent = c),
        ),
      ],
    );
  }

  Widget _buildOrnamentTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.tr('Pola Latar Islami', 'Islamic Background Pattern')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pat in _PatternStyle.values)
              ChoiceChip(
                key: Key('share-pattern-${pat.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(context.tr(pat.label, pat.labelEn)),
                selected: _patternStyle == pat,
                onSelected: (_) => setState(() => _patternStyle = pat),
              ),
          ],
        ),
        if (_patternStyle != _PatternStyle.none)
          Card(
            child: ListTile(
              title: Text(context.tr('Kepekatan Pola (${(_patternOpacity * 100).round()}%)', 'Pattern Opacity (${(_patternOpacity * 100).round()}%)')),
              subtitle: Slider(
                min: 0.03,
                max: 0.35,
                divisions: 16,
                value: _patternOpacity,
                onChanged: (v) => setState(() => _patternOpacity = v),
              ),
            ),
          ),
        SectionHeader(context.tr('Gaya Bingkai Kartu', 'Card Frame Style')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final fr in _FrameStyle.values)
              ChoiceChip(
                key: Key('share-frame-${fr.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(context.tr(fr.label, fr.labelEn)),
                selected: _frameStyle == fr,
                onSelected: (_) => setState(() => _frameStyle = fr),
              ),
          ],
        ),
        SectionHeader(context.tr('Pemisah Arab & Terjemahan', 'Arabic & Translation Divider')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final div in _DividerStyle.values)
              ChoiceChip(
                key: Key('share-divider-${div.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(context.tr(div.label, div.labelEn)),
                selected: _dividerStyle == div,
                onSelected: (_) => setState(() => _dividerStyle = div),
              ),
          ],
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(context.tr('Kelengkungan Sudut (${_borderRadius.round()} px)', 'Corner Radius (${_borderRadius.round()} px)')),
                subtitle: Slider(
                  min: 0,
                  max: 32,
                  divisions: 16,
                  value: _borderRadius,
                  onChanged: (v) => setState(() => _borderRadius = v),
                ),
              ),
              ListTile(
                title: Text(context.tr('Ruang Dalam Kartu (${_cardPadding.round()} px)', 'Inner Padding (${_cardPadding.round()} px)')),
                subtitle: Slider(
                  min: 16,
                  max: 40,
                  divisions: 12,
                  value: _cardPadding,
                  onChanged: (v) => setState(() => _cardPadding = v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypographyTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(context.tr('Ukuran Teks Arab (${_arabicSize.round()} pt)', 'Arabic Font Size (${_arabicSize.round()} pt)')),
                subtitle: Slider(
                  key: const Key('share-arabic-size-slider'),
                  min: 18,
                  max: 42,
                  divisions: 24,
                  value: _arabicSize,
                  onChanged: (v) => setState(() => _arabicSize = v),
                ),
              ),
              ListTile(
                title: Text(
                  context.tr(
                    'Jarak Baris Arab (${_arabicLineHeight.toStringAsFixed(2)}x)',
                    'Arabic Line Height (${_arabicLineHeight.toStringAsFixed(2)}x)',
                  ),
                ),
                subtitle: Slider(
                  min: 1.5,
                  max: 2.4,
                  divisions: 18,
                  value: _arabicLineHeight,
                  onChanged: (v) => setState(() => _arabicLineHeight = v),
                ),
              ),
              ListTile(
                title: Text(context.tr('Ukuran Terjemahan (${_translationSize.round()} pt)', 'Translation Size (${_translationSize.round()} pt)')),
                subtitle: Slider(
                  key: const Key('share-translation-size-slider'),
                  min: 11,
                  max: 24,
                  divisions: 13,
                  value: _translationSize,
                  onChanged: (v) => setState(() => _translationSize = v),
                ),
              ),
            ],
          ),
        ),
        SectionHeader(context.tr('Perataan & Posisi', 'Alignment & Layout')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.tr('Perataan Teks', 'Text Alignment'), style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<TextAlign>(
                  key: const Key('share-align-selector'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: TextAlign.left, label: Text(context.tr('Kiri', 'Left'))),
                    ButtonSegment(value: TextAlign.center, label: Text(context.tr('Tengah', 'Center'))),
                    ButtonSegment(value: TextAlign.right, label: Text(context.tr('Kanan', 'Right'))),
                  ],
                  selected: {_textAlign},
                  onSelectionChanged: (v) => setState(() => _textAlign = v.first),
                ),
                const SizedBox(height: 14),
                Text(context.tr('Posisi Watermark', 'Watermark Position'), style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<_WatermarkPosition>(
                  showSelectedIcon: false,
                  segments: [
                    for (final wp in _WatermarkPosition.values)
                      ButtonSegment(value: wp, label: Text(context.tr(wp.label, wp.labelEn))),
                  ],
                  selected: {_watermarkPosition},
                  onSelectionChanged: (v) => setState(() => _watermarkPosition = v.first),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Tanda kutip pada terjemahan ("...")', 'Quotation marks on translation ("...")')),
                  value: _showQuotes,
                  onChanged: (v) => setState(() => _showQuotes = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Terjemahan cetak miring (Italic)', 'Italic translation style')),
                  value: _italicTranslation,
                  onChanged: (v) => setState(() => _italicTranslation = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final palette = _activePalette();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Studio Kartu Ayat & Hadits', 'Verse & Hadith Card Studio')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('share-reset-style-btn'),
            tooltip: context.tr('Reset gaya kartu', 'Reset card style'),
            onPressed: _resetStyling,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SectionHeader(context.tr('Pratinjau Kartu Dakwah', 'Quote Card Preview')),
          _card(palette, lang),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('share-image-btn'),
            onPressed: _busy ? null : _shareImage,
            icon: const Icon(MoeslimIcons.bagikan),
            label: Text(
              context.tr(
                'Bagikan Gambar (WhatsApp, Instagram, dll.)',
                'Share Image (WhatsApp, Instagram, etc.)',
              ),
            ),
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
                label: Text(context.tr('Simpan Galeri', 'Save Gallery')),
              ),
              OutlinedButton.icon(
                key: const Key('share-text-btn'),
                onPressed: _busy ? null : _shareText,
                icon: const Icon(Icons.text_snippet_outlined),
                label: Text(context.tr('Bagikan Teks', 'Share Text')),
              ),
              OutlinedButton.icon(
                key: const Key('copy-share-card-btn'),
                onPressed: _copyFormattedCard,
                icon: const Icon(Icons.copy_outlined),
                label: Text(context.tr('Salin Teks', 'Copy Text')),
              ),
            ],
          ),
          SectionHeader(context.tr('Ambil dari Pustaka Lengkap', 'Pick from Full Library')),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                key: const Key('share-pick-quran'),
                onPressed: _openQuranPicker,
                icon: Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
                label: Text(context.tr('Al-Qur\'an (114 Surah)', 'Qur\'an (114 Surahs)')),
              ),
              FilledButton.tonalIcon(
                key: const Key('share-pick-hadith'),
                onPressed: _openHadithPicker,
                icon: Icon(MoeslimIcons.buku, color: scheme.primary),
                label: Text(context.tr('Hadits (${hadithCatalog.length})', 'Hadith (${hadithCatalog.length})')),
              ),
              FilledButton.tonalIcon(
                key: const Key('share-pick-dua'),
                onPressed: _openDuaPicker,
                icon: Icon(MoeslimIcons.zikr, color: scheme.primary),
                label: Text(context.tr('Doa Harian (229)', 'Daily Duas (229)')),
              ),
              OutlinedButton.icon(
                key: const Key('share-random-btn'),
                onPressed: _pickRandomSource,
                icon: const Icon(MoeslimIcons.acak, size: 18),
                label: Text(context.tr('Acak', 'Shuffle')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PillTabs(
            key: const Key('share-studio-tabs'),
            labels: [
              context.tr('Konten', 'Content'),
              context.tr('Tema', 'Theme'),
              context.tr('Ornamen', 'Ornaments'),
              context.tr('Tipografi', 'Typography'),
            ],
            index: _studioTab,
            onChanged: (i) => setState(() => _studioTab = i),
          ),
          const SizedBox(height: 8),
          switch (_studioTab) {
            0 => _buildContentTab(context, lang),
            1 => _buildThemeTab(context, lang),
            2 => _buildOrnamentTab(context),
            _ => _buildTypographyTab(context),
          },
        ],
      ),
    );
  }
}

class _ColorSwatchRow extends StatelessWidget {
  final Color? selected;
  final List<Color> colors;
  final String resetLabel;
  final ValueChanged<Color?> onSelected;

  const _ColorSwatchRow({
    required this.selected,
    required this.colors,
    required this.resetLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
          materialTapTargetSize: MaterialTapTargetSize.padded,
          label: Text(resetLabel),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final c in colors)
          InkWell(
            onTap: () => onSelected(c),
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected == c ? scheme.primary : scheme.outlineVariant,
                      width: selected == c ? 3 : 1.5,
                    ),
                  ),
                  child: selected == c
                      ? Icon(Icons.check, size: 18, color: _contrastFgFor(c))
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Picker penuh untuk memilih surah apa saja (1-114) dan satu ayat atau rentang ayat (6.236 ayat).
class _QuranPickerSheet extends ConsumerStatefulWidget {
  const _QuranPickerSheet();

  @override
  ConsumerState<_QuranPickerSheet> createState() => _QuranPickerSheetState();
}

class _QuranPickerSheetState extends ConsumerState<_QuranPickerSheet> {
  final _surahSearchCtrl = TextEditingController();
  final _ayahSearchCtrl = TextEditingController();
  Surah? _selectedSurah;
  int _startAyah = 1;
  int _endAyah = 1;
  String _surahQuery = '';
  String _ayahQuery = '';

  static const _quickRefs = <(String, String, int, int, int)>[
    ('Ayat Kursi', 'Ayat al-Kursi', 2, 255, 255),
    ('Al-Insyirah 5-6', 'Ash-Sharh 5-6', 94, 5, 6),
    ('Ar-Ra\'d 28', 'Ar-Ra\'d 28', 13, 28, 28),
    ('Al-Baqarah 286', 'Al-Baqarah 286', 2, 286, 286),
    ('At-Talaq 2-3', 'At-Talaq 2-3', 65, 2, 3),
    ('Al-Ikhlas 1-4', 'Al-Ikhlas 1-4', 112, 1, 4),
    ('Al-Fatihah 1-7', 'Al-Fatihah 1-7', 1, 1, 7),
  ];

  @override
  void dispose() {
    _surahSearchCtrl.dispose();
    _ayahSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectQuickRef(int surahNum, int start, int end) async {
    final surah = surahs[surahNum - 1];
    final ayat = await ref.read(quranSourceProvider).load(surahNum);
    if (!mounted) return;
    if (ayat == null || ayat.isEmpty) {
      setState(() {
        _selectedSurah = surah;
        _startAyah = start.clamp(1, surah.ayahCount);
        _endAyah = end.clamp(_startAyah, surah.ayahCount);
      });
      return;
    }
    final s = start.clamp(1, ayat.length);
    final e = end.clamp(s, ayat.length);
    Navigator.of(context).pop(_PickedQuran(surah, ayat.sublist(s - 1, e)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollCtrl) {
        if (_selectedSurah == null) {
          final q = _surahQuery.trim().toLowerCase();
          final filteredSurahs = [
            for (final s in surahs)
              if (q.isEmpty ||
                  '${s.number}' == q ||
                  s.name.toLowerCase().contains(q) ||
                  s.arabicName.contains(_surahQuery.trim()))
                s,
          ];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Pilih Surah & Ayat Al-Qur\'an', 'Choose Qur\'an Surah & Verse'),
                      style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (idLabel, enLabel, sNum, aStart, aEnd) in _quickRefs)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                label: Text(context.tr(idLabel, enLabel)),
                                onPressed: () => _selectQuickRef(sNum, aStart, aEnd),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('share-quran-surah-search'),
                      controller: _surahSearchCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(MoeslimIcons.pencarian),
                        hintText: context.tr('Cari 114 surah (nama / nomor)...', 'Search 114 surahs (name / number)...'),
                        suffixIcon: _surahQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _surahSearchCtrl.clear();
                                  setState(() => _surahQuery = '');
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _surahQuery = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredSurahs.isEmpty
                    ? Center(child: Text(context.tr('Surah tidak ditemukan.', 'No surah found.')))
                    : ListView.separated(
                        controller: scrollCtrl,
                        itemCount: filteredSurahs.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = filteredSurahs[i];
                          return ListTile(
                            key: Key('share-surah-item-${s.number}'),
                            leading: OctagonNumber(s.number, size: 34),
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              context.tr(
                                '${s.revelation} · ${s.ayahCount} Ayat',
                                '${s.revelationFor(lang)} · ${s.ayahCount} Verses',
                              ),
                            ),
                            trailing: Text(s.arabicName, style: quranTextStyle(fontSize: 20)),
                            onTap: () => setState(() {
                              _selectedSurah = s;
                              _startAyah = 1;
                              _endAyah = 1;
                              _ayahQuery = '';
                              _ayahSearchCtrl.clear();
                            }),
                          );
                        },
                      ),
              ),
            ],
          );
        }

        final surah = _selectedSurah!;
        final textAsync = ref.watch(surahTextProvider(surah.number));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.tr('Kembali ke daftar surah', 'Back to surah list'),
                    onPressed: () => setState(() => _selectedSurah = null),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${surah.number}. ${surah.name}',
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          context.tr(
                            'Pilih 1 ayat atau rentang hingga 10 ayat (${surah.ayahCount} ayat)',
                            'Pick 1 verse or a range up to 10 verses (${surah.ayahCount} verses)',
                          ),
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(surah.arabicName, style: quranTextStyle(fontSize: 22, color: scheme.primary)),
                ],
              ),
            ),
            Expanded(
              child: textAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (ayat) {
                  if (ayat == null || ayat.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr(
                            'Teks Al-Qur\'an belum tersedia pada sumber ini.',
                            'Qur\'an text is not available in this source.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final maxAyah = ayat.length;
                  final safeStart = _startAyah.clamp(1, maxAyah);
                  final maxAllowedEnd = math.min(maxAyah, safeStart + 9);
                  final safeEnd = _endAyah.clamp(safeStart, maxAllowedEnd);
                  final q = _ayahQuery.trim().toLowerCase();
                  final visibleAyat = [
                    for (final a in ayat)
                      if (q.isEmpty ||
                          '${a.number}' == q ||
                          (a.translation?.toLowerCase().contains(q) ?? false) ||
                          (a.translationEn?.toLowerCase().contains(q) ?? false) ||
                          a.text.contains(_ayahQuery.trim()))
                        a,
                  ];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    key: const Key('share-ayah-start-dropdown'),
                                    initialValue: safeStart,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: context.tr('Dari Ayat', 'From Verse'),
                                    ),
                                    items: [
                                      for (var n = 1; n <= maxAyah; n++)
                                        DropdownMenuItem(value: n, child: Text('${context.tr('Ayat', 'Verse')} $n')),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        _startAyah = v;
                                        if (_endAyah < v) _endAyah = v;
                                        if (_endAyah > v + 9) _endAyah = math.min(maxAyah, v + 9);
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    key: const Key('share-ayah-end-dropdown'),
                                    initialValue: safeEnd,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: context.tr('Sampai Ayat', 'To Verse'),
                                    ),
                                    items: [
                                      for (var n = safeStart; n <= maxAllowedEnd; n++)
                                        DropdownMenuItem(value: n, child: Text('${context.tr('Ayat', 'Verse')} $n')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setState(() => _endAyah = v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  key: const Key('share-apply-quran-range'),
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                      _PickedQuran(surah, ayat.sublist(safeStart - 1, safeEnd)),
                                    );
                                  },
                                  child: Text(context.tr('Pakai', 'Apply')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              key: const Key('share-quran-ayah-search'),
                              controller: _ayahSearchCtrl,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: const Icon(MoeslimIcons.pencarian),
                                hintText: context.tr('Cari nomor atau kata dalam terjemahan ayat...', 'Search verse number or translation keyword...'),
                              ),
                              onChanged: (v) => setState(() => _ayahQuery = v),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollCtrl,
                          itemCount: visibleAyat.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, idx) {
                            final a = visibleAyat[idx];
                            final inRange = a.number >= safeStart && a.number <= safeEnd;
                            return ListTile(
                              key: Key('share-ayah-item-${a.number}'),
                              selected: inRange,
                              leading: OctagonNumber(a.number, size: 32),
                              title: Text(
                                a.text,
                                textDirection: TextDirection.rtl,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: quranTextStyle(fontSize: 19),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  a.translationFor(lang) ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () => Navigator.of(context).pop(_PickedQuran(surah, [a])),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Picker penuh untuk seluruh 50 Hadits Shahih di katalog offline.
class _HadithPickerSheet extends StatefulWidget {
  const _HadithPickerSheet();

  @override
  State<_HadithPickerSheet> createState() => _HadithPickerSheetState();
}

class _HadithPickerSheetState extends State<_HadithPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _collection;
  String? _topic;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final collections = {for (final h in hadithCatalog) h.collection: h.collectionFor(lang)};
    final topics = {for (final h in hadithCatalog) h.topic: h.topicFor(lang)};
    final filtered = [
      for (final h in hadithCatalog)
        if ((_collection == null || h.collection == _collection) &&
            (_topic == null || h.topic == _topic) &&
            h.matches(_query))
          h,
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Pilih Hadits Shahih (${hadithCatalog.length})', 'Choose Authentic Hadith (${hadithCatalog.length})'),
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('share-hadith-search'),
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(MoeslimIcons.pencarian),
                    hintText: context.tr('Cari hadits (niat, sabar, syukur, ibu, sedekah)...', 'Search hadith (intention, patience, gratitude, mother, charity)...'),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(context.tr('Semua Kitab', 'All Books')),
                          selected: _collection == null,
                          onSelected: (_) => setState(() => _collection = null),
                        ),
                      ),
                      for (final e in collections.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(e.value),
                            selected: _collection == e.key,
                            onSelected: (_) => setState(() => _collection = _collection == e.key ? null : e.key),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(context.tr('Semua Tema', 'All Topics')),
                          selected: _topic == null,
                          onSelected: (_) => setState(() => _topic = null),
                        ),
                      ),
                      for (final e in topics.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(e.value),
                            selected: _topic == e.key,
                            onSelected: (_) => setState(() => _topic = _topic == e.key ? null : e.key),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(context.tr('Hadits tidak ditemukan.', 'No hadiths found.')))
                : ListView.separated(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final h = filtered[i];
                      return ListTile(
                        key: Key('share-hadith-item-${h.id}'),
                        leading: OctagonNumber(h.id, size: 34),
                        title: Text(h.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${h.collectionFor(lang)} · ${h.topicFor(lang)}\n${h.translationFor(lang)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.of(context).pop(h),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Picker penuh untuk seluruh 229 Doa Harian & Aktivitas.
class _DuaPickerSheet extends ConsumerStatefulWidget {
  const _DuaPickerSheet();

  @override
  ConsumerState<_DuaPickerSheet> createState() => _DuaPickerSheetState();
}

class _DuaPickerSheetState extends ConsumerState<_DuaPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _selectedGroup;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final duasAsync = ref.watch(dailyDuasProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => duasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          final groups = <String, String>{for (final d in list) d.group: d.groupFor(lang)};
          final q = _query.trim().toLowerCase();
          final filtered = [
            for (final d in list)
              if ((_selectedGroup == null || d.group == _selectedGroup) &&
                  (q.isEmpty ||
                      d.title.toLowerCase().contains(q) ||
                      (d.titleEn?.toLowerCase().contains(q) ?? false) ||
                      d.translation.toLowerCase().contains(q) ||
                      (d.translationEn?.toLowerCase().contains(q) ?? false) ||
                      d.group.toLowerCase().contains(q) ||
                      (d.groupEn?.toLowerCase().contains(q) ?? false)))
                d,
          ];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Pilih Doa Harian (${list.length})', 'Choose Daily Dua (${list.length})'),
                      style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('share-dua-search'),
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(MoeslimIcons.pencarian),
                        hintText: context.tr('Cari doa (tidur, makan, masjid, perjalanan, ilmu)...', 'Search dua (sleep, meal, mosque, travel, knowledge)...'),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(context.tr('Semua Kategori', 'All Categories')),
                              selected: _selectedGroup == null,
                              onSelected: (_) => setState(() => _selectedGroup = null),
                            ),
                          ),
                          for (final e in groups.entries)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(e.value),
                                selected: _selectedGroup == e.key,
                                onSelected: (_) => setState(() => _selectedGroup = _selectedGroup == e.key ? null : e.key),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(context.tr('Doa tidak ditemukan.', 'No duas found.')))
                    : ListView.separated(
                        controller: scrollCtrl,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final d = filtered[i];
                          return ListTile(
                            key: Key('share-dua-item-${d.id}'),
                            leading: OctagonNumber(i + 1, size: 32),
                            title: Text(d.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${d.groupFor(lang)}\n${d.translationFor(lang)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            onTap: () => Navigator.of(context).pop(d),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  final _PatternStyle style;
  final Color color;

  const _CardPatternPainter({required this.style, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    switch (style) {
      case _PatternStyle.eightPointStar:
        const cell = 42.0;
        for (var y = -cell; y < size.height + cell; y += cell) {
          for (var x = -cell; x < size.width + cell; x += cell) {
            final c = Offset(x + cell / 2, y + cell / 2);
            final r = cell * 0.40;
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
      case _PatternStyle.mushafLattice:
        const step = 28.0;
        for (var d = -size.height; d < size.width + size.height; d += step) {
          canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), p);
          canvas.drawLine(Offset(d + size.height, 0), Offset(d, size.height), p);
        }
      case _PatternStyle.mihrabArch:
        final archPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        final w = size.width;
        final h = size.height;
        final inset = 14.0;
        final topY = inset + 18;
        final archPath = Path()
          ..moveTo(inset, h - inset)
          ..lineTo(inset, h * 0.34)
          ..quadraticBezierTo(inset, topY + 24, w * 0.5, topY)
          ..quadraticBezierTo(w - inset, topY + 24, w - inset, h * 0.34)
          ..lineTo(w - inset, h - inset)
          ..close();
        canvas.drawPath(archPath, archPaint);
      case _PatternStyle.none:
      case _PatternStyle.brandOrnament:
        break;
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter old) => old.style != style || old.color != color;
}

class _CardFramePainter extends CustomPainter {
  final _FrameStyle style;
  final Color color;
  final double radius;

  const _CardFramePainter({required this.style, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    switch (style) {
      case _FrameStyle.doubleClassic:
        final outer = RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
          Radius.circular(math.max(0, radius - 2)),
        );
        final inner = RRect.fromRectAndRadius(
          Rect.fromLTWH(9, 9, size.width - 18, size.height - 18),
          Radius.circular(math.max(0, radius - 8)),
        );
        canvas.drawRRect(outer, stroke);
        canvas.drawRRect(
          inner,
          Paint()
            ..color = color.withValues(alpha: .72)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1,
        );
      case _FrameStyle.cornerBrackets:
        const m = 12.0;
        const len = 24.0;
        final bp = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        // Top-left
        canvas.drawLine(const Offset(m, m), const Offset(m + len, m), bp);
        canvas.drawLine(const Offset(m, m), const Offset(m, m + len), bp);
        // Top-right
        canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m - len, m), bp);
        canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m, m + len), bp);
        // Bottom-left
        canvas.drawLine(Offset(m, size.height - m), Offset(m + len, size.height - m), bp);
        canvas.drawLine(Offset(m, size.height - m), Offset(m, size.height - m - len), bp);
        // Bottom-right
        canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m - len, size.height - m), bp);
        canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m, size.height - m - len), bp);
      case _FrameStyle.archVault:
        const m = 10.0;
        final path = Path()
          ..moveTo(m, size.height - m)
          ..lineTo(m, size.height * 0.28)
          ..quadraticBezierTo(m, m + 16, size.width * 0.5, m)
          ..quadraticBezierTo(size.width - m, m + 16, size.width - m, size.height * 0.28)
          ..lineTo(size.width - m, size.height - m)
          ..close();
        canvas.drawPath(path, stroke);
      case _FrameStyle.none:
      case _FrameStyle.single:
        break;
    }
  }

  @override
  bool shouldRepaint(_CardFramePainter old) =>
      old.style != style || old.color != color || old.radius != radius;
}

class _MiniRubElHizbPainter extends CustomPainter {
  final Color color;
  const _MiniRubElHizbPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 1.5;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final rot in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = rot + math.pi / 4 + i * math.pi / 2;
        final pt = c + Offset(math.cos(a), math.sin(a)) * r;
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_MiniRubElHizbPainter old) => old.color != color;
}
