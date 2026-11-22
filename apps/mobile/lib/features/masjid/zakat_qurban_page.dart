import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'finance_pro_pages.dart' show saveBoundaryPng;
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const _zakatTypeLabels = {
  'fitrah_money': 'Fitrah (Uang)',
  'fitrah_rice': 'Fitrah (Beras)',
  'maal': 'Zakat Maal',
  'fidyah': 'Fidyah',
};

const _asnafLabels = {
  'fakir': 'Fakir',
  'miskin': 'Miskin',
  'amil': 'Amil',
  'muallaf': 'Muallaf',
  'riqab': 'Riqab',
  'gharimin': 'Gharimin',
  'fisabilillah': 'Fisabilillah',
  'ibnu_sabil': 'Ibnu Sabil',
};

const _speciesLabels = {
  'sapi': 'Sapi',
  'kambing': 'Kambing',
  'domba': 'Domba',
  'kerbau': 'Kerbau',
  'unta': 'Unta',
};

const _slaughterLabels = {
  'registered': 'Terdaftar',
  'slaughtered': 'Disembelih',
  'skinned': 'Dikuliti',
  'packaged': 'Dikemas',
  'distributed': 'Didistribusikan',
};

const _paymentLabels = {
  'unpaid': ('Belum Lunas', MosqueColors.expense),
  'dp': ('DP', MosqueColors.warning),
  'paid': ('Lunas', MosqueColors.income),
};

int defaultHijriYear() => ((DateTime.now().year - 622) * 33 ~/ 32);

