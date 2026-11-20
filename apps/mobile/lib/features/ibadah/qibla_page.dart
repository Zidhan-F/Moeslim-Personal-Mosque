import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/providers.dart';

/// Arah kompas perangkat (derajat dari utara). Di-override di test.
final headingProvider = StreamProvider<double?>((ref) {
  final events = FlutterCompass.events;
  if (events == null) return Stream.value(null);
  return events.map((e) => e.heading);
});

class QiblaPage extends ConsumerWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bearing = qiblaBearing(settings.location.coordinates);
    final distance = distanceToKaabaKm(settings.location.coordinates);
    final heading = ref.watch(headingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Dari ${settings.location.name}', textAlign: TextAlign.center),
          Text(
            '${bearing.toStringAsFixed(1)}° dari utara sejati',
            key: const Key('qibla-bearing'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('Jarak ke Ka\'bah ± ${distance.toStringAsFixed(0)} km', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          heading.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const _NoSensor(),
            data: (h) => h == null
                ? const _NoSensor()
                : Center(
                    child: Transform.rotate(
                      angle: (bearing - h) * math.pi / 180,
                      child: Icon(Icons.navigation, size: 160, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Kalibrasi: gerakkan ponsel membentuk angka 8 beberapa kali dan jauhkan dari benda logam/magnet. '
                'Akurasi sensor kompas berbeda antar perangkat; gunakan sudut di atas bersama kompas fisik atau '
                'arah matahari bila ragu.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSensor extends StatelessWidget {
  const _NoSensor();

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Sensor kompas tidak tersedia. Gunakan sudut kiblat di atas dengan kompas fisik.',
      textAlign: TextAlign.center,
    ),
  );
}
