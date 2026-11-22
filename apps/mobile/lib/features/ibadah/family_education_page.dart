import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class FamilyEducationPage extends ConsumerStatefulWidget {
  final int initialTab;
  const FamilyEducationPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<FamilyEducationPage> createState() => _FamilyEducationPageState();
}

class _FamilyEducationPageState extends ConsumerState<FamilyEducationPage> {
  late int _tab;

  // 41. Baby names state
  final _nameSearchCtrl = TextEditingController();
  String _nameQuery = '';
  String _genderFilter = 'Semua';
  Set<String> _favNames = {};
  IslamicBabyName _comboFirst = islamicBabyNamesCatalog.first;
  IslamicBabyName _comboSecond = islamicBabyNamesCatalog[4];

  // 43. Daily Quiz state
  int _quizIdx = 0;
  int _quizScore = 0;
  int? _pickedQuizOpt;

  // 44. Glossary state
  final _glossarySearchCtrl = TextEditingController();
  String _glossaryQuery = '';

  // 45. Debt Ledger state
  List<DebtLedgerEntry> _debts = const [];
  DebtRecordKind _debtKind = DebtRecordKind.utangSaya;
  final _debtPersonCtrl = TextEditingController();
  final _debtAmountCtrl = TextEditingController();
  final _debtNoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    _load();
  }

  @override
  void dispose() {
    _nameSearchCtrl.dispose();
    _glossarySearchCtrl.dispose();
    _debtPersonCtrl.dispose();
    _debtAmountCtrl.dispose();
    _debtNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final favs = await ref.read(babyNamesRepoProvider).favoriteIds();
    final debts = await ref.read(debtLedgerRepoProvider).allEntries();
    if (mounted) {
      setState(() {
        _favNames = favs;
        _debts = debts;
      });
    }
  }

  String _genderLabel(BuildContext context, String g) => switch (g) {
        'Semua' => context.tr('Semua', 'All'),
        'Laki-laki' => context.tr('Laki-laki', 'Boy'),
        'Perempuan' => context.tr('Perempuan', 'Girl'),
        _ => g,
      };

  String _babyThemeLabel(BuildContext context, String theme) => switch (theme) {
        'Nabi & Rasul' => context.tr(theme, 'Prophets & Messengers'),
        'Sahabat & Ulama' => context.tr(theme, 'Companions & Scholars'),
        'Kemuliaan & Ilmu' => context.tr(theme, 'Nobility & Knowledge'),
        'Al-Qur\'an' => context.tr(theme, 'Al-Qur\'an'),
        'Akhlak & Cahaya' => context.tr(theme, 'Character & Light'),
        _ => theme,
      };

  String _babyMeaningEn(IslamicBabyName n) => switch (n.id) {
        'muhammad' => 'The greatly praised one with noble character',
        'ahmad' => 'The most praiseworthy and constant in praising Allah',
        'ibrahim' => 'Compassionate father and exemplar of pure monotheism',
        'yusuf' => 'Allah increases goodness, beauty, and patience',
        'zayd' => 'Growth and abundance in knowledge and goodness',
        'fatih' => 'Opener of goodness and victory',
        'rayyan' => 'The special gate of Paradise for those who fast, fresh and blessed',
        'furqan' => 'The clear criterion between truth and falsehood',
        'haidar' => 'Courageous defender of the truth',
        'aliim' => 'Gentle, patient, and forbearing',
        'aisyah' => 'Woman of joyful life, intelligence, and vast knowledge',
        'khadijah' => 'Noble woman who is steadfast, generous, and trustworthy',
        'fathimah' => 'Protected from harm and full of compassion',
        'maryam' => 'Pure woman devoted to worship and serving Allah',
        'zahra' => 'Radiant, shining bright, and luminous',
        'humaira' => 'Rosy-cheeked, affectionate nickname given by the Prophet to Aisyah RA',
        'nadhira' => 'Radiant face glowing with joy (QS. Al-Qiyamah: 22)',
        'salma' => 'Safe, peaceful, and comforting to the heart',
        'aliyah' => 'Woman of elevated rank and nobility',
        'syifa' => 'Healing and remedy that soothes the soul',
        _ => n.meaning,
      };

  String _babyMeaning(BuildContext context, IslamicBabyName n) => context.isEn ? _babyMeaningEn(n) : n.meaning;

  ({String sound, String makhraj}) _hijaiyahEn(HijaiyahLetterItem h) => switch (h.order) {
        1 => (sound: 'a / i / u', makhraj: 'Oral cavity / deepest throat (Hamzah)'),
        2 => (sound: 'b', makhraj: 'Closing both lips together (Qalqalah when sukun)'),
        3 => (sound: 't', makhraj: 'Tip of the tongue touching the base of upper front teeth'),
        4 => (sound: 'th (soft)', makhraj: 'Tip of the tongue touching the edge of upper front teeth (light)'),
        5 => (sound: 'j', makhraj: 'Middle of the tongue touching the upper palate (Qalqalah)'),
        6 => (sound: 'h (clear)', makhraj: 'Middle of the throat (smooth and clear)'),
        7 => (sound: 'kh', makhraj: 'Upper throat nearest to the mouth'),
        8 => (sound: 'd', makhraj: 'Tip of the tongue at the base of upper front teeth (Qalqalah)'),
        9 => (sound: 'dh', makhraj: 'Tip of the tongue touching the edge of upper front teeth'),
        10 => (sound: 'r', makhraj: 'Tip of the tongue near the gums of upper front teeth'),
        11 => (sound: 'z', makhraj: 'Tip of the tongue near lower front teeth (buzzing)'),
        12 => (sound: 's', makhraj: 'Tip of the tongue between upper and lower front teeth (light)'),
        13 => (sound: 'sh', makhraj: 'Middle of the tongue with spreading airflow'),
        14 => (sound: 's (heavy)', makhraj: 'Tip of the tongue with the back of the tongue raised (Isti\'la)'),
        15 => (sound: 'd (heavy)', makhraj: 'One or both sides of the tongue touching upper molars'),
        16 => (sound: 't (heavy)', makhraj: 'Tip of the tongue at the base of upper front teeth with heaviness (Qalqalah)'),
        17 => (sound: 'dh (heavy)', makhraj: 'Tip of the tongue at the edge of upper front teeth with heaviness'),
        18 => (sound: '\'ain', makhraj: 'Middle of the throat'),
        19 => (sound: 'gh', makhraj: 'Upper throat nearest to the mouth'),
        20 => (sound: 'f', makhraj: 'Inner lower lip touching the edge of upper front teeth'),
        21 => (sound: 'q', makhraj: 'Back of the tongue near the uvula (Qalqalah)'),
        22 => (sound: 'k', makhraj: 'Back of the tongue slightly forward of Qaf'),
        23 => (sound: 'l', makhraj: 'Front edges of the tongue touching upper front gums'),
        24 => (sound: 'm', makhraj: 'Closing both lips together with nasalization (ghunnah)'),
        25 => (sound: 'n', makhraj: 'Tip of the tongue touching upper gums with nasalization (ghunnah)'),
        26 => (sound: 'w', makhraj: 'Rounding both lips forward'),
        27 => (sound: 'h (deep)', makhraj: 'Deepest part of the throat'),
        28 => (sound: '\' (glottal)', makhraj: 'Deepest part of the throat'),
        29 => (sound: 'y', makhraj: 'Middle of the tongue touching the upper palate'),
        _ => (sound: h.latinSound, makhraj: h.makhrajNote),
      };

  ({String category, String question, List<String> options, String explanation}) _quizText(
    BuildContext context,
    IslamicKnowledgeQuestion q,
  ) {
    if (!context.isEn) {
      return (category: q.category, question: q.question, options: q.options, explanation: q.explanation);
    }
    return switch (q.id) {
      1 => (
          category: 'Al-Qur\'an',
          question: 'Which surah in the Al-Qur\'an does not begin with the Basmalah?',
          options: const ['Surah Al-Anfal', 'Surah At-Tawbah', 'Surah Al-Kahfi', 'Surah Yasin'],
          explanation: 'Surah At-Tawbah (Surah 9) is the only surah in the Mushaf that does not begin with the Basmalah.',
        ),
      2 => (
          category: 'Prophetic Seerah',
          question: 'What was the first mosque built by Prophet Muhammad (PBUH) upon arriving during the Hijrah?',
          options: const ['Al-Masjid al-Haram', 'Masjid Quba', 'Al-Masjid an-Nabawi', 'Masjid al-Qiblatayn'],
          explanation: 'Masjid Quba was established when the Prophet (PBUH) stopped in Quba before entering central Madinah (QS. At-Tawbah: 108).',
        ),
      3 => (
          category: 'Fiqh of Worship',
          question: 'What is the nisab threshold for Zakat on gold savings held for one full Hijri year (haul)?',
          options: const ['50 grams of gold', '85 grams of gold', '100 grams of gold', '200 grams of gold'],
          explanation: 'The nisab for gold zakat is 20 dinars, equivalent to 85 grams of pure gold, with a zakat rate of 2.5%.',
        ),
      4 => (
          category: 'Hadith & Sunnah',
          question: 'How many daily Rawatib Sunnah rakaat are promised a house in Paradise in Sahih Muslim no. 728?',
          options: const ['8 rakaat', '10 rakaat', '12 rakaat', '14 rakaat'],
          explanation: '12 Rawatib rakaat: 2 before Fajr, 4 before Dhuhr, 2 after Dhuhr, 2 after Maghrib, and 2 after Isha.',
        ),
      5 => (
          category: 'Al-Qur\'an',
          question: 'In which surah and verse is the greatest verse of the Al-Qur\'an (Ayat al-Kursi) found?',
          options: const ['QS. Al-Baqarah: 185', 'QS. Al-Baqarah: 255', 'QS. Al-Baqarah: 286', 'QS. Ali \'Imran: 18'],
          explanation: 'Ayat al-Kursi is QS. Al-Baqarah verse 255, affirming the eternal life and absolute sovereignty of Allah SWT.',
        ),
      _ => (category: q.category, question: q.question, options: q.options, explanation: q.explanation),
    };
  }

  ({String category, String definition}) _glossaryEn(IslamicGlossaryTerm item) => switch (item.term) {
        'Tuma\'ninah' => (
            category: 'Prayer Fiqh',
            definition: 'Calmness and a brief pause once every limb settles completely in each pillar of prayer (such as ruku\', i\'tidal, and sujud).',
          ),
        'Sujud Sahwi' => (
            category: 'Prayer Fiqh',
            definition: 'Two prostrations at the end of prayer (before or after taslim) to make up for forgetfulness in rakaat count or missed sunnah ab\'adh.',
          ),
        'Sujud Tilawah' => (
            category: 'Quran Fiqh',
            definition: 'A single recommended prostration performed upon reciting or hearing one of the 15 verses of prostration (Ayat Sajdah) in the Al-Qur\'an.',
          ),
        'Nisab & Haul' => (
            category: 'Zakat & Finance',
            definition: 'Nisab is the minimum wealth threshold subject to zakat; Haul is owning that wealth for one complete Hijri year (354 days).',
          ),
        'Masafatul Qashr' => (
            category: 'Travel Fiqh',
            definition: 'The minimum travel distance (~81-89 km / 2 Marhalah) that permits shortening (Qasr) and combining (Jama\') prayers.',
          ),
        'Ashabul Furudh & Ashabah' => (
            category: 'Inheritance (Faraid)',
            definition: 'Ashabul Furudh are heirs with fixed Quranic shares (1/2, 1/4, 1/8, 2/3, 1/3, 1/6); Asabah are residuary heirs who receive the remainder.',
          ),
        '\'Aul & Radd' => (
            category: 'Inheritance (Faraid)',
            definition: '\'Aul increases the denominator proportionally when fixed shares exceed 100%; Radd returns leftover estate proportionally to blood heirs when no Asabah exists.',
          ),
        'Gharar & Riba' => (
            category: 'Islamic Finance',
            definition: 'Gharar is prohibited excessive uncertainty or speculation in contracts; Riba is stipulated interest on debt or unequal exchange of ribawi goods.',
          ),
        'Mahram' => (
            category: 'Family',
            definition: 'Close relatives (by blood, nursing, or marriage) whom one is permanently forbidden to marry and may travel with.',
          ),
        'Tabayyun' => (
            category: 'Character',
            definition: 'Carefully verifying and checking the truth of news before sharing it or acting upon it (QS. Al-Hujurat: 6).',
          ),
        'Ihsan & Muraqabah' => (
            category: 'Creed & Character',
            definition: 'Worshipping Allah as though you see Him, with full awareness that Allah continually watches over every action.',
          ),
        'Istidraj' => (
            category: 'Creed',
            definition: 'Abundance of worldly ease granted to one who persists in disobedience and turning away from Allah, serving as a gradual test.',
          ),
        _ => (category: item.category, definition: item.definition),
      };

  String _debtKindLabel(BuildContext context, DebtRecordKind k) => switch (k) {
        DebtRecordKind.utangSaya => context.tr(k.label, 'My Debt (To Pay)'),
        DebtRecordKind.piutangSaya => context.tr(k.label, 'Receivable (Lent Out)'),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Keluarga, Anak & Edukasi', 'Family, Kids & Learning')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Nama Bayi', 'Baby Names'),
                context.tr('29 Hijaiyah', '29 Arabic Letters'),
                context.tr('Kuis Islam', 'Islamic Quiz'),
                context.tr('Glosarium', 'Glossary'),
                context.tr('Utang Piutang', 'Debt Ledger'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildBabyNamesTab(context),
              1 => _buildHijaiyahTab(context),
              2 => _buildIslamicQuizTab(context),
              3 => _buildGlossaryTab(context),
              _ => _buildDebtLedgerTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 41. Katalog Nama Bayi Islami + Arti & Tulisan Arab
  Widget _buildBabyNamesTab(BuildContext context) {
    final combined = combineIslamicBabyNames(_comboFirst, _comboSecond);
    final qLower = _nameQuery.toLowerCase();
    final filtered = [
      for (final n in islamicBabyNamesCatalog)
        if ((_genderFilter == 'Semua' || n.gender == _genderFilter) &&
            (n.matches(_nameQuery) ||
                (context.isEn &&
                    (_babyMeaningEn(n).toLowerCase().contains(qLower) ||
                        _babyThemeLabel(context, n.theme).toLowerCase().contains(qLower)))))
          n,
    ];
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final combinedMeaningEn = '${_babyMeaningEn(_comboFirst)}, and ${_babyMeaningEn(_comboSecond).toLowerCase()}.';

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
                  context.tr('Perangkai Kombinasi Nama Bayi Islami', 'Islamic Baby Name Combiner'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<IslamicBabyName>(
                        initialValue: _comboFirst,
                        isDense: true,
                        decoration: InputDecoration(labelText: context.tr('Nama Depan', 'First Name')),
                        items: [
                          for (final n in islamicBabyNamesCatalog)
                            DropdownMenuItem(value: n, child: Text(n.name)),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _comboFirst = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<IslamicBabyName>(
                        initialValue: _comboSecond,
                        isDense: true,
                        decoration: InputDecoration(labelText: context.tr('Nama Belakang', 'Last Name')),
                        items: [
                          for (final n in islamicBabyNamesCatalog)
                            DropdownMenuItem(value: n, child: Text(n.name)),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _comboSecond = v);
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  combined.fullArabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 28, color: scheme.primary),
                ),
                Text(
                  combined.fullLatin,
                  key: const Key('baby-name-combo-output'),
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('Makna Rangkaian: ${combined.combinedMeaning}', 'Combined Meaning: $combinedMeaningEn'),
                  textAlign: TextAlign.center,
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('baby-name-search'),
          controller: _nameSearchCtrl,
          decoration: InputDecoration(
            prefixIcon: const Icon(MoeslimIcons.pencarian),
            hintText: context.tr(
              'Cari nama atau arti (mis. Muhammad, Aisyah, Cahaya, Terpuji)',
              'Search name or meaning (e.g., Muhammad, Aisyah, Light, Praiseworthy)',
            ),
          ),
          onChanged: (v) => setState(() => _nameQuery = v.trim()),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final g in ['Semua', 'Laki-laki', 'Perempuan'])
              ChoiceChip(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(_genderLabel(context, g)),
                selected: _genderFilter == g,
                onSelected: (_) => setState(() => _genderFilter = g),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in filtered)
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} (${_genderLabel(context, item.gender)})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(item.arabic, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 22, color: scheme.primary)),
                ],
              ),
              subtitle: Text('${_babyThemeLabel(context, item.theme)} · ${_babyMeaning(context, item)}'),
              trailing: IconButton(
                tooltip: context.tr('Simpan nama favorit', 'Save favorite name'),
                onPressed: () async {
                  final next = await ref.read(babyNamesRepoProvider).toggleFavorite(item.id);
                  setState(() => _favNames = next);
                },
                icon: Icon(
                  _favNames.contains(item.id) ? MoeslimIcons.cinta : Icons.favorite_border,
                  color: _favNames.contains(item.id) ? scheme.primary : null,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 42. Belajar Huruf Hijaiyah & Dasar Membaca Al-Qur'an
  Widget _buildHijaiyahTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hijaiyah29Catalog.length,
      itemBuilder: (context, index) {
        final h = hijaiyah29Catalog[index];
        final en = _hijaiyahEn(h);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OctagonNumber(h.order),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('${h.name} (Bunyi: ${h.latinSound})', '${h.name} (Sound: ${en.sound})'),
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            context.tr('Makhraj: ${h.makhrajNote}', 'Articulation (Makhraj): ${en.makhraj}'),
                            style: t.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      h.isolated,
                      textDirection: TextDirection.rtl,
                      style: quranTextStyle(fontSize: 34, color: scheme.primary),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Text(
                  context.tr(
                    'Bentuk Sambung (Akhir · Tengah · Awal): ${h.connectedForms}',
                    'Connected Forms (Final · Medial · Initial): ${h.connectedForms}',
                  ),
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('Latihan Harakat: ${h.harakatSample}', 'Vowel Practice (Harakat): ${h.harakatSample}'),
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 43. Kuis Wawasan Islam Harian (Offline)
  Widget _buildIslamicQuizTab(BuildContext context) {
    final q = islamicKnowledgeQuizBank[_quizIdx % islamicKnowledgeQuizBank.length];
    final loc = _quizText(context, q);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  context.tr(
                    'Kategori: ${loc.category} · Skor: $_quizScore / ${islamicKnowledgeQuizBank.length}',
                    'Category: ${loc.category} · Score: $_quizScore / ${islamicKnowledgeQuizBank.length}',
                  ),
                  key: const Key('islamic-quiz-score'),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.question,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < loc.options.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              key: Key('islamic-quiz-opt-$i'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
              ),
              onPressed: _pickedQuizOpt != null
                  ? null
                  : () => setState(() {
                        _pickedQuizOpt = i;
                        if (i == q.correctIndex) _quizScore++;
                      }),
              child: Row(
                children: [
                  Expanded(child: Text(loc.options[i], style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (_pickedQuizOpt != null && i == q.correctIndex)
                    Icon(MoeslimIcons.berhasil, color: scheme.primary),
                ],
              ),
            ),
          ),
        if (_pickedQuizOpt != null) ...[
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(loc.explanation, style: t.bodyMedium),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('islamic-quiz-next'),
            onPressed: () => setState(() {
              _quizIdx = (_quizIdx + 1) % islamicKnowledgeQuizBank.length;
              _pickedQuizOpt = null;
            }),
            icon: const Icon(Icons.arrow_forward),
            label: Text(context.tr('Pertanyaan Berikutnya', 'Next Question')),
          ),
        ],
      ],
    );
  }

  // 44. Glosarium / Ensiklopedia Mini Istilah Islam
  Widget _buildGlossaryTab(BuildContext context) {
    final qLower = _glossaryQuery.toLowerCase();
    final filtered = [
      for (final term in islamicGlossaryCatalog)
        if (term.matches(_glossaryQuery) ||
            (context.isEn &&
                (_glossaryEn(term).category.toLowerCase().contains(qLower) ||
                    _glossaryEn(term).definition.toLowerCase().contains(qLower))))
          term,
    ];
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            key: const Key('glossary-search'),
            controller: _glossarySearchCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(MoeslimIcons.pencarian),
              hintText: context.tr(
                'Cari istilah Islam (mis. Tuma\'ninah, Nisab, Mahram, Gharar, Tabayyun)',
                'Search Islamic terms (e.g., Tuma\'ninah, Nisab, Mahram, Gharar, Tabayyun)',
              ),
            ),
            onChanged: (v) => setState(() => _glossaryQuery = v.trim()),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final en = _glossaryEn(item);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.term, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            context.isEn ? en.category : item.category,
                            style: t.labelMedium?.copyWith(color: scheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(context.isEn ? en.definition : item.definition, style: t.bodyMedium),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 45. Pencatat Utang-Piutang Pribadi (Sesuai QS. Al-Baqarah: 282)
  Widget _buildDebtLedgerTab(BuildContext context) {
    final totalPayable = _debts
        .where((d) => d.kind == DebtRecordKind.utangSaya)
        .fold<int>(0, (s, d) => s + d.remainingAmount);
    final totalReceivable = _debts
        .where((d) => d.kind == DebtRecordKind.piutangSaya)
        .fold<int>(0, (s, d) => s + d.remainingAmount);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'QS. Al-Baqarah: 282 (Ayat Mudayanah): "Wahai orang-orang yang beriman, apabila kamu melakukan utang piutang untuk waktu yang ditentukan, hendaklah kamu menuliskannya."',
                    'QS. Al-Baqarah: 282 (Verse of Debt): "O you who believe, when you contract a debt for a specified term, write it down."',
                  ),
                  style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
                const Divider(height: 18),
                Text(
                  context.tr(
                    'Sisa Utang Saya: ${rupiah(totalPayable)} · Sisa Piutang Saya: ${rupiah(totalReceivable)}',
                    'Remaining Payable: ${rupiah(totalPayable)} · Remaining Receivable: ${rupiah(totalReceivable)}',
                  ),
                  key: const Key('debt-ledger-summary'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<DebtRecordKind>(
                  segments: [
                    for (final k in DebtRecordKind.values)
                      ButtonSegment(value: k, label: Text(_debtKindLabel(context, k))),
                  ],
                  selected: {_debtKind},
                  onSelectionChanged: (v) => setState(() => _debtKind = v.first),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('debt-person-field'),
                  controller: _debtPersonCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      'Nama Pihak Terkait (Pemberi / Penerima)',
                      'Counterparty Name (Lender / Borrower)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('debt-amount-field'),
                  controller: _debtAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr('Nominal (Rp)', 'Amount (Rp)'),
                    hintText: context.tr('Contoh: 500000', 'Example: 500000'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _debtNoteCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr('Keterangan / Akad (Opsional)', 'Notes / Agreement (Optional)'),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('debt-add-btn'),
                  onPressed: () async {
                    if (_debtPersonCtrl.text.trim().isEmpty) return;
                    final amount = int.tryParse(_debtAmountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    final next = await ref.read(debtLedgerRepoProvider).addEntry(
                          kind: _debtKind,
                          personName: _debtPersonCtrl.text,
                          totalAmount: amount,
                          dueDate: DateTime.now().add(const Duration(days: 30)),
                          note: _debtNoteCtrl.text,
                        );
                    _debtPersonCtrl.clear();
                    _debtAmountCtrl.clear();
                    _debtNoteCtrl.clear();
                    setState(() => _debts = next);
                  },
                  icon: const Icon(MoeslimIcons.tambahLingkar),
                  label: Text(context.tr('Catat Utang / Piutang', 'Record Debt / Loan')),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr('Buku Catatan Utang-Piutang (${_debts.length})', 'Debt & Loan Ledger (${_debts.length})'),
        ),
        for (final d in _debts)
          Card(
            child: ListTile(
              leading: Icon(
                d.isPaidOff ? MoeslimIcons.berhasil : MoeslimIcons.anggaran,
                color: d.isPaidOff ? scheme.primary : BrandColors.goldText,
              ),
              title: Text(
                '${d.personName} · ${rupiah(d.totalAmount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  decoration: d.isPaidOff ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                context.tr(
                  '${d.kind.label} · Jatuh tempo: ${d.dueDateKey}${d.isPaidOff ? ' (LUNAS)' : ' (Sisa: ${rupiah(d.remainingAmount)})'}',
                  '${_debtKindLabel(context, d.kind)} · Due: ${d.dueDateKey}${d.isPaidOff ? ' (PAID)' : ' (Left: ${rupiah(d.remainingAmount)})'}',
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!d.isPaidOff)
                    TextButton(
                      key: Key('debt-payoff-${d.id}'),
                      onPressed: () async {
                        final next = await ref.read(debtLedgerRepoProvider).markPaidOff(d.id);
                        setState(() => _debts = next);
                      },
                      child: Text(context.tr('Tandai Lunas', 'Mark Paid')),
                    ),
                  IconButton(
                    tooltip: context.tr('Hapus catatan', 'Delete record'),
                    onPressed: () async {
                      final next = await ref.read(debtLedgerRepoProvider).deleteEntry(d.id);
                      setState(() => _debts = next);
                    },
                    icon: const Icon(MoeslimIcons.hapus),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
