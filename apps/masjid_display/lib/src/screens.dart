import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'display_api.dart';
import 'schedule.dart';
import 'state.dart';

const _emerald = Color(0xFF0B6E4F);
const _gold = Color(0xFFC9A227);

String _two(int v) => v.toString().padLeft(2, '0');
String _hm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';
String _hms(Duration d) => '${_two(d.inHours)}:${_two(d.inMinutes % 60)}:${_two(d.inSeconds % 60)}';
const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

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
    return Scaffold(
      backgroundColor: _emerald,
      body: Center(
        child: SizedBox(
          width: 520,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tv, size: 56, color: _emerald),
                  const SizedBox(height: 12),
                  Text('Hubungkan TV Display', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'Buka aplikasi Moeslim Masjid → TV Display → Buat kode pairing, lalu masukkan 6 digit kode di sini.',
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
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Hubungkan', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayScreen extends ConsumerWidget {
  const DisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(nowProvider, (_, next) {
      final n = next.value;
      if (n != null) ref.read(displayControllerProvider.notifier).tick(n);
    });
    // Sinkron pertama saat layar dibuka.
    final state = ref.watch(displayControllerProvider);
    final content = state.content;
    final device = ref.watch(nowProvider).value ?? DateTime.now();

    if (content == null) {
      return Scaffold(
        backgroundColor: _emerald,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                state.offline ? 'Menunggu koneksi untuk sinkron pertama…' : 'Menyinkronkan…',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final mosque = Map<String, dynamic>.from(content['mosque'] as Map);
    final schedule = DisplaySchedule.fromMosque(mosque);
    final now = schedule.wallClock(device.add(state.clockSkew));
    final times = schedule.timesFor(now);
    final status = schedule.statusAt(now);
    final hijri = HijriDate.fromGregorian(now, offsetDays: schedule.hijriOffset);
    final rotation = ((content['device'] as Map?)?['config'] as Map?)?['rotation_seconds'] as int? ?? 12;

    final slides = <(String, String)>[
      for (final a in (content['announcements'] as List? ?? const []).cast<Map>())
        ('Pengumuman: ${a['title']}', '${a['body']}'),
      for (final e in (content['events'] as List? ?? const []).cast<Map>())
        (
          'Agenda: ${e['title']}',
          [
            if (e['starts_at'] != null) _eventTime(schedule, e['starts_at'] as String),
            if (e['speaker'] != null) '${e['speaker']}',
            if (e['location'] != null) '${e['location']}',
          ].join(' • '),
        ),
    ];
    final slide = slides.isEmpty ? null : slides[(now.millisecondsSinceEpoch ~/ 1000 ~/ rotation) % slides.length];
    final finance = content['finance'] as Map?;

    final statusText = switch (status.phase) {
      SchedulePhase.beforeAdhan => 'Menuju azan ${status.prayer.label}',
      SchedulePhase.beforeIqamah => 'Iqamah ${status.prayer.label}',
      SchedulePhase.praying => 'Sholat ${status.prayer.label} sedang berlangsung — mohon luruskan dan rapatkan shaf',
    };

    return Scaffold(
      backgroundColor: const Color(0xFF06261C),
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque['name'] as String,
                          key: const Key('mosque-name'),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${mosque['address'] ?? ''} ${mosque['city'] ?? ''}',
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_hm(now)}:${_two(now.second)}',
                        key: const Key('clock'),
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(hijri.toString(), style: const TextStyle(fontSize: 20, color: _gold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: status.phase == SchedulePhase.beforeAdhan ? _emerald : _gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        statusText,
                        key: const Key('status'),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (status.phase != SchedulePhase.praying)
                      Text(
                        _hms(status.remaining),
                        key: const Key('countdown'),
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _PrayerTile('Imsak', times.imsak, false),
                  for (final p in Prayer.values) _PrayerTile(p.label, times.timeOf(p), p == status.prayer),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Panel(
                        child: slide == null
                            ? const Center(
                                child: Text('Selamat datang. Mari makmurkan masjid.', style: TextStyle(fontSize: 28)),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slide.$1,
                                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _gold),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Text(
                                      slide.$2,
                                      style: const TextStyle(fontSize: 26),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (finance != null || (content['staff_today'] as List? ?? const []).isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _Panel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (finance != null) ...[
                                const Text('Kas Masjid', style: TextStyle(fontSize: 22, color: _gold)),
                                Text(
                                  _rupiah(finance['balance'] as num),
                                  key: const Key('finance-balance'),
                                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                                Text('Masuk bulan ini ${_rupiah(finance['month_in'] as num)}'),
                                Text('Keluar bulan ini ${_rupiah(finance['month_out'] as num)}'),
                                const SizedBox(height: 16),
                              ],
                              for (final s in (content['staff_today'] as List? ?? const []).cast<Map>())
                                Text(
                                  '${_duty(s['duty_type'] as String)}: ${s['name']}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${state.offline ? 'Offline — menampilkan data tersimpan. ' : ''}'
                  'Terakhir sinkron ${state.lastSync != null ? _hm(state.lastSync!) : '-'}',
                  key: const Key('sync-label'),
                  style: TextStyle(fontSize: 14, color: state.offline ? Colors.orangeAccent : Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _eventTime(DisplaySchedule s, String iso) {
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final w = s.wallClock(t);
    return '${_days[w.weekday - 1]}, ${w.day} ${_months[w.month - 1]} ${_hm(w)}';
  }

  static String _duty(String d) => switch (d) {
    'imam' => 'Imam',
    'muadzin' => 'Muadzin',
    'khatib' => 'Khatib',
    'bilal' => 'Bilal',
    _ => d,
  };

  static String _rupiah(num v) {
    final s = v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
    return 'Rp$s';
  }
}

class _PrayerTile extends StatelessWidget {
  final String label;
  final DateTime time;
  final bool active;
  const _PrayerTile(this.label, this.time, this.active);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: active ? _gold : Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 22)),
          Text(_hm(time), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
    child: child,
  );
}
