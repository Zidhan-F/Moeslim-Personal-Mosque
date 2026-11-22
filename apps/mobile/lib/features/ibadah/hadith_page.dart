import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'share_card_page.dart';

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

  static const _collectionKeys = [
    null,
    'Arba\'in Nawawi',
    'Shahih Bukhari & Muslim',
    'Riyadus Shalihin',
  ];

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
    final lang = context.lang;
    final daily = dailyHadithFor(DateTime.now());
    final topics = <String, String>{for (final h in hadithCatalog) h.topic: h.topicFor(lang)};
    final activeCollection = _collectionKeys[_collectionTab];
    final filtered = [
      for (final h in hadithCatalog)
        if ((activeCollection == null || h.collection == activeCollection) &&
            (_selectedTopic == null || h.topic == _selectedTopic) &&
            h.matches(_query))
          h,
    ];
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Kitab Hadits Pilihan', 'Selected Hadith Collection')), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PillTabs(
                    labels: [
                      context.tr('Semua', 'All'),
                      context.tr('Arba\'in Nawawi', 'Nawawi\'s 40'),
                      context.tr('Bukhari & Muslim', 'Bukhari & Muslim'),
                      context.tr('Riyadus Shalihin', 'Riyad al-Salihin'),
                    ],
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
                              Expanded(
                                child: Text(
                                  context.tr(
                                    'Hadits Hari Ini · ${daily.collectionFor(lang)} #${daily.number}',
                                    'Hadith of the Day · ${daily.collectionFor(lang)} #${daily.number}',
                                  ),
                                  style: t.labelLarge?.copyWith(color: BrandColors.emerald, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            daily.titleFor(lang),
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            daily.translationFor(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall,
                          ),
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
                      hintText: context.tr(
                        'Cari hadits (mis. niat, ilmu, marah, tetangga, halal)',
                        'Search hadith (e.g. intention, knowledge, anger, neighbor, halal)',
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              key: const Key('hadith-search-clear'),
                              tooltip: context.tr('Hapus pencarian', 'Clear search'),
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
                      label: Text(
                        context.tr('Semua Tema (${hadithCatalog.length})', 'All Topics (${hadithCatalog.length})'),
                      ),
                      selected: _selectedTopic == null,
                      onSelected: (_) => setState(() => _selectedTopic = null),
                    ),
                  ),
                  for (final entry in topics.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(entry.value),
                        selected: _selectedTopic == entry.key,
                        onSelected: (_) => setState(() => _selectedTopic = _selectedTopic == entry.key ? null : entry.key),
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
                context.tr(
                  'Menampilkan ${filtered.length} hadits shahih',
                  'Showing ${filtered.length} authentic hadiths',
                ),
                style: t.bodySmall,
              ),
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
                      Text(
                        context.tr('Hadits tidak ditemukan', 'No hadiths found'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          'Tidak ada hadits yang cocok dengan filter atau kata kunci "${_searchController.text.trim()}".',
                          'No hadiths match the current filter or keyword "${_searchController.text.trim()}".',
                        ),
                        textAlign: TextAlign.center,
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('hadith-reset-filter'),
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh),
                        label: Text(context.tr('Reset filter', 'Reset filters')),
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
                      leading: OctagonNumber(h.id),
                      title: Text(h.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${h.collectionFor(lang)} · ${h.topicFor(lang)}\n${h.translationFor(lang)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: marked
                            ? context.tr('Hapus penanda hadits', 'Remove hadith bookmark')
                            : context.tr('Simpan penanda hadits', 'Bookmark hadith'),
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
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final collection = hadith.collectionFor(lang);
    final topic = hadith.topicFor(lang);
    final title = hadith.titleFor(lang);
    final translation = hadith.translationFor(lang);
    final narrator = hadith.narratorFor(lang);
    final fiqhPoints = hadith.fiqhPointsFor(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text('$collection #${hadith.number}'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('hadith-share-card-btn'),
            tooltip: context.tr('Buat kartu bagikan', 'Create share card'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShareCardPage(
                  initialArabic: hadith.arabic,
                  initialLatin: hadith.latin,
                  initialTranslation: translation,
                  initialSource: narrator,
                  initialBadge: collection,
                ),
              ),
            ),
            icon: const Icon(Icons.style_outlined),
          ),
          IconButton(
            tooltip: context.tr('Salin hadits', 'Copy hadith'),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: '$title ($collection #${hadith.number})\n\n'
                      '${hadith.arabic}\n\n${hadith.latin}\n\n'
                      '${context.tr('Artinya', 'Translation')}: "$translation"\n($narrator)',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.tr('Teks hadits disalin ke papan klip.', 'Hadith text copied to clipboard.'),
                  ),
                ),
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
                Text(topic, style: t.labelLarge?.copyWith(color: scheme.primary)),
                const SizedBox(height: 4),
                Text(
                  title,
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
                  Text(
                    context.tr('Bacaan Latin', 'Transliteration'),
                    style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
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
                  Text(
                    context.tr('Terjemahan & Perawi', 'Translation & Narrator'),
                    style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(translation, style: t.bodyLarge),
                  const SizedBox(height: 10),
                  Text(narrator, style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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
                  Text(
                    context.tr('Faidah & Intisari Fiqih', 'Benefits & Fiqh Takeaways'),
                    style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(fiqhPoints, style: t.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
