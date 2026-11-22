import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class AstronomyQiblaFiqihPage extends ConsumerStatefulWidget {
  final int initialTab;
  const AstronomyQiblaFiqihPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<AstronomyQiblaFiqihPage> createState() => _AstronomyQiblaFiqihPageState();
}

class _AstronomyQiblaFiqihPageState extends ConsumerState<AstronomyQiblaFiqihPage> {
  late int _tab;
  City _destCity = indonesianCities.firstWhere((c) => c.name == 'Bandung', orElse: () => indonesianCities.last);
  Set<String> _fridayChecks = {};

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    _loadFridayChecks();
  }

  Future<void> _loadFridayChecks() async {
    final checks = await ref.read(fridaySunnahRepoProvider).checkedForDate(_today);
    if (mounted) setState(() => _fridayChecks = checks);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? PersonalSettings.defaults;
    final status = ref.watch(prayerStatusProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Salat, Kiblat & Astronomi'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Bayangan', 'Peta Kiblat', 'Safar', 'Dhuha & Tahajud', 'Sunnah Jumat'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildSolarShadowTab(context, settings, status),
              1 => _buildMapQiblaTab(context, settings),
              2 => _buildSafarCalculatorTab(context, settings),
              3 => _buildExtendedPrayerWindowsTab(context, settings, status),
              _ => _buildFridaySunnahTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 26. Kiblat Bayangan Matahari (Istiwa & Rashdul Qiblah)
  Widget _buildSolarShadowTab(BuildContext context, PersonalSettings settings, PrayerStatus? status) {
    final now = status?.now ?? DateTime.now();
    final solar = computeSolarShadowQibla(
      coords: settings.effectiveCoordinates,
      localTime: now,
      utcOffsetHours: settings.effectiveUtcOffset,
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ArchHeader(
          child: Column(
            children: [
              Text('Kiblat Bayangan Matahari (Bebas Gangguan Logam)', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'Arah Kiblat: ${solar.qiblaBearingDeg.toStringAsFixed(1)}° · Bayangan Saat Ini: ${solar.shadowAzimuthDeg.toStringAsFixed(1)}°',
                key: const Key('solar-qibla-summary'),
                style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text('Tinggi Matahari (Altitude): ${solar.sunAltitudeDeg.toStringAsFixed(1)}° di ${settings.effectiveLocationName}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Panduan Praktis Menentukan Kiblat dengan Tongkat Tegak', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(solar.alignmentInstruction, style: t.bodyLarge),
              ],
            ),
          ),
        ),
        const SectionHeader('Hari Istiwa A\'zham (Rashdul Qiblah Global)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dua Momen Matahari Tepat di Atas Ka\'bah Setiap Tahun:',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '• 27–28 Mei pukul 16:18 WIB (17:18 WITA / 18:18 WIT)\n'
                  '• 15–16 Juli pukul 16:27 WIB (17:27 WITA / 18:27 WIT)\n\n'
                  'Pada menit tersebut, bayangan setiap benda tegak lurus di seluruh Indonesia yang terkena sinar matahari pasti menghadap lurus ke arah Ka\'bah.',
                  style: t.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 27. Kiblat Peta (Garis Lurus ke Ka'bah di Atas Bangunan)
  Widget _buildMapQiblaTab(BuildContext context, PersonalSettings settings) {
    final coords = settings.effectiveCoordinates;
    final bearing = qiblaBearing(coords);
    final distKm = distanceToKaabaKm(coords);
    final offsetFromWest = bearing - 270.0;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Garis Vektor Geodetik ke Ka\'bah di Atas Dinding Bangunan',
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  key: const Key('qibla-building-map-canvas'),
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: _BuildingQiblaGridPainter(
                      qiblaDegrees: bearing,
                      primary: scheme.primary,
                      outline: scheme.outlineVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sudut Kiblat: ${bearing.toStringAsFixed(1)}° dari Utara Sejati',
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patokan Dinding Bangunan: Serong +${offsetFromWest.toStringAsFixed(1)}° ke arah Utara dari garis lurus menghadap Barat (270°).',
                  textAlign: TextAlign.center,
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Jarak Lurus ke Ka\'bah (Makkah): ${distKm.round()} km',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 28. Kalkulator Safar & Rukhshah (Jama' / Qashar)
  Widget _buildSafarCalculatorTab(BuildContext context, PersonalSettings settings) {
    final eval = evaluateSafarRukhshah(
      originName: settings.effectiveLocationName,
      originCoords: settings.effectiveCoordinates,
      destinationName: _destCity.name,
      destinationCoords: _destCity.coordinates,
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kota / Titik Asal: ${settings.effectiveLocationName}', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                DropdownButtonFormField<City>(
                  key: const Key('safar-dest-dropdown'),
                  initialValue: _destCity,
                  decoration: const InputDecoration(labelText: 'Pilih Kota Tujuan Safar'),
                  items: [
                    for (final c in indonesianCities)
                      DropdownMenuItem(value: c, child: Text('${c.name}, ${c.province}')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _destCity = v);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      eval.eligibleForQasharAndJama ? MoeslimIcons.berhasil : MoeslimIcons.info,
                      color: eval.eligibleForQasharAndJama ? scheme.primary : scheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        eval.eligibleForQasharAndJama
                            ? 'Memenuhi Syarat Rukhshah Jama\' & Qashar'
                            : 'Belum Mencapai Jarak Masafatul Qashr (81 km)',
                        key: const Key('safar-eligibility-status'),
                        style: t.titleMedium?.copyWith(
                          color: eval.eligibleForQasharAndJama ? scheme.primary : null,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Jarak Udara: ${eval.straightDistanceKm.toStringAsFixed(1)} km · Estimasi Jalur Darat: ±${eval.estimatedRoadDistanceKm.toStringAsFixed(1)} km',
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(eval.summary, style: t.bodyMedium),
                const Divider(height: 20),
                for (final r in eval.prayerRules)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $r', style: t.bodySmall),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 29. Penanda Waktu Dhuha, Sepertiga Malam & Waktu Terlarang Salat
  Widget _buildExtendedPrayerWindowsTab(BuildContext context, PersonalSettings settings, PrayerStatus? status) {
    final baseDate = status?.now ?? DateTime.now();
    final todayTimes = status?.today ?? settings.timesFor(baseDate);
    final tomorrowTimes = settings.timesFor(baseDate.add(const Duration(days: 1)));
    final ext = computeExtendedPrayerWindows(todayTimes, tomorrowTimes);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader('Waktu Salat Sunnah Utama Hari Ini'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(MoeslimIcons.matahari, color: scheme.primary),
                title: const Text('Waktu Salat Sunnah Dhuha', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Waktu utama (Awwabin): sekitar ${hhmm(ext.dhuhaOptimal)}'),
                trailing: Text(
                  '${hhmm(ext.dhuhaStart)} – ${hhmm(ext.dhuhaEnd)}',
                  key: const Key('extended-dhuha-window'),
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(MoeslimIcons.bulan, color: scheme.primary),
                title: const Text('Sepertiga Malam Terakhir (Tahajud Utama)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Pertengahan malam (Nishful Lail): ${hhmm(ext.midnightNishfulLail)}'),
                trailing: Text(
                  '${hhmm(ext.lastThirdNightStart)} – ${hhmm(ext.lastThirdNightEnd)}',
                  key: const Key('extended-tahajud-window'),
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('3 Waktu Terlarang Salat Sunnah Mutlak'),
        for (final (title, start, end, desc) in ext.forbiddenWindows)
          Card(
            child: ListTile(
              leading: Icon(MoeslimIcons.peringatan, color: scheme.error),
              title: Text('$title (${hhmm(start)} – ${hhmm(end)})', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(desc),
            ),
          ),
      ],
    );
  }

  // 30. Panduan & Checklist Sunnah Hari Jumat
  Widget _buildFridaySunnahTab(BuildContext context) {
    final ratio = fridaySunnahCatalog.isEmpty ? 0.0 : _fridayChecks.length / fridaySunnahCatalog.length;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amalan Sunnah Hari Jumat', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${_fridayChecks.length} / ${fridaySunnahCatalog.length} selesai',
                      key: const Key('friday-sunnah-progress'),
                      style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final item in fridaySunnahCatalog)
          Card(
            child: CheckboxListTile(
              key: Key('friday-check-${item.id}'),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item.dalilAndVirtue),
              value: _fridayChecks.contains(item.id),
              onChanged: (_) async {
                final next = await ref.read(fridaySunnahRepoProvider).toggleItem(_today, item.id);
                setState(() => _fridayChecks = next);
              },
            ),
          ),
      ],
    );
  }
}

class _BuildingQiblaGridPainter extends CustomPainter {
  final double qiblaDegrees;
  final Color primary;
  final Color outline;

  const _BuildingQiblaGridPainter({
    required this.qiblaDegrees,
    required this.primary,
    required this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final gridPaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Building square outline (aligned to N-S-E-W walls)
    final houseRect = Rect.fromCenter(center: center, width: radius * 1.35, height: radius * 1.35);
    canvas.drawRect(houseRect, gridPaint);
    canvas.drawCircle(center, radius, gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), gridPaint);
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), gridPaint);

    // Qibla vector ray (0 deg = North / top, clockwise)
    final rad = (qiblaDegrees - 90.0) * math.pi / 180.0;
    final target = Offset(
      center.dx + radius * math.cos(rad),
      center.dy + radius * math.sin(rad),
    );
    final qiblaPaint = Paint()
      ..color = primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, target, qiblaPaint);
    canvas.drawCircle(target, 6, Paint()..color = BrandColors.gold);
  }

  @override
  bool shouldRepaint(covariant _BuildingQiblaGridPainter oldDelegate) =>
      oldDelegate.qiblaDegrees != qiblaDegrees || oldDelegate.primary != primary;
}
