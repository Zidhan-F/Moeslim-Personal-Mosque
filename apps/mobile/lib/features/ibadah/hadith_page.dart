import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';

class HadithPage extends ConsumerStatefulWidget {
  const HadithPage({super.key});

  @override
  ConsumerState<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends ConsumerState<HadithPage> {
  final _searchController = TextEditingController();
  int _collectionTab = 0;
  String _query = '';
  String? _selectedTopic;
  Set<int> _bookmarkedIds = {};

  static const _collections = ['Semua', 'Arba\'in Nawawi', 'Riyadus Shalihin'];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final ids = await ref.read(hadithRepoProvider).bookmarkedIds();
    if (mounted) setState(() => _bookmarkedIds = ids);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTopic = null;
      _collectionTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daily = dailyHadithFor(DateTime.now());
    final topics = {for (final h in hadithCatalog) h.topic}.toList();
    final activeCollection = _collectionTab == 0 ? null : _collections[_collectionTab];
    final filtered = [
      for (final h in hadithCatalog)
        if ((activeCollection == null || h.collection == activeCollection) &&
            (_selectedTopic == null || h.topic == _selectedTopic) &&
            h.matches(_query))
          h,
    ];
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kitab Hadits Pilihan'), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PillTabs(
                    labels: _collections,
                    index: _collectionTab,
                    onChanged: (i) => setState(() => _collectionTab = i),
                  ),
                  const SizedBox(height: 12),
                  OrnamentCard(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HadithDetailPage(hadith: daily)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(MoeslimIcons.bintang, color: BrandColors.goldText, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Hadits Hari Ini · ${daily.collection} #${daily.number}',
                                style: t.labelLarge?.copyWith(color: BrandColors.emerald, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(daily.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(daily.translation, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('hadith-search'),
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(MoeslimIcons.pencarian),
                      hintText: 'Cari hadits (mis. niat, ilmu, marah, tetangga, halal)',
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              key: const Key('hadith-search-clear'),
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text('Semua Tema (${hadithCatalog.length})'),
                      selected: _selectedTopic == null,
                      onSelected: (_) => setState(() => _selectedTopic = null),
                    ),
                  ),
                  for (final topic in topics)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(topic),
                        selected: _selectedTopic == topic,
                        onSelected: (_) => setState(() => _selectedTopic = _selectedTopic == topic ? null : topic),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text('Menampilkan ${filtered.length} hadits shahih', style: t.bodySmall),
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(MoeslimIcons.pencarian, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Hadits tidak ditemukan', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'Tidak ada hadits yang cocok dengan filter atau kata kunci "${_searchController.text.trim()}".',
                        textAlign: TextAlign.center,
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('hadith-reset-filter'),
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset filter'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final h = filtered[index];
                  final marked = _bookmarkedIds.contains(h.id);
                  return Card(
                    child: ListTile(
                      leading: OctagonNumber(h.number),
                      title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${h.collection} · ${h.topic}\n${h.translation}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: marked ? 'Hapus penanda hadits' : 'Simpan penanda hadits',
                        onPressed: () async {
                          final next = await ref.read(hadithRepoProvider).toggleBookmark(h.id);
                          setState(() => _bookmarkedIds = next);
                        },
                        icon: Icon(
                          marked ? MoeslimIcons.bookmark : MoeslimIcons.penanda,
                          color: marked ? BrandColors.goldText : null,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HadithDetailPage(hadith: h)),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class HadithDetailPage extends StatelessWidget {
  final HadithItem hadith;
  const HadithDetailPage({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${hadith.collection} #${hadith.number}'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Salin hadits',
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: '${hadith.title} (${hadith.collection} #${hadith.number})\n\n'
                      '${hadith.arabic}\n\n${hadith.latin}\n\n'
                      'Artinya: "${hadith.translation}"\n(${hadith.narrator})',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teks hadits disalin ke papan klip.')),
              );
            },
            icon: const Icon(MoeslimIcons.bagikan),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: Column(
              children: [
                Text(hadith.topic, style: t.labelLarge?.copyWith(color: scheme.primary)),
                const SizedBox(height: 4),
                Text(
                  hadith.title,
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Text(
                  hadith.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 26),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bacaan Latin', style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(hadith.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terjemahan & Perawi', style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(hadith.translation, style: t.bodyLarge),
                  const SizedBox(height: 10),
                  Text(hadith.narrator, style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Faidah & Intisari Fiqih', style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(hadith.fiqhPoints, style: t.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
