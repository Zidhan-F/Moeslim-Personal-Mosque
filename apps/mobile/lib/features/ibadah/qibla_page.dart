import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/location_service.dart';

enum CompassAccuracy { high, medium, low, unavailable }

/// Pembacaan mentah sensor kompas perangkat (utara magnetik + estimasi galat sensor).
class CompassReading {
  final double? magneticHeading;
  final double? accuracyDeg;

  const CompassReading({this.magneticHeading, this.accuracyDeg});

  CompassAccuracy get level {
    if (magneticHeading == null) return CompassAccuracy.unavailable;
    final a = accuracyDeg;
    if (a == null || a >= 45) return CompassAccuracy.low;
    if (a >= 30) return CompassAccuracy.medium;
    return CompassAccuracy.high;
  }

  bool get needsCalibration => level == CompassAccuracy.low;
}

/// Stream sensor kompas perangkat beserta akurasinya. Di-override di test.
final compassProvider = StreamProvider<CompassReading?>((ref) {
  final events = FlutterCompass.events;
  if (events == null) return Stream.value(null);
  return events.map((e) => CompassReading(magneticHeading: e.heading, accuracyDeg: e.accuracy));
});

/// Arah kompas perangkat (derajat dari utara magnetik). Disediakan untuk kompatibilitas.
final headingProvider = StreamProvider<double?>((ref) {
  final events = FlutterCompass.events;
  if (events == null) return Stream.value(null);
  return events.map((e) => e.heading);
});

/// Format derajat gaya Indonesia: 295,0°.
String degreeId(double v) => '${v.toStringAsFixed(1).replaceAll('.', ',')}°';

/// Format deklinasi magnetik bertanda: +0,8° atau -1,2°.
String signedDegreeId(double v) {
  final sign = v >= 0 ? '+' : '-';
  return '$sign${v.abs().toStringAsFixed(1).replaceAll('.', ',')}°';
}

/// Format koordinat geografis presisi (5 angka desimal ≈ 1,1 meter).
String coordinateId(double value, {required bool isLatitude}) {
  final hemi = isLatitude ? (value >= 0 ? 'LU' : 'LS') : (value >= 0 ? 'BT' : 'BB');
  return '${value.abs().toStringAsFixed(5).replaceAll('.', ',')}° $hemi';
}

class QiblaPage extends ConsumerStatefulWidget {
  const QiblaPage({super.key});

