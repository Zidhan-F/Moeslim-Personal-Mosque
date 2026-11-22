import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../quran/surah_page.dart';
import 'doa_pages.dart';

class SpiritualCarePage extends ConsumerStatefulWidget {
  final int initialTab;
  const SpiritualCarePage({super.key, this.initialTab = 0});

  @override
  ConsumerState<SpiritualCarePage> createState() => _SpiritualCarePageState();
}

class _SpiritualCarePageState extends ConsumerState<SpiritualCarePage> {
  late int _tab;
  SpiritualMoodCondition _selectedMood = spiritualMoodCatalog.first;
  int _shalawatCount = 0;
  int _shalawatTarget = 100;
  List<PersonalHajatItem> _hajatList = const [];
  final _hajatTitleCtrl = TextEditingController();
  String _hajatCategory = 'Diri Sendiri & Keluarga';
  Set<String> _completedHabits = {};

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    _load();
  }

  @override
  void dispose() {
    _hajatTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sh = await ref.read(shalawatCounterRepoProvider).loadForDay(_today);
    final hj = await ref.read(hajatPrayerListRepoProvider).allItems();
    final hb = await ref.read(sunnahHabitRepoProvider).completedForDate(_today);
    if (mounted) {
      setState(() {
        _shalawatCount = sh.count;
        _shalawatTarget = sh.target;
        _hajatList = hj;
        _completedHabits = hb;
      });
    }
  }

  ({String label, String comfort}) _moodText(BuildContext context, SpiritualMoodCondition m) {
    if (!context.isEn) return (label: m.label, comfort: m.quranicComfort);
    return switch (m.id) {
      'gelisah' => (
          label: 'Anxious & Restless',
          comfort: 'QS. Ar-Ra\'d: 28: "Verily, in the remembrance of Allah do hearts find rest."',
        ),
      'sedih' => (
          label: 'Sad & Grieving',
          comfort: 'QS. At-Tawbah: 40: "Do not grieve; indeed Allah is with us."',
        ),
      'marah' => (
          label: 'Angry & Upset',
          comfort: 'QS. Ali \'Imran: 134: "...who restrain anger and pardon people."',
        ),
      'sakit' => (
          label: 'Unwell & Tired',
          comfort: 'QS. Ash-Shu\'ara: 80: "And when I am ill, it is He who cures me."',
        ),
      'ujian' => (
          label: 'Hardship & Debt',
          comfort: 'QS. At-Talaq: 2-3: "Whoever fears Allah, He will make for them a way out."',
        ),
      'safar' => (
          label: 'Travel & Journey',
          comfort: 'QS. Az-Zukhruf: 13-14: "Glory to Him who has subjected this to us."',
        ),
      'syukur' => (
          label: 'Joyful & Grateful',
          comfort: 'QS. Ibrahim: 7: "If you are grateful, I will surely increase you in favor."',
        ),
      'keluarga' => (
          label: 'Family & Knowledge',
          comfort: 'QS. Al-Furqan: 74: "Our Lord, grant us from our spouses and offspring comfort to our eyes."',
        ),
      _ => (label: m.label, comfort: m.quranicComfort),
    };
  }

  ({String title, String repeat, String translation, String reference}) _ruqyahText(
    BuildContext context,
    RuqyahReadingItem item,
  ) {
    if (!context.isEn) {
      return (title: item.title, repeat: item.repeatLabel, translation: item.translation, reference: item.reference);
    }
    return switch (item.order) {
      1 => (
          title: 'Surah Al-Fatihah (The Opening / Ash-Shifa)',
          repeat: 'Recite 1x / 3x / 7x',
          translation:
              'In the name of Allah, the Entirely Merciful, the Especially Merciful. All praise is due to Allah, Lord of the worlds... Guide us to the straight path.',
          reference: 'Sahih al-Bukhari no. 2276 (Companions performed ruqyah with Al-Fatihah and the Prophet approved)',
        ),
      2 => (
          title: 'Ayat al-Kursi (QS. Al-Baqarah: 255)',
          repeat: 'Recite 1x',
          translation: 'Allah: there is no deity except Him, the Ever-Living, the Sustainer of all existence.',
          reference: 'Sahih al-Bukhari no. 2311 (Protection from harm and whispers of Satan)',
        ),
      3 => (
          title: 'Al-Mu\'awwidhat (Al-Ikhlas, Al-Falaq & An-Nas)',
          repeat: 'Recite 3x while wiping the body',
          translation:
              'Recite Al-Ikhlas, Al-Falaq, and An-Nas, gently blow into both palms, and wipe over the head, face, and as much of the body as possible.',
          reference: 'Sahih al-Bukhari no. 5017 & Sahih Muslim no. 2192 (Narrated by Aisyah RA)',
        ),
      4 => (
          title: 'Ruqyah Supplication Holding the Area of Pain',
          repeat: 'Bismillah 3x + Dua 7x',
          translation:
              'In the name of Allah (3x). I seek refuge in Allah and His power from the evil of what I find and fear (7x).',
          reference: 'Sahih Muslim no. 2202 (Prophet\'s advice to Uthman ibn Abi al-As RA)',
        ),
      _ => (
          title: 'Supplication for Healing to Ash-Shafi',
          repeat: 'Recite 1x / 3x',
          translation:
              'O Allah, Lord of mankind, remove the harm and heal, for You are the Healer. There is no healing except Your healing, a healing that leaves behind no ailment.',
          reference: 'Sahih al-Bukhari no. 5743 & Sahih Muslim no. 2191',
        ),
    };
  }

  ({String title, String translation, String source}) _shalawatText(BuildContext context, ShalawatReading sh) {
    if (!context.isEn) return (title: sh.title, translation: sh.translation, source: sh.sourceAndVirtue);
    return switch (sh.id) {
      'ibrahimiyah' => (
          title: 'Salawat Ibrahimiyah (Most Virtuous & Authentic)',
          translation:
              'O Allah, send prayers upon Muhammad and the family of Muhammad as You sent prayers upon Ibrahim and the family of Ibrahim; indeed You are Praiseworthy and Glorious. O Allah, bless Muhammad and the family of Muhammad as You blessed Ibrahim and the family of Ibrahim; indeed You are Praiseworthy and Glorious.',
          source: 'Sahih al-Bukhari no. 3370 & Sahih Muslim no. 406 (Taught directly by Prophet Muhammad PBUH)',
        ),
      'ringkas_matsur' => (
          title: 'Concise Authentic Salawat',
          translation: 'O Allah, send prayers and peace upon our Prophet Muhammad.',
          source: 'Sahih Muslim no. 408: "Whoever sends one blessing upon me, Allah sends ten blessings upon them."',
        ),
      'dzurriyah' => (
          title: 'Salawat Upon the Prophet, His Wives & Offspring',
          translation:
              'O Allah, send prayers upon Muhammad, his wives, and his offspring as You sent prayers upon the family of Ibrahim, and bless Muhammad, his wives, and his offspring as You blessed the family of Ibrahim; indeed You are Praiseworthy and Glorious.',
          source: 'Sahih al-Bukhari no. 3369 & Sahih Muslim no. 407 (Narrated by Abu Humayd as-Sa\'idi RA)',
        ),
      _ => (title: sh.title, translation: sh.translation, source: sh.sourceAndVirtue),
    };
  }

  String _hajatCategoryLabel(BuildContext context, String cat) => switch (cat) {
        'Diri Sendiri & Keluarga' => context.tr('Diri Sendiri & Keluarga', 'Self & Family'),
        'Orang Tua' => context.tr('Orang Tua', 'Parents'),
        'Kesehatan & Rezeki' => context.tr('Kesehatan & Rezeki', 'Health & Provision'),
        'Ilmu & Akhirat' => context.tr('Ilmu & Akhirat', 'Knowledge & Hereafter'),
        _ => cat,
      };

  ({String title, String virtue}) _sunnahHabitText(BuildContext context, SunnahHabitSpec h) {
    if (!context.isEn) return (title: h.title, virtue: h.virtue);
    return switch (h.id) {
      'qabliyah_subuh' => (
          title: '2 Rakaat Before Fajr (Qabliyah)',
          virtue: 'Sahih Muslim no. 725: "The two rakaat before Fajr are better than the world and everything in it."',
        ),
      'qabliyah_dzuhur' => (
          title: '4 Rakaat Before Dhuhr (Qabliyah)',
          virtue: 'Part of the 12 daily Rawatib rakaat promised a house in Paradise (Sahih Muslim no. 728).',
        ),
      'badiyah_dzuhur' => (
          title: '2 Rakaat After Dhuhr (Ba\'diyah)',
          virtue: 'Part of the 12 confirmed daily Rawatib rakaat following Dhuhr prayer.',
        ),
      'badiyah_maghrib' => (
          title: '2 Rakaat After Maghrib (Ba\'diyah)',
          virtue: 'Part of the 12 daily Rawatib rakaat following Maghrib prayer.',
        ),
      'badiyah_isya' => (
          title: '2 Rakaat After Isha (Ba\'diyah)',
          virtue: 'Completes the 12 daily Rawatib rakaat.',
        ),
      'salat_dhuha' => (
          title: 'Dhuha Sunnah Prayer (At Least 2 Rakaat)',
          virtue: 'Sahih Muslim no. 720: Fulfills the charity due on all 360 joints of the body each morning.',
        ),
      'salat_witir' => (
          title: 'Witr Prayer Closing the Night',
          virtue: 'Sahih al-Bukhari no. 998: "Make Witr the last of your night prayers."',
        ),
      'wudhu_sebelum_tidur' => (
          title: 'Wudu & Dhikr Before Sleep',
          virtue: 'Sahih al-Bukhari no. 247: Sleeping in a state of purity earns the prayers of angels for forgiveness.',
        ),
      _ => (title: h.title, virtue: h.virtue),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Dzikir, Doa & Penguatan Hati', 'Dhikr, Dua & Heart Care')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Doa Kondisi', 'Mood Duas'),
                context.tr('Ruqyah', 'Ruqyah'),
                context.tr('Shalawat', 'Salawat'),
                context.tr('Daftar Hajat', 'Prayer List'),
                context.tr('Sunnah Rawatib', 'Sunnah Habits'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildMoodDuaFinderTab(context),
              1 => _buildRuqyahTab(context),
              2 => _buildShalawatTab(context),
              3 => _buildHajatListTab(context),
              _ => _buildSunnahHabitsTab(context),
            },
          ),
        ],
      ),
    );
  }

  // 37. Pencari Doa Berbasis Kondisi / Suasana Hati
  Widget _buildMoodDuaFinderTab(BuildContext context) {
    final dailyDuasAsync = ref.watch(dailyDuasProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lang = context.lang;
    final selectedMoodLoc = _moodText(context, _selectedMood);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.tr('Apa yang Sedang Anda Rasakan / Hadapi Hari Ini?', 'What Are You Feeling or Facing Today?'),
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in spiritualMoodCatalog)
              ChoiceChip(
                key: Key('mood-chip-${m.id}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(_moodText(context, m).label),
                selected: _selectedMood.id == m.id,
                onSelected: (_) => setState(() => _selectedMood = m),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'Penyejuk Hati dari Al-Qur\'an (${selectedMoodLoc.label})',
                    'Quranic Comfort (${selectedMoodLoc.label})',
                  ),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedMoodLoc.comfort,
                  key: const Key('mood-quran-comfort'),
                  style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr(
            'Doa Shahih untuk Kondisi: ${selectedMoodLoc.label}',
            'Authentic Duas for: ${selectedMoodLoc.label}',
          ),
        ),
        dailyDuasAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          error: (e, _) => Text(context.tr('Gagal memuat doa: $e', 'Failed to load duas: $e')),
          data: (allDuas) {
            final matched = filterDailyDuasByMood(allDuas, _selectedMood);
            return Column(
              children: [
                for (var i = 0; i < matched.length; i++)
                  Card(
                    child: ListTile(
                      leading: OctagonNumber(i + 1),
                      title: Text(matched[i].titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${matched[i].groupFor(lang)} · ${matched[i].translationFor(lang)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DailyDuaDetailPage(dua: matched[i])),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 36. Panduan Ruqyah Syar'iyyah Mandiri
  Widget _buildRuqyahTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PatternBanner(
          child: Text(
            context.tr(
              'Adab Ruqyah Mandiri: Berwudhu, yakin sepenuh hati bahwa kesembuhan dan perlindungan semata-mata dari Allah SWT, membaca ayat & doa dengan khusyuk, lalu mengusapkan tangan ke bagian tubuh yang sakit.',
              'Self-Ruqyah Etiquette: Perform wudu, hold firm conviction that healing and protection come solely from Allah SWT, recite the verses and supplications mindfully, then wipe your hands over the affected area.',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in ruqyahMandiriCatalog) ...[
          Builder(
            builder: (context) {
              final loc = _ruqyahText(context, item);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          OctagonNumber(item.order),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                Text(loc.repeat, style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          if (item.linkedSurah != null)
                            IconButton(
                              tooltip: context.tr('Buka surah di Mushaf', 'Open surah in Mushaf'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => SurahPage(surah: surahs[item.linkedSurah! - 1])),
                              ),
                              icon: Icon(MoeslimIcons.quranTerbuka, color: scheme.primary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.arabic,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(item.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),
                      Text(loc.translation, style: t.bodyMedium),
                      const SizedBox(height: 6),
                      Text(context.tr('Dalil: ${loc.reference}', 'Source: ${loc.reference}'), style: t.bodySmall),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // 38. Koleksi Shalawat Ma'tsur & Target Shalawat Harian
  Widget _buildShalawatTab(BuildContext context) {
    final ratio = _shalawatTarget <= 0 ? 1.0 : (_shalawatCount / _shalawatTarget).clamp(0.0, 1.0);
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
                  context.tr('Target Shalawat Harian / Hari Jumat', 'Daily / Friday Salawat Target'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('$_shalawatCount / $_shalawatTarget kali', '$_shalawatCount / $_shalawatTarget times'),
                  key: const Key('shalawat-counter-value'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      key: const Key('shalawat-tap-btn'),
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        final res = await ref.read(shalawatCounterRepoProvider).increment(_today);
                        setState(() => _shalawatCount = res.count);
                      },
                      icon: const Icon(MoeslimIcons.tasbih),
                      label: Text(context.tr('+1 Shalawat', '+1 Salawat')),
                    ),
                    for (final target in [100, 300, 1000])
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(context.tr('Target $target', 'Goal $target')),
                        selected: _shalawatTarget == target,
                        onSelected: (_) async {
                          final res = await ref.read(shalawatCounterRepoProvider).setTarget(_today, target);
                          setState(() => _shalawatTarget = res.target);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr('Koleksi Bacaan Shalawat Ma\'tsur (Sesuai Sunnah)', 'Authentic Sunnah Salawat Collection'),
        ),
        for (final sh in shalawatCatalog) ...[
          Builder(
            builder: (context) {
              final loc = _shalawatText(context, sh);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(loc.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(
                        sh.arabic,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(sh.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),
                      Text(loc.translation, style: t.bodyMedium),
                      const SizedBox(height: 6),
                      Text(loc.source, style: t.bodySmall?.copyWith(color: scheme.primary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // 39. Daftar Hajat & Doa Pribadi (Prayer List)
  Widget _buildHajatListTab(BuildContext context) {
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
                  context.tr('Tambah Daftar Hajat / Orang yang Didoakan', 'Add Personal Need / Person to Pray For'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('hajat-title-field'),
                  controller: _hajatTitleCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      'Tulis hajat atau nama keluarga/sahabat yang ingin didoakan...',
                      'Write a personal need or name of family/friend to pray for...',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cat in ['Diri Sendiri & Keluarga', 'Orang Tua', 'Kesehatan & Rezeki', 'Ilmu & Akhirat'])
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(_hajatCategoryLabel(context, cat)),
                        selected: _hajatCategory == cat,
                        onSelected: (_) => setState(() => _hajatCategory = cat),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  key: const Key('hajat-add-btn'),
                  onPressed: () async {
                    if (_hajatTitleCtrl.text.trim().isEmpty) return;
                    final next = await ref.read(hajatPrayerListRepoProvider).addHajat(
                          title: _hajatTitleCtrl.text,
                          category: _hajatCategory,
                          now: DateTime.now(),
                        );
                    _hajatTitleCtrl.clear();
                    setState(() => _hajatList = next);
                  },
                  icon: const Icon(MoeslimIcons.tambahLingkar),
                  label: Text(context.tr('Simpan ke Daftar Doa', 'Save to Prayer List')),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(
          context.tr(
            'Daftar Hajat & Doa Pribadi (${_hajatList.length})',
            'Personal Needs & Prayer List (${_hajatList.length})',
          ),
        ),
        if (_hajatList.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr(
                  'Belum ada daftar hajat. Catat hajat penting untuk selalu diingat setiap sujud terakhir dan waktu mustajab.',
                  'No prayer requests yet. Write down your heartfelt needs to remember during sujud and blessed times of dua.',
                ),
              ),
            ),
          )
        else
          for (final item in _hajatList)
            Card(
              child: ListTile(
                leading: Icon(
                  item.isAnswered ? MoeslimIcons.berhasil : MoeslimIcons.cinta,
                  color: item.isAnswered ? scheme.primary : BrandColors.goldText,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: item.isAnswered ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  context.tr(
                    '${item.category} · Dicatat ${item.createdAtKey}${item.isAnswered ? ' · Alhamdulillah Terkabul!' : ''}',
                    '${_hajatCategoryLabel(context, item.category)} · Added ${item.createdAtKey}${item.isAnswered ? ' · Alhamdulillah Answered!' : ''}',
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: Key('hajat-toggle-${item.id}'),
                      tooltip: item.isAnswered
                          ? context.tr('Tandai masih didoakan', 'Mark as still praying')
                          : context.tr('Tandai Alhamdulillah terkabul', 'Mark as answered (Alhamdulillah)'),
                      onPressed: () async {
                        final next = await ref.read(hajatPrayerListRepoProvider).toggleAnswered(item.id);
                        setState(() => _hajatList = next);
                      },
                      icon: Icon(MoeslimIcons.berhasil, color: item.isAnswered ? scheme.primary : null),
                    ),
                    IconButton(
                      tooltip: context.tr('Hapus hajat', 'Delete item'),
                      onPressed: () async {
                        final next = await ref.read(hajatPrayerListRepoProvider).deleteHajat(item.id);
                        setState(() => _hajatList = next);
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

  // 40. Pelacak Kebiasaan Sunnah Harian (Rawatib 12 Rakaat, Dhuha, Witir)
  Widget _buildSunnahHabitsTab(BuildContext context) {
    final rawatibIds = sunnahHabitsCatalog.where((h) => h.isRawatib12).map((h) => h.id).toList();
    final rawatibDoneCount = rawatibIds.where(_completedHabits.contains).length;
    final allRawatib12Done = rawatibDoneCount == rawatibIds.length;
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
                  allRawatib12Done
                      ? context.tr(
                          'Alhamdulillah, 12 Rakaat Sunnah Rawatib Hari Ini Lengkap!',
                          'Alhamdulillah, All 12 Rawatib Sunnah Rakaat Completed Today!',
                        )
                      : context.tr(
                          'Progres 12 Rakaat Sunnah Rawatib: $rawatibDoneCount / ${rawatibIds.length} waktu',
                          '12 Rawatib Sunnah Progress: $rawatibDoneCount / ${rawatibIds.length} prayers',
                        ),
                  key: const Key('sunnah-rawatib-progress'),
                  style: t.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'HR. Muslim no. 728: "Barang siapa mengerjakan salat sunnah 12 rakaat dalam sehari semalam, Allah akan membangunkan untuknya sebuah rumah di surga."',
                    'Sahih Muslim no. 728: "Whoever prays twelve voluntary rakaat in a day and night, a house will be built for them in Paradise."',
                  ),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final h in sunnahHabitsCatalog) ...[
          Builder(
            builder: (context) {
              final loc = _sunnahHabitText(context, h);
              return Card(
                child: CheckboxListTile(
                  key: Key('habit-check-${h.id}'),
                  title: Text(loc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(loc.virtue),
                  value: _completedHabits.contains(h.id),
                  onChanged: (_) async {
                    final next = await ref.read(sunnahHabitRepoProvider).toggleHabit(_today, h.id);
                    setState(() => _completedHabits = next);
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
