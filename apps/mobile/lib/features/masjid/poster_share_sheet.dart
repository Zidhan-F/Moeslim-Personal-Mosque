import 'package:flutter/services.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import 'agenda_page.dart' show categoryLabel;
import 'finance_pro_pages.dart' show saveBoundaryPng;
import 'mosque_providers.dart';
import 'staff_page.dart' show dutyTypeLabel, prayerSlotLabel;

/// Data siap pakai untuk kartu Poster & teks WhatsApp.
class PosterData {
  final String overline;
  final String title;
  final String mosqueName;
  final String? subtitle;
  final List<(String, String)> rows;
  final String footer;
  final String whatsappText;
  final String filePrefix;

  const PosterData({
    required this.overline,
    required this.title,
    required this.mosqueName,
    this.subtitle,
    required this.rows,
    required this.footer,
    required this.whatsappText,
    this.filePrefix = 'poster-masjid',
  });
}

/// Pembangun teks WhatsApp resmi masjid (ringkas, sopan, bebas karakter tidak rapi).
abstract final class WaTextBuilder {
  static PosterData forEvent(
    String mosqueName,
    Map<String, dynamic> event, {
    AppLanguage lang = AppLanguage.id,
  }) {
    final isEn = lang == AppLanguage.en;
    final start = DateTime.parse(event['starts_at'] as String).toLocal();
    final title = '${event['title'] ?? (isEn ? 'Mosque Event' : 'Agenda Masjid')}';
    final cat = categoryLabel(event['category'] as String?, lang: lang);
    final speaker = event['speaker'] as String?;
    final location = event['location'] as String?;
    final desc = event['description'] as String?;
    final dateText = '${longDate(start, lang: lang)}, ${hhmm(start)}';

    final rows = <(String, String)>[
      (isEn ? 'Category' : 'Kategori', cat),
      (isEn ? 'Time' : 'Waktu', dateText),
      if (location != null && location.isNotEmpty) (isEn ? 'Location' : 'Lokasi', location),
      if (speaker != null && speaker.isNotEmpty) (isEn ? 'Speaker' : 'Pemateri', speaker),
    ];

    final wa = [
      'Assalamualaikum warahmatullahi wabarakatuh.',
      '',
      '*${title.toUpperCase()}*',
      '*$mosqueName*',
      '',
      for (final r in rows) '${r.$1}: ${r.$2}',
      if (desc != null && desc.isNotEmpty) ...['', desc],
      '',
      isEn
          ? 'Please join us with family and friends. Barakallahu fiikum.'
          : 'Mari hadir dan ajak keluarga serta sahabat. Barakallahu fiikum.',
    ].join('\n');

    return PosterData(
      overline: isEn ? 'MOSQUE EVENT' : 'AGENDA MASJID',
      title: title,
      mosqueName: mosqueName,
      subtitle: cat,
      rows: rows,
      footer: isEn
          ? 'Join us with family and congregation to enliven the mosque.'
          : 'Mari makmurkan masjid bersama keluarga dan jamaah.',
      whatsappText: wa,
      filePrefix: 'poster-agenda-${event['id'] ?? 'masjid'}',
    );
  }

  static PosterData forAnnouncement(
    String mosqueName,
    Map<String, dynamic> ann, {
    AppLanguage lang = AppLanguage.id,
  }) {
    final isEn = lang == AppLanguage.en;
    final title = '${ann['title'] ?? (isEn ? 'Mosque Announcement' : 'Pengumuman Masjid')}';
    final body = '${ann['body'] ?? ''}';

    final wa = [
      isEn ? '*MOSQUE ANNOUNCEMENT*' : '*PENGUMUMAN MASJID*',
      '*$mosqueName*',
      '',
      '*$title*',
      body,
      '',
      isEn ? 'Thank you for your attention. Jazakumullahu khairan.' : 'Demikian disampaikan, jazakumullahu khairan katsiran.',
    ].join('\n');

    return PosterData(
      overline: isEn ? 'MOSQUE ANNOUNCEMENT' : 'PENGUMUMAN MASJID',
      title: title,
      mosqueName: mosqueName,
      rows: [
        (isEn ? 'Details' : 'Informasi', body),
      ],
      footer: isEn ? 'Official announcement from $mosqueName Committee.' : 'Informasi resmi Takmir $mosqueName.',
      whatsappText: wa,
      filePrefix: 'poster-pengumuman-${ann['id'] ?? 'masjid'}',
    );
  }

