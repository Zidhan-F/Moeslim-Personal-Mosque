import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'src/screens.dart';
import 'src/state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await WakelockPlus.enable();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [prefsProvider.overrideWithValue(prefs)], child: const DisplayApp()));
}

class DisplayApp extends StatelessWidget {
  const DisplayApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Moeslim Display',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0B6E4F)),
    // Remote TV: navigasi D-pad memakai fokus bawaan; tombol OK = activate.
    shortcuts: {
      ...WidgetsApp.defaultShortcuts,
      const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
    },
    home: const DisplayRoot(),
  );
}
