import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';
import 'tv_design_page.dart';

const themeLabels = {
  'auto': ('Otomatis', 'Ikuti waktu'),
  'light': ('Terang', 'Krem'),
  'dark': ('Gelap', 'Hijau malam'),
};

const themeLabelsEn = {'auto': ('Auto', 'Match time'), 'light': ('Light', 'Cream'), 'dark': ('Dark', 'Night green')};

(String, String) themeLabelFor(String key, AppLanguage lang) =>
    (lang == AppLanguage.en ? themeLabelsEn[key] : themeLabels[key]) ?? (key, '');

bool isOnline(Map d) {
  final seen = d['last_seen_at'] == null ? null : DateTime.tryParse(d['last_seen_at'] as String);
  return seen != null && DateTime.now().difference(seen.toLocal()) < const Duration(minutes: 5);
}

String _tvWebUrl(String baseUrl) {
  final trimmed = baseUrl.endsWith('/api') ? baseUrl.substring(0, baseUrl.length - 4) : baseUrl;
  return '$trimmed/tv';
}

/// Konfigurasi TV Display: slot 5 layar, scan QR TV Web, pairing kode 6 digit, tema & rotasi per layar.
class TvConfigPage extends ConsumerWidget {
  final MosqueCtx ctx;
  const TvConfigPage({super.key, required this.ctx});

