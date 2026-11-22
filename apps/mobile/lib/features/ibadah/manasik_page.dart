import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class ManasikPage extends ConsumerStatefulWidget {
  const ManasikPage({super.key});

  @override
  ConsumerState<ManasikPage> createState() => _ManasikPageState();
}

class _ManasikPageState extends ConsumerState<ManasikPage> {
  int _tab = 0;
  ManasikCounterState _state = const ManasikCounterState();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ref.read(manasikRepoProvider).load();
    if (mounted) {
      setState(() {
        _state = s;
        _loading = false;
      });
    }
  }

  Future<void> _save(ManasikCounterState next) async {
    await ref.read(manasikRepoProvider).save(next);
    if (mounted) setState(() => _state = next);
  }

  ({String title, String ruling, String location, String description, String translation}) _localizedStep(
    BuildContext context,
    ManasikStep s,
  ) {
    if (!context.isEn) {
      return (
        title: s.title,
        ruling: s.ruling,
        location: s.location,
        description: s.description,
        translation: s.translation,
      );
    }
    return switch (s.order) {
      1 => (
          title: 'Ihram from Miqat & Reciting Talbiyah',
          ruling: 'Pillar & Obligatory',
          location: 'Miqat (Dhul Hulayfah / Bir Ali, Juhfah, Qarn al-Manazil, Yalamlam)',
          description:
              'Take the sunnah ghusl bath, wear Ihram garments (two unstitched white cloths for men; modest attire without niqab or gloves for women), make the intention for Ihram at the Miqat, and recite the Talbiyah frequently.',
          translation:
              'Here I am, O Allah, for Umrah. Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise, grace, and sovereignty belong to You; You have no partner.',
        ),
      2 => (
          title: 'Tawaf Around the Kaaba (7 Circuits)',
          ruling: 'Pillar',
          location: 'Al-Masjid al-Haram (Starts & ends aligned with Hajar al-Aswad)',
          description:
              'In a state of ritual purity, circle the Kaaba 7 times counter-clockwise (keeping the Kaaba on your left). Say Bismillahi Allahu Akbar when aligned with Hajar al-Aswad, and recite the Rabbana supplication between Rukn al-Yamani and Hajar al-Aswad.',
          translation:
              'In the name of Allah, and Allah is the Greatest. Our Lord, grant us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
        ),
      3 => (
          title: '2 Rakaat Prayer Behind Maqam Ibrahim & Drinking Zamzam',
          ruling: 'Confirmed Sunnah',
          location: 'Behind Maqam Ibrahim / Al-Masjid al-Haram',
          description:
              'Perform 2 rakaat of Tawaf prayer (reciting Surah Al-Kafirun in the first rakaat and Surah Al-Ikhlas in the second after Al-Fatihah), then drink Zamzam water while making dua.',
          translation: 'And take from the standing place of Abraham a place of prayer. (QS. Al-Baqarah: 125)',
        ),
      4 => (
          title: 'Sa\'i Between Mount Safa and Mount Marwah (7 Laps)',
          ruling: 'Pillar',
          location: 'Mas\'a (Starts at Mount Safa and ends at Mount Marwah)',
          description:
              'Head to Mount Safa, face the Kaaba while praising Allah and reciting takbir and tahlil. Walking from Safa to Marwah counts as lap 1, and Marwah to Safa as lap 2, completing 7 laps ending at Marwah.',
          translation: 'Indeed, Safa and Marwah are among the symbols of Allah. (QS. Al-Baqarah: 158)',
        ),
      5 => (
          title: 'Tahallul (Shaving or Trimming Hair)',
          ruling: 'Pillar / Obligatory',
          location: 'Mount Marwah / Around Al-Masjid al-Haram',
          description:
              'Men shave the entire head (halq, preferred) or trim hair evenly (taqsir). Women trim the tips of their hair by the length of a fingertip. With Tahallul, the rites of Umrah are complete.',
          translation: 'O Allah, forgive those who shave their heads. (Sahih al-Bukhari & Muslim)',
        ),
      _ => (
          title: 'Peak of Hajj: Wuquf at Arafah, Muzdalifah & Mina (8-13 Dhu al-Hijjah)',
          ruling: 'Peak Pillars of Hajj',
          location: 'Arafah (9 Dhu al-Hijjah), Muzdalifah & Mina',
          description:
              'On 8 Dhu al-Hijjah enter Hajj Ihram and stay in Mina (Tarwiyah). On 9 Dhu al-Hijjah perform Wuquf at Arafah from midday (combining and shortening Dhuhr and Asr) until sunset in earnest dhikr and dua. Spend the night of 10 Dhu al-Hijjah in Muzdalifah, then stone Jamarat al-Aqabah, offer Hadyu sacrifice, perform Tahallul and Tawaf al-Ifadah, and stay in Mina during the Days of Tashriq (11-13 Dhu al-Hijjah).',
          translation:
              'The best supplication on the Day of Arafah: There is no deity worthy of worship except Allah alone without partner; to Him belongs dominion and praise, and He has power over all things.',
        ),
    };
  }

  String _saiDirection(BuildContext context) {
    if (!context.isEn) return _state.saiRouteDirection;
    if (_state.saiLap >= 7) return 'Completed 7 Laps at Mount Marwah (Proceed to Tahallul)';
    final nextLap = _state.saiLap + 1;
    return nextLap.isOdd
        ? 'Lap $nextLap: Mount Safa to Mount Marwah'
        : 'Lap $nextLap: Mount Marwah to Mount Safa';
  }

  static const _packingEn = [
    'Ihram cloths (2 sets for men) & unstitched ihram belt',
    'Loose modest attire & thick socks for Tawaf and Sa\'i',
    'Small folding scissors for Tahallul (pack in checked luggage)',
    'Personal medications, unscented moisturizer/petroleum jelly, and masks',
    'Copies of passport, visa, vaccination record, and emergency ID',
    'Pocket guide / Moeslim PM offline app for Tawaf, Sa\'i & Wuquf duas',
  ];

  static const _prohibitionsEn = [
    'Wearing stitched garments fitted to the body (for men).',
    'Covering the head for men, or covering the face (niqab) and wearing gloves for women.',
    'Applying perfume or scented products to the body or clothing after entering Ihram.',
    'Cutting nails or shaving/plucking hair from the head or body.',
    'Conducting a marriage contract, proposing marriage, or marital relations.',
    'Hunting or killing land game animals within the Sacred Precinct.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Manasik Haji & Umrah', 'Hajj & Umrah Manasik')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Urutan Manasik', 'Manasik Steps'),
                context.tr('Counter Thawaf & Sa\'i', 'Tawaf & Sa\'i Counter'),
                context.tr('Checklist Safar', 'Travel Checklist'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : switch (_tab) {
                    0 => _buildStepsTab(context),
                    1 => _buildCountersTab(context),
                    _ => _buildChecklistTab(context),
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: manasikUmrahHajiSteps.length,
      itemBuilder: (context, index) {
        final s = manasikUmrahHajiSteps[index];
        final loc = _localizedStep(context, s);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    OctagonNumber(s.order),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text('${loc.ruling} · ${loc.location}', style: t.bodySmall?.copyWith(color: scheme.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(loc.description, style: t.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  s.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(s.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(context.tr('Artinya: "${loc.translation}"', 'Meaning: "${loc.translation}"'), style: t.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountersTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('1. Penghitung Thawaf (7 Putaran)', '1. Tawaf Counter (7 Circuits)'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('Reset putaran Thawaf', 'Reset Tawaf circuits'),
                      onPressed: () => _save(_state.copyWith(thawafLap: 0)),
                      icon: const Icon(MoeslimIcons.ulang),
                    ),
                  ],
                ),
                Text(
                  context.tr(
                    'Putaran Selesai: ${_state.thawafLap} / 7',
                    'Completed Circuits: ${_state.thawafLap} / 7',
                  ),
                  key: const Key('manasik-thawaf-count'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _state.thawafLap / 7.0, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 10),
                Text(
                  '${context.tr('Doa Antara Rukun Yamani & Hajar Aswad:', 'Supplication Between Rukn al-Yamani & Hajar al-Aswad:')}\n'
                  'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n'
                  '"Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adzaban-nar."',
                  style: t.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('manasik-thawaf-tap'),
                  onPressed: _state.thawafLap >= 7
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _save(_state.copyWith(thawafLap: _state.thawafLap + 1));
                        },
                  icon: Icon(_state.thawafLap >= 7 ? MoeslimIcons.berhasil : MoeslimIcons.tasbih),
                  label: Text(
                    _state.thawafLap >= 7
                        ? context.tr('Thawaf 7 Putaran Selesai', 'Tawaf 7 Circuits Complete')
                        : context.tr('Tambah 1 Putaran Thawaf', 'Add 1 Tawaf Circuit'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('2. Penghitung Sa\'i Shafa–Marwah (7 Lintasan)', '2. Sa\'i Safa-Marwah Counter (7 Laps)'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('Reset lintasan Sa\'i', 'Reset Sa\'i laps'),
                      onPressed: () => _save(_state.copyWith(saiLap: 0)),
                      icon: const Icon(MoeslimIcons.ulang),
                    ),
                  ],
                ),
                Text(
                  context.tr(
                    'Lintasan Selesai: ${_state.saiLap} / 7',
                    'Completed Laps: ${_state.saiLap} / 7',
                  ),
                  key: const Key('manasik-sai-count'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(_saiDirection(context), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _state.saiLap / 7.0, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('manasik-sai-tap'),
                  onPressed: _state.saiLap >= 7
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _save(_state.copyWith(saiLap: _state.saiLap + 1));
                        },
                  icon: Icon(_state.saiLap >= 7 ? MoeslimIcons.berhasil : MoeslimIcons.tasbih),
                  label: Text(
                    _state.saiLap >= 7
                        ? context.tr('Sa\'i 7 Lintasan Selesai', 'Sa\'i 7 Laps Complete')
                        : context.tr('Tambah 1 Lintasan Sa\'i', 'Add 1 Sa\'i Lap'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final packingItems = context.isEn ? _packingEn : manasikPackingChecklist;
    final prohibitions = context.isEn ? _prohibitionsEn : ihramProhibitions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SectionHeader(context.tr('Checklist Persiapan Safar Haji & Umrah', 'Hajj & Umrah Travel Checklist')),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < packingItems.length; i++)
                CheckboxListTile(
                  key: Key('manasik-pack-$i'),
                  title: Text(packingItems[i]),
                  value: _state.checkedPackingIndexes.contains(i),
                  onChanged: (v) {
                    final next = Set<int>.from(_state.checkedPackingIndexes);
                    if (v == true) {
                      next.add(i);
                    } else {
                      next.remove(i);
                    }
                    _save(_state.copyWith(checkedPackingIndexes: next));
                  },
                ),
            ],
          ),
        ),
        SectionHeader(context.tr('Larangan Selama Berihram', 'Prohibitions During Ihram')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in prohibitions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $item', style: t.bodyMedium),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
