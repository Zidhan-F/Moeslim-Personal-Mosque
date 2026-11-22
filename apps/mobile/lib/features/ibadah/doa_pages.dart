import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../ui/components.dart';
import '../quran/quran_source.dart';

/// Satu doa dalam Al-Qur'an: rentang ayat beserta teks & terjemahan dari dataset terpasang.
class QuranicDua {
  final int surah;
  final int from;
  final int to;
  final List<Ayah> ayat;
  const QuranicDua(this.surah, this.from, this.to, this.ayat);

  String get reference => 'QS. ${surahs[surah - 1].name}: ${from == to ? '$from' : '$from–$to'}';
  String get translation => ayat.map((a) => a.translation ?? '').join(' ');
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

List<String> _orderedGroups(List<DailyDua> list) {
  final seen = <String>{for (final d in list) d.group};
  return [
    for (final g in _priorityGroups)
      if (seen.remove(g)) g,
    ...seen,
  ];
}

class DoaListPage extends ConsumerStatefulWidget {
  const DoaListPage({super.key});

  @override
  ConsumerState<DoaListPage> createState() => _DoaListPageState();
}

class _DoaListPageState extends ConsumerState<DoaListPage> {
  final _searchController = TextEditingController();
  int _tab = 0;
  String _q = '';
  String? _selectedGroup;

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
    final dailyDuas = ref.watch(dailyDuasProvider);
    final quranDuas = ref.watch(quranicDuasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Doa & Dzikir'), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PillTabs(
                    labels: const ['Doa Harian', 'Doa Al-Qur\'an'],
                    index: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: BrandArt(BrandIllustration.heroQuran, height: 150)),
                  const SizedBox(height: 8),
                  Text(
                    isDaily ? 'Doa Harian & Aktivitas' : 'Doa dalam Al-Qur\'an',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDaily
                        ? 'Kumpulan doa sehari-hari dan aktivitas dari bangun tidur hingga tidur lagi.'
                        : 'Doa-doa yang diabadikan dalam Al-Qur\'an, lengkap dengan teks Arab dan terjemahan.',
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
                              tooltip: 'Hapus pencarian',
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      hintText: isDaily
                          ? 'Cari doa aktivitas (mis. tidur, makan, masjid, perjalanan)'
                          : 'Cari doa (mis. ampunan, ilmu, orang tua)',
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
    );
  }

  List<Widget> _buildDailySlivers(BuildContext context, AsyncValue<List<DailyDua>> dailyDuas) {
    return dailyDuas.when(
      loading: () => const [
        SliverToBoxAdapter(child: _DoaLoadingState(label: 'Memuat kumpulan doa harian...')),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: _DoaErrorState(
            title: 'Gagal memuat daftar doa harian.',
            detail: '$e',
            onRetry: () => ref.invalidate(dailyDuasProvider),
          ),
        ),
      ],
      data: (list) {
        final groups = _orderedGroups(list);
        final activeGroup = _selectedGroup != null && groups.contains(_selectedGroup) ? _selectedGroup : null;
        final filtered = [
          for (final d in list)
            if ((activeGroup == null || d.group == activeGroup) && d.matches(_q)) d,
        ];
        final queryText = _searchController.text.trim();
        final hasActiveFilter = queryText.isNotEmpty || activeGroup != null;
        final String emptyMessage;
        if (queryText.isNotEmpty && activeGroup != null) {
          emptyMessage = 'Tidak ada doa di kategori "$activeGroup" yang cocok dengan "$queryText".';
        } else if (queryText.isNotEmpty) {
          emptyMessage = 'Tidak ada doa yang cocok dengan "$queryText".';
        } else if (activeGroup != null) {
          emptyMessage = 'Belum ada doa pada kategori "$activeGroup".';
        } else {
          emptyMessage = 'Belum ada data doa harian yang dimuat di perangkat.';
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
                      label: Text('Semua (${list.length})'),
                      selected: activeGroup == null,
                      onSelected: (_) => setState(() => _selectedGroup = null),
                    ),
                  ),
                  for (final g in groups)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(g),
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
                'Menampilkan ${filtered.length} doa',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: _DoaEmptyState(
                icon: hasActiveFilter ? MoeslimIcons.pencarian : MoeslimIcons.alquran,
                title: hasActiveFilter ? 'Doa tidak ditemukan' : 'Data doa belum tersedia',
                message: emptyMessage,
                actionLabel: hasActiveFilter ? 'Reset filter' : 'Muat ulang',
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
                  return Card(
                    child: ListTile(
                      leading: OctagonNumber(index + 1),
                      title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${d.group} • ${d.translation}', maxLines: 2, overflow: TextOverflow.ellipsis),
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
    return duas.when(
      loading: () => const [
        SliverToBoxAdapter(child: _DoaLoadingState(label: 'Memuat doa dalam Al-Qur\'an...')),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: _DoaErrorState(
            title: 'Gagal memuat doa dalam Al-Qur\'an.',
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
                title: 'Teks Al-Qur\'an belum tersedia',
                message: 'Aset teks Al-Qur\'an belum dimuat di perangkat ini. Muat ulang untuk mencoba kembali.',
                actionLabel: 'Muat ulang',
                actionKey: const Key('doa-quran-reload'),
                onAction: () => ref.invalidate(quranicDuasProvider),
              ),
            ),
          ];
        }
        final filtered = list
            .where((d) => _q.isEmpty || d.translation.toLowerCase().contains(_q) || d.reference.toLowerCase().contains(_q))
            .take(200)
            .toList();
        if (filtered.isEmpty) {
          final queryText = _searchController.text.trim();
          return [
            SliverToBoxAdapter(
              child: _DoaEmptyState(
                icon: MoeslimIcons.pencarian,
                title: 'Doa tidak ditemukan',
                message: 'Tidak ada doa Al-Qur\'an yang cocok dengan "$queryText".',
                actionLabel: 'Hapus pencarian',
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
                    title: Text(d.reference, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(d.translation, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                label: const Text('Coba lagi'),
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
      .where((line) => !RegExp(r'^\s*sumber\s*:', caseSensitive: false).hasMatch(line))
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
    final note = cleanDuaNote(dua.source);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Doa'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Salin doa',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () {
              final text = [
                dua.title,
                dua.arabic,
                if (dua.latin.isNotEmpty) dua.latin,
                'Artinya: ${dua.translation}',
                if (note.isNotEmpty) note,
              ].join('\n\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doa disalin ke clipboard')));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: _DuaHeader(
              badge: dua.group,
              title: dua.title,
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
                title: const Text('Bacaan Latin', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(dua.latin, style: const TextStyle(fontStyle: FontStyle.italic)),
                ),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.translate, color: BrandColors.emerald),
              title: const Text('Artinya', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(dua.translation)),
            ),
          ),
          if (note.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(MoeslimIcons.quranTerbuka, color: BrandColors.emerald),
                title: const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.w600)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Doa'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: _DuaHeader(
              badge: 'Doa dalam Al-Qur\'an',
              title: dua.reference,
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
              title: const Text('Artinya', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(dua.translation)),
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
