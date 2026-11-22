import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
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

const _zakatTypeLabelsEn = {
  'fitrah_money': 'Fitrah (Cash)',
  'fitrah_rice': 'Fitrah (Rice)',
  'maal': 'Zakat Maal',
  'fidyah': 'Fidyah',
};

String _zakatTypeLabel(Object? k, AppLanguage lang) =>
    (lang == AppLanguage.en ? _zakatTypeLabelsEn[k] : _zakatTypeLabels[k]) ?? '$k';

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

const _asnafLabelsEn = {
  'fakir': 'Fakir',
  'miskin': 'Miskin',
  'amil': 'Amil',
  'muallaf': 'Muallaf',
  'riqab': 'Riqab',
  'gharimin': 'Gharimin',
  'fisabilillah': 'Fisabilillah',
  'ibnu_sabil': 'Ibn al-Sabil',
};

String _asnafLabel(Object? k, AppLanguage lang) =>
    (lang == AppLanguage.en ? _asnafLabelsEn[k] : _asnafLabels[k]) ?? '$k';

const _speciesLabels = {
  'sapi': 'Sapi',
  'kambing': 'Kambing',
  'domba': 'Domba',
  'kerbau': 'Kerbau',
  'unta': 'Unta',
};

const _speciesLabelsEn = {
  'sapi': 'Cow',
  'kambing': 'Goat',
  'domba': 'Sheep',
  'kerbau': 'Buffalo',
  'unta': 'Camel',
};

String _speciesLabel(Object? k, AppLanguage lang) =>
    (lang == AppLanguage.en ? _speciesLabelsEn[k] : _speciesLabels[k]) ?? '$k';

const _slaughterLabels = {
  'registered': 'Terdaftar',
  'slaughtered': 'Disembelih',
  'skinned': 'Dikuliti',
  'packaged': 'Dikemas',
  'distributed': 'Didistribusikan',
};

const _slaughterLabelsEn = {
  'registered': 'Registered',
  'slaughtered': 'Slaughtered',
  'skinned': 'Skinned',
  'packaged': 'Packaged',
  'distributed': 'Distributed',
};

String _slaughterLabel(Object? k, AppLanguage lang) =>
    (lang == AppLanguage.en ? _slaughterLabelsEn[k] : _slaughterLabels[k]) ?? '$k';

const _paymentLabels = {
  'unpaid': ('Belum Lunas', MosqueColors.expense),
  'dp': ('DP', MosqueColors.warning),
  'paid': ('Lunas', MosqueColors.income),
};

const _paymentLabelsEn = {
  'unpaid': ('Unpaid', MosqueColors.expense),
  'dp': ('Deposit', MosqueColors.warning),
  'paid': ('Paid', MosqueColors.income),
};

