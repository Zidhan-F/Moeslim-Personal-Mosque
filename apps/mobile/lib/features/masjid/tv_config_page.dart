import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const themeLabels = {
  'auto': ('Otomatis', 'Ikuti waktu'),
  'light': ('Terang', 'Krem'),
  'dark': ('Gelap', 'Hijau malam'),
};

bool isOnline(Map d) {
  final seen = d['last_seen_at'] == null ? null : DateTime.tryParse(d['last_seen_at'] as String);
  return seen != null && DateTime.now().difference(seen.toLocal()) < const Duration(minutes: 5);
}

/// Konfigurasi TV Display: slot 5 layar, pairing kode 6 digit, tema & rotasi per layar, cabut perangkat.
class TvConfigPage extends ConsumerWidget {
  final MosqueCtx ctx;
  const TvConfigPage({super.key, required this.ctx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(displaysProvider(ctx.id));
    final canManage = ctx.can('display.manage');
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi TV Display'), centerTitle: true),
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
                    SectionHeader('Screen Aktif (${devices.length} / $limit)'),
                    const Text('Atur hingga 5 layar TV/Public Display per masjid.', style: TextStyle(fontSize: 12.5)),
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
                    const SectionHeader('Kontrol TV Display Pro'),
                    _OverrideControlCard(ctx: ctx, activeOverride: activeOverride, canManage: canManage),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            key: const Key('tv-prayer-settings-btn'),
                            leading: const Icon(MoeslimIcons.jam, color: BrandColors.emerald),
                            title: const Text('Iqamah, Layar Hening & Mode Jumat'),
                            subtitle: Text(
                              'Layar hening: ${mosqueSettings['silent_prayer_screen'] == false ? 'Nonaktif' : 'Aktif'} • '
                              'Jumat: ${((mosqueSettings['praying_minutes'] as Map?)?['jumuah'] ?? 45)} mnt • '
                              'Beep: ${mosqueSettings['iqamah_beep'] == false ? 'Mati' : 'Aktif'}',
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
                            title: const Text('Tampilkan Kas Jumat di TV'),
                            subtitle: const Text('Saldo kas & ringkasan pekan Jumat di layar Informasi Jamaah'),
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
                            title: const Text('Tampilkan QRIS Infaq di TV'),
                            subtitle: Text(
                              qris['has_image'] == true
                                  ? 'Label: ${qris['label'] ?? 'Infaq Masjid'} (gambar terpasang)'
                                  : 'Aktifkan untuk menampilkan kotak QRIS infaq di layar TV',
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
                    const SectionHeader('Tampilan di Layar'),
                    const Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: _Thumb(BrandIllustration.tvMosque),
                            title: Text('Layar Utama & Hening Salat'),
                            subtitle: Text('Jam, jadwal salat, iqamah, layar hening & papan petugas Jumat'),
                          ),
                          ListTile(
                            leading: _Thumb(BrandIllustration.heroQuran),
                            title: Text('Informasi Jamaah'),
                            subtitle: Text('Agenda, pengumuman, rekap kas Jumat & QRIS infaq'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (canManage)
                      FilledButton.icon(
                        key: const Key('pair-tv'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: devices.length >= limit ? null : () => _pair(context, ref),
                        icon: const Icon(MoeslimIcons.layarTv),
                        label: const Text('Hubungkan TV Baru'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pair(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hubungkan TV'),
        content: TextField(
          key: const Key('tv-name'),
          controller: name,
          decoration: const InputDecoration(labelText: 'Nama layar', hintText: 'Contoh: Ruang Utama'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            key: const Key('create-code'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Buat Kode'),
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
        builder: (_) => AlertDialog(
          title: const Text('Kode Pairing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan kode ini di aplikasi Moeslim Mosque TV. Berlaku 10 menit, sekali pakai.'),
              const SizedBox(height: 16),
              Text(
                '${code['code']}',
                key: const Key('pairing-code'),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 8),
              ),
            ],
          ),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai'))],
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
  Widget build(BuildContext context) {
    final d = widget.device;
    final theme = _config['theme'] as String? ?? 'auto';
    final rotation = (_config['rotation_seconds'] as num?)?.toInt() ?? 15;
    final seen = d['last_seen_at'] == null ? null : DateTime.tryParse(d['last_seen_at'] as String)?.toLocal();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${d['name'] ?? 'TV Display'}', style: Theme.of(context).textTheme.titleLarge),
          Text(seen == null ? 'Belum pernah sinkron' : 'Terakhir sinkron ${shortDate(seen)} ${hhmm(seen)}'),
          const SectionHeader('Tema Tampilan'),
          Row(
            children: [
              for (final t in themeLabels.entries)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _ThemeCard(
                      key: Key('theme-${t.key}'),
                      value: t.key,
                      title: t.value.$1,
                      subtitle: t.value.$2,
                      selected: theme == t.key,
                      onTap: widget.canManage ? () => _save({'theme': t.key}) : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Rotasi informasi: $rotation detik'),
          Slider(
            value: rotation.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            label: '$rotation dtk',
            onChanged: widget.canManage ? (v) => setState(() => _config['rotation_seconds'] = v.round()) : null,
            onChangeEnd: widget.canManage ? (v) => _save({'rotation_seconds': v.round()}) : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tampilkan petugas hari ini'),
            value: _config['show_staff'] as bool? ?? true,
            onChanged: widget.canManage ? (v) => _save({'show_staff': v}) : null,
          ),
          if (widget.canManage) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('revoke-tv'),
              style: OutlinedButton.styleFrom(foregroundColor: MosqueColors.expense),
              icon: const Icon(Icons.link_off),
              label: const Text('Cabut perangkat ini'),
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
    );
  }
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
                      'Siaran Aktif: ${ov['title']}',
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
                    try {
                      await ref.read(masjidApiProvider).clearDisplayOverride(ctx.id);
                      ref.invalidate(displaysProvider(ctx.id));
                      if (context.mounted) showSnack(context, 'Siaran darurat dihentikan.');
                    } on ApiException catch (e) {
                      if (context.mounted) showSnack(context, e.message);
                    }
                  },
                  icon: const Icon(MoeslimIcons.tutup, size: 18),
                  label: const Text('Hentikan Siaran'),
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
        title: const Text('Siarkan Berita Duka / Darurat', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('Ambil alih seluruh layar TV masjid secara instan'),
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

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(masjidApiProvider).setDisplayOverride(widget.ctx.id, {
        'type': _type,
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        'duration_minutes': _duration,
      });
      ref.invalidate(displaysProvider(widget.ctx.id));
      if (mounted) {
        Navigator.pop(context);
        showSnack(context, 'Siaran dikirim ke semua TV Display.');
      }
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Siaran Instan TV Masjid', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'duka', label: Text('Berita Duka')),
                ButtonSegment(value: 'darurat', label: Text('Darurat / Penting')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('override-title'),
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Judul siaran *',
                hintText: 'Contoh: Berita Duka / Info Parkir',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('override-body'),
              controller: _body,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Isi pengumuman *',
                hintText: 'Tuliskan pesan yang akan tampil penuh di layar TV',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _duration,
              decoration: const InputDecoration(labelText: 'Durasi tayang'),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 menit')),
                DropdownMenuItem(value: 30, child: Text('30 menit')),
                DropdownMenuItem(value: 60, child: Text('1 jam')),
                DropdownMenuItem(value: 180, child: Text('3 jam')),
                DropdownMenuItem(value: 360, child: Text('6 jam')),
              ],
              onChanged: (v) => setState(() => _duration = v ?? 60),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('override-submit'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
              onPressed: _busy ? null : _submit,
              icon: const Icon(MoeslimIcons.pengumuman),
              label: const Text('Tayangkan Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
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
    ('fajr', 'Subuh'),
    ('dhuhr', 'Dzuhur'),
    ('asr', 'Ashar'),
    ('maghrib', 'Maghrib'),
    ('isha', 'Isya'),
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
    _iqamah = {
      for (final (k, _) in _prayers) k: (iq[k] as num?)?.toInt() ?? (k == 'maghrib' ? 5 : 10),
    };
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

  Future<void> _save() async {
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
      if (mounted) {
        Navigator.pop(context);
        showSnack(context, 'Pengaturan TV Display tersimpan.');
      }
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stepper(String label, int value, ValueChanged<int> onChanged, {int min = 0, int max = 90}) => Row(
    children: [
      Expanded(child: Text(label)),
      IconButton(
        icon: const Icon(MoeslimIcons.kurangi),
        onPressed: value > min ? () => onChanged(value - 1) : null,
      ),
      SizedBox(width: 52, child: Text('$value mnt', textAlign: TextAlign.center)),
      IconButton(
        icon: const Icon(MoeslimIcons.tambah),
        onPressed: value < max ? () => onChanged(value + 1) : null,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Iqamah & Layar Hening Salat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Layar hening otomatis saat salat'),
              subtitle: const Text('Layar gelap tenang agar jemaah tidak silau saat salat & khutbah'),
              value: _silent,
              onChanged: (v) => setState(() => _silent = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sinyal bunyi (beep) saat iqamah'),
              value: _beep,
              onChanged: (v) => setState(() => _beep = v),
            ),
            TextField(
              controller: _message,
              maxLength: 160,
              decoration: const InputDecoration(labelText: 'Pesan layar hening'),
            ),
            const SectionHeader('Jeda Iqamah (menit setelah adzan)'),
            for (final (k, label) in _prayers)
              _stepper(label, _iqamah[k]!, (v) => setState(() => _iqamah[k] = v), min: 0, max: 60),
            const SectionHeader('Durasi Layar Hening Salat'),
            _stepper('Salat 5 Waktu (default)', _praying['dhuhr']!, (v) {
              setState(() {
                for (final (k, _) in _prayers) {
                  _praying[k] = v;
                }
              });
            }, min: 5, max: 45),
            _stepper('Khutbah & Salat Jumat', _praying['jumuah']!, (v) => setState(() => _praying['jumuah'] = v), min: 15, max: 90),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('save-tv-settings'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
              onPressed: _busy ? null : _save,
              icon: const Icon(MoeslimIcons.simpan),
              label: const Text('Simpan Pengaturan TV'),
            ),
          ],
        ),
      ),
    );
  }
}
