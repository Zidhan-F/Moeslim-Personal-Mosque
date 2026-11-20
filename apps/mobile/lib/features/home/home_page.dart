import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../../ui/core_nav.dart';
import '../ibadah/doa_pages.dart';
import '../ibadah/hijri_page.dart';
import '../ibadah/qibla_page.dart';
import '../ibadah/tracker_page.dart';
import '../more/followed_mosques_page.dart';
import '../prayer/prayer_page.dart';
import '../quran/naghom_hero.dart';
import '../quran/naghom_pages.dart';
import '../quran/quran_source.dart';

/// Ayat pilihan harian (teks & terjemahan diambil dari dataset terpasang, bukan ditulis tangan).
const dailyAyahRefs = <(int, int)>[
  (29, 45),
  (2, 286),
  (94, 5),
  (13, 28),
  (2, 152),
  (3, 139),
  (39, 53),
  (2, 153),
  (20, 114),
  (65, 3),
];

final dailyAyahProvider = FutureProvider<Ayah?>((ref) async {
  final day = DateTime.now().difference(DateTime(2024)).inDays;
  final (s, a) = dailyAyahRefs[day % dailyAyahRefs.length];
  final ayat = await ref.watch(quranSourceProvider).load(s);
  return ayat == null || a > ayat.length ? null : ayat[a - 1];
});

class HomePage extends ConsumerWidget {
  final void Function(int tab) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(prayerStatusProvider);
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
      body: status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat jadwal: $e')),
        data: (s) {
          final hijri = HijriDate.fromGregorian(s.now, offsetDays: settings?.hijriOffset ?? 0);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _Greeting(name: settings?.displayName),
              Transform.translate(
                offset: const Offset(0, -18),
                child: _PrayerCard(status: s, city: settings?.location.name ?? '', hijri: hijri.toString()),
              ),
              SectionHeader('Menu Cepat', actionLabel: 'Lihat Semua', onAction: () => onNavigate(2)),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: .9,
                children: [
                  MenuTile(icon: Icons.menu_book, label: "Al-Qur'an", onTap: () => onNavigate(1)),
                  MenuTile(
                    icon: Icons.volunteer_activism,
                    label: 'Doa & Dzikir',
                    onTap: () => push(const DoaListPage()),
                  ),
                  MenuTile(icon: Icons.calendar_month, label: 'Jadwal Salat', onTap: () => push(const PrayerPage())),
                  MenuTile(icon: Icons.explore, label: 'Arah Kiblat', onTap: () => push(const QiblaPage())),
                  MenuTile(icon: Icons.event_note, label: 'Kalender Hijriah', onTap: () => push(const HijriPage())),
                  MenuTile(icon: Icons.fact_check, label: 'Catatan Ibadah', onTap: () => push(const TrackerPage())),
                  MenuTile(icon: Icons.graphic_eq, label: '7 Irama', onTap: () => push(const NaghomCatalogPage())),
                  MenuTile(
                    icon: Icons.location_city,
                    label: 'Masjid Diikuti',
                    onTap: () => push(const FollowedMosquesPage()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const NaghomHero(),
              const SizedBox(height: 12),
              const _DailyAyah(),
            ],
          );
        },
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
                name?.isNotEmpty == true ? name! : 'Sahabat Moeslim',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Semoga hari ini penuh keberkahan.', style: TextStyle(color: BrandColors.cream, fontSize: 13)),
            ],
          ),
        ),
        const BrandLogo(variant: BrandLogoVariant.symbol, height: 56, onDark: true),
      ],
    ),
  );
}

class _PrayerCard extends StatelessWidget {
  final PrayerStatus status;
  final String city;
  final String hijri;
  const _PrayerCard({required this.status, required this.city, required this.hijri});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final rows = <(String, DateTime, Prayer?)>[
      ('Subuh', status.today.fajr, Prayer.fajr),
      ('Syuruq', status.today.sunrise, null),
      ('Dzuhur', status.today.dhuhr, Prayer.dhuhr),
      ('Ashar', status.today.asr, Prayer.asr),
      ('Maghrib', status.today.maghrib, Prayer.maghrib),
      ('Isya', status.today.isha, Prayer.isha),
    ];
    return Card(
      key: const Key('prayer-card'),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerSettingsPage())),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: scheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text('Waktu Salat di $city', style: t.labelLarge, overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(longDate(status.now), style: t.bodySmall),
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
                  child: const Icon(Icons.mosque, color: BrandColors.goldText, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menuju ${status.nextPrayer.label}', style: t.titleSmall),
                      Text(hhmm(status.nextTime), style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrandColors.gold.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 16, color: BrandColors.goldText),
                      const SizedBox(width: 4),
                      Text(
                        '${countdown(status.remaining)} lagi',
                        key: const Key('countdown'),
                        style: const TextStyle(color: BrandColors.goldText, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                for (final (label, time, p) in rows)
                  Expanded(
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
        ),
      ),
    );
  }
}

class _DailyAyah extends ConsumerWidget {
  const _DailyAyah();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayah = ref.watch(dailyAyahProvider).value;
    if (ayah == null || ayah.translation == null) return const SizedBox.shrink();
    return OrnamentCard(
      key: const Key('daily-ayah'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: BrandColors.gold, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${ayah.translation}"',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 6),
                Text(
                  '(QS. ${surahs[ayah.surah - 1].name}: ${ayah.number})',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