  static PosterData forFridayStaff(
    String mosqueName,
    DateTime date,
    List<Map<String, dynamic>> staff, {
    AppLanguage lang = AppLanguage.id,
  }) {
    final isEn = lang == AppLanguage.en;
    final dateText = longDate(date, lang: lang);
    final rows = <(String, String)>[
      for (final s in staff)
        (
          '${dutyTypeLabel(s['duty_type'] as String?, lang: lang)}${s['prayer'] != null ? ' (${prayerSlotLabel(s['prayer'] as String?, lang: lang)})' : ''}',
          '${s['name']}',
        ),
    ];

    final wa = [
      isEn ? '*FRIDAY PRAYER ROSTER*' : '*PETUGAS SALAT JUMAT*',
      '*$mosqueName*',
      '${isEn ? 'Date' : 'Tanggal'}: $dateText',
      '',
      if (rows.isEmpty)
        (isEn ? 'Duty roster has not been assigned yet.' : 'Jadwal petugas belum ditentukan.')
      else
        for (final r in rows) '- ${r.$1}: *${r.$2}*',
      '',
      isEn
          ? 'Please arrive early and straighten the rows. Barakallahu fiikum.'
          : 'Mari bersegera menuju masjid dan luruskan shaf. Barakallahu fiikum.',
    ].join('\n');

    return PosterData(
      overline: isEn ? 'FRIDAY ROSTER' : 'PETUGAS JUMAT',
      title: dateText,
      mosqueName: mosqueName,
      rows: rows.isEmpty
          ? [(isEn ? 'Schedule' : 'Jadwal', isEn ? 'No roster assigned yet' : 'Belum ada petugas terjadwal')]
          : rows,
      footer: isEn
          ? 'Arrive early to gain the blessings of Friday.'
          : 'Mari hadir lebih awal untuk meraih keutamaan Jumat.',
      whatsappText: wa,
      filePrefix: 'poster-petugas-${isoDate(date)}',
    );
  }
}

enum _PosterTheme { emerald, cream, night }

/// Bottom sheet generator Poster PNG + Salin Teks WhatsApp (3 tema brand).
class PosterShareSheet extends StatefulWidget {
  final PosterData data;
  const PosterShareSheet({super.key, required this.data});

  @override
  State<PosterShareSheet> createState() => _PosterShareSheetState();
}

class _PosterShareSheetState extends State<PosterShareSheet> {
  final _posterKey = GlobalKey();
  _PosterTheme _theme = _PosterTheme.emerald;
  bool _saving = false;

  Future<void> _copyWa(BuildContext context) async {
    final lang = context.lang;
    await Clipboard.setData(ClipboardData(text: widget.data.whatsappText));
    if (context.mounted) {
      showSnack(
        context,
        lang == AppLanguage.en
            ? 'WhatsApp text copied. Ready to share with congregation groups.'
            : 'Teks WhatsApp disalin. Siap bagikan ke grup jamaah.',
      );
    }
  }

  Future<void> _savePng(BuildContext context) async {
    final lang = context.lang;
    setState(() => _saving = true);
    try {
      final path = await saveBoundaryPng(_posterKey, '${widget.data.filePrefix}.png', lang: lang);
      if (context.mounted) {
        showSnack(context, lang == AppLanguage.en ? 'Poster saved: $path' : 'Poster tersimpan: $path');
      }
    } catch (e) {
      if (context.mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final (bg, headerBg, accent, textColor, mutedColor) = switch (_theme) {
      _PosterTheme.emerald => (
        BrandColors.cream,
        BrandColors.dark,
        BrandColors.gold,
        BrandColors.deep,
        BrandColors.textMuted,
      ),
      _PosterTheme.cream => (
        Colors.white,
        BrandColors.emerald,
        BrandColors.gold,
        BrandColors.deep,
        BrandColors.textMuted,
      ),
      _PosterTheme.night => (
        const Color(0xFF0E1D19),
        const Color(0xFF073B2C),
        BrandColors.gold,
        const Color(0xFFF6F5F0),
        const Color(0xFFC4D1CC),
      ),
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Bagikan Poster & Teks WA', 'Share Poster & WhatsApp Text'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('theme-emerald'),
                  label: Text(context.tr('Hijau Moeslim', 'Moeslim Green')),
                  selected: _theme == _PosterTheme.emerald,
                  onSelected: (_) => setState(() => _theme = _PosterTheme.emerald),
                ),
                ChoiceChip(
                  key: const Key('theme-cream'),
                  label: Text(context.tr('Krem Elegan', 'Warm Cream')),
                  selected: _theme == _PosterTheme.cream,
                  onSelected: (_) => setState(() => _theme = _PosterTheme.cream),
                ),
                ChoiceChip(
                  key: const Key('theme-night'),
                  label: Text(context.tr('Malam', 'Night')),
                  selected: _theme == _PosterTheme.night,
                  onSelected: (_) => setState(() => _theme = _PosterTheme.night),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: _posterKey,
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: BrandColors.emerald.withValues(alpha: .28), width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      color: headerBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.overline,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.data.title,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.data.mosqueName,
                            style: const TextStyle(color: BrandColors.cream, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final r in widget.data.rows)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.$1,
                                    style: TextStyle(color: mutedColor, fontSize: 11.5, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r.$2,
                                    style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          Divider(color: mutedColor.withValues(alpha: .25), height: 1),
                          const SizedBox(height: 8),
                          Text(
                            widget.data.footer,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: mutedColor, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const Key('poster-copy-wa'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
              onPressed: _saving ? null : () => _copyWa(context),
              icon: const Icon(Icons.copy_rounded),
              label: Text(context.tr('Salin Teks WhatsApp', 'Copy WhatsApp Text')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('poster-save-png'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: _saving ? null : () => _savePng(context),
              icon: const Icon(Icons.image_outlined),
              label: Text(context.tr('Simpan Poster PNG', 'Save Poster PNG')),
            ),
          ],
        ),
      ),
    );
  });
}