/// Halaman Zakat Fitrah, Maal & Distribusi Mustahik (#21).
class ZakatPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const ZakatPage({super.key, required this.ctx});

  @override
  ConsumerState<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends ConsumerState<ZakatPage> {
  int _tab = 0;
  int _year = defaultHijriYear();

  Future<void> _distribute(Map<String, dynamic> m) async {
    try {
      await ref.read(masjidApiProvider).distributeMustahik(widget.ctx.id, m['id'] as int);
      ref.invalidate(zakatProvider((widget.ctx.id, _year)));
      if (mounted) showSnack(context, '${m['name']} ditandai sudah menerima zakat.');
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final key = (ctx.id, _year);
    final zakat = ref.watch(zakatProvider(key));
    final canWrite = ctx.can('zakat.write');

    return Scaffold(
      appBar: AppBar(title: const Text('Zakat Fitrah & Maal'), centerTitle: true),
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              heroTag: null,
              key: Key(_tab == 0 ? 'add-zakat-collection' : 'add-zakat-mustahik'),
              icon: const Icon(MoeslimIcons.tambah),
              label: Text(_tab == 0 ? 'Catat Muzakki' : 'Tambah Mustahik'),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _tab == 0
                    ? _ZakatCollectionSheet(ctx: ctx, hijriYear: _year)
                    : _ZakatMustahikSheet(ctx: ctx, hijriYear: _year),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(zakatProvider(key).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            _HijriYearBar(
              year: _year,
              onChanged: (y) => setState(() => _year = y),
            ),
            const SizedBox(height: 10),
            PillTabs(
              labels: const ['Muzakki (Masuk)', 'Mustahik (Salur)'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            AsyncBody(
              value: zakat,
              onRetry: () => ref.invalidate(zakatProvider(key)),
              data: (d) {
                final sum = (d['summary'] as Map?) ?? const {};
                final collections = (d['collections'] as List? ?? const []).cast<Map<String, dynamic>>();
                final mustahiks = (d['mustahiks'] as List? ?? const []).cast<Map<String, dynamic>>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.85,
                      children: [
                        StatTile(
                          icon: MoeslimIcons.keuangan,
                          label: 'Zakat Uang',
                          value: rupiah((sum['total_money_in'] as num?) ?? 0),
                          caption: '${sum['total_souls'] ?? 0} jiwa',
                        ),
                        StatTile(
                          icon: MoeslimIcons.saldo,
                          label: 'Zakat Beras',
                          value: '${sum['total_rice_in_kg'] ?? 0} kg',
                          caption: '${sum['distributed_mustahik'] ?? 0}/${sum['total_mustahik'] ?? 0} mustahik',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_tab == 0)
                      collections.isEmpty
                          ? const EmptyState(MoeslimIcons.keuangan, 'Belum ada penerimaan zakat pada tahun ini')
                          : Column(
                              children: [
                                for (final c in collections)
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text('${c['muzakki_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                      subtitle: Text(
                                        '${_zakatTypeLabels[c['type']] ?? c['type']} • ${c['souls_count']} jiwa • ${c['date']}',
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (((c['money_amount'] as num?) ?? 0) > 0)
                                            Text(
                                              rupiah(c['money_amount'] as num),
                                              style: const TextStyle(fontWeight: FontWeight.w800, color: MosqueColors.income),
                                            ),
                                          if (((c['rice_kg'] as num?) ?? 0) > 0)
                                            Text(
                                              '${c['rice_kg']} kg beras',
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                    else
                      mustahiks.isEmpty
                          ? const EmptyState(MoeslimIcons.jamaah, 'Belum ada daftar mustahik pada tahun ini')
                          : Column(
                              children: [
                                for (final m in mustahiks)
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${m['name']}',
                                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                                      ),
                                                    ),
                                                    StatusBadge(_asnafLabels[m['asnaf']] ?? '${m['asnaf']}'),
                                                  ],
                                                ),
                                                if (m['address'] != null)
                                                  Text('${m['address']}', style: const TextStyle(fontSize: 12.5)),
                                                const SizedBox(height: 4),
                                                Text(
                                                  [
                                                    if (((m['money_amount'] as num?) ?? 0) > 0) rupiah(m['money_amount'] as num),
                                                    if (((m['rice_kg'] as num?) ?? 0) > 0) '${m['rice_kg']} kg beras',
                                                  ].join(' • '),
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (m['status'] == 'distributed')
                                            const StatusBadge('Tersalur', icon: MoeslimIcons.check, color: MosqueColors.income)
                                          else if (canWrite)
                                            FilledButton.tonal(
                                              key: Key('distribute-mustahik-${m['id']}'),
                                              onPressed: () => _distribute(m),
                                              child: const Text('Salurkan'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
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

class _ZakatCollectionSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  const _ZakatCollectionSheet({required this.ctx, required this.hijriYear});

  @override
  ConsumerState<_ZakatCollectionSheet> createState() => _ZakatCollectionSheetState();
}

class _ZakatCollectionSheetState extends ConsumerState<_ZakatCollectionSheet> {
  String _type = 'fitrah_money';
  final _name = TextEditingController();
  final _souls = TextEditingController(text: '1');
  final _money = TextEditingController();
  final _rice = TextEditingController();
  bool _recordFinance = true;
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final canFinance = widget.ctx.can('finance.write');
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Catat Penerimaan Zakat (${widget.hijriYear} H)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Jenis Zakat'),
            items: [for (final e in _zakatTypeLabels.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('muzakki-name'),
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nama Muzakki / Kepala Keluarga *'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('muzakki-souls'),
                  controller: _souls,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Jumlah Jiwa'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('muzakki-money'),
                  controller: _money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Uang (Rp)', prefixText: 'Rp '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('muzakki-rice'),
            controller: _rice,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Beras (kg, opsional)', hintText: 'Contoh: 2.7'),
          ),
          if (canFinance)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Catat otomatis ke Buku Kas (Dana Zakat)'),
              value: _recordFinance,
              onChanged: (v) => setState(() => _recordFinance = v),
            ),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('save-zakat-collection'),
            onPressed: _busy
                ? null
                : () async {
                    setState(() {
                      _busy = true;
                      _error = null;
                    });
                    try {
                      await ref.read(masjidApiProvider).createZakatCollection(widget.ctx.id, {
                        'type': _type,
                        'hijri_year': widget.hijriYear,
                        'date': isoDate(DateTime.now()),
                        'muzakki_name': _name.text.trim(),
                        'souls_count': int.tryParse(_souls.text.trim()) ?? 1,
                        'money_amount': int.tryParse(_money.text.trim()) ?? 0,
                        'rice_kg': double.tryParse(_rice.text.trim().replaceAll(',', '.')) ?? 0,
                        'record_to_finance': canFinance && _recordFinance,
                      });
                      ref.invalidate(zakatProvider((widget.ctx.id, widget.hijriYear)));
                      ref.invalidate(dashboardProvider(widget.ctx.id));
                      ref.invalidate(financeSummaryProvider);
                      if (context.mounted) Navigator.pop(context);
                    } on ApiException catch (e) {
                      setState(() => _error = e.message);
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            child: const Text('Simpan Penerimaan'),
          ),
        ],
      ),
    );
  }
}

class _ZakatMustahikSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  const _ZakatMustahikSheet({required this.ctx, required this.hijriYear});

  @override
  ConsumerState<_ZakatMustahikSheet> createState() => _ZakatMustahikSheetState();
}

class _ZakatMustahikSheetState extends ConsumerState<_ZakatMustahikSheet> {
  String _asnaf = 'fakir';
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _money = TextEditingController();
  final _rice = TextEditingController(text: '3.5');
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tambah Mustahik (${widget.hijriYear} H)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          key: const Key('mustahik-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nama Penerima *'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _asnaf,
          decoration: const InputDecoration(labelText: 'Golongan Asnaf'),
          items: [for (final e in _asnafLabels.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
          onChanged: (v) => setState(() => _asnaf = v ?? _asnaf),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _address,
          decoration: const InputDecoration(labelText: 'Alamat / RT RW'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _money,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Uang (Rp)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _rice,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Beras (kg)'),
              ),
            ),
          ],
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('save-mustahik'),
          onPressed: _busy
              ? null
              : () async {
                  setState(() {
                    _busy = true;
                    _error = null;
                  });
                  try {
                    await ref.read(masjidApiProvider).createZakatMustahik(widget.ctx.id, {
                      'hijri_year': widget.hijriYear,
                      'name': _name.text.trim(),
                      'asnaf': _asnaf,
                      if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
                      'money_amount': int.tryParse(_money.text.trim()) ?? 0,
                      'rice_kg': double.tryParse(_rice.text.trim().replaceAll(',', '.')) ?? 0,
                    });
                    ref.invalidate(zakatProvider((widget.ctx.id, widget.hijriYear)));
                    if (context.mounted) Navigator.pop(context);
                  } on ApiException catch (e) {
                    setState(() => _error = e.message);
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: const Text('Simpan Mustahik'),
        ),
      ],
    ),
  );
}

/// Halaman Kurban Lengkap (Patungan 1/7, Progres Sembelih) & Kupon Distribusi QR Anti-Dobel (#22, #23).
class QurbanPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const QurbanPage({super.key, required this.ctx});

  @override
  ConsumerState<QurbanPage> createState() => _QurbanPageState();
}

class _QurbanPageState extends ConsumerState<QurbanPage> {
  int _tab = 0;
  int _year = defaultHijriYear();
  final _couponCode = TextEditingController();
  bool _redeeming = false;
  (bool ok, String message)? _redeemResult;

  @override
  void dispose() {
    _couponCode.dispose();
    super.dispose();
  }

  Future<void> _redeem([String? scanned]) async {
    final code = (scanned ?? _couponCode.text).trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _redeeming = true;
      _redeemResult = null;
    });
    try {
      final data = await ref.read(masjidApiProvider).redeemCoupon(widget.ctx.id, code);
      ref.invalidate(couponsProvider((widget.ctx.id, 'qurban', _year)));
      _couponCode.clear();
      if (mounted) {
        setState(() => _redeemResult = (true, 'Kupon ${data['code']} (${data['recipient_name']}) berhasil ditukar.'));
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _redeemResult = (false, e.message));
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _openScanner() async {
    final code = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerPage()));
    if (code != null && code.isNotEmpty && mounted) {
      _couponCode.text = code;
      await _redeem(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final canWrite = ctx.can('qurban.write');
    final qurban = ref.watch(qurbanProvider((ctx.id, _year)));
    final coupons = ref.watch(couponsProvider((ctx.id, 'qurban', _year)));

    return Scaffold(
      appBar: AppBar(title: const Text('Kurban & Kupon QR'), centerTitle: true),
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              heroTag: null,
              key: Key(_tab == 0 ? 'add-animal' : 'add-coupons'),
              icon: const Icon(MoeslimIcons.tambah),
              label: Text(_tab == 0 ? 'Tambah Hewan' : 'Terbitkan Kupon'),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _tab == 0
                    ? _AnimalSheet(ctx: ctx, hijriYear: _year)
                    : _CouponBatchSheet(ctx: ctx, hijriYear: _year),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(qurbanProvider((ctx.id, _year)));
          ref.invalidate(couponsProvider((ctx.id, 'qurban', _year)));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            _HijriYearBar(year: _year, onChanged: (y) => setState(() => _year = y)),
            const SizedBox(height: 10),
            PillTabs(
              labels: const ['Hewan & Patungan', 'Kupon QR & Scan'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            if (_tab == 0)
              AsyncBody(
                value: qurban,
                onRetry: () => ref.invalidate(qurbanProvider((ctx.id, _year))),
                data: (d) {
                  final sum = (d['summary'] as Map?) ?? const {};
                  final animals = (d['data'] as List? ?? const []).cast<Map<String, dynamic>>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.85,
                        children: [
                          StatTile(
                            icon: MoeslimIcons.kegiatan,
                            label: 'Hewan Kurban',
                            value: '${sum['total_animals'] ?? 0}',
                            caption: '${sum['slaughtered_count'] ?? 0} sudah disembelih',
                          ),
                          StatTile(
                            icon: MoeslimIcons.jamaah,
                            label: 'Shohibul Qurban',
                            value: '${sum['total_participants'] ?? 0}',
                            caption: '${sum['total_meat_packs'] ?? 0} bungkus daging',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (animals.isEmpty)
                        const EmptyState(MoeslimIcons.kegiatan, 'Belum ada hewan kurban terdaftar')
                      else
                        for (final a in animals) _AnimalCard(ctx: ctx, hijriYear: _year, animal: a, canWrite: canWrite),
                    ],
                  );
                },
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (canWrite)
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Verifikasi & Tukar Kupon (Anti-Dobel)', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    key: const Key('coupon-code-input'),
                                    controller: _couponCode,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: const InputDecoration(
                                      labelText: 'Kode Kupon',
                                      hintText: 'QBN-XXXXXX',
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _redeem(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  key: const Key('open-qr-scanner'),
                                  tooltip: 'Pindai QR Kamera',
                                  onPressed: _redeeming ? null : _openScanner,
                                  icon: const Icon(Icons.qr_code_scanner_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              key: const Key('redeem-coupon-btn'),
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                              onPressed: _redeeming ? null : () => _redeem(),
                              icon: const Icon(MoeslimIcons.check),
                              label: const Text('Verifikasi & Tukar Kupon'),
                            ),
                            if (_redeemResult != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                key: const Key('redeem-result-banner'),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (_redeemResult!.$1 ? MosqueColors.income : MosqueColors.expense).withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _redeemResult!.$2,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _redeemResult!.$1 ? MosqueColors.income : MosqueColors.expense,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  AsyncBody(
                    value: coupons,
                    onRetry: () => ref.invalidate(couponsProvider((ctx.id, 'qurban', _year))),
                    data: (d) {
                      final sum = (d['summary'] as Map?) ?? const {};
                      final list = (d['data'] as List? ?? const []).cast<Map<String, dynamic>>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  icon: Icons.confirmation_num_outlined,
                                  label: 'Kupon Aktif',
                                  value: '${sum['issued'] ?? 0}',
                                  caption: 'dari ${sum['total'] ?? 0} total',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatTile(
                                  icon: MoeslimIcons.check,
                                  label: 'Sudah Ditukar',
                                  value: '${sum['redeemed'] ?? 0}',
                                  caption: 'terverifikasi',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (list.isEmpty)
                            const EmptyState(Icons.qr_code_2_rounded, 'Belum ada kupon distribusi')
                          else
                            for (final c in list)
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  key: Key('coupon-${c['code']}'),
                                  leading: Icon(
                                    Icons.qr_code_2_rounded,
                                    color: c['status'] == 'redeemed' ? MosqueColors.income : BrandColors.emerald,
                                  ),
                                  title: Text('${c['recipient_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text('${c['code']}${c['recipient_address'] != null ? ' • ${c['recipient_address']}' : ''}'),
                                  trailing: StatusBadge(
                                    c['status'] == 'redeemed'
                                        ? 'Ditukar'
                                        : (c['status'] == 'void' ? 'Batal' : 'Aktif'),
                                    color: c['status'] == 'redeemed'
                                        ? MosqueColors.income
                                        : (c['status'] == 'void' ? MosqueColors.expense : MosqueColors.info),
                                  ),
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => _CouponQrSheet(mosqueName: ctx.name, coupon: c),
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimalCard extends ConsumerWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  final Map<String, dynamic> animal;
  final bool canWrite;
  const _AnimalCard({required this.ctx, required this.hijriYear, required this.animal, required this.canWrite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = animal;
    final used = (a['used_shares'] as num?)?.toInt() ?? 0;
    final cap = (a['capacity'] as num?)?.toInt() ?? 1;
    final rem = (a['remaining_shares'] as num?)?.toInt() ?? 0;
    final participants = (a['participants'] as List? ?? const []).cast<Map<String, dynamic>>();
    final status = '${a['slaughter_status'] ?? 'registered'}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${a['code']} • ${_speciesLabels[a['species']] ?? a['species']}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        'Kuota: $used/$cap bagian${a['weight_kg'] != null ? ' • ${a['weight_kg']} kg' : ''}',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                StatusBadge(_slaughterLabels[status] ?? status),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: cap > 0 ? (used / cap).clamp(0.0, 1.0) : 0,
                minHeight: 7,
                color: rem == 0 ? MosqueColors.income : BrandColors.emerald,
              ),
            ),
            if (canWrite) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: Key('animal-status-${a['id']}'),
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status Penyembelihan', isDense: true),
                items: [for (final s in _slaughterLabels.entries) DropdownMenuItem(value: s.key, child: Text(s.value))],
                onChanged: (v) async {
                  if (v == null || v == status) return;
                  try {
                    await ref.read(masjidApiProvider).updateQurbanAnimal(ctx.id, a['id'] as int, {'slaughter_status': v});
                    ref.invalidate(qurbanProvider((ctx.id, hijriYear)));
                  } on ApiException catch (e) {
                    if (context.mounted) showSnack(context, e.message);
                  }
                },
              ),
            ],
            const SizedBox(height: 8),
            if (participants.isEmpty)
              const Text('Belum ada shohibul qurban.', style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic))
            else
              for (final p in participants)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${p['name']} (${p['shares']} bagian)', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(rupiah((p['amount_idr'] as num?) ?? 0)),
                  trailing: StatusBadge(
                    (_paymentLabels[p['payment_status']] ?? ('Belum', MosqueColors.expense)).$1,
                    color: (_paymentLabels[p['payment_status']] ?? ('Belum', MosqueColors.expense)).$2,
                  ),
                ),
            if (canWrite && rem > 0) ...[
              const SizedBox(height: 6),
              OutlinedButton.icon(
                key: Key('add-participant-${a['id']}'),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => _ParticipantSheet(
                    ctx: ctx,
                    hijriYear: hijriYear,
                    animalId: a['id'] as int,
                    animalCode: '${a['code']}',
                    remaining: rem,
                  ),
                ),
                icon: const Icon(MoeslimIcons.tambah),
                label: Text('Tambah Shohibul Qurban (sisa $rem)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimalSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  const _AnimalSheet({required this.ctx, required this.hijriYear});

  @override
  ConsumerState<_AnimalSheet> createState() => _AnimalSheetState();
}

class _AnimalSheetState extends ConsumerState<_AnimalSheet> {
  String _species = 'sapi';
  final _code = TextEditingController(text: 'SAPI-01');
  final _weight = TextEditingController();
  final _price = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tambah Hewan Kurban (${widget.hijriYear} H)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _species,
          decoration: const InputDecoration(labelText: 'Jenis Hewan'),
          items: [for (final s in _speciesLabels.entries) DropdownMenuItem(value: s.key, child: Text(s.value))],
          onChanged: (v) => setState(() => _species = v ?? _species),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('animal-code'),
          controller: _code,
          decoration: const InputDecoration(labelText: 'Kode Hewan *', hintText: 'Contoh: SAPI-01 atau KMB-01'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Bobot (kg)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
              ),
            ),
          ],
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('save-animal'),
          onPressed: _busy
              ? null
              : () async {
                  setState(() {
                    _busy = true;
                    _error = null;
                  });
                  try {
                    await ref.read(masjidApiProvider).createQurbanAnimal(widget.ctx.id, {
                      'hijri_year': widget.hijriYear,
                      'code': _code.text.trim(),
                      'species': _species,
                      if (_weight.text.trim().isNotEmpty) 'weight_kg': double.tryParse(_weight.text.trim()),
                      'price_idr': int.tryParse(_price.text.trim()) ?? 0,
                    });
                    ref.invalidate(qurbanProvider((widget.ctx.id, widget.hijriYear)));
                    if (context.mounted) Navigator.pop(context);
                  } on ApiException catch (e) {
                    setState(() => _error = e.message);
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: const Text('Simpan Hewan'),
        ),
      ],
    ),
  );
}

class _ParticipantSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  final int animalId;
  final String animalCode;
  final int remaining;
  const _ParticipantSheet({
    required this.ctx,
    required this.hijriYear,
    required this.animalId,
    required this.animalCode,
    required this.remaining,
  });

  @override
  ConsumerState<_ParticipantSheet> createState() => _ParticipantSheetState();
}

class _ParticipantSheetState extends ConsumerState<_ParticipantSheet> {
  final _name = TextEditingController();
  final _shares = TextEditingController(text: '1');
  final _amount = TextEditingController();
  String _payment = 'paid';
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Shohibul Qurban (${widget.animalCode})', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          key: const Key('participant-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nama Pekurban *'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('participant-shares'),
                controller: _shares,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'Bagian (maks ${widget.remaining})'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: const Key('participant-amount'),
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _payment,
          decoration: const InputDecoration(labelText: 'Status Pembayaran'),
          items: [for (final e in _paymentLabels.entries) DropdownMenuItem(value: e.key, child: Text(e.value.$1))],
          onChanged: (v) => setState(() => _payment = v ?? _payment),
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('save-participant'),
          onPressed: _busy
              ? null
              : () async {
                  setState(() {
                    _busy = true;
                    _error = null;
                  });
                  try {
                    await ref.read(masjidApiProvider).createQurbanParticipant(widget.ctx.id, widget.animalId, {
                      'name': _name.text.trim(),
                      'shares': int.tryParse(_shares.text.trim()) ?? 1,
                      'amount_idr': int.tryParse(_amount.text.trim()) ?? 0,
                      'payment_status': _payment,
                    });
                    ref.invalidate(qurbanProvider((widget.ctx.id, widget.hijriYear)));
                    if (context.mounted) Navigator.pop(context);
                  } on ApiException catch (e) {
                    setState(() => _error = e.message);
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: const Text('Simpan Pekurban'),
        ),
      ],
    ),
  );
}

class _CouponBatchSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  const _CouponBatchSheet({required this.ctx, required this.hijriYear});

  @override
  ConsumerState<_CouponBatchSheet> createState() => _CouponBatchSheetState();
}

class _CouponBatchSheetState extends ConsumerState<_CouponBatchSheet> {
  final _prefix = TextEditingController(text: 'Warga Sekitar Masjid');
  final _count = TextEditingController(text: '10');
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Terbitkan Kupon QR Kurban', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          key: const Key('coupon-prefix'),
          controller: _prefix,
          decoration: const InputDecoration(labelText: 'Nama Penerima / Label Kelompok *'),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('coupon-count'),
          controller: _count,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Jumlah Kupon (1 hingga 200)'),
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('save-coupons'),
          onPressed: _busy
              ? null
              : () async {
                  setState(() {
                    _busy = true;
                    _error = null;
                  });
                  try {
                    final n = (int.tryParse(_count.text.trim()) ?? 1).clamp(1, 200);
                    await ref.read(masjidApiProvider).createCoupons(widget.ctx.id, {
                      'program': 'qurban',
                      'hijri_year': widget.hijriYear,
                      if (n == 1) 'recipient_name': _prefix.text.trim() else ...{
                        'batch_count': n,
                        'recipient_prefix': _prefix.text.trim(),
                      },
                    });
                    ref.invalidate(couponsProvider((widget.ctx.id, 'qurban', widget.hijriYear)));
                    if (context.mounted) Navigator.pop(context);
                  } on ApiException catch (e) {
                    setState(() => _error = e.message);
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: const Text('Terbitkan Kupon QR'),
        ),
      ],
    ),
  );
}

class _CouponQrSheet extends StatefulWidget {
  final String mosqueName;
  final Map<String, dynamic> coupon;
  const _CouponQrSheet({required this.mosqueName, required this.coupon});

  @override
  State<_CouponQrSheet> createState() => _CouponQrSheetState();
}

class _CouponQrSheetState extends State<_CouponQrSheet> {
  final _key = GlobalKey();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.coupon;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RepaintBoundary(
              key: _key,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BrandColors.emerald, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.mosqueName,
                      style: const TextStyle(color: BrandColors.dark, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const Text(
                      'KUPON DISTRIBUSI KURBAN',
                      style: TextStyle(color: BrandColors.goldText, fontWeight: FontWeight.w700, fontSize: 11.5),
                    ),
                    const SizedBox(height: 12),
                    QrImageView(data: '${c['code']}', size: 160),
                    const SizedBox(height: 8),
                    Text(
                      '${c['code']}',
                      style: const TextStyle(color: BrandColors.deep, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.2),
                    ),
                    Text('${c['recipient_name']}', style: const TextStyle(color: BrandColors.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      try {
                        final path = await saveBoundaryPng(_key, 'kupon-${c['code']}.png');
                        if (context.mounted) showSnack(context, 'Kupon PNG tersimpan: $path');
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              icon: const Icon(Icons.image_outlined),
              label: const Text('Simpan Kartu Kupon PNG'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  bool _popped = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pindai QR Kupon'), centerTitle: true),
    body: MobileScanner(
      onDetect: (capture) {
        if (_popped) return;
        final raw = capture.barcodes.firstOrNull?.rawValue;
        if (raw != null && raw.trim().isNotEmpty) {
          _popped = true;
          Navigator.of(context).pop(raw.trim());
        }
      },
    ),
  );
}

class _HijriYearBar extends StatelessWidget {
  final int year;
  final ValueChanged<int> onChanged;
  const _HijriYearBar({required this.year, required this.onChanged});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Row(
      children: [
        IconButton(
          tooltip: 'Tahun sebelumnya',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(year - 1),
        ),
        Expanded(
          child: Text(
            'Tahun $year H',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        IconButton(
          tooltip: 'Tahun berikutnya',
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onChanged(year + 1),
        ),
      ],
    ),
  );
}
