import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'core/adzan_service.dart';
import 'core/providers.dart';
import 'core/theme.dart';
import 'features/home/home_page.dart';
import 'features/ibadah/ibadah_page.dart';
import 'features/more/more_page.dart';
import 'features/more/followed_mosques_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/quran/quran_page.dart';

class MoeslimApp extends ConsumerWidget {
  const MoeslimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider).value;
    return MaterialApp(
      title: 'Moeslim PM',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: switch (s?.themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(s?.fontScale ?? 1.0)),
        child: child!,
      ),
      home: s == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (s.onboardingDone ? const HomeShell() : const OnboardingPage()),
    );
  }
}

/// Navigasi utama Moeslim Personal (maks. 5 menu): Beranda, Al-Qur'an, Ibadah, Masjid, Profil.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  final _visited = <int>{0};
  late final _pages = <Widget>[
    HomePage(onNavigate: _selectTab),
    const QuranPage(),
    const IbadahPage(),
    const FollowedMosquesPage(asTab: true),
    const MorePage(),
  ];

  void _selectTab(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _visited.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adzanState = ref.watch(adzanControllerProvider);
    final settings = ref.watch(settingsProvider).value;
    return Scaffold(
      body: Column(
        children: [
          if (adzanState.ringingPrayer != null && settings != null)
            SafeArea(
              bottom: false,
              child: _ActiveAdzanBanner(
                prayer: adzanState.ringingPrayer!,
                settings: settings,
                onStop: () => ref.read(adzanControllerProvider.notifier).stopAdzan(),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  TickerMode(enabled: i == _index, child: _visited.contains(i) ? _pages[i] : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(MoeslimIcons.beranda),
            selectedIcon: Icon(MoeslimIcons.beranda),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(MoeslimIcons.quranTerbuka),
            selectedIcon: Icon(MoeslimIcons.quranTerbuka),
            label: "Al-Qur'an",
          ),
          NavigationDestination(
            icon: Icon(MoeslimIcons.zikr),
            selectedIcon: Icon(MoeslimIcons.zikr),
            label: 'Ibadah',
          ),
          NavigationDestination(
            icon: Icon(MoeslimIcons.masjid),
            selectedIcon: Icon(MoeslimIcons.masjid),
            label: 'Masjid',
          ),
          NavigationDestination(
            icon: Icon(MoeslimIcons.profil),
            selectedIcon: Icon(MoeslimIcons.profil),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _ActiveAdzanBanner extends StatelessWidget {
  final Prayer prayer;
  final PersonalSettings settings;
  final VoidCallback onStop;

  const _ActiveAdzanBanner({
    required this.prayer,
    required this.settings,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final isFajr = prayer == Prayer.fajr;
    return Material(
      color: BrandColors.deep,
      child: Padding(
        key: const Key('active-adzan-banner'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BrandColors.gold.withValues(alpha: .2),
                shape: BoxShape.circle,
              ),
              child: const Icon(MoeslimIcons.adzan, color: BrandColors.gold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Waktu Adzan ${prayer.label} • ${settings.effectiveLocationName}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  Text(
                    isFajr
                        ? 'Ash-shalaatu khairum minan-nauum • ${settings.muadzin.name}'
                        : 'Hayya \'alash-shalaah • ${settings.muadzin.name}',
                    style: const TextStyle(color: BrandColors.cream, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              key: const Key('stop-adzan-alarm'),
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.gold,
                foregroundColor: BrandColors.deep,
              ),
              onPressed: onStop,
              icon: const Icon(MoeslimIcons.bisukan, size: 18),
              label: const Text('Matikan', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
