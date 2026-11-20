import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import 'dashboard_page.dart';
import 'masjid_api.dart';
import 'session.dart';

final transactionsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).transactions(id),
);

class TransactionsPage extends ConsumerWidget {
  final String mosqueId;
  final bool canWrite;
  const TransactionsPage({super.key, required this.mosqueId, required this.canWrite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider(mosqueId));
    return Scaffold(
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              key: const Key('add-transaction'),
              icon: const Icon(Icons.add),
              label: const Text('Catat'),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => TransactionFormPage(mosqueId: mosqueId))),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(transactionsProvider(mosqueId).future),
        child: txs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [Padding(padding: const EdgeInsets.all(24), child: Text('$e'))],
          ),
          data: (list) => list.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Belum ada transaksi')),
                    ),
                  ],
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = list[i];
                    final flow = t['flow'] as String;
                    final color = switch (flow) {
                      'in' => Colors.green.shade700,
                      'out' => Colors.red.shade700,
                      _ => Colors.blueGrey,
                    };
                    final sign = switch (flow) {
                      'in' => '+',
                      'out' => '−',
                      _ => '⇄',
                    };
                    return ListTile(
                      title: Text(t['description'] as String),
                      subtitle: Text(
                        '${t['date']} • ${(t['fund'] as Map?)?['name'] ?? ''} • ${t['reference_no']}'
                        '${t['reversal_of_id'] != null ? ' • pembatalan' : ''}',
                      ),
                      trailing: Text(
                        '$sign ${rupiah(t['amount'] as num)}',
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class TransactionFormPage extends ConsumerStatefulWidget {
  final String mosqueId;
  const TransactionFormPage({super.key, required this.mosqueId});

  @override
  ConsumerState<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  // Satu kunci per formulir: kirim ulang (retry) tidak membuat transaksi ganda.
  final _idempotencyKey = MasjidApi.newIdempotencyKey();
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  Map<String, dynamic>? _setup;
  String _flow = 'in';
  int? _fund, _account, _toAccount, _category;
  DateTime _date = DateTime.now();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(masjidApiProvider).financeSetup(widget.mosqueId).then((s) {
      if (!mounted) return;
      setState(() {
        _setup = s;
        _fund = ((s['funds'] as List).first as Map)['id'] as int;
        _account = ((s['accounts'] as List).first as Map)['id'] as int;
      });
    }, onError: (e) => setState(() => _error = '$e'));
  }

  List<Map> _list(String k) => ((_setup?[k] as List?) ?? const []).cast<Map>();

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(masjidApiProvider).createTransaction(widget.mosqueId, {
        'flow': _flow,
        'amount': int.tryParse(_amount.text.replaceAll('.', '')) ?? 0,
        'fund_id': _fund,
        'cash_account_id': _account,
        if (_flow == 'transfer') 'to_cash_account_id': _toAccount,
        if (_flow != 'transfer' && _category != null) 'category_id': _category,
        'date': '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        'description': _desc.text.trim(),
      }, idempotencyKey: _idempotencyKey);
      ref.invalidate(transactionsProvider(widget.mosqueId));
      ref.invalidate(dashboardProvider(widget.mosqueId));
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = _list('categories').where((c) => c['flow'] == _flow).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Transaksi')),
      body: _setup == null && _error == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'in', label: Text('Masuk')),
                    ButtonSegment(value: 'out', label: Text('Keluar')),
                    ButtonSegment(value: 'transfer', label: Text('Transfer')),
                  ],
                  selected: {_flow},
                  onSelectionChanged: (v) => setState(() {
                    _flow = v.first;
                    _category = null;
                  }),
                ),
                TextField(
                  key: const Key('amount'),
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _fund,
                  decoration: const InputDecoration(labelText: 'Dana'),
                  items: [
                    for (final f in _list('funds'))
                      DropdownMenuItem(
                        value: f['id'] as int,
                        child: Text('${f['name']}${f['restricted'] == true ? ' (terikat)' : ''}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _fund = v),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _account,
                  decoration: InputDecoration(labelText: _flow == 'transfer' ? 'Dari akun' : 'Akun kas'),
                  items: [
                    for (final a in _list('accounts'))
                      DropdownMenuItem(value: a['id'] as int, child: Text(a['name'] as String)),
                  ],
                  onChanged: (v) => setState(() => _account = v),
                ),
                if (_flow == 'transfer')
                  DropdownButtonFormField<int>(
                    initialValue: _toAccount,
                    decoration: const InputDecoration(labelText: 'Ke akun'),
                    items: [
                      for (final a in _list('accounts'))
                        DropdownMenuItem(value: a['id'] as int, child: Text(a['name'] as String)),
                    ],
                    onChanged: (v) => setState(() => _toAccount = v),
                  )
                else
                  DropdownButtonFormField<int>(
                    key: ValueKey(_flow),
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: [
                      for (final c in cats) DropdownMenuItem(value: c['id'] as int, child: Text(c['name'] as String)),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tanggal: ${shortDate(_date)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: _date,
                    );
                    if (d != null) setState(() => _date = d);
                  },
                ),
                TextField(
                  key: const Key('description'),
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: 16),
                FilledButton(key: const Key('save'), onPressed: _busy ? null : _save, child: const Text('Simpan')),
                const SizedBox(height: 8),
                const Text(
                  'Transaksi tidak dapat diubah atau dihapus. Kesalahan dikoreksi dengan entri pembatalan.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
    );
  }
}
