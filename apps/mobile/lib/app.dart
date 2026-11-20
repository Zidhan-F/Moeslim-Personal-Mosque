import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

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
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigate: (i) => setState(() => _index = i)),
      const QuranPage(),
      const IbadahPage(),
      const FollowedMosquesPage(asTab: true),
      const MorePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: "Al-Qur'an",
          ),
          NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque), label: 'Ibadah'),
          NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city),
            label: 'Masjid',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
