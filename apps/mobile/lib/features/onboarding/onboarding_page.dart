import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/location_service.dart';
import '../../core/providers.dart';

/// Sambutan pertama kali: 3 langkah, dapat dilewati. Tidak meminta akun apa pun.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;
  City _city = indonesianCities.firstWhere((c) => c.name == 'Jakarta');
  DeviceLocation? _gpsLocation;
  GpsState? _lastGpsState;
  bool _locating = false;

  static const _slidesId = [
    (
      'Selamat Datang di',
      'Moeslim PM',
      'Satu aplikasi untuk ibadah pribadi dan pengelolaan masjid yang lebih mudah, modern, dan terintegrasi.',
    ),
    (
      'Ibadah harian',
      'tetap jalan offline',
      "Jadwal salat, Al-Qur'an, dzikir, kiblat, dan catatan ibadah tersimpan di perangkat Anda, tanpa akun dan tanpa iklan.",
    ),
    (
      'Dengarkan',
      "Murottal Al-Qur'an",
      'Putar per ayat atau per surah dari qari pilihan, lalu simpan untuk didengar offline.',
    ),
  ];

  static const _slidesEn = [
    (
      'Welcome to',
      'Moeslim PM',
      'One app for daily worship and mosque management, built to be simple, modern, and integrated.',
    ),
    (
      'Daily worship',
      'works offline',
      "Prayer times, Qur'an, dhikr, Qibla, and worship logs stay on your device, with no account and no ads.",
    ),
    (
      'Listen to',
      "Qur'an Recitations",
      'Play verse by verse or by surah from selected reciters, and save audio for offline listening.',
    ),
  ];

  Future<void> _detectGps() async {
    setState(() {
      _locating = true;
      _lastGpsState = null;
    });
    final state = await ref.read(gpsControllerProvider.notifier).ensureActive(requestPermissionIfNeeded: true);
    if (!mounted) return;
    setState(() {
      _locating = false;
      _lastGpsState = state;
      if (state is GpsReady) {
        _gpsLocation = state.position.toDeviceLocation();
      }
    });
  }

  String? _gpsNoticeText(BuildContext context) {
    final state = _lastGpsState;
    if (state == null) return null;
    return switch (state) {
      GpsReady() when _gpsLocation != null => context.tr(
        'GPS aktif: ${_gpsLocation!.label}',
        'GPS active: ${localizeLocationLabel(_gpsLocation!.label, context.lang)}',
      ),
      GpsServiceDisabled() => context.tr(
        'GPS perangkat sedang nonaktif. Aktifkan GPS atau pilih kota manual.',
        'Device GPS is turned off. Enable GPS or choose a city manually.',
      ),
      GpsPermissionDenied() || GpsPermissionDeniedForever() => context.tr(
        'Izin lokasi belum diberikan. Anda bisa mengaktifkannya nanti di Jadwal Salat.',
        'Location permission not granted yet. You can enable it later in Prayer Times.',
      ),
      GpsError(:final message) => message,
      GpsChecking() || GpsAcquiring() => context.tr('Menunggu sinyal GPS...', 'Waiting for GPS signal...'),
      _ => null,
    };
  }

  Future<void> _finish() async {
    final s = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
    await ref.read(settingsProvider.notifier).save(
      s.copyWith(
        onboardingDone: true,
        location: _city,
        useDeviceLocation: _gpsLocation != null ? true : s.useDeviceLocation,
        deviceLocation: _gpsLocation ?? s.deviceLocation,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final lang = context.lang;
    final slides = lang == AppLanguage.en ? _slidesEn : _slidesId;
    final last = _page == slides.length - 1;
    final gpsNotice = _gpsNoticeText(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SegmentedButton<AppLanguage>(
                    key: const Key('onboarding-language'),
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    segments: const [
                      ButtonSegment(value: AppLanguage.id, label: Text('ID')),
                      ButtonSegment(value: AppLanguage.en, label: Text('EN')),
                    ],
                    selected: {lang},
                    onSelectionChanged: (v) {
                      final current = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
                      ref.read(settingsProvider.notifier).save(current.copyWith(language: v.first));
                    },
                  ),
                  TextButton(
                    key: const Key('onboarding-skip'),
                    onPressed: _finish,
                    child: Text(context.tr('Lewati', 'Skip')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (pre, title, body) = slides[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: BrandArt(
                            const [
                              BrandIllustration.masjidPagi4,
                              BrandIllustration.alquranRehal4,
                              BrandIllustration.ramadanMalam4,
                            ][i],
                            key: Key('onboarding-art-$i'),
                            height: 290,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(pre, style: t.headlineSmall),
                        Text(
                          title,
                          style: t.headlineMedium?.copyWith(color: BrandColors.emerald, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(body, style: t.bodyLarge),
                        if (i == slides.length - 1) ...[
                          const SizedBox(height: 20),
                          DropdownButtonFormField<City>(
                            key: const Key('onboarding-city'),
                            initialValue: _city,
                            decoration: InputDecoration(
                              labelText: context.tr('Kota untuk jadwal salat', 'City for prayer times'),
                              prefixIcon: const Icon(MoeslimIcons.lokasi),
                            ),
                            items: [
                              for (final c in indonesianCities)
                                DropdownMenuItem(value: c, child: Text('${c.name} (${c.zone})')),
                            ],
                            onChanged: (c) => setState(() {
                              _city = c ?? _city;
                              _gpsLocation = null;
                              _lastGpsState = null;
                            }),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              key: const Key('onboarding-use-gps'),
                              onPressed: _locating ? null : _detectGps,
                              icon: _locating
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(MoeslimIcons.lokasi),
                              label: Text(
                                _gpsLocation != null
                                    ? context.tr(
                                        'Lokasi GPS Aktif (${_gpsLocation!.label})',
                                        'GPS Location Active (${localizeLocationLabel(_gpsLocation!.label, lang)})',
                                      )
                                    : context.tr('Gunakan Lokasi GPS Presisi', 'Use Precise GPS Location'),
                              ),
                            ),
                          ),
                          if (gpsNotice != null) ...[
                            const SizedBox(height: 6),
                            Text(gpsNotice, style: t.bodySmall),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? BrandColors.emerald : BrandColors.emerald.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('onboarding-next'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
                  onPressed: last
                      ? _finish
                      : () => _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
                  icon: const Icon(MoeslimIcons.lanjut),
                  iconAlignment: IconAlignment.end,
                  label: Text(last ? context.tr('Mulai Sekarang', 'Get Started') : context.tr('Lanjut', 'Next')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
