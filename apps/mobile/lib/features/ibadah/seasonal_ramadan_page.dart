import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../more/ramadan_local_page.dart';

class SeasonalRamadanPage extends ConsumerStatefulWidget {
  final int initialTab;
  const SeasonalRamadanPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<SeasonalRamadanPage> createState() => _SeasonalRamadanPageState();
}

class _SeasonalRamadanPageState extends ConsumerState<SeasonalRamadanPage> {
  late int _tab;
  List<RamadanDayChecklist> _ramadanDays = const [];
  Set<String> _eidChecks = {};

  // Qurban & Aqiqah state (kosong secara default; contoh tampil sebagai hintText)
  final _cowPriceCtrl = TextEditingController();
  final _cowWeightCtrl = TextEditingController();
  final _goatPriceCtrl = TextEditingController();
  bool _isBabyBoy = true;
  DateTime _babyBirthDate = DateTime(2026, 5, 1);

  // Hijri age & converter state
  DateTime _birthDateForAge = DateTime(1998, 8, 17);
  int _convertHijriYear = 1447;
  int _convertHijriMonth = 9;
  int _convertHijriDay = 1;

  // Monthly Imsakiyah state
  late int _imsakiyahYear;
  late int _imsakiyahMonth;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    final now = DateTime.now();
    _imsakiyahYear = now.year;
    _imsakiyahMonth = now.month;
    _load();
  }

  @override
  void dispose() {
    _cowPriceCtrl.dispose();
    _cowWeightCtrl.dispose();
    _goatPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final days = await ref.read(ramadanDashboardRepoProvider).loadAll30Days();
    final eid = await ref.read(eidChecklistRepoProvider).checkedIds();
    if (mounted) {
      setState(() {
        _ramadanDays = days;
        _eidChecks = eid;
      });
    }
  }

  ({String title, String desc}) _eidSunnahText(BuildContext context, EidSunnahItem item) {
    if (!context.isEn) return (title: item.title, desc: item.description);
    return switch (item.id) {
      'zakat_fitrah' => (
          title: 'Pay Zakat al-Fitr Before Eid al-Fitr Prayer',
          desc: 'Obligatory to fulfill before the Eid al-Fitr prayer so it counts as purifying charity (Sunan Abi Dawud no. 1609).',
        ),
      'mandi_id' => (
          title: 'Take the Eid Morning Bath & Wear Your Best Attire',
          desc: 'Narrated from Ibn Umar (RA) that he bathed and wore his finest clothing on the morning of Eid.',
        ),
      'makan_sebelum_id' => (
          title: 'Eat Odd Dates (Eid al-Fitr) or Delay Eating (Eid al-Adha)',
          desc: 'On Eid al-Fitr, eat an odd number of dates before heading out; on Eid al-Adha, delay eating until after the Eid prayer (Sahih al-Bukhari no. 953).',
        ),
      'takbiran' => (
          title: 'Recite the Eid Takbir',
          desc: 'Proclaim the takbir from the night of Eid until the imam ascends the pulpit (and until the end of the Days of Tashriq, 13 Dhu al-Hijjah, for Eid al-Adha).',
        ),
      'jalan_berbeda' => (
          title: 'Take Different Routes Going and Returning',
          desc: 'The Prophet (PBUH) used to take one route to the Eid prayer and return by a different route (Sahih al-Bukhari no. 986).',
        ),
      'tahniah_id' => (
          title: 'Exchange Eid Greetings: Taqabbalallahu Minna wa Minkum',
          desc: 'The Companions\' greeting on Eid: "May Allah accept good deeds from us and from you."',
        ),
      _ => (title: item.title, desc: item.description),
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? PersonalSettings.defaults;
    final status = ref.watch(prayerStatusProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Ramadan, Hari Besar & Hijriah', 'Ramadan, Eid & Hijri Tools')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Ramadan 30H', '30D Ramadan'),
                context.tr('Kurban & Aqiqah', 'Qurban & Aqiqah'),
                context.tr('Umur Hijriah', 'Hijri Age'),
                context.tr('Imsakiyah', 'Imsakiyah'),
                context.tr('Panduan Id', 'Eid Guide'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildRamadanDashboardTab(context, status),
              1 => _buildQurbanAqiqahTab(context),
              2 => _buildHijriConverterTab(context, settings),
              3 => _buildMonthlyImsakiyahTab(context, settings),
              _ => _buildEidGuideTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 31. Dasbor Khusus Ramadan 30 Hari
  Widget _buildRamadanDashboardTab(BuildContext context, PrayerStatus? status) {
    final fastCount = _ramadanDays.where((d) => d.fasting).length;
    final tarawihCount = _ramadanDays.where((d) => d.tarawih).length;
    final juzCount = _ramadanDays.where((d) => d.tilawahJuz).length;
    final itikafCount = _ramadanDays.where((d) => d.itikaf).length;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _ramadanDays.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              ArchHeader(
                child: Column(
                  children: [
                    Text(
                      context.tr('Dasbor Ibadah Ramadan 30 Hari', '30-Day Ramadan Worship Dashboard'),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Imsak: ${hhmm(status.today.fajr.subtract(const Duration(minutes: 10)))} · ${context.prayerLabel(Prayer.fajr)}: ${hhmm(status.today.fajr)} · ${context.prayerLabel(Prayer.maghrib)}: ${hhmm(status.today.maghrib)}',
                        style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        'Puasa: $fastCount/30 · Tarawih: $tarawihCount/30 · Tilawah: $juzCount/30 Juz · I\'tikaf: $itikafCount/10',
                        'Fasting: $fastCount/30 · Tarawih: $tarawihCount/30 · Quran: $juzCount/30 Juz · I\'tikaf: $itikafCount/10',
                      ),
                      key: const Key('ramadan-dashboard-summary'),
                      textAlign: TextAlign.center,
                      style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                key: const Key('open-ramadan-local'),
                child: ListTile(
                  leading: Icon(MoeslimIcons.masjid, color: scheme.primary),
                  title: Text(
                    context.tr('Jadwal Ramadan Masjid Lokal', 'Local Mosque Ramadan Schedule'),
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    context.tr(
                      'Lihat jadwal tarawih, buka bersama, kajian resmi masjid, dan pendaftaran jamaah.',
                      'Browse official tarawih, iftar, lectures, and congregation registration.',
                    ),
                    style: t.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RamadanLocalPage()),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr(
                          'Doa Malam Lailatul Qadar (10 Malam Terakhir)',
                          'Laylat al-Qadr Supplication (Last 10 Nights)',
                        ),
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(fontSize: 24, color: scheme.primary),
                      ),
                      Text(
                        context.tr(
                          'Allahumma innaka \'Afuwwun tuhibbul-\'afwa fa\'fu \'anni. (HR. Tirmidzi no. 3513)',
                          'Allahumma innaka \'Afuwwun tuhibbul-\'afwa fa\'fu \'anni. (Jami\' at-Tirmidhi no. 3513)',
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

        final day = _ramadanDays[index - 1];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OctagonNumber(day.dayNumber, size: 30),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr(
                          'Ramadan Hari ke-${day.dayNumber}${day.isOddNightLailatulQadar ? ' · Malam Ganjil Lailatul Qadar' : ''}',
                          'Ramadan Day ${day.dayNumber}${day.isOddNightLailatulQadar ? ' · Odd Night of Laylat al-Qadr' : ''}',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: day.isOddNightLailatulQadar ? scheme.primary : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    FilterChip(
                      key: Key('ramadan-fast-${day.dayNumber}'),
                      label: Text(context.tr('Puasa', 'Fasting')),
                      selected: day.fasting,
                      onSelected: (v) async {
                        final next = await ref.read(ramadanDashboardRepoProvider).saveDay(day.copyWith(fasting: v));
                        setState(() => _ramadanDays = next);
                      },
                    ),
                    FilterChip(
                      key: Key('ramadan-tarawih-${day.dayNumber}'),
                      label: const Text('Tarawih'),
                      selected: day.tarawih,
                      onSelected: (v) async {
                        final next = await ref.read(ramadanDashboardRepoProvider).saveDay(day.copyWith(tarawih: v));
                        setState(() => _ramadanDays = next);
                      },
                    ),
                    FilterChip(
                      label: Text('Juz ${day.dayNumber}'),
                      selected: day.tilawahJuz,
                      onSelected: (v) async {
                        final next = await ref.read(ramadanDashboardRepoProvider).saveDay(day.copyWith(tilawahJuz: v));
                        setState(() => _ramadanDays = next);
                      },
                    ),
                    if (day.isLastTenNights)
                      FilterChip(
                        label: const Text('I\'tikaf'),
                        selected: day.itikaf,
                        onSelected: (v) async {
                          final next = await ref.read(ramadanDashboardRepoProvider).saveDay(day.copyWith(itikaf: v));
                          setState(() => _ramadanDays = next);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 32. Panduan & Kalkulator Kurban + Aqiqah
  Widget _buildQurbanAqiqahTab(BuildContext context) {
    final cowPrice = int.tryParse(_cowPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final cowWeight = double.tryParse(_cowWeightCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final goatPrice = int.tryParse(_goatPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final calc = calculateQurbanAndAqiqah(
      cowPriceRupiah: cowPrice,
      liveWeightKg: cowWeight,
      isBabyBoy: _isBabyBoy,
      goatPriceRupiah: goatPrice,
      babyBirthDate: _babyBirthDate,
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          context.tr(
            '1. Kalkulator Patungan Kurban Sapi (1/7) & Distribusi Daging',
            '1. Cow Qurban Share (1/7) & Meat Distribution Calculator',
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('qurban-cow-price'),
                  controller: _cowPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('Harga 1 Ekor Sapi Kurban (Rp)', 'Price of 1 Qurban Cow (Rp)'),
                    hintText: context.tr('Contoh: 24500000', 'Example: 24500000'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cowWeightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('Estimasi Bobot Hidup Sapi (Kg)', 'Estimated Live Weight (kg)'),
                    hintText: context.tr('Contoh: 280', 'Example: 280'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixText: 'kg',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 20),
                Text(
                  context.tr(
                    'Patungan per Orang (1/7 Sapi): ${rupiah(calc.cowSharePerPerson)}',
                    'Share per Person (1/7 Cow): ${rupiah(calc.cowSharePerPerson)}',
                  ),
                  key: const Key('qurban-cow-share-output'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'Estimasi Daging Bersih (~35%): ${calc.estimatedMeatKg.toStringAsFixed(1)} kg\n'
                    '• 1/3 Shohibul Kurban & Keluarga: ${calc.familyPortionKg.toStringAsFixed(1)} kg\n'
                    '• 1/3 Kerabat & Tetangga: ${calc.neighborsPortionKg.toStringAsFixed(1)} kg\n'
                    '• 1/3 Fakir & Miskin: ${calc.poorPortionKg.toStringAsFixed(1)} kg',
                    'Estimated Net Meat (~35%): ${calc.estimatedMeatKg.toStringAsFixed(1)} kg\n'
                    '• 1/3 Qurban Owner & Family: ${calc.familyPortionKg.toStringAsFixed(1)} kg\n'
                    '• 1/3 Relatives & Neighbors: ${calc.neighborsPortionKg.toStringAsFixed(1)} kg\n'
                    '• 1/3 Poor & Needy: ${calc.poorPortionKg.toStringAsFixed(1)} kg',
                  ),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr(
            '2. Kalkulator Aqiqah & Hitung Hari ke-7 Kelahiran',
            '2. Aqiqah Calculator & 7th Day Birth Counter',
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(context.tr('Anak Laki-laki (2 Kambing)', 'Baby Boy (2 Goats)'))),
                    ButtonSegment(value: false, label: Text(context.tr('Anak Perempuan (1 Kambing)', 'Baby Girl (1 Goat)'))),
                  ],
                  selected: {_isBabyBoy},
                  onSelectionChanged: (v) => setState(() => _isBabyBoy = v.first),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _goatPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('Harga 1 Ekor Kambing Aqiqah (Rp)', 'Price of 1 Aqiqah Goat (Rp)'),
                    hintText: context.tr('Contoh: 3200000', 'Example: 3200000'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixText: 'Rp ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr(
                      'Tanggal Lahir Anak: ${context.shortDateText(_babyBirthDate)}',
                      'Baby Birth Date: ${context.shortDateText(_babyBirthDate)}',
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _babyBirthDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setState(() => _babyBirthDate = picked);
                    },
                    child: Text(context.tr('Ubah Tanggal', 'Change Date')),
                  ),
                ),
                const Divider(height: 20),
                Text(
                  context.tr(
                    'Kebutuhan: ${calc.aqiqahGoatsRequired} ekor kambing · Estimasi Biaya: ${rupiah(calc.aqiqahTotalCost)}',
                    'Required: ${calc.aqiqahGoatsRequired} ${calc.aqiqahGoatsRequired == 1 ? 'goat' : 'goats'} · Est. Cost: ${rupiah(calc.aqiqahTotalCost)}',
                  ),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    '• Hari ke-7 (Utama): ${context.longDateText(calc.aqiqahDay7)}\n'
                    '• Hari ke-14 (Alternatif): ${context.longDateText(calc.aqiqahDay14)}\n'
                    '• Hari ke-21 (Alternatif): ${context.longDateText(calc.aqiqahDay21)}',
                    '• Day 7 (Recommended): ${context.longDateText(calc.aqiqahDay7)}\n'
                    '• Day 14 (Alternative): ${context.longDateText(calc.aqiqahDay14)}\n'
                    '• Day 21 (Alternative): ${context.longDateText(calc.aqiqahDay21)}',
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

  // 33. Konverter Masehi ↔ Hijriah & Hitung Umur Hijriah
  Widget _buildHijriConverterTab(BuildContext context, PersonalSettings settings) {
    final age = computeHijriAge(
      birthDate: _birthDateForAge,
      currentDate: DateTime.now(),
      hijriOffset: settings.hijriOffset,
    );
    final convertedGreg = approximateGregorianFromHijri(
      _convertHijriYear,
      _convertHijriMonth,
      _convertHijriDay,
      hijriOffset: settings.hijriOffset,
    );
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          context.tr('Kalkulator Umur Hijriah & Konversi Tanggal Lahir', 'Hijri Age Calculator & Birth Date Converter'),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr(
                      'Tanggal Lahir (Masehi): ${context.longDateText(_birthDateForAge)}',
                      'Birth Date (Gregorian): ${context.longDateText(_birthDateForAge)}',
                    ),
                  ),
                  subtitle: Text(
                    context.tr(
                      'Bertepatan dengan: ${context.hijriText(age.birthHijri)}',
                      'Corresponds to: ${context.hijriText(age.birthHijri)}',
                    ),
                  ),
                  trailing: OutlinedButton(
                    key: const Key('hijri-pick-birthdate'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _birthDateForAge,
                        firstDate: DateTime(1930),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _birthDateForAge = picked);
                    },
                    child: Text(context.tr('Pilih Tanggal', 'Pick Date')),
                  ),
                ),
                const Divider(),
                Text(
                  context.tr(
                    'Usia Hijriah: ${age.hijriYears} tahun, ${age.hijriMonths} bulan, ${age.hijriDays} hari',
                    'Hijri Age: ${age.hijriYears} years, ${age.hijriMonths} months, ${age.hijriDays} days',
                  ),
                  key: const Key('hijri-age-output'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Usia Masehi: ${age.gregorianYears} tahun (selisih ±11 hari per tahun dengan kalender kamariah)',
                    'Gregorian Age: ${age.gregorianYears} years (~11 days difference per year with the lunar calendar)',
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(context.tr('Konverter Tanggal Hijriah ke Masehi', 'Hijri to Gregorian Date Converter')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _convertHijriDay,
                        decoration: InputDecoration(labelText: context.tr('Tgl', 'Day')),
                        items: [for (var d = 1; d <= 30; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                        onChanged: (v) {
                          if (v != null) setState(() => _convertHijriDay = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: _convertHijriMonth,
                        decoration: InputDecoration(labelText: context.tr('Bulan Hijriah', 'Hijri Month')),
                        items: [
                          for (var m = 1; m <= 12; m++)
                            DropdownMenuItem(value: m, child: Text('$m. ${HijriDate(1447, m, 1).monthNameFor(context.lang)}')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _convertHijriMonth = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _convertHijriYear,
                        decoration: InputDecoration(labelText: context.tr('Tahun', 'Year')),
                        items: [
                          for (var y = 1400; y <= 1460; y++)
                            DropdownMenuItem(value: y, child: Text(context.isEn ? '$y AH' : '$y H')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _convertHijriYear = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    'Bertepatan dengan Masehi: ${context.longDateText(convertedGreg)}',
                    'Corresponds to Gregorian: ${context.longDateText(convertedGreg)}',
                  ),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 34. Jadwal Imsakiyah / Salat Bulanan Siap Cetak
  Widget _buildMonthlyImsakiyahTab(BuildContext context, PersonalSettings settings) {
    final rows = buildMonthlyImsakiyahTable(settings, _imsakiyahYear, _imsakiyahMonth);
    final t = Theme.of(context).textTheme;

    void copyPrintableTable() {
      final buf = StringBuffer();
      buf.writeln(
        context.tr(
          'JADWAL IMSAKIYAH & SALAT BULANAN - ${settings.effectiveLocationName.toUpperCase()}',
          'MONTHLY IMSAKIYAH & PRAYER SCHEDULE - ${settings.effectiveLocationName.toUpperCase()}',
        ),
      );
      buf.writeln(
        context.tr(
          'Bulan: $_imsakiyahMonth/$_imsakiyahYear · Metode: ${context.methodLabel(settings.method)}',
          'Month: $_imsakiyahMonth/$_imsakiyahYear · Method: ${context.methodLabel(settings.method)}',
        ),
      );
      buf.writeln(
        context.tr(
          'Tgl | Hijriah | Imsak | Subuh | Dzuhur | Ashar | Maghrib | Isya',
          'Day | Hijri | Imsak | Fajr | Dhuhr | Asr | Maghrib | Isha',
        ),
      );
      for (final r in rows) {
        buf.writeln(
          '${r.gregorian.day.toString().padLeft(2, '0')} | ${context.hijriText(r.hijri)} | ${hhmm(r.imsak)} | ${hhmm(r.times.fajr)} | ${hhmm(r.times.dhuhr)} | ${hhmm(r.times.asr)} | ${hhmm(r.times.maghrib)} | ${hhmm(r.times.isha)}',
        );
      }
      Clipboard.setData(ClipboardData(text: buf.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Tabel Jadwal Imsakiyah 1 bulan penuh disalin untuk dicetak/dibagikan.',
              'Full monthly Imsakiyah table copied for printing or sharing.',
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.tr('Bulan sebelumnya', 'Previous month'),
                  onPressed: () => setState(() {
                    if (_imsakiyahMonth == 1) {
                      _imsakiyahMonth = 12;
                      _imsakiyahYear--;
                    } else {
                      _imsakiyahMonth--;
                    }
                  }),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Imsakiyah ${settings.effectiveLocationName} ($_imsakiyahMonth/$_imsakiyahYear)',
                        textAlign: TextAlign.center,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        context.tr(
                          '${context.hijriText(rows.first.hijri)} s.d. ${context.hijriText(rows.last.hijri)}',
                          '${context.hijriText(rows.first.hijri)} to ${context.hijriText(rows.last.hijri)}',
                        ),
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr('Bulan berikutnya', 'Next month'),
                  onPressed: () => setState(() {
                    if (_imsakiyahMonth == 12) {
                      _imsakiyahMonth = 1;
                      _imsakiyahYear++;
                    } else {
                      _imsakiyahMonth++;
                    }
                  }),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('copy-monthly-imsakiyah-btn'),
          onPressed: copyPrintableTable,
          icon: const Icon(MoeslimIcons.cetak),
          label: Text(
            context.tr('Salin Tabel Imsakiyah 1 Bulan Siap Cetak', 'Copy Printable Monthly Imsakiyah Table'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: DataTable(
              columnSpacing: 14,
              columns: [
                DataColumn(label: Text(context.tr('Tgl', 'Day'))),
                const DataColumn(label: Text('Imsak')),
                DataColumn(label: Text(context.prayerLabel(Prayer.fajr))),
                DataColumn(label: Text(context.prayerLabel(Prayer.dhuhr))),
                DataColumn(label: Text(context.prayerLabel(Prayer.asr))),
                DataColumn(label: Text(context.prayerLabel(Prayer.maghrib))),
                DataColumn(label: Text(context.prayerLabel(Prayer.isha))),
              ],
              rows: [
                for (final r in rows)
                  DataRow(
                    cells: [
                      DataCell(Text('${r.gregorian.day}')),
                      DataCell(Text(hhmm(r.imsak), style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(hhmm(r.times.fajr))),
                      DataCell(Text(hhmm(r.times.dhuhr))),
                      DataCell(Text(hhmm(r.times.asr))),
                      DataCell(Text(hhmm(r.times.maghrib), style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(hhmm(r.times.isha))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 35. Checklist & Panduan Idul Fitri / Idul Adha
  Widget _buildEidGuideTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr(
                    'Lafaz Takbiran Hari Raya Idul Fitri & Idul Adha',
                    'Eid al-Fitr & Eid al-Adha Takbir Recitation',
                  ),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ، لَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ وَلِلَّهِ الْحَمْدُ',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 24, color: scheme.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Allahu Akbar, Allahu Akbar, Allahu Akbar, la ilaha illallahu wallahu Akbar, Allahu Akbar wa lillahil-hamd.',
                  style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Artinya: "Allah Mahabesar, Allah Mahabesar, Allah Mahabesar. Tiada Tuhan selain Allah dan Allah Mahabesar. Allah Mahabesar dan segala puji bagi Allah."',
                    'Meaning: "Allah is the Greatest, Allah is the Greatest, Allah is the Greatest. There is no deity worthy of worship except Allah, and Allah is the Greatest. Allah is the Greatest, and all praise belongs to Allah."',
                  ),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr(
            'Checklist Sunnah Pagi Hari Raya (Idul Fitri & Idul Adha)',
            'Eid Morning Sunnah Checklist (Eid al-Fitr & Eid al-Adha)',
          ),
        ),
        for (final item in eidSunnahChecklistCatalog) ...[
          Builder(
            builder: (context) {
              final loc = _eidSunnahText(context, item);
              return Card(
                child: CheckboxListTile(
                  key: Key('eid-check-${item.id}'),
                  title: Text(loc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(loc.desc),
                  value: _eidChecks.contains(item.id),
                  onChanged: (_) async {
                    final next = await ref.read(eidChecklistRepoProvider).toggle(item.id);
                    setState(() => _eidChecks = next);
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
