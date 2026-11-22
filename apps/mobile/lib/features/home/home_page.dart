import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/location_service.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../../ui/core_nav.dart';
import '../ibadah/doa_pages.dart';
import '../ibadah/guided_dzikir_page.dart';
import '../ibadah/qibla_page.dart';
import '../ibadah/utility_accessibility_page.dart';
import '../prayer/prayer_page.dart';
import '../quran/quran_source.dart';
import 'all_features_page.dart';

/// 30 ayat pilihan dari 30 surah dan ayat yang berbeda-beda (diambil dari dataset terpasang).
const dailyAyahRefs = <(int, int)>[
  (2, 152),
  (3, 139),
  (7, 56),
  (9, 51),
  (13, 28),
  (14, 7),
  (16, 97),
  (20, 114),
  (25, 63),
  (29, 69),
  (31, 17),
  (33, 41),
  (39, 53),
  (41, 34),
  (49, 10),
  (55, 60),
  (59, 18),
  (64, 11),
  (93, 3),
  (99, 7),
  (8, 46),
  (17, 9),
  (23, 1),
  (40, 60),
  (50, 16),
  (51, 56),
  (57, 4),
  (65, 3),
  (94, 5),
  (103, 3),
];

/// Interval pergantian otomatis ayat acak di bagian bawah Beranda.
const dailyAyahRotationInterval = Duration(seconds: 8);

/// Generator acak untuk rotasi ayat Beranda (dapat di-override saat pengujian).
final dailyAyahRandomProvider = Provider<math.Random>((_) => math.Random());

/// Memuat seluruh koleksi 30 ayat pilihan dari dataset Al-Qur'an lokal.
final dailyAyahPoolProvider = FutureProvider<List<Ayah>>((ref) async {
  final source = ref.watch(quranSourceProvider);
  final uniqueSurahs = {for (final (s, _) in dailyAyahRefs) s};
  final loaded = <int, List<Ayah>?>{};
  await Future.wait([for (final s in uniqueSurahs) source.load(s).then((ayat) => loaded[s] = ayat)]);
  return [
    for (final (s, a) in dailyAyahRefs)
      if (loaded[s] != null &&
          a <= loaded[s]!.length &&
          ((loaded[s]![a - 1].translation?.isNotEmpty ?? false) ||
              (loaded[s]![a - 1].translationEn?.isNotEmpty ?? false)))
        loaded[s]![a - 1],
  ];
});

final dailyAyahProvider = FutureProvider<Ayah?>((ref) async {
  final pool = await ref.watch(dailyAyahPoolProvider.future);
  if (pool.isEmpty) return null;
  final day = DateTime.now().difference(DateTime(2024)).inDays;
  return pool[day % pool.length];
});

class HomePage extends ConsumerWidget {
  final void Function(int tab) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CoreSwitcher(
          current: AppCore.personal,
          onSelected: (c) => switchCore(context, c, from: AppCore.personal),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _Greeting(name: settings?.displayName),
          Transform.translate(offset: const Offset(0, -18), child: const _LivePrayerCard()),
          SectionHeader(context.tr('Menu Cepat', 'Quick Menu')),
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(1);
              final cols = constraints.maxWidth >= 280 * scale ? 4 : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 110 * scale,
                children: [
                  MenuTile(
                    key: const Key('quick-alquran'),
                    tile: BrandTile.alquran,
                    label: context.tr("Al-Qur'an", "Qur'an"),
                    onTap: () => onNavigate(1),
                  ),
                  MenuTile(
                    key: const Key('quick-doa-dzikir'),
                    tile: BrandTile.doaDzikir,
                    label: context.tr('Doa & Dzikir', 'Duas & Dhikr'),
                    onTap: () => push(const DoaListPage()),
                  ),
                  MenuTile(
                    key: const Key('quick-arah-kiblat'),
                    tile: BrandTile.arahKiblat,
                    label: context.tr('Arah Kiblat', 'Qibla'),
                    onTap: () => push(const QiblaPage()),
                  ),
                  MenuTile(
                    key: const Key('quick-lihat-semua'),
                    tile: BrandTile.lihatSemua,
                    label: context.tr('Lihat Semua', 'See All'),
                    onTap: () => push(AllFeaturesPage(onNavigate: onNavigate)),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const _ContextualSunnahHomeCard(),
          const SizedBox(height: 12),
          const _DailyAyah(),
        ],
      ),
    );
  }
}

class _ContextualSunnahHomeCard extends ConsumerWidget {
  const _ContextualSunnahHomeCard();

