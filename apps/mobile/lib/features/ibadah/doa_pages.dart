import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import '../quran/quran_source.dart';
import 'guided_dzikir_page.dart';
import 'share_card_page.dart';

/// Satu doa dalam Al-Qur'an: rentang ayat beserta teks & terjemahan dari dataset terpasang.
class QuranicDua {
  final int surah;
  final int from;
  final int to;
  final List<Ayah> ayat;
  const QuranicDua(this.surah, this.from, this.to, this.ayat);

  String get reference => 'QS. ${surahs[surah - 1].name}: ${from == to ? '$from' : '$from–$to'}';
  String referenceFor(AppLanguage lang) => lang == AppLanguage.en
      ? 'Quran ${surahs[surah - 1].name}: ${from == to ? '$from' : '$from-$to'}'
      : reference;
  String get translation => ayat.map((a) => a.translation ?? '').join(' ');
  String translationFor(AppLanguage lang) => ayat.map((a) => a.translationFor(lang) ?? '').join(' ');
}

final dailyDuasProvider = FutureProvider<List<DailyDua>>((ref) async {
  final raw = await rootBundle.loadString('assets/doa/daily_duas.json');
  return parseDailyDuasJson(raw);
});

final quranicDuasProvider = FutureProvider<List<QuranicDua>>((ref) async {
  final source = ref.watch(quranSourceProvider);
  final cache = <int, List<Ayah>?>{};
  final out = <QuranicDua>[];
  for (final (s, a, b) in quranicDuaRanges) {
    final ayat = cache[s] ??= await source.load(s);
    if (ayat == null) continue;
    out.add(QuranicDua(s, a, b, ayat.sublist(a - 1, b)));
  }
  return out;
});

const _priorityGroups = <String>[
  'Doa Sebelum dan Sesudah Tidur',
  'Doa di Kamar Mandi',
  'Doa Saat Wudhu',
  'Doa Berpakaian',
  'Doa Keluar Dan Masuk Rumah',
  'Doa Terkait Masjid',
  'Bacaan Terkait Adzan',
  'Beberapa Doa Terkait Shalat',
  'Doa Terkait Makan',
  'Doa Perjalanan',
  'Doa Memohon Ilmu',
  'Doa Terkait Orang Tua',
  'Doa Terkait Harta dan Hutang',
  'Doa Saat Sedih dan Sulit',
  'Doa Saat Sakit',
  'Doa Menghadapi Fenomena Alam',
  'Doa Perlindungan',
  'Istighfar Dan Taubat',
  'Lafal Dzikir Dan Keutamaannya',
];

const _enGroupFallback = <String, String>{
  'Doa Sebelum dan Sesudah Tidur': 'Before & After Sleep',
  'Doa di Kamar Mandi': 'Restroom Etiquette',
  'Doa Saat Wudhu': 'During Wudu',
  'Doa Berpakaian': 'Getting Dressed',
  'Doa Keluar Dan Masuk Rumah': 'Leaving & Entering Home',
  'Doa Terkait Masjid': 'Mosque Duas',
  'Bacaan Terkait Adzan': 'Call to Prayer (Adhan)',
  'Beberapa Doa Terkait Shalat': 'Prayer Supplications',
  'Doa Terkait Makan': 'Eating & Drinking',
  'Doa Perjalanan': 'Travel Duas',
  'Doa Memohon Ilmu': 'Seeking Knowledge',
  'Doa Terkait Orang Tua': 'For Parents',
  'Doa Terkait Harta dan Hutang': 'Wealth & Debt Relief',
  'Doa Saat Sedih dan Sulit': 'Grief & Hardship',
  'Doa Saat Sakit': 'Illness & Healing',
  'Doa Menghadapi Fenomena Alam': 'Weather & Nature',
  'Doa Perlindungan': 'Seeking Protection',
  'Istighfar Dan Taubat': 'Forgiveness & Repentance',
  'Lafal Dzikir Dan Keutamaannya': 'Dhikr & Its Virtues',
  'Doa Harian': 'Daily Duas',
  'Doa Harian & Aktivitas Sehari-hari': 'Daily & Activity Duas',
};

String _duaGroupDisplay(DailyDua dua, AppLanguage lang) {
  final label = dua.groupFor(lang);
  if (lang == AppLanguage.en && label == dua.group) {
    return _enGroupFallback[dua.group] ?? label;
  }
  return label;
}

List<String> _orderedGroups(List<DailyDua> list) {
  final seen = <String>{for (final d in list) d.group};
  return [
    for (final g in _priorityGroups)
      if (seen.remove(g)) g,
    ...seen,
  ];
}

