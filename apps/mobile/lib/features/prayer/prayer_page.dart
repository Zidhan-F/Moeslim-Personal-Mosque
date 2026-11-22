import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/adzan_service.dart';
import '../../core/format.dart';
import '../../core/location_service.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../../ui/prayer_sky_icon.dart';
import '../ibadah/qibla_page.dart' show coordinateId;

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
      builder: (_) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Subuh')),
            DataColumn(label: Text('Dzuhur')),
            DataColumn(label: Text('Ashar')),
            DataColumn(label: Text('Maghrib')),
            DataColumn(label: Text('Isya')),
          ],
          rows: [
            for (final d in days)
              DataRow(
                cells: [
                  DataCell(Text(shortDate(d))),
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
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final goldInk = dark ? BrandColors.gold : BrandColors.goldText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Salat'),
        centerTitle: true,
        actions: [
          if (settings.value != null && status != null)
            IconButton(
              key: const Key('weekly-schedule'),
              tooltip: 'Jadwal 7 hari',
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
          final rows = <(String, DateTime, Prayer?)>[
            ('Subuh', status.today.fajr, Prayer.fajr),
            ('Syuruq', status.today.sunrise, null),
            ('Dzuhur', status.today.dhuhr, Prayer.dhuhr),
            ('Ashar', status.today.asr, Prayer.asr),
            ('Maghrib', status.today.maghrib, Prayer.maghrib),
            ('Isya', status.today.isha, Prayer.isha),
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ArchHeader(
                child: Column(
                  children: [
                    Text(longDate(status.now), style: t.titleMedium),
                    Text(hijri.toString(), style: t.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MoeslimIcons.lokasi, size: 16, color: scheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            s.effectiveLocationSubtitle,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (s.isUsingGpsLocation && s.deviceLocation != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${coordinateId(s.deviceLocation!.latitude, isLatitude: true)}, '
                        '${coordinateId(s.deviceLocation!.longitude, isLatitude: false)}'
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
                            const Text('Menuju Salat'),
                            Text(
                              status.nextPrayer.label,
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
              const SectionHeader('Jadwal Salat Hari Ini'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      for (final (label, time, p) in rows)
                        Container(
                          key: Key('row-$label'),
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: p != null && p == status.nextPrayer ? scheme.primary.withValues(alpha: .12) : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: label == 'Syuruq'
                                ? Icon(MoeslimIcons.matahari, color: goldInk)
                                : PrayerSkyIcon(label, color: goldInk),
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
                                        ? 'Alarm adzan $label aktif (ketuk untuk matikan)'
                                        : 'Alarm adzan $label mati (ketuk untuk aktifkan)',
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
                                          semanticLabel: 'sudah lewat',
                                        )
                                      : (p != null && p == status.nextPrayer
                                            ? Icon(
                                                MoeslimIcons.play,
                                                color: scheme.primary,
                                                size: 20,
                                                semanticLabel: 'berikutnya',
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
                      title: const Text('Alarm & Suara Adzan', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        s.activeAdzanCount > 0
                            ? 'Aktif (${s.activeAdzanCount}/5 waktu) • ${s.muadzin.name}'
                            : 'Alarm adzan nonaktif • Ketuk untuk mengatur',
                      ),
                      trailing: OutlinedButton.icon(
                        key: const Key('prayer-preview-adzan'),
                        onPressed: () =>
                            ref.read(adzanControllerProvider.notifier).togglePreviewMuadzin(s.muadzin),
                        icon: Icon(
                          adzanState.previewingMuadzinId == s.muadzin.id ? MoeslimIcons.pause : MoeslimIcons.suara,
                          size: 18,
                        ),
                        label: Text(adzanState.previewingMuadzinId == s.muadzin.id ? 'Berhenti' : 'Uji Suara'),
                      ),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calculate_outlined),
                      title: const Text('Metode Perhitungan'),
                      subtitle: Text(s.method.label),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                    ListTile(
                      leading: const Icon(MoeslimIcons.lokasi),
                      title: const Text('Lokasi'),
                      subtitle: Text(s.effectiveLocationSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Jadwal dihitung secara lokal (offline) dari koordinat GPS atau kota pilihan. Sesuaikan menit di pengaturan bila berbeda dengan jadwal resmi setempat.',
                  style: TextStyle(fontSize: 12),
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
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warnFg = dark ? const Color(0xFFFFDF8E) : const Color(0xFF5C3D00);
    final warnBg = Colors.amber.withValues(alpha: dark ? .18 : .14);

    if (!settings.useDeviceLocation) {
      return Card(
        child: ListTile(
          leading: Icon(MoeslimIcons.lokasi, color: scheme.primary),
          title: const Text('Gunakan Lokasi GPS Presisi', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Hitung jadwal salat otomatis sesuai koordinat GPS posisi Anda saat ini.'),
          trailing: FilledButton(
            key: const Key('prayer-use-gps'),
            onPressed: () async {
              await ref.read(settingsProvider.notifier).save(settings.copyWith(useDeviceLocation: true));
              await ref.read(gpsControllerProvider.notifier).syncToPrayerSettings();
            },
            child: const Text('Pakai GPS'),
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
                    'GPS Perangkat Tidak Aktif',
                    style: TextStyle(color: warnFg, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              settings.deviceLocation != null
                  ? 'Jadwal sementara memakai posisi GPS terakhir. Aktifkan GPS agar jadwal diperbarui sesuai posisi sekarang.'
                  : 'Aktifkan GPS perangkat agar jadwal salat dihitung dari koordinat lokasi Anda saat ini.',
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
                  label: const Text('Aktifkan GPS'),
                ),
                OutlinedButton(
                  onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
                  child: const Text('Cek Ulang'),
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
              'Izin lokasi diperlukan untuk memperbarui jadwal salat lewat GPS.',
              style: TextStyle(color: warnFg, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('prayer-request-permission'),
              onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
              icon: const Icon(MoeslimIcons.lokasi, size: 18),
              label: const Text('Izinkan Lokasi GPS'),
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
              'Izin lokasi ditolak permanen. Aktifkan izin lokasi di pengaturan aplikasi.',
              style: TextStyle(color: warnFg, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => ref.read(gpsControllerProvider.notifier).openAppSettings(),
              icon: const Icon(MoeslimIcons.pengaturan, size: 18),
              label: const Text('Buka Pengaturan Aplikasi'),
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
              const Expanded(child: Text('Memperbarui koordinat GPS untuk jadwal salat...')),
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
              child: const Text('Coba Lagi'),
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
            'GPS Aktif • ${formatGpsLocationLabel(position.coordinates)}',
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${coordinateId(position.latitude, isLatitude: true)}, '
            '${coordinateId(position.longitude, isLatitude: false)} • ±${position.accuracyMeters.round()} m',
          ),
          trailing: IconButton(
            key: const Key('prayer-refresh-gps'),
            tooltip: 'Perbarui lokasi GPS',
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
      appBar: AppBar(title: const Text('Pengaturan Jadwal')),
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
                    title: const Text('Gunakan Lokasi GPS Presisi', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      s.isUsingGpsLocation && s.deviceLocation != null
                          ? '${s.deviceLocation!.label} (${coordinateId(s.deviceLocation!.latitude, isLatitude: true)}, '
                              '${coordinateId(s.deviceLocation!.longitude, isLatitude: false)})'
                          : (s.useDeviceLocation
                              ? 'Menunggu status GPS aktif dan izin lokasi.'
                              : 'Aktifkan untuk menghitung jadwal salat sesuai koordinat GPS aktual.'),
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
                              label: const Text('Aktifkan GPS'),
                            ),
                          if (gpsState is GpsPermissionDenied)
                            FilledButton.icon(
                              key: const Key('settings-request-permission'),
                              onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
                              icon: const Icon(MoeslimIcons.lokasi, size: 18),
                              label: const Text('Izinkan Lokasi'),
                            ),
                          if (gpsState is GpsPermissionDeniedForever)
                            FilledButton.icon(
                              key: const Key('settings-open-app-settings'),
                              onPressed: () => ref.read(gpsControllerProvider.notifier).openAppSettings(),
                              icon: const Icon(MoeslimIcons.pengaturan, size: 18),
                              label: const Text('Pengaturan Aplikasi'),
                            ),
                          OutlinedButton.icon(
                            key: const Key('settings-refresh-gps'),
                            onPressed: () => ref.read(gpsControllerProvider.notifier).syncToPrayerSettings(),
                            icon: const Icon(MoeslimIcons.refresh, size: 18),
                            label: const Text('Perbarui GPS'),
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
                    title: const Text('Alarm Suara Adzan Otomatis', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      s.notificationsEnabled
                          ? 'Aktif (${s.activeAdzanCount}/5 waktu salat) mengikuti jadwal ${s.effectiveLocationName}.'
                          : 'Nonaktif. Nyalakan agar alarm adzan berbunyi saat masuk waktu salat.',
                    ),
                    value: s.notificationsEnabled,
                    onChanged: (enabled) async {
                      await notifier.save(s.copyWith(notificationsEnabled: enabled));
                      if (!enabled) {
                        await ref.read(adzanControllerProvider.notifier).stopAdzan();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      'Waktu Salat yang Dikumandangkan Adzan',
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
                            label: Text(p.label),
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
                      'Pilihan Muadzin',
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
                                'Memutar adzan: ${adzanMuadzins.where((m) => m.id == adzanState.previewingMuadzinId).firstOrNull?.name ?? ''}',
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref.read(adzanControllerProvider.notifier).stopAdzan(),
                              child: const Text('Hentikan'),
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
                      subtitle: Text('${m.origin} • ${m.style}'),
                      trailing: IconButton(
                        key: Key('preview-muadzin-${m.id}'),
                        tooltip: adzanState.previewingMuadzinId == m.id
                            ? 'Hentikan contoh suara ${m.name}'
                            : 'Dengarkan suara ${m.name}',
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
              labelText: s.useDeviceLocation ? 'Kota cadangan (bila memilih manual)' : 'Kota',
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
            decoration: const InputDecoration(labelText: 'Metode perhitungan'),
            items: [for (final m in CalculationMethod.values) DropdownMenuItem(value: m, child: Text(m.label))],
            onChanged: (v) => notifier.save(s.copyWith(method: v)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AsrMadhab>(
            initialValue: s.madhab,
            decoration: const InputDecoration(labelText: 'Waktu Ashar'),
            items: const [
              DropdownMenuItem(value: AsrMadhab.shafii, child: Text("Syafi'i, Maliki, Hanbali")),
              DropdownMenuItem(value: AsrMadhab.hanafi, child: Text('Hanafi')),
            ],
            onChanged: (v) => notifier.save(s.copyWith(madhab: v)),
          ),
          const SizedBox(height: 16),
          Text('Penyesuaian menit', style: Theme.of(context).textTheme.titleMedium),
          for (final p in Prayer.values)
            Row(
              children: [
                Expanded(child: Text(p.label)),
                IconButton(
                  tooltip: 'Kurangi ${p.label}',
                  icon: const Icon(MoeslimIcons.kurangi),
                  onPressed: () =>
                      notifier.save(s.copyWith(adjustments: {...s.adjustments, p: (s.adjustments[p] ?? 0) - 1})),
                ),
                SizedBox(width: 40, child: Text('${s.adjustments[p] ?? 0}', textAlign: TextAlign.center)),
                IconButton(
                  tooltip: 'Tambah ${p.label}',
                  icon: const Icon(MoeslimIcons.tambah),
                  onPressed: () =>
                      notifier.save(s.copyWith(adjustments: {...s.adjustments, p: (s.adjustments[p] ?? 0) + 1})),
                ),
              ],
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: Text('Koreksi tanggal Hijriah (hari)')),
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
