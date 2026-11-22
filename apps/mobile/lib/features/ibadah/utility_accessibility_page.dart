import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../prayer/prayer_page.dart';
import '../quran/quran_page.dart';
import 'doa_pages.dart';
import 'guided_dzikir_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilitas, Lansia & Halal'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Mode Lansia', 'Timer Ibadah', 'Refleksi', 'Cek E-Halal', 'Sunnah Waktu'],
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
            title: const Text(
              'Aktifkan Mode Lansia (Huruf Ekstra Besar & Tombol Lebar)',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              _seniorMode
                  ? 'Aktif (Skala Huruf 135%): Tampilan diperbesar agar ramah bagi mata lansia.'
                  : 'Nonaktif (Skala Huruf 100%). Ketuk sakelar untuk memperbesar seluruh huruf aplikasi.',
            ),
            value: _seniorMode,
            onChanged: _toggleSeniorMode,
          ),
        ),
        const SectionHeader('Beranda Ringkas Mode Lansia (Tombol Ekstra Besar)'),
        for (final (icon, title, subtitle, pageBuilder) in <(IconData, String, String, Widget Function())>[
          (MoeslimIcons.jam, '1. Jadwal Salat & Adzan', 'Lihat jam Subuh, Dzuhur, Ashar, Maghrib & Isya', () => const PrayerPage()),
          (MoeslimIcons.quranTerbuka, '2. Baca Al-Qur\'an (Mushaf)', 'Buka surah dan dengarkan murottal', () => const QuranPage()),
          (MoeslimIcons.buku, '3. Doa Harian & Aktivitas', 'Kumpulan doa sehari-hari lengkap', () => const DoaListPage()),
          (MoeslimIcons.zikr, '4. Dzikir Pagi, Petang & Salat', 'Bacaan dzikir terpandu langkah demi langkah', () => const GuidedDzikirPage()),
          (MoeslimIcons.tasbih, '5. Tasbih Digital', 'Penghitung dzikir dengan getaran', () => const TasbihPage()),
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
              Text(_focusKind.label, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                    label: Text(_timerRunning ? 'Jeda' : 'Mulai Fokus'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('worship-timer-complete-btn'),
                    onPressed: _finishFocusSession,
                    icon: const Icon(MoeslimIcons.berhasil),
                    label: const Text('Catat Selesai Sekarang'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionHeader('Pilih Jenis & Durasi Sesi Fokus'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in WorshipFocusKind.values)
              ChoiceChip(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(k.label),
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
                label: Text('$mins Menit'),
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
        SectionHeader('Riwayat Sesi Fokus (${_timerLogs.length})'),
        for (final l in _timerLogs)
          Card(
            child: ListTile(
              leading: Icon(MoeslimIcons.jam, color: scheme.primary),
              title: Text('${l.kind.label} · ${l.durationMinutes} menit', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Tanggal: ${l.dateKey} (Otomatis tersinkron ke Catatan Ibadah)'),
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
        const PatternBanner(
          child: Text(
            'Rekap refleksi ibadah ini diolah 100% secara privat di perangkat Anda dari catatan salat, tilawah, puasa, sedekah, dan sesi fokus ibadah.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        statTile('Hari Salat 5 Waktu Lengkap (30 Hari)', '${r.fullPrayerDaysLast30} hari', 'Streak saat ini: ${r.currentPrayerStreak} hari · Rekor: ${r.bestPrayerStreak} hari', MoeslimIcons.centangKotak),
        statTile('Total Tilawah Al-Qur\'an (30 Hari)', '${r.totalTilawahPagesLast30} hal', 'Setara ${(r.totalTilawahPagesLast30 / 20.0).toStringAsFixed(1)} Juz dalam 30 hari terakhir', MoeslimIcons.quranTerbuka),
        statTile('Total Hari Puasa Tercatat', '${r.totalFastingDaysLogged} hari', 'Akumulasi puasa wajib Ramadan, Qadha, dan Sunnah', MoeslimIcons.bulan),
        statTile('Total Sedekah & Amal Tercatat', rupiah(r.totalSedekahRupiahLogged), 'Catatan sedekah subuh, Jumat, dan infaq pribadi', MoeslimIcons.donasi),
        statTile('Total Waktu Fokus Ibadah', '${r.totalFocusMinutesLogged} mnt', 'Akumulasi timer sesi tilawah, dzikir, dan i\'tikaf', MoeslimIcons.jam),
      ],
    );
  }

  // 49. Referensi Kode Bahan Pangan Halal (E-Number Checker Offline)
  Widget _buildHalalENumberTab(BuildContext context) {
    final filtered = [
      for (final item in halalENumberCatalog)
        if ((_halalFilter == null || item.status == _halalFilter) && item.matches(_halalQuery)) item,
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
                decoration: const InputDecoration(
                  prefixIcon: Icon(MoeslimIcons.pencarian),
                  hintText: 'Cari kode E-Number atau bahan (mis. E471, E120, Gelatin, Lesitin, Mirin)',
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
                        label: const Text('Semua'),
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
                          label: Text(st.label),
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
                              '${item.code} · ${item.name}',
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
                              item.status.name.toUpperCase(),
                              style: TextStyle(color: badgeColor, fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Fungsi: ${item.functionInFood}', style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(item.sourceExplanation, style: t.bodyMedium),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader('Rekomendasi Sunnah Sesuai Waktu Saat Ini'),
        for (final adv in activeAdvices)
          Card(
            child: ListTile(
              leading: Icon(MoeslimIcons.bintang, color: scheme.primary),
              title: Text(adv.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${adv.timeWindowLabel}\n${adv.subtitle}'),
              isThreeLine: true,
            ),
          ),
        const SectionHeader('Jadwal Pengingat Sunnah Sepanjang Hari'),
        for (final (window, title, desc) in const [
          ('03:00 – 04:45 (Sepertiga Malam)', 'Salat Tahajud, Witir & Istighfar Sahur', 'Waktu turunnya rahmat dan dikabulkannya doa.'),
          ('05:00 – 07:30 (Ba\'da Subuh)', 'Dzikir Pagi Al-Ma\'tsurat & Sedekah Subuh', 'Penjagaan pagi hari dan doa malaikat bagi orang yang bersedekah di pagi hari.'),
          ('07:30 – 11:30 (Waktu Dhuha)', 'Salat Sunnah Dhuha 2–8 Rakaat', 'Sedekah bagi 360 persendian tubuh.'),
          ('Hari Jumat (Kamis Sore s.d. Jumat Sore)', 'Surah Al-Kahfi, Shalawat & Doa Akhir Ashar', 'Cahaya di antara dua Jumat dan syafaat Rasulullah SAW.'),
          ('15:30 – 18:00 (Ba\'da Ashar)', 'Dzikir Petang Terpandu', 'Perlindungan sore hingga malam hari.'),
          ('20:00 – 23:00 (Sebelum Tidur)', 'Surah Al-Mulk, Wudhu Sebelum Tidur & Muhasabah', 'Penyelamat dari siksa kubur dan evaluasi amal harian.'),
        ])
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
