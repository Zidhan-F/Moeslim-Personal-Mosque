import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

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

  static const _slides = [
    (
      'Selamat Datang di',
      'Moeslim PM',
      'Satu aplikasi untuk ibadah pribadi dan pengelolaan masjid yang lebih mudah, modern, dan terintegrasi.',
    ),
    (
      'Ibadah harian',
      'tetap jalan offline',
      'Jadwal salat, Al-Qur\'an, dzikir, kiblat, dan catatan ibadah tersimpan di perangkat Anda — tanpa akun, tanpa iklan.',
    ),
    (
      'Belajar',
      '7 Irama Al-Qur\'an',
      'Dengarkan dan pelajari Bayyati, Hijaz, Shaba, Rast, Jiharkah, Sika, dan Nahawand.',
    ),
  ];

  Future<void> _finish() async {
    final s = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
    await ref.read(settingsProvider.notifier).save(s.copyWith(onboardingDone: true, location: _city));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final last = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(key: const Key('onboarding-skip'), onPressed: _finish, child: const Text('Lewati')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (pre, title, body) = _slides[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: BrandArt(
                            const [
                              BrandIllustration.heroQuran,
                              BrandIllustration.mosqueCircle,
                              BrandIllustration.naghomLantern,
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
                        if (i == _slides.length - 1) ...[
                          const SizedBox(height: 20),
                          DropdownButtonFormField<City>(
                            key: const Key('onboarding-city'),
                            initialValue: _city,
                            decoration: const InputDecoration(
                              labelText: 'Kota untuk jadwal salat',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            items: [
                              for (final c in indonesianCities)
                                DropdownMenuItem(value: c, child: Text('${c.name} (${c.zone})')),
                            ],
                            onChanged: (c) => setState(() => _city = c ?? _city),
                          ),
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
                for (var i = 0; i < _slides.length; i++)
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
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  label: Text(last ? 'Mulai Sekarang' : 'Lanjut'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
