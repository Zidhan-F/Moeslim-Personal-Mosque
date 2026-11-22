import 'package:flutter/services.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import 'agenda_page.dart' show categoryLabel;
import 'finance_pro_pages.dart' show saveBoundaryPng;
import 'mosque_providers.dart';
import 'staff_page.dart' show dutyLabels, prayerLabels;

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
  static PosterData forEvent(String mosqueName, Map<String, dynamic> event) {
    final start = DateTime.parse(event['starts_at'] as String).toLocal();
    final title = '${event['title'] ?? 'Agenda Masjid'}';
    final cat = categoryLabel(event['category'] as String?);
    final speaker = event['speaker'] as String?;
    final location = event['location'] as String?;
    final desc = event['description'] as String?;
    final dateText = '${longDate(start)}, ${hhmm(start)}';

    final rows = <(String, String)>[
      ('Kategori', cat),
      ('Waktu', dateText),
      if (location != null && location.isNotEmpty) ('Lokasi', location),
      if (speaker != null && speaker.isNotEmpty) ('Pemateri', speaker),
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
      'Mari hadir dan ajak keluarga serta sahabat. Barakallahu fiikum.',
    ].join('\n');

    return PosterData(
      overline: 'AGENDA MASJID',
      title: title,
      mosqueName: mosqueName,
      subtitle: cat,
      rows: rows,
      footer: 'Mari makmurkan masjid bersama keluarga dan jamaah.',
      whatsappText: wa,
      filePrefix: 'poster-agenda-${event['id'] ?? 'masjid'}',
    );
  }

  static PosterData forAnnouncement(String mosqueName, Map<String, dynamic> ann) {
    final title = '${ann['title'] ?? 'Pengumuman Masjid'}';
    final body = '${ann['body'] ?? ''}';

    final wa = [
      '*PENGUMUMAN MASJID*',
      '*$mosqueName*',
      '',
      '*$title*',
      body,
      '',
      'Demikian disampaikan, jazakumullahu khairan katsiran.',
    ].join('\n');

    return PosterData(
      overline: 'PENGUMUMAN MASJID',
      title: title,
      mosqueName: mosqueName,
      rows: [
        ('Informasi', body),
      ],
      footer: 'Informasi resmi Takmir $mosqueName.',
      whatsappText: wa,
      filePrefix: 'poster-pengumuman-${ann['id'] ?? 'masjid'}',
    );
  }

  static PosterData forFridayStaff(String mosqueName, DateTime date, List<Map<String, dynamic>> staff) {
    final dateText = longDate(date);
    final rows = <(String, String)>[
      for (final s in staff)
        (
          '${dutyLabels[s['duty_type']] ?? s['duty_type']}${s['prayer'] != null ? ' (${prayerLabels[s['prayer']] ?? s['prayer']})' : ''}',
          '${s['name']}',
        ),
    ];

    final wa = [
      '*PETUGAS SALAT JUMAT*',
      '*$mosqueName*',
      'Tanggal: $dateText',
      '',
      if (rows.isEmpty)
        'Jadwal petugas belum ditentukan.'
      else
        for (final r in rows) '- ${r.$1}: *${r.$2}*',
      '',
      'Mari bersegera menuju masjid dan luruskan shaf. Barakallahu fiikum.',
    ].join('\n');

    return PosterData(
      overline: 'PETUGAS JUMAT',
      title: dateText,
      mosqueName: mosqueName,
      rows: rows.isEmpty ? const [('Jadwal', 'Belum ada petugas terjadwal')] : rows,
      footer: 'Mari hadir lebih awal untuk meraih keutamaan Jumat.',
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

  Future<void> _copyWa() async {
    await Clipboard.setData(ClipboardData(text: widget.data.whatsappText));
    if (mounted) showSnack(context, 'Teks WhatsApp disalin. Siap bagikan ke grup jamaah.');
  }

  Future<void> _savePng() async {
    setState(() => _saving = true);
    try {
      final path = await saveBoundaryPng(_posterKey, '${widget.data.filePrefix}.png');
      if (mounted) showSnack(context, 'Poster tersimpan: $path');
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Bagikan Poster & Teks WA', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('theme-emerald'),
                  label: const Text('Hijau Moeslim'),
                  selected: _theme == _PosterTheme.emerald,
                  onSelected: (_) => setState(() => _theme = _PosterTheme.emerald),
                ),
                ChoiceChip(
                  key: const Key('theme-cream'),
                  label: const Text('Krem Elegan'),
                  selected: _theme == _PosterTheme.cream,
                  onSelected: (_) => setState(() => _theme = _PosterTheme.cream),
                ),
                ChoiceChip(
                  key: const Key('theme-night'),
                  label: const Text('Malam'),
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
              onPressed: _saving ? null : _copyWa,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Salin Teks WhatsApp'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('poster-save-png'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: _saving ? null : _savePng,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Simpan Poster PNG'),
            ),
          ],
        ),
      ),
    );
  }
}
