import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'utility_accessibility_page.dart';

typedef _GuidedDzikirEn = ({String title, String translation, String source, String virtue});

const Map<String, _GuidedDzikirEn> _guidedDzikirEn = {
  'pagi_ayat_kursi': (
    title: 'Recite Ayat al-Kursi',
    translation:
        'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
    source: 'Quran 2:255 · Al-Nasa\'i & Al-Tabarani (Sahih)',
    virtue: 'Whoever recites it in the morning will be protected from jinn until evening.',
  ),
  'pagi_ikhlas': (
    title: 'Surah Al-Ikhlas',
    translation:
        'Say, He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
    source: 'Abu Dawud 5082 & Al-Tirmidhi 3575 (Hasan Sahih)',
    virtue: 'Reciting Al-Ikhlas, Al-Falaq, and An-Nas three times each in the morning and evening suffices against everything.',
  ),
  'pagi_falaq': (
    title: 'Surah Al-Falaq',
    translation:
        'Say, I seek refuge in the Lord of daybreak, from the evil of that which He created, and from the evil of darkness when it settles.',
    source: 'Abu Dawud 5082 & Al-Tirmidhi 3575',
    virtue: 'Protection with Allah from the evil of creation, the darkness of night, sorcery, and envy.',
  ),
  'pagi_nas': (
    title: 'Surah An-Nas',
    translation:
        'Say, I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer who whispers into the breasts of mankind, from among the jinn and mankind.',
    source: 'Abu Dawud 5082 & Al-Tirmidhi 3575',
    virtue: 'A shield guarding the heart from whispering doubts of devils among jinn and humans.',
  ),
  'pagi_asbahna_mulku': (
    title: 'Morning Remembrance of Sovereignty',
    translation:
        'We have reached the morning and at this very time all sovereignty belongs to Allah, and all praise is for Allah. None has the right to be worshipped except Allah alone, without partner.',
    source: 'Sahih Muslim 2723',
    virtue: 'Seeking the good of this day and refuge from the evil of this day and what follows it.',
  ),
  'pagi_sayyidul_istighfar': (
    title: 'Sayyidul Istighfar (Master Supplication for Forgiveness)',
    translation:
        'O Allah, You are my Lord; none has the right to be worshipped except You. You created me and I am Your servant. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me.',
    source: 'Sahih al-Bukhari 6306',
    virtue: 'Whoever recites it with certainty in the morning and dies before evening will enter Paradise.',
  ),
  'pagi_bika_asbahna': (
    title: 'Reliance Upon Allah at Dawn',
    translation:
        'O Allah, by Your leave we have reached the morning and by Your leave we reach the evening, by Your leave we live and die, and unto You is our resurrection.',
    source: 'Al-Tirmidhi 3391 & Abu Dawud 5068 (Sahih)',
    virtue: 'Affirms that life, death, and resurrection rest entirely in the hands of Allah.',
  ),
  'pagi_afiyah': (
    title: 'Dua for Well-Being in Faith, World & Family',
    translation:
        'O Allah, I ask You for pardon and well-being in this life and the next. O Allah, I ask You for pardon and well-being in my religion, my worldly affairs, my family, and my wealth.',
    source: 'Abu Dawud 5074 & Ibn Majah 3871 (Sahih)',
    virtue: 'A supplication the Prophet (peace be upon him) never omitted morning or evening for complete protection.',
  ),
  'pagi_bismillah_layadhurru': (
    title: 'Protection from Sudden Harm',
    translation:
        'In the name of Allah, with whose name nothing on earth or in the heavens can cause harm, and He is the All-Hearing, the All-Knowing.',
    source: 'Abu Dawud 5088 & Al-Tirmidhi 3388 (Sahih)',
    virtue: 'Whoever recites it 3 times in the morning and evening will not be harmed by anything.',
  ),
  'pagi_radhitu': (
    title: 'Pledge of Contentment with Allah, Islam & the Prophet',
    translation: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (peace be upon him) as my Prophet.',
    source: 'Musnad Ahmad IV/337 & Al-Tirmidhi 3389 (Hasan)',
    virtue: 'Whoever recites it 3 times morning and evening, Allah has promised to please them on the Day of Resurrection.',
  ),
  'pagi_ya_hayyu': (
    title: 'Seeking Rectification of All Affairs',
    translation:
        'O Ever-Living, O Sustainer, in Your mercy I seek relief. Rectify all of my affairs and do not leave me to myself even for the blink of an eye.',
    source: 'Al-Hakim I/545 & Al-Nasa\'i, Amal al-Yawm wal-Laylah 575 (Hasan)',
    virtue: 'Counsel of the Prophet (peace be upon him) to Fatimah (RA) for serenity and divine aid in every matter.',
  ),
  'pagi_subhanallah_wabihamdih': (
    title: 'Morning Tasbih & Tahmid',
    translation: 'Glory be to Allah and praise be to Him.',
    source: 'Sahih Muslim 2692',
    virtue: 'Forgives sins even if they are like the foam of the sea, and none will bring a better deed on the Day of Resurrection except one who recited similarly.',
  ),
  'petang_ayat_kursi': (
    title: 'Recite Ayat al-Kursi',
    translation:
        'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep.',
    source: 'Quran 2:255 · Al-Nasa\'i (Sahih)',
    virtue: 'Whoever recites it in the evening will be protected from jinn until morning.',
  ),
  'petang_ikhlas': (
    title: 'Surah Al-Ikhlas',
    translation: 'Say, He is Allah, the One. Allah, the Eternal Refuge.',
    source: 'Abu Dawud 5082 & Al-Tirmidhi 3575',
    virtue: 'Suffices as a believer\'s protection against all harm through the night.',
  ),
  'petang_falaq': (
    title: 'Surah Al-Falaq',
    translation: 'Say, I seek refuge in the Lord of daybreak, from the evil of that which He created.',
    source: 'Abu Dawud 5082 & Al-Tirmidhi 3575',
    virtue: 'Protection from the evils of the night when darkness settles.',
  ),
  'petang_nas': (
    title: 'Surah An-Nas',
    translation: 'Say, I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind.',
    source: 'Abu Dawud 5082 & Al-Tirmidhi 3575',
    virtue: 'Protection from satanic whisperings during the evening and night.',
  ),
  'petang_amsayna_mulku': (
    title: 'Evening Remembrance of Sovereignty',
    translation:
        'We have reached the evening and at this very time all sovereignty belongs to Allah, and all praise is for Allah. None has the right to be worshipped except Allah alone.',
    source: 'Sahih Muslim 2723',
    virtue: 'Seeking the good of this night and refuge from the evil of this night and the nights after it.',
  ),
  'petang_sayyidul_istighfar': (
    title: 'Evening Sayyidul Istighfar',
    translation:
        'O Allah, You are my Lord; none has the right to be worshipped except You. You created me and I am Your servant.',
    source: 'Sahih al-Bukhari 6306',
    virtue: 'Whoever recites it with certainty in the evening and passes away that night will enter Paradise.',
  ),
  'petang_bismillah_layadhurru': (
    title: 'Night Protection from Harm',
    translation:
        'In the name of Allah, with whose name nothing on earth or in the heavens can cause harm, and He is the All-Hearing, the All-Knowing.',
    source: 'Abu Dawud 5088 & Al-Tirmidhi 3388',
    virtue: 'Protection from sudden harm throughout the night until dawn.',
  ),
  'petang_audzu_bikalimatillah': (
    title: 'Refuge in the Perfect Words of Allah',
    translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    source: 'Sahih Muslim 2709',
    virtue: 'Protects from venomous creatures and nighttime harm.',
  ),
  'petang_subhanallah_wabihamdih': (
    title: 'Evening Tasbih & Tahmid',
    translation: 'Glory be to Allah and praise be to Him.',
    source: 'Sahih Muslim 2692',
    virtue: 'Erases daily sins and weighs heavily on the scale of good deeds.',
  ),
  'salat_istighfar_salam': (
    title: 'Istighfar (3x) & Praise of As-Salam',
    translation:
        'I seek forgiveness from Allah (3x). O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of majesty and honor.',
    source: 'Sahih Muslim 591',
    virtue: 'The very first remembrance the Prophet (peace be upon him) recited immediately after finishing obligatory prayer.',
  ),
  'salat_tahlil_wahdah': (
    title: 'Tahlil & Affirming Allah\'s Sovereignty',
    translation:
        'None has the right to be worshipped except Allah alone, without partner. O Allah, none can prevent what You have willed to bestow, and none can bestow what You have willed to prevent.',
    source: 'Sahih al-Bukhari 844 & Sahih Muslim 593',
    virtue: 'Reinforces pure monotheism after every obligatory prayer.',
  ),
  'salat_ainni_ala_dzikrika': (
    title: 'Dua for Help in Remembrance & Gratitude',
    translation: 'O Allah, help me to remember You, to give thanks to You, and to worship You in the best of manners.',
    source: 'Abu Dawud 1522 & Al-Nasa\'i 1303 (Sahih)',
    virtue: 'Beloved advice of the Prophet (peace be upon him) to Mu\'adh ibn Jabal (RA) never to omit after each prayer.',
  ),
  'salat_ayat_kursi': (
    title: 'Ayat al-Kursi After Prayer',
    translation:
        'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence.',
    source: 'Al-Nasa\'i, Amal al-Yawm wal-Laylah 100 (Sahih)',
    virtue: 'Whoever recites Ayat al-Kursi after every obligatory prayer, nothing prevents them from entering Paradise except death.',
  ),
  'salat_tasbih_33': (
    title: 'Tasbih (Subhanallah) 33 Times',
    translation: 'Glory be to Allah.',
    source: 'Sahih Muslim 597',
    virtue: 'First part of the 99 post-prayer remembrances that erase sins.',
  ),
  'salat_tahmid_33': (
    title: 'Tahmid (Alhamdulillah) 33 Times',
    translation: 'All praise is due to Allah.',
    source: 'Sahih Muslim 597',
    virtue: 'Second part of the 99 post-prayer remembrances.',
  ),
  'salat_takbir_33': (
    title: 'Takbir (Allahu Akbar) 33 Times',
    translation: 'Allah is the Greatest.',
    source: 'Sahih Muslim 597',
    virtue: 'Third part of the 99 post-prayer remembrances.',
  ),
  'salat_penggenap_100': (
    title: 'Completing the Hundredth with Tahlil',
    translation:
        'None has the right to be worshipped except Allah alone, without partner. To Him belongs all sovereignty and praise, and He is over all things omnipotent.',
    source: 'Sahih Muslim 597',
    virtue: 'Completes the 99 tasbih-tahmid-takbir to 100; sins are forgiven even if like the foam of the sea.',
  ),
};

