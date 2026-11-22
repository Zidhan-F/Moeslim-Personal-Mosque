import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../ui/components.dart';

class FiqihGuidePage extends StatefulWidget {
  const FiqihGuidePage({super.key});

  @override
  State<FiqihGuidePage> createState() => _FiqihGuidePageState();
}

class _FiqihGuidePageState extends State<FiqihGuidePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  FiqihCategory? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = [
      for (final topic in fiqihGuideCatalog)
        if ((_selectedCategory == null || topic.category == _selectedCategory) && topic.matches(_query)) topic,
    ];
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Ibadah & Fiqih'), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PatternBanner(
                    child: Text(
                      'Tuntunan langkah demi langkah wudhu, tayammum, salat fardhu, salat sunnah, salat safar, hingga salat jenazah beserta bacaannya.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('fiqih-search'),
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(MoeslimIcons.pencarian),
                      hintText: 'Cari panduan (mis. wudhu, tayammum, istikharah, qashar, jenazah)',
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              key: const Key('fiqih-search-clear'),
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchCtrl.clear();
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
                      label: Text('Semua (${fiqihGuideCatalog.length})'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                  ),
                  for (final cat in FiqihCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(cat.label),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(() => _selectedCategory = _selectedCategory == cat ? null : cat),
                      ),
                    ),
                ],
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
                      Icon(MoeslimIcons.buku, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Panduan tidak ditemukan', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'Tidak ada materi fiqih yang cocok dengan "${_searchCtrl.text.trim()}".',
                        textAlign: TextAlign.center,
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('fiqih-reset-filter'),
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final topic = filtered[index];
                  return Card(
                    child: ListTile(
                      leading: OctagonNumber(index + 1),
                      title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${topic.category.label} · ${topic.steps.length} langkah\n${topic.summary}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FiqihTopicDetailPage(topic: topic)),
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

class FiqihTopicDetailPage extends StatelessWidget {
  final FiqihGuideTopic topic;
  const FiqihTopicDetailPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(topic.category.label), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: Column(
              children: [
                Text(
                  topic.title,
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(topic.summary, textAlign: TextAlign.center, style: t.bodyMedium),
                const SizedBox(height: 8),
                Text(topic.dalil, textAlign: TextAlign.center, style: t.bodySmall?.copyWith(color: scheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final step in topic.steps)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        OctagonNumber(step.number),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text('Hukum: ${step.ruling}', style: t.bodySmall?.copyWith(color: scheme.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(step.description, style: t.bodyMedium),
                    if (step.arabic != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        step.arabic!,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(fontSize: 24),
                      ),
                    ],
                    if (step.latin != null) ...[
                      const SizedBox(height: 6),
                      Text(step.latin!, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                    ],
                    if (step.translation != null) ...[
                      const SizedBox(height: 4),
                      Text('Artinya: "${step.translation!}"', style: t.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
