import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';

typedef _FiqihStepEn = ({String title, String ruling, String description, String? translation});
typedef _FiqihTopicEn = ({String title, String summary, String dalil, Map<int, _FiqihStepEn> steps});

const Map<String, _FiqihTopicEn> _fiqihEn = {
  'wudhu': (
    title: 'How to Perform Wudu According to the Sunnah',
    summary: 'Sequence of obligatory and sunnah steps of wudu from intention to the closing supplication.',
    dalil: 'Quran 5:6 · Sahih al-Bukhari 159 & Sahih Muslim 226 (Hadith of Uthman ibn Affan RA)',
    steps: {
      1: (
        title: 'Intention in the Heart & Reciting Bismillah',
        ruling: 'Pillar & Sunnah',
        description: 'Make the intention in the heart to remove minor ritual impurity for Allah, then say Bismillah.',
        translation: 'In the name of Allah.',
      ),
      2: (
        title: 'Wash Both Hands (3x), Rinse Mouth & Nose (3x)',
        ruling: 'Confirmed Sunnah',
        description:
            'Wash both hands up to the wrists 3 times, then rinse the mouth and sniff water into the nostrils with the right hand and expel it with the left hand 3 times.',
        translation: null,
      ),
      3: (
        title: 'Wash the Entire Face (3x)',
        ruling: 'Pillar',
        description:
            'Wash the face from the hairline to the chin, and from ear to ear, running wet fingers through a thick beard.',
        translation: null,
      ),
      4: (
        title: 'Wash Both Arms Including the Elbows (3x)',
        ruling: 'Pillar',
        description:
            'Wash the right arm from the fingertips past the elbow 3 times, then the left arm in the same way while washing between the fingers.',
        translation: null,
      ),
      5: (
        title: 'Wipe the Head & Both Ears (1x)',
        ruling: 'Pillar & Sunnah',
        description:
            'Wipe the entire head with wet hands from front to the nape and back to the front, then wipe the inside of the ears with the index fingers and the outside with the thumbs.',
        translation: null,
      ),
      6: (
        title: 'Wash Both Feet Including the Ankles (3x) in Order',
        ruling: 'Pillar',
        description:
            'Wash the right foot past the ankles 3 times while washing between the toes, then the left foot, and conclude with the supplication after wudu.',
        translation:
            'I bear witness that none has the right to be worshipped except Allah alone without partner, and that Muhammad is His servant and Messenger.',
      ),
    },
  ),
  'tayammum': (
    title: 'How to Perform Tayammum (When Water Is Unavailable or Harmful)',
    summary: 'Concession for dry purification using clean earth when water is absent or medically unsafe.',
    dalil: 'Quran 5:6 · Sahih al-Bukhari 338 & Sahih Muslim 368 (Hadith of Ammar ibn Yasir RA)',
    steps: {
      1: (
        title: 'Intention & Strike Both Palms on Clean Dusty Surface',
        ruling: 'Pillar',
        description:
            'Make the intention to perform tayammum for prayer, say Bismillah, strike both palms once on clean earth or a dusty surface, and lightly blow off excess dust.',
        translation: null,
      ),
      2: (
        title: 'Wipe the Face & Both Hands',
        ruling: 'Pillar',
        description:
            'Wipe the entire face once, then wipe the back and palm of the right hand with the left hand, and the left hand with the right hand up to the wrists.',
        translation: null,
      ),
    },
  ),
  'salat_fardhu': (
    title: 'Complete Guide to Pillars & Recitations of Obligatory Prayer',
    summary: 'Sequence of movements and recitations from the opening Takbir to Taslim with calmness (tuma\'ninah).',
    dalil: 'Sahih al-Bukhari 631 ("Pray as you have seen me praying") & Sahih Muslim 397',
    steps: {
      1: (
        title: 'Stand Facing Qibla, Intention & Opening Takbir',
        ruling: 'Pillar',
        description:
            'Stand upright facing the Qibla (if able), hold the intention in the heart, raise both hands to shoulder or ear level, and say Allahu Akbar.',
        translation: 'Allah is the Greatest.',
      ),
      2: (
        title: 'Recite the Opening Dua & Surah Al-Fatihah',
        ruling: 'Sunnah & Pillar',
        description:
            'Recite the opening supplication quietly, seek refuge, say Bismillah, then recite Surah Al-Fatihah verse by verse (a pillar of prayer), ending with Amin.',
        translation:
            'O Allah, distance me from my sins just as You have distanced the east from the west.',
      ),
      3: (
        title: 'Bowing (Ruku\') with Calmness',
        ruling: 'Pillar',
        description:
            'Say Takbir while raising the hands, then bow with a level back and head, palms resting on the knees, pausing calmly.',
        translation: 'Glory be to my Lord, the Most Great.',
      ),
      4: (
        title: 'Rising from Bowing (I\'tidal) with Calmness',
        ruling: 'Pillar',
        description:
            'Rise upright while saying Sami\'allahu liman hamidah, and once standing straight recite Rabbana wa lakal-hamd.',
        translation:
            'Allah hears whoever praises Him. Our Lord, to You belongs all praise, abundant, pure, and blessed.',
      ),
      5: (
        title: 'Prostration (Sujud) on Seven Bones & Sitting Between Prostrations',
        ruling: 'Pillar',
        description:
            'Prostrate placing the forehead with nose, both palms, both knees, and the toes of both feet on the ground. Then sit calmly between the two prostrations.',
        translation:
            'Glory be to my Lord, the Most High. My Lord, forgive me, have mercy on me, mend me, elevate me, provide for me, guide me, and grant me well-being.',
      ),
      6: (
        title: 'Final Tashahhud, Ibrahimiyyah Salawat & Taslim',
        ruling: 'Pillar',
        description:
            'Sit in tawarruk in the final rak\'ah, recite Tashahhud, send blessings upon the Prophet, seek refuge from the four trials, then turn right and left offering Salam.',
        translation: 'May the peace and mercy of Allah be upon you.',
      ),
    },
  ),
  'salat_sunnah_dhuha_tahajud_istikharah': (
    title: 'Duha, Tahajjud (Witr) & Istikharah Prayers',
    summary: 'Prescribed times, rak\'ah counts, and special supplications for key daily sunnah prayers.',
    dalil: 'Sahih Muslim 720 (Duha), Sahih al-Bukhari 1145 (Tahajjud), Sahih al-Bukhari 1166 (Istikharah)',
    steps: {
      1: (
        title: 'Sunnah Duha Prayer (2 to 8 Rak\'ahs)',
        ruling: 'Confirmed Sunnah',
        description:
            'Performed from when the sun rises a spear\'s height (~15 minutes after sunrise) until shortly before zenith (~10 minutes before Dhuhr), prayed two rak\'ahs at a time. It fulfills charity on behalf of all 360 joints.',
        translation: null,
      ),
      2: (
        title: 'Tahajjud Night Prayer & Closing Witr',
        ruling: 'Confirmed Sunnah',
        description:
            'Performed after waking from sleep at night (best in the final third of the night), two rak\'ahs at a time, and concluded with an odd-numbered Witr prayer (1 or 3 rak\'ahs).',
        translation: null,
      ),
      3: (
        title: 'Istikharah Prayer & Supplication (Seeking Guidance)',
        ruling: 'Sunnah',
        description:
            'Pray 2 voluntary rak\'ahs, then after Taslim recite the Istikharah dua while mentioning the decision you are considering.',
        translation:
            'O Allah, I seek Your guidance through Your knowledge, and Your empowerment through Your might, and I ask You of Your immense favor, for You are able while I am not, You know while I do not, and You are the Knower of the unseen.',
      ),
    },
  ),
  'salat_id_dan_gerhana': (
    title: 'Eid Prayer & Eclipse Prayer (Kusuf / Khusuf)',
    summary: 'Extra takbirs in Eid prayer (7 and 5 takbirs) and two bowings per rak\'ah in Eclipse prayer.',
    dalil: 'Sunan Abi Dawud 1149 (Eid Prayer) & Sahih al-Bukhari 1044 (Eclipse Prayer)',
    steps: {
      1: (
        title: 'Eid al-Fitr & Eid al-Adha Prayer (2 Rak\'ahs, No Adhan/Iqamah)',
        ruling: 'Confirmed Sunnah / Communal Obligation',
        description:
            'First rak\'ah: after the opening Takbir and opening dua, say 7 additional takbirs before Al-Fatihah. Second rak\'ah: after rising, say 5 additional takbirs before Al-Fatihah. Praise Allah between takbirs.',
        translation: 'Glory be to Allah, all praise is due to Allah, there is no deity except Allah, and Allah is the Greatest.',
      ),
      2: (
        title: 'Solar (Kusuf) & Lunar (Khusuf) Eclipse Prayer',
        ruling: 'Confirmed Sunnah',
        description:
            'Prayed as 2 rak\'ahs where each rak\'ah includes 2 standings (reciting Al-Fatihah and a long surah), 2 bowings, and 2 prostrations, followed by a sermon reminding believers of Allah\'s majesty.',
        translation: null,
      ),
    },
  ),
  'salat_safar_jama_qashar': (
    title: 'Travel Prayer Guide: Qasr & Jama\' (Combined / Shortened)',
    summary: 'Rules for shortening 4-rak\'ah prayers to 2 and combining two prayer times while traveling.',
    dalil: 'Quran 4:101 · Sahih Muslim 686 & 705',
    steps: {
      1: (
        title: 'Travel Distance Requirement & Prayers Eligible for Qasr',
        ruling: 'Rukhsah (Legal Concession)',
        description:
            'Journey meets the travel distance (~81-89 km) and you have exited your home city limits. Four-rak\'ah prayers (Dhuhr, Asr, Isha) are shortened to 2 rak\'ahs. Fajr (2) and Maghrib (3) are not shortened.',
        translation: null,
      ),
      2: (
        title: 'Combined Prayer Pairs (Dhuhr-Asr & Maghrib-Isha)',
        ruling: 'Rukhsah',
        description:
            'Jama\' Taqdim: praying Dhuhr and Asr during Dhuhr time (or Maghrib and Isha during Maghrib time). Jama\' Takhir: praying both during the later prayer\'s time. Fajr is always prayed in its own time.',
        translation: null,
      ),
    },
  ),
  'salat_jenazah': (
    title: 'How to Perform Funeral Prayer (Janazah - 4 Takbirs)',
    summary: 'Standing prayer with no bowing or prostration, consisting of 4 takbirs with Al-Fatihah, Salawat, and dua for the deceased.',
    dalil: 'Sahih al-Bukhari 1335 & Sahih Muslim 963',
    steps: {
      1: (
        title: 'First Takbir: Recite Surah Al-Fatihah',
        ruling: 'Pillar',
        description:
            'Stand facing the Qibla (the imam stands near the head of a male deceased or the middle of a female deceased), say the opening Takbir, and recite Surah Al-Fatihah.',
        translation: null,
      ),
      2: (
        title: 'Second Takbir: Recite Ibrahimiyyah Salawat',
        ruling: 'Pillar',
        description:
            'Say the second Takbir and send blessings upon Prophet Muhammad (peace be upon him) just as in the final Tashahhud.',
        translation:
            'O Allah, send blessings upon Muhammad and upon the family of Muhammad, as You sent blessings upon Ibrahim and upon the family of Ibrahim; indeed You are Praiseworthy and Glorious.',
      ),
      3: (
        title: 'Third Takbir: Supplication for the Deceased',
        ruling: 'Pillar',
        description: 'Say the third Takbir and supplicate for forgiveness, mercy, and spaciousness in the grave for the deceased.',
        translation:
            'O Allah, forgive them, have mercy on them, grant them peace, pardon them, honor their resting place, expand their entrance, and wash them with water, snow, and hail.',
      ),
      4: (
        title: 'Fourth Takbir & Salam',
        ruling: 'Pillar',
        description: 'Say the fourth Takbir, recite a brief closing supplication, then offer Salam to the right (and optionally to the left).',
        translation: 'O Allah, do not deprive us of their reward, do not put us to trial after them, and forgive us and them.',
      ),
    },
  ),
};