class GuidedDzikirPage extends StatefulWidget {
  final GuidedDzikirTime initialTime;
  const GuidedDzikirPage({super.key, this.initialTime = GuidedDzikirTime.pagi});

  @override
  State<GuidedDzikirPage> createState() => _GuidedDzikirPageState();
}

class _GuidedDzikirPageState extends State<GuidedDzikirPage> {
  final _bodyKey = GlobalKey<GuidedDzikirBodyState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Dzikir Terpandu', 'Guided Dhikr')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('guided-dzikir-reset-session'),
            tooltip: context.tr('Ulangi sesi ini', 'Reset this session'),
            onPressed: () => _bodyKey.currentState?.resetSession(),
            icon: const Icon(MoeslimIcons.ulang),
          ),
        ],
      ),
      body: GuidedDzikirBody(
        key: _bodyKey,
        initialTime: widget.initialTime,
        showInlineReset: false,
      ),
    );
  }
}

/// Konten interaktif Dzikir Terpandu (Pagi, Petang, Ba'da Salat) yang dapat dipakai
/// langsung di halaman Doa & Dzikir maupun halaman mandiri.
class GuidedDzikirBody extends ConsumerStatefulWidget {
  final GuidedDzikirTime initialTime;
  final bool showInlineReset;

  const GuidedDzikirBody({
    super.key,
    this.initialTime = GuidedDzikirTime.pagi,
    this.showInlineReset = true,
  });

