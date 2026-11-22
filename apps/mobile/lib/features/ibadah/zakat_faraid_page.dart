import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../ui/components.dart';

class ZakatFaraidPage extends StatefulWidget {
  const ZakatFaraidPage({super.key});

  @override
  State<ZakatFaraidPage> createState() => _ZakatFaraidPageState();
}

class _ZakatFaraidPageState extends State<ZakatFaraidPage> {
  int _tab = 0;

  // Zakat Maal & Profesi controllers (kosong secara default; contoh tampil sebagai hintText)
  final _goldPriceCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  final _goldGramsCtrl = TextEditingController();
  final _tradeCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();
  final _monthlyIncomeCtrl = TextEditingController();
  final _monthlyNeedsCtrl = TextEditingController();

  // Fitrah & Fidyah controllers
  int _souls = 1;
  final _ricePriceCtrl = TextEditingController();
  int _fidyahDays = 0;
  final _mealCostCtrl = TextEditingController();

  // Faraid state
  final _estateCtrl = TextEditingController();
  final _funeralDebtCtrl = TextEditingController();
  final _wasiatCtrl = TextEditingController();
  bool _hasHusband = false;
  int _wivesCount = 0;
  int _sonsCount = 0;
  int _daughtersCount = 0;
  bool _hasFather = false;
  bool _hasMother = false;
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

  void _resetActiveTab() {
    setState(() {
      if (_tab == 0) {
        _goldPriceCtrl.clear();
        _savingsCtrl.clear();
        _goldGramsCtrl.clear();
        _tradeCtrl.clear();
        _debtCtrl.clear();
        _monthlyIncomeCtrl.clear();
        _monthlyNeedsCtrl.clear();
      } else if (_tab == 1) {
        _souls = 1;
        _ricePriceCtrl.clear();
        _fidyahDays = 0;
        _mealCostCtrl.clear();
      } else {
        _estateCtrl.clear();
        _funeralDebtCtrl.clear();
        _wasiatCtrl.clear();
        _hasHusband = false;
        _wivesCount = 0;
        _sonsCount = 0;
        _daughtersCount = 0;
        _hasFather = false;
        _hasMother = false;
        _brothersCount = 0;
        _sistersCount = 0;
      }
    });
  }