class DoaListPage extends ConsumerStatefulWidget {
  final int initialTab;
  final GuidedDzikirTime initialDzikirTime;
  const DoaListPage({
    super.key,
    this.initialTab = 0,
    this.initialDzikirTime = GuidedDzikirTime.pagi,
  });

  @override
  ConsumerState<DoaListPage> createState() => _DoaListPageState();
}

class _DoaListPageState extends ConsumerState<DoaListPage> {
  final _searchController = TextEditingController();
  late int _tab;
  String _q = '';
  String? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _q = '');
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _q = '';
      _selectedGroup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDaily = _tab == 0;
    final isDzikir = _tab == 2;
    final dailyDuas = ref.watch(dailyDuasProvider);
    final quranDuas = ref.watch(quranicDuasProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Doa & Dzikir', 'Duas & Dhikr')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Doa Harian', 'Daily Duas'),
                context.tr('Doa Al-Qur\'an', 'Quranic Duas'),
                context.tr('Dzikir Terpandu', 'Guided Dhikr'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: isDzikir
                ? GuidedDzikirBody(
                    initialTime: widget.initialDzikirTime,
                    showInlineReset: true,
                  )
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(child: BrandArt(BrandIllustration.heroQuran, height: 150)),
                              const SizedBox(height: 8),
                              Text(
                                isDaily
                                    ? context.tr('Doa Harian & Aktivitas', 'Daily & Activity Duas')
                                    : context.tr('Doa dalam Al-Qur\'an', 'Duas in the Quran'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDaily
                                    ? context.tr(
                                        'Kumpulan doa sehari-hari dan aktivitas dari bangun tidur hingga tidur lagi.',
                                        'Collection of everyday duas from waking up until going to sleep.',
                                      )
                                    : context.tr(
                                        'Doa-doa yang diabadikan dalam Al-Qur\'an, lengkap dengan teks Arab dan terjemahan.',
                                        'Supplications preserved in the Quran, complete with Arabic text and translation.',
                                      ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                key: const Key('doa-search'),
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(MoeslimIcons.pencarian),
                                  suffixIcon: _q.isNotEmpty
                                      ? IconButton(
                                          key: const Key('doa-search-clear'),
                                          tooltip: context.tr('Hapus pencarian', 'Clear search'),
                                          onPressed: _clearSearch,
                                          icon: const Icon(Icons.close),
                                        )
                                      : null,
                                  hintText: isDaily
                                      ? context.tr(
                                          'Cari doa aktivitas (mis. tidur, makan, masjid, perjalanan)',
                                          'Search daily duas (e.g. sleep, meal, mosque, travel)',
                                        )
                                      : context.tr(
                                          'Cari doa (mis. ampunan, ilmu, orang tua)',
                                          'Search duas (e.g. forgiveness, knowledge, parents)',
                                        ),
                                ),
                                onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isDaily)
                        ..._buildDailySlivers(context, dailyDuas)
                      else
                        ..._buildQuranSlivers(context, quranDuas),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDailySlivers(BuildContext context, AsyncValue<List<DailyDua>> dailyDuas) {
    final lang = context.lang;
    return dailyDuas.when(
      loading: () => [
        SliverToBoxAdapter(
          child: _DoaLoadingState(
            label: context.tr('Memuat kumpulan doa harian...', 'Loading daily duas...'),
          ),
        ),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: _DoaErrorState(
            title: context.tr('Gagal memuat daftar doa harian.', 'Failed to load daily duas.'),
            detail: '$e',
            onRetry: () => ref.invalidate(dailyDuasProvider),
          ),
        ),
      ],
      data: (list) {
        final groups = _orderedGroups(list);
        final groupDisplay = <String, String>{
          for (final d in list) d.group: _duaGroupDisplay(d, lang),
        };
        final activeGroup = _selectedGroup != null && groups.contains(_selectedGroup) ? _selectedGroup : null;
        final activeGroupLabel = activeGroup == null ? null : (groupDisplay[activeGroup] ?? activeGroup);
        final filtered = [
          for (final d in list)
            if ((activeGroup == null || d.group == activeGroup) &&
                (d.matches(_q) || (groupDisplay[d.group]?.toLowerCase().contains(_q) ?? false)))
              d,
        ];
        final queryText = _searchController.text.trim();
        final hasActiveFilter = queryText.isNotEmpty || activeGroup != null;
        final String emptyMessage;
        if (queryText.isNotEmpty && activeGroupLabel != null) {
          emptyMessage = context.tr(
            'Tidak ada doa di kategori "$activeGroupLabel" yang cocok dengan "$queryText".',
            'No duas in "$activeGroupLabel" match "$queryText".',
          );
        } else if (queryText.isNotEmpty) {
          emptyMessage = context.tr(
            'Tidak ada doa yang cocok dengan "$queryText".',
            'No duas match "$queryText".',
          );
        } else if (activeGroupLabel != null) {
          emptyMessage = context.tr(
            'Belum ada doa pada kategori "$activeGroupLabel".',
            'No duas in "$activeGroupLabel" yet.',
          );
        } else {
          emptyMessage = context.tr(
            'Belum ada data doa harian yang dimuat di perangkat.',
            'No daily duas are loaded on this device yet.',
          );
        }

        return [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              key: const Key('doa-categories'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: const Key('doa-cat-all'),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(context.tr('Semua (${list.length})', 'All (${list.length})')),
                      selected: activeGroup == null,
                      onSelected: (_) => setState(() => _selectedGroup = null),
                    ),
                  ),
                  for (final g in groups)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(groupDisplay[g] ?? g),
                        selected: activeGroup == g,
                        onSelected: (_) => setState(() => _selectedGroup = activeGroup == g ? null : g),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                context.tr('Menampilkan ${filtered.length} doa', 'Showing ${filtered.length} duas'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: _DoaEmptyState(
                icon: hasActiveFilter ? MoeslimIcons.pencarian : MoeslimIcons.alquran,
                title: hasActiveFilter
                    ? context.tr('Doa tidak ditemukan', 'No duas found')
                    : context.tr('Data doa belum tersedia', 'Dua data unavailable'),
                message: emptyMessage,
                actionLabel: hasActiveFilter
                    ? context.tr('Reset filter', 'Reset filters')
                    : context.tr('Muat ulang', 'Reload'),
                actionKey: const Key('doa-reset-filter'),
                onAction: hasActiveFilter ? _resetFilters : () => ref.invalidate(dailyDuasProvider),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final d = filtered[index];
                  final groupLabel = _duaGroupDisplay(d, lang);
                  return Card(
                    child: ListTile(
                      leading: OctagonNumber(index + 1),
                      title: Text(d.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '$groupLabel • ${d.translationFor(lang)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DailyDuaDetailPage(dua: d)),
                      ),
                    ),
                  );
                },
              ),
            ),
        ];
      },
    );
  }

  List<Widget> _buildQuranSlivers(BuildContext context, AsyncValue<List<QuranicDua>> duas) {
    final lang = context.lang;
    return duas.when(
      loading: () => [
        SliverToBoxAdapter(
          child: _DoaLoadingState(
            label: context.tr('Memuat doa dalam Al-Qur\'an...', 'Loading Quranic duas...'),
          ),
        ),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: _DoaErrorState(
            title: context.tr('Gagal memuat doa dalam Al-Qur\'an.', 'Failed to load Quranic duas.'),
            detail: '$e',
            onRetry: () => ref.invalidate(quranicDuasProvider),
          ),
        ),
      ],
      data: (list) {
        if (list.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: _DoaEmptyState(
                icon: MoeslimIcons.quranTerbuka,
                title: context.tr('Teks Al-Qur\'an belum tersedia', 'Quran text unavailable'),
                message: context.tr(
                  'Aset teks Al-Qur\'an belum dimuat di perangkat ini. Muat ulang untuk mencoba kembali.',
                  'Quran text assets are not loaded on this device yet. Reload to try again.',
                ),
                actionLabel: context.tr('Muat ulang', 'Reload'),
                actionKey: const Key('doa-quran-reload'),
                onAction: () => ref.invalidate(quranicDuasProvider),
              ),
            ),
          ];
        }
        final filtered = list
            .where(
              (d) =>
                  _q.isEmpty ||
                  d.translationFor(lang).toLowerCase().contains(_q) ||
                  d.translation.toLowerCase().contains(_q) ||
                  d.referenceFor(lang).toLowerCase().contains(_q) ||
                  d.reference.toLowerCase().contains(_q),
            )
            .take(200)
            .toList();
        if (filtered.isEmpty) {
          final queryText = _searchController.text.trim();
          return [
            SliverToBoxAdapter(
              child: _DoaEmptyState(
                icon: MoeslimIcons.pencarian,
                title: context.tr('Doa tidak ditemukan', 'No duas found'),
                message: context.tr(
                  'Tidak ada doa Al-Qur\'an yang cocok dengan "$queryText".',
                  'No Quranic duas match "$queryText".',
                ),
                actionLabel: context.tr('Hapus pencarian', 'Clear search'),
                actionKey: const Key('doa-search-reset'),
                onAction: _clearSearch,
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final d = filtered[index];
                return Card(
                  child: ListTile(
                    title: Text(d.referenceFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(d.translationFor(lang), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DoaDetailPage(dua: d))),
                  ),
                );
              },
            ),
          ),
        ];
      },
    );
  }
}