String _fiqihCategoryLabel(BuildContext context, FiqihCategory cat) => switch (cat) {
      FiqihCategory.thaharah => context.tr(cat.label, 'Purification (Taharah)'),
      FiqihCategory.salatFardhu => context.tr(cat.label, 'Obligatory Prayers'),
      FiqihCategory.salatSunnah => context.tr(cat.label, 'Sunnah Prayers'),
      FiqihCategory.salatSafar => context.tr(cat.label, 'Travel Prayer (Jama\' & Qasr)'),
      FiqihCategory.salatJenazah => context.tr(cat.label, 'Funeral Prayer (Janazah)'),
    };

class FiqihGuidePage extends StatefulWidget {
  const FiqihGuidePage({super.key});

  @override
  State<FiqihGuidePage> createState() => _FiqihGuidePageState();
}

class _FiqihGuidePageState extends State<FiqihGuidePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  FiqihCategory? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _selectedCategory = null;
    });
  }

  bool _matchesTopic(BuildContext context, FiqihGuideTopic topic, String query) {
    if (topic.matches(query)) return true;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final en = _fiqihEn[topic.id];
    final catLabel = _fiqihCategoryLabel(context, topic.category).toLowerCase();
    if (catLabel.contains(q)) return true;
    if (en == null) return false;
    return en.title.toLowerCase().contains(q) ||
        en.summary.toLowerCase().contains(q) ||
        en.dalil.toLowerCase().contains(q) ||
        en.steps.values.any((s) => s.title.toLowerCase().contains(q) || s.description.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    final filtered = [
      for (final topic in fiqihGuideCatalog)
        if ((_selectedCategory == null || topic.category == _selectedCategory) && _matchesTopic(context, topic, _query))
          topic,
    ];
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Panduan Ibadah & Fiqih', 'Worship & Fiqh Guide')), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PatternBanner(
                    child: Text(
                      context.tr(
                        'Tuntunan langkah demi langkah wudhu, tayammum, salat fardhu, salat sunnah, salat safar, hingga salat jenazah beserta bacaannya.',
                        'Step-by-step guidance for wudu, tayammum, obligatory prayers, sunnah prayers, travel prayers, and funeral prayers with recitations.',
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('fiqih-search'),
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(MoeslimIcons.pencarian),
                      hintText: context.tr(
                        'Cari panduan (mis. wudhu, tayammum, istikharah, qashar, jenazah)',
                        'Search guide (e.g. wudu, tayammum, istikharah, qasr, janazah)',
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              key: const Key('fiqih-search-clear'),
                              tooltip: context.tr('Hapus pencarian', 'Clear search'),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(
                        context.tr('Semua (${fiqihGuideCatalog.length})', 'All (${fiqihGuideCatalog.length})'),
                      ),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                  ),
                  for (final cat in FiqihCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(_fiqihCategoryLabel(context, cat)),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(() => _selectedCategory = _selectedCategory == cat ? null : cat),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(MoeslimIcons.buku, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('Panduan tidak ditemukan', 'Guide not found'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          'Tidak ada materi fiqih yang cocok dengan "${_searchCtrl.text.trim()}".',
                          'No fiqh guide matches "${_searchCtrl.text.trim()}".',
                        ),
                        textAlign: TextAlign.center,
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('fiqih-reset-filter'),
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh),
                        label: Text(context.tr('Reset filter', 'Reset filters')),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final topic = filtered[index];
                  final en = isEn ? _fiqihEn[topic.id] : null;
                  final catLabel = _fiqihCategoryLabel(context, topic.category);
                  return Card(
                    child: ListTile(
                      leading: OctagonNumber(index + 1),
                      title: Text(en?.title ?? topic.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        context.tr(
                          '${topic.category.label} · ${topic.steps.length} langkah\n${topic.summary}',
                          '$catLabel · ${topic.steps.length} steps\n${en?.summary ?? topic.summary}',
                        ),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FiqihTopicDetailPage(topic: topic)),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FiqihTopicDetailPage extends StatelessWidget {
  final FiqihGuideTopic topic;
  const FiqihTopicDetailPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final en = context.isEn ? _fiqihEn[topic.id] : null;

    return Scaffold(
      appBar: AppBar(title: Text(_fiqihCategoryLabel(context, topic.category)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: Column(
              children: [
                Text(
                  en?.title ?? topic.title,
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(en?.summary ?? topic.summary, textAlign: TextAlign.center, style: t.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  en?.dalil ?? topic.dalil,
                  textAlign: TextAlign.center,
                  style: t.bodySmall?.copyWith(color: scheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final step in topic.steps) ...[
            Builder(
              builder: (context) {
                final stepEn = en?.steps[step.number];
                final stepTitle = stepEn?.title ?? step.title;
                final stepRuling = stepEn?.ruling ?? step.ruling;
                final stepDesc = stepEn?.description ?? step.description;
                final stepTrans = stepEn?.translation ?? step.translation;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            OctagonNumber(step.number),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stepTitle, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  Text(
                                    context.tr('Hukum: ${step.ruling}', 'Ruling: $stepRuling'),
                                    style: t.bodySmall?.copyWith(color: scheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(stepDesc, style: t.bodyMedium),
                        if (step.arabic != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            step.arabic!,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: quranTextStyle(fontSize: 24),
                          ),
                        ],
                        if (step.latin != null) ...[
                          const SizedBox(height: 6),
                          Text(step.latin!, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                        ],
                        if (stepTrans != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            context.tr('Artinya: "${step.translation!}"', 'Meaning: "$stepTrans"'),
                            style: t.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