  static ({String window, String title, String subtitle}) _localizeAdvice(
    BuildContext context,
    ContextualSunnahAdvice advice,
  ) {
    if (!context.isEn) {
      return (window: advice.timeWindowLabel, title: advice.title, subtitle: advice.subtitle);
    }
    return switch (advice.id) {
      'tahajud_sahur' => (
        window: 'Last Third of the Night & Suhoor',
        title: 'Blessed Time for Tahajjud, Witr & Istighfar',
        subtitle: 'Ask Allah in quiet supplication and seek forgiveness during the pre-dawn hours.',
      ),
      'dzikir_pagi' => (
        window: 'Morning After Fajr',
        title: 'Morning Dhikr & Early Charity',
        subtitle: 'Start your day with Ayat al-Kursi, Sayyid al-Istighfar, and guided morning remembrance.',
      ),
      'salat_dhuha' => (
        window: 'Mid-Morning',
        title: 'Time for Dhuha Prayer (2-8 Rakaat)',
        subtitle: 'Two rakaat of Dhuha fulfill the charity due for every joint in your body today.',
      ),
      'dzikir_petang' => (
        window: 'Evening After Asr',
        title: 'Guided Evening Dhikr',
        subtitle: 'Protect your evening and night with authentic prophetic evening remembrance.',
      ),
      'almulk_muhasabah' => (
        window: 'Before Sleeping',
        title: 'Recite Surah Al-Mulk, Make Wudu & Reflect',
        subtitle: 'Recite Surah Al-Mulk (30 verses) and close the night with quiet self-reflection.',
      ),
      'dzikrullah_siang' => (
        window: 'Midday',
        title: 'Pray on Time & Keep Your Tongue in Dhikr',
        subtitle: 'Prepare for the Dhuhr and Asr call to prayer and remember Allah between daily tasks.',
      ),
      'sunnah_jumat' => (
        window: 'Blessings of Friday',
        title: 'Recite Surah Al-Kahf & Send Salawat',
        subtitle:
            'Friday is the best day of the week. Read Al-Kahf, send blessings on the Prophet, and pray before Maghrib.',
      ),
      _ => (window: advice.timeWindowLabel, title: advice.title, subtitle: advice.subtitle),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final advice = evaluateContextualSunnahForTime(now).first;
    final localized = _localizeAdvice(context, advice);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Card(
      key: const Key('home-contextual-sunnah-card'),
      child: ListTile(
        leading: Icon(MoeslimIcons.bintang, color: scheme.primary),
        title: Text(localized.title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('${localized.window} · ${localized.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => advice.actionType == 'dzikir_pagi'
                ? const GuidedDzikirPage(initialTime: GuidedDzikirTime.pagi)
                : (advice.actionType == 'dzikir_petang'
                      ? const GuidedDzikirPage(initialTime: GuidedDzikirTime.petang)
                      : const UtilityAccessibilityPage(initialTab: 4)),
          ),
        ),
      ),
    );
  }
}

class _LivePrayerCard extends ConsumerStatefulWidget {
  const _LivePrayerCard();

