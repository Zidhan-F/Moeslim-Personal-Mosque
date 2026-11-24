import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'asmaul_husna_audio.dart';

const Map<int, (String, String)> _asmaulEn = {
  1: ('The Most Merciful', 'Bestows boundless mercy and blessings upon all creation in this world.'),
  2: ('The Especially Merciful', 'Bestows special, eternal mercy upon the believers in the Hereafter.'),
  3: ('The Sovereign', 'Possesses absolute dominion over the heavens and the earth.'),
  4: ('The Most Holy', 'Free from every imperfection, flaw, and likeness to creation.'),
  5: ('The Source of Peace', 'Source of safety, serenity, and perfection free from all defect.'),
  6: ('The Granter of Security', 'Grants peace and safety to His creation and fulfills His promise.'),
  7: ('The Guardian', 'Watches over, protects, and governs all affairs of creation perfectly.'),
  8: ('The Almighty', 'Possesses invincible honor and might that none can overcome.'),
  9: ('The Compeller & Restorer', 'Subdues all things by His will while healing the broken and weak.'),
  10: ('The Supreme', 'Alone deserves absolute greatness and majesty above all creation.'),
  11: ('The Creator', 'Creates the entire universe from nothing in perfect measure.'),
  12: ('The Evolver', 'Brings creation into existence in harmony and free from flaw.'),
  13: ('The Fashioner', 'Shapes and gives every creature its unique form and features.'),
  14: ('The All-Forgiving', 'Repeatedly conceals sins and forgives servants who repent.'),
  15: ('The All-Subduing', 'Subdues all creation under His decree and absolute authority.'),
  16: ('The Bestower', 'Gives gifts freely and abundantly without expecting anything in return.'),
  17: ('The Provider', 'Guarantees and delivers physical and spiritual sustenance for every creature.'),
  18: ('The Opener', 'Opens the doors of mercy, relief, knowledge, and just judgment.'),
  19: ('The All-Knowing', 'Knows everything visible and hidden across the heavens and earth.'),
  20: ('The Withholder', 'Restricts sustenance and takes souls according to His wisdom.'),
  21: ('The Expander', 'Expands provision, mercy, and ease of heart for His servants.'),
  22: ('The Abaser', 'Humbles the arrogant and those who persist in disobedience.'),
  23: ('The Exalter', 'Elevates the rank of those who believe and hold beneficial knowledge.'),
  24: ('The Honorer', 'Grants true honor and dignity to whomever He wills.'),
  25: ('The Humiliator', 'Brings low those who oppose His truth and justice.'),
  26: ('The All-Hearing', 'Hears every prayer, sigh, and the quietest whisper.'),
  27: ('The All-Seeing', 'Sees every movement and deed of creation without barrier.'),
  28: ('The Judge', 'The supreme legislator and arbiter who never errs.'),
  29: ('The Utterly Just', 'Places everything in perfect justice without the slightest wrong.'),
  30: ('The Most Subtle & Kind', 'Cares for His servants with gentleness in unseen, subtle ways.'),
  31: ('The All-Aware', 'Knows the deepest realities and inner secrets of all things.'),
  32: ('The Forbearing', 'Does not hasten to punish sinners, granting time to repent.'),
  33: ('The Magnificent', 'Possesses greatness of essence and attributes beyond human grasp.'),
  34: ('The Forgiving', 'Forgives major and minor sins for all who seek His pardon.'),
  35: ('The Appreciative', 'Rewards even a small good deed with multiplied grace.'),
  36: ('The Most High', 'Supreme in status, authority, and majesty above all things.'),
  37: ('The Greatest', 'Everything besides Him is small before His greatness.'),
  38: ('The Preserver', 'Preserves the heavens, earth, and His servants, recording every deed.'),
  39: ('The Sustainer', 'Provides adequate nourishment and strength for every living being.'),
  40: ('The Reckoner', 'Suffices those who trust Him and takes exact account of deeds.'),
  41: ('The Majestic', 'Possesses sublime attributes of glory, nobility, and perfection.'),
  42: ('The Most Generous', 'Gives before being asked and pardons even when able to punish.'),
  43: ('The Watchful', 'Never heedless, watching every thought of the heart and every act.'),
  44: ('The Responsive', 'Answers the prayers and calls of those who invoke Him.'),
  45: ('The All-Encompassing', 'His knowledge, mercy, and bounty encompass everything.'),
  46: ('The All-Wise', 'Every creation and decree of His is full of wisdom and rightness.'),
  47: ('The Most Loving', 'Loves His obedient, repentant servants and is beloved by them.'),
  48: ('The Most Glorious', 'Glorious in His essence and noble in all His deeds and gifts.'),
  49: ('The Resurrector', 'Raises humanity from the graves on the Day of Judgment and sends messengers.'),
  50: ('The Witness', 'Directly witnesses every event with nothing escaping His sight.'),
  51: ('The Absolute Truth', 'Ultimate truth in His being, word, promise, and meeting.'),
  52: ('The Trustee', 'The finest guardian who manages the affairs of those who rely on Him.'),
  53: ('The All-Strong', 'Possesses complete strength untouched by any weakness.'),
  54: ('The Firm', 'Unshakable in power, needing no assistance from anyone.'),
  55: ('The Protecting Friend', 'Loyal helper and protector of the believers.'),
  56: ('The Praiseworthy', 'Worthy of praise in every blessing, law, and decree.'),
  57: ('The Accounter', 'Counts every creature, breath, and particle of deeds with precision.'),
  58: ('The Originator', 'Begins creation from nothing without any prior model.'),
  59: ('The Restorer', 'Restores creation to life after death on the Day of Resurrection.'),
  60: ('The Giver of Life', 'Grants life to bodies and revives hearts with faith.'),
  61: ('The Bringer of Death', 'Decrees the appointed term and death of every living soul.'),
  62: ('The Ever-Living', 'Lives eternally without beginning and without end.'),
  63: ('The Self-Subsisting', 'Stands by Himself and sustains all affairs of the heavens and earth.'),
  64: ('The Finder & Rich', 'Possesses all things and lacks nothing whatsoever.'),
  65: ('The Illustrious', 'Possesses complete nobility and boundless generosity.'),
  66: ('The Unique One', 'Singular in essence, attributes, and right to be worshipped.'),
  67: ('The Indivisible One', 'Absolutely One, indivisible, with no partner or equal.'),
  68: ('The Eternal Refuge', 'The One upon whom all creation depends in every need.'),
  69: ('The All-Capable', 'Able to bring about whatever He wills without effort.'),
  70: ('The Omnipotent', 'Displays His complete power over all creation.'),
  71: ('The Expediter', 'Brings forward whomever and whatever He wills in wisdom.'),
  72: ('The Delayer', 'Defers or delays things until their most fitting time.'),
  73: ('The First', 'Existed before all things, with no beginning.'),
  74: ('The Last', 'Remains eternal after all creation perishes, with no end.'),
  75: ('The Manifest', 'His signs of existence and power are evident throughout creation.'),
  76: ('The Hidden', 'The reality of His essence is beyond mortal sight in this world.'),
  77: ('The Governor', 'Governs and directs every event throughout the universe.'),
  78: ('The Most Exalted', 'Far above every deficiency and anything unworthy of Him.'),
  79: ('The Source of Goodness', 'Acts with kindness, fulfills promises, and pours goodness on His servants.'),
  80: ('The Acceptor of Repentance', 'Opens the door of repentance and welcomes back those who turn to Him.'),
  81: ('The Avenger', 'Delivers just retribution to defiant wrongdoers.'),
  82: ('The Pardoner', 'Erases the trace of sins and pardons faults completely.'),
  83: ('The Most Compassionate', 'Holds deep, tender compassion toward His servants.'),
  84: ('Master of All Sovereignty', 'Grants and withdraws earthly dominion to whomever He wills.'),
  85: ('Lord of Majesty & Generosity', 'Worthy of all reverence and constantly honoring sincere servants.'),
  86: ('The Equitable', 'Upholds justice and vindicates the oppressed.'),
  87: ('The Gatherer', 'Gathers all humanity on the Day of Judgment and unites believers\' hearts.'),
  88: ('The Self-Sufficient', 'Utterly rich and completely free of need for creation or worship.'),
  89: ('The Enricher', 'Enriches the hearts and livelihoods of whomever He wills.'),
  90: ('The Preventer', 'Prevents harm or withholds something for a servant\'s protection and good.'),
  91: ('The Distresser', 'Decrees trials or hardship as a reminder and wisdom for humanity.'),
  92: ('The Propitious', 'The sole true source of benefit in medicine, knowledge, and effort.'),
  93: ('The Light', 'Light of the heavens and earth who illuminates believers\' hearts with guidance.'),
  94: ('The Guide', 'Guides creation to recognize the path of safety and truth.'),
  95: ('The Incomparable Originator', 'Creates wondrous beauty throughout the universe without precedent.'),
  96: ('The Everlasting', 'Endures forever without ever experiencing extinction.'),
  97: ('The Inheritor', 'To Him returns all ownership after every creature passes away.'),
  98: ('The Guide to the Right Path', 'Directs all affairs toward the truest and straightest goal.'),
  99: ('The Most Patient', 'Does not rush to punish sinners, giving ample opportunity to return.'),
};

