import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const conditionLabels = {
  'baik': 'Baik',
  'rusak_ringan': 'Rusak ringan',
  'rusak_berat': 'Rusak berat',
  'hilang': 'Hilang',
};

StatusBadge conditionBadge(String? c) => switch (c) {
  'baik' => const StatusBadge('Baik', icon: MoeslimIcons.berhasil, color: MosqueColors.income),
  'rusak_ringan' => const StatusBadge('Rusak ringan', icon: Icons.build_outlined, color: MosqueColors.warning),
  'rusak_berat' => const StatusBadge('Rusak berat', icon: MoeslimIcons.peringatan, color: MosqueColors.expense),
  _ => const StatusBadge('Hilang', icon: MoeslimIcons.bantuan, color: Color(0xFF5B5F5E)),
};

/// Inventaris Masjid: pencarian, filter kondisi (dengan jumlah), daftar, detail + riwayat perawatan.
class InventoryPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const InventoryPage({super.key, required this.ctx});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  String _q = '';
  String? _condition;

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final items = ref.watch(inventoryProvider(ctx.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Inventaris Masjid'), centerTitle: true),
      floatingActionButton: ctx.can('inventory.write')
          ? FloatingActionButton.extended(
              heroTag: null,
              key: const Key('add-inventory'),
              icon: const Icon(MoeslimIcons.tambah),
              label: const Text('Tambah Barang'),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _InventoryForm(ctx: ctx),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(inventoryProvider(ctx.id).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            TextField(
              key: const Key('inventory-search'),
              decoration: const InputDecoration(
                prefixIcon: Icon(MoeslimIcons.pencarian),
                hintText: 'Cari inventaris (nama atau kode)',
              ),
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 10),
            AsyncBody(
              value: items,
              onRetry: () => ref.invalidate(inventoryProvider(ctx.id)),
              data: (list) {
                int count(String? c) => c == null ? list.length : list.where((i) => i['condition'] == c).length;
                final shown = list.where((i) {
                  final hay = '${i['name']} ${i['code'] ?? ''}'.toLowerCase();
                  return (_condition == null || i['condition'] == _condition) && (_q.isEmpty || hay.contains(_q));
                }).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in [null, ...conditionLabels.keys])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                key: Key('cond-${c ?? 'all'}'),
                                label: Text('${c == null ? 'Semua' : conditionLabels[c]} (${count(c)})'),
                                selected: _condition == c,
                                onSelected: (_) => setState(() => _condition = c),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (shown.isEmpty) const EmptyState(MoeslimIcons.inventaris, 'Belum ada barang'),
                    for (final i in shown)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          key: Key('item-${i['id']}'),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: BrandColors.emerald.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(MoeslimIcons.inventaris, color: BrandColors.emerald),
                          ),
                          title: Text('${i['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text([?i['code'] as String?, ?i['location'] as String?].join(' • ')),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              conditionBadge(i['condition'] as String?),
                              const SizedBox(height: 4),
                              Text('${i['quantity']} unit', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InventoryDetailPage(ctx: ctx, itemId: i['id'] as int),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final _itemProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, int)>(
  (ref, k) => ref.watch(masjidApiProvider).inventoryItem(k.$1, k.$2),
);

class InventoryDetailPage extends ConsumerWidget {
  final MosqueCtx ctx;
  final int itemId;
  const InventoryDetailPage({super.key, required this.ctx, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(_itemProvider((ctx.id, itemId)));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Inventaris'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AsyncBody(
            value: item,
            onRetry: () => ref.invalidate(_itemProvider((ctx.id, itemId))),
            data: (i) {
              final logs = (i['maintenance'] as List? ?? const []).cast<Map>();
              Widget row(IconData icon, String k, String v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: BrandColors.emerald),
                    const SizedBox(width: 10),
                    SizedBox(width: 130, child: Text(k)),
                    Expanded(
                      child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OrnamentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i['name']}', style: Theme.of(context).textTheme.titleLarge),
                        if (i['code'] != null) Text('${i['code']}'),
                        const SizedBox(height: 6),
                        conditionBadge(i['condition'] as String?),
                        const Divider(height: 24),
                        row(Icons.numbers, 'Jumlah', '${i['quantity']} unit'),
                        row(MoeslimIcons.lokasi, 'Lokasi', '${i['location'] ?? '-'}'),
                        row(MoeslimIcons.profil, 'Penanggung jawab', '${i['responsible'] ?? '-'}'),
                        row(
                          Icons.build_outlined,
                          'Perawatan terakhir',
                          logs.isEmpty ? '-' : shortDate(DateTime.parse(logs.first['date'] as String)),
                        ),
                        if (i['notes'] != null) row(MoeslimIcons.keterangan, 'Catatan', '${i['notes']}'),
                      ],
                    ),
                  ),
                  SectionHeader(
                    'Riwayat Perawatan',
                    actionLabel: ctx.can('inventory.write') ? 'Catat' : null,
                    onAction: () => _addMaintenance(context, ref),
                  ),
                  if (logs.isEmpty) const EmptyState(Icons.build_outlined, 'Belum ada catatan perawatan'),
                  for (final l in logs)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.build_outlined, color: BrandColors.emerald),
                        title: Text('${l['notes']}'),
                        subtitle: Text(shortDate(DateTime.parse(l['date'] as String))),
                        trailing: l['cost'] == null ? null : Text(rupiah(l['cost'] as num)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addMaintenance(BuildContext context, WidgetRef ref) async {
    final notes = TextEditingController();
    final cost = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Catat Perawatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('maintenance-notes'),
              controller: notes,
              decoration: const InputDecoration(labelText: 'Keterangan'),
            ),
            TextField(
              controller: cost,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Biaya (opsional)', prefixText: 'Rp '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(masjidApiProvider).addMaintenance(ctx.id, itemId, {
        'date': isoDate(DateTime.now()),
        'notes': notes.text.trim(),
        if (cost.text.isNotEmpty) 'cost': int.parse(cost.text),
      });
      ref.invalidate(_itemProvider((ctx.id, itemId)));
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message);
    }
  }
}

class _InventoryForm extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const _InventoryForm({required this.ctx});

  @override
  ConsumerState<_InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends ConsumerState<_InventoryForm> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _location = TextEditingController();
  final _responsible = TextEditingController();
  String _condition = 'baik';
  String? _error;

  @override
  Widget build(BuildContext context) {
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tambah Barang', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              key: const Key('inventory-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nama barang *'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    decoration: const InputDecoration(labelText: 'Kode', hintText: 'INV-001'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Jumlah *'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Kondisi'),
              items: [for (final c in conditionLabels.entries) DropdownMenuItem(value: c.key, child: Text(c.value))],
              onChanged: (v) => setState(() => _condition = v ?? _condition),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _responsible,
              decoration: const InputDecoration(labelText: 'Penanggung jawab'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-inventory'),
              onPressed: () async {
                try {
                  await ref.read(masjidApiProvider).createInventory(widget.ctx.id, {
                    'name': _name.text.trim(),
                    'code': opt(_code),
                    'quantity': int.tryParse(_qty.text) ?? 0,
                    'condition': _condition,
                    'location': opt(_location),
                    'responsible': opt(_responsible),
                  });
                  ref.invalidate(inventoryProvider(widget.ctx.id));
                  if (context.mounted) Navigator.pop(context);
                } on ApiException catch (e) {
                  setState(
                    () => _error =
                        e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message,
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
