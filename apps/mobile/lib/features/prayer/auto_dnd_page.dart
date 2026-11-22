import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class AutoDndPage extends ConsumerStatefulWidget {
  const AutoDndPage({super.key});

  @override
  ConsumerState<AutoDndPage> createState() => _AutoDndPageState();
}

class _AutoDndPageState extends ConsumerState<AutoDndPage> {
  AutoDndConfig _config = const AutoDndConfig();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ref.read(autoDndRepoProvider).load();
    if (mounted) {
      setState(() {
        _config = c;
        _loading = false;
      });
    }
  }

  Future<void> _save(AutoDndConfig next) async {
    await ref.read(autoDndRepoProvider).save(next);
    if (mounted) setState(() => _config = next);
  }

  String _windowLabel(BuildContext context, AutoDndWindow w) {
    if (!context.isEn) return w.label;
    if (w.label == 'Salat Jumat') return 'Jumuah Prayer';
    return '${context.prayerLabel(w.prayer)} Prayer';
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(prayerStatusProvider).value;
    final windows = status == null ? const <AutoDndWindow>[] : buildDailyDndWindows(_config, status.today);
    final activeWindow = status == null ? null : windows.where((w) => w.contains(status.now)).firstOrNull;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Mode Hening Waktu Salat', 'Prayer Silent Mode')), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: SwitchListTile(
                    key: const Key('auto-dnd-enable-switch'),
                    secondary: Icon(MoeslimIcons.bisukan, color: scheme.primary),
                    title: Text(
                      context.tr(
                        'Aktifkan Mode Hening Otomatis (Auto DND)',
                        'Enable Automatic Silent Mode (Auto DND)',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      _config.enabled
                          ? (activeWindow != null
                              ? context.tr(
                                  'Sedang aktif untuk ${activeWindow.label} hingga ${hhmm(activeWindow.end)}',
                                  'Active for ${_windowLabel(context, activeWindow)} until ${hhmm(activeWindow.end)}',
                                )
                              : context.tr(
                                  'Siaga menyenyapkan dering saat masuk jendela waktu salat',
                                  'Ready to silence ringer during prayer windows',
                                ))
                          : context.tr(
                              'Nonaktif. Aktifkan agar ponsel hening otomatis saat salat berjamaah.',
                              'Off. Enable to automatically silence your phone during prayer.',
                            ),
                    ),
                    value: _config.enabled,
                    onChanged: (v) => _save(_config.copyWith(enabled: v)),
                  ),
                ),
                SectionHeader(context.tr('Durasi Hening Sebelum & Sesudah Adzan', 'Silent Duration Around Adhan')),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            'Mulai Hening Sebelum Adzan: ${_config.minutesBeforeAdzan} menit',
                            'Start Before Adhan: ${_config.minutesBeforeAdzan} min',
                          ),
                          style: t.titleSmall,
                        ),
                        Slider(
                          min: 0,
                          max: 20,
                          divisions: 4,
                          value: _config.minutesBeforeAdzan.toDouble(),
                          label: context.tr('${_config.minutesBeforeAdzan} mnt', '${_config.minutesBeforeAdzan} min'),
                          onChanged: (v) => _save(_config.copyWith(minutesBeforeAdzan: v.round())),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                            'Durasi Hening Salat Harian: ${_config.minutesAfterAdzan} menit',
                            'Daily Prayer Silent Duration: ${_config.minutesAfterAdzan} min',
                          ),
                          style: t.titleSmall,
                        ),
                        Slider(
                          min: 10,
                          max: 45,
                          divisions: 7,
                          value: _config.minutesAfterAdzan.toDouble(),
                          label: context.tr('${_config.minutesAfterAdzan} mnt', '${_config.minutesAfterAdzan} min'),
                          onChanged: (v) => _save(_config.copyWith(minutesAfterAdzan: v.round())),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                            'Durasi Khusus Salat Jumat: ${_config.fridayDurationMinutes} menit',
                            'Friday (Jumuah) Duration: ${_config.fridayDurationMinutes} min',
                          ),
                          style: t.titleSmall,
                        ),
                        Slider(
                          min: 30,
                          max: 90,
                          divisions: 6,
                          value: _config.fridayDurationMinutes.toDouble(),
                          label: context.tr(
                            '${_config.fridayDurationMinutes} mnt',
                            '${_config.fridayDurationMinutes} min',
                          ),
                          onChanged: (v) => _save(_config.copyWith(fridayDurationMinutes: v.round())),
                        ),
                      ],
                    ),
                  ),
                ),
                SectionHeader(context.tr('Waktu Salat yang Disenyapkan', 'Prayers to Silence')),
                Card(
                  child: Column(
                    children: [
                      for (final p in Prayer.values)
                        CheckboxListTile(
                          key: Key('dnd-prayer-${p.name}'),
                          title: Text(context.tr('Salat ${p.label}', '${context.prayerLabel(p)} Prayer')),
                          value: _config.activePrayers.contains(p),
                          onChanged: (checked) {
                            final next = Set<Prayer>.from(_config.activePrayers);
                            if (checked == true) {
                              next.add(p);
                            } else if (next.length > 1) {
                              next.remove(p);
                            }
                            _save(_config.copyWith(activePrayers: next));
                          },
                        ),
                    ],
                  ),
                ),
                SectionHeader(context.tr('Jendela Waktu Hening Hari Ini', "Today's Silent Windows")),
                if (windows.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        context.tr(
                          'Memuat jadwal salat lokasi aktif...',
                          'Loading prayer schedule for active location...',
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final w in windows)
                          ListTile(
                            leading: Icon(MoeslimIcons.bisukan, color: scheme.primary),
                            title: Text(_windowLabel(context, w), style: const TextStyle(fontWeight: FontWeight.w600)),
                            trailing: Text(
                              '${hhmm(w.start)} – ${hhmm(w.end)}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
