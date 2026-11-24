import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../ibadah/family_education_page.dart';
import '../ibadah/muhasabah_journal_page.dart';
import '../masjid/masjid_api.dart';
import '../masjid/masjid_home_page.dart';
import '../masjid/mosque_providers.dart';
import '../masjid/session.dart';

/// Moeslim Learning Path (LP-01..LP-10) + Submodul Bahasa Arab & Terjemahan (ARB-01..ARB-11):
/// - Pembelajaran mandiri offline-first di Moeslim Personal (6 jalur resmi, tanpa 7 Naghom).
/// - Bahasa Arab & Kamus Dua Arah offline berada di dalam Learning Path, bukan core terpisah.
/// - Kelas Masjid opsional dikelola pengurus di Moeslim Mosque dan diakses/didaftar di sini.
class LearningPathPage extends ConsumerStatefulWidget {
  final int initialTab;
  final String? initialMosqueSlug;
  final String? initialMosqueName;

  const LearningPathPage({
    super.key,
    this.initialTab = 0,
    this.initialMosqueSlug,
    this.initialMosqueName,
  });

  @override
  ConsumerState<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends ConsumerState<LearningPathPage> {
  late int _tab = widget.initialTab.clamp(0, 2);
  Map<String, LessonProgress> _progress = const {};
  Set<String> _bookmarks = {};
  Set<String> _bundles = {};
  LearningLesson? _recommended;

  // Bahasa Arab submodul state
  int _arabicSubTab = 0; // 0 = Kamus Dua Arah, 1 = Flashcard SRS, 2 = Percakapan L2
  final _dictCtrl = TextEditingController();
  String _dictQuery = '';
  int? _dictLevelFilter;
  Set<String> _arabicFavs = {};
  List<ArabicLexeme> _dueCards = const [];
  int _cardIdx = 0;
  bool _showCardBack = false;
  final Map<String, int> _dialogueAnswers = {};

  // Kelas Masjid state
  List<FollowedMosque> _followed = const [];
  String? _selectedSlug;
  String? _selectedMosqueName;
  List<Map<String, dynamic>> _classes = const [];
  DateTime? _classesSyncedAt;
  bool _loadingClasses = false;
  bool _classesOffline = false;

  @override
  void initState() {
    super.initState();
    _selectedSlug = widget.initialMosqueSlug;
    _selectedMosqueName = widget.initialMosqueName;
    _loadLocal();
  }

  @override
  void dispose() {
    _dictCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    final lp = ref.read(learningPathRepoProvider);
    final ar = ref.read(arabicStudyRepoProvider);
    final followed = await ref.read(favoriteMosqueRepoProvider).all();
    final prog = await lp.loadProgress();
    final bms = await lp.bookmarks();
    final bnd = await lp.installedBundles();
    final rec = await lp.recommendedNext();
    final favs = await ar.favoriteIds();
    final due = await ar.dueFlashcards();
    if (mounted) {
      setState(() {
        _progress = prog;
        _bookmarks = bms;
        _bundles = bnd;
        _recommended = rec;
        _arabicFavs = favs;
        _dueCards = due;
        _followed = followed;
        if (_selectedSlug == null && followed.isNotEmpty) {
          _selectedSlug = followed.first.slug;
          _selectedMosqueName = followed.first.name;
        }
      });
    }
    if (_selectedSlug != null) {
      await _loadMosqueClasses(_selectedSlug!);
    }
  }

  Future<void> _loadMosqueClasses(String slug) async {
    setState(() => _loadingClasses = true);
    final cache = ref.read(communityCacheRepoProvider);
    final cached = await cache.loadClassesCache(slug);
    if (cached != null && mounted) {
      setState(() {
        _classes = cached.classes;
        _classesSyncedAt = cached.syncedAt;
      });
    }
    try {
      final res = await ref.read(masjidApiProvider).publicMosqueClasses(slug);
      final list = List<Map<String, dynamic>>.from(
        (res['data'] as List? ?? const []).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      final at = DateTime.tryParse('${res['synced_at'] ?? ''}')?.toUtc() ?? DateTime.now().toUtc();
      await cache.saveClassesCache(slug, list, at);
      if (mounted) {
        setState(() {
          _classes = list;
          _classesSyncedAt = at;
          _classesOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _classesOffline = true);
    } finally {
      if (mounted) setState(() => _loadingClasses = false);
    }
  }

  Future<void> _openLesson(LearningLesson lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LessonDetailPage(
          lesson: lesson,
          isBookmarked: _bookmarks.contains(lesson.id),
          isBundleInstalled: _bundles.contains(lesson.offlineBundleId),
        ),
      ),
    );
    await _loadLocal();
  }

  Future<void> _enrollClass(Map<String, dynamic> c) async {
    if (ref.read(sessionProvider).value == null) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    try {
      final reg = await ref.read(masjidApiProvider).registerEvent((c['id'] as num).toInt());
      final st = '${reg['status']}';
      if (mounted) {
        showSnack(
          context,
          st == 'waitlisted'
              ? context.tr('Kuota kelas penuh, Anda masuk daftar tunggu.', 'Class full, added to waiting list.')
              : context.tr('Pendaftaran kelas berhasil dicatat.', 'Enrolled in mosque class.'),
        );
      }
      if (_selectedSlug != null) await _loadMosqueClasses(_selectedSlug!);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Learning Path & Bahasa Arab', 'Learning Path & Arabic')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Jalur Belajar', 'Paths'),
                context.tr('Bahasa Arab', 'Arabic'),
                context.tr('Kelas Masjid', 'Mosque Classes'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildPathsTab(context),
              1 => _buildArabicSubmoduleTab(context),
              _ => _buildMosqueClassesTab(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPathsTab(BuildContext context) {
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final totalLessons = learningPathCatalog.fold<int>(0, (s, p) => s + p.lessons.length);
    final completedLessons = _progress.values.where((p) => p.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        PatternBanner(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Belajar Mandiri Tanpa Login', 'Self-Paced Offline Learning'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  'Progres lokal: $completedLessons / $totalLessons pelajaran selesai. Seluruh materi terkurasi berreferensi jelas dan siap offline.',
                  'Local progress: $completedLessons / $totalLessons lessons completed. All curated lessons cite references and work offline.',
                ),
                style: const TextStyle(color: BrandColors.cream, fontSize: 12.5),
              ),
            ],
          ),
        ),
        if (_recommended != null) ...[
          SectionHeader(context.tr('Rekomendasi Berikutnya', 'Recommended Next')),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              key: const Key('lp-recommended-card'),
              leading: const Icon(MoeslimIcons.target, color: BrandColors.emerald),
              title: Text(_recommended!.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${_recommended!.levelTitleFor(lang)} • ${_recommended!.estimatedMinutes} ${context.tr('mnt', 'min')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openLesson(_recommended!),
            ),
          ),
        ],
        for (final track in learningPathCatalog) ...[
          SectionHeader(track.titleFor(lang)),
          Text(track.summaryFor(lang), style: t.bodySmall),
          const SizedBox(height: 6),
          for (final lesson in track.lessons)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                key: Key('lp-lesson-${lesson.id}'),
                leading: Icon(
                  _progress[lesson.id]?.isCompleted == true ? MoeslimIcons.berhasil : MoeslimIcons.buku,
                  color: _progress[lesson.id]?.isCompleted == true ? BrandColors.emerald : Theme.of(context).colorScheme.outline,
                ),
                title: Text(lesson.titleFor(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${lesson.levelTitleFor(lang)} • ${lesson.estimatedMinutes} ${context.tr('mnt', 'min')} • '
                  '${_bundles.contains(lesson.offlineBundleId) ? context.tr('Offline siap', 'Offline ready') : context.tr('Paket belum diunduh', 'Bundle removed')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openLesson(lesson),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildArabicSubmoduleTab(BuildContext context) {
    final lang = context.lang;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dictResults = searchArabicDictionary(_dictQuery, level: _dictLevelFilter);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              key: const Key('arabic-sub-dict'),
              label: Text(context.tr('Kamus Dua Arah', 'Dictionary')),
              selected: _arabicSubTab == 0,
              onSelected: (_) => setState(() => _arabicSubTab = 0),
            ),
            ChoiceChip(
              key: const Key('arabic-sub-flashcard'),
              label: Text(context.tr('Flashcard (${_dueCards.length})', 'Flashcards (${_dueCards.length})')),
              selected: _arabicSubTab == 1,
              onSelected: (_) => setState(() => _arabicSubTab = 1),
            ),
            ChoiceChip(
              key: const Key('arabic-sub-dialogue'),
              label: Text(context.tr('Percakapan L2', 'L2 Dialogues')),
              selected: _arabicSubTab == 2,
              onSelected: (_) => setState(() => _arabicSubTab = 2),
            ),
            ActionChip(
              label: Text(context.tr('Tabel 29 Hijaiyah (L1)', '29 Hijaiyah Table (L1)')),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FamilyEducationPage(initialTab: 1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_arabicSubTab == 0) ...[
          TextField(
            key: const Key('arabic-dict-search'),
            controller: _dictCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(MoeslimIcons.pencarian),
              hintText: context.tr('Cari Arab / Indonesia (mis. مسجد, rumah, rahmat)...', 'Search Arabic / English (e.g. masjid, house, mercy)...'),
            ),
            onChanged: (v) => setState(() => _dictQuery = v),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: Text(context.tr('Semua', 'All')),
                selected: _dictLevelFilter == null,
                onSelected: (_) => setState(() => _dictLevelFilter = null),
              ),
              for (final lv in const [2, 3, 4, 5])
                ChoiceChip(
                  label: Text('L$lv'),
                  selected: _dictLevelFilter == lv,
                  onSelected: (_) => setState(() => _dictLevelFilter = lv),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                context.tr(
                  'Kamus & frasa di bawah adalah basis data lokal terkurasi (bekerja 100% di mode pesawat). Terjemahan ayat Al-Qur\'an tetap merujuk mushaf resmi dan tidak diganti terjemahan otomatis.',
                  'Dictionary and phrases below are curated offline data (works in airplane mode). Qur\'an translations always stay separate from automatic translation.',
                ),
                style: t.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (final item in dictResults)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.transliteration} • ${item.pos.toUpperCase()} • L${item.level}',
                            style: t.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: context.tr('Favorit kosakata', 'Favorite word'),
                          icon: Icon(
                            _arabicFavs.contains(item.id) ? MoeslimIcons.cinta : Icons.favorite_border,
                            color: _arabicFavs.contains(item.id) ? scheme.primary : null,
                            size: 20,
                          ),
                          onPressed: () async {
                            final next = await ref.read(arabicStudyRepoProvider).toggleFavorite(item.id);
                            setState(() => _arabicFavs = next);
                          },
                        ),
                      ],
                    ),
                    Text(
                      item.lemmaAr,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: quranTextStyle(fontSize: 28, color: scheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(item.meaningsFor(lang).join('; '), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if (item.root != '-')
                      Text(context.tr('Akar kata: ${item.root}', 'Root: ${item.root}'), style: t.bodySmall),
                    const SizedBox(height: 4),
                    Text(item.contextFor(lang), style: t.bodySmall),
                    const Divider(height: 16),
                    Text(item.exampleAr, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 19)),
                    Text(item.exampleFor(lang), style: t.bodySmall),
                  ],
                ),
              ),
            ),
        ] else if (_arabicSubTab == 1) ...[
          if (_dueCards.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  context.tr(
                    'Semua kartu kosakata untuk hari ini sudah diulang. Kembali lagi besok untuk pengulangan terjadwal (Spaced Repetition).',
                    'All flashcards due today are reviewed. Come back tomorrow for scheduled spaced repetition.',
                  ),
                ),
              ),
            )
          else ...[
            Builder(
              builder: (context) {
                final card = _dueCards[_cardIdx % _dueCards.length];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('Kartu ${(_cardIdx % _dueCards.length) + 1} / ${_dueCards.length} • ${card.theme}', 'Card ${(_cardIdx % _dueCards.length) + 1} / ${_dueCards.length} • ${card.theme}'),
                          style: t.labelMedium?.copyWith(color: scheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card.lemmaAr,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: quranTextStyle(fontSize: 34, color: scheme.primary),
                        ),
                        Text(card.transliteration, textAlign: TextAlign.center, style: t.titleMedium),
                        const SizedBox(height: 16),
                        if (!_showCardBack)
                          FilledButton(
                            key: const Key('arabic-reveal-card'),
                            onPressed: () => setState(() => _showCardBack = true),
                            child: Text(context.tr('Tampilkan Arti & Contoh', 'Reveal Meaning & Example')),
                          )
                        else ...[
                          const Divider(),
                          Text(card.meaningsFor(lang).join('; '), textAlign: TextAlign.center, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(card.contextFor(lang), textAlign: TextAlign.center, style: t.bodySmall),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _gradeCard(card.id, 1),
                                  child: Text(context.tr('Ulang Besok', 'Repeat Soon')),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  key: const Key('arabic-grade-easy'),
                                  onPressed: () => _gradeCard(card.id, 5),
                                  child: Text(context.tr('Hafal Lancar', 'Mastered')),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ] else ...[
          for (final dlg in arabicDialoguesCatalog)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(context.isEn ? dlg.titleEn : dlg.titleId, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    for (final line in dlg.lines) ...[
                      Text(context.isEn ? line.speakerEn : line.speakerId, style: t.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                      Text(line.arabic, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 21)),
                      Text(line.transliteration, style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                      Text(context.isEn ? line.translationEn : line.translationId, style: t.bodySmall),
                      const SizedBox(height: 8),
                    ],
                    const Divider(),
                    Text(context.isEn ? dlg.promptHintEn : dlg.promptHintId, style: t.labelMedium),
                    Text(dlg.promptAr, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 20, color: scheme.primary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (var i = 0; i < dlg.choices.length; i++)
                          ChoiceChip(
                            label: Text(dlg.choices[i]),
                            selected: _dialogueAnswers[dlg.id] == i,
                            onSelected: (_) => setState(() => _dialogueAnswers[dlg.id] = i),
                          ),
                      ],
                    ),
                    if (_dialogueAnswers.containsKey(dlg.id))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _dialogueAnswers[dlg.id] == dlg.correctIndex
                              ? context.tr('Tepat sekali! Latihan dialog selesai.', 'Spot on! Dialogue practice complete.')
                              : context.tr('Belum tepat, coba pilihan lain ya.', 'Not quite yet, feel free to try another choice.'),
                          style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _gradeCard(String lexemeId, int quality) async {
    await ref.read(arabicStudyRepoProvider).recordReview(lexemeId, quality: quality);
    final due = await ref.read(arabicStudyRepoProvider).dueFlashcards();
    if (mounted) {
      setState(() {
        _dueCards = due;
        _cardIdx = 0;
        _showCardBack = false;
      });
    }
  }

  Widget _buildMosqueClassesTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (_followed.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: _selectedSlug,
            decoration: InputDecoration(labelText: context.tr('Pilih Masjid Diikuti', 'Select Followed Mosque')),
            items: [
              for (final m in _followed) DropdownMenuItem(value: m.slug, child: Text(m.name)),
            ],
            onChanged: (slug) {
              if (slug == null) return;
              final m = _followed.firstWhere((x) => x.slug == slug);
              setState(() {
                _selectedSlug = slug;
                _selectedMosqueName = m.name;
              });
              _loadMosqueClasses(slug);
            },
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr(
                  'Ikuti masjid terlebih dahulu di menu Masjid Diikuti untuk melihat kelas Bahasa Arab & kajian resmi yang dibuka masjid.',
                  'Follow a mosque first under Followed Mosques to browse official mosque classes.',
                ),
              ),
            ),
          ),
        if (_classesSyncedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.tr(
                '${_classesOffline ? 'Mode cache offline · ' : ''}Terakhir sinkron: ${context.shortDateText(_classesSyncedAt!.toLocal())} ${hhmm(_classesSyncedAt!.toLocal())}',
                '${_classesOffline ? 'Offline cache · ' : ''}Last synced: ${context.shortDateText(_classesSyncedAt!.toLocal())} ${hhmm(_classesSyncedAt!.toLocal())}',
              ),
              style: t.bodySmall,
            ),
          ),
        const SizedBox(height: 10),
        if (_loadingClasses)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (_classes.isEmpty && _selectedSlug != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr(
                  'Belum ada kelas terpublikasi dari ${_selectedMosqueName ?? _selectedSlug}.',
                  'No published classes yet from ${_selectedMosqueName ?? _selectedSlug}.',
                ),
              ),
            ),
          )
        else
          for (final c in _classes)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c['title']}', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    if (c['speaker'] != null) Text(context.tr('Pengajar: ${c['speaker']}', 'Instructor: ${c['speaker']}'), style: t.bodySmall),
                    if (c['starts_at'] != null)
                      Text(
                        '${context.shortDateText(DateTime.parse('${c['starts_at']}').toLocal())} ${hhmm(DateTime.parse('${c['starts_at']}').toLocal())}',
                        style: t.bodySmall,
                      ),
                    if (c['capacity'] != null)
                      Text(
                        context.tr(
                          'Sisa kuota: ${c['remaining_seats'] ?? 0} / ${c['capacity']}',
                          'Remaining seats: ${c['remaining_seats'] ?? 0} / ${c['capacity']}',
                        ),
                        style: t.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (c['registration_enabled'] == true)
                          FilledButton(
                            onPressed: () => _enrollClass(c),
                            child: Text(context.tr('Daftar Kelas', 'Enroll Class')),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MuhasabahJournalPage(
                                initialKind: JournalEntryKind.kajian,
                                initialTitle: '${c['title']}',
                                initialSourceRef: '${c['title']} (${_selectedMosqueName ?? ''})',
                              ),
                            ),
                          ),
                          icon: const Icon(MoeslimIcons.edit, size: 16),
                          label: Text(context.tr('Catat di Jurnal Privat', 'Note in Private Journal')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _LessonDetailPage extends ConsumerStatefulWidget {
  final LearningLesson lesson;
  final bool isBookmarked;
  final bool isBundleInstalled;
  const _LessonDetailPage({required this.lesson, required this.isBookmarked, required this.isBundleInstalled});

  @override
  ConsumerState<_LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends ConsumerState<_LessonDetailPage> {
  late bool _bookmarked = widget.isBookmarked;
  late bool _installed = widget.isBundleInstalled;
  final Map<String, int> _answers = {};

  Future<void> _submitQuiz() async {
    var score = 0;
    for (final a in widget.lesson.activities) {
      if (_answers[a.id] == a.correctIndex) score++;
    }
    await ref.read(learningPathRepoProvider).saveLessonProgress(
      widget.lesson.id,
      status: 'completed',
      bestScore: score,
      totalQuestions: widget.lesson.activities.length,
    );
    if (mounted) {
      showSnack(
        context,
        context.tr(
          'Pelajaran ditandai selesai (Skor latihan: $score/${widget.lesson.activities.length}). Anda boleh mengulang kapan saja.',
          'Lesson completed (Practice score: $score/${widget.lesson.activities.length}). Feel free to retry anytime.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final l = widget.lesson;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.levelTitleFor(lang)),
        actions: [
          IconButton(
            tooltip: context.tr('Simpan bookmark', 'Bookmark lesson'),
            icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              await ref.read(learningPathRepoProvider).toggleBookmark(l.id);
              setState(() => _bookmarked = !_bookmarked);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.titleFor(lang), style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            context.tr(
              'Sumber: ${l.sourceRef} • Peninjau: ${l.reviewer} (v${l.contentVersion}, ${l.reviewedAt})',
              'Source: ${l.sourceRef} • Reviewer: ${l.reviewer} (v${l.contentVersion}, ${l.reviewedAt})',
            ),
            style: t.bodySmall,
          ),
          const SizedBox(height: 12),
          if (l.arabicHighlight != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.arabicHighlight!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 28, color: scheme.primary),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.bodyFor(lang), style: t.bodyLarge?.copyWith(height: 1.55)),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              title: Text(context.tr('Paket Offline (${l.bundleSizeKb} KB)', 'Offline Bundle (${l.bundleSizeKb} KB)')),
              subtitle: Text(
                context.tr(
                  'Menghapus paket offline tidak akan menghapus progres belajar Anda.',
                  'Removing the offline bundle will never delete your learning progress.',
                ),
              ),
              value: _installed,
              onChanged: (v) async {
                await ref.read(learningPathRepoProvider).setBundleInstalled(l.offlineBundleId, v);
                setState(() => _installed = v);
              },
            ),
          ),
          if (l.activities.isNotEmpty) ...[
            SectionHeader(context.tr('Latihan Interaktif', 'Interactive Practice')),
            for (final act in l.activities)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(act.promptFor(lang), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (act.arabicSample != null) ...[
                        const SizedBox(height: 8),
                        Text(act.arabicSample!, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 24, color: scheme.primary)),
                      ],
                      const SizedBox(height: 8),
                      for (var i = 0; i < act.choicesFor(lang).length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: OutlinedButton(
                            key: Key('lp-choice-${act.id}-$i'),
                            onPressed: () => setState(() => _answers[act.id] = i),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _answers[act.id] == i ? scheme.primary.withValues(alpha: .12) : null,
                            ),
                            child: Align(alignment: Alignment.centerLeft, child: Text(act.choicesFor(lang)[i])),
                          ),
                        ),
                      if (_answers.containsKey(act.id)) ...[
                        const SizedBox(height: 8),
                        Text(act.feedbackFor(lang), style: t.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('lp-complete-lesson-btn'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
            onPressed: _submitQuiz,
            icon: const Icon(MoeslimIcons.berhasil),
            label: Text(context.tr('Selesaikan Pelajaran', 'Complete Lesson')),
          ),
        ],
      ),
    );
  }
}
