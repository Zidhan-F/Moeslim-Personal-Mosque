import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/adzan_service.dart';
import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/location_service.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../../ui/prayer_sky_icon.dart';
import '../ibadah/qibla_page.dart' show coordinateId;

String _formatCoord(double value, {required bool isLatitude, required AppLanguage lang}) {
  if (lang != AppLanguage.en) return coordinateId(value, isLatitude: isLatitude);
  final hemi = isLatitude ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
  return '${value.abs().toStringAsFixed(5)}° $hemi';
}

class PrayerPage extends ConsumerStatefulWidget {
  const PrayerPage({super.key});

  @override
  ConsumerState<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends ConsumerState<PrayerPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncIfUsingGps());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _syncIfUsingGps();
    }
  }

  void _syncIfUsingGps() {
    if (!mounted) return;
    final s = ref.read(settingsProvider).value;
    if (s != null && s.useDeviceLocation) {
      unawaited(ref.read(gpsControllerProvider.notifier).ensureActive());
    }
  }

  void _weekly(BuildContext context, PersonalSettings s, DateTime today) {
    final days = [for (var i = 0; i < 7; i++) DateTime(today.year, today.month, today.day + i)];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columnSpacing: 16,
          columns: [
            DataColumn(label: Text(sheetCtx.tr('Tanggal', 'Date'))),
            for (final p in Prayer.values) DataColumn(label: Text(sheetCtx.prayerLabel(p))),
          ],
          rows: [
            for (final d in days)
              DataRow(
                cells: [
                  DataCell(Text(sheetCtx.shortDateText(d))),
                  for (final p in Prayer.values) DataCell(Text(hhmm(s.timesFor(d).timeOf(p)))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final status = ref.watch(prayerStatusProvider).value;
    final gpsState = ref.watch(gpsControllerProvider);
    final adzanState = ref.watch(adzanControllerProvider);
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final goldInk = dark ? BrandColors.gold : BrandColors.goldText;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Jadwal Salat', 'Prayer Times')),
        centerTitle: true,
        actions: [
          if (settings.value != null && status != null)
            IconButton(
              key: const Key('weekly-schedule'),
              tooltip: context.tr('Jadwal 7 hari', '7-day schedule'),
              icon: const Icon(MoeslimIcons.kalender),
              onPressed: () => _weekly(context, settings.value!, status.now),
            ),
        ],
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          if (status == null) return const Center(child: CircularProgressIndicator());
          final hijri = HijriDate.fromGregorian(status.now, offsetDays: s.hijriOffset);
          final rows = <(String, String, DateTime, Prayer?)>[
            ('Subuh', context.prayerLabel(Prayer.fajr), status.today.fajr, Prayer.fajr),
            ('Syuruq', context.tr('Syuruq', 'Sunrise'), status.today.sunrise, null),
            ('Dzuhur', context.prayerLabel(Prayer.dhuhr), status.today.dhuhr, Prayer.dhuhr),
            ('Ashar', context.prayerLabel(Prayer.asr), status.today.asr, Prayer.asr),
            ('Maghrib', context.prayerLabel(Prayer.maghrib), status.today.maghrib, Prayer.maghrib),
            ('Isya', context.prayerLabel(Prayer.isha), status.today.isha, Prayer.isha),
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ArchHeader(
                child: Column(
                  children: [
                    Text(context.longDateText(status.now), style: t.titleMedium),
                    Text(context.hijriText(hijri), style: t.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MoeslimIcons.lokasi, size: 16, color: scheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            localizeLocationSubtitle(s, lang),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (s.isUsingGpsLocation && s.deviceLocation != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${_formatCoord(s.deviceLocation!.latitude, isLatitude: true, lang: lang)}, '
                        '${_formatCoord(s.deviceLocation!.longitude, isLatitude: false, lang: lang)}'
                        '${s.deviceLocation!.accuracyMeters != null ? ' • ±${s.deviceLocation!.accuracyMeters!.round()} m' : ''}',
                        style: t.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _PrayerGpsBanner(settings: s, gpsState: gpsState),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(MoeslimIcons.masjid, color: scheme.primary, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('Menuju Salat', 'Next Prayer')),
                            Text(
                              context.prayerLabel(status.nextPrayer),
                              key: const Key('next-prayer'),
                              style: t.titleLarge?.copyWith(color: scheme.primary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: BrandColors.gold.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(MoeslimIcons.jam, size: 18, color: goldInk),
                            const SizedBox(width: 4),
                            Text(
                              countdown(status.remaining),
                              style: TextStyle(
                                color: goldInk,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(context.tr('Jadwal Salat Hari Ini', "Today's Prayer Times")),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      for (final (canonicalKey, label, time, p) in rows)
                        Container(
                          key: Key('row-$canonicalKey'),
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: p != null && p == status.nextPrayer ? scheme.primary.withValues(alpha: .12) : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: p == null
                                ? Icon(MoeslimIcons.matahari, color: goldInk)
                                : PrayerSkyIcon(canonicalKey, color: goldInk),
                            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(hhmm(time), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                if (p != null) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    key: Key('toggle-adzan-${p.name}'),
                                    visualDensity: VisualDensity.compact,
                                    tooltip: s.isAdzanActiveFor(p)
                                        ? context.tr(
                                            'Alarm adzan $label aktif (ketuk untuk matikan)',
                                            '$label adhan alert on (tap to mute)',
                                          )
                                        : context.tr(
                                            'Alarm adzan $label mati (ketuk untuk aktifkan)',
                                            '$label adhan alert off (tap to enable)',
                                          ),
                                    icon: Icon(
                                      s.isAdzanActiveFor(p) ? MoeslimIcons.adzan : MoeslimIcons.bisukan,
                                      size: 20,
                                      color: s.isAdzanActiveFor(p) ? scheme.primary : scheme.outline,
                                    ),
                                    onPressed: () => ref
                                        .read(settingsProvider.notifier)
                                        .save(s.setPrayerAdzan(p, !s.isAdzanActiveFor(p))),
                                  ),
                                ] else
                                  const SizedBox(width: 10),
                                SizedBox(
                                  width: 24,
                                  child: !time.isAfter(status.now)
                                      ? Icon(
                                          MoeslimIcons.check,
                                          color: scheme.primary,
                                          size: 20,
                                          semanticLabel: context.tr('sudah lewat', 'passed'),
                                        )
                                      : (p != null && p == status.nextPrayer
                                            ? Icon(
                                                MoeslimIcons.play,
                                                color: scheme.primary,
                                                size: 20,
                                                semanticLabel: context.tr('berikutnya', 'upcoming'),
                                              )
                                            : null),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                key: const Key('prayer-adzan-summary'),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        s.activeAdzanCount > 0 ? MoeslimIcons.adzan : MoeslimIcons.bisukan,
                        color: s.activeAdzanCount > 0 ? scheme.primary : scheme.outline,
                      ),
                      title: Text(
                        context.tr('Alarm & Suara Adzan', 'Adhan Alerts & Voice'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        s.activeAdzanCount > 0
                            ? context.tr(
                                'Aktif (${s.activeAdzanCount}/5 waktu) • ${s.muadzin.name}',
                                'Active (${s.activeAdzanCount}/5 prayers) • ${s.muadzin.name}',
                              )
                            : context.tr(
                                'Alarm adzan nonaktif • Ketuk untuk mengatur',
                                'Adhan alerts off • Tap to configure',
                              ),
                      ),
                      trailing: OutlinedButton.icon(
                        key: const Key('prayer-preview-adzan'),
                        onPressed: () =>
                            ref.read(adzanControllerProvider.notifier).togglePreviewMuadzin(s.muadzin),
                        icon: Icon(
                          adzanState.previewingMuadzinId == s.muadzin.id ? MoeslimIcons.pause : MoeslimIcons.suara,
                          size: 18,
                        ),
                        label: Text(
                          adzanState.previewingMuadzinId == s.muadzin.id
                              ? context.tr('Berhenti', 'Stop')
                              : context.tr('Uji Suara', 'Preview'),
                        ),
                      ),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calculate_outlined),
                      title: Text(context.tr('Metode Perhitungan', 'Calculation Method')),
                      subtitle: Text(context.methodLabel(s.method)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                    ListTile(
                      leading: const Icon(MoeslimIcons.lokasi),
                      title: Text(context.tr('Lokasi', 'Location')),
                      subtitle: Text(localizeLocationSubtitle(s, lang)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  context.tr(
                    'Jadwal dihitung secara lokal (offline) dari koordinat GPS atau kota pilihan. Sesuaikan menit di pengaturan bila berbeda dengan jadwal resmi setempat.',
                    'Prayer times are calculated locally (offline) from your GPS coordinates or selected city. Adjust minutes in settings if they differ from your local official schedule.',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrayerGpsBanner extends ConsumerWidget {
  final PersonalSettings settings;
  final GpsState gpsState;

  const _PrayerGpsBanner({required this.settings, required this.gpsState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warnFg = dark ? const Color(0xFFFFDF8E) : const Color(0xFF5C3D00);
    final warnBg = Colors.amber.withValues(alpha: dark ? .18 : .14);

    if (!settings.useDeviceLocation) {
      return Card(
        child: ListTile(
          leading: Icon(MoeslimIcons.lokasi, color: scheme.primary),
          title: Text(
            context.tr('Gunakan Lokasi GPS Presisi', 'Use Precise GPS Location'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            context.tr(
              'Hitung jadwal salat otomatis sesuai koordinat GPS posisi Anda saat ini.',
              'Automatically calculate prayer times from your current GPS coordinates.',
            ),
          ),
          trailing: FilledButton(
            key: const Key('prayer-use-gps'),
            onPressed: () async {
              await ref.read(settingsProvider.notifier).save(settings.copyWith(useDeviceLocation: true));
              await ref.read(gpsControllerProvider.notifier).syncToPrayerSettings();
            },
            child: Text(context.tr('Pakai GPS', 'Use GPS')),
          ),
        ),
      );
    }

    return switch (gpsState) {
      GpsServiceDisabled() => Container(
        key: const Key('prayer-gps-disabled'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: warnBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade700.withValues(alpha: .45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_off_rounded, size: 20, color: warnFg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('GPS Perangkat Tidak Aktif', 'Device GPS Is Off'),
                    style: TextStyle(color: warnFg, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              settings.deviceLocation != null
                  ? context.tr(
                      'Jadwal sementara memakai posisi GPS terakhir. Aktifkan GPS agar jadwal diperbarui sesuai posisi sekarang.',
                      'Using your last known GPS position for now. Enable GPS to update prayer times for your current location.',
                    )
                  : context.tr(
                      'Aktifkan GPS perangkat agar jadwal salat dihitung dari koordinat lokasi Anda saat ini.',
                      'Enable device GPS to calculate prayer times from your current location.',
                    ),
              style: TextStyle(color: warnFg, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('prayer-enable-gps'),
                  onPressed: () => ref.read(gpsControllerProvider.notifier).openLocationSettings(),
                  icon: const Icon(MoeslimIcons.lokasi, size: 18),
                  label: Text(context.tr('Aktifkan GPS', 'Enable GPS')),
                ),
                OutlinedButton(
                  onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
                  child: Text(context.tr('Cek Ulang', 'Recheck')),
                ),
              ],
            ),
          ],
        ),
      ),
      GpsPermissionDenied() => Container(
        key: const Key('prayer-permission-denied'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: warnBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade700.withValues(alpha: .45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(
                'Izin lokasi diperlukan untuk memperbarui jadwal salat lewat GPS.',
                'Location permission is needed to update prayer times with GPS.',
              ),
              style: TextStyle(color: warnFg, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('prayer-request-permission'),
              onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
              icon: const Icon(MoeslimIcons.lokasi, size: 18),
              label: Text(context.tr('Izinkan Lokasi GPS', 'Allow GPS Location')),
            ),
          ],
        ),
      ),
      GpsPermissionDeniedForever() => Container(
        key: const Key('prayer-permission-forever'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: warnBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade700.withValues(alpha: .45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(
                'Izin lokasi ditolak permanen. Aktifkan izin lokasi di pengaturan aplikasi.',
                'Location permission was permanently denied. Enable location access in app settings.',
              ),
              style: TextStyle(color: warnFg, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => ref.read(gpsControllerProvider.notifier).openAppSettings(),
              icon: const Icon(MoeslimIcons.pengaturan, size: 18),
              label: Text(context.tr('Buka Pengaturan Aplikasi', 'Open App Settings')),
            ),
          ],
        ),
      ),
      GpsAcquiring() || GpsChecking() => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr(
                    'Memperbarui koordinat GPS untuk jadwal salat...',
                    'Updating GPS coordinates for prayer times...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      GpsError(:final message) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: warnBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade700.withValues(alpha: .45)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(message, style: TextStyle(color: warnFg, fontSize: 13))),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
              child: Text(context.tr('Coba Lagi', 'Try Again')),
            ),
          ],
        ),
      ),
      GpsReady(:final position) => Card(
        key: const Key('prayer-gps-active'),
        child: ListTile(
          dense: true,
          leading: Icon(MoeslimIcons.lokasi, color: scheme.primary),
          title: Text(
            context.tr(
              'GPS Aktif • ${formatGpsLocationLabel(position.coordinates)}',
              'GPS Active • ${localizeLocationLabel(formatGpsLocationLabel(position.coordinates), lang)}',
            ),
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${_formatCoord(position.latitude, isLatitude: true, lang: lang)}, '
            '${_formatCoord(position.longitude, isLatitude: false, lang: lang)} • ±${position.accuracyMeters.round()} m',
          ),
          trailing: IconButton(
            key: const Key('prayer-refresh-gps'),
            tooltip: context.tr('Perbarui lokasi GPS', 'Refresh GPS location'),
            icon: Icon(MoeslimIcons.refresh, color: scheme.primary),
            onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
          ),
        ),
      ),
    };
  }
}

class PrayerSettingsPage extends ConsumerStatefulWidget {
  const PrayerSettingsPage({super.key});

  @override
  ConsumerState<PrayerSettingsPage> createState() => _PrayerSettingsPageState();
}

class _PrayerSettingsPageState extends ConsumerState<PrayerSettingsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final s = ref.read(settingsProvider).value;
      if (s != null && s.useDeviceLocation) {
        unawaited(ref.read(gpsControllerProvider.notifier).syncToPrayerSettings());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final lang = context.lang;
    final notifier = ref.read(settingsProvider.notifier);
    final gpsState = ref.watch(gpsControllerProvider);
    final adzanState = ref.watch(adzanControllerProvider);
    ref.listen<String?>(
      adzanControllerProvider.select((st) => st.lastError),
      (_, err) {
        if (err != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        }
      },
    );
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Pengaturan Jadwal', 'Prayer Settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    key: const Key('use-gps-switch'),
                    secondary: Icon(MoeslimIcons.lokasi, color: scheme.primary),
                    title: Text(
                      context.tr('Gunakan Lokasi GPS Presisi', 'Use Precise GPS Location'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      s.isUsingGpsLocation && s.deviceLocation != null
                          ? '${localizeLocationLabel(s.deviceLocation!.label, lang)} '
                              '(${_formatCoord(s.deviceLocation!.latitude, isLatitude: true, lang: lang)}, '
                              '${_formatCoord(s.deviceLocation!.longitude, isLatitude: false, lang: lang)})'
                          : (s.useDeviceLocation
                              ? context.tr(
                                  'Menunggu status GPS aktif dan izin lokasi.',
                                  'Waiting for GPS and location permission.',
                                )
                              : context.tr(
                                  'Aktifkan untuk menghitung jadwal salat sesuai koordinat GPS aktual.',
                                  'Enable to calculate prayer times from your live GPS coordinates.',
                                )),
                    ),
                    value: s.useDeviceLocation,
                    onChanged: (enabled) async {
                      await notifier.save(s.copyWith(useDeviceLocation: enabled));
                      if (enabled) {
                        await ref.read(gpsControllerProvider.notifier).syncToPrayerSettings();
                      }
                    },
                  ),
                  if (s.useDeviceLocation)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (gpsState is GpsServiceDisabled)
                            FilledButton.icon(
                              key: const Key('settings-enable-gps'),
                              onPressed: () => ref.read(gpsControllerProvider.notifier).openLocationSettings(),
                              icon: const Icon(MoeslimIcons.lokasi, size: 18),
                              label: Text(context.tr('Aktifkan GPS', 'Enable GPS')),
                            ),
                          if (gpsState is GpsPermissionDenied)
                            FilledButton.icon(
                              key: const Key('settings-request-permission'),
                              onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
                              icon: const Icon(MoeslimIcons.lokasi, size: 18),
                              label: Text(context.tr('Izinkan Lokasi', 'Allow Location')),
                            ),
                          if (gpsState is GpsPermissionDeniedForever)
                            FilledButton.icon(
                              key: const Key('settings-open-app-settings'),
                              onPressed: () => ref.read(gpsControllerProvider.notifier).openAppSettings(),
                              icon: const Icon(MoeslimIcons.pengaturan, size: 18),
                              label: Text(context.tr('Pengaturan Aplikasi', 'App Settings')),
                            ),
                          OutlinedButton.icon(
                            key: const Key('settings-refresh-gps'),
                            onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
                            icon: const Icon(MoeslimIcons.refresh, size: 18),
                            label: Text(context.tr('Perbarui GPS', 'Refresh GPS')),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            key: const Key('adzan-settings-card'),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    key: const Key('adzan-master-switch'),
                    secondary: Icon(
                      s.notificationsEnabled ? MoeslimIcons.adzan : MoeslimIcons.bisukan,
                      color: s.notificationsEnabled ? scheme.primary : scheme.outline,
                    ),
                    title: Text(
                      context.tr('Alarm Suara Adzan Otomatis', 'Automatic Adhan Alerts'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      s.notificationsEnabled
                          ? context.tr(
                              'Aktif (${s.activeAdzanCount}/5 waktu salat) mengikuti jadwal ${s.effectiveLocationName}.',
                              'Active (${s.activeAdzanCount}/5 prayers) for ${localizeLocationLabel(s.effectiveLocationName, lang)}.',
                            )
                          : context.tr(
                              'Nonaktif. Nyalakan agar alarm adzan berbunyi saat masuk waktu salat.',
                              'Off. Enable to play the adhan when each prayer time arrives.',
                            ),
                    ),
                    value: s.notificationsEnabled,
                    onChanged: (enabled) async {
                      await notifier.save(s.copyWith(notificationsEnabled: enabled));
                      if (enabled) {
                        await ref.read(adzanControllerProvider.notifier).requestNotificationPermission();
                      } else {
                        await ref.read(adzanControllerProvider.notifier).stopAdzan();
                      }
                    },
                  ),
                  if (s.notificationsEnabled && !adzanState.notificationsGranted)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        key: const Key('adzan-notif-permission-warning'),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade700.withValues(alpha: .45)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(
                                'Izin notifikasi belum aktif. Aktifkan izin agar pop-up alarm dengan tombol Matikan Adzan tampil saat waktu salat tiba.',
                                'Notification permission is off. Allow notifications so the pop-up alert with Stop Adhan appears at prayer time.',
                              ),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.icon(
                                  key: const Key('request-adzan-notif-perm'),
                                  onPressed: () =>
                                      ref.read(adzanControllerProvider.notifier).requestNotificationPermission(),
                                  icon: const Icon(MoeslimIcons.notifikasi, size: 18),
                                  label: Text(context.tr('Izinkan Notifikasi', 'Allow Notifications')),
                                ),
                                OutlinedButton(
                                  key: const Key('open-adzan-notif-settings'),
                                  onPressed: () =>
                                      ref.read(adzanControllerProvider.notifier).openNotificationSettings(),
                                  child: Text(context.tr('Pengaturan Notifikasi', 'Notification Settings')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: OutlinedButton.icon(
                      key: const Key('test-adzan-alarm'),
                      onPressed: () => ref.read(adzanControllerProvider.notifier).triggerAlarm(Prayer.dhuhr),
                      icon: const Icon(MoeslimIcons.notifikasi, size: 18),
                      label: Text(context.tr('Uji Pop-up & Suara Alarm', 'Test Alarm Pop-up & Sound')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      context.tr('Waktu Salat yang Dikumandangkan Adzan', 'Prayers with Adhan Alert'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in Prayer.values)
                          FilterChip(
                            key: Key('settings-adzan-${p.name}'),
                            label: Text(context.prayerLabel(p)),
                            selected: s.isAdzanActiveFor(p),
                            onSelected: (enabled) => notifier.save(s.setPrayerAdzan(p, enabled)),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Text(
                      context.tr('Pilihan Muadzin', 'Muadzin Voice'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (adzanState.previewingMuadzinId != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Container(
                        key: const Key('preview-playing-banner'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(MoeslimIcons.adzan, size: 18, color: scheme.onPrimaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr(
                                  'Memutar adzan: ${adzanMuadzins.where((m) => m.id == adzanState.previewingMuadzinId).firstOrNull?.name ?? ''}',
                                  'Playing adhan: ${adzanMuadzins.where((m) => m.id == adzanState.previewingMuadzinId).firstOrNull?.name ?? ''}',
                                ),
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref.read(adzanControllerProvider.notifier).stopAdzan(),
                              child: Text(context.tr('Hentikan', 'Stop')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final m in adzanMuadzins)
                    ListTile(
                      key: Key('muadzin-option-${m.id}'),
                      dense: true,
                      leading: Icon(
                        m.id == s.muadzin.id ? MoeslimIcons.berhasil : Icons.radio_button_unchecked,
                        color: m.id == s.muadzin.id ? scheme.primary : scheme.outline,
                      ),
                      title: Text(
                        m.name,
                        style: TextStyle(
                          fontWeight: m.id == s.muadzin.id ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text('${m.originFor(lang)} • ${m.styleFor(lang)}'),
                      trailing: IconButton(
                        key: Key('preview-muadzin-${m.id}'),
                        tooltip: adzanState.previewingMuadzinId == m.id
                            ? context.tr('Hentikan contoh suara ${m.name}', 'Stop preview for ${m.name}')
                            : context.tr('Dengarkan suara ${m.name}', 'Preview ${m.name}'),
                        icon: Icon(
                          adzanState.previewingMuadzinId == m.id ? MoeslimIcons.pause : MoeslimIcons.play,
                          color: scheme.primary,
                        ),
                        onPressed: () => ref.read(adzanControllerProvider.notifier).togglePreviewMuadzin(m),
                      ),
                      onTap: () => notifier.save(s.copyWith(muadzinId: m.id)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: s.location.name,
            decoration: InputDecoration(
              labelText: s.useDeviceLocation
                  ? context.tr('Kota cadangan (bila memilih manual)', 'Fallback city (if choosing manually)')
                  : context.tr('Kota', 'City'),
            ),
            items: [
              for (final c in indonesianCities) DropdownMenuItem(value: c.name, child: Text('${c.name} (${c.zone})')),
            ],
            onChanged: (v) {
              if (v == null) return;
              notifier.save(
                s.copyWith(
                  location: indonesianCities.firstWhere((c) => c.name == v),
                  useDeviceLocation: false,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CalculationMethod>(
            initialValue: s.method,
            decoration: InputDecoration(labelText: context.tr('Metode perhitungan', 'Calculation method')),
            items: [
              for (final m in CalculationMethod.values) DropdownMenuItem(value: m, child: Text(context.methodLabel(m))),
            ],
            onChanged: (v) => notifier.save(s.copyWith(method: v)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AsrMadhab>(
            initialValue: s.madhab,
            decoration: InputDecoration(labelText: context.tr('Waktu Ashar', 'Asr juristic method')),
            items: [
              DropdownMenuItem(
                value: AsrMadhab.shafii,
                child: Text(context.tr("Syafi'i, Maliki, Hanbali", "Shafi'i, Maliki, Hanbali")),
              ),
              const DropdownMenuItem(value: AsrMadhab.hanafi, child: Text('Hanafi')),
            ],
            onChanged: (v) => notifier.save(s.copyWith(madhab: v)),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('Penyesuaian menit', 'Minute adjustments'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final p in Prayer.values)
            Row(
              children: [
                Expanded(child: Text(context.prayerLabel(p))),
                IconButton(
                  tooltip: context.tr('Kurangi ${context.prayerLabel(p)}', 'Decrease ${context.prayerLabel(p)}'),
                  icon: const Icon(MoeslimIcons.kurangi),
                  onPressed: () =>
                      notifier.save(s.copyWith(adjustments: {...s.adjustments, p: (s.adjustments[p] ?? 0) - 1})),
                ),
                SizedBox(width: 40, child: Text('${s.adjustments[p] ?? 0}', textAlign: TextAlign.center)),
                IconButton(
                  tooltip: context.tr('Tambah ${context.prayerLabel(p)}', 'Increase ${context.prayerLabel(p)}'),
                  icon: const Icon(MoeslimIcons.tambah),
                  onPressed: () =>
                      notifier.save(s.copyWith(adjustments: {...s.adjustments, p: (s.adjustments[p] ?? 0) + 1})),
                ),
              ],
            ),
          const Divider(),
          Row(
            children: [
              Expanded(child: Text(context.tr('Koreksi tanggal Hijriah (hari)', 'Hijri date adjustment (days)'))),
              IconButton(
                icon: const Icon(MoeslimIcons.kurangi),
                onPressed: () => notifier.save(s.copyWith(hijriOffset: (s.hijriOffset - 1).clamp(-2, 2))),
              ),
              Text('${s.hijriOffset}'),
              IconButton(
                icon: const Icon(MoeslimIcons.tambah),
                onPressed: () => notifier.save(s.copyWith(hijriOffset: (s.hijriOffset + 1).clamp(-2, 2))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
