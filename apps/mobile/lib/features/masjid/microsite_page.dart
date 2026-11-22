import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/l10n.dart';
import 'finance_pro_pages.dart' show saveBoundaryPng;
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

/// Halaman Microsite Profil Masjid Publik: tautan /m/{slug}, kartu QR spanduk, & sakelar transparansi kas.
class MosqueMicrositePage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const MosqueMicrositePage({super.key, required this.ctx});

  @override
  ConsumerState<MosqueMicrositePage> createState() => _MosqueMicrositePageState();
}

class _MosqueMicrositePageState extends ConsumerState<MosqueMicrositePage> {
  final _qrCardKey = GlobalKey();
  bool _saving = false;
  bool? _localPublicFinance;

  String _micrositeUrl(String baseUrl, String slug) {
    final trimmed = baseUrl.endsWith('/api') ? baseUrl.substring(0, baseUrl.length - 4) : baseUrl;
    return '$trimmed/m/$slug';
  }

  Future<void> _copy(BuildContext context, String text, String msg) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) showSnack(context, msg);
  }

  Future<void> _saveQr(BuildContext context, String slug) async {
    final lang = context.lang;
    setState(() => _saving = true);
    try {
      final path = await saveBoundaryPng(_qrCardKey, 'qr-profil-$slug.png', lang: lang);
      if (context.mounted) {
        showSnack(context, lang == AppLanguage.en ? 'QR card saved: $path' : 'Kartu QR tersimpan: $path');
      }
    } catch (e) {
      if (context.mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _togglePublicFinance(BuildContext context, bool value) async {
    final lang = context.lang;
    setState(() {
      _saving = true;
      _localPublicFinance = value;
    });
    try {
      await ref.read(masjidApiProvider).updateMosque(widget.ctx.id, {
        'settings': {'public_show_finance': value},
      });
      ref.invalidate(dashboardProvider(widget.ctx.id));
      if (context.mounted) {
        showSnack(
          context,
          value
              ? (lang == AppLanguage.en
                    ? 'Friday cash transparency is now displayed on the public profile page.'
                    : 'Transparansi kas Jumat kini ditampilkan di halaman profil publik.')
              : (lang == AppLanguage.en
                    ? 'Cash summary is now hidden from the public profile page.'
                    : 'Ringkasan kas disembunyikan dari halaman profil publik.'),
        );
      }
    } on ApiException catch (e) {
      setState(() => _localPublicFinance = !value);
      if (context.mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final api = ref.watch(masjidApiProvider);
    final dash = ref.watch(dashboardProvider(widget.ctx.id));
    final mosqueMap = dash.value?['mosque'] as Map?;
    final slug = (mosqueMap?['slug'] as String?) ?? widget.ctx.slug ?? widget.ctx.id.toLowerCase();
    final url = _micrositeUrl(api.baseUrl, slug);
    final serverPublicFinance = (mosqueMap?['settings'] as Map?)?['public_show_finance'] == true;
    final showFinance = _localPublicFinance ?? serverPublicFinance;
    final canUpdate = widget.ctx.can('mosque.update');

    final waInvite = context.isEn
        ? [
            'Assalamualaikum warahmatullahi wabarakatuh.',
            '',
            'Visit the official profile page of *${widget.ctx.name}* for lecture schedules, announcements, Friday roster, and mosque info:',
            url,
            '',
            'Barakallahu fiikum.',
          ].join('\n')
        : [
            'Assalamualaikum warahmatullahi wabarakatuh.',
            '',
            'Kunjungi halaman profil resmi *${widget.ctx.name}* untuk melihat jadwal kajian, pengumuman, petugas Jumat, dan informasi masjid:',
            url,
            '',
            'Barakallahu fiikum.',
          ].join('\n');

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Microsite Profil Masjid', 'Mosque Profile Microsite')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          RepaintBoundary(
            key: _qrCardKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: BrandColors.emerald.withValues(alpha: .28), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: BrandColors.dark,
                    child: Column(
                      children: [
                        Text(
                          context.tr('PROFIL RESMI MASJID', 'OFFICIAL MOSQUE PROFILE'),
                          style: const TextStyle(
                            color: BrandColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.ctx.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                        ),
                        if (widget.ctx.city != null)
                          Text(widget.ctx.city!, style: const TextStyle(color: BrandColors.cream, fontSize: 13)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: BrandColors.emerald.withValues(alpha: .2)),
                          ),
                          child: QrImageView(
                            key: const Key('microsite-qr'),
                            data: url,
                            size: 180,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr(
                            'Pindai QR untuk agenda, petugas Jumat, & informasi resmi masjid',
                            'Scan QR for events, Friday roster, & official mosque info',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: BrandColors.deep, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          url,
                          key: const Key('microsite-url'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: BrandColors.dark, fontSize: 12.5, fontWeight: FontWeight.w700),
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
            key: const Key('microsite-copy-url'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
            onPressed: () => _copy(context, url, context.tr('Tautan profil masjid disalin.', 'Mosque profile link copied.')),
            icon: const Icon(Icons.link_rounded),
            label: Text(context.tr('Salin Tautan Profil', 'Copy Profile Link')),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('microsite-copy-wa'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () => _copy(
                    context,
                    waInvite,
                    context.tr('Undangan WA profil masjid disalin.', 'Mosque profile WhatsApp invite copied.'),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(context.tr('Teks WA', 'WhatsApp Text')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('microsite-save-qr'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: _saving ? null : () => _saveQr(context, slug),
                  icon: const Icon(Icons.qr_code_2_rounded),
                  label: Text(context.tr('Simpan QR PNG', 'Save QR PNG')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              key: const Key('microsite-finance-switch'),
              secondary: const Icon(MoeslimIcons.keuangan, color: BrandColors.emerald),
              title: Text(context.tr('Tampilkan Ringkasan Kas di Microsite', 'Show Cash Summary on Microsite')),
              subtitle: Text(
                context.tr(
                  'Opt-in transparansi saldo & arus kas Jumat di halaman web publik masjid.',
                  'Opt-in transparency for cash balance & Friday summary on your public mosque page.',
                ),
              ),
              value: showFinance,
              onChanged: canUpdate && !_saving ? (v) => _togglePublicFinance(context, v) : null,
            ),
          ),
        ],
      ),
    );
  });
}