  @override
  Widget build(BuildContext context, WidgetRef ref) => mosqueScoped(context, (context) {
    final data = ref.watch(displaysProvider(ctx.id));
    final api = ref.watch(masjidApiProvider);
    final tvUrl = _tvWebUrl(api.baseUrl);
    final canManage = ctx.can('display.manage');
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Konfigurasi TV Display', 'TV Display Settings')), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(displaysProvider(ctx.id).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Container(
                  width: 64,
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: BrandColors.deep, borderRadius: BorderRadius.circular(6)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: const BrandArt(BrandIllustration.tvMosque, fit: BoxFit.cover),
                  ),
                ),
                title: const Text('Moeslim Mosque TV', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text([ctx.name, ?ctx.city].join(' • ')),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              key: const Key('tv-web-card'),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: BrandColors.emerald),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('TV Web Tanpa Install Aplikasi', 'Zero-Install Web TV Display'),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(
                        'Buka alamat di bawah pada browser Smart TV atau laptop masjid, lalu ketuk Scan QR di Layar TV.',
                        'Open the link below in any Smart TV or laptop browser, then tap Scan TV QR.',
                      ),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            tvUrl,
                            key: const Key('tv-web-url'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: BrandColors.emerald,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          key: const Key('copy-tv-url'),
                          onPressed: () async {
                            final msg = context.tr('Tautan TV Web disalin.', 'Web TV link copied.');
                            await Clipboard.setData(ClipboardData(text: tvUrl));
                            if (context.mounted) showSnack(context, msg);
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: Text(context.tr('Salin', 'Copy')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AsyncBody(
              value: data,
              onRetry: () => ref.invalidate(displaysProvider(ctx.id)),
              data: (d) {
                final devices = (d['data'] as List).cast<Map>().where((x) => x['status'] == 'active').toList();
                final limit = d['limit'] as int? ?? 5;
                final mosqueSettings = Map<String, dynamic>.from((d['mosque_settings'] as Map?) ?? const {});
                final qris = Map<String, dynamic>.from((d['qris'] as Map?) ?? const {});
                final activeOverride = d['override'] is Map ? Map<String, dynamic>.from(d['override'] as Map) : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      context.tr(
                        'Screen Aktif (${devices.length} / $limit)',
                        'Active Screens (${devices.length} / $limit)',
                      ),
                    ),
                    Text(
                      context.tr(
                        'Atur hingga 5 layar TV/Public Display per masjid.',
                        'Manage up to 5 TV/Public Display screens per mosque.',
                      ),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: [
                        for (var i = 0; i < limit; i++)
                          i < devices.length
                              ? _ScreenSlot(
                                  key: Key('screen-${devices[i]['id']}'),
                                  label: 'TV ${i + 1}',
                                  name: devices[i]['name'] as String?,
                                  online: isOnline(devices[i]),
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => _DeviceSheet(
                                      ctx: ctx,
                                      device: Map<String, dynamic>.from(devices[i]),
                                      canManage: canManage,
                                    ),
                                  ),
                                )
                              : _ScreenSlot(
                                  key: Key('slot-$i'),
                                  label: 'TV ${i + 1}',
                                  empty: true,
                                  onTap: canManage ? () => _pair(context, ref) : null,
                                ),
                      ],
                    ),
                    SectionHeader(context.tr('Kontrol TV Display Pro', 'TV Display Pro Controls')),
                    _OverrideControlCard(ctx: ctx, activeOverride: activeOverride, canManage: canManage),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            key: const Key('tv-prayer-settings-btn'),
                            leading: const Icon(MoeslimIcons.jam, color: BrandColors.emerald),
                            title: Text(
                              context.tr('Iqamah, Layar Hening & Mode Jumat', 'Iqamah, Silent Screen & Friday Mode'),
                            ),
                            subtitle: Text(
                              context.tr(
                                'Layar hening: ${mosqueSettings['silent_prayer_screen'] == false ? 'Nonaktif' : 'Aktif'} • '
                                    'Jumat: ${((mosqueSettings['praying_minutes'] as Map?)?['jumuah'] ?? 45)} mnt • '
                                    'Beep: ${mosqueSettings['iqamah_beep'] == false ? 'Mati' : 'Aktif'}',
                                'Silent screen: ${mosqueSettings['silent_prayer_screen'] == false ? 'Off' : 'On'} • '
                                    'Friday: ${((mosqueSettings['praying_minutes'] as Map?)?['jumuah'] ?? 45)} min • '
                                    'Beep: ${mosqueSettings['iqamah_beep'] == false ? 'Off' : 'On'}',
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: canManage
                                ? () => showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => _TvPrayerSettingsSheet(ctx: ctx, settings: mosqueSettings),
                                  )
                                : null,
                          ),
                          SwitchListTile(
                            key: const Key('tv-show-finance-switch'),
                            secondary: const Icon(MoeslimIcons.keuangan, color: BrandColors.emerald),
                            title: Text(context.tr('Tampilkan Kas Jumat di TV', 'Show Friday Cash on TV')),
                            subtitle: Text(
                              context.tr(
                                'Saldo kas & ringkasan pekan Jumat di layar Informasi Jamaah',
                                'Cash balance & weekly Friday summary on the Congregation Info screen',
                              ),
                            ),
                            value: mosqueSettings['display_show_finance'] as bool? ?? false,
                            onChanged: canManage
                                ? (v) async {
                                    try {
                                      await ref.read(masjidApiProvider).updateDisplaySettings(ctx.id, {
                                        'display_show_finance': v,
                                      });
                                      ref.invalidate(displaysProvider(ctx.id));
                                    } on ApiException catch (e) {
                                      if (context.mounted) showSnack(context, e.message);
                                    }
                                  }
                                : null,
                          ),
                          SwitchListTile(
                            key: const Key('tv-show-qris-switch'),
                            secondary: const Icon(Icons.qr_code_2_rounded, color: BrandColors.emerald),
                            title: Text(context.tr('Tampilkan QRIS Infaq di TV', 'Show Donation QRIS on TV')),
                            subtitle: Text(
                              qris['has_image'] == true
                                  ? context.tr(
                                      'Label: ${qris['label'] ?? 'Infaq Masjid'} (gambar terpasang)',
                                      'Label: ${qris['label'] ?? 'Mosque Donations'} (image uploaded)',
                                    )
                                  : context.tr(
                                      'Aktifkan untuk menampilkan kotak QRIS infaq di layar TV',
                                      'Enable to show the donation QRIS card on the TV screen',
                                    ),
                            ),
                            value: mosqueSettings['display_show_qris'] as bool? ?? false,
                            onChanged: canManage
                                ? (v) async {
                                    try {
                                      await ref.read(masjidApiProvider).updateDisplaySettings(ctx.id, {
                                        'display_show_qris': v,
                                      });
                                      ref.invalidate(displaysProvider(ctx.id));
                                    } on ApiException catch (e) {
                                      if (context.mounted) showSnack(context, e.message);
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    SectionHeader(context.tr('Tampilan di Layar', 'Screen Views')),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const _Thumb(BrandIllustration.tvMosque),
                            title: Text(context.tr('Layar Utama & Hening Salat', 'Main & Silent Prayer Screen')),
                            subtitle: Text(
                              context.tr(
                                'Jam, jadwal salat, iqamah, layar hening & papan petugas Jumat',
                                'Clock, prayer times, iqamah, silent screen & Friday roster board',
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const _Thumb(BrandIllustration.heroQuran),
                            title: Text(context.tr('Informasi Jamaah', 'Congregation Info')),
                            subtitle: Text(
                              context.tr(
                                'Agenda, pengumuman, rekap kas Jumat & QRIS infaq',
                                'Events, announcements, Friday cash summary & donation QRIS',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (canManage) ...[
                      FilledButton.icon(
                        key: const Key('scan-tv-qr'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: devices.length >= limit
                            ? null
                            : () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (_) => _TvQrPairSheet(ctx: ctx),
                              ),
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: Text(context.tr('Scan QR di Layar TV', 'Scan QR on TV Screen')),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        key: const Key('pair-tv'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: devices.length >= limit ? null : () => _pair(context, ref),
                        icon: const Icon(MoeslimIcons.layarTv),
                        label: Text(context.tr('Buat Kode Manual (APK TV)', 'Generate Manual Code (TV App)')),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  });

  Future<void> _pair(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.tr('Hubungkan TV', 'Connect TV')),
        content: TextField(
          key: const Key('tv-name'),
          controller: name,
          decoration: InputDecoration(
            labelText: context.tr('Nama layar', 'Screen name'),
            hintText: context.tr('Contoh: Ruang Utama', 'Example: Main Hall'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: Text(context.tr('Batal', 'Cancel'))),
          FilledButton(
            key: const Key('create-code'),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(context.tr('Buat Kode', 'Generate Code')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final code = await ref.read(masjidApiProvider).createPairingCode(ctx.id, name.text.trim());
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text(context.tr('Kode Pairing', 'Pairing Code')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(
                  'Masukkan kode ini di aplikasi Moeslim Mosque TV. Berlaku 10 menit, sekali pakai.',
                  'Enter this code in the Moeslim Mosque TV app. Valid for 10 minutes, single use.',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${code['code']}',
                key: const Key('pairing-code'),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 8),
              ),
            ],
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(context.tr('Selesai', 'Done'))),
          ],
        ),
      );
      ref.invalidate(displaysProvider(ctx.id));
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message);
    }
  }
}

class _ScreenSlot extends StatelessWidget {
  final String label;
  final String? name;
  final bool online;
  final bool empty;
  final VoidCallback? onTap;
  const _ScreenSlot({super.key, required this.label, this.name, this.online = false, this.empty = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: empty ? Colors.transparent : scheme.primary.withValues(alpha: .08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: empty ? scheme.outlineVariant : scheme.primary.withValues(alpha: .4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    empty ? MoeslimIcons.tambah : MoeslimIcons.layarTv,
                    color: empty ? scheme.outline : scheme.primary,
                    size: 28,
                  ),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (name != null)
                    Text(name!, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!empty)
              Positioned(
                right: 6,
                top: 6,
                child: Icon(
                  online ? MoeslimIcons.berhasil : Icons.cloud_off,
                  size: 18,
                  color: online ? BrandColors.emerald : scheme.outline,
                  semanticLabel: online ? 'Online' : 'Offline',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> device;
  final bool canManage;
  const _DeviceSheet({required this.ctx, required this.device, required this.canManage});

  @override
  ConsumerState<_DeviceSheet> createState() => _DeviceSheetState();
}

class _DeviceSheetState extends ConsumerState<_DeviceSheet> {
  late final Map<String, dynamic> _config = Map<String, dynamic>.from((widget.device['config'] as Map?) ?? const {});

  Future<void> _save(Map<String, dynamic> patch) async {
    setState(() => _config.addAll(patch));
    try {
      await ref.read(masjidApiProvider).updateDisplay(widget.ctx.id, widget.device['id'] as int, {'config': patch});
      ref.invalidate(displaysProvider(widget.ctx.id));
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    final d = widget.device;
    final theme = _config['theme'] as String? ?? 'auto';
    final displayLang = (_config['language'] as String?) == 'en' ? 'en' : 'id';
    final rotation = (_config['rotation_seconds'] as num?)?.toInt() ?? 15;
    final seen = d['last_seen_at'] == null ? null : DateTime.tryParse(d['last_seen_at'] as String)?.toLocal();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${d['name'] ?? 'TV Display'}', style: Theme.of(context).textTheme.titleLarge),
            Text(
              seen == null
                  ? context.tr('Belum pernah sinkron', 'Never synced')
                  : context.tr(
                      'Terakhir sinkron ${context.shortDateText(seen)} ${hhmm(seen)}',
                      'Last synced ${context.shortDateText(seen)} ${hhmm(seen)}',
                    ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('open-tv-design'),
              icon: const Icon(MoeslimIcons.layarTv),
              label: Text(context.tr('Desain & Pratinjau Tampilan', 'Design & Preview Display')),
              onPressed: () {
                final all = ref.read(displaysProvider(widget.ctx.id)).value?['data'] as List?;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TvDesignPage(
                      ctx: widget.ctx,
                      device: d,
                      devices: [
                        for (final x in all ?? const [])
                          if (x is Map && x['status'] == 'active') Map<String, dynamic>.from(x),
                      ],
                    ),
                  ),
                );
              },
            ),
            SectionHeader(context.tr('Tema Tampilan', 'Display Theme')),
            Row(
              children: [
                for (final t in themeLabels.entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _ThemeCard(
                        key: Key('theme-${t.key}'),
                        value: t.key,
                        title: themeLabelFor(t.key, lang).$1,
                        subtitle: themeLabelFor(t.key, lang).$2,
                        selected: theme == t.key,
                        onTap: widget.canManage ? () => _save({'theme': t.key}) : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('Bahasa TV Display', 'TV Display Language'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              key: const Key('tv-config-language'),
              segments: const [
                ButtonSegment(value: 'id', label: Text('Indonesia')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {displayLang},
              onSelectionChanged: widget.canManage ? (v) => _save({'language': v.first}) : null,
            ),
            const SizedBox(height: 12),
            Text(context.tr('Rotasi informasi TV Web: $rotation detik', 'TV Web info rotation: $rotation seconds')),
            Slider(
              value: rotation.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: context.tr('$rotation dtk', '$rotation s'),
              onChanged: widget.canManage ? (v) => setState(() => _config['rotation_seconds'] = v.round()) : null,
              onChangeEnd: widget.canManage ? (v) => _save({'rotation_seconds': v.round()}) : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Tampilkan petugas hari ini', "Show today's duty roster")),
              value: _config['show_staff'] as bool? ?? true,
              onChanged: widget.canManage ? (v) => _save({'show_staff': v}) : null,
            ),
            if (widget.canManage) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('revoke-tv'),
                style: OutlinedButton.styleFrom(foregroundColor: MosqueColors.expense),
                icon: const Icon(Icons.link_off),
                label: Text(context.tr('Cabut perangkat ini', 'Revoke this device')),
                onPressed: () async {
                  try {
                    await ref.read(masjidApiProvider).revokeDisplay(widget.ctx.id, d['id'] as int);
                    ref.invalidate(displaysProvider(widget.ctx.id));
                    ref.invalidate(dashboardProvider(widget.ctx.id));
                    if (context.mounted) Navigator.pop(context);
                  } on ApiException catch (e) {
                    if (context.mounted) showSnack(context, e.message);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  });
}

class _ThemeCard extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  const _ThemeCard({
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (value) {
      'light' => (BrandColors.cream, BrandColors.deep),
      'dark' => (BrandColors.nightSurface, BrandColors.cream),
      _ => (BrandColors.emerald, Colors.white),
    };
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? BrandColors.gold : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const BrandArt(BrandIllustration.mosqueBanner, height: 50),
                  if (selected)
                    const Positioned(
                      right: -6,
                      top: -6,
                      child: Icon(MoeslimIcons.berhasil, color: BrandColors.gold, size: 22),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
              Text(subtitle, style: TextStyle(color: fg, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final BrandIllustration art;
  const _Thumb(this.art);

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 64,
      height: 42,
      color: BrandColors.emerald,
      child: BrandArt(art, fit: BoxFit.cover),
    ),
  );
}

class _OverrideControlCard extends ConsumerWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic>? activeOverride;
  final bool canManage;
  const _OverrideControlCard({required this.ctx, required this.activeOverride, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ov = activeOverride;
    if (ov != null) {
      final isDuka = ov['type'] == 'duka';
      return Card(
        key: const Key('tv-override-active'),
        margin: EdgeInsets.zero,
        color: isDuka ? BrandColors.deep : const Color(0xFF7A1C16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isDuka ? MoeslimIcons.peringatan : Icons.campaign_rounded, color: BrandColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('Siaran Aktif: ${ov['title']}', 'Active Broadcast: ${ov['title']}'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${ov['body']}', style: const TextStyle(color: BrandColors.cream, fontSize: 13)),
              if (canManage) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  key: const Key('tv-clear-override'),
                  style: FilledButton.styleFrom(backgroundColor: BrandColors.gold, foregroundColor: BrandColors.deep),
                  onPressed: () async {
                    final lang = context.lang;
                    try {
                      await ref.read(masjidApiProvider).clearDisplayOverride(ctx.id);
                      ref.invalidate(displaysProvider(ctx.id));
                      if (context.mounted) {
                        showSnack(
                          context,
                          lang == AppLanguage.en ? 'Emergency broadcast stopped.' : 'Siaran darurat dihentikan.',
                        );
                      }
                    } on ApiException catch (e) {
                      if (context.mounted) showSnack(context, e.message);
                    }
                  },
                  icon: const Icon(MoeslimIcons.tutup, size: 18),
                  label: Text(context.tr('Hentikan Siaran', 'Stop Broadcast')),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: const Key('tv-override-btn'),
        leading: const Icon(MoeslimIcons.peringatan, color: MosqueColors.warning),
        title: Text(
          context.tr('Siarkan Berita Duka / Darurat', 'Broadcast Condolence / Emergency'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          context.tr('Ambil alih seluruh layar TV masjid secara instan', 'Instantly take over all mosque TV screens'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: canManage
            ? () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _OverrideSheet(ctx: ctx),
              )
            : null,
      ),
    );
  }
}

class _OverrideSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const _OverrideSheet({required this.ctx});

  @override
  ConsumerState<_OverrideSheet> createState() => _OverrideSheetState();
}

class _OverrideSheetState extends ConsumerState<_OverrideSheet> {
  String _type = 'duka';
  int _duration = 60;
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) return;
    final lang = context.lang;
    setState(() => _busy = true);
    try {
      await ref.read(masjidApiProvider).setDisplayOverride(widget.ctx.id, {
        'type': _type,
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        'duration_minutes': _duration,
      });
      ref.invalidate(displaysProvider(widget.ctx.id));
      if (context.mounted) {
        Navigator.pop(context);
        showSnack(
          context,
          lang == AppLanguage.en ? 'Broadcast sent to all TV Displays.' : 'Siaran dikirim ke semua TV Display.',
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(
    context,
    (context) => Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Siaran Instan TV Masjid', 'Instant Mosque TV Broadcast'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'duka', label: Text(context.tr('Berita Duka', 'Condolence'))),
                ButtonSegment(value: 'darurat', label: Text(context.tr('Darurat / Penting', 'Emergency / Urgent'))),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('override-title'),
              controller: _title,
              decoration: InputDecoration(
                labelText: context.tr('Judul siaran *', 'Broadcast title *'),
                hintText: context.tr('Contoh: Berita Duka / Info Parkir', 'Example: Condolence Notice / Parking Alert'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('override-body'),
              controller: _body,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr('Isi pengumuman *', 'Message *'),
                hintText: context.tr(
                  'Tuliskan pesan yang akan tampil penuh di layar TV',
                  'Write the message to display fullscreen on TV',
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _duration,
              decoration: InputDecoration(labelText: context.tr('Durasi tayang', 'Display duration')),
              items: [
                DropdownMenuItem(value: 15, child: Text(context.tr('15 menit', '15 minutes'))),
                DropdownMenuItem(value: 30, child: Text(context.tr('30 menit', '30 minutes'))),
                DropdownMenuItem(value: 60, child: Text(context.tr('1 jam', '1 hour'))),
                DropdownMenuItem(value: 180, child: Text(context.tr('3 jam', '3 hours'))),
                DropdownMenuItem(value: 360, child: Text(context.tr('6 jam', '6 hours'))),
              ],
              onChanged: (v) => setState(() => _duration = v ?? 60),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('override-submit'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
              onPressed: _busy ? null : () => _submit(context),
              icon: const Icon(MoeslimIcons.pengumuman),
              label: Text(context.tr('Tayangkan Sekarang', 'Broadcast Now')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TvPrayerSettingsSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> settings;
  const _TvPrayerSettingsSheet({required this.ctx, required this.settings});

  @override
  ConsumerState<_TvPrayerSettingsSheet> createState() => _TvPrayerSettingsSheetState();
}

class _TvPrayerSettingsSheetState extends ConsumerState<_TvPrayerSettingsSheet> {
  static const _prayers = [
    ('fajr', Prayer.fajr),
    ('dhuhr', Prayer.dhuhr),
    ('asr', Prayer.asr),
    ('maghrib', Prayer.maghrib),
    ('isha', Prayer.isha),
  ];

  late final Map<String, int> _iqamah;
  late final Map<String, int> _praying;
  late bool _silent;
  late bool _beep;
  late final TextEditingController _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final iq = (widget.settings['iqamah_minutes'] as Map?) ?? const {};
    final pr = (widget.settings['praying_minutes'] as Map?) ?? const {};
    _iqamah = {for (final (k, _) in _prayers) k: (iq[k] as num?)?.toInt() ?? (k == 'maghrib' ? 5 : 10)};
    _praying = {
      for (final (k, _) in _prayers) k: (pr[k] as num?)?.toInt() ?? 15,
      'jumuah': (pr['jumuah'] as num?)?.toInt() ?? 45,
    };
    _silent = widget.settings['silent_prayer_screen'] as bool? ?? true;
    _beep = widget.settings['iqamah_beep'] as bool? ?? true;
    _message = TextEditingController(
      text: widget.settings['silent_prayer_message'] as String? ?? 'Luruskan & Rapatkan Shaf • Harap Tenangkan Ponsel',
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final lang = context.lang;
    setState(() => _busy = true);
    try {
      await ref.read(masjidApiProvider).updateDisplaySettings(widget.ctx.id, {
        'iqamah_minutes': _iqamah,
        'praying_minutes': _praying,
        'silent_prayer_screen': _silent,
        'silent_prayer_message': _message.text.trim(),
        'iqamah_beep': _beep,
      });
      ref.invalidate(displaysProvider(widget.ctx.id));
      if (context.mounted) {
        Navigator.pop(context);
        showSnack(context, lang == AppLanguage.en ? 'TV Display settings saved.' : 'Pengaturan TV Display tersimpan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stepper(
    BuildContext context,
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int min = 0,
    int max = 90,
  }) => Row(
    children: [
      Expanded(child: Text(label)),
      IconButton(icon: const Icon(MoeslimIcons.kurangi), onPressed: value > min ? () => onChanged(value - 1) : null),
      SizedBox(width: 52, child: Text(context.tr('$value mnt', '$value min'), textAlign: TextAlign.center)),
      IconButton(icon: const Icon(MoeslimIcons.tambah), onPressed: value < max ? () => onChanged(value + 1) : null),
    ],
  );

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Iqamah & Layar Hening Salat', 'Iqamah & Silent Prayer Screen'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Layar hening otomatis saat salat', 'Automatic silent screen during prayer')),
              subtitle: Text(
                context.tr(
                  'Layar gelap tenang agar jemaah tidak silau saat salat & khutbah',
                  'Calm dark screen to avoid distraction during prayer & sermon',
                ),
              ),
              value: _silent,
              onChanged: (v) => setState(() => _silent = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Sinyal bunyi (beep) saat iqamah', 'Audio chime (beep) at iqamah')),
              value: _beep,
              onChanged: (v) => setState(() => _beep = v),
            ),
            TextField(
              controller: _message,
              maxLength: 160,
              decoration: InputDecoration(labelText: context.tr('Pesan layar hening', 'Silent screen message')),
            ),
            SectionHeader(context.tr('Jeda Iqamah (menit setelah adzan)', 'Iqamah Delay (minutes after adhan)')),
            for (final (k, prayer) in _prayers)
              _stepper(
                context,
                prayer.labelFor(lang),
                _iqamah[k]!,
                (v) => setState(() => _iqamah[k] = v),
                min: 0,
                max: 60,
              ),
            SectionHeader(context.tr('Durasi Layar Hening Salat', 'Silent Prayer Screen Duration')),
            _stepper(
              context,
              context.tr('Salat 5 Waktu (default)', '5 Daily Prayers (default)'),
              _praying['dhuhr']!,
              (v) {
                setState(() {
                  for (final (k, _) in _prayers) {
                    _praying[k] = v;
                  }
                });
              },
              min: 5,
              max: 45,
            ),
            _stepper(
              context,
              context.tr('Khutbah & Salat Jumat', 'Friday Sermon & Prayer'),
              _praying['jumuah']!,
              (v) => setState(() => _praying['jumuah'] = v),
              min: 15,
              max: 90,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('save-tv-settings'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
              onPressed: _busy ? null : () => _save(context),
              icon: const Icon(MoeslimIcons.simpan),
              label: Text(context.tr('Simpan Pengaturan TV', 'Save TV Settings')),
            ),
          ],
        ),
      ),
    );
  });
}

class _TvQrPairSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const _TvQrPairSheet({required this.ctx});

  @override
  ConsumerState<_TvQrPairSheet> createState() => _TvQrPairSheetState();
}

class _TvQrPairSheetState extends ConsumerState<_TvQrPairSheet> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _approve(BuildContext context, {String? sessionId, String? code}) async {
    final lang = context.lang;
    setState(() => _busy = true);
    try {
      await ref
          .read(masjidApiProvider)
          .approveDisplaySession(
            widget.ctx.id,
            sessionId: sessionId,
            code: code,
            name: _name.text.trim().isEmpty ? null : _name.text.trim(),
          );
      ref.invalidate(displaysProvider(widget.ctx.id));
      ref.invalidate(dashboardProvider(widget.ctx.id));
      if (context.mounted) {
        Navigator.pop(context);
        showSnack(
          context,
          lang == AppLanguage.en
              ? 'TV connected. The TV screen will switch automatically in a few seconds.'
              : 'TV berhasil terhubung. Layar TV akan otomatis berganti dalam beberapa detik.',
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scanQr(BuildContext context) async {
    final raw = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _TvQrScannerPage()));
    if (!context.mounted || raw == null || raw.trim().isEmpty) return;
    final trimmed = raw.trim();
    if (trimmed.toUpperCase().startsWith('MOESLIMTV:')) {
      await _approve(context, sessionId: trimmed);
      return;
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      _code.text = digits;
      await _approve(context, code: digits);
      return;
    }
    await _approve(context, sessionId: trimmed);
  }

  Future<void> _submitCode(BuildContext context) async {
    final digits = _code.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      showSnack(
        context,
        context.tr(
          'Masukkan 6 digit kode yang tampil di layar TV.',
          'Enter the 6-digit code displayed on the TV screen.',
        ),
      );
      return;
    }
    await _approve(context, code: digits);
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(
    context,
    (context) => Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Hubungkan TV Web via QR', 'Connect Web TV via QR'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                'Buka tautan /tv di browser TV masjid, lalu pindai QR yang muncul di layar TV.',
                'Open the /tv link on your mosque TV browser, then scan the QR code shown on screen.',
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('qr-tv-name'),
              controller: _name,
              decoration: InputDecoration(
                labelText: context.tr('Nama layar (opsional)', 'Screen name (optional)'),
                hintText: context.tr('Contoh: TV Ruang Utama', 'Example: Main Hall TV'),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const Key('open-tv-qr-scanner'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
              onPressed: _busy ? null : () => _scanQr(context),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(context.tr('Buka Kamera Scan QR TV', 'Open Camera to Scan TV QR')),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr('Atau ketik 6 digit kode di layar TV', 'Or enter the 6-digit code shown on TV'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('tv-session-code'),
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: context.tr('Kode 6 digit dari layar TV', '6-digit code from TV screen'),
                hintText: '123456',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('approve-tv-session'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
              onPressed: _busy ? null : () => _submitCode(context),
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(MoeslimIcons.layarTv),
              label: Text(context.tr('Hubungkan TV Ini', 'Connect This TV')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TvQrScannerPage extends StatefulWidget {
  const _TvQrScannerPage();

  @override
  State<_TvQrScannerPage> createState() => _TvQrScannerPageState();
}

class _TvQrScannerPageState extends State<_TvQrScannerPage> {
  bool _popped = false;

  @override
  Widget build(BuildContext context) => mosqueScoped(
    context,
    (context) => Scaffold(
      appBar: AppBar(title: Text(context.tr('Pindai QR Layar TV', 'Scan TV Screen QR')), centerTitle: true),
      body: MobileScanner(
        onDetect: (capture) {
          if (_popped) return;
          final raw = capture.barcodes.firstOrNull?.rawValue;
          if (raw != null && raw.trim().isNotEmpty) {
            _popped = true;
            Navigator.of(context).pop(raw.trim());
          }
        },
      ),
    ),
  );
}
