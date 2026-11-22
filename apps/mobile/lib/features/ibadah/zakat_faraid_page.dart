import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../ui/components.dart';

class ZakatFaraidPage extends StatefulWidget {
  const ZakatFaraidPage({super.key});

  @override
  State<ZakatFaraidPage> createState() => _ZakatFaraidPageState();
}

class _ZakatFaraidPageState extends State<ZakatFaraidPage> {
  int _tab = 0;

  // Zakat Maal & Profesi controllers
  final _goldPriceCtrl = TextEditingController(text: '1500000');
  final _savingsCtrl = TextEditingController(text: '150000000');
  final _goldGramsCtrl = TextEditingController(text: '10');
  final _tradeCtrl = TextEditingController(text: '0');
  final _debtCtrl = TextEditingController(text: '5000000');
  final _monthlyIncomeCtrl = TextEditingController(text: '15000000');
  final _monthlyNeedsCtrl = TextEditingController(text: '3000000');

  // Fitrah & Fidyah controllers
  int _souls = 4;
  final _ricePriceCtrl = TextEditingController(text: '18000');
  int _fidyahDays = 5;
  final _mealCostCtrl = TextEditingController(text: '45000');

  // Faraid state
  final _estateCtrl = TextEditingController(text: '120000000');
  final _funeralDebtCtrl = TextEditingController(text: '0');
  final _wasiatCtrl = TextEditingController(text: '0');
  bool _hasHusband = false;
  int _wivesCount = 1;
  int _sonsCount = 1;
  int _daughtersCount = 1;
  bool _hasFather = true;
  bool _hasMother = true;
  int _brothersCount = 0;
  int _sistersCount = 0;

  @override
  void dispose() {
    _goldPriceCtrl.dispose();
    _savingsCtrl.dispose();
    _goldGramsCtrl.dispose();
    _tradeCtrl.dispose();
    _debtCtrl.dispose();
    _monthlyIncomeCtrl.dispose();
    _monthlyNeedsCtrl.dispose();
    _ricePriceCtrl.dispose();
    _mealCostCtrl.dispose();
    _estateCtrl.dispose();
    _funeralDebtCtrl.dispose();
    _wasiatCtrl.dispose();
    super.dispose();
  }

