import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/location_service.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

const _defaultQuoteId = "Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram. (QS. Ar-Ra'd: 28)";
const _defaultQuoteEn = "Unquestionably, by the remembrance of Allah hearts are assured. (Qur'an Ar-Ra'd: 28)";

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

  String _styleLabel(BuildContext context, HomeWidgetStyle style) => switch (style) {
    HomeWidgetStyle.compactPrayer => context.tr(style.label, 'Compact (Next Prayer)'),
    HomeWidgetStyle.prayerAndQuote => context.tr(style.label, 'Prayer & Daily Verse'),
    HomeWidgetStyle.fullFiveTimes => context.tr(style.label, 'All 5 Daily Prayers'),
  };

  String _styleDescription(BuildContext context, HomeWidgetStyle style) => switch (style) {
    HomeWidgetStyle.compactPrayer => context.tr(
      style.description,
      'Shows the next prayer time, countdown, and location.',
    ),
    HomeWidgetStyle.prayerAndQuote => context.tr(
      style.description,
      'Shows the next prayer time along with a daily verse or supplication.',
    ),
    HomeWidgetStyle.fullFiveTimes => context.tr(
      style.description,
      'Displays Fajr, Dhuhr, Asr, Maghrib, and Isha times for today.',
    ),
  };

  Future<void> _syncFromLivePrayer() async {
    final status = ref.read(prayerStatusProvider).value;
    final settings = ref.read(settingsProvider).value;
    if (status == null || settings == null) return;
    final lang = ref.read(appLanguageProvider);
    final hijri = HijriDate.fromGregorian(status.now, offsetDays: settings.hijriOffset).format(lang);
    final quote = lang == AppLanguage.en ? _defaultQuoteEn : _defaultQuoteId;
    final updated = _config.copyWith(
      lastSyncedNextPrayer: status.nextPrayer.labelFor(lang),
      lastSyncedNextTime: hhmm(status.nextTime),
      lastSyncedLocation: localizeLocationLabel(settings.effectiveLocationName, lang),
      lastSyncedHijri: hijri,
      lastSyncedQuote: quote,
    );
    await _save(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'Data widget layar utama diperbarui dengan jadwal salat aktif.',
            'Home screen widget updated with active prayer times.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(prayerStatusProvider).value;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Widget Layar Utama Android', 'Android Home Screen Widget')),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionHeader(context.tr('Pratinjau Widget Layar Utama', 'Home Widget Preview')),
                _WidgetPreviewCard(config: _config, status: status),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('sync-home-widget'),
                  onPressed: _syncFromLivePrayer,
                  icon: const Icon(MoeslimIcons.refresh),
                  label: Text(
                    context.tr('Sinkronkan Jadwal ke Widget Sekarang', 'Sync Schedule to Widget Now'),
                  ),
                ),
                SectionHeader(context.tr('Gaya Tampilan Widget', 'Widget Layout Style')),
                for (final style in HomeWidgetStyle.values)
                  Card(
                    child: ListTile(
                      key: Key('widget-style-${style.name}'),
                      leading: Icon(
                        _config.style == style ? MoeslimIcons.berhasil : Icons.circle_outlined,
                        color: _config.style == style ? BrandColors.emerald : null,
                      ),
                      title: Text(_styleLabel(context, style), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_styleDescription(context, style)),
                      onTap: () => _save(_config.copyWith(style: style)),
                    ),
                  ),
                SectionHeader(context.tr('Opsi Informasi Widget', 'Widget Display Options')),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(context.tr('Tampilkan Tanggal Hijriah', 'Show Hijri Date')),
                        value: _config.showHijriDate,
                        onChanged: (v) => _save(_config.copyWith(showHijriDate: v)),
                      ),
                      SwitchListTile(
                        title: Text(context.tr('Tampilkan Lokasi Salat', 'Show Prayer Location')),
                        value: _config.showLocation,
                        onChanged: (v) => _save(_config.copyWith(showLocation: v)),
                      ),
                      SwitchListTile(
                        title: Text(
                          context.tr('Latar Zamrud Gelap (Kontras Tinggi)', 'Dark Emerald Surface (High Contrast)'),
                        ),
                        value: _config.darkSurface,
                        onChanged: (v) => _save(_config.copyWith(darkSurface: v)),
                      ),
                    ],
                  ),
                ),
                SectionHeader(
                  context.tr('Cara Memasang di Layar Utama Android', 'How to Add on Android Home Screen'),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      context.tr(
                        '1. Tekan tahan area kosong di Layar Utama (Home Screen) ponsel Android Anda.\n'
                            '2. Pilih menu "Widget" lalu cari "Moeslim PM".\n'
                            '3. Tarik widget Jadwal Salat Moeslim PM ke layar utama Anda.',
                        '1. Press and hold an empty area on your Android Home Screen.\n'
                            '2. Select "Widgets" and search for "Moeslim PM".\n'
                            '3. Drag the Moeslim PM Prayer Times widget onto your home screen.',
                      ),
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

  String _previewPrayer(BuildContext context) {
    if (!context.isEn) return config.lastSyncedNextPrayer;
    return switch (config.lastSyncedNextPrayer) {
      'Subuh' => 'Fajr',
      'Dzuhur' => 'Dhuhr',
      'Ashar' => 'Asr',
      'Isya' => 'Isha',
      _ => config.lastSyncedNextPrayer,
    };
  }

  String _previewHijri(BuildContext context) {
    if (!context.isEn) return config.lastSyncedHijri;
    if (config.lastSyncedHijri.endsWith(' H')) {
      return '${config.lastSyncedHijri.substring(0, config.lastSyncedHijri.length - 2)} AH';
    }
    return config.lastSyncedHijri;
  }

  String _previewQuote(BuildContext context) {
    if (context.isEn && config.lastSyncedQuote == _defaultQuoteId) return _defaultQuoteEn;
    if (!context.isEn && config.lastSyncedQuote == _defaultQuoteEn) return _defaultQuoteId;
    return config.lastSyncedQuote;
  }

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
                      if (config.showLocation) localizeLocationLabel(config.lastSyncedLocation, context.lang),
                      if (config.showHijriDate) _previewHijri(context),
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
                  Text(
                    context.tr('Salat Berikutnya', 'Next Prayer'),
                    style: TextStyle(color: fg.withValues(alpha: .75), fontSize: 12),
                  ),
                  Text(
                    '${_previewPrayer(context)} · ${config.lastSyncedNextTime}',
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
              _previewQuote(context),
              style: TextStyle(color: fg.withValues(alpha: .9), fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
          if (config.style == HomeWidgetStyle.fullFiveTimes && status != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final p in Prayer.values)
                  Column(
                    children: [
                      Text(context.prayerLabel(p), style: TextStyle(color: fg.withValues(alpha: .75), fontSize: 11)),
                      Text(
                        hhmm(status!.today.timeOf(p)),
                        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
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