(String, Color) _paymentBadge(Object? k, AppLanguage lang) =>
    (lang == AppLanguage.en ? _paymentLabelsEn[k] : _paymentLabels[k]) ??
    (lang == AppLanguage.en ? ('Unpaid', MosqueColors.expense) : ('Belum', MosqueColors.expense));

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

  Future<void> _distribute(BuildContext context, Map<String, dynamic> m) async {
    final isEn = context.isEn;
    try {
      await ref.read(masjidApiProvider).distributeMustahik(widget.ctx.id, m['id'] as int);
      ref.invalidate(zakatProvider((widget.ctx.id, _year)));
      if (context.mounted) {
        showSnack(
          context,
          isEn
              ? '${m['name']} marked as having received zakat.'
              : '${m['name']} ditandai sudah menerima zakat.',
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final ctx = widget.ctx;
    final lang = context.lang;
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
              label: Text(
                _tab == 0 ? context.tr('Catat Muzakki', 'Record Donor') : context.tr('Tambah Mustahik', 'Add Recipient'),
              ),
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
              labels: [
                context.tr('Muzakki (Masuk)', 'Muzakki (In)'),
                context.tr('Mustahik (Salur)', 'Mustahik (Out)'),
              ],
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
                          label: context.tr('Zakat Uang', 'Cash Zakat'),
                          value: rupiah((sum['total_money_in'] as num?) ?? 0),
                          caption: context.tr('${sum['total_souls'] ?? 0} jiwa', '${sum['total_souls'] ?? 0} people'),
                        ),
                        StatTile(
                          icon: MoeslimIcons.saldo,
                          label: context.tr('Zakat Beras', 'Rice Zakat'),
                          value: '${sum['total_rice_in_kg'] ?? 0} kg',
                          caption: context.tr(
                            '${sum['distributed_mustahik'] ?? 0}/${sum['total_mustahik'] ?? 0} mustahik',
                            '${sum['distributed_mustahik'] ?? 0}/${sum['total_mustahik'] ?? 0} recipients',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_tab == 0)
                      collections.isEmpty
                          ? EmptyState(
                              MoeslimIcons.keuangan,
                              context.tr(
                                'Belum ada penerimaan zakat pada tahun ini',
                                'No zakat collections recorded this year',
                              ),
                            )
                          : Column(
                              children: [
                                for (final c in collections)
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text('${c['muzakki_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                      subtitle: Text(
                                        '${_zakatTypeLabel(c['type'], lang)} • ${c['souls_count']} ${context.tr('jiwa', 'people')} • ${c['date']}',
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
                                              context.tr('${c['rice_kg']} kg beras', '${c['rice_kg']} kg rice'),
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
                          ? EmptyState(
                              MoeslimIcons.jamaah,
                              context.tr(
                                'Belum ada daftar mustahik pada tahun ini',
                                'No recipients listed this year',
                              ),
                            )
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
                                                    StatusBadge(_asnafLabel(m['asnaf'], lang)),
                                                  ],
                                                ),
                                                if (m['address'] != null)
                                                  Text('${m['address']}', style: const TextStyle(fontSize: 12.5)),
                                                const SizedBox(height: 4),
                                                Text(
                                                  [
                                                    if (((m['money_amount'] as num?) ?? 0) > 0) rupiah(m['money_amount'] as num),
                                                    if (((m['rice_kg'] as num?) ?? 0) > 0)
                                                      context.tr('${m['rice_kg']} kg beras', '${m['rice_kg']} kg rice'),
                                                  ].join(' • '),
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (m['status'] == 'distributed')
                                            StatusBadge(
                                              context.tr('Tersalur', 'Distributed'),
                                              icon: MoeslimIcons.check,
                                              color: MosqueColors.income,
                                            )
                                          else if (canWrite)
                                            FilledButton.tonal(
                                              key: Key('distribute-mustahik-${m['id']}'),
                                              onPressed: () => _distribute(context, m),
                                              child: Text(context.tr('Salurkan', 'Distribute')),
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
  });
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
  final _souls = TextEditingController();
  final _money = TextEditingController();
  final _rice = TextEditingController();
  bool _recordFinance = true;
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    final canFinance = widget.ctx.can('finance.write');
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(
              'Catat Penerimaan Zakat (${widget.hijriYear} H)',
              'Record Zakat Collection (${widget.hijriYear} AH)',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(labelText: context.tr('Jenis Zakat', 'Zakat Type')),
            items: [
              for (final e in _zakatTypeLabels.entries)
                DropdownMenuItem(value: e.key, child: Text(_zakatTypeLabel(e.key, lang))),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('muzakki-name'),
            controller: _name,
            decoration: InputDecoration(
              labelText: context.tr('Nama Muzakki / Kepala Keluarga *', 'Donor / Head of Household Name *'),
            ),
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
                  decoration: InputDecoration(
                    labelText: context.tr('Jumlah Jiwa', 'Number of People'),
                    hintText: context.tr('Contoh: 1', 'Example: 1'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('muzakki-money'),
                  controller: _money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: context.tr('Uang (Rp)', 'Cash (Rp)'), prefixText: 'Rp '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('muzakki-rice'),
            controller: _rice,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.tr('Beras (kg, opsional)', 'Rice (kg, optional)'),
              hintText: context.tr('Contoh: 2.7', 'Example: 2.7'),
            ),
          ),
          if (canFinance)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.tr(
                  'Catat otomatis ke Buku Kas (Dana Zakat)',
                  'Automatically record to Cash Ledger (Zakat Fund)',
                ),
              ),
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
            child: Text(context.tr('Simpan Penerimaan', 'Save Collection')),
          ),
        ],
      ),
    );
  });
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
  final _rice = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('Tambah Mustahik (${widget.hijriYear} H)', 'Add Recipient (${widget.hijriYear} AH)'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('mustahik-name'),
            controller: _name,
            decoration: InputDecoration(labelText: context.tr('Nama Penerima *', 'Recipient Name *')),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _asnaf,
            decoration: InputDecoration(labelText: context.tr('Golongan Asnaf', 'Asnaf Category')),
            items: [
              for (final e in _asnafLabels.entries) DropdownMenuItem(value: e.key, child: Text(_asnafLabel(e.key, lang))),
            ],
            onChanged: (v) => setState(() => _asnaf = v ?? _asnaf),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _address,
            decoration: InputDecoration(labelText: context.tr('Alamat / RT RW', 'Address / Neighborhood')),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: context.tr('Uang (Rp)', 'Cash (Rp)')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _rice,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.tr('Beras (kg)', 'Rice (kg)'),
                    hintText: context.tr('Contoh: 3.5', 'Example: 3.5'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
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
            child: Text(context.tr('Simpan Mustahik', 'Save Recipient')),
          ),
        ],
      ),
    );
  });
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

  Future<void> _redeem(BuildContext context, [String? scanned]) async {
    final code = (scanned ?? _couponCode.text).trim().toUpperCase();
    if (code.isEmpty) return;
    final isEn = context.isEn;
    setState(() {
      _redeeming = true;
      _redeemResult = null;
    });
    try {
      final data = await ref.read(masjidApiProvider).redeemCoupon(widget.ctx.id, code);
      ref.invalidate(couponsProvider((widget.ctx.id, 'qurban', _year)));
      _couponCode.clear();
      if (mounted) {
        setState(
          () => _redeemResult = (
            true,
            isEn
                ? 'Coupon ${data['code']} (${data['recipient_name']}) successfully redeemed.'
                : 'Kupon ${data['code']} (${data['recipient_name']}) berhasil ditukar.',
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _redeemResult = (false, e.message));
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _openScanner(BuildContext context) async {
    final code = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerPage()));
    if (code != null && code.isNotEmpty && context.mounted) {
      _couponCode.text = code;
      await _redeem(context, code);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final ctx = widget.ctx;
    final canWrite = ctx.can('qurban.write');
    final qurban = ref.watch(qurbanProvider((ctx.id, _year)));
    final coupons = ref.watch(couponsProvider((ctx.id, 'qurban', _year)));

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Kurban & Kupon QR', 'Qurban & QR Coupons')), centerTitle: true),
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              heroTag: null,
              key: Key(_tab == 0 ? 'add-animal' : 'add-coupons'),
              icon: const Icon(MoeslimIcons.tambah),
              label: Text(
                _tab == 0 ? context.tr('Tambah Hewan', 'Add Animal') : context.tr('Terbitkan Kupon', 'Issue Coupons'),
              ),
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
              labels: [
                context.tr('Hewan & Patungan', 'Animals & Shares'),
                context.tr('Kupon QR & Scan', 'QR Coupons & Scan'),
              ],
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
                            label: context.tr('Hewan Kurban', 'Qurban Animals'),
                            value: '${sum['total_animals'] ?? 0}',
                            caption: context.tr(
                              '${sum['slaughtered_count'] ?? 0} sudah disembelih',
                              '${sum['slaughtered_count'] ?? 0} slaughtered',
                            ),
                          ),
                          StatTile(
                            icon: MoeslimIcons.jamaah,
                            label: context.tr('Shohibul Qurban', 'Participants'),
                            value: '${sum['total_participants'] ?? 0}',
                            caption: context.tr(
                              '${sum['total_meat_packs'] ?? 0} bungkus daging',
                              '${sum['total_meat_packs'] ?? 0} meat packs',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (animals.isEmpty)
                        EmptyState(
                          MoeslimIcons.kegiatan,
                          context.tr('Belum ada hewan kurban terdaftar', 'No qurban animals registered yet'),
                        )
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
                            Text(
                              context.tr(
                                'Verifikasi & Tukar Kupon (Anti-Dobel)',
                                'Verify & Redeem Coupon (Anti-Duplicate)',
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    key: const Key('coupon-code-input'),
                                    controller: _couponCode,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      labelText: context.tr('Kode Kupon', 'Coupon Code'),
                                      hintText: 'QBN-XXXXXX',
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _redeem(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  key: const Key('open-qr-scanner'),
                                  tooltip: context.tr('Pindai QR Kamera', 'Scan QR with Camera'),
                                  onPressed: _redeeming ? null : () => _openScanner(context),
                                  icon: const Icon(Icons.qr_code_scanner_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              key: const Key('redeem-coupon-btn'),
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                              onPressed: _redeeming ? null : () => _redeem(context),
                              icon: const Icon(MoeslimIcons.check),
                              label: Text(context.tr('Verifikasi & Tukar Kupon', 'Verify & Redeem Coupon')),
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
                                  label: context.tr('Kupon Aktif', 'Active Coupons'),
                                  value: '${sum['issued'] ?? 0}',
                                  caption: context.tr('dari ${sum['total'] ?? 0} total', 'of ${sum['total'] ?? 0} total'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatTile(
                                  icon: MoeslimIcons.check,
                                  label: context.tr('Sudah Ditukar', 'Redeemed'),
                                  value: '${sum['redeemed'] ?? 0}',
                                  caption: context.tr('terverifikasi', 'verified'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (list.isEmpty)
                            EmptyState(
                              Icons.qr_code_2_rounded,
                              context.tr('Belum ada kupon distribusi', 'No distribution coupons yet'),
                            )
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
                                        ? context.tr('Ditukar', 'Redeemed')
                                        : (c['status'] == 'void'
                                              ? context.tr('Batal', 'Void')
                                              : context.tr('Aktif', 'Active')),
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
  });
}

class _AnimalCard extends ConsumerWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  final Map<String, dynamic> animal;
  final bool canWrite;
  const _AnimalCard({required this.ctx, required this.hijriYear, required this.animal, required this.canWrite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
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
                        '${a['code']} • ${_speciesLabel(a['species'], lang)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        context.tr(
                          'Kuota: $used/$cap bagian${a['weight_kg'] != null ? ' • ${a['weight_kg']} kg' : ''}',
                          'Quota: $used/$cap shares${a['weight_kg'] != null ? ' • ${a['weight_kg']} kg' : ''}',
                        ),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                StatusBadge(_slaughterLabel(status, lang)),
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
                decoration: InputDecoration(
                  labelText: context.tr('Status Penyembelihan', 'Slaughter Status'),
                  isDense: true,
                ),
                items: [
                  for (final s in _slaughterLabels.entries)
                    DropdownMenuItem(value: s.key, child: Text(_slaughterLabel(s.key, lang))),
                ],
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
              Text(
                context.tr('Belum ada shohibul qurban.', 'No participants yet.'),
                style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic),
              )
            else
              for (final p in participants)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr(
                      '${p['name']} (${p['shares']} bagian)',
                      '${p['name']} (${p['shares']} ${p['shares'] == 1 ? 'share' : 'shares'})',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(rupiah((p['amount_idr'] as num?) ?? 0)),
                  trailing: StatusBadge(
                    _paymentBadge(p['payment_status'], lang).$1,
                    color: _paymentBadge(p['payment_status'], lang).$2,
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
                label: Text(context.tr('Tambah Shohibul Qurban (sisa $rem)', 'Add Participant ($rem left)')),
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
  final _code = TextEditingController();
  final _weight = TextEditingController();
  final _price = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('Tambah Hewan Kurban (${widget.hijriYear} H)', 'Add Qurban Animal (${widget.hijriYear} AH)'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _species,
            decoration: InputDecoration(labelText: context.tr('Jenis Hewan', 'Animal Type')),
            items: [
              for (final s in _speciesLabels.entries)
                DropdownMenuItem(value: s.key, child: Text(_speciesLabel(s.key, lang))),
            ],
            onChanged: (v) => setState(() => _species = v ?? _species),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('animal-code'),
            controller: _code,
            decoration: InputDecoration(
              labelText: context.tr('Kode Hewan *', 'Animal Code *'),
              hintText: context.tr('Contoh: SAPI-01 atau KMB-01', 'Example: COW-01 or GOAT-01'),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: context.tr('Bobot (kg)', 'Weight (kg)')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: context.tr('Harga (Rp)', 'Price (Rp)')),
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
            child: Text(context.tr('Simpan Hewan', 'Save Animal')),
          ),
        ],
      ),
    );
  });
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
  final _shares = TextEditingController();
  final _amount = TextEditingController();
  String _payment = 'paid';
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final lang = context.lang;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('Shohibul Qurban (${widget.animalCode})', 'Qurban Participant (${widget.animalCode})'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('participant-name'),
            controller: _name,
            decoration: InputDecoration(labelText: context.tr('Nama Pekurban *', 'Participant Name *')),
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
                  decoration: InputDecoration(
                    labelText: context.tr('Bagian (maks ${widget.remaining})', 'Shares (max ${widget.remaining})'),
                    hintText: context.tr('Contoh: 1', 'Example: 1'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('participant-amount'),
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: context.tr('Nominal (Rp)', 'Amount (Rp)')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _payment,
            decoration: InputDecoration(labelText: context.tr('Status Pembayaran', 'Payment Status')),
            items: [
              for (final e in _paymentLabels.entries)
                DropdownMenuItem(value: e.key, child: Text(_paymentBadge(e.key, lang).$1)),
            ],
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
            child: Text(context.tr('Simpan Pekurban', 'Save Participant')),
          ),
        ],
      ),
    );
  });
}

class _CouponBatchSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int hijriYear;
  const _CouponBatchSheet({required this.ctx, required this.hijriYear});

  @override
  ConsumerState<_CouponBatchSheet> createState() => _CouponBatchSheetState();
}

class _CouponBatchSheetState extends ConsumerState<_CouponBatchSheet> {
  final _prefix = TextEditingController();
  final _count = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) => mosqueScoped(
    context,
    (context) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('Terbitkan Kupon QR Kurban', 'Issue Qurban QR Coupons'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('coupon-prefix'),
            controller: _prefix,
            decoration: InputDecoration(
              labelText: context.tr('Nama Penerima / Label Kelompok *', 'Recipient Name / Group Label *'),
              hintText: context.tr('Contoh: Warga Sekitar Masjid', 'Example: Local Residents'),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('coupon-count'),
            controller: _count,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: context.tr('Jumlah Kupon (1 hingga 200)', 'Number of Coupons (1 to 200)'),
              hintText: context.tr('Contoh: 10', 'Example: 10'),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
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
            child: Text(context.tr('Terbitkan Kupon QR', 'Issue QR Coupons')),
          ),
        ],
      ),
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
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final c = widget.coupon;
    final lang = context.lang;
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
                    Text(
                      context.tr('KUPON DISTRIBUSI KURBAN', 'QURBAN DISTRIBUTION COUPON'),
                      style: const TextStyle(color: BrandColors.goldText, fontWeight: FontWeight.w700, fontSize: 11.5),
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
                        final path = await saveBoundaryPng(_key, 'kupon-${c['code']}.png', lang: lang);
                        if (context.mounted) {
                          showSnack(
                            context,
                            lang == AppLanguage.en ? 'Coupon PNG saved: $path' : 'Kupon PNG tersimpan: $path',
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              icon: const Icon(Icons.image_outlined),
              label: Text(context.tr('Simpan Kartu Kupon PNG', 'Save Coupon Card PNG')),
            ),
          ],
        ),
      ),
    );
  });
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  bool _popped = false;

  @override
  Widget build(BuildContext context) => mosqueScoped(
    context,
    (context) => Scaffold(
      appBar: AppBar(title: Text(context.tr('Pindai QR Kupon', 'Scan Coupon QR')), centerTitle: true),
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
          tooltip: context.tr('Tahun sebelumnya', 'Previous year'),
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(year - 1),
        ),
        Expanded(
          child: Text(
            context.tr('Tahun $year H', 'Year $year AH'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        IconButton(
          tooltip: context.tr('Tahun berikutnya', 'Next year'),
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onChanged(year + 1),
        ),
      ],
    ),
  );
}
