import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class SedekahTrackerPage extends ConsumerStatefulWidget {
  const SedekahTrackerPage({super.key});

  @override
  ConsumerState<SedekahTrackerPage> createState() => _SedekahTrackerPageState();
}

class _SedekahTrackerPageState extends ConsumerState<SedekahTrackerPage> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  SedekahCategory _selectedCategory = SedekahCategory.sedekahSubuh;
  List<SedekahEntry> _entries = const [];
  int _monthlyTarget = 500000;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(sedekahRepoProvider);
    final entries = await repo.allEntries();
    final target = await repo.monthlyTargetRupiah();
    if (mounted) {
      setState(() {
        _entries = entries;
        _monthlyTarget = target;
        _loading = false;
      });
    }
  }

  Future<void> _addSedekah() async {
    final amount = int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    await ref.read(sedekahRepoProvider).addEntry(
          date: DateTime.now(),
          category: _selectedCategory,
          amountRupiah: amount,
          note: _noteCtrl.text,
        );
    _amountCtrl.clear();
    _noteCtrl.clear();
    await _load();
  }

  String _categoryLabel(BuildContext context, SedekahCategory cat) => switch (cat) {
        SedekahCategory.sedekahSubuh => context.tr(cat.label, 'Fajr Charity'),
        SedekahCategory.infaqJumatMasjid => context.tr(cat.label, 'Friday & Mosque Infaq'),
        SedekahCategory.santunanYatimDhuafa => context.tr(cat.label, 'Orphans & Needy Aid'),
        SedekahCategory.wakafAmalJariyah => context.tr(cat.label, 'Waqf & Ongoing Charity'),
        SedekahCategory.kebaikanNonMateri => context.tr(cat.label, 'Non-Material Charity & Help'),
      };

  @override
  Widget build(BuildContext context) {
    final totalAmount = _entries.fold<int>(0, (s, e) => s + e.amountRupiah);
    final ratio = _monthlyTarget <= 0 ? 1.0 : (totalAmount / _monthlyTarget).clamp(0.0, 1.0);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Pelacak Sedekah & Kebaikan', 'Charity & Good Deeds Tracker')), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ArchHeader(
                  child: Column(
                    children: [
                      Text(context.tr('Total Sedekah Tercatat', 'Total Recorded Charity'), style: t.bodyMedium),
                      Text(
                        rupiah(totalAmount),
                        key: const Key('sedekah-total-amount'),
                        style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr(
                          'Target Bulanan: ${rupiah(_monthlyTarget)} (${_entries.length} kali amal)',
                          'Monthly Target: ${rupiah(_monthlyTarget)} (${_entries.length} deeds)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('Catat Sedekah / Amal Kebaikan Hari Ini', 'Log Today\'s Charity / Good Deed'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final cat in SedekahCategory.values)
                              ChoiceChip(
                                key: Key('sedekah-cat-${cat.name}'),
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                label: Text(_categoryLabel(context, cat)),
                                selected: _selectedCategory == cat,
                                onSelected: (_) => setState(() => _selectedCategory = cat),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          key: const Key('sedekah-amount-field'),
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.tr(
                              'Nominal Sedekah (Rp, kosongkan bila non-materi)',
                              'Charity Amount (Rp, leave blank if non-material)',
                            ),
                            hintText: context.tr('Contoh: 25000', 'Example: 25000'),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixText: 'Rp ',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          key: const Key('sedekah-note-field'),
                          controller: _noteCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr(
                              'Catatan Kebaikan / Niat (Opsional, privat di perangkat)',
                              'Good Deed Note / Intention (Optional, stored privately)',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const Key('sedekah-add-btn'),
                          onPressed: _addSedekah,
                          icon: const Icon(MoeslimIcons.donasi),
                          label: Text(context.tr('Simpan Catatan Sedekah', 'Save Charity Log')),
                        ),
                      ],
                    ),
                  ),
                ),
                SectionHeader(
                  context.tr(
                    'Riwayat Sedekah Privat (${_entries.length})',
                    'Private Charity History (${_entries.length})',
                  ),
                ),
                if (_entries.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        context.tr(
                          'Belum ada catatan sedekah. Semua catatan disimpan lokal di perangkat tanpa akun.',
                          'No charity records yet. All entries are saved locally on your device without an account.',
                        ),
                      ),
                    ),
                  )
                else
                  for (final e in _entries)
                    Card(
                      child: ListTile(
                        leading: Icon(MoeslimIcons.donasi, color: scheme.primary),
                        title: Text(
                          '${_categoryLabel(context, e.category)} · ${rupiah(e.amountRupiah)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          e.note.isEmpty ? e.dateKey : '${e.dateKey} · ${e.note}',
                        ),
                        trailing: IconButton(
                          tooltip: context.tr('Hapus catatan', 'Delete entry'),
                          onPressed: () async {
                            await ref.read(sedekahRepoProvider).deleteEntry(e.id);
                            await _load();
                          },
                          icon: const Icon(MoeslimIcons.hapus),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}
