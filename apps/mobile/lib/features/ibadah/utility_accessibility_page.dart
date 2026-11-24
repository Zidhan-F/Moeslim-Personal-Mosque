import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../prayer/prayer_page.dart';
import '../quran/quran_page.dart';
import 'doa_pages.dart';
import 'tasbih_page.dart';

class UtilityAccessibilityPage extends ConsumerStatefulWidget {
  final int initialTab;
  const UtilityAccessibilityPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<UtilityAccessibilityPage> createState() => _UtilityAccessibilityPageState();
}

class _UtilityAccessibilityPageState extends ConsumerState<UtilityAccessibilityPage> {
  late int _tab;
  bool _seniorMode = false;

  // 47. Timer Fokus Ibadah
  WorshipFocusKind _focusKind = WorshipFocusKind.tilawah;
  int _selectedPresetMinutes = 15;
  int _remainingSeconds = 15 * 60;
  bool _timerRunning = false;
  Timer? _countdownTimer;
  List<WorshipTimerLog> _timerLogs = const [];

  // 48. Reflection summary
  WorshipReflectionSummary? _reflection;

  // 49. Halal E-Number checker
  final _halalSearchCtrl = TextEditingController();
  String _halalQuery = '';
  HalalAdditiveStatus? _halalFilter;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    _load();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _halalSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final senior = await ref.read(seniorModeRepoProvider).isEnabled();
    final logs = await ref.read(worshipTimerRepoProvider).allLogs();
    final tracker = ref.read(trackerRepoProvider);
    var fullDays = 0;
    var pages30 = 0;
    for (var i = 0; i < 30; i++) {
      final d = _today.subtract(Duration(days: i));
      final items = await tracker.day(d);
      if (TrackerItem.prayers.every(items.contains)) fullDays++;
      pages30 += await tracker.tilawahPages(d);
    }
    final fastLogs = await ref.read(fastingRepoProvider).allLogs();
    final sedekahLogs = await ref.read(sedekahRepoProvider).allEntries();
    final streak = await tracker.prayerStreak(_today);
    final best = await tracker.bestPrayerStreak(_today);

