import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
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

  String _solarInstruction(BuildContext context, SolarQiblaSnapshot solar) {
    if (!context.isEn) return solar.alignmentInstruction;
    if (!solar.isSunAboveHorizon) {
      return 'The sun is currently below or too close to the horizon. Use the sun shadow method when the sun is shining clearly, or use the building angle guide in the Qibla Map tab.';
    }
    final delta = solar.angleFromShadowToQiblaDeg;
    if (delta.abs() <= 3.0) {
      return 'The shadow of a vertical object is currently ALIGNED directly with the Qibla! Align your prayer mat along the shadow line.';
    }
    if (delta > 0) {
      return 'Place a straight vertical stick under sunlight. From the direction of its shadow (${solar.shadowAzimuthDeg.toStringAsFixed(1)}°), rotate ${delta.abs().toStringAsFixed(1)}° clockwise (to the right) to face the Qibla (${solar.qiblaBearingDeg.toStringAsFixed(1)}°).';
    }
    return 'Place a straight vertical stick under sunlight. From the direction of its shadow (${solar.shadowAzimuthDeg.toStringAsFixed(1)}°), rotate ${delta.abs().toStringAsFixed(1)}° counter-clockwise (to the left) to face the Qibla (${solar.qiblaBearingDeg.toStringAsFixed(1)}°).';
  }

  String _safarSummary(BuildContext context, SafarRukhshahEvaluation eval) {
    if (!context.isEn) return eval.summary;
    final roadStr = eval.estimatedRoadDistanceKm.toStringAsFixed(1);
    return eval.eligibleForQasharAndJama
        ? 'Estimated travel distance (~$roadStr km) exceeds the Masafat al-Qasr threshold (81 km). You are eligible for the travel concession (rukhsah) to shorten (Qasr) and combine (Jama\') prayers after leaving your home city boundary.'
        : 'Estimated travel distance (~$roadStr km) has not reached the Masafat al-Qasr threshold (81 km). Obligatory prayers remain full (4 rakaat) at their regular times.';
  }

  List<String> _safarRules(BuildContext context, SafarRukhshahEvaluation eval) {
    if (!context.isEn) return eval.prayerRules;
    if (eval.eligibleForQasharAndJama) {
      return const [
        'Dhuhr (4 -> 2 rakaat) & Asr (4 -> 2 rakaat): may be shortened (Qasr) and combined (Jama\' Taqdim during Dhuhr or Takhir during Asr).',
        'Maghrib (stays 3 rakaat) & Isha (4 -> 2 rakaat): may be combined (Jama\' Taqdim during Maghrib or Takhir during Isha).',
        'Fajr (stays 2 rakaat): performed at its own time (neither combined nor shortened).',
        'Stay Limit: The concession applies while traveling and up to 4 full days (excluding arrival and departure days) at the destination in the Shafi\'i school.',
      ];
    }
    return const [
      'All obligatory prayers (Fajr 2, Dhuhr 4, Asr 4, Maghrib 3, Isha 4) are performed in full at their appointed times.',
    ];
  }

  ({String title, String desc}) _forbiddenWindowText(BuildContext context, int index, String titleId, String descId) {
    if (!context.isEn) return (title: titleId, desc: descId);
    return switch (index) {
      0 => (
          title: '1. After Fajr Until Sunrise Rises',
          desc: 'Unspecified voluntary prayers are prohibited after Fajr prayer until the sun rises a spear\'s height above the horizon (~15 minutes after sunrise).',
        ),
      1 => (
          title: '2. Solar Zenith (Istiwa)',
          desc: 'Just before the sun passes its zenith (~10 minutes before Dhuhr), except on Fridays.',
        ),
      _ => (
          title: '3. After Asr Until Sunset',
          desc: 'After performing Asr prayer until the sun has completely set at Maghrib.',
        ),
    };
  }

  ({String title, String dalil}) _fridaySunnahText(BuildContext context, FridaySunnahItem item) {
    if (!context.isEn) return (title: item.title, dalil: item.dalilAndVirtue);
    return switch (item.id) {
      'mandi_jumat' => (
          title: 'Friday Ritual Bath (Ghusl)',
          dalil: 'Sahih al-Bukhari no. 877: "Taking a bath on Friday is strongly emphasized for every adult Muslim."',
        ),
      'siwak_wewangian' => (
          title: 'Use Siwak, Trim Nails & Wear Fragrance',
          dalil: 'Sahih al-Bukhari no. 880: Recommended to use siwak and apply your best fragrance before heading to the mosque.',
        ),
      'pakaian_terbaik' => (
          title: 'Wear Your Best Attire (Preferably White)',
          dalil: 'Sunan Abi Dawud no. 343: Wearing clean and fine garments to honor the weekly celebration.',
        ),
      'baca_alkahfi' => (
          title: 'Recite Surah Al-Kahfi',
          dalil: 'Al-Hakim II/399 (Sahih): Illuminated with a light of blessings between two Fridays.',
        ),
      'perbanyak_shalawat' => (
          title: 'Send Abundant Salawat Upon Prophet Muhammad (PBUH)',
          dalil: 'Sunan Abi Dawud no. 1047: "Send abundant blessings upon me on Friday and the night before Friday."',
        ),
      'berangkat_awal' => (
          title: 'Arrive Early at the Mosque & Pray Tahiyatul Masjid',
          dalil: 'Sahih al-Bukhari no. 881: Arriving in the first hour carries the reward of offering a camel in charity.',
        ),
      'simak_khutbah' => (
          title: 'Listen Attentively to the Friday Khutbah',
          dalil: 'Sahih al-Bukhari no. 934: Listening quietly to the sermon is a means of forgiveness between two Fridays.',
        ),
      'doa_ashar_jumat' => (
          title: 'Make Dua During the Last Hour of Friday (After Asr)',
          dalil: 'Sunan Abi Dawud no. 1048: A blessed hour of answered prayers after Asr until Maghrib.',
        ),
      _ => (title: item.title, dalil: item.dalilAndVirtue),
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? PersonalSettings.defaults;
    final status = ref.watch(prayerStatusProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Salat, Kiblat & Astronomi', 'Prayer, Qibla & Astronomy')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Bayangan', 'Sun Shadow'),
                context.tr('Peta Kiblat', 'Qibla Map'),
                context.tr('Safar', 'Travel'),
                context.tr('Dhuha & Tahajud', 'Dhuha & Tahajjud'),
                context.tr('Sunnah Jumat', 'Friday Sunnah'),
              ],
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
              Text(
                context.tr(
                  'Kiblat Bayangan Matahari (Bebas Gangguan Logam)',
                  'Sun Shadow Qibla (Free from Magnetic Interference)',
                ),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(
                  'Arah Kiblat: ${solar.qiblaBearingDeg.toStringAsFixed(1)}° · Bayangan Saat Ini: ${solar.shadowAzimuthDeg.toStringAsFixed(1)}°',
                  'Qibla Bearing: ${solar.qiblaBearingDeg.toStringAsFixed(1)}° · Current Shadow: ${solar.shadowAzimuthDeg.toStringAsFixed(1)}°',
                ),
                key: const Key('solar-qibla-summary'),
                style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  'Tinggi Matahari (Altitude): ${solar.sunAltitudeDeg.toStringAsFixed(1)}° di ${settings.effectiveLocationName}',
                  'Sun Altitude: ${solar.sunAltitudeDeg.toStringAsFixed(1)}° in ${settings.effectiveLocationName}',
                ),
              ),
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
                Text(
                  context.tr(
                    'Panduan Praktis Menentukan Kiblat dengan Tongkat Tegak',
                    'Practical Guide to Finding Qibla with a Vertical Stick',
                  ),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(_solarInstruction(context, solar), style: t.bodyLarge),
              ],
            ),
          ),
        ),
        SectionHeader(context.tr('Hari Istiwa A\'zham (Rashdul Qiblah Global)', 'Istiwa A\'zam Days (Global Rashdul Qiblah)')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'Dua Momen Matahari Tepat di Atas Ka\'bah Setiap Tahun:',
                    'Two Annual Moments When the Sun Is Directly Above the Kaaba:',
                  ),
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    '• 27–28 Mei pukul 16:18 WIB (17:18 WITA / 18:18 WIT)\n'
                    '• 15–16 Juli pukul 16:27 WIB (17:27 WITA / 18:27 WIT)\n\n'
                    'Pada menit tersebut, bayangan setiap benda tegak lurus di seluruh Indonesia yang terkena sinar matahari pasti menghadap lurus ke arah Ka\'bah.',
                    '• May 27-28 at 16:18 WIB (17:18 WITA / 18:18 WIT)\n'
                    '• July 15-16 at 16:27 WIB (17:27 WITA / 18:27 WIT)\n\n'
                    'At these exact times, the shadow of any upright object exposed to sunlight across Indonesia points directly along the Qibla line toward the Kaaba.',
                  ),
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
                  context.tr(
                    'Garis Vektor Geodetik ke Ka\'bah di Atas Dinding Bangunan',
                    'Geodetic Vector Line to the Kaaba on Building Walls',
                  ),
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
                  context.tr(
                    'Sudut Kiblat: ${bearing.toStringAsFixed(1)}° dari Utara Sejati',
                    'Qibla Angle: ${bearing.toStringAsFixed(1)}° from True North',
                  ),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Patokan Dinding Bangunan: Serong +${offsetFromWest.toStringAsFixed(1)}° ke arah Utara dari garis lurus menghadap Barat (270°).',
                    'Building Wall Reference: Angle +${offsetFromWest.toStringAsFixed(1)}° toward North from a straight line facing West (270°).',
                  ),
                  textAlign: TextAlign.center,
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Jarak Lurus ke Ka\'bah (Makkah): ${distKm.round()} km',
                    'Direct Distance to the Kaaba (Makkah): ${distKm.round()} km',
                  ),
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
    final rules = _safarRules(context, eval);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'Kota / Titik Asal: ${settings.effectiveLocationName}',
                    'Origin City / Point: ${settings.effectiveLocationName}',
                  ),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<City>(
                  key: const Key('safar-dest-dropdown'),
                  initialValue: _destCity,
                  decoration: InputDecoration(
                    labelText: context.tr('Pilih Kota Tujuan Safar', 'Select Travel Destination City'),
                  ),
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
                            ? context.tr(
                                'Memenuhi Syarat Rukhshah Jama\' & Qashar',
                                'Eligible for Jama\' & Qasr Concession',
                              )
                            : context.tr(
                                'Belum Mencapai Jarak Masafatul Qashr (81 km)',
                                'Below Masafat al-Qasr Distance (81 km)',
                              ),
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
                  context.tr(
                    'Jarak Udara: ${eval.straightDistanceKm.toStringAsFixed(1)} km · Estimasi Jalur Darat: ±${eval.estimatedRoadDistanceKm.toStringAsFixed(1)} km',
                    'Straight-Line Distance: ${eval.straightDistanceKm.toStringAsFixed(1)} km · Est. Road Distance: ~${eval.estimatedRoadDistanceKm.toStringAsFixed(1)} km',
                  ),
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(_safarSummary(context, eval), style: t.bodyMedium),
                const Divider(height: 20),
                for (final r in rules)
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
        SectionHeader(context.tr('Waktu Salat Sunnah Utama Hari Ini', 'Key Voluntary Prayer Windows Today')),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(MoeslimIcons.matahari, color: scheme.primary),
                title: Text(
                  context.tr('Waktu Salat Sunnah Dhuha', 'Dhuha Voluntary Prayer Window'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  context.tr(
                    'Waktu utama (Awwabin): sekitar ${hhmm(ext.dhuhaOptimal)}',
                    'Optimal time (Awwabin): around ${hhmm(ext.dhuhaOptimal)}',
                  ),
                ),
                trailing: Text(
                  '${hhmm(ext.dhuhaStart)} – ${hhmm(ext.dhuhaEnd)}',
                  key: const Key('extended-dhuha-window'),
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(MoeslimIcons.bulan, color: scheme.primary),
                title: Text(
                  context.tr('Sepertiga Malam Terakhir (Tahajud Utama)', 'Last Third of the Night (Best for Tahajjud)'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  context.tr(
                    'Pertengahan malam (Nishful Lail): ${hhmm(ext.midnightNishfulLail)}',
                    'Islamic Midnight (Nisf al-Layl): ${hhmm(ext.midnightNishfulLail)}',
                  ),
                ),
                trailing: Text(
                  '${hhmm(ext.lastThirdNightStart)} – ${hhmm(ext.lastThirdNightEnd)}',
                  key: const Key('extended-tahajud-window'),
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        SectionHeader(
          context.tr('3 Waktu Terlarang Salat Sunnah Mutlak', '3 Prohibited Times for Unspecified Voluntary Prayers'),
        ),
        for (var i = 0; i < ext.forbiddenWindows.length; i++) ...[
          Builder(
            builder: (context) {
              final (title, start, end, desc) = ext.forbiddenWindows[i];
              final loc = _forbiddenWindowText(context, i, title, desc);
              return Card(
                child: ListTile(
                  leading: Icon(MoeslimIcons.peringatan, color: scheme.error),
                  title: Text('${loc.title} (${hhmm(start)} – ${hhmm(end)})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(loc.desc),
                ),
              );
            },
          ),
        ],
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
                    Text(
                      context.tr('Amalan Sunnah Hari Jumat', 'Friday Sunnah Practices'),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      context.tr(
                        '${_fridayChecks.length} / ${fridaySunnahCatalog.length} selesai',
                        '${_fridayChecks.length} / ${fridaySunnahCatalog.length} done',
                      ),
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
        for (final item in fridaySunnahCatalog) ...[
          Builder(
            builder: (context) {
              final loc = _fridaySunnahText(context, item);
              return Card(
                child: CheckboxListTile(
                  key: Key('friday-check-${item.id}'),
                  title: Text(loc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(loc.dalil),
                  value: _fridayChecks.contains(item.id),
                  onChanged: (_) async {
                    final next = await ref.read(fridaySunnahRepoProvider).toggleItem(_today, item.id);
                    setState(() => _fridayChecks = next);
                  },
                ),
              );
            },
          ),
        ],
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
