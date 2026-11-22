import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';

class HijriPage extends ConsumerStatefulWidget {
  const HijriPage({super.key});

  @override
  ConsumerState<HijriPage> createState() => _HijriPageState();
}

class _HijriPageState extends ConsumerState<HijriPage> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  static const _monthsId = [
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

  static const _monthsEn = [
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

  static const _important = <(int, int), (String, String)>{
    (1, 1): ('Tahun Baru Hijriah', 'Islamic New Year'),
    (1, 10): ("'Asyura", 'Day of Ashura'),
    (3, 12): ('Maulid Nabi', 'Mawlid al-Nabi'),
    (7, 27): ("Isra' Mi'raj", "Isra' and Mi'raj"),
    (9, 1): ('Awal Ramadan', 'Start of Ramadan'),
    (10, 1): ('Idul Fitri', 'Eid al-Fitr'),
    (12, 9): ('Hari Arafah', 'Day of Arafah'),
    (12, 10): ('Idul Adha', 'Eid al-Adha'),
  };

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final offset = ref.watch(settingsProvider).value?.hijriOffset ?? 0;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final first = HijriDate.fromGregorian(_month, offsetDays: offset);
    final ramadan = [
      for (var d = 1; d <= days; d++)
        HijriDate.fromGregorian(DateTime(_month.year, _month.month, d), offsetDays: offset),
    ].where((h) => h.month == 9).firstOrNull;

    final monthHeading = lang == AppLanguage.en
        ? '${_monthsEn[_month.month - 1]} ${_month.year}'
        : '${_monthsId[_month.month - 1]} ${_month.year}';
    final hijriMonthHeading = lang == AppLanguage.en
        ? '${first.monthNameFor(lang)} ${first.year} AH'
        : '${first.monthName} ${first.year} H';

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Kalender Hijriah', 'Hijri Calendar'))),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: context.tr('Bulan sebelumnya', 'Previous month'),
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      monthHeading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(hijriMonthHeading),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('Bulan berikutnya', 'Next month'),
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
              ),
            ],
          ),
          if (ramadan != null)
            Card(
              key: const Key('ramadan-banner'),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang == AppLanguage.en ? 'Ramadan ${ramadan.year} AH' : 'Ramadan ${ramadan.year} H',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            context.tr(
                              'Bulan ini memuat hari-hari Ramadan. Semoga ibadah kita diterima.',
                              'This month includes days of Ramadan. May our worship be accepted.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const BrandArt(BrandIllustration.ramadanMalam4, width: 120, height: 80),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: days,
              itemBuilder: (_, i) {
                final g = DateTime(_month.year, _month.month, i + 1);
                final h = HijriDate.fromGregorian(g, offsetDays: offset);
                final eventPair = _important[(h.month, h.day)];
                final event = eventPair == null ? null : context.tr(eventPair.$1, eventPair.$2);
                return ListTile(
                  dense: true,
                  leading: Text('${g.day}', style: Theme.of(context).textTheme.titleMedium),
                  title: Text(context.hijriText(h)),
                  subtitle: event != null
                      ? Text(event, style: TextStyle(color: Theme.of(context).colorScheme.secondary))
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              context.tr(
                'Koreksi tanggal Hijriah dapat diatur di Pengaturan Jadwal.',
                'Hijri date adjustment can be configured in Prayer Settings.',
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