  @override
  ConsumerState<GuidedDzikirBody> createState() => GuidedDzikirBodyState();
}

class GuidedDzikirBodyState extends ConsumerState<GuidedDzikirBody> {
  late int _tabIndex;
  Map<String, int> _counts = {};
  bool _loading = true;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  GuidedDzikirTime get _currentTime => GuidedDzikirTime.values[_tabIndex];

  @override
  void initState() {
    super.initState();
    _tabIndex = GuidedDzikirTime.values.indexOf(widget.initialTime);
    _load();
  }

  Future<void> _load() async {
    final counts = await ref.read(guidedDzikirRepoProvider).countsForDay(_today);
    if (mounted) {
      setState(() {
        _counts = counts;
        _loading = false;
      });
    }
  }

  Future<void> _tapItem(GuidedDzikirItem item) async {
    final repo = ref.read(guidedDzikirRepoProvider);
    final next = await repo.increment(_today, item);
    if (next >= item.targetCount) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    final updated = Map<String, int>.from(_counts)..[item.id] = next;
    setState(() => _counts = updated);
    await _syncTrackerIfCompleted(updated);
  }

  Future<void> _completeDirectly(GuidedDzikirItem item) async {
    final repo = ref.read(guidedDzikirRepoProvider);
    final next = await repo.setCount(_today, item, item.targetCount);
    HapticFeedback.mediumImpact();
    final updated = Map<String, int>.from(_counts)..[item.id] = next;
    setState(() => _counts = updated);
    await _syncTrackerIfCompleted(updated);
  }

