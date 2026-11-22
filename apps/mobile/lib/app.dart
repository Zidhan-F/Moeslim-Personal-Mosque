import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'core/adzan_service.dart';
import 'core/l10n.dart';
import 'core/providers.dart';
import 'core/theme.dart';
import 'features/home/home_page.dart';
import 'features/ibadah/ibadah_page.dart';
import 'features/more/more_page.dart';
import 'features/more/followed_mosques_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/quran/quran_page.dart';

class MoeslimApp extends ConsumerStatefulWidget {
  const MoeslimApp({super.key});

  @override
  ConsumerState<MoeslimApp> createState() => _MoeslimAppState();
}

class _MoeslimAppState extends ConsumerState<MoeslimApp> with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(adzanControllerProvider.notifier).syncActiveNativeAlarm());
      unawaited(ref.read(adzanControllerProvider.notifier).refreshNotificationStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider).value;
    final adzanState = ref.watch(adzanControllerProvider);
    final lang = s?.language ?? AppLanguage.id;
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
      builder: (context, child) => AppLangScope(
        language: lang,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(s?.fontScale ?? 1.0)),
          child: Stack(
            children: [
              child!,
              if (adzanState.ringingPrayer != null && s != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: _ActiveAdzanPopup(
                        prayer: adzanState.ringingPrayer!,
                        settings: s,
                        onStop: () => ref.read(adzanControllerProvider.notifier).stopAdzan(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
    // Pastikan AdzanController aktif saat berada di HomeShell.
    ref.watch(adzanControllerProvider);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _pages.length; i++)
            TickerMode(enabled: i == _index, child: _visited.contains(i) ? _pages[i] : const SizedBox.shrink()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(MoeslimIcons.beranda),
            selectedIcon: const Icon(MoeslimIcons.beranda),
            label: context.tr('Beranda', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(MoeslimIcons.quranTerbuka),
            selectedIcon: const Icon(MoeslimIcons.quranTerbuka),
            label: context.tr("Al-Qur'an", "Qur'an"),
          ),
          NavigationDestination(
            icon: const Icon(MoeslimIcons.zikr),
            selectedIcon: const Icon(MoeslimIcons.zikr),
            label: context.tr('Ibadah', 'Worship'),
          ),
          NavigationDestination(
            icon: const Icon(MoeslimIcons.masjid),
            selectedIcon: const Icon(MoeslimIcons.masjid),
            label: context.tr('Masjid', 'Mosque'),
          ),
          NavigationDestination(
            icon: const Icon(MoeslimIcons.profil),
            selectedIcon: const Icon(MoeslimIcons.profil),
            label: context.tr('Profil', 'Profile'),
          ),
        ],
      ),
    );
  }
}

/// Pop-up notifikasi alarm adzan mengambang di atas seluruh halaman aplikasi.
class _ActiveAdzanPopup extends StatelessWidget {
  final Prayer prayer;
  final PersonalSettings settings;
  final VoidCallback onStop;

  const _ActiveAdzanPopup({
    required this.prayer,
    required this.settings,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final isFajr = prayer == Prayer.fajr;
    final pLabel = context.prayerLabel(prayer);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? BrandColors.nightCard : BrandColors.white;
    final borderColor = isDark ? BrandColors.gold : BrandColors.emerald.withValues(alpha: .35);
    final shadowColor = isDark ? Colors.black.withValues(alpha: .45) : Colors.black.withValues(alpha: .16);
    final iconBg = isDark ? BrandColors.gold.withValues(alpha: .20) : BrandColors.emerald.withValues(alpha: .12);
    final iconColor = isDark ? BrandColors.gold : BrandColors.emerald;
    final titleColor = isDark ? BrandColors.cream : BrandColors.deep;
    final subtitleColor = isDark ? BrandColors.cream.withValues(alpha: .82) : BrandColors.textMuted;
    final buttonBg = isDark ? BrandColors.gold : BrandColors.emerald;
    final buttonFg = isDark ? BrandColors.deep : Colors.white;

    return Material(
      key: const Key('active-adzan-popup-surface'),
      color: surfaceColor,
      elevation: isDark ? 10 : 6,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        key: const Key('active-adzan-banner'),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_rounded, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr(
                          'Waktu Adzan $pLabel • ${settings.effectiveLocationName}',
                          'Adhan Time: $pLabel • ${settings.effectiveLocationName}',
                        ),
                        style: TextStyle(color: titleColor, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFajr
                            ? 'Ash-shalaatu khairum minan-nauum • ${settings.muadzin.name}'
                            : 'Hayya \'alash-shalaah • ${settings.muadzin.name}',
                        style: TextStyle(color: subtitleColor, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('stop-adzan-alarm'),
              style: FilledButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: buttonFg,
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
              ),
              onPressed: onStop,
              icon: const Icon(MoeslimIcons.bisukan, size: 18),
              label: Text(
                context.tr('Matikan Adzan', 'Stop Adhan'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