  double _parseNum(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zakat, Fidyah & Waris'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Zakat Maal', 'Fitrah & Fidyah', 'Waris (Faraid)'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildZakatMaalTab(context),
              1 => _buildFitrahFidyahTab(context),
              _ => _buildFaraidTab(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZakatMaalTab(BuildContext context) {
    final goldPrice = _parseNum(_goldPriceCtrl);
    final maal = calculateZakatMaal(
      cashAndSavings: _parseNum(_savingsCtrl),
      goldGrams: _parseNum(_goldGramsCtrl),
      tradeInventory: _parseNum(_tradeCtrl),
      shortTermDebt: _parseNum(_debtCtrl),
      goldPricePerGram: goldPrice,
    );
    final profesi = calculateZakatProfesiMonthly(
      monthlyIncome: _parseNum(_monthlyIncomeCtrl),
      monthlyNeedsOrDebt: _parseNum(_monthlyNeedsCtrl),
      goldPricePerGram: goldPrice,
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acuan Harga Emas & Nisab (85 Gram)', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('zakat-gold-price'),
                  controller: _goldPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Emas per Gram (Rp)',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  'Batas Nisab Tahunan (85g): ${rupiah(maal.nisabValue.round())}',
                  style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('1. Zakat Maal (Tabungan, Emas & Perniagaan)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('zakat-savings-field'),
                  controller: _savingsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tabungan, Deposito & Kas (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _goldGramsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Emas Simpanan / Investasi (Gram)', suffixText: 'gram'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _tradeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Aset Modal Perdagangan Bersih (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _debtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Utang Jatuh Tempo (Pengurang) (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Harta Bersih Wajib Zakat', style: t.bodyMedium),
                    Text(rupiah(maal.netZakatable.round()), style: t.titleMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      maal.isObligatory ? 'Wajib Zakat Maal (2,5%)' : 'Belum Wajib Zakat',
                      style: t.titleMedium?.copyWith(
                        color: maal.isObligatory ? scheme.primary : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      rupiah(maal.zakatAmount.round()),
                      key: const Key('zakat-maal-output'),
                      style: t.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(maal.explanation, style: t.bodySmall),
              ],
            ),
          ),
        ),
        const SectionHeader('2. Zakat Penghasilan / Profesi Bulanan'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _monthlyIncomeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Penghasilan Kotor Bulanan (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _monthlyNeedsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Kebutuhan Pokok / Cicilan Wajib (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Zakat Penghasilan (2,5%/bulan)', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      rupiah(profesi.zakatAmount.round()),
                      style: t.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(profesi.explanation, style: t.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFitrahFidyahTab(BuildContext context) {
    final res = calculateFitrahAndFidyah(
      soulCount: _souls,
      ricePricePerKg: _parseNum(_ricePriceCtrl),
      fidyahDays: _fidyahDays,
      fidyahMealCostPerDay: _parseNum(_mealCostCtrl),
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const SectionHeader('Zakat Fitrah (2,5 kg / 3,5 Liter Beras per Jiwa)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Jumlah Jiwa Keluarga', style: t.titleMedium)),
                    IconButton(
                      tooltip: 'Kurangi jiwa',
                      onPressed: _souls <= 1 ? null : () => setState(() => _souls--),
                      icon: const Icon(MoeslimIcons.minusLingkar),
                    ),
                    Text('$_souls jiwa', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                      key: const Key('fitrah-add-soul'),
                      tooltip: 'Tambah jiwa',
                      onPressed: () => setState(() => _souls++),
                      icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ricePriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Beras Konsumsi per Kg (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                Text('Total Beras: ${res.riceKgTotal.toStringAsFixed(1)} kg beras', style: t.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Setara Uang: ${rupiah(res.fitrahMoneyTotal.round())}',
                  key: const Key('fitrah-money-output'),
                  style: t.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('Kalkulator Fidyah Puasa'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Jumlah Hari Utang Puasa (Fidyah)', style: t.titleMedium)),
                    IconButton(
                      tooltip: 'Kurangi hari fidyah',
                      onPressed: _fidyahDays <= 0 ? null : () => setState(() => _fidyahDays--),
                      icon: const Icon(MoeslimIcons.minusLingkar),
                    ),
                    Text('$_fidyahDays hari', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                      tooltip: 'Tambah hari fidyah',
                      onPressed: () => setState(() => _fidyahDays++),
                      icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _mealCostCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Biaya 1 Porsi Makan Layak / Hari (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                Text(
                  'Total Fidyah ($_fidyahDays hari): ${rupiah(res.fidyahMoneyTotal.round())}',
                  style: t.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fidyah wajib bagi lansia renta, sakit menahun yang tidak ada harapan sembuh, atau kondisi uzur syar\'i dengan memberi makan 1 orang miskin per hari puasa yang ditinggalkan (QS. Al-Baqarah: 184).',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaraidTab(BuildContext context) {
    final result = computeFaraid(
      FaraidInput(
        grossEstate: _parseNum(_estateCtrl),
        funeralCost: _parseNum(_funeralDebtCtrl),
        bequestRequested: _parseNum(_wasiatCtrl),
        hasHusband: _hasHusband,
        wivesCount: _hasHusband ? 0 : _wivesCount,
        sonsCount: _sonsCount,
        daughtersCount: _daughtersCount,
        hasFather: _hasFather,
        hasMother: _hasMother,
        fullBrothersCount: _brothersCount,
        fullSistersCount: _sistersCount,
      ),
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget counterRow(String label, int val, ValueChanged<int> onChanged, {int max = 10, Key? plusKey}) {
      return Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: 'Kurangi $label',
            onPressed: val <= 0 ? null : () => onChanged(val - 1),
            icon: const Icon(MoeslimIcons.minusLingkar),
          ),
          Text('$val', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            key: plusKey,
            tooltip: 'Tambah $label',
            onPressed: val >= max ? null : () => onChanged(val + 1),
            icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Harta Peninggalan Pewaris (Tirkah)', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('faraid-estate-field'),
                  controller: _estateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Harta Kotor Pewaris (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _funeralDebtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Biaya Jenazah & Utang Pewaris (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _wasiatCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Wasiat (Maks. 1/3 = ${rupiah(result.maxAllowedBequest.round())})',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  'Harta Bersih Siap Waris: ${rupiah(result.netInheritableEstate.round())}',
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status Masalah: ${result.caseType}',
                  key: const Key('faraid-case-type'),
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2. Pilih Ahli Waris yang Masih Hidup', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Meninggalkan Suami'),
                  value: _hasHusband,
                  onChanged: (v) => setState(() {
                    _hasHusband = v;
                    if (v) _wivesCount = 0;
                  }),
                ),
                if (!_hasHusband)
                  counterRow('Jumlah Istri (0–4)', _wivesCount, (v) => setState(() => _wivesCount = v), max: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ayah Kandung Masih Hidup'),
                  value: _hasFather,
                  onChanged: (v) => setState(() => _hasFather = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ibu Kandung Masih Hidup'),
                  value: _hasMother,
                  onChanged: (v) => setState(() => _hasMother = v),
                ),
                counterRow(
                  'Anak Laki-laki',
                  _sonsCount,
                  (v) => setState(() => _sonsCount = v),
                  plusKey: const Key('faraid-add-son'),
                ),
                counterRow('Anak Perempuan', _daughtersCount, (v) => setState(() => _daughtersCount = v)),
                counterRow('Saudara Laki-laki Kandung', _brothersCount, (v) => setState(() => _brothersCount = v)),
                counterRow('Saudara Perempuan Kandung', _sistersCount, (v) => setState(() => _sistersCount = v)),
              ],
            ),
          ),
        ),
        const SectionHeader('3. Hasil Perhitungan Faraid'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rincian Bagian (${result.caseType})',
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(result.caseExplanation, style: t.bodySmall),
                const Divider(height: 20),
                for (final s in result.shares)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${s.heirName} (${s.count} orang) · ${s.portionLabel}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: s.isBlocked ? scheme.outline : null,
                                ),
                              ),
                            ),
                            Text(
                              rupiah(s.totalAmount.round()),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: s.isBlocked ? scheme.outline : scheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (s.count > 1 && !s.isBlocked)
                          Text(
                            'Per orang: ${rupiah(s.perPersonAmount.round())} (${(s.totalShareRatio * 100).toStringAsFixed(1)}% total)',
                            style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        Text(s.legalReason, style: t.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
