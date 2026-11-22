import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class FamilyEducationPage extends ConsumerStatefulWidget {
  final int initialTab;
  const FamilyEducationPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<FamilyEducationPage> createState() => _FamilyEducationPageState();
}

class _FamilyEducationPageState extends ConsumerState<FamilyEducationPage> {
  late int _tab;

  // 41. Baby names state
  final _nameSearchCtrl = TextEditingController();
  String _nameQuery = '';
  String _genderFilter = 'Semua';
  Set<String> _favNames = {};
  IslamicBabyName _comboFirst = islamicBabyNamesCatalog.first;
  IslamicBabyName _comboSecond = islamicBabyNamesCatalog[4];

  // 43. Daily Quiz state
  int _quizIdx = 0;
  int _quizScore = 0;
  int? _pickedQuizOpt;

  // 44. Glossary state
  final _glossarySearchCtrl = TextEditingController();
  String _glossaryQuery = '';

  // 45. Debt Ledger state
  List<DebtLedgerEntry> _debts = const [];
  DebtRecordKind _debtKind = DebtRecordKind.utangSaya;
  final _debtPersonCtrl = TextEditingController();
  final _debtAmountCtrl = TextEditingController(text: '500000');
  final _debtNoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    _load();
  }

  @override
  void dispose() {
    _nameSearchCtrl.dispose();
    _glossarySearchCtrl.dispose();
    _debtPersonCtrl.dispose();
    _debtAmountCtrl.dispose();
    _debtNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final favs = await ref.read(babyNamesRepoProvider).favoriteIds();
    final debts = await ref.read(debtLedgerRepoProvider).allEntries();
    if (mounted) {
      setState(() {
        _favNames = favs;
        _debts = debts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keluarga, Anak & Edukasi'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Nama Bayi', '29 Hijaiyah', 'Kuis Islam', 'Glosarium', 'Utang Piutang'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildBabyNamesTab(context),
              1 => _buildHijaiyahTab(context),
              2 => _buildIslamicQuizTab(context),
              3 => _buildGlossaryTab(context),
              _ => _buildDebtLedgerTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 41. Katalog Nama Bayi Islami + Arti & Tulisan Arab
  Widget _buildBabyNamesTab(BuildContext context) {
    final combined = combineIslamicBabyNames(_comboFirst, _comboSecond);
    final filtered = [
      for (final n in islamicBabyNamesCatalog)
        if ((_genderFilter == 'Semua' || n.gender == _genderFilter) && n.matches(_nameQuery)) n,
    ];
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
                Text('Perangkai Kombinasi Nama Bayi Islami', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<IslamicBabyName>(
                        initialValue: _comboFirst,
                        isDense: true,
                        decoration: const InputDecoration(labelText: 'Nama Depan'),
                        items: [
                          for (final n in islamicBabyNamesCatalog)
                            DropdownMenuItem(value: n, child: Text(n.name)),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _comboFirst = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<IslamicBabyName>(
                        initialValue: _comboSecond,
                        isDense: true,
                        decoration: const InputDecoration(labelText: 'Nama Belakang'),
                        items: [
                          for (final n in islamicBabyNamesCatalog)
                            DropdownMenuItem(value: n, child: Text(n.name)),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _comboSecond = v);
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  combined.fullArabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 28, color: scheme.primary),
                ),
                Text(
                  combined.fullLatin,
                  key: const Key('baby-name-combo-output'),
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('Makna Rangkaian: ${combined.combinedMeaning}', textAlign: TextAlign.center, style: t.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('baby-name-search'),
          controller: _nameSearchCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(MoeslimIcons.pencarian),
            hintText: 'Cari nama atau arti (mis. Muhammad, Aisyah, Cahaya, Terpuji)',
          ),
          onChanged: (v) => setState(() => _nameQuery = v.trim()),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final g in ['Semua', 'Laki-laki', 'Perempuan'])
              ChoiceChip(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(g),
                selected: _genderFilter == g,
                onSelected: (_) => setState(() => _genderFilter = g),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in filtered)
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text('${item.name} (${item.gender})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text(item.arabic, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 22, color: scheme.primary)),
                ],
              ),
              subtitle: Text('${item.theme} · ${item.meaning}'),
              trailing: IconButton(
                tooltip: 'Simpan nama favorit',
                onPressed: () async {
                  final next = await ref.read(babyNamesRepoProvider).toggleFavorite(item.id);
                  setState(() => _favNames = next);
                },
                icon: Icon(
                  _favNames.contains(item.id) ? MoeslimIcons.cinta : Icons.favorite_border,
                  color: _favNames.contains(item.id) ? scheme.primary : null,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 42. Belajar Huruf Hijaiyah & Dasar Membaca Al-Qur'an
  Widget _buildHijaiyahTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hijaiyah29Catalog.length,
      itemBuilder: (context, index) {
        final h = hijaiyah29Catalog[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OctagonNumber(h.order),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${h.name} (Bunyi: ${h.latinSound})', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text('Makhraj: ${h.makhrajNote}', style: t.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      h.isolated,
                      textDirection: TextDirection.rtl,
                      style: quranTextStyle(fontSize: 34, color: scheme.primary),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Text('Bentuk Sambung (Akhir · Tengah · Awal): ${h.connectedForms}', style: t.bodyMedium),
                const SizedBox(height: 4),
                Text('Latihan Harakat: ${h.harakatSample}', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 43. Kuis Wawasan Islam Harian (Offline)
  Widget _buildIslamicQuizTab(BuildContext context) {
    final q = islamicKnowledgeQuizBank[_quizIdx % islamicKnowledgeQuizBank.length];
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
                  'Kategori: ${q.category} · Skor: $_quizScore / ${islamicKnowledgeQuizBank.length}',
                  key: const Key('islamic-quiz-score'),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              key: Key('islamic-quiz-opt-$i'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
              ),
              onPressed: _pickedQuizOpt != null
                  ? null
                  : () => setState(() {
                        _pickedQuizOpt = i;
                        if (i == q.correctIndex) _quizScore++;
                      }),
              child: Row(
                children: [
                  Expanded(child: Text(q.options[i], style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (_pickedQuizOpt != null && i == q.correctIndex)
                    Icon(MoeslimIcons.berhasil, color: scheme.primary),
                ],
              ),
            ),
          ),
        if (_pickedQuizOpt != null) ...[
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(q.explanation, style: t.bodyMedium),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('islamic-quiz-next'),
            onPressed: () => setState(() {
              _quizIdx = (_quizIdx + 1) % islamicKnowledgeQuizBank.length;
              _pickedQuizOpt = null;
            }),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Pertanyaan Berikutnya'),
          ),
        ],
      ],
    );
  }

  // 44. Glosarium / Ensiklopedia Mini Istilah Islam
  Widget _buildGlossaryTab(BuildContext context) {
    final filtered = [
      for (final term in islamicGlossaryCatalog)
        if (term.matches(_glossaryQuery)) term,
    ];
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            key: const Key('glossary-search'),
            controller: _glossarySearchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(MoeslimIcons.pencarian),
              hintText: 'Cari istilah Islam (mis. Tuma\'ninah, Nisab, Mahram, Gharar, Tabayyun)',
            ),
            onChanged: (v) => setState(() => _glossaryQuery = v.trim()),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.term, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(item.category, style: t.labelMedium?.copyWith(color: scheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.definition, style: t.bodyMedium),
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

  // 45. Pencatat Utang-Piutang Pribadi (Sesuai QS. Al-Baqarah: 282)
  Widget _buildDebtLedgerTab(BuildContext context) {
    final totalPayable = _debts
        .where((d) => d.kind == DebtRecordKind.utangSaya)
        .fold<int>(0, (s, d) => s + d.remainingAmount);
    final totalReceivable = _debts
        .where((d) => d.kind == DebtRecordKind.piutangSaya)
        .fold<int>(0, (s, d) => s + d.remainingAmount);
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
                  'QS. Al-Baqarah: 282 (Ayat Mudayanah): "Wahai orang-orang yang beriman, apabila kamu melakukan utang piutang untuk waktu yang ditentukan, hendaklah kamu menuliskannya."',
                  style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
                const Divider(height: 18),
                Text(
                  'Sisa Utang Saya: ${rupiah(totalPayable)} · Sisa Piutang Saya: ${rupiah(totalReceivable)}',
                  key: const Key('debt-ledger-summary'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<DebtRecordKind>(
                  segments: [
                    for (final k in DebtRecordKind.values)
                      ButtonSegment(value: k, label: Text(k.label)),
                  ],
                  selected: {_debtKind},
                  onSelectionChanged: (v) => setState(() => _debtKind = v.first),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('debt-person-field'),
                  controller: _debtPersonCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Pihak Terkait (Pemberi / Penerima)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('debt-amount-field'),
                  controller: _debtAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixText: 'Rp '),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _debtNoteCtrl,
                  decoration: const InputDecoration(labelText: 'Keterangan / Akad (Opsional)'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('debt-add-btn'),
                  onPressed: () async {
                    if (_debtPersonCtrl.text.trim().isEmpty) return;
                    final amount = int.tryParse(_debtAmountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    final next = await ref.read(debtLedgerRepoProvider).addEntry(
                          kind: _debtKind,
                          personName: _debtPersonCtrl.text,
                          totalAmount: amount,
                          dueDate: DateTime.now().add(const Duration(days: 30)),
                          note: _debtNoteCtrl.text,
                        );
                    _debtPersonCtrl.clear();
                    _debtNoteCtrl.clear();
                    setState(() => _debts = next);
                  },
                  icon: const Icon(MoeslimIcons.tambahLingkar),
                  label: const Text('Catat Utang / Piutang'),
                ),
              ],
            ),
          ),
        ),
        SectionHeader('Buku Catatan Utang-Piutang (${_debts.length})'),
        for (final d in _debts)
          Card(
            child: ListTile(
              leading: Icon(
                d.isPaidOff ? MoeslimIcons.berhasil : MoeslimIcons.anggaran,
                color: d.isPaidOff ? scheme.primary : BrandColors.goldText,
              ),
              title: Text(
                '${d.personName} · ${rupiah(d.totalAmount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  decoration: d.isPaidOff ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '${d.kind.label} · Jatuh tempo: ${d.dueDateKey}${d.isPaidOff ? ' (LUNAS)' : ' (Sisa: ${rupiah(d.remainingAmount)})'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!d.isPaidOff)
                    TextButton(
                      key: Key('debt-payoff-${d.id}'),
                      onPressed: () async {
                        final next = await ref.read(debtLedgerRepoProvider).markPaidOff(d.id);
                        setState(() => _debts = next);
                      },
                      child: const Text('Tandai Lunas'),
                    ),
                  IconButton(
                    tooltip: 'Hapus catatan',
                    onPressed: () async {
                      final next = await ref.read(debtLedgerRepoProvider).deleteEntry(d.id);
                      setState(() => _debts = next);
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
}
