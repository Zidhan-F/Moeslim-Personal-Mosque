import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const _idrDenominations = [100000, 50000, 20000, 10000, 5000, 2000, 1000, 500];

/// Simpan gambar PNG dari widget di dalam [RepaintBoundary] ke direktori dokumen perangkat.
Future<String> saveBoundaryPng(GlobalKey boundaryKey, String filename) async {
  final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('Pratinjau belum siap dirender.');
  }
  final image = await boundary.toImage(pixelRatio: 2.5);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    throw StateError('Gagal mengonversi gambar PNG.');
  }
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file.path;
}

/// Laporan Kas Jumat 1-Klik: PDF mading, Poster PNG, dan Salin Teks WhatsApp.
class FridayReportPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const FridayReportPage({super.key, required this.ctx});

  @override
  ConsumerState<FridayReportPage> createState() => _FridayReportPageState();
}

class _FridayReportPageState extends ConsumerState<FridayReportPage> {
  final _posterKey = GlobalKey();
  DateTime _friday = _latestFriday(DateTime.now());
  bool _saving = false;

  static DateTime _latestFriday(DateTime now) {
    final d = DateUtils.dateOnly(now);
    final diff = (d.weekday - DateTime.friday + 7) % 7;
    return d.subtract(Duration(days: diff));
  }

  Future<void> _copyWa(Map<String, dynamic> r) async {
    final text = (r['whatsapp_text'] as String?) ?? '';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showSnack(context, 'Teks Laporan Kas Jumat disalin. Siap tempel ke WhatsApp.');
  }

