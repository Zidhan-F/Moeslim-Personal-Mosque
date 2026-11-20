import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'display_api.dart';
import 'schedule.dart';
import 'state.dart';

const _emerald = BrandColors.emerald;
const _gold = BrandColors.gold;
const _deep = BrandColors.deep;

/// Teks di atas latar emas wajib warna deep (kontras 6.2:1); putih di atas emas hanya 2.1:1.
const _onGold = BrandColors.deep;

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
      backgroundColor: _deep,
      body: Center(
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
                  Text('Hubungkan TV Display', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'Di aplikasi Moeslim PM buka Moeslim Mosque → Akun → Konfigurasi TV Display → Hubungkan TV Baru, lalu masukkan 6 digit kode di sini.',
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

/// Palet layar TV per tema perangkat (config.theme): auto = hijau brand, light = krem, dark = hijau malam.
class TvPalette {
  final List<Color> background;
  final Color fg;
  final Color muted;
  final Color card;
  final Color cardFg;
  final Color accentText; // teks aksen (emas di latar gelap, emas-tua di latar terang)
  const TvPalette({
    required this.background,
    required this.fg,
    required this.muted,
    required this.card,
    required this.cardFg,
    required this.accentText,
  });

  static TvPalette of(String? theme) => switch (theme) {
    'light' => const TvPalette(
      background: [BrandColors.cream, Color(0xFFEFEBDD)],
      fg: _deep,
      muted: Color(0xFF3F5A53),
      card: Colors.white,
      cardFg: _deep,
      accentText: BrandColors.goldText,
    ),
    'dark' => const TvPalette(
      background: [BrandColors.nightSurface, Color(0xFF020F0C)],
      fg: BrandColors.cream,
      muted: Color(0xFFB5C9C2),
      card: BrandColors.nightCard,
      cardFg: BrandColors.cream,
      accentText: _gold,
    ),
    _ => const TvPalette(
      background: [_emerald, _deep],
      fg: Colors.white,
      muted: Color(0xFFD5E8E1),
      card: Color(0xFFFFFDF6),
      cardFg: _deep,
      accentText: _gold,
    ),
  };
}

/// Layar TV: bergantian antara Layar Utama (jam, jadwal, iqamah) dan Informasi Jamaah (agenda, kas, pengumuman).
/// Menjelang azan (≤ 10 menit), saat iqamah, dan saat salat berlangsung, Layar Utama dikunci.
class DisplayScreen extends ConsumerWidget {
  const DisplayScreen({super.key});

  static const lockBeforeAdhan = Duration(minutes: 10);

  /// Detik ke-[infoFrom]..59 tiap menit menampilkan Informasi Jamaah (bila tidak dikunci).
  static bool showInfoAt(DateTime now, ScheduleStatus status, {required bool hasInfo}) {
    if (!hasInfo) return false;
    if (status.phase != SchedulePhase.beforeAdhan || status.remaining <= lockBeforeAdhan) return false;
    return now.second >= 40;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(nowProvider, (_, next) {
      final n = next.value;
      if (n != null) ref.read(displayControllerProvider.notifier).tick(n);
    });
    final state = ref.watch(displayControllerProvider);
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
                state.offline ? 'Menunggu koneksi untuk sinkron pertama…' : 'Menyinkronkan…',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    final mosque = Map<String, dynamic>.from(content['mosque'] as Map);
    final config = Map<String, dynamic>.from(((content['device'] as Map?)?['config'] as Map?) ?? const {});
    final palette = TvPalette.of(config['theme'] as String?);
    final schedule = DisplaySchedule.fromMosque(mosque);
    final now = schedule.wallClock(device.add(state.clockSkew));
    final status = schedule.statusAt(now);
    final events = (content['events'] as List? ?? const []).cast<Map>();
    final announcements = (content['announcements'] as List? ?? const []).cast<Map>();
    final finance = content['finance'] as Map?;
    final staff = config['show_staff'] == false
        ? const <Map>[]
        : (content['staff_today'] as List? ?? const []).cast<Map>();
    final info = showInfoAt(now, status, hasInfo: events.isNotEmpty || announcements.isNotEmpty || finance != null);

    final ticker = [
      for (final a in announcements) '${a['title']}: ${a['body']}',
      for (final e in events)
        [
          '${e['title']}',
          if (e['starts_at'] != null) _eventTime(schedule, e['starts_at'] as String),
          if (e['speaker'] != null) '${e['speaker']}',
        ].join(' — '),
    ].join('   •   ');

    final syncText =
        '${state.offline ? 'Offline — menampilkan data tersimpan. ' : ''}'
        'Terakhir sinkron ${state.lastSync != null ? _hm(state.lastSync!) : '-'}';

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: palette.background, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: CustomPaint(
          painter: _StarPatternPainter(palette.fg.withValues(alpha: .05)),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: palette.fg),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: info
                          ? _InfoScreen(
                              key: const ValueKey('info-screen'),
                              palette: palette,
                              mosque: mosque,
                              now: now,
                              schedule: schedule,
                              events: events,
                              announcements: announcements,
                              finance: finance,
                              staff: staff,
                            )
                          : _MainScreen(
                              key: const ValueKey('main-screen'),
                              palette: palette,
                              mosque: mosque,
                              now: now,
                              schedule: schedule,
                              status: status,
                              staff: staff,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TickerBar(palette: palette, text: ticker, syncText: syncText, offline: state.offline),
                ],
              ),
            ),
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
}

String _duty(String d) => switch (d) {
  'imam' => 'Imam',
  'muadzin' => 'Muadzin',
  'khatib' => 'Khatib',
  'bilal' => 'Bilal',
  _ => d,
};

String _rupiah(num v) {
  final s = v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  return 'Rp$s';
}

String _dateLine(DateTime now) => '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';

/// Identitas: logo + "Moeslim Mosque" + nama masjid + kota.
class _Identity extends StatelessWidget {
  final TvPalette palette;
  final Map<String, dynamic> mosque;
  final double scale;
  const _Identity({required this.palette, required this.mosque, this.scale = 1});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      BrandLogo(variant: BrandLogoVariant.symbol, height: 76 * scale, onDark: palette.fg != _deep),
      const SizedBox(width: 16),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moeslim Mosque',
              style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w600, color: palette.muted),
            ),
            Text(
              mosque['name'] as String,
              key: const Key('mosque-name'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 34 * scale, fontWeight: FontWeight.w800, height: 1.1),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 20 * scale, color: palette.accentText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    [mosque['address'], mosque['city']].whereType<String>().join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18 * scale, color: palette.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _MainScreen extends StatelessWidget {
  final TvPalette palette;
  final Map<String, dynamic> mosque;
  final DateTime now;
  final DisplaySchedule schedule;
  final ScheduleStatus status;
  final List<Map> staff;
  const _MainScreen({
    super.key,
    required this.palette,
    required this.mosque,
    required this.now,
    required this.schedule,
    required this.status,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final times = schedule.timesFor(now);
    final hijri = HijriDate.fromGregorian(now, offsetDays: schedule.hijriOffset);
    final rows = <(String, DateTime, Prayer?)>[
      ('Subuh', times.fajr, Prayer.fajr),
      ('Syuruq', times.sunrise, null),
      ('Dzuhur', times.dhuhr, Prayer.dhuhr),
      ('Ashar', times.asr, Prayer.asr),
      ('Maghrib', times.maghrib, Prayer.maghrib),
      ('Isya', times.isha, Prayer.isha),
    ];
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Identity(palette: palette, mosque: mosque),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_hm(now)}:${_two(now.second)}',
                        key: const Key('clock'),
                        style: const TextStyle(
                          fontSize: 150,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_dateLine(now), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                    Text(
                      hijri.toString(),
                      style: TextStyle(fontSize: 28, color: palette.accentText, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (staff.isNotEmpty)
                      Wrap(
                        spacing: 24,
                        runSpacing: 4,
                        children: [
                          for (final s in staff)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person, size: 22, color: palette.accentText),
                                const SizedBox(width: 6),
                                Text(
                                  '${_duty(s['duty_type'] as String)}: ${s['name']}',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(flex: 6, child: _MosqueIllustration()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.fg == _deep ? _emerald.withValues(alpha: .1) : Colors.black.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withValues(alpha: .35)),
                  ),
                  child: Row(
                    children: [
                      for (final r in rows)
                        Expanded(
                          child: _PrayerCard(
                            label: r.$1,
                            time: r.$2,
                            active: r.$3 != null && r.$3 == status.prayer,
                            fg: palette.fg == _deep ? _deep : Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _IqamahCard(status: status)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String label;
  final DateTime time;
  final bool active;
  final Color fg;
  const _PrayerCard({required this.label, required this.time, required this.active, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    key: active ? const Key('active-prayer') : null,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: active ? _gold : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      boxShadow: active ? [BoxShadow(color: _gold.withValues(alpha: .45), blurRadius: 18)] : null,
    ),
    child: DefaultTextStyle.merge(
      style: TextStyle(color: active ? _onGold : fg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_hm(time), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    ),
  );
}

/// Kartu status di kanan jadwal: menuju azan (krem), iqamah (emas, teks deep), salat berlangsung (emerald).
class _IqamahCard extends StatelessWidget {
  final ScheduleStatus status;
  const _IqamahCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status.phase) {
      SchedulePhase.beforeAdhan => (const Color(0xFFFFFDF6), _deep),
      SchedulePhase.beforeIqamah => (_gold, _onGold),
      SchedulePhase.praying => (_emerald, Colors.white),
    };
    final title = switch (status.phase) {
      SchedulePhase.beforeAdhan => 'Menuju azan ${status.prayer.label}',
      SchedulePhase.beforeIqamah => 'Iqamah ${status.prayer.label}',
      SchedulePhase.praying => 'Sholat ${status.prayer.label}',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold, width: 2),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: Row(
          children: [
            Icon(Icons.mosque, size: 56, color: status.phase == SchedulePhase.beforeAdhan ? _emerald : fg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    key: const Key('status'),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.15),
                  ),
                  if (status.phase == SchedulePhase.praying)
                    const Text('Luruskan dan rapatkan shaf', style: TextStyle(fontSize: 20))
                  else
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _hms(status.remaining),
                        key: const Key('countdown'),
                        style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, height: 1.1),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto/ilustrasi masjid dalam bingkai lengkung berpinggiran emas (sisi kanan layar utama).
class _MosqueIllustration extends StatelessWidget {
  const _MosqueIllustration();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      key: const Key('tv-mosque-art'),
      foregroundPainter: _ArchBorderPainter(),
      child: ClipPath(
        clipper: _ArchClipper(),
        child: const BrandArt(BrandIllustration.tvMosque, fit: BoxFit.cover, alignment: Alignment.bottomCenter),
      ),
    ),
  );
}

Path _archPath(Size size) {
  final w = size.width, h = size.height;
  return Path()
    ..moveTo(w * .18, 0)
    ..lineTo(w - 24, 0)
    ..quadraticBezierTo(w, 0, w, 24)
    ..lineTo(w, h - 24)
    ..quadraticBezierTo(w, h, w - 24, h)
    ..lineTo(0, h)
    ..quadraticBezierTo(w * .02, h * .25, w * .18, 0)
    ..close();
}

class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _archPath(size);

  @override
  bool shouldReclip(_ArchClipper old) => false;
}

class _ArchBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * .18, 0)
        ..quadraticBezierTo(w * .02, h * .25, 0, h),
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(_ArchBorderPainter old) => false;
}

/// Pola bintang delapan halus untuk latar.
class _StarPatternPainter extends CustomPainter {
  final Color color;
  _StarPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 64.0;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var y = 0.0; y < size.height + cell; y += cell) {
      for (var x = 0.0; x < size.width * .45; x += cell) {
        final c = Offset(x + cell / 2, y + cell / 2);
        for (final rot in [0.0, math.pi / 4]) {
          final path = Path();
          for (var i = 0; i < 4; i++) {
            final a = rot + i * math.pi / 2;
            final pt = c + Offset(math.cos(a), math.sin(a)) * cell * .4;
            i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
          }
          canvas.drawPath(path..close(), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_StarPatternPainter old) => old.color != color;
}

class _InfoScreen extends StatelessWidget {
  final TvPalette palette;
  final Map<String, dynamic> mosque;
  final DateTime now;
  final DisplaySchedule schedule;
  final List<Map> events;
  final List<Map> announcements;
  final Map? finance;
  final List<Map> staff;
  const _InfoScreen({
    super.key,
    required this.palette,
    required this.mosque,
    required this.now,
    required this.schedule,
    required this.events,
    required this.announcements,
    required this.finance,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromGregorian(now, offsetDays: schedule.hijriOffset);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Identity(palette: palette, mosque: mosque, scale: .9),
            ),
            Text(
              _hm(now),
              key: const Key('clock'),
              style: const TextStyle(fontSize: 84, fontWeight: FontWeight.w800, height: 1),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateLine(now), style: const TextStyle(fontSize: 24)),
                Text(
                  hijri.toString(),
                  style: TextStyle(fontSize: 24, color: palette.accentText, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _InfoPanel(
                  palette: palette,
                  icon: Icons.event_note,
                  title: 'Agenda Masjid',
                  child: events.isEmpty
                      ? const _Muted('Belum ada agenda terpublikasi')
                      : Column(
                          children: [
                            for (final e in events.take(4))
                              _AgendaRow(event: e, start: DateTime.tryParse('${e['starts_at']}'), schedule: schedule),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: finance != null
                    ? _InfoPanel(
                        palette: palette,
                        icon: Icons.account_balance_wallet,
                        title: 'Rekap Kas Masjid',
                        child: _FinanceSummary(finance: finance!),
                      )
                    : _InfoPanel(
                        palette: palette,
                        icon: Icons.badge,
                        title: 'Petugas Hari Ini',
                        child: staff.isEmpty
                            ? const _Muted('Jadwal petugas belum diisi')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final s in staff)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Text(
                                        '${_duty(s['duty_type'] as String)} — ${s['name']}',
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _InfoPanel(
                  palette: palette,
                  icon: Icons.campaign,
                  title: 'Pengumuman Terbaru',
                  child: announcements.isEmpty
                      ? const _Muted('Belum ada pengumuman')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final a in announcements.take(3))
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _gold.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${a['title']}',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '${a['body']}',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 19),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final TvPalette palette;
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoPanel({required this.palette, required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _gold.withValues(alpha: .6), width: 1.5),
    ),
    child: DefaultTextStyle.merge(
      style: TextStyle(color: palette.cardFg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: palette.cardFg == _deep ? _emerald : _gold, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRect(
              child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: child),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Muted extends StatelessWidget {
  final String text;
  const _Muted(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic));
}

class _AgendaRow extends StatelessWidget {
  final Map event;
  final DateTime? start;
  final DisplaySchedule schedule;
  const _AgendaRow({required this.event, required this.start, required this.schedule});

  static const _short = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahd'];
  static const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  Widget build(BuildContext context) {
    final w = start == null ? null : schedule.wallClock(start!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (w != null)
            Container(
              width: 74,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: _gold.withValues(alpha: .18), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text(_short[w.weekday - 1], style: const TextStyle(fontSize: 17)),
                  Text(_two(w.day), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
                  Text(_mon[w.month - 1], style: const TextStyle(fontSize: 17)),
                ],
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${event['title']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                if (event['speaker'] != null) Text('${event['speaker']}', style: const TextStyle(fontSize: 19)),
                Text(
                  [if (w != null) _hm(w), ?event['location'] as String?].join(' • '),
                  style: const TextStyle(fontSize: 19),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceSummary extends StatelessWidget {
  final Map finance;
  const _FinanceSummary({required this.finance});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Saldo kas saat ini', style: TextStyle(fontSize: 22)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _rupiah(finance['balance'] as num),
          key: const Key('finance-balance'),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 18),
      _FlowLine(
        icon: Icons.arrow_upward,
        label: 'Pemasukan bulan ini',
        value: _rupiah(finance['month_in'] as num),
        color: _emerald,
      ),
      const SizedBox(height: 10),
      _FlowLine(
        icon: Icons.arrow_downward,
        label: 'Pengeluaran bulan ini',
        value: _rupiah(finance['month_out'] as num),
        color: const Color(0xFFB3261E),
      ),
      const SizedBox(height: 18),
      const Text(
        'Laporan kas lengkap dapat diminta kepada pengurus masjid.',
        style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
      ),
    ],
  );
}

class _FlowLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _FlowLine({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 20))),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    ),
  );
}

/// Bilah pengumuman berjalan + label sinkron.
class _TickerBar extends StatelessWidget {
  final TvPalette palette;
  final String text;
  final String syncText;
  final bool offline;
  const _TickerBar({required this.palette, required this.text, required this.syncText, required this.offline});

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: _gold.withValues(alpha: .6)),
    ),
    child: Row(
      children: [
        Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: const BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
          ),
          child: const Row(
            children: [
              Icon(Icons.campaign, color: _onGold, size: 30),
              SizedBox(width: 8),
              Text(
                'Pengumuman',
                style: TextStyle(color: _onGold, fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTextStyle.merge(
            style: TextStyle(color: palette.cardFg, fontSize: 24, fontWeight: FontWeight.w500),
            child: text.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Selamat datang. Mari makmurkan masjid.'),
                  )
                : _Marquee(text: text),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            syncText,
            key: const Key('sync-label'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: offline ? FontWeight.w700 : FontWeight.w400,
              color: offline ? const Color(0xFFB3261E) : palette.cardFg.withValues(alpha: .7),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Teks berjalan satu baris (satu widget Text, digeser animasi; berhenti bila teks muat).
class _Marquee extends StatefulWidget {
  final String text;
  const _Marquee({required this.text});

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    return LayoutBuilder(
      builder: (context, box) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final textW = tp.width;
        final viewW = box.maxWidth;
        final label = Text(widget.text, maxLines: 1, softWrap: false, overflow: TextOverflow.visible);
        if (textW <= viewW - 40) {
          _c.stop();
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: const EdgeInsets.only(left: 20), child: label),
          );
        }
        final distance = textW + viewW;
        final duration = Duration(milliseconds: (distance / 90 * 1000).round()); // ±90 px/detik
        if (_c.duration != duration || !_c.isAnimating) {
          _c.duration = duration;
          _c.repeat();
        }
        return ClipRect(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) => Transform.translate(offset: Offset(viewW - _c.value * distance, 0), child: child),
            child: OverflowBox(alignment: Alignment.centerLeft, minWidth: textW, maxWidth: textW, child: label),
          ),
        );
      },
    );
  }
}