  InputDecoration _numDecoration(
    BuildContext context, {
    required String label,
    required String example,
    String? prefixText,
    String? suffixText,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: context.tr('Contoh: $example', 'Example: $example'),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixText: prefixText,
        suffixText: suffixText,
      );

  Widget _metricRow(BuildContext context, String label, String value) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(label, style: t.bodyMedium)),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _highlightResultBox(
    BuildContext context, {
    required String label,
    required String value,
    required bool emphasized,
    Key? valueKey,
  }) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: emphasized
            ? scheme.primary.withValues(alpha: .10)
            : scheme.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: emphasized ? scheme.primary.withValues(alpha: .35) : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: t.labelLarge?.copyWith(
              color: emphasized ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              key: valueKey,
              style: t.headlineSmall?.copyWith(
                color: emphasized ? scheme.primary : scheme.onSurface,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _faraidCaseTypeEn(String raw) {
    if (raw == 'Normal / Seimbang') return 'Normal / Balanced';
    if (raw == 'Belum Ada Ahli Waris') return 'No Heirs Selected';
    if (raw.startsWith('Kasus \'Aul')) return raw.replaceFirst('Kasus \'Aul', '\'Awl Case');
    if (raw == 'Kasus Radd') return 'Radd Case';
    if (raw == 'Hanya Pasangan (Sisa ke Baitul Maal / Kerabat)') {
      return 'Spouse Only (Remainder to Public Treasury / Relatives)';
    }
    if (raw == 'Ashabul Furudh & Ashabah') return 'Fixed Shares & Residuary (Asabah)';
    return raw;
  }

  static String _faraidCaseExplanationEn(String raw) {
    if (raw.contains('Pilih minimal satu ahli waris')) {
      return 'Select at least one surviving heir to calculate the Faraid inheritance distribution.';
    }
    if (raw.contains('diterapkan \'Aul')) {
      return 'Total fixed shares exceed 100%, so \'Awl is applied: each heir\'s share denominator is proportionally increased.';
    }
    if (raw.contains('dikembalikan (Radd)')) {
      return 'There is a remaining estate after fixed shares and no residuary heir (Asabah). The remainder is returned (Radd) proportionally to non-spouse blood heirs.';
    }
    if (raw.contains('kerabat Dzawil Arham')) {
      return 'The spouse receives their fixed share, while the remaining estate goes to extended relatives (Dhawil Arham) or the public treasury (Bayt al-Mal).';
    }
    return 'Distribution follows Quranic fixed shares (Ashabul Furudh) and residuary shares (Asabah) proportionally.';
  }

  static String _faraidHeirNameEn(String raw, int count) => switch (raw) {
        'Suami' => 'Husband',
        'Istri' => count == 1 ? 'Wife' : 'Wives',
        'Ibu' => 'Mother',
        'Ayah' => 'Father',
        'Anak Laki-laki' => count == 1 ? 'Son' : 'Sons',
        'Anak Perempuan' => count == 1 ? 'Daughter' : 'Daughters',
        'Saudara Laki-laki Kandung' => count == 1 ? 'Full Brother' : 'Full Brothers',
        'Saudara Perempuan Kandung' => count == 1 ? 'Full Sister' : 'Full Sisters',
        _ => raw,
      };

  static String _faraidPortionLabelEn(String raw) => raw
      .replaceAll('(\'Aul dari ', '(\'Awl from ')
      .replaceAll('Ashabul Furudh', 'Fixed Share')
      .replaceAll('Mahjub (Terhalang)', 'Blocked (Mahjub)')
      .replaceAll('Ashabah Binafsih', 'Residuary (Asabah)')
      .replaceAll('Ashabah bil Ghair', 'Residuary with Male')
      .replaceAll('Ashabah Ma\'al Ghair', 'Residuary with Daughters')
      .replaceAll('Ashabah', 'Residuary');

  static String _faraidLegalReasonEn(String raw) {
    final hasRadd = raw.contains('Ditambah pengembalian sisa harta (Radd).');
    final base = raw.replaceAll(' Ditambah pengembalian sisa harta (Radd).', '');
    String en;
    if (base.startsWith('Suami mendapat 1/4')) {
      en = 'Husband receives 1/4 because the deceased left children/descendants (Quran 4:12).';
    } else if (base.startsWith('Suami mendapat 1/2')) {
      en = 'Husband receives 1/2 because the deceased left no children/descendants (Quran 4:12).';
    } else if (base.startsWith('Istri mendapat 1/8')) {
      en = 'Wife receives 1/8 (shared equally if more than one) because the deceased left descendants (Quran 4:12).';
    } else if (base.startsWith('Istri mendapat 1/4')) {
      en = 'Wife receives 1/4 because the deceased left no descendants (Quran 4:12).';
    } else if (base.startsWith('Ibu mendapat 1/6')) {
      en = 'Mother receives 1/6 because the deceased left descendants or 2+ siblings (Quran 4:11).';
    } else if (base.startsWith('Ibu mendapat 1/3')) {
      en = 'Mother receives 1/3 because the deceased left no descendants and fewer than two siblings (Quran 4:11).';
    } else if (base.startsWith('Ayah mendapat bagian pasti 1/6')) {
      en = 'Father receives a fixed 1/6 share because there is a surviving son (Quran 4:11).';
    } else if (base.startsWith('Ayah mendapat 1/6 ditambah')) {
      en = 'Father receives 1/6 plus the remainder (Asabah) because there are only daughters and no sons.';
    } else if (base.startsWith('Ayah menjadi Ashabah')) {
      en = 'Father inherits as residuary heir (Asabah) taking the remainder after fixed shares because there are no descendants.';
    } else if (base.startsWith('Anak perempuan tunggal')) {
      en = 'An only daughter without sons receives 1/2 of the estate (Quran 4:11).';
    } else if (base.startsWith('Dua atau lebih anak perempuan')) {
      en = 'Two or more daughters without sons share 2/3 equally (Quran 4:11).';
    } else if (base.startsWith('Anak laki-laki menjadi Ashabah')) {
      en = 'Sons inherit as residuary heirs with daughters in a 2:1 ratio (Quran 4:11).';
    } else if (base.startsWith('Anak laki-laki mewarisi seluruh')) {
      en = 'Sons inherit the entire remaining estate as residuary heirs (Asabah).';
    } else if (base.startsWith('Anak perempuan menjadi Ashabah')) {
      en = 'Daughters inherit as residuary heirs alongside sons at a 1:2 share ratio (Quran 4:11).';
    } else if (base.startsWith('Saudara perempuan kandung menjadi Ashabah Ma\'al Ghair')) {
      en = 'Full sisters inherit the remainder alongside daughters (Asabah Ma\'al Ghair).';
    } else if (base.startsWith('Saudara perempuan kandung tunggal')) {
      en = 'An only full sister (kalalah, with no children or father) receives 1/2 (Quran 4:176).';
    } else if (base.startsWith('Dua atau lebih saudara perempuan kandung')) {
      en = 'Two or more full sisters (kalalah) share 2/3 equally (Quran 4:176).';
    } else if (base.startsWith('Saudara laki-laki kandung mewarisi')) {
      en = 'Full brothers inherit the remainder as residuary heirs since there is no father or son (Quran 4:176).';
    } else if (base.startsWith('Saudara perempuan kandung menjadi Ashabah bil Ghair')) {
      en = 'Full sisters inherit alongside full brothers in a 1:2 share ratio.';
    } else if (base.startsWith('Terhalang (Mahjub Hirman)')) {
      final blocker = base.contains('Anak Laki-laki') ? 'Son' : 'Father';
      en = 'Blocked (Mahjub) from inheriting due to the presence of a surviving $blocker.';
    } else {
      en = base;
    }
    return hasRadd ? '$en Plus proportional return of remainder (Radd).' : en;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Zakat, Fidyah & Waris', 'Zakat, Fidyah & Inheritance')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('zakat-reset-btn'),
            tooltip: context.tr('Kosongkan isian', 'Clear fields'),
            onPressed: _resetActiveTab,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Zakat Maal', 'Wealth Zakat'),
                context.tr('Fitrah & Fidyah', 'Fitrah & Fidyah'),
                context.tr('Waris (Faraid)', 'Inheritance (Faraid)'),
              ],
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
    final hasMaalInput = _savingsCtrl.text.trim().isNotEmpty ||
        _goldGramsCtrl.text.trim().isNotEmpty ||
        _tradeCtrl.text.trim().isNotEmpty ||
        _debtCtrl.text.trim().isNotEmpty;
    final hasProfesiInput =
        _monthlyIncomeCtrl.text.trim().isNotEmpty || _monthlyNeedsCtrl.text.trim().isNotEmpty;
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

    return ListView(
      key: const ValueKey('zakat-maal-list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Acuan Harga Emas & Nisab (85 Gram)', 'Gold Price & Nisab Reference (85 Grams)'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('zakat-gold-price'),
                  controller: _goldPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Harga Emas per Gram (Rp)', 'Gold Price per Gram (IDR)'),
                    example: '1500000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  goldPrice > 0
                      ? context.tr(
                          'Batas Nisab Tahunan (85g): ${rupiah(maal.nisabValue.round())}',
                          'Annual Nisab Threshold (85g): ${rupiah(maal.nisabValue.round())}',
                        )
                      : context.tr(
                          'Batas Nisab Tahunan (85g, acuan Rp1.500.000/g bila kosong): ${rupiah(maal.nisabValue.round())}',
                          'Annual Nisab (85g, ref. Rp1.500.000/g if left blank): ${rupiah(maal.nisabValue.round())}',
                        ),
                  style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr('1. Zakat Maal (Tabungan, Emas & Perniagaan)', '1. Wealth Zakat (Savings, Gold & Trade)'),
        ),
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
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Tabungan, Deposito & Kas (Rp)', 'Savings, Deposits & Cash (IDR)'),
                    example: '150000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _goldGramsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Emas Simpanan / Investasi (Gram)', 'Gold Savings / Investment (Grams)'),
                    example: '10',
                    suffixText: context.tr('gram', 'g'),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _tradeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Aset Modal Perdagangan Bersih (Rp)', 'Net Trade & Business Assets (IDR)'),
                    example: '50000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _debtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Utang Jatuh Tempo (Pengurang) (Rp)', 'Short-Term Debt Deduction (IDR)'),
                    example: '5000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                _metricRow(
                  context,
                  context.tr('Harta Bersih Wajib Zakat', 'Net Zakatable Wealth'),
                  rupiah(maal.netZakatable.round()),
                ),
                const SizedBox(height: 10),
                _highlightResultBox(
                  context,
                  label: maal.isObligatory
                      ? context.tr('Wajib Zakat Maal (2,5%)', 'Wealth Zakat Due (2.5%)')
                      : context.tr('Belum Wajib Zakat Maal', 'Wealth Zakat Not Yet Due'),
                  value: rupiah(maal.zakatAmount.round()),
                  emphasized: maal.isObligatory,
                  valueKey: const Key('zakat-maal-output'),
                ),
                const SizedBox(height: 8),
                Text(
                  !hasMaalInput
                      ? context.tr(
                          'Masukkan nominal harta di atas untuk menghitung zakat maal secara otomatis.',
                          'Enter your asset values above to calculate your wealth zakat automatically.',
                        )
                      : (maal.isObligatory
                          ? context.tr(
                              maal.explanation,
                              'Net wealth meets the 85g gold nisab threshold and 2.5% zakat is due after one lunar year (hawl).',
                            )
                          : context.tr(
                              maal.explanation,
                              'Net wealth is below the 85g gold nisab threshold. Wealth zakat is not obligatory, though voluntary charity is encouraged.',
                            )),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr('2. Zakat Penghasilan / Profesi Bulanan', '2. Monthly Income / Profession Zakat'),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('zakat-income-field'),
                  controller: _monthlyIncomeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Penghasilan Kotor Bulanan (Rp)', 'Gross Monthly Income (IDR)'),
                    example: '15000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _monthlyNeedsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Kebutuhan Pokok / Cicilan Wajib (Rp)', 'Basic Needs / Mandatory Obligations (IDR)'),
                    example: '3000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                _metricRow(
                  context,
                  context.tr('Penghasilan Bersih Bulanan', 'Net Monthly Income'),
                  rupiah(profesi.netZakatable.round()),
                ),
                const SizedBox(height: 10),
                _highlightResultBox(
                  context,
                  label: profesi.isObligatory
                      ? context.tr('Zakat Penghasilan (2,5%/bulan)', 'Income Zakat (2.5%/month)')
                      : context.tr('Belum Wajib Zakat Penghasilan', 'Income Zakat Not Yet Due'),
                  value: rupiah(profesi.zakatAmount.round()),
                  emphasized: profesi.isObligatory,
                  valueKey: const Key('zakat-profesi-output'),
                ),
                const SizedBox(height: 8),
                Text(
                  !hasProfesiInput
                      ? context.tr(
                          'Masukkan penghasilan bulanan Anda untuk menghitung zakat penghasilan (nisab bulanan ${rupiah(profesi.nisabValue.round())}).',
                          'Enter your monthly income above to calculate income zakat (monthly nisab ${rupiah(profesi.nisabValue.round())}).',
                        )
                      : (profesi.isObligatory
                          ? context.tr(
                              profesi.explanation,
                              'Net monthly income meets the monthly nisab (1/12 of 85g gold). You may pay 2.5% income zakat each month.',
                            )
                          : context.tr(
                              profesi.explanation,
                              'Net monthly income is below the monthly nisab threshold (1/12 of 85g gold).',
                            )),
                  style: t.bodySmall,
                ),
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
      key: const ValueKey('fitrah-fidyah-list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SectionHeader(
          context.tr(
            'Zakat Fitrah (2,5 kg / 3,5 Liter Beras per Jiwa)',
            'Zakat al-Fitr (2.5 kg / 3.5 Liters of Rice per Person)',
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(context.tr('Jumlah Jiwa Keluarga', 'Family Members'), style: t.titleMedium)),
                    IconButton(
                      tooltip: context.tr('Kurangi jiwa', 'Decrease people'),
                      onPressed: _souls <= 1 ? null : () => setState(() => _souls--),
                      icon: const Icon(MoeslimIcons.minusLingkar),
                    ),
                    Text(
                      context.tr('$_souls jiwa', '$_souls ${_souls == 1 ? 'person' : 'people'}'),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      key: const Key('fitrah-add-soul'),
                      tooltip: context.tr('Tambah jiwa', 'Increase people'),
                      onPressed: () => setState(() => _souls++),
                      icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ricePriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Harga Beras Konsumsi per Kg (Rp)', 'Rice Price per Kg (IDR)'),
                    example: '18000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                _metricRow(
                  context,
                  context.tr('Total Beras', 'Total Rice'),
                  context.tr(
                    '${res.riceKgTotal.toStringAsFixed(1)} kg beras',
                    '${res.riceKgTotal.toStringAsFixed(1)} kg rice',
                  ),
                ),
                const SizedBox(height: 10),
                _highlightResultBox(
                  context,
                  label: context.tr('Setara Uang Zakat Fitrah', 'Zakat al-Fitr Cash Equivalent'),
                  value: rupiah(res.fitrahMoneyTotal.round()),
                  emphasized: res.fitrahMoneyTotal > 0,
                  valueKey: const Key('fitrah-money-output'),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(context.tr('Kalkulator Fidyah Puasa', 'Fasting Fidyah Calculator')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('Jumlah Hari Utang Puasa (Fidyah)', 'Missed Fasting Days (Fidyah)'),
                        style: t.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('Kurangi hari fidyah', 'Decrease fidyah days'),
                      onPressed: _fidyahDays <= 0 ? null : () => setState(() => _fidyahDays--),
                      icon: const Icon(MoeslimIcons.minusLingkar),
                    ),
                    Text(
                      context.tr('$_fidyahDays hari', '$_fidyahDays ${_fidyahDays == 1 ? 'day' : 'days'}'),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      tooltip: context.tr('Tambah hari fidyah', 'Increase fidyah days'),
                      onPressed: () => setState(() => _fidyahDays++),
                      icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _mealCostCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Biaya 1 Porsi Makan Layak / Hari (Rp)', 'Cost of 1 Decent Meal / Day (IDR)'),
                    example: '45000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                _highlightResultBox(
                  context,
                  label: context.tr(
                    'Total Fidyah ($_fidyahDays hari)',
                    'Total Fidyah ($_fidyahDays ${_fidyahDays == 1 ? 'day' : 'days'})',
                  ),
                  value: rupiah(res.fidyahMoneyTotal.round()),
                  emphasized: res.fidyahMoneyTotal > 0,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Fidyah wajib bagi lansia renta, sakit menahun yang tidak ada harapan sembuh, atau kondisi uzur syar\'i dengan memberi makan 1 orang miskin per hari puasa yang ditinggalkan (QS. Al-Baqarah: 184).',
                    'Fidyah is obligatory for the frail elderly, the chronically ill with no expectation of recovery, or valid Islamic excuses by feeding 1 person in need per missed fasting day (Quran 2:184).',
                  ),
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
    final isEn = context.isEn;
    final caseTypeLabel = isEn ? _faraidCaseTypeEn(result.caseType) : result.caseType;
    final caseExplanation = isEn ? _faraidCaseExplanationEn(result.caseExplanation) : result.caseExplanation;

    Widget counterRow(String label, int val, ValueChanged<int> onChanged, {int max = 10, Key? plusKey}) {
      return Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: context.tr('Kurangi $label', 'Decrease $label'),
            onPressed: val <= 0 ? null : () => onChanged(val - 1),
            icon: const Icon(MoeslimIcons.minusLingkar),
          ),
          Text('$val', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            key: plusKey,
            tooltip: context.tr('Tambah $label', 'Increase $label'),
            onPressed: val >= max ? null : () => onChanged(val + 1),
            icon: Icon(MoeslimIcons.tambahLingkar, color: scheme.primary),
          ),
        ],
      );
    }

    return ListView(
      key: const ValueKey('faraid-list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('1. Harta Peninggalan Pewaris (Tirkah)', '1. Deceased\'s Estate (Tirkah)'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('faraid-estate-field'),
                  controller: _estateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Total Harta Kotor Pewaris (Rp)', 'Gross Estate Value (IDR)'),
                    example: '120000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _funeralDebtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr('Biaya Jenazah & Utang Pewaris (Rp)', 'Funeral Costs & Debts (IDR)'),
                    example: '5000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _wasiatCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _numDecoration(
                    context,
                    label: context.tr(
                      'Wasiat (Maks. 1/3 = ${rupiah(result.maxAllowedBequest.round())})',
                      'Bequest / Wasiyyah (Max 1/3 = ${rupiah(result.maxAllowedBequest.round())})',
                    ),
                    example: '10000000',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _highlightResultBox(
                  context,
                  label: context.tr('Harta Bersih Siap Waris', 'Net Inheritable Estate'),
                  value: rupiah(result.netInheritableEstate.round()),
                  emphasized: result.netInheritableEstate > 0,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('Status Masalah: ${result.caseType}', 'Case Status: $caseTypeLabel'),
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
                Text(
                  context.tr('2. Pilih Ahli Waris yang Masih Hidup', '2. Select Surviving Heirs'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Meninggalkan Suami', 'Surviving Husband')),
                  value: _hasHusband,
                  onChanged: (v) => setState(() {
                    _hasHusband = v;
                    if (v) _wivesCount = 0;
                  }),
                ),
                if (!_hasHusband)
                  counterRow(
                    context.tr('Jumlah Istri (0–4)', 'Number of Wives (0-4)'),
                    _wivesCount,
                    (v) => setState(() => _wivesCount = v),
                    max: 4,
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Ayah Kandung Masih Hidup', 'Surviving Father')),
                  value: _hasFather,
                  onChanged: (v) => setState(() => _hasFather = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Ibu Kandung Masih Hidup', 'Surviving Mother')),
                  value: _hasMother,
                  onChanged: (v) => setState(() => _hasMother = v),
                ),
                counterRow(
                  context.tr('Anak Laki-laki', 'Sons'),
                  _sonsCount,
                  (v) => setState(() => _sonsCount = v),
                  plusKey: const Key('faraid-add-son'),
                ),
                counterRow(
                  context.tr('Anak Perempuan', 'Daughters'),
                  _daughtersCount,
                  (v) => setState(() => _daughtersCount = v),
                ),
                counterRow(
                  context.tr('Saudara Laki-laki Kandung', 'Full Brothers'),
                  _brothersCount,
                  (v) => setState(() => _brothersCount = v),
                ),
                counterRow(
                  context.tr('Saudara Perempuan Kandung', 'Full Sisters'),
                  _sistersCount,
                  (v) => setState(() => _sistersCount = v),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(context.tr('3. Hasil Perhitungan Faraid', '3. Faraid Calculation Results')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Rincian Bagian (${result.caseType})', 'Share Breakdown ($caseTypeLabel)'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(caseExplanation, style: t.bodySmall),
                const Divider(height: 20),
                for (final s in result.shares)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                isEn
                                    ? '${_faraidHeirNameEn(s.heirName, s.count)} (${s.count} ${s.count == 1 ? 'person' : 'people'}) · ${_faraidPortionLabelEn(s.portionLabel)}'
                                    : '${s.heirName} (${s.count} orang) · ${s.portionLabel}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: s.isBlocked ? scheme.outline : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              rupiah(s.totalAmount.round()),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: s.isBlocked ? scheme.outline : scheme.primary,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        if (s.count > 1 && !s.isBlocked)
                          Text(
                            context.tr(
                              'Per orang: ${rupiah(s.perPersonAmount.round())} (${(s.totalShareRatio * 100).toStringAsFixed(1)}% total)',
                              'Per person: ${rupiah(s.perPersonAmount.round())} (${(s.totalShareRatio * 100).toStringAsFixed(1)}% total)',
                            ),
                            style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        Text(
                          isEn ? _faraidLegalReasonEn(s.legalReason) : s.legalReason,
                          style: t.bodySmall,
                        ),
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