  @override
  ConsumerState<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends ConsumerState<QiblaPage> with WidgetsBindingObserver {
  CompassReading? _lastReading;
  double? _lastDeclination;
  double? _smoothedTrueHeading;
  double? _unwrappedHeading;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(gpsControllerProvider.notifier).ensureActive());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      unawaited(ref.read(gpsControllerProvider.notifier).ensureActive());
    }
  }

  void _updateHeadingSmoothing(CompassReading? reading, GpsReady gps) {
    final mag = reading?.magneticHeading;
    if (mag == null) {
      _smoothedTrueHeading = null;
      _unwrappedHeading = null;
      _wasAligned = false;
      return;
    }

    final rawTrue = applyMagneticDeclination(mag, gps.declinationDegrees);
    if (_smoothedTrueHeading == null || _unwrappedHeading == null) {
      _smoothedTrueHeading = rawTrue;
      _unwrappedHeading = rawTrue;
    } else {
      final next = smoothHeading(_smoothedTrueHeading!, rawTrue, alpha: 0.35);
      _unwrappedHeading = _unwrappedHeading! + shortestAngleDelta(_smoothedTrueHeading!, next);
      _smoothedTrueHeading = next;
    }

    final bearing = qiblaBearing(gps.position.coordinates);
    final aligned = isAlignedWithQibla(_smoothedTrueHeading!, bearing);
    if (aligned && !_wasAligned && reading?.needsCalibration != true) {
      HapticFeedback.mediumImpact();
    }
    _wasAligned = aligned;
  }

  void _calibrate(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(Icons.screen_rotation_alt),
      title: const Text('Kalibrasi Kompas'),
      content: const Text(
        'Putar ponsel membentuk angka 8 beberapa kali di udara. Jauhkan dari benda logam, magnet, casing bermagnet, '
        'atau perangkat elektronik. Setelah itu letakkan ponsel mendatar.',
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai'))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final gpsState = ref.watch(gpsControllerProvider);
    final compassReading = ref.watch(compassProvider).value;

    if (gpsState is! GpsReady) {
      _wasAligned = false;
      _lastReading = null;
      _lastDeclination = null;
      _smoothedTrueHeading = null;
      _unwrappedHeading = null;
    } else if (!identical(compassReading, _lastReading) || gpsState.declinationDegrees != _lastDeclination) {
      _lastReading = compassReading;
      _lastDeclination = gpsState.declinationDegrees;
      _updateHeadingSmoothing(compassReading, gpsState);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat'), centerTitle: true),
      body: switch (gpsState) {
        GpsChecking() => const _GpsProgressView(
          key: Key('qibla-gps-checking'),
          title: 'Memeriksa Status GPS...',
          subtitle: 'Memastikan layanan GPS perangkat aktif sebelum menghitung arah kiblat.',
        ),
        GpsServiceDisabled() => _GpsGateView(
          key: const Key('qibla-gps-disabled'),
          icon: Icons.location_off_rounded,
          title: 'GPS Perangkat Tidak Aktif',
          message:
              'Arah kiblat harus dihitung dari koordinat GPS aktif agar tepat dan presisi, tidak menggunakan perkiraan kota.',
          primaryKey: const Key('enable-gps'),
          primaryLabel: 'Aktifkan GPS',
          primaryIcon: MoeslimIcons.lokasi,
          onPrimary: () => ref.read(gpsControllerProvider.notifier).openLocationSettings(),
          secondaryKey: const Key('recheck-gps'),
          secondaryLabel: 'Cek Ulang Status GPS',
          onSecondary: () => ref.read(gpsControllerProvider.notifier).ensureActive(),
        ),
        GpsPermissionDenied() => _GpsGateView(
          key: const Key('qibla-permission-denied'),
          icon: MoeslimIcons.lokasi,
          title: 'Izin Lokasi GPS Diperlukan',
          message:
              'Izinkan akses lokasi presisi agar Moeslim PM dapat membaca koordinat GPS perangkat untuk menentukan arah kiblat.',
          primaryKey: const Key('request-location-permission'),
          primaryLabel: 'Izinkan Lokasi GPS',
          primaryIcon: MoeslimIcons.lokasi,
          onPrimary: () => ref.read(gpsControllerProvider.notifier).requestPermissionAndStart(),
          secondaryKey: const Key('recheck-gps'),
          secondaryLabel: 'Cek Ulang Status GPS',
          onSecondary: () => ref.read(gpsControllerProvider.notifier).ensureActive(),
        ),
        GpsPermissionDeniedForever() => _GpsGateView(
          key: const Key('qibla-permission-forever'),
          icon: Icons.gpp_maybe_outlined,
          title: 'Izin Lokasi Ditolak Permanen',
          message:
              'Buka pengaturan aplikasi lalu aktifkan izin Lokasi (Lokasi Presisi) untuk Moeslim PM agar arah kiblat dapat digunakan.',
          primaryKey: const Key('open-app-settings'),
          primaryLabel: 'Buka Pengaturan Aplikasi',
          primaryIcon: MoeslimIcons.pengaturan,
          onPrimary: () => ref.read(gpsControllerProvider.notifier).openAppSettings(),
          secondaryKey: const Key('recheck-gps'),
          secondaryLabel: 'Cek Ulang Status GPS',
          onSecondary: () => ref.read(gpsControllerProvider.notifier).ensureActive(),
        ),
        GpsAcquiring() => _GpsProgressView(
          key: const Key('qibla-gps-acquiring'),
          title: 'Mengunci Sinyal GPS Presisi...',
          subtitle:
              'GPS aktif. Menunggu koordinat satelit perangkat Anda. Pindah ke dekat jendela atau area terbuka jika perlu.',
          onRetry: () => ref.read(gpsControllerProvider.notifier).ensureActive(),
        ),
        GpsError(:final message) => _GpsGateView(
          key: const Key('qibla-gps-error'),
          icon: MoeslimIcons.peringatan,
          title: 'Gagal Membaca Lokasi GPS',
          message: message,
          primaryKey: const Key('retry-gps'),
          primaryLabel: 'Coba Lagi',
          primaryIcon: MoeslimIcons.refresh,
          onPrimary: () => ref.read(gpsControllerProvider.notifier).ensureActive(),
        ),
        GpsReady() => _buildCompassBody(context, gpsState, compassReading),
      },
    );
  }

  Widget _buildCompassBody(BuildContext context, GpsReady gps, CompassReading? reading) {
    final pos = gps.position;
    final bearing = qiblaBearing(pos.coordinates);
    final distance = distanceToKaabaKm(pos.coordinates);
    final trueHeading = _smoothedTrueHeading;
    final renderHeading = _unwrappedHeading ?? trueHeading ?? 0.0;
    final delta = trueHeading == null ? null : shortestAngleDelta(trueHeading, bearing);
    final aligned = delta != null && delta.abs() <= 2.0;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final goldInk = dark ? BrandColors.gold : BrandColors.goldText;
    final locationLabel = formatGpsLocationLabel(pos.coordinates);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          key: const Key('qibla-gps-status'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(MoeslimIcons.lokasi, size: 18, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS Aktif • $locationLabel',
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${coordinateId(pos.latitude, isLatitude: true)}, '
                        '${coordinateId(pos.longitude, isLatitude: false)} • Akurasi ±${pos.accuracyMeters.round()} m',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('refresh-gps'),
                  tooltip: 'Perbarui posisi GPS',
                  onPressed: () => ref.read(gpsControllerProvider.notifier).ensureActive(),
                  icon: Icon(MoeslimIcons.refresh, color: scheme.primary),
                ),
              ],
            ),
          ),
        ),
        if (pos.isMocked)
          const _WarningBanner(
            key: Key('qibla-mock-warning'),
            icon: MoeslimIcons.peringatan,
            text: 'Lokasi tiruan (Mock GPS) terdeteksi. Matikan aplikasi lokasi palsu agar arah kiblat benar.',
          ),
        if (pos.isLowAccuracy)
          _WarningBanner(
            key: const Key('qibla-gps-weak'),
            icon: MoeslimIcons.peringatan,
            text:
                'Sinyal GPS masih lemah (±${pos.accuracyMeters.round()} m). Pindah ke area lebih terbuka agar koordinat makin presisi.',
          ),
        if (reading?.needsCalibration == true)
          const _WarningBanner(
            key: Key('qibla-compass-low'),
            icon: Icons.screen_rotation_alt,
            text:
                'Akurasi sensor kompas rendah atau terganggu medan magnet. Kalibrasi ponsel membentuk angka 8 dan jauhkan dari logam.',
          ),
        const SizedBox(height: 8),
        Center(
          child: _AlignmentBanner(
            delta: delta,
            aligned: aligned,
            hasSensor: trueHeading != null,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 28,
                color: aligned ? scheme.primary : goldInk,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: aligned ? scheme.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dialSize = math.min(288.0, MediaQuery.sizeOf(context).width - 56).clamp(200.0, 288.0);
                    final center = dialSize / 2;
                    final radius = center * 192 / 220 + 4;
                    return SizedBox.square(
                      dimension: dialSize,
                      child: Semantics(
                        label: 'Kompas kiblat GPS, ${degreeId(bearing)} dari utara sejati',
                        child: Stack(
                          children: [
                            // Dial asset kit berputar mengikuti arah perangkat (utara dial = utara sejati).
                            Positioned.fill(
                              child: Transform.rotate(
                                angle: -renderHeading * math.pi / 180,
                                child: const BrandElementArt(BrandElement.compassDial, key: Key('compass-dial')),
                              ),
                            ),
                            // Huruf mata angin (Inter, tetap tegak) di dalam cincin dial.
                            Positioned.fill(
                              child: CustomPaint(
                                painter: CompassPainter(qibla: bearing, heading: trueHeading == null ? null : renderHeading),
                              ),
                            ),
                            // Jarum asset kit menunjuk arah kiblat sejati.
                            Positioned.fill(
                              child: Transform.rotate(
                                angle: (bearing - renderHeading) * math.pi / 180,
                                child: const BrandElementArt(BrandElement.compassNeedle, key: Key('compass-needle')),
                              ),
                            ),
                            // Ka'bah di ujung jarum (arah kiblat), ilustrasi brand.
                            Builder(
                              builder: (_) {
                                final a = (bearing - renderHeading - 90) * math.pi / 180;
                                return Positioned(
                                  key: const Key('compass-kaaba'),
                                  left: center + math.cos(a) * radius - 18,
                                  top: center + math.sin(a) * radius - 18,
                                  child: Container(
                                    decoration: const BoxDecoration(color: BrandColors.cream, shape: BoxShape.circle),
                                    padding: const EdgeInsets.all(3),
                                    child: const BrandArt(BrandIllustration.kaaba, width: 30, height: 30),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (trueHeading == null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Sensor kompas tidak tersedia. Gunakan sudut kiblat GPS di bawah bersama kompas fisik.',
              textAlign: TextAlign.center,
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
                    const BrandArt(BrandIllustration.kaaba, width: 52, height: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Arah Kiblat (GPS)'),
                          Text(
                            degreeId(bearing),
                            key: const Key('qibla-bearing'),
                            style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
                          ),
                          Text('dari utara sejati • ± ${distance.toStringAsFixed(0)} km', style: t.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: BrandColors.gold.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(MoeslimIcons.lokasi, size: 16, color: goldInk),
                          const SizedBox(width: 4),
                          Text("Ke Ka'bah\n(Makkah)", style: TextStyle(color: goldInk, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Deklinasi magnetik: ${signedDegreeId(gps.declinationDegrees)} (koreksi utara sejati WGS84)',
                  key: const Key('qibla-declination'),
                  style: t.bodySmall,
                ),
                if (reading != null && reading.magneticHeading != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Arah ponsel saat ini: ${degreeId(trueHeading!)} • Sensor: ${_accuracyLabel(reading.level)}',
                    style: t.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(MoeslimIcons.kiblat, color: scheme.primary),
            title: const Text('Kalibrasi Kompas', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
              'Putar ponsel membentuk angka 8 untuk mengkalibrasi akurasi kompas. Letakkan ponsel mendatar dan jauh dari benda logam.',
            ),
            trailing: const BrandArt(BrandIllustration.calibrate, width: 72),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('calibrate'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
          onPressed: () => _calibrate(context),
          icon: const Icon(Icons.screen_rotation_alt),
          label: const Text('Kalibrasi Sekarang'),
        ),
      ],
    );
  }

  static String _accuracyLabel(CompassAccuracy level) => switch (level) {
    CompassAccuracy.high => 'Tinggi',
    CompassAccuracy.medium => 'Sedang',
    CompassAccuracy.low => 'Rendah (perlu kalibrasi)',
    CompassAccuracy.unavailable => 'Tidak tersedia',
  };
}

class _AlignmentBanner extends StatelessWidget {
  final double? delta;
  final bool aligned;
  final bool hasSensor;

  const _AlignmentBanner({required this.delta, required this.aligned, required this.hasSensor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!hasSensor || delta == null) {
      return const SizedBox.shrink();
    }
    if (aligned) {
      return Container(
        key: const Key('qibla-aligned'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: BrandColors.emerald,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MoeslimIcons.berhasil, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Tepat Menghadap Kiblat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    final turnRight = delta! > 0;
    return Container(
      key: const Key('qibla-direction-hint'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            turnRight ? Icons.turn_right_rounded : Icons.turn_left_rounded,
            size: 18,
            color: scheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '${turnRight ? 'Putar kanan' : 'Putar kiri'} ${degreeId(delta!.abs())}',
            style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WarningBanner({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? const Color(0xFFFFDF8E) : const Color(0xFF5C3D00);
    final bg = Colors.amber.withValues(alpha: dark ? .18 : .15);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700.withValues(alpha: .45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: fg, fontSize: 13, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _GpsProgressView extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _GpsProgressView({super.key, required this.title, required this.subtitle, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(title, textAlign: TextAlign.center, style: t.titleMedium),
                const SizedBox(height: 8),
                Text(subtitle, textAlign: TextAlign.center, style: t.bodyMedium),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(MoeslimIcons.refresh),
                    label: const Text('Coba Ulang'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GpsGateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Key primaryKey;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final Key? secondaryKey;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _GpsGateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryKey,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryKey,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: scheme.primary),
                ),
                const SizedBox(height: 18),
                Text(title, textAlign: TextAlign.center, style: t.titleLarge),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center, style: t.bodyMedium),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: primaryKey,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onPrimary,
                    icon: Icon(primaryIcon),
                    label: Text(primaryLabel),
                  ),
                ),
                if (secondaryLabel != null && onSecondary != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: secondaryKey,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: onSecondary,
                      icon: const Icon(MoeslimIcons.refresh),
                      label: Text(secondaryLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Huruf mata angin U/T/S/B di atas dial kompas asset kit (440×440, cincin dalam r=170).
/// Posisi huruf berputar mengikuti [heading], hurufnya tetap tegak agar mudah dibaca.
class CompassPainter extends CustomPainter {
  final double qibla;
  final double? heading;
  const CompassPainter({required this.qibla, this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final scale = size.shortestSide / 440;
    final rot = -(heading ?? 0) * math.pi / 180;
    const labels = {'U': 0.0, 'T': 90.0, 'S': 180.0, 'B': 270.0};
    for (final e in labels.entries) {
      final a = rot + (e.value - 90) * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(
          text: e.key,
          style: TextStyle(
            fontFamily: 'Inter',
            package: 'moeslim_brand',
            color: const Color(0xFFF2D88B), // gold_light asset kit; ≥ 7:1 di atas dial hijau tua
            fontWeight: FontWeight.w700,
            fontSize: 29 * scale,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c + Offset(math.cos(a), math.sin(a)) * (134 * scale) - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(CompassPainter old) => old.qibla != qibla || old.heading != heading;
}