  Future<void> _savePng(Map<String, dynamic> r) async {
    setState(() => _saving = true);
    try {
      final path = await saveBoundaryPng(_posterKey, 'poster-kas-jumat-${r['to']}.png');
      if (mounted) showSnack(context, 'Poster tersimpan: $path');
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _savePdf(Map<String, dynamic> r) async {
    setState(() => _saving = true);
    try {
      final doc = pw.Document();
      final funds = (r['funds'] as List? ?? const []).cast<Map>();
      final topIn = (r['top_in'] as List? ?? const []).cast<Map>();
      final topOut = (r['top_out'] as List? ?? const []).cast<Map>();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0A6B4F),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN KAS JUMAT',
                      style: pw.TextStyle(color: PdfColors.amber100, fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${r['mosque_name'] ?? widget.ctx.name}',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Periode: ${r['from']} s.d. ${r['to']}',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF0A6B4F)),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                headers: ['Uraian', 'Nominal'],
                data: [
                  ['Saldo Awal Pekan', rupiah((r['opening_balance'] as num?) ?? 0)],
                  ['Total Pemasukan', '+ ${rupiah((r['total_in'] as num?) ?? 0)}'],
                  ['Total Pengeluaran', '- ${rupiah((r['total_out'] as num?) ?? 0)}'],
                  ['Saldo Akhir Kas', rupiah((r['closing_balance'] as num?) ?? 0)],
                ],
              ),
              if (funds.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text('Rincian Saldo per Dana', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  headers: ['Dana', 'Status', 'Saldo'],
                  data: [
                    for (final f in funds)
                      [
                        '${f['name']}',
                        f['restricted'] == true ? 'Terikat' : 'Umum',
                        rupiah((f['balance'] as num?) ?? 0),
                      ],
                  ],
                ),
              ],
              if (topIn.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text('Pemasukan Utama Pekan Ini', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                for (final t in topIn)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('${t['date']} • ${t['description']}', style: const pw.TextStyle(fontSize: 10))),
                      pw.Text(rupiah((t['amount'] as num?) ?? 0), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
              ],
              if (topOut.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Text('Pengeluaran Utama Pekan Ini', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                for (final t in topOut)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('${t['date']} • ${t['description']}', style: const pw.TextStyle(fontSize: 10))),
                      pw.Text(rupiah((t['amount'] as num?) ?? 0), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
              ],
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey400),
              pw.Text(
                'Jazakumullahu khairan katsiran atas infaq dan amanah jamaah. Dicetak melalui Moeslim Mosque.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/laporan-kas-jumat-${r['to']}.pdf');
      await file.writeAsBytes(await doc.save());
      if (mounted) showSnack(context, 'PDF Mading tersimpan: ${file.path}');
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = (widget.ctx.id, isoDate(_friday));
    final report = ref.watch(fridayReportProvider(key));
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Kas Jumat'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fridayReportProvider(key).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(MoeslimIcons.kalender, color: BrandColors.emerald),
                title: const Text('Tanggal Jumat'),
                subtitle: Text(longDate(_friday)),
                trailing: TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 7)),
                      initialDate: _friday,
                    );
                    if (d != null) setState(() => _friday = d);
                  },
                  child: const Text('Ubah'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AsyncBody(
              value: report,
              onRetry: () => ref.invalidate(fridayReportProvider(key)),
              data: (r) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RepaintBoundary(
                    key: _posterKey,
                    child: _FridayPosterCard(report: r, fallbackName: widget.ctx.name),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    key: const Key('friday-copy-wa'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
                    onPressed: _saving ? null : () => _copyWa(r),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Salin Teks WhatsApp'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('friday-save-pdf'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                          onPressed: _saving ? null : () => _savePdf(r),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('PDF Mading'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('friday-save-png'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                          onPressed: _saving ? null : () => _savePng(r),
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Poster PNG'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FridayPosterCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final String fallbackName;
  const _FridayPosterCard({required this.report, required this.fallbackName});

  @override
  Widget build(BuildContext context) {
    final funds = (report['funds'] as List? ?? const []).cast<Map>();
    final opening = (report['opening_balance'] as num?) ?? 0;
    final totalIn = (report['total_in'] as num?) ?? 0;
    final totalOut = (report['total_out'] as num?) ?? 0;
    final closing = (report['closing_balance'] as num?) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: BrandColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrandColors.emerald.withValues(alpha: .22), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [BrandColors.dark, BrandColors.emerald],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LAPORAN KAS JUMAT',
                  style: TextStyle(color: BrandColors.gold, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report['mosque_name'] ?? fallbackName}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Periode ${report['from']} s.d. ${report['to']}',
                  style: const TextStyle(color: BrandColors.cream, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: const TextStyle(color: BrandColors.deep, fontSize: 13.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PosterRow('Saldo Awal', rupiah(opening), color: BrandColors.deep),
                  const SizedBox(height: 6),
                  _PosterRow('Pemasukan Pekan Ini', '+ ${rupiah(totalIn)}', color: MosqueColors.income),
                  const SizedBox(height: 6),
                  _PosterRow('Pengeluaran Pekan Ini', '- ${rupiah(totalOut)}', color: MosqueColors.expense),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: BrandColors.emerald,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Saldo Akhir Kas',
                            style: TextStyle(color: BrandColors.cream, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          rupiah(closing),
                          key: const Key('friday-closing-balance'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (funds.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'RINCIAN SALDO DANA',
                      style: TextStyle(
                        color: BrandColors.dark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final f in funds)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: _PosterRow('${f['name']}', rupiah((f['balance'] as num?) ?? 0), color: BrandColors.deep),
                      ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Jazakumullahu khairan katsiran atas infaq dan amanah jamaah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: BrandColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PosterRow(this.label, this.value, {required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(
        value,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    ],
  );
}

/// Hitung Kotak Amal Multi-Saksi: input pecahan IDR + 2 saksi -> entri kas immutable idempoten.
class DonationBoxCountPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const DonationBoxCountPage({super.key, required this.ctx});

  @override
  ConsumerState<DonationBoxCountPage> createState() => _DonationBoxCountPageState();
}

class _DonationBoxCountPageState extends ConsumerState<DonationBoxCountPage> {
  int _tab = 0;
  String _idempotencyKey = MasjidApi.newIdempotencyKey();
  final _boxName = TextEditingController(text: 'Kotak Amal Jumat Utama');
  final _witness1 = TextEditingController();
  final _witness2 = TextEditingController();
  final _notes = TextEditingController();
  final Map<int, TextEditingController> _qty = {for (final d in _idrDenominations) d: TextEditingController(text: '0')};
  DateTime _date = DateTime.now();
  Map<String, dynamic>? _setup;
  int? _fundId, _accountId, _categoryId;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(masjidApiProvider).financeSetup(widget.ctx.id).then((s) {
      if (!mounted) return;
      final funds = (s['funds'] as List).cast<Map>();
      final accounts = (s['accounts'] as List).cast<Map>();
      final cats = (s['categories'] as List).cast<Map>().where((c) => c['flow'] == 'in').toList();
      setState(() {
        _setup = s;
        _fundId = funds.isNotEmpty ? funds.first['id'] as int : null;
        _accountId = accounts.isNotEmpty ? accounts.first['id'] as int : null;
        _categoryId = cats.isNotEmpty ? cats.first['id'] as int : null;
      });
    }, onError: (e) {
      if (mounted) setState(() => _error = '$e');
    });
  }

  @override
  void dispose() {
    _boxName.dispose();
    _witness1.dispose();
    _witness2.dispose();
    _notes.dispose();
    for (final c in _qty.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _countOf(int denom) => int.tryParse(_qty[denom]!.text.trim()) ?? 0;

  int get _total => _idrDenominations.fold<int>(0, (sum, d) => sum + d * _countOf(d));

  void _step(int denom, int delta) {
    final next = (_countOf(denom) + delta).clamp(0, 100000);
    setState(() => _qty[denom]!.text = '$next');
  }

  Future<void> _submit() async {
    if (_total <= 0) {
      setState(() => _error = 'Isi minimal satu pecahan uang kotak amal.');
      return;
    }
    if (_witness1.text.trim().isEmpty || _witness2.text.trim().isEmpty) {
      setState(() => _error = 'Nama Saksi 1 dan Saksi 2 wajib diisi untuk akuntabilitas.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final denoms = <String, int>{
        for (final d in _idrDenominations)
          if (_countOf(d) > 0) '$d': _countOf(d),
      };
      await ref.read(masjidApiProvider).createDonationBoxCount(
        widget.ctx.id,
        {
          'box_name': _boxName.text.trim(),
          'date': isoDate(_date),
          'fund_id': _fundId,
          'cash_account_id': _accountId,
          if (_categoryId != null) 'category_id': _categoryId,
          'witness_1_name': _witness1.text.trim(),
          'witness_2_name': _witness2.text.trim(),
          if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
          'denominations': denoms,
        },
        idempotencyKey: _idempotencyKey,
      );
      ref.invalidate(donationBoxCountsProvider(widget.ctx.id));
      ref.invalidate(transactionsProvider);
      ref.invalidate(financeSummaryProvider);
      ref.invalidate(fridayReportProvider);
      ref.invalidate(dashboardProvider(widget.ctx.id));
      if (!mounted) return;
      showSnack(context, 'Hitungan kotak amal (${rupiah(_total)}) dicatat ke buku kas.');
      setState(() {
        _idempotencyKey = MasjidApi.newIdempotencyKey();
        for (final c in _qty.values) {
          c.text = '0';
        }
        _notes.clear();
        _tab = 1;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(donationBoxCountsProvider(widget.ctx.id));
    final funds = ((_setup?['funds'] as List?) ?? const []).cast<Map>();
    final accounts = ((_setup?['accounts'] as List?) ?? const []).cast<Map>();
    final cats = ((_setup?['categories'] as List?) ?? const []).cast<Map>().where((c) => c['flow'] == 'in').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Hitung Kotak Amal'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          PillTabs(
            labels: const ['Hitung Baru', 'Riwayat Hitungan'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 12),
          if (_tab == 0)
            _setup == null && _error == null
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        key: const Key('box-name'),
                        controller: _boxName,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kotak Amal *',
                          prefixIcon: Icon(MoeslimIcons.saldo),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('witness-1'),
                              controller: _witness1,
                              decoration: const InputDecoration(
                                labelText: 'Saksi 1 *',
                                prefixIcon: Icon(MoeslimIcons.profil),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              key: const Key('witness-2'),
                              controller: _witness2,
                              decoration: const InputDecoration(
                                labelText: 'Saksi 2 *',
                                prefixIcon: Icon(MoeslimIcons.profil),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _fundId,
                              decoration: const InputDecoration(labelText: 'Dana'),
                              items: [
                                for (final f in funds)
                                  DropdownMenuItem(value: f['id'] as int, child: Text('${f['name']}')),
                              ],
                              onChanged: (v) => setState(() => _fundId = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _accountId,
                              decoration: const InputDecoration(labelText: 'Akun Kas'),
                              items: [
                                for (final a in accounts)
                                  DropdownMenuItem(value: a['id'] as int, child: Text('${a['name']}')),
                              ],
                              onChanged: (v) => setState(() => _accountId = v),
                            ),
                          ),
                        ],
                      ),
                      if (cats.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int?>(
                          initialValue: _categoryId,
                          decoration: const InputDecoration(labelText: 'Kategori Pemasukan'),
                          items: [
                            for (final c in cats) DropdownMenuItem(value: c['id'] as int, child: Text('${c['name']}')),
                          ],
                          onChanged: (v) => setState(() => _categoryId = v),
                        ),
                      ],
                      const SizedBox(height: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDate: _date,
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Tanggal Hitung', prefixIcon: Icon(MoeslimIcons.kalender)),
                          child: Text(longDate(_date)),
                        ),
                      ),
                      const SectionHeader('Pecahan Uang (Lembar / Koin)'),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final d in _idrDenominations)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 86,
                                      child: Text(rupiah(d), style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                    IconButton(
                                      tooltip: 'Kurangi $d',
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => _step(d, -1),
                                    ),
                                    SizedBox(
                                      width: 62,
                                      child: TextField(
                                        key: Key('denom-$d'),
                                        controller: _qty[d],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Tambah $d',
                                      icon: const Icon(Icons.add_circle_outline, color: BrandColors.emerald),
                                      onPressed: () => _step(d, 1),
                                    ),
                                    Expanded(
                                      child: Text(
                                        rupiah(d * _countOf(d)),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notes,
                        decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: BrandColors.emerald.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text('Total Hitungan', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Text(
                              rupiah(_total),
                              key: const Key('box-total'),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        key: const Key('save-box-count'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
                        onPressed: _busy ? null : _submit,
                        icon: const Icon(MoeslimIcons.check),
                        label: const Text('Catat ke Buku Kas'),
                      ),
                    ],
                  )
          else
            AsyncBody(
              value: history,
              onRetry: () => ref.invalidate(donationBoxCountsProvider(widget.ctx.id)),
              data: (list) => list.isEmpty
                  ? const EmptyState(MoeslimIcons.saldo, 'Belum ada riwayat hitungan kotak amal')
                  : Column(
                      children: [
                        for (final item in list)
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: BrandColors.emerald,
                                foregroundColor: Colors.white,
                                child: Icon(MoeslimIcons.saldo),
                              ),
                              title: Text('${item['box_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                '${item['date']} • Saksi: ${item['witness_1_name']} & ${item['witness_2_name']}'
                                '${(item['transaction'] as Map?)?['reference_no'] != null ? '\nRef: ${(item['transaction'] as Map)['reference_no']}' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: Text(
                                rupiah((item['total_amount'] as num?) ?? 0),
                                style: const TextStyle(fontWeight: FontWeight.w800, color: MosqueColors.income),
                              ),
                              onTap: () {
                                final txId = (item['transaction'] as Map?)?['id'] as int?;
                                if (txId != null) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => ReceiptSheet(ctx: widget.ctx, txId: txId),
                                  );
                                }
                              },
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

/// Kuitansi Donasi Digital bernomor resmi + QR verifikasi publik + ekspor PDF/PNG/WA.
class ReceiptSheet extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  final int txId;
  const ReceiptSheet({super.key, required this.ctx, required this.txId});

  @override
  ConsumerState<ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends ConsumerState<ReceiptSheet> {
  final _cardKey = GlobalKey();
  Map<String, dynamic>? _receipt;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final data = await ref.read(masjidApiProvider).transactionReceipt(widget.ctx.id, widget.txId);
      if (mounted) setState(() => _receipt = data);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _copyWa(Map<String, dynamic> r) async {
    final text = [
      '*KUITANSI DONASI RESMI*',
      '*${r['mosque_name']}*',
      'No: ${r['receipt_no']}',
      'Tanggal: ${r['date']}',
      'Diterima dari: ${r['donor_name']}',
      'Nominal: *${rupiah((r['amount'] as num?) ?? 0)}*',
      'Dana: ${r['fund_name'] ?? '-'}',
      'Keterangan: ${r['description']}',
      '',
      'Verifikasi keaslian: ${r['verify_url']}',
      'Jazakumullahu khairan katsiran.',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showSnack(context, 'Teks kuitansi disalin. Siap kirim ke WhatsApp donatur.');
  }

  Future<void> _savePng(Map<String, dynamic> r) async {
    setState(() => _saving = true);
    try {
      final path = await saveBoundaryPng(_cardKey, 'kuitansi-${r['receipt_no']}.png');
      if (mounted) showSnack(context, 'Kuitansi PNG tersimpan: $path');
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _savePdf(Map<String, dynamic> r) async {
    setState(() => _saving = true);
    try {
      final doc = pw.Document();
      final verifyUrl = '${r['verify_url'] ?? ''}';
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(22),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0A6B4F),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('KUITANSI DONASI RESMI', style: pw.TextStyle(color: PdfColors.amber100, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Text('${r['mosque_name']}', style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('No. ${r['receipt_no']}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text('Telah diterima dari: ${r['donor_name']}', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 6),
              pw.Text(rupiah((r['amount'] as num?) ?? 0), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Dana: ${r['fund_name'] ?? '-'}', style: const pw.TextStyle(fontSize: 10.5)),
              pw.Text('Tanggal: ${r['date']}', style: const pw.TextStyle(fontSize: 10.5)),
              pw.Text('Keterangan: ${r['description']}', style: const pw.TextStyle(fontSize: 10.5)),
              pw.SizedBox(height: 16),
              if (verifyUrl.isNotEmpty)
                pw.Row(
                  children: [
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: verifyUrl, width: 72, height: 72),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Text(
                        'Pindai kode QR untuk memverifikasi keaslian kuitansi secara daring.\n$verifyUrl',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/kuitansi-${r['receipt_no']}.pdf');
      await file.writeAsBytes(await doc.save());
      if (mounted) showSnack(context, 'Kuitansi PDF tersimpan: ${file.path}');
    } catch (e) {
      if (mounted) showSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _receipt;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: const Text('Coba lagi')),
                ],
              )
            : r == null
                ? const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RepaintBoundary(
                        key: _cardKey,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: BrandColors.emerald.withValues(alpha: .25)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                color: BrandColors.dark,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'KUITANSI DONASI DIGITAL',
                                            style: TextStyle(
                                              color: BrandColors.gold,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Text(
                                            '${r['mosque_name']}',
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                          ),
                                          Text(
                                            'No. ${r['receipt_no']}',
                                            style: const TextStyle(color: BrandColors.cream, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: r['status'] == 'reversed' ? MosqueColors.expense : BrandColors.emerald,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        r['status'] == 'reversed' ? 'Dibatalkan' : 'Terverifikasi',
                                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: DefaultTextStyle(
                                  style: const TextStyle(color: BrandColors.deep, fontSize: 13),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('Telah diterima dari', style: TextStyle(fontSize: 11.5, color: BrandColors.textMuted)),
                                      Text('${r['donor_name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 8),
                                      Text(
                                        rupiah((r['amount'] as num?) ?? 0),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: BrandColors.dark,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _PosterRow('Tanggal', '${r['date']}', color: BrandColors.deep),
                                      const SizedBox(height: 4),
                                      _PosterRow('Dana', '${r['fund_name'] ?? '-'}', color: BrandColors.deep),
                                      const SizedBox(height: 4),
                                      _PosterRow('Keterangan', '${r['description']}', color: BrandColors.deep),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: BrandColors.cream,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              color: Colors.white,
                                              child: QrImageView(
                                                key: const Key('receipt-qr'),
                                                data: '${r['verify_url'] ?? r['receipt_token']}',
                                                size: 76,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text(
                                                'Pindai QR untuk verifikasi keaslian kuitansi dari buku kas resmi masjid.',
                                                style: TextStyle(fontSize: 11.5, color: BrandColors.textMuted),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        key: const Key('receipt-copy-wa'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
                        onPressed: _saving ? null : () => _copyWa(r),
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Salin Teks WA Donatur'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const Key('receipt-save-pdf'),
                              onPressed: _saving ? null : () => _savePdf(r),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: const Text('Simpan PDF'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const Key('receipt-save-png'),
                              onPressed: _saving ? null : () => _savePng(r),
                              icon: const Icon(Icons.image_outlined),
                              label: const Text('Simpan PNG'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
