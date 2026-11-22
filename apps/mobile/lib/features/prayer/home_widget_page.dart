import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class HomeWidgetPage extends ConsumerStatefulWidget {
  const HomeWidgetPage({super.key});

  @override
  ConsumerState<HomeWidgetPage> createState() => _HomeWidgetPageState();
}

class _HomeWidgetPageState extends ConsumerState<HomeWidgetPage> {
  HomeWidgetConfig _config = const HomeWidgetConfig();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await ref.read(homeWidgetRepoProvider).load();
    if (mounted) {
      setState(() {
        _config = loaded;
        _loading = false;
      });
    }
  }

  Future<void> _save(HomeWidgetConfig next) async {
    await ref.read(homeWidgetRepoProvider).save(next);
    if (mounted) setState(() => _config = next);
  }

  Future<void> _syncFromLivePrayer() async {
    final status = ref.read(prayerStatusProvider).value;
    final settings = ref.read(settingsProvider).value;
    if (status == null || settings == null) return;
    final hijri = HijriDate.fromGregorian(status.now, offsetDays: settings.hijriOffset).toString();
    final updated = _config.copyWith(
      lastSyncedNextPrayer: status.nextPrayer.label,
      lastSyncedNextTime: hhmm(status.nextTime),
      lastSyncedLocation: settings.effectiveLocationName,
      lastSyncedHijri: hijri,
    );
    await _save(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data widget layar utama diperbarui dengan jadwal salat aktif.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(prayerStatusProvider).value;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Widget Layar Utama Android'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader('Pratinjau Widget Layar Utama'),
                _WidgetPreviewCard(config: _config, status: status),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('sync-home-widget'),
                  onPressed: _syncFromLivePrayer,
                  icon: const Icon(MoeslimIcons.refresh),
                  label: const Text('Sinkronkan Jadwal ke Widget Sekarang'),
                ),
                const SectionHeader('Gaya Tampilan Widget'),
                for (final style in HomeWidgetStyle.values)
                  Card(
                    child: ListTile(
                      key: Key('widget-style-${style.name}'),
                      leading: Icon(
                        _config.style == style ? MoeslimIcons.berhasil : Icons.circle_outlined,
                        color: _config.style == style ? BrandColors.emerald : null,
                      ),
                      title: Text(style.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(style.description),
                      onTap: () => _save(_config.copyWith(style: style)),
                    ),
                  ),
                const SectionHeader('Opsi Informasi Widget'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Tampilkan Tanggal Hijriah'),
                        value: _config.showHijriDate,
                        onChanged: (v) => _save(_config.copyWith(showHijriDate: v)),
                      ),
                      SwitchListTile(
                        title: const Text('Tampilkan Lokasi Salat'),
                        value: _config.showLocation,
                        onChanged: (v) => _save(_config.copyWith(showLocation: v)),
                      ),
                      SwitchListTile(
                        title: const Text('Latar Zamrud Gelap (Kontras Tinggi)'),
                        value: _config.darkSurface,
                        onChanged: (v) => _save(_config.copyWith(darkSurface: v)),
                      ),
                    ],
                  ),
                ),
                const SectionHeader('Cara Memasang di Layar Utama Android'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '1. Tekan tahan area kosong di Layar Utama (Home Screen) ponsel Android Anda.\n'
                      '2. Pilih menu "Widget" lalu cari "Moeslim PM".\n'
                      '3. Tarik widget Jadwal Salat Moeslim PM ke layar utama Anda.',
                      style: t.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  final HomeWidgetConfig config;
  final PrayerStatus? status;

  const _WidgetPreviewCard({required this.config, required this.status});

  @override
  Widget build(BuildContext context) {
    final bg = config.darkSurface ? BrandColors.deep : BrandColors.cream;
    final fg = config.darkSurface ? Colors.white : BrandColors.deep;
    final accent = config.darkSurface ? BrandColors.emeraldLight : BrandColors.emerald;

    return Container(
      key: const Key('home-widget-preview'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moeslim PM',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              if (config.showLocation || config.showHijriDate)
                Flexible(
                  child: Text(
                    [
                      if (config.showLocation) config.lastSyncedLocation,
                      if (config.showHijriDate) config.lastSyncedHijri,
                    ].join(' · '),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg.withValues(alpha: .8), fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Salat Berikutnya', style: TextStyle(color: fg.withValues(alpha: .75), fontSize: 12)),
                  Text(
                    '${config.lastSyncedNextPrayer} · ${config.lastSyncedNextTime}',
                    style: TextStyle(color: fg, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    countdown(status!.remaining),
                    style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          if (config.style == HomeWidgetStyle.prayerAndQuote) ...[
            const SizedBox(height: 10),
            Text(
              config.lastSyncedQuote,
              style: TextStyle(color: fg.withValues(alpha: .9), fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
          if (config.style == HomeWidgetStyle.fullFiveTimes && status != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final (lbl, tm) in [
                  ('Subuh', status!.today.fajr),
                  ('Dzuhur', status!.today.dhuhr),
                  ('Ashar', status!.today.asr),
                  ('Maghrib', status!.today.maghrib),
                  ('Isya', status!.today.isha),
                ])
                  Column(
                    children: [
                      Text(lbl, style: TextStyle(color: fg.withValues(alpha: .75), fontSize: 11)),
                      Text(hhmm(tm), style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
