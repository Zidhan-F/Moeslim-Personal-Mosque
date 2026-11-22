import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'finance_pro_pages.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
String monthLabel(DateTime m) => '${_monthNames[m.month - 1]} ${m.year}';

/// Palet kategori untuk donut/legenda (emerald → emas → netral); label & persentase selalu tertulis.
const categoryPalette = [
  BrandColors.emerald,
  BrandColors.gold,
  Color(0xFF5FB89A),
  Color(0xFFB98A2E),
  Color(0xFF8FA39C),
  Color(0xFF2D5F55),
];

/// Pemilih bulan sederhana (12 bulan terakhir).
class MonthPicker extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const MonthPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [for (var i = 0; i < 12; i++) DateTime(now.year, now.month - i)];
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<DateTime>(
          key: const Key('month-picker'),
          value: months.firstWhere((m) => m.year == value.year && m.month == value.month, orElse: () => months.first),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            for (final m in months)
              DropdownMenuItem(
                value: m,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(MoeslimIcons.kalender, size: 18),
                    const SizedBox(width: 8),
                    Text(monthLabel(m)),
                  ],
                ),
              ),
          ],
          onChanged: (m) => m == null ? null : onChanged(m),
        ),
      ),
    );
  }
}

/// Tab Keuangan: saldo (bisa disembunyikan), pemasukan/pengeluaran periode, komposisi kategori, aksi.
class FinanceTab extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const FinanceTab({super.key, required this.ctx});

  @override
  ConsumerState<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends ConsumerState<FinanceTab> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _hidden = false;
  String _flow = 'in';

  void _push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final (from, to) = monthRange(_month);
    final key = (ctx.id, from, to);
    final summary = ref.watch(financeSummaryProvider(key));
    return Scaffold(
      floatingActionButton: ctx.can('finance.write')
          ? FloatingActionButton.extended(
              heroTag: null,
              key: const Key('add-transaction'),
              icon: const Icon(MoeslimIcons.tambah),
              label: const Text('Tambah Transaksi'),
              onPressed: () => _push(TransactionFormPage(mosqueId: ctx.id)),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(financeSummaryProvider(key).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            MosqueBanner(overline: 'Kas Masjid', title: ctx.name, subtitle: ctx.city),
            AsyncBody(
              value: summary,
              onRetry: () => ref.invalidate(financeSummaryProvider(key)),
              data: (s) => _body(context, s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Map<String, dynamic> s) {
    final ctx = widget.ctx;
    final cats = (s['by_category'] as List).cast<Map>().where((c) => c['flow'] == _flow).toList();
    final total = _flow == 'in' ? s['total_in'] as num : s['total_out'] as num;
    String money(num v) => _hidden ? 'Rp •••••••' : rupiah(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(MoeslimIcons.keuangan, color: BrandColors.emerald, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saldo Kas Saat Ini'),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              money(s['balance'] as num),
                              key: const Key('balance'),
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('toggle-balance'),
                      tooltip: _hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                      icon: Icon(_hidden ? MoeslimIcons.kunci : Icons.lock_open_outlined),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FlowBox(
                        icon: MoeslimIcons.arahAtas,
                        label: 'Pemasukan',
                        value: money(s['total_in'] as num),
                        color: MosqueColors.income,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FlowBox(
                        icon: MoeslimIcons.arahBawah,
                        label: 'Pengeluaran',
                        value: money(s['total_out'] as num),
                        color: MosqueColors.expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                key: const Key('open-friday-report'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => _push(FridayReportPage(ctx: ctx)),
                icon: const Icon(MoeslimIcons.laporan),
                label: const Text('Kas Jumat', overflow: TextOverflow.ellipsis),
              ),
            ),
            if (ctx.can('finance.write')) ...[
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  key: const Key('open-box-count'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () => _push(DonationBoxCountPage(ctx: ctx)),
                  icon: const Icon(MoeslimIcons.saldo),
                  label: const Text('Kotak Amal', overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text('Periode Bulan', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            MonthPicker(value: _month, onChanged: (m) => setState(() => _month = m)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Komposisi Arus Kas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                PillTabs(
                  labels: const ['Pemasukan', 'Pengeluaran'],
                  index: _flow == 'in' ? 0 : 1,
                  onChanged: (i) => setState(() => _flow = i == 0 ? 'in' : 'out'),
                ),
                const SizedBox(height: 12),
                if (cats.isEmpty)
                  const EmptyState(
                    MoeslimIcons.grafikPie,
                    'Belum ada transaksi pada periode ini',
                    art: BrandEmptyArt.transaksi,
                  )
                else
                  Row(
                    children: [
                      SizedBox.square(
                        dimension: 140,
                        child: CustomPaint(
                          key: const Key('category-donut'),
                          painter: DonutPainter([
                            for (final c in cats) (c['total'] as num).toDouble(),
                          ], categoryPalette),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: FittedBox(
                                child: Column(
                                  children: [
                                    Text(money(total), style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(
                                      _flow == 'in' ? 'Pemasukan' : 'Pengeluaran',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            for (final (i, c) in cats.indexed)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: categoryPalette[i % categoryPalette.length],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${c['category']}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${total == 0 ? 0 : ((c['total'] as num) / total * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('open-history'),
                  onPressed: () => _push(TransactionHistoryPage(ctx: ctx)),
                  icon: const Icon(MoeslimIcons.laporan),
                  label: const Text('Lihat Detail Transaksi'),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('Saldo per Dana'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final f in (s['funds'] as List).cast<Map>())
                ListTile(
                  dense: true,
                  leading: Icon(
                    f['restricted'] == true ? MoeslimIcons.kunci : MoeslimIcons.saldo,
                    color: BrandColors.emerald,
                  ),
                  title: Text('${f['name']}'),
                  subtitle: f['restricted'] == true ? const Text('Dana terikat') : null,
                  trailing: Text(money(f['balance'] as num), style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            key: const Key('open-report'),
            leading: const Icon(MoeslimIcons.grafikBatang, color: BrandColors.emerald),
            title: const Text('Laporan Keuangan'),
            subtitle: const Text('Grafik bulanan/tahunan & ekspor CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _push(ReportPage(ctx: ctx)),
          ),
        ),
      ],
    );
  }
}

class _FlowBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _FlowBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  DonutPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;
    final stroke = size.shortestSide * .16;
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    var start = -math.pi / 2;
    for (final (i, v) in values.indexed) {
      final sweep = v / total * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        math.max(0, sweep - .02),
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) => old.values != values;
}

/// Tambah Transaksi: Pemasukan / Pengeluaran / Transfer. Satu Idempotency-Key per formulir.
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
  final _donor = TextEditingController();
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
        'date': isoDate(_date),
        'description': _desc.text.trim(),
        if (_flow == 'in' && _donor.text.trim().isNotEmpty) 'donor_name': _donor.text.trim(),
      }, idempotencyKey: _idempotencyKey);
      ref.invalidate(transactionsProvider);
      ref.invalidate(financeSummaryProvider);
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
    const flows = ['in', 'out', 'transfer'];
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi'), centerTitle: true),
      body: _setup == null && _error == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PillTabs(
                  labels: const ['Pemasukan', 'Pengeluaran', 'Transfer'],
                  index: flows.indexOf(_flow),
                  onChanged: (i) => setState(() {
                    _flow = flows[i];
                    _category = null;
                  }),
                ),
                const SizedBox(height: 16),
                if (_flow != 'transfer') ...[
                  DropdownButtonFormField<int>(
                    key: ValueKey('category-$_flow'),
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(MoeslimIcons.kategori)),
                    items: [
                      for (final c in cats) DropdownMenuItem(value: c['id'] as int, child: Text(c['name'] as String)),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  key: const Key('amount'),
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Jumlah *', prefixText: 'Rp  '),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: _date,
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Tanggal *', prefixIcon: Icon(MoeslimIcons.kalender)),
                    child: Text(longDate(_date)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _fund,
                  decoration: const InputDecoration(labelText: 'Dana', prefixIcon: Icon(MoeslimIcons.saldo)),
                  items: [
                    for (final f in _list('funds'))
                      DropdownMenuItem(
                        value: f['id'] as int,
                        child: Text('${f['name']}${f['restricted'] == true ? ' (terikat)' : ''}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _fund = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _account,
                  decoration: InputDecoration(
                    labelText: _flow == 'transfer' ? 'Dari akun' : 'Akun kas',
                    prefixIcon: const Icon(MoeslimIcons.saldo),
                  ),
                  items: [
                    for (final a in _list('accounts'))
                      DropdownMenuItem(value: a['id'] as int, child: Text(a['name'] as String)),
                  ],
                  onChanged: (v) => setState(() => _account = v),
                ),
                if (_flow == 'transfer') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _toAccount,
                    decoration: const InputDecoration(labelText: 'Ke akun', prefixIcon: Icon(Icons.call_received)),
                    items: [
                      for (final a in _list('accounts'))
                        DropdownMenuItem(value: a['id'] as int, child: Text(a['name'] as String)),
                    ],
                    onChanged: (v) => setState(() => _toAccount = v),
                  ),
                ],
                if (_flow == 'in') ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('donor-name'),
                    controller: _donor,
                    decoration: const InputDecoration(
                      labelText: 'Nama donatur (opsional untuk kuitansi)',
                      hintText: 'Kosongkan untuk Hamba Allah',
                      prefixIcon: Icon(MoeslimIcons.profil),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  key: const Key('description'),
                  controller: _desc,
                  maxLength: 200,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan / sumber dana *',
                    alignLabelWithHint: true,
                    hintText: 'Contoh: Infaq Jumat, Hamba Allah',
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                FilledButton.icon(
                  key: const Key('save'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: const StadiumBorder()),
                  onPressed: _busy ? null : _save,
                  icon: const Icon(MoeslimIcons.tambahLingkar),
                  label: const Text('Simpan Transaksi'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Transaksi tidak dapat diubah atau dihapus. Kesalahan dikoreksi dengan entri pembatalan.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

/// Riwayat Transaksi: pencarian, filter arus, total, dikelompokkan per bulan; detail + pembatalan.
class TransactionHistoryPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const TransactionHistoryPage({super.key, required this.ctx});

  @override
  ConsumerState<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends ConsumerState<TransactionHistoryPage> {
  String? _flow;
  String? _q;
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final key = (widget.ctx.id, _flow, _q);
    final txs = ref.watch(transactionsProvider(key));
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(transactionsProvider(key).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            TextField(
              key: const Key('tx-search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(MoeslimIcons.pencarian),
                hintText: 'Cari keterangan transaksi',
              ),
              onSubmitted: (v) => setState(() => _q = v.trim().isEmpty ? null : v.trim()),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final (v, l) in const [
                  (null, 'Semua'),
                  ('in', 'Pemasukan'),
                  ('out', 'Pengeluaran'),
                  ('transfer', 'Transfer'),
                ])
                  ChoiceChip(
                    key: Key('flow-${v ?? 'all'}'),
                    label: Text(l),
                    selected: _flow == v,
                    onSelected: (_) => setState(() => _flow = v),
                  ),
              ],
            ),
            AsyncBody(
              value: txs,
              onRetry: () => ref.invalidate(transactionsProvider(key)),
              data: (list) => _list(context, list),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const EmptyState(
        MoeslimIcons.laporan,
        'Belum ada transaksi',
        art: BrandEmptyArt.transaksi,
        message: 'Mulai catat pemasukan atau pengeluaran kas.',
      );
    }
    final reversed = {
      for (final t in list)
        if (t['reversal_of_id'] != null) t['reversal_of_id'],
    };
    num sum(String f) => list.where((t) => t['flow'] == f).fold<num>(0, (a, t) => a + (t['amount'] as num));
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final t in list) {
      final d = DateTime.parse(t['date'] as String);
      groups.putIfAbsent(monthLabel(DateTime(d.year, d.month)), () => []).add(t);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FlowBox(
                icon: MoeslimIcons.arahAtas,
                label: 'Total Pemasukan',
                value: rupiah(sum('in')),
                color: MosqueColors.income,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FlowBox(
                icon: MoeslimIcons.arahBawah,
                label: 'Total Pengeluaran',
                value: rupiah(sum('out')),
                color: MosqueColors.expense,
              ),
            ),
          ],
        ),
        for (final g in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
            child: Row(
              children: [
                Expanded(child: Text(g.key, style: Theme.of(context).textTheme.titleMedium)),
                Text('${g.value.length} transaksi', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final t in g.value)
                  TransactionTile(
                    tx: t,
                    cancelled: reversed.contains(t['id']),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => _TxDetailSheet(ctx: widget.ctx, tx: t, cancelled: reversed.contains(t['id'])),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final bool cancelled;
  final VoidCallback? onTap;
  const TransactionTile({super.key, required this.tx, this.cancelled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final flow = tx['flow'] as String;
    final isReversal = tx['reversal_of_id'] != null;
    final color = switch (flow) {
      'in' => MosqueColors.income,
      'out' => MosqueColors.expense,
      _ => MosqueColors.info,
    };
    final sign = switch (flow) {
      'in' => '+ ',
      'out' => '− ',
      _ => '',
    };
    return ListTile(
      key: Key('tx-${tx['id']}'),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .1),
        child: Icon(
          switch (flow) {
            'in' => Icons.south_west,
            'out' => Icons.north_east,
            _ => MoeslimIcons.sinkronisasi,
          },
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        (tx['category'] as Map?)?['name'] as String? ?? tx['description'] as String,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${tx['description']}\n${shortDate(DateTime.parse(tx['date'] as String))} • ${(tx['fund'] as Map?)?['name'] ?? ''}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign${rupiah(tx['amount'] as num)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (cancelled)
            const StatusBadge('Dibatalkan', icon: Icons.block, color: MosqueColors.expense)
          else if (isReversal)
            const StatusBadge('Pembatalan', icon: MoeslimIcons.ulang, color: MosqueColors.warning)
          else
            const StatusBadge('Tercatat', icon: MoeslimIcons.check, color: MosqueColors.income),
        ],
      ),
    );
  }
}

class _TxDetailSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final Map<String, dynamic> tx;
  final bool cancelled;
  const _TxDetailSheet({required this.ctx, required this.tx, required this.cancelled});

  @override
  ConsumerState<_TxDetailSheet> createState() => _TxDetailSheetState();
}

class _TxDetailSheetState extends ConsumerState<_TxDetailSheet> {
  final _reason = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final t = widget.tx;
    final canReverse = widget.ctx.can('finance.write') && !widget.cancelled && t['reversal_of_id'] == null;
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(k)),
          Expanded(
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Detail Transaksi', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          row('No. referensi', '${t['reference_no']}'),
          row('Jumlah', rupiah(t['amount'] as num)),
          row('Tanggal', longDate(DateTime.parse(t['date'] as String))),
          row('Dana', '${(t['fund'] as Map?)?['name'] ?? '-'}'),
          row(
            'Akun',
            '${(t['account'] as Map?)?['name'] ?? '-'}${t['to_account'] != null ? ' → ${(t['to_account'] as Map)['name']}' : ''}',
          ),
          if (t['donor_name'] != null) row('Donatur', '${t['donor_name']}'),
          row('Keterangan', '${t['description']}'),
          if (t['flow'] == 'in') ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              key: const Key('open-receipt'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('Kuitansi Digital QR'),
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => ReceiptSheet(ctx: widget.ctx, txId: t['id'] as int),
                );
              },
            ),
          ],
          if (canReverse) ...[
            const Divider(height: 24),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(labelText: 'Alasan pembatalan'),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('reverse-tx'),
              style: OutlinedButton.styleFrom(foregroundColor: MosqueColors.expense),
              icon: const Icon(MoeslimIcons.ulang),
              label: const Text('Batalkan dengan entri pembalik'),
              onPressed: () async {
                try {
                  await ref
                      .read(masjidApiProvider)
                      .reverseTransaction(widget.ctx.id, t['id'] as int, _reason.text.trim());
                  ref.invalidate(transactionsProvider);
                  ref.invalidate(financeSummaryProvider);
                  ref.invalidate(dashboardProvider(widget.ctx.id));
                  if (context.mounted) Navigator.pop(context);
                } on ApiException catch (e) {
                  setState(
                    () => _error =
                        e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message,
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Laporan Keuangan: Bulanan (ringkasan bulan) / Tahunan (12 bulan), grafik batang, ekspor CSV.
class ReportPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const ReportPage({super.key, required this.ctx});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  int _tab = 0;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  int _year = DateTime.now().year;
  bool _exporting = false;

  (String, String) get _range =>
      _tab == 0 ? monthRange(_month) : (isoDate(DateTime(_year)), isoDate(DateTime(_year, 12, 31)));

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final (from, to) = _range;
      final csv = await ref.read(masjidApiProvider).exportCsv(widget.ctx.id, from: from, to: to);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/laporan-kas-$from-$to.csv');
      await file.writeAsString(csv);
      if (mounted) showSnack(context, 'Laporan tersimpan: ${file.path}');
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final (from, to) = _range;
    final summary = ref.watch(financeSummaryProvider((ctx.id, from, to)));
    final year = _tab == 0 ? _month.year : _year;
    final monthly = ref.watch(monthlyReportProvider((ctx.id, year)));
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PillTabs(labels: const ['Bulanan', 'Tahunan'], index: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(_tab == 0 ? 'Periode Bulan' : 'Tahun', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (_tab == 0)
                MonthPicker(value: _month, onChanged: (m) => setState(() => _month = m))
              else
                SegmentedButton<int>(
                  segments: [
                    for (final y in [DateTime.now().year - 1, DateTime.now().year])
                      ButtonSegment(value: y, label: Text('$y')),
                  ],
                  selected: {_year},
                  onSelectionChanged: (v) => setState(() => _year = v.first),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arus Kas $year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      _Legend(color: BrandColors.emerald, label: 'Pemasukan'),
                      SizedBox(width: 16),
                      _Legend(color: BrandColors.gold, label: 'Pengeluaran'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AsyncBody(
                    value: monthly,
                    onRetry: () => ref.invalidate(monthlyReportProvider((ctx.id, year))),
                    data: (m) => SizedBox(
                      height: 180,
                      child: CustomPaint(
                        key: const Key('monthly-chart'),
                        size: Size.infinite,
                        painter: BarChartPainter(
                          (m['months'] as List)
                              .cast<Map>()
                              .map((e) => ((e['in'] as num).toDouble(), (e['out'] as num).toDouble()))
                              .toList(),
                          highlight: _tab == 0 ? _month.month - 1 : null,
                          labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AsyncBody(
            value: summary,
            onRetry: () => ref.invalidate(financeSummaryProvider((ctx.id, from, to))),
            data: (s) => Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ringkasan ${_tab == 0 ? monthLabel(_month) : '$_year'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _SumRow(
                      MoeslimIcons.arahAtas,
                      'Total Pemasukan',
                      rupiah(s['total_in'] as num),
                      MosqueColors.income,
                    ),
                    _SumRow(
                      MoeslimIcons.arahBawah,
                      'Total Pengeluaran',
                      rupiah(s['total_out'] as num),
                      MosqueColors.expense,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: BrandColors.emerald.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _SumRow(
                        MoeslimIcons.keuangan,
                        'Saldo Akhir',
                        rupiah(s['balance'] as num),
                        null,
                        key: const Key('report-balance'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (ctx.can('finance.export')) ...[
            const SectionHeader('Ekspor Laporan'),
            OutlinedButton.icon(
              key: const Key('export-csv'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _exporting ? null : _export,
              icon: const Icon(MoeslimIcons.excel),
              label: const Text('Ekspor CSV (dapat dibuka di Excel)'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(radius: 5, backgroundColor: color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12.5)),
    ],
  );
}

class _SumRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _SumRow(this.icon, this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: color ?? BrandColors.emerald),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

/// Grafik batang berpasangan (pemasukan emerald, pengeluaran emas) per bulan; bulan terpilih ditebalkan.
class BarChartPainter extends CustomPainter {
  final List<(double, double)> data;
  final int? highlight;
  final Color labelColor;
  BarChartPainter(this.data, {this.highlight, required this.labelColor});

  static const _short = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 18.0;
    final maxV = data.fold<double>(0, (m, e) => math.max(m, math.max(e.$1, e.$2)));
    final chartH = size.height - labelH;
    final slot = size.width / data.length;
    final barW = slot * .3;
    final grid = Paint()
      ..color = labelColor.withValues(alpha: .15)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chartH * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (final (i, (inV, outV)) in data.indexed) {
      final x = slot * i + slot / 2;
      final dim = highlight != null && highlight != i;
      void bar(double v, double dx, Color c) {
        if (maxV <= 0 || v <= 0) return;
        final h = v / maxV * (chartH - 4);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x + dx, chartH - h, barW, h),
            topLeft: const Radius.circular(3),
            topRight: const Radius.circular(3),
          ),
          Paint()..color = dim ? c.withValues(alpha: .35) : c,
        );
      }

      bar(inV, -barW, BrandColors.emerald);
      bar(outV, 0, BrandColors.gold);
      final tp = TextPainter(
        text: TextSpan(
          text: _short[i % 12],
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontFamily: 'Inter',
            package: 'moeslim_brand',
            fontWeight: highlight == i ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 3));
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) => old.data != data || old.highlight != highlight;
}
