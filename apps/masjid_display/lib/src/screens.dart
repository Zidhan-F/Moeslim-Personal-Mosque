import 'package:display_ui/display_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'display_api.dart';
import 'state.dart';

const _gold = BrandColors.gold;
const _deep = BrandColors.deep;

String _two(int v) => v.toString().padLeft(2, '0');
String _hm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';
String _tr(AppLanguage lang, String id, String en) => lang == AppLanguage.en ? en : id;

class DisplayRoot extends ConsumerWidget {
  const DisplayRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paired = ref.watch(displayControllerProvider.select((s) => s.paired));
    return paired ? const DisplayScreen() : const PairingScreen();
  }
}

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(displayControllerProvider.notifier).pair(_code.text.trim());
    } on DisplayApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayControllerProvider.select((s) => s.effectiveLanguage));
    return Scaffold(
      backgroundColor: _deep,
      body: Stack(
        children: [
          Positioned(
            top: 24,
            right: 28,
            child: OutlinedButton(
              key: const Key('tv-language-toggle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: BrandColors.cream,
                side: BorderSide(color: _gold.withValues(alpha: .7)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => ref
                  .read(displayControllerProvider.notifier)
                  .setLanguage(lang == AppLanguage.en ? AppLanguage.id : AppLanguage.en),
              child: Text(
                lang == AppLanguage.en ? 'EN / ID' : 'ID / EN',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 520,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandLogo(height: 72, onDark: false),
                      const SizedBox(height: 12),
                      Text(
                        _tr(lang, 'Hubungkan TV Display', 'Connect TV Display'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tr(
                          lang,
                          'Di aplikasi Moeslim PM buka Moeslim Mosque → Akun → Konfigurasi TV Display → Hubungkan TV Baru, lalu masukkan 6 digit kode di sini.',
                          'In the Moeslim PM app, open Moeslim Mosque → Account → TV Display Settings → Connect New TV, then enter the 6-digit code here.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('pair-code'),
                        controller: _code,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 36, letterSpacing: 12),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      FilledButton(
                        key: const Key('pair-submit'),
                        onPressed: _busy ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_tr(lang, 'Hubungkan', 'Connect'), style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Callback sinyal suara iqamah/masuk salat (di-override di test).
final beepCallbackProvider = Provider<VoidCallback>(
  (ref) =>
      () => SystemSound.play(SystemSoundType.alert),
);

/// Layar TV: bergantian antara Layar Utama (jam, jadwal, iqamah) dan Informasi Jamaah (agenda, kas, pengumuman).
/// Mendukung Override Berita Duka/Darurat (#17), Layar Hening Otomatis Saat Salat/Khutbah Jumat (#11),
/// Sinyal Beep Iqamah (#12), QRIS & Kas Jumat (#15), serta Papan Petugas Jumat (#16).
/// Tema warna & widget mengikuti `device.config` yang diatur pengurus dari aplikasi (lihat [TvDisplayConfig]).
class DisplayScreen extends ConsumerStatefulWidget {
  const DisplayScreen({super.key});

  static const lockBeforeAdhan = Duration(minutes: 10);

  /// [infoSeconds] terakhir tiap menit menampilkan Informasi Jamaah (bila tidak dikunci).
  static bool showInfoAt(DateTime now, ScheduleStatus status, {required bool hasInfo, int infoSeconds = 20}) {
    if (!hasInfo) return false;
    if (status.phase != SchedulePhase.beforeAdhan || status.remaining <= lockBeforeAdhan) return false;
    return now.second >= 60 - infoSeconds;
  }

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  SchedulePhase? _lastPhase;
  Prayer? _lastPrayer;

  static Map<String, dynamic>? _activeOverride(Map<String, dynamic> content, DateTime deviceUtc) {
    final raw = content['override'];
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final exp = DateTime.tryParse('${map['expires_at'] ?? ''}');
    if (exp == null || !exp.isAfter(deviceUtc)) return null;
    return map;
  }

  void _checkBeep(ScheduleStatus status, {required bool enabled}) {
    final prevPhase = _lastPhase;
    final prevPrayer = _lastPrayer;
    _lastPhase = status.phase;
    _lastPrayer = status.prayer;
    if (!enabled || prevPhase == null) return;
    final enteredIqamah = prevPhase == SchedulePhase.beforeAdhan && status.phase == SchedulePhase.beforeIqamah;
    final enteredPraying =
        prevPhase == SchedulePhase.beforeIqamah && status.phase == SchedulePhase.praying && prevPrayer == status.prayer;
    if (enteredIqamah || enteredPraying) {
      ref.read(beepCallbackProvider)();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(nowProvider, (_, next) {
      final n = next.value;
      if (n != null) ref.read(displayControllerProvider.notifier).tick(n);
    });
    final state = ref.watch(displayControllerProvider);
    final lang = state.effectiveLanguage;
    final content = state.content;
    final device = ref.watch(nowProvider).value ?? ref.read(clockProvider)();

    if (content == null) {
      return Scaffold(
        backgroundColor: _deep,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                state.offline
                    ? _tr(lang, 'Menunggu koneksi untuk sinkron pertama…', 'Waiting for connection for initial sync...')
                    : _tr(lang, 'Menyinkronkan…', 'Syncing...'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final mosque = Map<String, dynamic>.from(content['mosque'] as Map);
    final mosqueSettings = Map<String, dynamic>.from((mosque['settings'] as Map?) ?? const {});
    final config = TvDisplayConfig.fromJson(
      Map<String, dynamic>.from(((content['device'] as Map?)?['config'] as Map?) ?? const {}),
    );
    final schedule = DisplaySchedule.fromMosque(mosque);
    final correctedUtc = device.add(state.clockSkew);
    final now = schedule.wallClock(correctedUtc);
    final status = schedule.statusAt(now);

    final beepEnabled = mosqueSettings['iqamah_beep'] as bool? ?? true;
    _checkBeep(status, enabled: beepEnabled);

    // #17 Prioritas tertinggi: Override Berita Duka / Pengumuman Darurat.
    final alertData = _activeOverride(content, correctedUtc);
    if (alertData != null) {
      return TvOverrideScreen(mosque: mosque, alert: alertData, now: now, lang: lang);
    }

    // #11 Mode Layar Hening Otomatis Saat Salat & Khutbah Jumat.
    final silentEnabled = mosqueSettings['silent_prayer_screen'] as bool? ?? true;
    if (status.phase == SchedulePhase.praying && silentEnabled) {
      final msg =
          mosqueSettings['silent_prayer_message'] as String? ??
          _tr(
            lang,
            'Luruskan & Rapatkan Shaf • Harap Tenangkan Ponsel',
            'Straighten & Close the Rows • Please Silence Your Phone',
          );
      return TvSilentPrayerScreen(mosque: mosque, status: status, now: now, message: msg, lang: lang);
    }

    final info = DisplayScreen.showInfoAt(
      now,
      status,
      hasInfo: TvStage.hasInfo(content, config),
      infoSeconds: config.infoSeconds,
    );

    final syncText = lang == AppLanguage.en
        ? '${state.offline ? 'Offline: showing cached data. ' : ''}'
              'Last synced ${state.lastSync != null ? _hm(state.lastSync!) : '-'}'
        : '${state.offline ? 'Offline: menampilkan data tersimpan. ' : ''}'
              'Terakhir sinkron ${state.lastSync != null ? _hm(state.lastSync!) : '-'}';

    final baseUrl = ref.read(displayApiProvider).baseUrl;
    final token = state.token;

    return Scaffold(
      body: TvStage(
        content: content,
        config: config,
        now: now,
        schedule: schedule,
        status: status,
        screen: info ? TvScreen.info : TvScreen.main,
        lang: lang,
        syncText: syncText,
        offline: state.offline,
        qrisImageUrl: '$baseUrl/display/qris',
        qrisHeaders: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }
}