class _DoaLoadingState extends StatelessWidget {
  const _DoaLoadingState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DoaErrorState extends StatelessWidget {
  const _DoaErrorState({
    required this.title,
    required this.detail,
    required this.onRetry,
  });

  final String title;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 32, color: cs.error),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(detail, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.tr('Coba lagi', 'Try again')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoaEmptyState extends StatelessWidget {
  const _DoaEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.actionKey,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: actionKey,
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menghapus baris atribusi "Sumber: ..." agar seluruh referensi dipusatkan di menu Tentang.
String cleanDuaNote(String raw) {
  final lines = raw
      .split('\n')
      .where((line) => !RegExp(r'^\s*(sumber|source)\s*:', caseSensitive: false).hasMatch(line))
      .toList();
  while (lines.isNotEmpty && lines.last.trim().isEmpty) {
    lines.removeLast();
  }
  while (lines.isNotEmpty && lines.first.trim().isEmpty) {
    lines.removeAt(0);
  }
  return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

class DailyDuaDetailPage extends StatelessWidget {
  final DailyDua dua;
  const DailyDuaDetailPage({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final title = dua.titleFor(lang);
    final group = _duaGroupDisplay(dua, lang);
    final translation = dua.translationFor(lang);
    final note = cleanDuaNote(dua.sourceFor(lang));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Detail Doa', 'Dua Details')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('dua-share-card-btn'),
            tooltip: context.tr('Buat kartu doa', 'Create dua card'),
            icon: const Icon(Icons.style_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShareCardPage(
                  initialArabic: dua.arabic,
                  initialLatin: dua.latin,
                  initialTranslation: translation,
                  initialSource: note.isNotEmpty && note.length <= 64 ? '$title · $note' : title,
                  initialBadge: group,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.tr('Salin doa', 'Copy dua'),
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () {
              final text = [
                title,
                dua.arabic,
                if (dua.latin.isNotEmpty) dua.latin,
                context.tr('Artinya: $translation', 'Meaning: $translation'),
                if (note.isNotEmpty) note,
              ].join('\n\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('Doa disalin ke clipboard', 'Dua copied to clipboard'))),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: _DuaHeader(
              badge: group,
              title: title,
              arabicWidgets: [
                Text(
                  dua.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 25),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (dua.latin.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.record_voice_over_outlined, color: BrandColors.emerald),
                title: Text(
                  context.tr('Bacaan Latin', 'Transliteration'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(dua.latin, style: const TextStyle(fontStyle: FontStyle.italic)),
                ),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.translate, color: BrandColors.emerald),
              title: Text(
                context.tr('Artinya', 'Translation'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(translation)),
            ),
          ),
          if (note.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(MoeslimIcons.quranTerbuka, color: BrandColors.emerald),
                title: Text(
                  context.tr('Keterangan', 'Notes'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(note)),
              ),
            ),
        ],
      ),
    );
  }
}

class DoaDetailPage extends StatelessWidget {
  final QuranicDua dua;
  const DoaDetailPage({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Detail Doa', 'Dua Details')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('quran-dua-share-card-btn'),
            tooltip: context.tr('Buat kartu doa', 'Create dua card'),
            icon: const Icon(Icons.style_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShareCardPage(
                  initialArabic: dua.ayat.map((a) => a.text).join(' ۝ '),
                  initialTranslation: dua.translationFor(lang),
                  initialSource: dua.referenceFor(lang),
                  initialBadge: context.tr('Doa Al-Qur\'an', 'Quranic Dua'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: _DuaHeader(
              badge: context.tr('Doa dalam Al-Qur\'an', 'Quranic Dua'),
              title: dua.referenceFor(lang),
              arabicWidgets: [
                for (final a in dua.ayat)
                  Text(
                    a.text,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: quranTextStyle(fontSize: 26),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.translate, color: BrandColors.emerald),
              title: Text(
                context.tr('Artinya', 'Translation'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(dua.translationFor(lang))),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaHeader extends StatelessWidget {
  final String badge;
  final String title;
  final List<Widget> arabicWidgets;
  const _DuaHeader({required this.badge, required this.title, required this.arabicWidgets});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: BrandColors.emerald, borderRadius: BorderRadius.circular(20)),
          child: Text(
            badge,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Text(title, style: t.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...arabicWidgets,
        const SizedBox(height: 10),
        const BrandElementArt(BrandElement.ayahDivider, width: 150, height: 26),
      ],
    );
  }
}
