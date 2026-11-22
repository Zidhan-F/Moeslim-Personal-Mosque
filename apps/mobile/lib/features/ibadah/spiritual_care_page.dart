import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import '../quran/surah_page.dart';
import 'doa_pages.dart';

class SpiritualCarePage extends ConsumerStatefulWidget {
  final int initialTab;
  const SpiritualCarePage({super.key, this.initialTab = 0});

  @override
  ConsumerState<SpiritualCarePage> createState() => _SpiritualCarePageState();
}

class _SpiritualCarePageState extends ConsumerState<SpiritualCarePage> {
  late int _tab;
  SpiritualMoodCondition _selectedMood = spiritualMoodCatalog.first;
  int _shalawatCount = 0;
  int _shalawatTarget = 100;
  List<PersonalHajatItem> _hajatList = const [];
  final _hajatTitleCtrl = TextEditingController();
  String _hajatCategory = 'Diri Sendiri & Keluarga';
  Set<String> _completedHabits = {};

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
    _hajatTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sh = await ref.read(shalawatCounterRepoProvider).loadForDay(_today);
    final hj = await ref.read(hajatPrayerListRepoProvider).allItems();
    final hb = await ref.read(sunnahHabitRepoProvider).completedForDate(_today);
    if (mounted) {
      setState(() {
        _shalawatCount = sh.count;
        _shalawatTarget = sh.target;
        _hajatList = hj;
        _completedHabits = hb;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dzikir, Doa & Penguatan Hati'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Doa Kondisi', 'Ruqyah', 'Shalawat', 'Daftar Hajat', 'Sunnah Rawatib'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildMoodDuaFinderTab(context),
              1 => _buildRuqyahTab(context),
              2 => _buildShalawatTab(context),
              3 => _buildHajatListTab(context),
              _ => _buildSunnahHabitsTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 37. Pencari Doa Berbasis Kondisi / Suasana Hati
  Widget _buildMoodDuaFinderTab(BuildContext context) {
    final dailyDuasAsync = ref.watch(dailyDuasProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Apa yang Sedang Anda Rasakan / Hadapi Hari Ini?', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in spiritualMoodCatalog)
              ChoiceChip(
                key: Key('mood-chip-${m.id}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(m.label),
                selected: _selectedMood.id == m.id,
                onSelected: (_) => setState(() => _selectedMood = m),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penyejuk Hati dari Al-Qur\'an (${_selectedMood.label})', style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_selectedMood.quranicComfort, key: const Key('mood-quran-comfort'), style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        SectionHeader('Doa Shahih untuk Kondisi: ${_selectedMood.label}'),
        dailyDuasAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          error: (e, _) => Text('Gagal memuat doa: $e'),
          data: (allDuas) {
            final matched = filterDailyDuasByMood(allDuas, _selectedMood);
            return Column(
              children: [
                for (var i = 0; i < matched.length; i++)
                  Card(
                    child: ListTile(
                      leading: OctagonNumber(i + 1),
                      title: Text(matched[i].title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(matched[i].translation, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DailyDuaDetailPage(dua: matched[i])),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 36. Panduan Ruqyah Syar'iyyah Mandiri
  Widget _buildRuqyahTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PatternBanner(
          child: Text(
            'Adab Ruqyah Mandiri: Berwudhu, yakin sepenuh hati bahwa kesembuhan dan perlindungan semata-mata dari Allah SWT, membaca ayat & doa dengan khusyuk, lalu mengusapkan tangan ke bagian tubuh yang sakit.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in ruqyahMandiriCatalog)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      OctagonNumber(item.order),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            Text(item.repeatLabel, style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (item.linkedSurah != null)
                        IconButton(
                          tooltip: 'Buka surah di Mushaf',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SurahPage(surah: surahs[item.linkedSurah! - 1])),
                          ),
                          icon: Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: quranTextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(item.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text(item.translation, style: t.bodyMedium),
                  const SizedBox(height: 6),
                  Text('Dalil: ${item.reference}', style: t.bodySmall),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // 38. Koleksi Shalawat Ma'tsur & Target Shalawat Harian
  Widget _buildShalawatTab(BuildContext context) {
    final ratio = _shalawatTarget <= 0 ? 1.0 : (_shalawatCount / _shalawatTarget).clamp(0.0, 1.0);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Target Shalawat Harian / Hari Jumat', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  '$_shalawatCount / $_shalawatTarget kali',
                  key: const Key('shalawat-counter-value'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      key: const Key('shalawat-tap-btn'),
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        final res = await ref.read(shalawatCounterRepoProvider).increment(_today);
                        setState(() => _shalawatCount = res.count);
                      },
                      icon: const Icon(MoeslimIcons.tasbih),
                      label: const Text('+1 Shalawat'),
                    ),
                    for (final target in [100, 300, 1000])
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text('Target $target'),
                        selected: _shalawatTarget == target,
                        onSelected: (_) async {
                          final res = await ref.read(shalawatCounterRepoProvider).setTarget(_today, target);
                          setState(() => _shalawatTarget = res.target);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('Koleksi Bacaan Shalawat Ma\'tsur (Sesuai Sunnah)'),
        for (final sh in shalawatCatalog)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(sh.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(
                    sh.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: quranTextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(sh.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text(sh.translation, style: t.bodyMedium),
                  const SizedBox(height: 6),
                  Text(sh.sourceAndVirtue, style: t.bodySmall?.copyWith(color: scheme.primary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // 39. Daftar Hajat & Doa Pribadi (Prayer List)
  Widget _buildHajatListTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tambah Daftar Hajat / Orang yang Didoakan', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('hajat-title-field'),
                  controller: _hajatTitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tulis hajat atau nama keluarga/sahabat yang ingin didoakan...',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cat in ['Diri Sendiri & Keluarga', 'Orang Tua', 'Kesehatan & Rezeki', 'Ilmu & Akhirat'])
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(cat),
                        selected: _hajatCategory == cat,
                        onSelected: (_) => setState(() => _hajatCategory = cat),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  key: const Key('hajat-add-btn'),
                  onPressed: () async {
                    if (_hajatTitleCtrl.text.trim().isEmpty) return;
                    final next = await ref.read(hajatPrayerListRepoProvider).addHajat(
                          title: _hajatTitleCtrl.text,
                          category: _hajatCategory,
                          now: DateTime.now(),
                        );
                    _hajatTitleCtrl.clear();
                    setState(() => _hajatList = next);
                  },
                  icon: const Icon(MoeslimIcons.tambahLingkar),
                  label: const Text('Simpan ke Daftar Doa'),
                ),
              ],
            ),
          ),
        ),
        SectionHeader('Daftar Hajat & Doa Pribadi (${_hajatList.length})'),
        if (_hajatList.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada daftar hajat. Catat hajat penting untuk selalu diingat setiap sujud terakhir dan waktu mustajab.'),
            ),
          )
        else
          for (final item in _hajatList)
            Card(
              child: ListTile(
                leading: Icon(
                  item.isAnswered ? MoeslimIcons.berhasil : MoeslimIcons.cinta,
                  color: item.isAnswered ? scheme.primary : BrandColors.goldText,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: item.isAnswered ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${item.category} · Dicatat ${item.createdAtKey}${item.isAnswered ? ' · Alhamdulillah Terkabul!' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: Key('hajat-toggle-${item.id}'),
                      tooltip: item.isAnswered ? 'Tandai masih didoakan' : 'Tandai Alhamdulillah terkabul',
                      onPressed: () async {
                        final next = await ref.read(hajatPrayerListRepoProvider).toggleAnswered(item.id);
                        setState(() => _hajatList = next);
                      },
                      icon: Icon(MoeslimIcons.berhasil, color: item.isAnswered ? scheme.primary : null),
                    ),
                    IconButton(
                      tooltip: 'Hapus hajat',
                      onPressed: () async {
                        final next = await ref.read(hajatPrayerListRepoProvider).deleteHajat(item.id);
                        setState(() => _hajatList = next);
                      },
                      icon: const Icon(MoeslimIcons.hapus),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  // 40. Pelacak Kebiasaan Sunnah Harian (Rawatib 12 Rakaat, Dhuha, Witir)
  Widget _buildSunnahHabitsTab(BuildContext context) {
    final rawatibIds = sunnahHabitsCatalog.where((h) => h.isRawatib12).map((h) => h.id).toList();
    final rawatibDoneCount = rawatibIds.where(_completedHabits.contains).length;
    final allRawatib12Done = rawatibDoneCount == rawatibIds.length;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allRawatib12Done
                      ? 'Alhamdulillah, 12 Rakaat Sunnah Rawatib Hari Ini Lengkap!'
                      : 'Progres 12 Rakaat Sunnah Rawatib: $rawatibDoneCount / ${rawatibIds.length} waktu',
                  key: const Key('sunnah-rawatib-progress'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'HR. Muslim no. 728: "Barang siapa mengerjakan salat sunnah 12 rakaat dalam sehari semalam, Allah akan membangunkan untuknya sebuah rumah di surga."',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final h in sunnahHabitsCatalog)
          Card(
            child: CheckboxListTile(
              key: Key('habit-check-${h.id}'),
              title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(h.virtue),
              value: _completedHabits.contains(h.id),
              onChanged: (_) async {
                final next = await ref.read(sunnahHabitRepoProvider).toggleHabit(_today, h.id);
                setState(() => _completedHabits = next);
              },
            ),
          ),
      ],
    );
  }
}