  @override
  ConsumerState<_LivePrayerCard> createState() => _LivePrayerCardState();
}

class _LivePrayerCardState extends ConsumerState<_LivePrayerCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = ref.read(settingsProvider).value;
      if (settings != null && settings.useDeviceLocation) {
        unawaited(ref.read(gpsControllerProvider.notifier).ensureActive());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(prayerStatusProvider);
    final settings = ref.watch(settingsProvider).value;
    final lang = context.lang;
    return status.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(context.tr('Gagal memuat jadwal: $e', 'Failed to load prayer times: $e')),
      data: (s) => _PrayerCard(
        status: s,
        city: localizeLocationLabel(settings?.effectiveLocationName ?? '', lang),
        isGps: settings?.isUsingGpsLocation ?? false,
        hijri: context.hijriText(HijriDate.fromGregorian(s.now, offsetDays: settings?.hijriOffset ?? 0)),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String? name;
  const _Greeting({required this.name});

  @override
  Widget build(BuildContext context) => PatternBanner(
    key: const Key('greeting'),
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Assalamu'alaikum", style: TextStyle(color: BrandColors.cream, fontSize: 15)),
              Text(
                name?.isNotEmpty == true ? name! : context.tr('Sahabat Moeslim', 'Fellow Muslim'),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('Semoga hari ini penuh keberkahan.', 'May your day be filled with blessings.'),
                style: const TextStyle(color: BrandColors.cream, fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.textScalerOf(context).scale(14) > 16 ? 72 : 120,
          height: 84,
          child: const BrandArt(BrandIllustration.skyline, fit: BoxFit.contain, alignment: Alignment.bottomRight),
        ),
      ],
    ),
  );
}

class _PrayerCard extends StatelessWidget {
  final PrayerStatus status;
  final String city;
  final bool isGps;
  final String hijri;
  const _PrayerCard({required this.status, required this.city, this.isGps = false, required this.hijri});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final rows = <(String, DateTime, Prayer?)>[
      (context.prayerLabel(Prayer.fajr), status.today.fajr, Prayer.fajr),
      (context.tr('Syuruq', 'Sunrise'), status.today.sunrise, null),
      (context.prayerLabel(Prayer.dhuhr), status.today.dhuhr, Prayer.dhuhr),
      (context.prayerLabel(Prayer.asr), status.today.asr, Prayer.asr),
      (context.prayerLabel(Prayer.maghrib), status.today.maghrib, Prayer.maghrib),
      (context.prayerLabel(Prayer.isha), status.today.isha, Prayer.isha),
    ];
    return Card(
      key: const Key('prayer-card'),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final columns = (constraints.maxWidth / (52 * scale)).floor().clamp(2, 6);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    InkWell(
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(MoeslimIcons.lokasi, size: 18, color: scheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              context.tr('Waktu Salat di $city', 'Prayer Times in $city'),
                              style: t.labelLarge,
                            ),
                          ),
                          if (isGps) ...[
                            const SizedBox(width: 6),
                            Container(
                              key: const Key('home-gps-badge'),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'GPS',
                                style: TextStyle(color: scheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                          const Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.longDateText(status.now), style: t.bodySmall),
                        Text(hijri, style: t.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: BrandColors.gold.withValues(alpha: .15), shape: BoxShape.circle),
                      child: const Icon(MoeslimIcons.masjid, color: BrandColors.goldText, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('Sekarang', 'Now'),
                            style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              hhmmss(status.now),
                              key: const Key('now-clock'),
                              style: t.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: BrandColors.gold.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.tr(
                              'Menuju ${context.prayerLabel(status.nextPrayer)}',
                              'Next ${context.prayerLabel(status.nextPrayer)}',
                            ),
                            style: t.titleSmall,
                          ),
                          Text(
                            context.tr('pukul ${hhmm(status.nextTime)}', 'at ${hhmm(status.nextTime)}'),
                            style: t.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? BrandColors.gold
                                  : BrandColors.goldText,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(MoeslimIcons.jam, size: 16, color: BrandColors.goldText),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('${countdown(status.remaining)} lagi', '${countdown(status.remaining)} left'),
                            key: const Key('countdown'),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? BrandColors.gold
                                  : BrandColors.goldText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Wrap(
                  runSpacing: 8,
                  children: [
                    for (final (label, time, p) in rows)
                      SizedBox(
                        width: constraints.maxWidth / columns,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: p != null && p == status.nextPrayer ? scheme.primary.withValues(alpha: .12) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(label, style: const TextStyle(fontSize: 11.5)),
                              Text(hhmm(time), style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DailyAyah extends ConsumerStatefulWidget {
  const _DailyAyah();

  @override
  ConsumerState<_DailyAyah> createState() => _DailyAyahState();
}

class _DailyAyahState extends ConsumerState<_DailyAyah> {
  Timer? _timer;
  List<int> _order = const [];
  int _cursor = 0;
  int _poolLength = 0;
  bool _tickerEnabled = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(dailyAyahRotationInterval, (_) {
      if (_tickerEnabled) _advanceRandom();
    });
  }

  void _ensureOrder(int length, math.Random rng) {
    if (length == _poolLength) return;
    _poolLength = length;
    if (length == 0) {
      _order = const [];
      _cursor = 0;
      return;
    }
    _order = List<int>.generate(length, (i) => i)..shuffle(rng);
    _cursor = 0;
  }

  void _advanceRandom() {
    if (!mounted || _poolLength <= 1) return;
    final rng = ref.read(dailyAyahRandomProvider);
    setState(() {
      if (_cursor + 1 < _order.length) {
        _cursor++;
      } else {
        final lastIndex = _order.isNotEmpty ? _order.last : -1;
        final next = List<int>.generate(_poolLength, (i) => i)..shuffle(rng);
        if (next.length > 1 && next.first == lastIndex) {
          final swap = next[1];
          next[1] = next[0];
          next[0] = swap;
        }
        _order = next;
        _cursor = 0;
      }
    });
  }

  void _triggerNext() {
    _advanceRandom();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final pool = ref.watch(dailyAyahPoolProvider).value;
    if (pool == null || pool.isEmpty) return const SizedBox.shrink();

    _ensureOrder(pool.length, ref.read(dailyAyahRandomProvider));
    final ayah = pool[_order[_cursor]];
    final canRotate = pool.length > 1;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canRotate ? _triggerNext : null,
      child: OrnamentCard(
        key: const Key('daily-ayah'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, color: BrandColors.gold, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                layoutBuilder: (currentChild, previousChildren) =>
                    Stack(alignment: Alignment.topLeft, children: [...previousChildren, ?currentChild]),
                child: Column(
                  key: ValueKey('${ayah.surah}:${ayah.number}'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '"${ayah.translationFor(context.lang) ?? ''}"',
                      key: const Key('daily-ayah-text'),
                      style: const TextStyle(fontStyle: FontStyle.italic, height: 1.45),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(
                              '(QS. ${surahs[ayah.surah - 1].name}: ${ayah.number})',
                              "(Qur'an ${surahs[ayah.surah - 1].name}: ${ayah.number})",
                            ),
                            key: const Key('daily-ayah-ref'),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (canRotate)
                          IconButton(
                            key: const Key('shuffle-ayah'),
                            tooltip: context.tr('Ayat acak berikutnya', 'Next random verse'),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(MoeslimIcons.acak, size: 18, color: scheme.primary),
                            onPressed: _triggerNext,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
