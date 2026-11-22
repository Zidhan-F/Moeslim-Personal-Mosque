import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

String _sirahSectionLabel(BuildContext context, SirahSection s) => switch (s) {
      SirahSection.sirahNabawiyah => context.tr(s.label, 'Prophetic Seerah'),
      SirahSection.kisah25Nabi => context.tr(s.label, '25 Prophets'),
      SirahSection.biografiSahabat => context.tr(s.label, 'Companions'),
    };

class SirahPage extends ConsumerStatefulWidget {
  const SirahPage({super.key});

  @override
  ConsumerState<SirahPage> createState() => _SirahPageState();
}

class _SirahPageState extends ConsumerState<SirahPage> {
  final _searchCtrl = TextEditingController();
  int _tab = 0;
  String _query = '';
  Set<String> _completedIds = {};
  String? _lastReadId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(sirahRepoProvider);
    final done = await repo.completedChapters();
    final last = await repo.lastReadChapterId();
    if (mounted) {
      setState(() {
        _completedIds = done;
        _lastReadId = last;
      });
    }
  }

  Future<void> _openChapter(SirahChapter chapter) async {
    await ref.read(sirahRepoProvider).markRead(chapter.id);
    await _load();
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SirahChapterDetailPage(chapter: chapter)));
  }

  String _sectionCaption(BuildContext context, SirahSection s) {
    final n = sirahLibraryCatalog.where((c) => c.section == s).length;
    return switch (s) {
      SirahSection.sirahNabawiyah => context.tr(
          '$n bab berurutan, dari Jazirah Arab sebelum Islam hingga wafatnya Rasulullah SAW',
          '$n chronological chapters, from pre-Islamic Arabia to the passing of Prophet Muhammad (PBUH)',
        ),
      SirahSection.kisah25Nabi => context.tr(
          '$n nabi dan rasul, satu bab untuk setiap nabi, dari Nabi Adam AS hingga Nabi Muhammad SAW',
          '$n prophets and messengers, one chapter for each prophet, from Prophet Adam (AS) to Prophet Muhammad (PBUH)',
        ),
      SirahSection.biografiSahabat => context.tr(
          '$n sahabat dan shahabiyah, termasuk Khulafaur Rasyidin dan sepuluh sahabat yang dijamin surga',
          '$n male and female companions, including the Rightly Guided Caliphs and the ten promised Paradise',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final section = SirahSection.values[_tab];
    final filtered = [
      for (final c in sirahLibraryCatalog)
        if (c.section == section && c.matches(_query)) c,
    ];
    final lastChapter = sirahLibraryCatalog.where((c) => c.id == _lastReadId).firstOrNull;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Sirah, 25 Nabi & Sahabat', 'Seerah, 25 Prophets & Companions')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                PillTabs(
                  labels: [for (final s in SirahSection.values) _sirahSectionLabel(context, s)],
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _sectionCaption(context, section),
                    key: const Key('sirah-caption'),
                    textAlign: TextAlign.center,
                    style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                if (lastChapter != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: Icon(MoeslimIcons.bookmark, color: scheme.primary),
                      title: Text(
                        context.tr(
                          'Terakhir Dibaca: ${lastChapter.titleFor(lang)}',
                          'Last Read: ${lastChapter.titleFor(lang)}',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(lastChapter.periodOrTitleFor(lang)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openChapter(lastChapter),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  key: const Key('sirah-search'),
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(MoeslimIcons.pencarian),
                    hintText: context.tr(
                      'Cari kisah (mis. Hijrah, Badar, Ibrahim, Yusuf, Abu Bakar)',
                      'Search stories (e.g., Hijrah, Badr, Ibrahim, Yusuf, Abu Bakr)',
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: context.tr('Hapus pencarian', 'Clear search'),
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
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MoeslimIcons.buku, size: 32, color: scheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('Kisah tidak ditemukan', 'No stories found'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(context.tr('Reset pencarian', 'Reset search')),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      final isDone = _completedIds.contains(c.id);
                      final mins = c.readingMinutesFor(lang);
                      return Card(
                        child: ListTile(
                          leading: OctagonNumber(c.order),
                          title: Text(c.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            context.tr(
                              '${c.periodOrTitleFor(lang)} · $mins menit baca',
                              '${c.periodOrTitleFor(lang)} · $mins min read',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            isDone ? MoeslimIcons.berhasil : Icons.chevron_right,
                            color: isDone ? scheme.primary : null,
                          ),
                          onTap: () => _openChapter(c),
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

class SirahChapterDetailPage extends ConsumerWidget {
  final SirahChapter chapter;
  const SirahChapterDetailPage({super.key, required this.chapter});

  List<SirahChapter> get _siblings => [
    for (final c in sirahLibraryCatalog)
      if (c.section == chapter.section) c,
  ];

  void _go(BuildContext context, WidgetRef ref, SirahChapter target) {
    ref.read(sirahRepoProvider).markRead(target.id);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SirahChapterDetailPage(chapter: target)));
  }

  Widget _block(BuildContext context, SirahBlock b) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final body = t.bodyLarge?.copyWith(height: 1.6);
    switch (b.kind) {
      case SirahBlockKind.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Semantics(
            header: true,
            child: Text(
              b.text,
              style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
        );
      case SirahBlockKind.bullet:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: BrandColors.gold, shape: BoxShape.circle),
                ),
              ),
              Expanded(child: Text(b.text, style: body)),
            ],
          ),
        );
      case SirahBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(b.text, style: body),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final siblings = _siblings;
    final index = siblings.indexWhere((c) => c.id == chapter.id);
    final prev = index > 0 ? siblings[index - 1] : null;
    final next = index >= 0 && index < siblings.length - 1 ? siblings[index + 1] : null;
    final mins = chapter.readingMinutesFor(lang);

    return Scaffold(
      appBar: AppBar(title: Text(_sirahSectionLabel(context, chapter.section)), centerTitle: true),
      body: ListView(
        key: const Key('sirah-detail'),
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: Column(
              children: [
                Text(
                  chapter.periodOrTitleFor(lang),
                  textAlign: TextAlign.center,
                  style: t.labelLarge?.copyWith(color: scheme.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  chapter.titleFor(lang),
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'Bab ${chapter.order} dari ${siblings.length} · $mins menit baca',
                    'Chapter ${chapter.order} of ${siblings.length} · $mins min read',
                  ),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final b in chapter.blocksFor(lang)) _block(context, b)],
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
                    context.tr('Hikmah & Keteladanan', 'Wisdom & Role Models'),
                    style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(chapter.hikmahFor(lang), style: t.bodyLarge?.copyWith(height: 1.5)),
                  const SizedBox(height: 10),
                  Text(
                    context.tr(
                      'Rujukan: ${chapter.referenceFor(lang)}',
                      'Reference: ${chapter.referenceFor(lang)}',
                    ),
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: prev == null
                    ? const SizedBox.shrink()
                    : OutlinedButton.icon(
                        key: const Key('sirah-prev'),
                        onPressed: () => _go(context, ref, prev),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(
                          context.tr('Bab ${prev.order}', 'Ch. ${prev.order}'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: next == null
                    ? const SizedBox.shrink()
                    : FilledButton.icon(
                        key: const Key('sirah-next'),
                        onPressed: () => _go(context, ref, next),
                        icon: const Icon(Icons.chevron_right),
                        label: Text(
                          context.tr(
                            'Bab ${next.order}: ${next.titleFor(lang)}',
                            'Ch. ${next.order}: ${next.titleFor(lang)}',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