    if (mounted) {
      setState(() {
        _seniorMode = senior;
        _timerLogs = logs;
        _reflection = WorshipReflectionSummary(
          fullPrayerDaysLast30: fullDays,
          totalTilawahPagesLast30: pages30,
          totalFastingDaysLogged: fastLogs.length,
          totalSedekahRupiahLogged: sedekahLogs.fold<int>(0, (s, e) => s + e.amountRupiah),
          totalFocusMinutesLogged: logs.fold<int>(0, (s, e) => s + e.durationMinutes),
          currentPrayerStreak: streak,
          bestPrayerStreak: best,
        );
      });
    }
  }

  Future<void> _toggleSeniorMode(bool enabled) async {
    await ref.read(seniorModeRepoProvider).setEnabled(enabled);
    final settings = ref.read(settingsProvider).value;
    if (settings != null) {
      await ref.read(settingsProvider.notifier).save(
            settings.copyWith(fontScale: enabled ? 1.35 : 1.0),
          );
    }
    setState(() => _seniorMode = enabled);
  }

  void _startOrPauseTimer() {
    if (_timerRunning) {
      _countdownTimer?.cancel();
      setState(() => _timerRunning = false);
      return;
    }
    setState(() => _timerRunning = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _countdownTimer?.cancel();
        _finishFocusSession();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _finishFocusSession() async {
    _countdownTimer?.cancel();
    setState(() {
      _timerRunning = false;
      _remainingSeconds = _selectedPresetMinutes * 60;
    });
    await ref.read(worshipTimerRepoProvider).logSession(
          now: DateTime.now(),
          kind: _focusKind,
          durationMinutes: _selectedPresetMinutes,
          trackerRepo: ref.read(trackerRepoProvider),
        );
    await _load();
  }

  String _focusKindLabel(BuildContext context, WorshipFocusKind k) => switch (k) {
        WorshipFocusKind.tilawah => context.tr(k.label, 'Quran Recitation Focus'),
        WorshipFocusKind.dzikir => context.tr(k.label, 'Dhikr & Contemplation Focus'),
        WorshipFocusKind.itikaf => context.tr(k.label, 'I\'tikaf & Dua Session'),
      };

  String _halalStatusLabel(BuildContext context, HalalAdditiveStatus st) => switch (st) {
        HalalAdditiveStatus.halal => context.tr(st.label, 'Halal'),
        HalalAdditiveStatus.syubhat => context.tr(st.label, 'Doubtful (Check Halal Certificate)'),
        HalalAdditiveStatus.haram => context.tr(st.label, 'Haram'),
      };

  String _halalStatusBadge(BuildContext context, HalalAdditiveStatus st) => switch (st) {
        HalalAdditiveStatus.halal => 'HALAL',
        HalalAdditiveStatus.syubhat => context.tr('SYUBHAT', 'DOUBTFUL'),
        HalalAdditiveStatus.haram => 'HARAM',
      };

  ({String name, String func, String source}) _halalItemEn(ENumberAdditiveItem item) => switch (item.code) {
        'E100' => (
            name: 'Curcumin (Turmeric)',
            func: 'Natural yellow coloring',
            source: 'Derived from plant turmeric rhizome extract (Curcuma longa); halal to consume.',
          ),
        'E120' => (
            name: 'Carmine / Cochineal (Carminic Acid)',
            func: 'Red coloring for food & cosmetics',
            source: 'Extracted from Cochineal insects. Scholarly rulings differ; check for an official Halal logo on packaging.',
          ),
        'E160a' => (
            name: 'Beta-Carotene',
            func: 'Orange/yellow coloring',
            source: 'Natural pigment from carrots and green plants (ensure capsule carriers are not non-halal gelatin).',
          ),
        'E300' => (
            name: 'Ascorbic Acid (Vitamin C)',
            func: 'Antioxidant & acidity regulator',
            source: 'Produced from plant glucose synthesis; halal.',
          ),
        'E322' => (
            name: 'Lecithin',
            func: 'Emulsifier in chocolate, bread & milk',
            source: 'Usually halal when sourced from soy or sunflower, but doubtful if derived from uncertified animal fat.',
          ),
        'E330' => (
            name: 'Citric Acid',
            func: 'Acidity regulator in drinks & candies',
            source: 'Derived from citrus fruits or fermentation of sugarcane/tapioca; halal.',
          ),
        'E406' => (
            name: 'Agar-Agar',
            func: 'Gelling agent & thickener',
            source: '100% plant-based from red seaweed; the best substitute for animal gelatin.',
          ),
        'E407' => (
            name: 'Carrageenan',
            func: 'Thickener in ice cream & dairy products',
            source: 'Natural seaweed extract; halal.',
          ),
        'E422' => (
            name: 'Glycerol / Glycerin',
            func: 'Sweetener & humectant in food/medicine',
            source: 'Halal when derived from vegetable oils (such as palm oil), but haram/doubtful if a byproduct of pork or non-halal animal fat.',
          ),
        'E441' => (
            name: 'Gelatin',
            func: 'Gelling agent in gummies, capsules & marshmallows',
            source: 'High critical point: derived from animal bones or skin collagen. Verify official Halal certification (halal-slaughtered beef or fish gelatin).',
          ),
        'E471' => (
            name: 'Mono- and Diglycerides of Fatty Acids',
            func: 'Emulsifier in margarine, ice cream & bread',
            source: 'Can be made from plant oils (halal) or animal fats (haram/doubtful). Ensure the product carries an official Halal label.',
          ),
        'E542' => (
            name: 'Edible Bone Phosphate',
            func: 'Anti-caking agent in supplements',
            source: 'Derived from animal bone extract; haram if sourced from pork or animals not slaughtered according to Islamic law.',
          ),
        'E621' => (
            name: 'Monosodium Glutamate (MSG)',
            func: 'Savory flavor enhancer (umami)',
            source: 'Produced through bacterial fermentation of molasses or tapioca (check halal certification for the fermentation media).',
          ),
        'E904' => (
            name: 'Shellac',
            func: 'Glazing agent for candies & chocolates',
            source: 'Natural resin secreted by the lac insect Laccifer lacca (halal when alcohol solvent has evaporated or halal-certified).',
          ),
        'E920' => (
            name: 'L-Cysteine',
            func: 'Dough conditioner for flour & bread',
            source: 'Haram if extracted from human hair; doubtful if from poultry feathers; halal if from plant/synthetic fermentation.',
          ),
        'MIRIN' => (
            name: 'Mirin / Cooking Wine / Rum',
            func: 'Alcoholic cooking seasoning (khamr)',
            source: 'Classified as khamr (intoxicating alcohol), which is haram to use even in small amounts in cooking.',
          ),
        _ => (name: item.name, func: item.functionInFood, source: item.sourceExplanation),
      };

  ({String window, String title, String subtitle}) _contextualAdviceText(
    BuildContext context,
    ContextualSunnahAdvice adv,
  ) {
    if (!context.isEn) return (window: adv.timeWindowLabel, title: adv.title, subtitle: adv.subtitle);
    return switch (adv.id) {
      'tahajud_sahur' => (
          window: 'Last Third of the Night & Suhoor',
          title: 'Blessed Time for Tahajjud, Witr & Suhoor Istighfar',
          subtitle: 'Allah descends to the lowest heaven to answer supplications and forgive those seeking pardon before dawn.',
        ),
      'dzikir_pagi' => (
          window: 'Morning After Fajr',
          title: 'Practice Morning Dhikr & Fajr Charity',
          subtitle: 'Fortify your day with Ayat al-Kursi, Sayyidul Istighfar, and guided morning dhikr.',
        ),
      'salat_dhuha' => (
          window: 'Late Morning Window',
          title: 'Time for Dhuha Sunnah Prayer (2-8 Rakaat)',
          subtitle: 'Two rakaat of Dhuha fulfill the charity due for all 360 joints of your body today.',
        ),
      'dzikir_petang' => (
          window: 'Evening After Asr',
          title: 'Practice Guided Evening Dhikr',
          subtitle: 'Complete your afternoon and evening protection with authentic evening remembrances.',
        ),
      'almulk_muhasabah' => (
          window: 'Before Night Rest',
          title: 'Recite Surah Al-Mulk, Make Wudu & Reflect',
          subtitle: 'Surah Al-Mulk (30 verses) protects from the torment of the grave, followed by nightly self-reflection.',
        ),
      'dzikrullah_siang' => (
          window: 'Midday Window',
          title: 'Guard Timely Prayers & Keep Your Tongue Moist with Dhikr',
          subtitle: 'Prepare for the call to Dhuhr or Asr prayer and increase istighfar between daily tasks.',
        ),
      'sunnah_jumat' => (
          window: 'Blessings of Friday Night & Day',
          title: 'Recite Surah Al-Kahfi & Increase Salawat',
          subtitle: 'The best day the sun rises upon is Friday. Do not miss Al-Kahfi, salawat, and late-Asr dua.',
        ),
      _ => (window: adv.timeWindowLabel, title: adv.title, subtitle: adv.subtitle),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Utilitas, Lansia & Halal', 'Utilities, Senior & Halal')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Mode Lansia', 'Senior Mode'),
                context.tr('Timer Ibadah', 'Focus Timer'),
                context.tr('Refleksi', 'Reflection'),
                context.tr('Cek E-Halal', 'Halal E-Check'),
                context.tr('Sunnah Waktu', 'Timed Sunnah'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildSeniorModeTab(context),
              1 => _buildWorshipTimerTab(context),
              2 => _buildReflectionTab(context),
              3 => _buildHalalENumberTab(context),
              _ => _buildContextualSunnahTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 46. Mode Lansia (Senior Mode / Aksesibilitas Tinggi)
  Widget _buildSeniorModeTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SwitchListTile(
            key: const Key('senior-mode-switch'),
            secondary: Icon(Icons.accessibility_new, color: scheme.primary, size: 32),
            title: Text(
              context.tr(
                'Aktifkan Mode Lansia (Huruf Ekstra Besar & Tombol Lebar)',
                'Enable Senior Mode (Extra-Large Text & Wide Buttons)',
              ),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              _seniorMode
                  ? context.tr(
                      'Aktif (Skala Huruf 135%): Tampilan diperbesar agar ramah bagi mata lansia.',
                      'Active (135% Text Scale): Enlarged display for comfortable senior reading.',
                    )
                  : context.tr(
                      'Nonaktif (Skala Huruf 100%). Ketuk sakelar untuk memperbesar seluruh huruf aplikasi.',
                      'Off (100% Text Scale). Toggle on to enlarge all text across the app.',
                    ),
            ),
            value: _seniorMode,
            onChanged: _toggleSeniorMode,
          ),
        ),
        SectionHeader(
          context.tr('Beranda Ringkas Mode Lansia (Tombol Ekstra Besar)', 'Senior Mode Quick Home (Extra-Large Buttons)'),
        ),
        for (final (icon, title, subtitle, pageBuilder) in <(IconData, String, String, Widget Function())>[
          (
            MoeslimIcons.jam,
            context.tr('1. Jadwal Salat & Adzan', '1. Prayer Times & Adhan'),
            context.tr('Lihat jam Subuh, Dzuhur, Ashar, Maghrib & Isya', 'View Fajr, Dhuhr, Asr, Maghrib & Isha times'),
            () => const PrayerPage(),
          ),
          (
            MoeslimIcons.quranTerbuka,
            context.tr('2. Baca Al-Qur\'an (Mushaf)', '2. Read Al-Quran (Mushaf)'),
            context.tr('Buka surah dan dengarkan murottal', 'Open surahs and listen to audio recitation'),
            () => const QuranPage(),
          ),
          (
            MoeslimIcons.buku,
            context.tr('3. Doa Harian & Aktivitas', '3. Daily & Activity Duas'),
            context.tr('Kumpulan doa sehari-hari lengkap', 'Complete collection of daily supplications'),
            () => const DoaListPage(),
          ),
          (
            MoeslimIcons.zikr,
            context.tr('4. Dzikir Pagi, Petang & Salat', '4. Morning, Evening & Prayer Dhikr'),
            context.tr('Bacaan dzikir terpandu langkah demi langkah', 'Step-by-step guided dhikr recitations'),
            () => const DoaListPage(initialTab: 2),
          ),
          (
            MoeslimIcons.tasbih,
            context.tr('5. Tasbih Digital', '5. Digital Tasbih'),
            context.tr('Penghitung dzikir dengan getaran', 'Dhikr counter with haptic feedback'),
            () => const TasbihPage(),
          ),
        ])
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => pageBuilder())),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(icon, size: 36, color: scheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: t.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 30),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 47. Timer Sesi Tilawah, Dzikir & I'tikaf
  Widget _buildWorshipTimerTab(BuildContext context) {
    final mm = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ArchHeader(
          child: Column(
            children: [
              Text(_focusKindLabel(context, _focusKind), style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                '$mm:$ss',
                key: const Key('worship-timer-clock'),
                style: t.displayMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const Key('worship-timer-start-btn'),
                    onPressed: _startOrPauseTimer,
                    icon: Icon(_timerRunning ? Icons.pause : MoeslimIcons.play),
                    label: Text(_timerRunning ? context.tr('Jeda', 'Pause') : context.tr('Mulai Fokus', 'Start Focus')),
                  ),
                  OutlinedButton.icon(
                    key: const Key('worship-timer-complete-btn'),
                    onPressed: _finishFocusSession,
                    icon: const Icon(MoeslimIcons.berhasil),
                    label: Text(context.tr('Catat Selesai Sekarang', 'Log Completed Now')),
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionHeader(context.tr('Pilih Jenis & Durasi Sesi Fokus', 'Choose Focus Session Type & Duration')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in WorshipFocusKind.values)
              ChoiceChip(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(_focusKindLabel(context, k)),
                selected: _focusKind == k,
                onSelected: (_) => setState(() => _focusKind = k),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final mins in [10, 15, 30, 45, 60])
              ChoiceChip(
                key: Key('timer-preset-$mins'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(context.tr('$mins Menit', '$mins Min')),
                selected: _selectedPresetMinutes == mins,
                onSelected: (_) => setState(() {
                  _countdownTimer?.cancel();
                  _timerRunning = false;
                  _selectedPresetMinutes = mins;
                  _remainingSeconds = mins * 60;
                }),
              ),
          ],
        ),
        SectionHeader(
          context.tr('Riwayat Sesi Fokus (${_timerLogs.length})', 'Focus Session History (${_timerLogs.length})'),
        ),
        for (final l in _timerLogs)
          Card(
            child: ListTile(
              leading: Icon(MoeslimIcons.jam, color: scheme.primary),
              title: Text(
                context.tr(
                  '${l.kind.label} · ${l.durationMinutes} menit',
                  '${_focusKindLabel(context, l.kind)} · ${l.durationMinutes} min',
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                context.tr(
                  'Tanggal: ${l.dateKey} (Otomatis tersinkron ke Catatan Ibadah)',
                  'Date: ${l.dateKey} (Auto-synced to Worship Log)',
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 48. Ringkasan Refleksi Ibadah Bulanan & Tahunan
  Widget _buildReflectionTab(BuildContext context) {
    final r = _reflection;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    if (r == null) return const Center(child: CircularProgressIndicator());

    Widget statTile(String title, String value, String subtitle, IconData icon) {
      return Card(
        child: ListTile(
          leading: Icon(icon, color: scheme.primary, size: 30),
          title: Text(title, style: t.titleSmall),
          subtitle: Text(subtitle),
          trailing: Text(value, style: t.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PatternBanner(
          child: Text(
            context.tr(
              'Rekap refleksi ibadah ini diolah 100% secara privat di perangkat Anda dari catatan salat, tilawah, puasa, sedekah, dan sesi fokus ibadah.',
              'This worship reflection summary is computed 100% privately on your device from your prayer, Quran, fasting, charity, and focus timer logs.',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        statTile(
          context.tr('Hari Salat 5 Waktu Lengkap (30 Hari)', 'Full 5-Prayer Days (Last 30 Days)'),
          context.tr('${r.fullPrayerDaysLast30} hari', '${r.fullPrayerDaysLast30} days'),
          context.tr(
            'Streak saat ini: ${r.currentPrayerStreak} hari · Rekor: ${r.bestPrayerStreak} hari',
            'Current streak: ${r.currentPrayerStreak} days · Best: ${r.bestPrayerStreak} days',
          ),
          MoeslimIcons.centangKotak,
        ),
        statTile(
          context.tr('Total Tilawah Al-Qur\'an (30 Hari)', 'Total Quran Reading (Last 30 Days)'),
          context.tr('${r.totalTilawahPagesLast30} hal', '${r.totalTilawahPagesLast30} pgs'),
          context.tr(
            'Setara ${(r.totalTilawahPagesLast30 / 20.0).toStringAsFixed(1)} Juz dalam 30 hari terakhir',
            'Equivalent to ${(r.totalTilawahPagesLast30 / 20.0).toStringAsFixed(1)} Juz in the last 30 days',
          ),
          MoeslimIcons.quranTerbuka,
        ),
        statTile(
          context.tr('Total Hari Puasa Tercatat', 'Total Fasting Days Logged'),
          context.tr('${r.totalFastingDaysLogged} hari', '${r.totalFastingDaysLogged} days'),
          context.tr('Akumulasi puasa wajib Ramadan, Qadha, dan Sunnah', 'Combined Ramadan, Qadha, and Sunnah fasts'),
          MoeslimIcons.bulan,
        ),
        statTile(
          context.tr('Total Sedekah & Amal Tercatat', 'Total Charity & Good Deeds Logged'),
          rupiah(r.totalSedekahRupiahLogged),
          context.tr(
            'Catatan sedekah subuh, Jumat, dan infaq pribadi',
            'Fajr charity, Friday infaq, and personal giving logs',
          ),
          MoeslimIcons.donasi,
        ),
        statTile(
          context.tr('Total Waktu Fokus Ibadah', 'Total Worship Focus Time'),
          context.tr('${r.totalFocusMinutesLogged} mnt', '${r.totalFocusMinutesLogged} min'),
          context.tr(
            'Akumulasi timer sesi tilawah, dzikir, dan i\'tikaf',
            'Combined Quran, dhikr, and i\'tikaf focus sessions',
          ),
          MoeslimIcons.jam,
        ),
      ],
    );
  }

  // 49. Referensi Kode Bahan Pangan Halal (E-Number Checker Offline)
  Widget _buildHalalENumberTab(BuildContext context) {
    final qLower = _halalQuery.toLowerCase();
    final filtered = [
      for (final item in halalENumberCatalog)
        if ((_halalFilter == null || item.status == _halalFilter) &&
            (item.matches(_halalQuery) ||
                (context.isEn &&
                    (_halalItemEn(item).name.toLowerCase().contains(qLower) ||
                        _halalItemEn(item).func.toLowerCase().contains(qLower) ||
                        _halalItemEn(item).source.toLowerCase().contains(qLower)))))
          item,
    ];
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            children: [
              TextField(
                key: const Key('halal-enumber-search'),
                controller: _halalSearchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(MoeslimIcons.pencarian),
                  hintText: context.tr(
                    'Cari kode E-Number atau bahan (mis. E471, E120, Gelatin, Lesitin, Mirin)',
                    'Search E-Number or ingredient (e.g., E471, E120, Gelatin, Lecithin, Mirin)',
                  ),
                ),
                onChanged: (v) => setState(() => _halalQuery = v.trim()),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(context.tr('Semua', 'All')),
                        selected: _halalFilter == null,
                        onSelected: (_) => setState(() => _halalFilter = null),
                      ),
                    ),
                    for (final st in HalalAdditiveStatus.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          key: Key('halal-filter-${st.name}'),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          label: Text(_halalStatusLabel(context, st)),
                          selected: _halalFilter == st,
                          onSelected: (_) => setState(() => _halalFilter = _halalFilter == st ? null : st),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final en = _halalItemEn(item);
              final badgeColor = switch (item.status) {
                HalalAdditiveStatus.halal => scheme.primary,
                HalalAdditiveStatus.syubhat => BrandColors.goldText,
                HalalAdditiveStatus.haram => scheme.error,
              };
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.code} · ${context.isEn ? en.name : item.name}',
                              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _halalStatusBadge(context, item.status),
                              style: TextStyle(color: badgeColor, fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('Fungsi: ${item.functionInFood}', 'Function: ${en.func}'),
                        style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(context.isEn ? en.source : item.sourceExplanation, style: t.bodyMedium),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 50. Pengingat Sunnah Kontekstual Berbasis Waktu
  Widget _buildContextualSunnahTab(BuildContext context) {
    final activeAdvices = evaluateContextualSunnahForTime(DateTime.now());
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final scheduleItems = context.isEn
        ? const [
            (
              '03:00 - 04:45 (Last Third of Night)',
              'Tahajjud, Witr & Suhoor Istighfar',
              'A blessed time of descending mercy and answered supplications.',
            ),
            (
              '05:00 - 07:30 (After Fajr)',
              'Morning Dhikr Al-Ma\'tsurat & Fajr Charity',
              'Morning spiritual protection and prayers of the angels for those who give charity at dawn.',
            ),
            (
              '07:30 - 11:30 (Dhuha Window)',
              'Dhuha Sunnah Prayer (2-8 Rakaat)',
              'Fulfills charity on behalf of all 360 joints of the body.',
            ),
            (
              'Friday (Thursday Evening to Friday Sunset)',
              'Surah Al-Kahfi, Salawat & Late-Asr Dua',
              'A light between two Fridays and the intercession of Prophet Muhammad (PBUH).',
            ),
            (
              '15:30 - 18:00 (After Asr)',
              'Guided Evening Dhikr',
              'Spiritual protection from evening through the night.',
            ),
            (
              '20:00 - 23:00 (Before Sleep)',
              'Surah Al-Mulk, Wudu Before Sleep & Muhasabah',
              'Protection from the punishment of the grave and daily self-evaluation.',
            ),
          ]
        : const [
            (
              '03:00 – 04:45 (Sepertiga Malam)',
              'Salat Tahajud, Witir & Istighfar Sahur',
              'Waktu turunnya rahmat dan dikabulkannya doa.',
            ),
            (
              '05:00 – 07:30 (Ba\'da Subuh)',
              'Dzikir Pagi Al-Ma\'tsurat & Sedekah Subuh',
              'Penjagaan pagi hari dan doa malaikat bagi orang yang bersedekah di pagi hari.',
            ),
            (
              '07:30 – 11:30 (Waktu Dhuha)',
              'Salat Sunnah Dhuha 2–8 Rakaat',
              'Sedekah bagi 360 persendian tubuh.',
            ),
            (
              'Hari Jumat (Kamis Sore s.d. Jumat Sore)',
              'Surah Al-Kahfi, Shalawat & Doa Akhir Ashar',
              'Cahaya di antara dua Jumat dan syafaat Rasulullah SAW.',
            ),
            (
              '15:30 – 18:00 (Ba\'da Ashar)',
              'Dzikir Petang Terpandu',
              'Perlindungan sore hingga malam hari.',
            ),
            (
              '20:00 – 23:00 (Sebelum Tidur)',
              'Surah Al-Mulk, Wudhu Sebelum Tidur & Muhasabah',
              'Penyelamat dari siksa kubur dan evaluasi amal harian.',
            ),
          ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(context.tr('Rekomendasi Sunnah Sesuai Waktu Saat Ini', 'Recommended Sunnah for Right Now')),
        for (final adv in activeAdvices) ...[
          Builder(
            builder: (context) {
              final loc = _contextualAdviceText(context, adv);
              return Card(
                child: ListTile(
                  leading: Icon(MoeslimIcons.bintang, color: scheme.primary),
                  title: Text(loc.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${loc.window}\n${loc.subtitle}'),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ],
        SectionHeader(context.tr('Jadwal Pengingat Sunnah Sepanjang Hari', 'Daily Sunnah Reminder Schedule')),
        for (final (window, title, desc) in scheduleItems)
          Card(
            child: ListTile(
              leading: Icon(MoeslimIcons.jam, color: scheme.primary),
              title: Text(title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text('$window · $desc'),
            ),
          ),
      ],
    );
  }
}
