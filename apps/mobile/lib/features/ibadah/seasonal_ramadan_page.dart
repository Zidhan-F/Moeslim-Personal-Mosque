import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

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

  // Qurban & Aqiqah state
  final _cowPriceCtrl = TextEditingController(text: '24500000');
  final _cowWeightCtrl = TextEditingController(text: '280');
  final _goatPriceCtrl = TextEditingController(text: '3200000');
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? PersonalSettings.defaults;
    final status = ref.watch(prayerStatusProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Ramadan, Hari Besar & Hijriah'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Ramadan 30H', 'Kurban & Aqiqah', 'Umur Hijriah', 'Imsakiyah', 'Panduan Id'],
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
                    Text('Dasbor Ibadah Ramadan 30 Hari', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    if (status != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Imsak: ${hhmm(status.today.fajr.subtract(const Duration(minutes: 10)))} · Subuh: ${hhmm(status.today.fajr)} · Maghrib: ${hhmm(status.today.maghrib)}',
                        style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Puasa: $fastCount/30 · Tarawih: $tarawihCount/30 · Tilawah: $juzCount/30 Juz · I\'tikaf: $itikafCount/10',
                      key: const Key('ramadan-dashboard-summary'),
                      textAlign: TextAlign.center,
                      style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Doa Malam Lailatul Qadar (10 Malam Terakhir)', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(fontSize: 24, color: scheme.primary),
                      ),
                      Text(
                        'Allahumma innaka \'Afuwwun tuhibbul-\'afwa fa\'fu \'anni. (HR. Tirmidzi no. 3513)',
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
                        'Ramadan Hari ke-${day.dayNumber}${day.isOddNightLailatulQadar ? ' · Malam Ganjil Lailatul Qadar' : ''}',
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
                      label: const Text('Puasa'),
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
    final cowPrice = int.tryParse(_cowPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 24500000;
    final cowWeight = double.tryParse(_cowWeightCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 280;
    final goatPrice = int.tryParse(_goatPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 3200000;
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
        const SectionHeader('1. Kalkulator Patungan Kurban Sapi (1/7) & Distribusi Daging'),
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
                  decoration: const InputDecoration(labelText: 'Harga 1 Ekor Sapi Kurban (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cowWeightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Estimasi Bobot Hidup Sapi (Kg)', suffixText: 'kg'),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 20),
                Text(
                  'Patungan per Orang (1/7 Sapi): ${rupiah(calc.cowSharePerPerson)}',
                  key: const Key('qurban-cow-share-output'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estimasi Daging Bersih (~35%): ${calc.estimatedMeatKg.toStringAsFixed(1)} kg\n'
                  '• 1/3 Shohibul Kurban & Keluarga: ${calc.familyPortionKg.toStringAsFixed(1)} kg\n'
                  '• 1/3 Kerabat & Tetangga: ${calc.neighborsPortionKg.toStringAsFixed(1)} kg\n'
                  '• 1/3 Fakir & Miskin: ${calc.poorPortionKg.toStringAsFixed(1)} kg',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('2. Kalkulator Aqiqah & Hitung Hari ke-7 Kelahiran'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Anak Laki-laki (2 Kambing)')),
                    ButtonSegment(value: false, label: Text('Anak Perempuan (1 Kambing)')),
                  ],
                  selected: {_isBabyBoy},
                  onSelectionChanged: (v) => setState(() => _isBabyBoy = v.first),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _goatPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga 1 Ekor Kambing Aqiqah (Rp)', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tanggal Lahir Anak: ${shortDate(_babyBirthDate)}'),
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
                    child: const Text('Ubah Tanggal'),
                  ),
                ),
                const Divider(height: 20),
                Text(
                  'Kebutuhan: ${calc.aqiqahGoatsRequired} ekor kambing · Estimasi Biaya: ${rupiah(calc.aqiqahTotalCost)}',
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Hari ke-7 (Utama): ${longDate(calc.aqiqahDay7)}\n'
                  '• Hari ke-14 (Alternatif): ${longDate(calc.aqiqahDay14)}\n'
                  '• Hari ke-21 (Alternatif): ${longDate(calc.aqiqahDay21)}',
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
        const SectionHeader('Kalkulator Umur Hijriah & Konversi Tanggal Lahir'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tanggal Lahir (Masehi): ${longDate(_birthDateForAge)}'),
                  subtitle: Text('Bertepatan dengan: ${age.birthHijri}'),
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
                    child: const Text('Pilih Tanggal'),
                  ),
                ),
                const Divider(),
                Text(
                  'Usia Hijriah: ${age.hijriYears} tahun, ${age.hijriMonths} bulan, ${age.hijriDays} hari',
                  key: const Key('hijri-age-output'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('Usia Masehi: ${age.gregorianYears} tahun (selisih ±11 hari per tahun dengan kalender kamariah)'),
              ],
            ),
          ),
        ),
        const SectionHeader('Konverter Tanggal Hijriah ke Masehi'),
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
                        decoration: const InputDecoration(labelText: 'Tgl'),
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
                        decoration: const InputDecoration(labelText: 'Bulan Hijriah'),
                        items: [
                          for (var m = 1; m <= 12; m++)
                            DropdownMenuItem(value: m, child: Text('$m. ${HijriDate(1447, m, 1).monthName}')),
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
                        decoration: const InputDecoration(labelText: 'Tahun'),
                        items: [
                          for (var y = 1400; y <= 1460; y++) DropdownMenuItem(value: y, child: Text('$y H')),
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
                  'Bertepatan dengan Masehi: ${longDate(convertedGreg)}',
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
      buf.writeln('JADWAL IMSAKIYAH & SALAT BULANAN - ${settings.effectiveLocationName.toUpperCase()}');
      buf.writeln('Bulan: $_imsakiyahMonth/$_imsakiyahYear · Metode: ${settings.method.label}');
      buf.writeln('Tgl | Hijriah | Imsak | Subuh | Dzuhur | Ashar | Maghrib | Isya');
      for (final r in rows) {
        buf.writeln(
          '${r.gregorian.day.toString().padLeft(2, '0')} | ${r.hijri} | ${hhmm(r.imsak)} | ${hhmm(r.times.fajr)} | ${hhmm(r.times.dhuhr)} | ${hhmm(r.times.asr)} | ${hhmm(r.times.maghrib)} | ${hhmm(r.times.isha)}',
        );
      }
      Clipboard.setData(ClipboardData(text: buf.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabel Jadwal Imsakiyah 1 bulan penuh disalin untuk dicetak/dibagikan.')),
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
                  tooltip: 'Bulan sebelumnya',
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
                      Text('${rows.first.hijri} s.d. ${rows.last.hijri}', style: t.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Bulan berikutnya',
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
          label: const Text('Salin Tabel Imsakiyah 1 Bulan Siap Cetak'),
        ),
        const SizedBox(height: 8),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: DataTable(
              columnSpacing: 14,
              columns: const [
                DataColumn(label: Text('Tgl')),
                DataColumn(label: Text('Imsak')),
                DataColumn(label: Text('Subuh')),
                DataColumn(label: Text('Dzuhur')),
                DataColumn(label: Text('Ashar')),
                DataColumn(label: Text('Maghrib')),
                DataColumn(label: Text('Isya')),
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
                Text('Lafaz Takbiran Hari Raya Idul Fitri & Idul Adha', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                  'Artinya: "Allah Mahabesar, Allah Mahabesar, Allah Mahabesar. Tiada Tuhan selain Allah dan Allah Mahabesar. Allah Mahabesar dan segala puji bagi Allah."',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('Checklist Sunnah Pagi Hari Raya (Idul Fitri & Idul Adha)'),
        for (final item in eidSunnahChecklistCatalog)
          Card(
            child: CheckboxListTile(
              key: Key('eid-check-${item.id}'),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item.description),
              value: _eidChecks.contains(item.id),
              onChanged: (_) async {
                final next = await ref.read(eidChecklistRepoProvider).toggle(item.id);
                setState(() => _eidChecks = next);
              },
            ),
          ),
      ],
    );
  }
}