  Future<void> _resetItem(GuidedDzikirItem item) async {
    await ref.read(guidedDzikirRepoProvider).setCount(_today, item, 0);
    setState(() => _counts = Map<String, int>.from(_counts)..[item.id] = 0);
  }

  Future<void> resetSession() async {
    await ref.read(guidedDzikirRepoProvider).resetSession(_today, _currentTime);
    await _load();
  }

  Future<void> _syncTrackerIfCompleted(Map<String, int> counts) async {
    final items = guidedDzikirFor(_currentTime);
    final allDone = items.isNotEmpty && items.every((e) => (counts[e.id] ?? 0) >= e.targetCount);
    if (allDone) {
      final tracker = ref.read(trackerRepoProvider);
      final dayItems = await tracker.day(_today);
      if (!dayItems.contains(TrackerItem.dzikir)) {
        await tracker.toggle(_today, TrackerItem.dzikir);
      }
    }
  }

  String _timeLabel(BuildContext context, GuidedDzikirTime time) => switch (time) {
        GuidedDzikirTime.pagi => context.tr(time.label, 'Morning Dhikr'),
        GuidedDzikirTime.petang => context.tr(time.label, 'Evening Dhikr'),
        GuidedDzikirTime.badaSalat => context.tr(time.label, 'Post-Prayer Dhikr'),
      };

