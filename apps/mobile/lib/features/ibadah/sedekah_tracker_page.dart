import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class SedekahTrackerPage extends ConsumerStatefulWidget {
  const SedekahTrackerPage({super.key});

  @override
  ConsumerState<SedekahTrackerPage> createState() => _SedekahTrackerPageState();
}

class _SedekahTrackerPageState extends ConsumerState<SedekahTrackerPage> {
  final _amountCtrl = TextEditingController(text: '25000');
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
    _noteCtrl.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _entries.fold<int>(0, (s, e) => s + e.amountRupiah);
    final ratio = _monthlyTarget <= 0 ? 1.0 : (totalAmount / _monthlyTarget).clamp(0.0, 1.0);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pelacak Sedekah & Kebaikan'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ArchHeader(
                  child: Column(
                    children: [
                      Text('Total Sedekah Tercatat', style: t.bodyMedium),
                      Text(
                        rupiah(totalAmount),
                        key: const Key('sedekah-total-amount'),
                        style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text('Target Bulanan: ${rupiah(_monthlyTarget)} (${_entries.length} kali amal)'),
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
                        Text('Catat Sedekah / Amal Kebaikan Hari Ini', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final cat in SedekahCategory.values)
                              ChoiceChip(
                                key: Key('sedekah-cat-${cat.name}'),
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                label: Text(cat.label),
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
                          decoration: const InputDecoration(
                            labelText: 'Nominal Sedekah (Rp, isi 0 bila non-materi)',
                            prefixText: 'Rp ',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          key: const Key('sedekah-note-field'),
                          controller: _noteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Catatan Kebaikan / Niat (Opsional, privat di perangkat)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const Key('sedekah-add-btn'),
                          onPressed: _addSedekah,
                          icon: const Icon(MoeslimIcons.donasi),
                          label: const Text('Simpan Catatan Sedekah'),
                        ),
                      ],
                    ),
                  ),
                ),
                SectionHeader('Riwayat Sedekah Privat (${_entries.length})'),
                if (_entries.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada catatan sedekah. Semua catatan disimpan lokal di perangkat tanpa akun.'),
                    ),
                  )
                else
                  for (final e in _entries)
                    Card(
                      child: ListTile(
                        leading: Icon(MoeslimIcons.donasi, color: scheme.primary),
                        title: Text(
                          '${e.category.label} · ${rupiah(e.amountRupiah)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          e.note.isEmpty ? e.dateKey : '${e.dateKey} · ${e.note}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus catatan',
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
