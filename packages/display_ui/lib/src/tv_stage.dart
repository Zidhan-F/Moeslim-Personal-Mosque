import 'dart:math' as math;

import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'schedule.dart';
import 'tv_config.dart';

const _emerald = BrandColors.emerald;
const _gold = BrandColors.gold;
const _deep = BrandColors.deep;

/// Teks di atas latar emas wajib warna deep (kontras 6.2:1); putih di atas emas hanya 2.1:1.
const _onGold = BrandColors.deep;

String _two(int v) => v.toString().padLeft(2, '0');
String _hm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';
String _hms(Duration d) => '${_two(d.inHours)}:${_two(d.inMinutes % 60)}:${_two(d.inSeconds % 60)}';
String _tr(AppLanguage lang, String id, String en) => lang == AppLanguage.en ? en : id;
const _daysId = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
const _daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _monthsId = [
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
const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _duty(String d, AppLanguage lang) => switch (d) {
  'imam' => 'Imam',
  'muadzin' => lang == AppLanguage.en ? 'Muezzin' : 'Muadzin',
  'khatib' => 'Khatib',
  'bilal' => 'Bilal',
  _ => d,
};

String _rupiah(num v) {
  final s = v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  return 'Rp$s';
}

String _dateLine(DateTime now, AppLanguage lang) => lang == AppLanguage.en
    ? '${_daysEn[now.weekday - 1]}, ${_monthsEn[now.month - 1]} ${now.day}, ${now.year}'
    : '${_daysId[now.weekday - 1]}, ${now.day} ${_monthsId[now.month - 1]} ${now.year}';

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
                Icon(MoeslimIcons.lokasi, size: 20 * scale, color: palette.accentText),
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
  final TvDisplayConfig config;
  final Map<String, dynamic> mosque;
  final DateTime now;
  final DisplaySchedule schedule;
  final ScheduleStatus status;
  final List<Map> staff;
  final Map? fridayStaff;
  final AppLanguage lang;
  const _MainScreen({
    super.key,
    required this.palette,
    required this.config,
    required this.mosque,
    required this.now,
    required this.schedule,
    required this.status,
    required this.staff,
    this.fridayStaff,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final times = schedule.timesFor(now);
    final hijri = HijriDate.fromGregorian(now, offsetDays: schedule.hijriOffset);
    final rows = <(String, DateTime, Prayer?)>[
      (Prayer.fajr.labelFor(lang), times.fajr, Prayer.fajr),
      if (config.showSunrise) (_tr(lang, 'Syuruq', 'Sunrise'), times.sunrise, null),
      (Prayer.dhuhr.labelFor(lang), times.dhuhr, Prayer.dhuhr),
      (Prayer.asr.labelFor(lang), times.asr, Prayer.asr),
      (Prayer.maghrib.labelFor(lang), times.maghrib, Prayer.maghrib),
      (Prayer.isha.labelFor(lang), times.isha, Prayer.isha),
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
                        config.showSeconds ? '${_hm(now)}:${_two(now.second)}' : _hm(now),
                        key: const Key('clock'),
                        style: TextStyle(
                          fontSize: config.largeClock ? 190 : 150,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_dateLine(now, lang), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                    if (config.showHijri)
                      Text(
                        hijri.format(lang),
                        key: const Key('tv-hijri'),
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
                                Icon(MoeslimIcons.profil, size: 22, color: palette.accentText),
                                const SizedBox(width: 6),
                                Text(
                                  '${_duty(s['duty_type'] as String, lang)}: ${s['name']}',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              if (config.showIllustration) ...[
                const SizedBox(width: 24),
                Expanded(flex: 6, child: _MosqueIllustration(accent: palette.accent)),
              ],
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
                    border: Border.all(color: palette.accent.withValues(alpha: .35)),
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
                            accent: palette.accent,
                            onAccent: palette.onAccent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _IqamahCard(status: status, palette: palette, lang: lang),
              ),
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
  final Color accent;
  final Color onAccent;
  const _PrayerCard({
    required this.label,
    required this.time,
    required this.active,
    required this.fg,
    this.accent = _gold,
    this.onAccent = _onGold,
  });

  @override
  Widget build(BuildContext context) => Container(
    key: active ? const Key('active-prayer') : null,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: active ? accent : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      boxShadow: active ? [BoxShadow(color: accent.withValues(alpha: .45), blurRadius: 18)] : null,
    ),
    child: DefaultTextStyle.merge(
      style: TextStyle(color: active ? onAccent : fg),
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
  final TvPalette palette;
  final AppLanguage lang;
  const _IqamahCard({required this.status, required this.palette, required this.lang});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status.phase) {
      SchedulePhase.beforeAdhan => (const Color(0xFFFFFDF6), _deep),
      SchedulePhase.beforeIqamah => (palette.accent, palette.onAccent),
      SchedulePhase.praying => (_emerald, Colors.white),
    };
    final prayerLabel = status.prayer.labelFor(lang);
    final title = switch (status.phase) {
      SchedulePhase.beforeAdhan => _tr(lang, 'Menuju azan $prayerLabel', 'Until $prayerLabel Adhan'),
      SchedulePhase.beforeIqamah => _tr(lang, 'Iqamah $prayerLabel', '$prayerLabel Iqamah'),
      SchedulePhase.praying => _tr(lang, 'Sholat $prayerLabel', '$prayerLabel Prayer'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.accent, width: 2),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: Row(
          children: [
            Icon(MoeslimIcons.masjid, size: 56, color: status.phase == SchedulePhase.beforeAdhan ? _emerald : fg),
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
                    Text(
                      _tr(lang, 'Luruskan dan rapatkan shaf', 'Straighten and close the rows'),
                      style: const TextStyle(fontSize: 20),
                    )
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
  final Color accent;
  const _MosqueIllustration({required this.accent});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      key: const Key('tv-mosque-art'),
      foregroundPainter: _ArchBorderPainter(accent),
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
  final Color color;
  _ArchBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * .18, 0)
        ..quadraticBezierTo(w * .02, h * .25, 0, h),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(_ArchBorderPainter old) => old.color != color;
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
  final TvDisplayConfig config;
  final Map<String, dynamic> mosque;
  final DateTime now;
  final DisplaySchedule schedule;
  final List<Map> events;
  final List<Map> announcements;
  final Map? finance;
  final Map? qris;
  final Map? fridayStaff;
  final List<Map> staff;
  final String qrisImageUrl;
  final Map<String, String> qrisHeaders;
  final AppLanguage lang;
  const _InfoScreen({
    super.key,
    required this.palette,
    required this.config,
    required this.mosque,
    required this.now,
    required this.schedule,
    required this.events,
    required this.announcements,
    required this.finance,
    this.qris,
    this.fridayStaff,
    required this.staff,
    required this.qrisImageUrl,
    this.qrisHeaders = const {},
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromGregorian(now, offsetDays: schedule.hijriOffset);
    final fridayItems = ((fridayStaff?['items'] as List?) ?? const []).cast<Map>();
    final hasQris = qris != null && qris!['enabled'] == true;
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
              style: TextStyle(fontSize: config.largeClock ? 100 : 84, fontWeight: FontWeight.w800, height: 1),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateLine(now, lang), style: const TextStyle(fontSize: 24)),
                if (config.showHijri)
                  Text(
                    hijri.format(lang),
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
                  icon: MoeslimIcons.kegiatan,
                  title: _tr(lang, 'Agenda Masjid', 'Mosque Schedule'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fridayItems.isNotEmpty) ...[
                        _FridayStaffCard(
                          key: const Key('friday-staff-board'),
                          dateIso: fridayStaff?['date'] as String?,
                          items: fridayItems,
                          lang: lang,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (events.isEmpty && fridayItems.isEmpty)
                        _Muted(_tr(lang, 'Belum ada agenda terpublikasi', 'No published events yet'))
                      else
                        for (final e in events.take(fridayItems.isNotEmpty ? 2 : 4))
                          _AgendaRow(
                            event: e,
                            start: DateTime.tryParse('${e['starts_at']}'),
                            schedule: schedule,
                            lang: lang,
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: finance != null || hasQris
                    ? _InfoPanel(
                        palette: palette,
                        icon: MoeslimIcons.keuangan,
                        title: finance != null
                            ? _tr(lang, 'Rekap Kas Masjid', 'Mosque Cash Summary')
                            : _tr(lang, 'Infaq Masjid', 'Mosque Donations'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (finance != null) _FinanceSummary(finance: finance!, lang: lang),
                            if (hasQris) ...[
                              if (finance != null) const SizedBox(height: 14),
                              _QrisCard(
                                label: '${qris!['label'] ?? _tr(lang, 'Infaq Masjid', 'Mosque Donations')}',
                                imageUrl: qrisImageUrl,
                                headers: qrisHeaders,
                                lang: lang,
                              ),
                            ],
                          ],
                        ),
                      )
                    : _InfoPanel(
                        palette: palette,
                        icon: MoeslimIcons.petugas,
                        title: _tr(lang, 'Petugas Hari Ini', "Today's Duty Roster"),
                        child: staff.isEmpty
                            ? _Muted(_tr(lang, 'Jadwal petugas belum diisi', 'Duty roster not yet assigned'))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final s in staff)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Text(
                                        '${_duty(s['duty_type'] as String, lang)}: ${s['name']}',
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
                  icon: MoeslimIcons.pengumuman,
                  title: _tr(lang, 'Pengumuman Terbaru', 'Latest Announcements'),
                  child: announcements.isEmpty
                      ? _Muted(_tr(lang, 'Belum ada pengumuman', 'No announcements yet'))
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
      border: Border.all(color: palette.accent.withValues(alpha: .6), width: 1.5),
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
  final AppLanguage lang;
  const _AgendaRow({required this.event, required this.start, required this.schedule, required this.lang});

  static const _shortId = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahd'];
  static const _shortEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  static const _monEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final w = start == null ? null : schedule.wallClock(start!);
    final shortDays = lang == AppLanguage.en ? _shortEn : _shortId;
    final shortMons = lang == AppLanguage.en ? _monEn : _monId;
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
                  Text(shortDays[w.weekday - 1], style: const TextStyle(fontSize: 17)),
                  Text(_two(w.day), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
                  Text(shortMons[w.month - 1], style: const TextStyle(fontSize: 17)),
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
  final AppLanguage lang;
  const _FinanceSummary({required this.finance, required this.lang});

  @override
  Widget build(BuildContext context) {
    final hasWeek = finance['week_in'] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr(lang, 'Saldo kas saat ini', 'Current cash balance'), style: const TextStyle(fontSize: 22)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _rupiah(finance['balance'] as num),
            key: const Key('finance-balance'),
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 14),
        _FlowLine(
          icon: MoeslimIcons.arahAtas,
          label: hasWeek
              ? _tr(lang, 'Pemasukan pekan Jumat', 'Friday week income')
              : _tr(lang, 'Pemasukan bulan ini', 'Income this month'),
          value: _rupiah((hasWeek ? finance['week_in'] : finance['month_in']) as num),
          color: _emerald,
        ),
        const SizedBox(height: 10),
        _FlowLine(
          icon: MoeslimIcons.arahBawah,
          label: hasWeek
              ? _tr(lang, 'Pengeluaran pekan Jumat', 'Friday week expenses')
              : _tr(lang, 'Pengeluaran bulan ini', 'Expenses this month'),
          value: _rupiah((hasWeek ? finance['week_out'] : finance['month_out']) as num),
          color: const Color(0xFFB3261E),
        ),
        const SizedBox(height: 14),
        Text(
          _tr(
            lang,
            'Laporan kas lengkap dapat diminta kepada pengurus masjid.',
            'Full financial reports are available upon request from the mosque committee.',
          ),
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _QrisCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final Map<String, String> headers;
  final AppLanguage lang;
  const _QrisCard({required this.label, required this.imageUrl, this.headers = const {}, required this.lang});

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('tv-qris-card'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _emerald.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _gold.withValues(alpha: .55)),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 112,
            height: 112,
            color: Colors.white,
            padding: const EdgeInsets.all(6),
            child: imageUrl.isEmpty
                ? const Center(child: Icon(Icons.qr_code_2_rounded, size: 72, color: _deep))
                : Image.network(
                    imageUrl,
                    headers: headers,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.qr_code_2_rounded, size: 72, color: _deep)),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan QRIS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _emerald),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                _tr(
                  lang,
                  'Salurkan infaq terbaik langsung ke rekening resmi masjid.',
                  'Give your best charity directly to the official mosque account.',
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FridayStaffCard extends StatelessWidget {
  final String? dateIso;
  final List<Map> items;
  final AppLanguage lang;
  const _FridayStaffCard({super.key, required this.dateIso, required this.items, required this.lang});

  @override
  Widget build(BuildContext context) {
    final parsed = dateIso == null ? null : DateTime.tryParse(dateIso!);
    final dateText = parsed == null
        ? ''
        : (lang == AppLanguage.en
              ? '${_monthsEn[parsed.month - 1]} ${parsed.day}, ${parsed.year}'
              : '${parsed.day} ${_monthsId[parsed.month - 1]} ${parsed.year}');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _emerald.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _emerald.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(MoeslimIcons.petugas, color: _emerald, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateText.isEmpty
                      ? _tr(lang, 'Petugas Salat Jumat', 'Friday Prayer Roster')
                      : _tr(lang, 'Petugas Salat Jumat ($dateText)', 'Friday Prayer Roster ($dateText)'),
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final s in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '${_duty(s['duty_type'] as String, lang)}: ${s['name']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

/// #11 Layar Hening Otomatis saat Salat / Khutbah Jumat (gelap tenang, tidak menyilaukan jemaah).
class TvSilentPrayerScreen extends StatelessWidget {
  final Map<String, dynamic> mosque;
  final ScheduleStatus status;
  final DateTime now;
  final String message;
  final AppLanguage lang;

  const TvSilentPrayerScreen({
    super.key,
    required this.mosque,
    required this.status,
    required this.now,
    required this.message,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final pLabel = status.prayer.labelFor(lang);
    final title = status.isJumuah
        ? _tr(lang, 'Khutbah & Sholat Jumat', 'Friday Sermon & Prayer')
        : _tr(lang, 'Sholat $pLabel', '$pLabel Prayer');
    return Scaffold(
      key: const Key('silent-prayer-screen'),
      backgroundColor: const Color(0xFF020C0A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MoeslimIcons.masjid, size: 80, color: _gold.withValues(alpha: .75)),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: BrandColors.cream, fontSize: 64, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB5C9C2), fontSize: 32, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 36),
              Text(
                '${mosque['name']}  •  ${_hm(now)}',
                style: TextStyle(color: _gold.withValues(alpha: .8), fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// #17 Layar Override Penuh untuk Berita Duka atau Pengumuman Darurat Instan.
class TvOverrideScreen extends StatelessWidget {
  final Map<String, dynamic> mosque;
  final Map<String, dynamic> alert;
  final DateTime now;
  final AppLanguage lang;

  const TvOverrideScreen({super.key, required this.mosque, required this.alert, required this.now, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isDuka = alert['type'] == 'duka';
    final bg = isDuka ? const Color(0xFF0B1917) : const Color(0xFF4A1210);
    final accent = isDuka ? _gold : const Color(0xFFFFCF70);
    return Scaffold(
      key: const Key('tv-override-screen'),
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${mosque['name']}',
                  style: const TextStyle(color: BrandColors.cream, fontSize: 28, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${_hm(now)}:${_two(now.second)}',
                  style: TextStyle(color: accent, fontSize: 36, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const Spacer(),
            if (isDuka)
              Text(
                "Inna Lillahi wa Inna Ilaihi Raji'un",
                textAlign: TextAlign.center,
                style: TextStyle(color: accent, fontSize: 40, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(32)),
                child: Text(
                  _tr(lang, 'PENGUMUMAN PENTING', 'IMPORTANT ANNOUNCEMENT'),
                  style: const TextStyle(color: Color(0xFF2B0A09), fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              '${alert['title']}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w800, height: 1.15),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Text(
                '${alert['body']}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: BrandColors.cream, fontSize: 38, height: 1.4),
              ),
            ),
            const Spacer(),
            Text(
              _tr(lang, 'Disiarkan oleh Pengurus ${mosque['name']}', 'Broadcast by ${mosque['name']} Committee'),
              style: const TextStyle(color: Color(0xFFB5C9C2), fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
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
  final AppLanguage lang;
  const _TickerBar({
    required this.palette,
    required this.text,
    required this.syncText,
    required this.offline,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: palette.accent.withValues(alpha: .6)),
    ),
    child: Row(
      children: [
        Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
          ),
          child: Row(
            children: [
              Icon(MoeslimIcons.pengumuman, color: palette.onAccent, size: 30),
              const SizedBox(width: 8),
              Text(
                _tr(lang, 'Pengumuman', 'Announcements'),
                style: TextStyle(color: palette.onAccent, fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTextStyle.merge(
            style: TextStyle(color: palette.cardFg, fontSize: 24, fontWeight: FontWeight.w500),
            child: text.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _tr(
                        lang,
                        'Selamat datang. Mari makmurkan masjid.',
                        'Welcome. Let us enliven the mosque together.',
                      ),
                    ),
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

/// Layar yang ditampilkan [TvStage].
enum TvScreen { main, info }

/// Tampilan TV lengkap (latar, Layar Utama/Informasi Jamaah, bilah pengumuman) dari konten
/// `/display/content` dan [TvDisplayConfig]. Dirancang untuk kanvas 1920×1080; pratinjau di ponsel
/// cukup membungkusnya dengan `FittedBox`.
class TvStage extends StatelessWidget {
  final Map<String, dynamic> content;
  final TvDisplayConfig config;

  /// Jam dinding masjid (bukan UTC).
  final DateTime now;
  final DisplaySchedule schedule;
  final ScheduleStatus status;
  final TvScreen screen;
  final AppLanguage lang;
  final String syncText;
  final bool offline;

  /// URL & header gambar QRIS (perangkat TV memakai token perangkat).
  final String qrisImageUrl;
  final Map<String, String> qrisHeaders;

  const TvStage({
    super.key,
    required this.content,
    required this.config,
    required this.now,
    required this.schedule,
    required this.status,
    this.screen = TvScreen.main,
    this.lang = AppLanguage.id,
    this.syncText = '',
    this.offline = false,
    this.qrisImageUrl = '',
    this.qrisHeaders = const {},
  });

  Map<String, dynamic> get _mosque => Map<String, dynamic>.from(content['mosque'] as Map);
  List<Map> get _events => (content['events'] as List? ?? const []).cast<Map>();
  List<Map> get _announcements => (content['announcements'] as List? ?? const []).cast<Map>();
  Map? get _fridayStaff => config.showStaff ? content['friday_staff'] as Map? : null;
  List<Map> get _staff => config.showStaff ? (content['staff_today'] as List? ?? const []).cast<Map>() : const [];

  /// Ada isi untuk Layar Informasi Jamaah (dan pengurus mengaktifkannya).
  static bool hasInfo(Map<String, dynamic> content, TvDisplayConfig config) {
    if (!config.showInfoScreen) return false;
    final events = content['events'] as List? ?? const [];
    final announcements = content['announcements'] as List? ?? const [];
    return events.isNotEmpty ||
        announcements.isNotEmpty ||
        content['finance'] != null ||
        content['qris'] != null ||
        (config.showStaff && content['friday_staff'] != null);
  }

  /// Teks bilah berjalan: teks pengurus, pengumuman, lalu agenda.
  String tickerText() => [
    if (config.tickerText.isNotEmpty) config.tickerText,
    for (final a in _announcements) '${a['title']}: ${a['body']}',
    for (final e in _events)
      [
        '${e['title']}',
        if (e['starts_at'] != null) _eventTime(e['starts_at'] as String),
        if (e['speaker'] != null) '${e['speaker']}',
      ].join(' - '),
  ].join('   •   ');

  String _eventTime(String iso) {
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final w = schedule.wallClock(t);
    return lang == AppLanguage.en
        ? '${_daysEn[w.weekday - 1]}, ${_monthsEn[w.month - 1]} ${w.day}, ${_hm(w)}'
        : '${_daysId[w.weekday - 1]}, ${w.day} ${_monthsId[w.month - 1]} ${_hm(w)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = config.palette;
    final mosque = _mosque;
    final body = DefaultTextStyle.merge(
      style: TextStyle(color: palette.fg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: screen == TvScreen.info
                    ? _InfoScreen(
                        key: const ValueKey('info-screen'),
                        palette: palette,
                        config: config,
                        mosque: mosque,
                        now: now,
                        schedule: schedule,
                        events: _events,
                        announcements: _announcements,
                        finance: content['finance'] as Map?,
                        qris: content['qris'] as Map?,
                        fridayStaff: _fridayStaff,
                        staff: _staff,
                        qrisImageUrl: qrisImageUrl,
                        qrisHeaders: qrisHeaders,
                        lang: lang,
                      )
                    : _MainScreen(
                        key: const ValueKey('main-screen'),
                        palette: palette,
                        config: config,
                        mosque: mosque,
                        now: now,
                        schedule: schedule,
                        status: status,
                        staff: _staff,
                        fridayStaff: _fridayStaff,
                        lang: lang,
                      ),
              ),
            ),
            if (config.showTicker) ...[
              const SizedBox(height: 16),
              _TickerBar(palette: palette, text: tickerText(), syncText: syncText, offline: offline, lang: lang),
            ],
          ],
        ),
      ),
    );
    return DecoratedBox(
      key: const Key('tv-stage'),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: palette.background, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: config.showPattern
          ? CustomPaint(painter: _StarPatternPainter(palette.fg.withValues(alpha: .05)), child: body)
          : body,
    );
  }
}
