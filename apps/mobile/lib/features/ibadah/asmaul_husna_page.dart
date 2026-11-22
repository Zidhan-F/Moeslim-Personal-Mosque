import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';

class AsmaulHusnaPage extends ConsumerStatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  ConsumerState<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends ConsumerState<AsmaulHusnaPage> {
  final _searchCtrl = TextEditingController();
  int _tab = 0;
  String _query = '';
  bool _onlyMemorized = false;
  Set<int> _memorized = {};

  // Quiz state
  int _quizIndex = 0;
  int _score = 0;
  int? _selectedOptionNumber;

  @override
  void initState() {
    super.initState();
    _loadMemorized();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMemorized() async {
    final m = await ref.read(asmaulHusnaRepoProvider).memorizedNumbers();
    if (mounted) setState(() => _memorized = m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asmaul Husna (99 Nama Allah)'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['99 Nama Allah', 'Kuis Hafalan'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _tab == 0 ? _buildListTab(context) : _buildQuizTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab(BuildContext context) {
    final filtered = [
      for (final item in asmaulHusnaCatalog)
        if ((!_onlyMemorized || _memorized.contains(item.number)) && item.matches(_query)) item,
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
                key: const Key('asmaul-search'),
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(MoeslimIcons.pencarian),
                  hintText: 'Cari nama atau arti (mis. Ar-Rahman, Pengampun, Rezeki)',
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          key: const Key('asmaul-search-clear'),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    label: const Text('Semua (99)'),
                    selected: !_onlyMemorized,
                    onSelected: (_) => setState(() => _onlyMemorized = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    key: const Key('asmaul-filter-memorized'),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    label: Text('Sudah Dihafal (${_memorized.length})'),
                    selected: _onlyMemorized,
                    onSelected: (_) => setState(() => _onlyMemorized = !_onlyMemorized),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MoeslimIcons.pencarian, size: 32, color: scheme.primary),
                        const SizedBox(height: 8),
                        Text('Nama tidak ditemukan', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'Tidak ada Asmaul Husna yang cocok dengan filter saat ini.',
                          textAlign: TextAlign.center,
                          style: t.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('asmaul-reset-filter'),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _query = '';
                              _onlyMemorized = false;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset filter'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isMem = _memorized.contains(item.number);
                    return Card(
                      child: ListTile(
                        leading: OctagonNumber(item.number),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.latin} · ${item.meaning}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              item.arabic,
                              textDirection: TextDirection.rtl,
                              style: quranTextStyle(fontSize: 22, color: scheme.primary),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(item.explanation),
                        ),
                        trailing: IconButton(
                          key: Key('asmaul-mem-${item.number}'),
                          tooltip: isMem ? 'Tandai belum hafal' : 'Tandai sudah hafal',
                          onPressed: () async {
                            final next = await ref.read(asmaulHusnaRepoProvider).toggleMemorized(item.number);
                            setState(() => _memorized = next);
                          },
                          icon: Icon(
                            isMem ? MoeslimIcons.berhasil : Icons.check_circle_outline,
                            color: isMem ? scheme.primary : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    final q = buildAsmaulHusnaQuizQuestion(_quizIndex);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Skor Latihan: $_score · Soal ke-${_quizIndex + 1}',
                  key: const Key('asmaul-quiz-score'),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  q.target.arabic,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 40, color: scheme.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Apakah arti dari "${q.target.latin}" (#${q.target.number})?',
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final opt in q.options)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              key: Key('asmaul-quiz-opt-${opt.number}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
              ),
              onPressed: _selectedOptionNumber != null
                  ? null
                  : () => setState(() {
                        _selectedOptionNumber = opt.number;
                        if (opt.number == q.target.number) _score++;
                      }),
              child: Row(
                children: [
                  Expanded(child: Text(opt.meaning, style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (_selectedOptionNumber != null && opt.number == q.target.number)
                    Icon(MoeslimIcons.berhasil, color: scheme.primary),
                ],
              ),
            ),
          ),
        if (_selectedOptionNumber != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '${q.target.latin} (${q.target.meaning}): ${q.target.explanation}',
                style: t.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('asmaul-quiz-next'),
            onPressed: () => setState(() {
              _quizIndex = (_quizIndex + 11) % asmaulHusnaCatalog.length;
              _selectedOptionNumber = null;
            }),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Soal Berikutnya'),
          ),
        ],
      ],
    );
  }
}