class AsmaulHusnaPage extends ConsumerStatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  ConsumerState<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends ConsumerState<AsmaulHusnaPage> {
  final _searchCtrl = TextEditingController();
  int _tab = 0;
  String _query = '';
  bool _onlyMemorized = false;
  Set<int> _memorized = {};

  // Quiz state
  int _quizIndex = 0;
  int _score = 0;
  int? _selectedOptionNumber;

  @override
  void initState() {
    super.initState();
    _loadMemorized();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMemorized() async {
    final m = await ref.read(asmaulHusnaRepoProvider).memorizedNumbers();
    if (mounted) setState(() => _memorized = m);
  }

  static String _meaningFor(BuildContext context, AsmaulHusnaItem item) =>
      context.isEn ? (_asmaulEn[item.number]?.$1 ?? item.meaning) : item.meaning;

  static String _explanationFor(BuildContext context, AsmaulHusnaItem item) =>
      context.isEn ? (_asmaulEn[item.number]?.$2 ?? item.explanation) : item.explanation;

  static bool _matchesItem(AsmaulHusnaItem item, String query) {
    if (item.matches(query)) return true;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final en = _asmaulEn[item.number];
    return (en?.$1.toLowerCase().contains(q) ?? false) || (en?.$2.toLowerCase().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Asmaul Husna (99 Nama Allah)', 'Asmaul Husna (99 Names of Allah)')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('99 Nama Allah', '99 Names of Allah'),
                context.tr('Kuis Hafalan', 'Memorization Quiz'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _tab == 0 ? _buildListTab(context) : _buildQuizTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioBar(BuildContext context, AsmaulAudioState audio) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ctrl = ref.read(asmaulAudioControllerProvider.notifier);
    final activeItem = audio.currentNumber != null ? asmaulHusnaCatalog[audio.currentNumber! - 1] : null;

    final speedLabel = switch (audio.speed) {
      0.75 => '0.75x',
      1.25 => '1.25x',
      _ => '1x',
    };
    final repeatLabel = switch (audio.repeatMode) {
      AsmaulRepeatMode.off => context.tr('Ulangi: Mati', 'Repeat: Off'),
      AsmaulRepeatMode.one => context.tr('Ulangi: 1 Nama', 'Repeat: 1 Name'),
      AsmaulRepeatMode.all => context.tr('Ulangi: Semua', 'Repeat: All'),
    };

    return Card(
      key: const Key('asmaul-audio-card'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(MoeslimIcons.audio, color: scheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: activeItem == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('Audio Offline 99 Asmaul Husna', 'Offline Audio (99 Names)'),
                              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              context.tr(
                                'Putar berurutan 1-99 atau ketuk tombol dengar di tiap nama.',
                                'Play 1-99 in order or tap listen on any name.',
                              ),
                              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${activeItem.number} ${activeItem.latin}',
                              key: const Key('asmaul-audio-now'),
                              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary),
                            ),
                            Text(
                              '${_meaningFor(context, activeItem)} · ${activeItem.arabic}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            if (activeItem == null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const Key('asmaul-play-all'),
                  onPressed: () => ctrl.playAll(startNumber: 1),
                  icon: const Icon(MoeslimIcons.play, size: 18),
                  label: Text(context.tr('Putar Semua (1-99)', 'Play All (1-99)')),
                ),
              ),
            ],
            if (activeItem != null) ...[
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('asmaul-audio-prev'),
                        tooltip: context.tr('Nama sebelumnya', 'Previous name'),
                        onPressed: ctrl.previous,
                        icon: const Icon(MoeslimIcons.sebelumnya),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('asmaul-audio-toggle'),
                        onPressed: ctrl.togglePlayPause,
                        icon: Icon(audio.playing ? MoeslimIcons.pause : MoeslimIcons.play, size: 18),
                        label: Text(
                          audio.playing ? context.tr('Jeda', 'Pause') : context.tr('Lanjut', 'Resume'),
                        ),
                      ),
                      IconButton(
                        key: const Key('asmaul-audio-next'),
                        tooltip: context.tr('Nama berikutnya', 'Next name'),
                        onPressed: ctrl.next,
                        icon: const Icon(MoeslimIcons.selanjutnya),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('asmaul-audio-repeat'),
                        tooltip: repeatLabel,
                        onPressed: ctrl.cycleRepeat,
                        icon: Icon(
                          MoeslimIcons.ulang,
                          color: audio.repeatMode == AsmaulRepeatMode.off ? null : scheme.primary,
                        ),
                      ),
                      TextButton(
                        key: const Key('asmaul-audio-speed'),
                        onPressed: ctrl.cycleSpeed,
                        child: Text(speedLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        key: const Key('asmaul-audio-stop'),
                        tooltip: context.tr('Hentikan audio', 'Stop audio'),
                        onPressed: ctrl.stop,
                        icon: const Icon(MoeslimIcons.tutup),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            if (audio.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(audio.error!, style: t.bodySmall?.copyWith(color: scheme.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab(BuildContext context) {
    final audio = ref.watch(asmaulAudioControllerProvider);
    final ctrl = ref.read(asmaulAudioControllerProvider.notifier);
    final filtered = [
      for (final item in asmaulHusnaCatalog)
        if ((!_onlyMemorized || _memorized.contains(item.number)) && _matchesItem(item, _query)) item,
    ];
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildAudioBar(context, audio),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              TextField(
                key: const Key('asmaul-search'),
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(MoeslimIcons.pencarian),
                  hintText: context.tr(
                    'Cari nama atau arti (mis. Ar-Rahman, Pengampun, Rezeki)',
                    'Search name or meaning (e.g. Ar-Rahman, Forgiving, Provider)',
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          key: const Key('asmaul-search-clear'),
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(context.tr('Semua (99)', 'All (99)')),
                      selected: !_onlyMemorized,
                      onSelected: (_) => setState(() => _onlyMemorized = false),
                    ),
                    ChoiceChip(
                      key: const Key('asmaul-filter-memorized'),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(
                        context.tr('Sudah Dihafal (${_memorized.length})', 'Memorized (${_memorized.length})'),
                      ),
                      selected: _onlyMemorized,
                      onSelected: (_) => setState(() => _onlyMemorized = !_onlyMemorized),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MoeslimIcons.pencarian, size: 32, color: scheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('Nama tidak ditemukan', 'Name not found'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'Tidak ada Asmaul Husna yang cocok dengan filter saat ini.',
                            'No Names of Allah match the current filter.',
                          ),
                          textAlign: TextAlign.center,
                          style: t.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('asmaul-reset-filter'),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _query = '';
                              _onlyMemorized = false;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(context.tr('Reset filter', 'Reset filters')),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isMem = _memorized.contains(item.number);
                    final isActive = audio.currentNumber == item.number;
                    final isThisPlaying = isActive && audio.playing;
                    return Card(
                      shape: isActive
                          ? RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: scheme.primary, width: 1.5),
                            )
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                OctagonNumber(item.number),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${item.latin} · ${_meaningFor(context, item)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.arabic,
                                  textDirection: TextDirection.rtl,
                                  style: quranTextStyle(fontSize: 22, color: scheme.primary),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 4),
                              child: Text(_explanationFor(context, item), style: t.bodySmall),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                TextButton.icon(
                                  key: Key('asmaul-play-${item.number}'),
                                  onPressed: () => ctrl.playSingle(item.number),
                                  icon: Icon(
                                    isThisPlaying ? MoeslimIcons.pause : MoeslimIcons.suara,
                                    size: 18,
                                    color: scheme.primary,
                                  ),
                                  label: Text(
                                    isThisPlaying
                                        ? context.tr('Jeda', 'Pause')
                                        : context.tr('Dengarkan', 'Listen'),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  key: Key('asmaul-mem-${item.number}'),
                                  tooltip: isMem
                                      ? context.tr('Tandai belum hafal', 'Mark as not memorized')
                                      : context.tr('Tandai sudah hafal', 'Mark as memorized'),
                                  onPressed: () async {
                                    final next = await ref.read(asmaulHusnaRepoProvider).toggleMemorized(item.number);
                                    setState(() => _memorized = next);
                                  },
                                  icon: Icon(
                                    isMem ? MoeslimIcons.berhasil : Icons.check_circle_outline,
                                    color: isMem ? scheme.primary : null,
                                  ),
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

  Widget _buildQuizTab(BuildContext context) {
    final audio = ref.watch(asmaulAudioControllerProvider);
    final ctrl = ref.read(asmaulAudioControllerProvider.notifier);
    final q = buildAsmaulHusnaQuizQuestion(_quizIndex);
    final isQuizPlaying = audio.currentNumber == q.target.number && audio.playing;
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
                    'Skor Latihan: $_score · Soal ke-${_quizIndex + 1}',
                    'Practice Score: $_score · Question #${_quizIndex + 1}',
                  ),
                  key: const Key('asmaul-quiz-score'),
                  style: t.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  q.target.arabic,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 40, color: scheme.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'Apakah arti dari "${q.target.latin}" (#${q.target.number})?',
                    'What is the meaning of "${q.target.latin}" (#${q.target.number})?',
                  ),
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('asmaul-quiz-play'),
                  onPressed: () => ctrl.playSingle(q.target.number),
                  icon: Icon(isQuizPlaying ? MoeslimIcons.pause : MoeslimIcons.suara, size: 18),
                  label: Text(
                    isQuizPlaying
                        ? context.tr('Jeda Audio', 'Pause Audio')
                        : context.tr('Dengarkan Pelafalan', 'Listen Pronunciation'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final opt in q.options)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              key: Key('asmaul-quiz-opt-${opt.number}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
              ),
              onPressed: _selectedOptionNumber != null
                  ? null
                  : () => setState(() {
                        _selectedOptionNumber = opt.number;
                        if (opt.number == q.target.number) _score++;
                      }),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _meaningFor(context, opt),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_selectedOptionNumber != null && opt.number == q.target.number)
                    Icon(MoeslimIcons.berhasil, color: scheme.primary),
                ],
              ),
            ),
          ),
        if (_selectedOptionNumber != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '${q.target.latin} (${_meaningFor(context, q.target)}): ${_explanationFor(context, q.target)}',
                style: t.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('asmaul-quiz-next'),
            onPressed: () => setState(() {
              _quizIndex = (_quizIndex + 11) % asmaulHusnaCatalog.length;
              _selectedOptionNumber = null;
            }),
            icon: const Icon(Icons.arrow_forward),
            label: Text(context.tr('Soal Berikutnya', 'Next Question')),
          ),
        ],
      ],
    );
  }
}