  String _timeHint(BuildContext context, GuidedDzikirTime time) => switch (time) {
        GuidedDzikirTime.pagi => context.tr(
            time.timeHint,
            'Recited after Fajr prayer until sunrise or Duha time.',
          ),
        GuidedDzikirTime.petang => context.tr(
            time.timeHint,
            'Recited after Asr prayer until Maghrib or early evening.',
          ),
        GuidedDzikirTime.badaSalat => context.tr(
            time.timeHint,
            'Recited after completing each of the five daily obligatory prayers.',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final items = guidedDzikirFor(_currentTime);
    final completedCount = items.where((e) => (_counts[e.id] ?? 0) >= e.targetCount).length;
    final progress = items.isEmpty ? 0.0 : completedCount / items.length;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final isEn = context.isEn;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: PillTabs(
            labels: [
              context.tr('Dzikir Pagi', 'Morning Dhikr'),
              context.tr('Dzikir Petang', 'Evening Dhikr'),
              context.tr('Ba\'da Salat', 'After Prayer'),
            ],
            index: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ContextualDzikirReminderCard(
                            onSelectTab: (tab) => setState(() => _tabIndex = tab),
                          ),
                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _tabIndex == 0
                                            ? MoeslimIcons.matahari
                                            : (_tabIndex == 1 ? MoeslimIcons.bulan : MoeslimIcons.zikr),
                                        color: scheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _timeLabel(context, _currentTime),
                                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        context.tr(
                                          '$completedCount / ${items.length} selesai',
                                          '$completedCount / ${items.length} done',
                                        ),
                                        key: const Key('guided-dzikir-progress-text'),
                                        style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                                      ),
                                      if (widget.showInlineReset) ...[
                                        const SizedBox(width: 4),
                                        IconButton(
                                          key: const Key('guided-dzikir-reset-session'),
                                          tooltip: context.tr('Ulangi sesi ini', 'Reset this session'),
                                          visualDensity: VisualDensity.compact,
                                          onPressed: resetSession,
                                          icon: const Icon(MoeslimIcons.ulang, size: 18),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(_timeHint(context, _currentTime), style: t.bodySmall),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                      final item = items[index - 1];
                      final count = _counts[item.id] ?? 0;
                      final done = count >= item.targetCount;
                      final en = isEn ? _guidedDzikirEn[item.id] : null;
                      final title = en?.title ?? item.title;
                      final source = en?.source ?? item.source;
                      final translation = en?.translation ?? item.translation;
                      final virtue = en?.virtue ?? item.virtue;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: done ? scheme.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
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
                                        Text(
                                          title,
                                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Target: ${item.targetCount}x · $source',
                                          style: t.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (done)
                                    Icon(
                                      MoeslimIcons.berhasil,
                                      color: scheme.primary,
                                      semanticLabel: context.tr('Selesai', 'Completed'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                item.arabic,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: quranTextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.latin,
                                style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 6),
                              Text(translation, style: t.bodyMedium),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: .07),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  context.tr('Keutamaan: $virtue', 'Virtue: $virtue'),
                                  style: t.bodySmall,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  FilledButton.icon(
                                    key: Key('tap-dzikir-${item.id}'),
                                    onPressed: done ? null : () => _tapItem(item),
                                    icon: Icon(done ? MoeslimIcons.berhasil : MoeslimIcons.tasbih),
                                    label: Text(
                                      done
                                          ? context.tr(
                                              'Selesai ($count/${item.targetCount})',
                                              'Completed ($count/${item.targetCount})',
                                            )
                                          : context.tr(
                                              'Hitung Bacaan ($count/${item.targetCount})',
                                              'Count Recitation ($count/${item.targetCount})',
                                            ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!done && item.targetCount > 1)
                                        OutlinedButton(
                                          key: Key('done-dzikir-${item.id}'),
                                          onPressed: () => _completeDirectly(item),
                                          child: Text(context.tr('Tandai Selesai', 'Mark Done')),
                                        ),
                                      if (count > 0) ...[
                                        const SizedBox(width: 6),
                                        IconButton(
                                          tooltip: context.tr('Reset bacaan ini', 'Reset this count'),
                                          onPressed: () => _resetItem(item),
                                          icon: const Icon(MoeslimIcons.ulang),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
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
}

class _ContextualDzikirReminderCard extends ConsumerWidget {
  final ValueChanged<int> onSelectTab;
  const _ContextualDzikirReminderCard({required this.onSelectTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final advice = evaluateContextualSunnahForTime(now, lang: context.lang).first;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Card(
      key: const Key('dzikir-contextual-sunnah-card'),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(MoeslimIcons.bintang, color: scheme.primary),
        title: Text(advice.title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('${advice.timeWindowLabel} · ${advice.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (advice.actionType == 'dzikir_pagi') {
            onSelectTab(0);
          } else if (advice.actionType == 'dzikir_petang') {
            onSelectTab(1);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UtilityAccessibilityPage(initialTab: 4)),
            );
          }
        },
      ),
    );
  }
}
