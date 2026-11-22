import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'quran_source.dart';
import 'surah_page.dart';

const Map<String, ({String title, String description})> _thematicIndexEn = {
  'sabar': (
    title: 'Patience, Inner Peace & Facing Trials',
    description: 'Verses that steady the heart during hardship, loss, and life tests.',
  ),
  'rezeki': (
    title: 'Provision, Trust in Allah & Blessed Effort',
    description: 'Allah\'s promise of sustenance for servants who have taqwa, gratitude, and tawakkul.',
  ),
  'keluarga': (
    title: 'Family, Honoring Parents & Righteous Offspring',
    description: 'Guidance for a tranquil home, kindness to parents, and supplications for righteous children.',
  ),
  'taubat': (
    title: 'Repentance, Forgiveness & Allah\'s Mercy',
    description: 'The vastness of Allah\'s forgiveness for those who return to Him and never despair of His mercy.',
  ),
  'ilmu': (
    title: 'Knowledge, Wisdom & Reflection',
    description: 'The virtue of seeking knowledge, reflecting on Allah\'s signs, and asking for beneficial knowledge.',
  ),
  'akhlak': (
    title: 'Noble Character, Honesty & Brotherhood',
    description: 'Etiquette of speech, avoiding suspicion, forgiving others, and nurturing unity among believers.',
  ),
};

const Map<(int, int), String> _curatedConciseTafsirEn = {
  (1, 1): 'The Basmalah opens the Qur\'an as a reminder to begin every deed by invoking Allah, the Entirely Merciful (Ar-Rahman, encompassing all creation) and the Especially Merciful (Ar-Rahim, for the believers).',
  (1, 2): 'All perfect praise and gratitude belong solely to Allah, the Sustainer, Nurturer, and Sovereign of all worlds.',
  (1, 5): 'A pledge of pure monotheism in worship and reliance: the servant worships Allah alone and depends solely on His help in obedience.',
  (1, 6): 'The central prayer recited in every rak\'ah, asking to be guided and kept steadfast upon the Straight Path (Sirat al-Mustaqim) pleasing to Allah.',
  (2, 152): 'A command to remember Allah through speech, heart, and obedience; in return, Allah remembers His servant and showers mercy upon them.',
  (2, 153): 'A believer\'s two primary supports when facing life\'s heaviest trials are steadfast patience and establishing prayer with humility.',
  (2, 155): 'Tests of fear, hunger, and loss of wealth or life are an inevitable part of this world and a means by which Allah elevates the patient.',
  (2, 201): 'A comprehensive supplication uniting the good of this life (knowledge, worship, lawful provision, righteous family) and the Hereafter (Paradise and protection from the Fire).',
  (2, 255): 'Ayat al-Kursi affirms the majesty of tawhid, Allah\'s eternal life, and His absolute stewardship over the heavens and earth without ever tiring or sleeping.',
  (2, 286): 'A cornerstone of mercy in Islamic law: Allah never burdens a soul beyond its capacity, paired with a supplication for pardon and ease.',
  (3, 134): 'Hallmarks of the God-conscious include giving in both ease and hardship, restraining anger, and pardoning people\'s faults.',
  (3, 139): 'A call not to lose heart or grieve, because true faith uplifts the dignity and resolve of the believer.',
  (13, 28): 'True peace of heart is not attained through wealth alone, but through constant remembrance of Allah (dhikr).',
  (14, 7): 'Allah\'s firm promise that gratitude increases blessings, whereas ingratitude invites severe punishment.',
  (17, 23): 'Immediately after commanding pure monotheism, Allah commands excellence toward parents and forbids harshness, even a sigh of annoyance.',
  (18, 10): 'The supplication of the youths of the Cave asking Allah for direct mercy and right guidance while safeguarding their faith.',
  (20, 114): 'The Prophet\'s example of continually asking for an increase in beneficial knowledge ("Rabbi zidni \'ilma"), as knowledge is the foundation of right action.',
  (25, 74): 'The prayer of the servants of the Most Merciful for spouses and children who bring coolness to the eyes through their devotion to Allah.',
  (29, 45): 'Reciting the Qur\'an and establishing prayer sincerely shields a person from immorality and wrongdoing.',
  (30, 21): 'Marriage is among the signs of Allah\'s wisdom, designed to foster tranquility (sakinah), affection (mawaddah), and mercy (rahmah).',
  (31, 14): 'Luqman\'s counsel highlights the immense sacrifice of a mother in pregnancy and nursing, commanding gratitude to Allah and thankfulness to parents.',
  (39, 53): 'One of the most hopeful verses in the Qur\'an: never despair of Allah\'s mercy, for Allah forgives all sins for those who turn back in repentance.',
  (49, 12): 'A clear command to avoid suspicion, spying on others\' faults, and backbiting.',
  (65, 2): 'Whoever fears Allah by obeying His commands and avoiding His prohibitions will be granted a way out from every difficulty.',
  (65, 3): 'Allah provides from avenues never expected and suffices anyone who places full trust in Him.',
  (67, 1): 'Surah Al-Mulk reminds us of the blessed sovereignty of Allah, who created life and death to test who is best in deeds.',
  (94, 5): 'A repeated assurance that alongside every single hardship comes abundant ease for those who believe.',
  (96, 1): 'The first revelation commands reading (iqra\') in the name of the Creator, laying the foundation for a civilization of knowledge in Islam.',
  (112, 1): 'Surah Al-Ikhlas purifies tawhid: Allah is One in His essence, attributes, and actions, the Eternal Refuge upon whom all depend, with none comparable to Him.',
  (113, 1): 'Surah Al-Falaq teaches seeking refuge in Allah from the harm of creation, gathering darkness, sorcery, and envy.',
  (114, 1): 'Surah An-Nas teaches seeking protection in Allah from the subtle whispers of Shaytan that target the human heart.',
};

String _topicTitle(BuildContext context, QuranThemeTopic topic) =>
    context.isEn ? (_thematicIndexEn[topic.id]?.title ?? topic.title) : topic.title;

String _topicDescription(BuildContext context, QuranThemeTopic topic) =>
    context.isEn ? (_thematicIndexEn[topic.id]?.description ?? topic.description) : topic.description;

String _localizedConciseTafsir(
  BuildContext context, {
  required Surah surah,
  required Ayah ayah,
}) {
  if (!context.isEn) return buildConciseTafsir(surah: surah, ayah: ayah);

  final exact = _curatedConciseTafsirEn[(surah.number, ayah.number)];
  if (exact != null) return exact;

  final translation = (ayah.translationFor(AppLanguage.en) ?? '').trim();
  final matchingThemes = quranThematicIndex
      .where((t) => t.verses.any((v) => v.surah == surah.number && v.ayah == ayah.number))
      .map((t) => _thematicIndexEn[t.id]?.title ?? t.title)
      .toList();

  final buf = StringBuffer();
  buf.write(
    'Concise Tafsir of Surah ${surah.name} (${surah.number}:${ayah.number}, '
    '${surah.revelationFor(AppLanguage.en)} Surah, Juz ${juzOf(surah.number, ayah.number)}): ',
  );
  if (translation.isNotEmpty) {
    buf.write('This verse conveys the message: "$translation" ');
  }
  if (surah.makkiyah) {
    buf.write(
      'Within the context of a Meccan surah, this verse strengthens faith, monotheism (tawhid), awareness of the Hereafter, and moral steadiness before Allah.',
    );
  } else {
    buf.write(
      'Within the context of a Medinan surah, this verse guides legal observance, social etiquette, devotion in worship, and faithful responsibility in daily life.',
    );
  }
  if (matchingThemes.isNotEmpty) {
    buf.write(' Closely connected to: ${matchingThemes.join(', ')}.');
  }
  return buf.toString();
}

Future<void> showAyahTafsirSheet(
  BuildContext context,
  WidgetRef ref, {
  required Surah surah,
  required Ayah ayah,
}) async {
  final noteRepo = ref.read(ayahNoteRepoProvider);
  final existing = await noteRepo.noteFor(surah.number, ayah.number);
  if (!context.mounted) return;

  final noteController = TextEditingController(text: existing?.note ?? '');

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final tafsirText = _localizedConciseTafsir(sheetContext, surah: surah, ayah: ayah);
      final translation = ayah.translationFor(sheetContext.lang);
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sheetContext.tr(
                  'QS. ${surah.name} (${surah.number}): ${ayah.number}',
                  'Surah ${surah.name} (${surah.number}:${ayah.number})',
                ),
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: quranTextStyle(fontSize: 26),
              ),
              if ((translation ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(translation!, style: Theme.of(sheetContext).textTheme.bodyMedium),
              ],
              const Divider(height: 24),
              Text(
                sheetContext.tr('Tafsir Ringkas', 'Concise Tafsir'),
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(tafsirText, style: Theme.of(sheetContext).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                sheetContext.tr('Catatan Tadabbur Pribadi', 'Personal Reflection Notes'),
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                key: const Key('ayah-note-input'),
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: sheetContext.tr(
                    'Tulis renungan atau catatan pribadi untuk ayat ini (tersimpan di perangkat)...',
                    'Write your reflection or personal note for this verse (saved on this device)...',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (existing != null)
                    TextButton(
                      onPressed: () async {
                        await noteRepo.deleteNote(surah.number, ayah.number);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: Text(sheetContext.tr('Hapus Catatan', 'Delete Note')),
                    ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const Key('save-ayah-note'),
                    onPressed: () async {
                      await noteRepo.saveNote(surah.number, ayah.number, noteController.text);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    icon: const Icon(MoeslimIcons.berhasil),
                    label: Text(sheetContext.tr('Simpan Catatan', 'Save Note')),
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

class TafsirSearchPage extends ConsumerStatefulWidget {
  const TafsirSearchPage({super.key});

  @override
  ConsumerState<TafsirSearchPage> createState() => _TafsirSearchPageState();
}

class _TafsirSearchPageState extends ConsumerState<TafsirSearchPage> {
  final _searchController = TextEditingController();
  int _tab = 0;
  String _query = '';
  List<AyahSearchMatch> _matches = const [];
  bool _searching = false;
  List<AyahNote> _notes = const [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await ref.read(ayahNoteRepoProvider).all();
    if (mounted) setState(() => _notes = notes);
  }

  Future<void> _runSearch(String rawQuery) async {
    final q = rawQuery.trim().toLowerCase();
    setState(() {
      _query = q;
      _searching = q.length >= 2;
    });
    if (q.length < 2) {
      setState(() {
        _matches = const [];
        _searching = false;
      });
      return;
    }

    final source = ref.read(quranSourceProvider);
    final activeLang = ref.readLang;
    final results = <AyahSearchMatch>[];
    for (final s in surahs) {
      final ayat = await source.load(s.number);
      if (ayat == null) continue;
      for (final a in ayat) {
        final trId = a.translation ?? '';
        final trEn = a.translationEn ?? '';
        if (trId.toLowerCase().contains(q) ||
            trEn.toLowerCase().contains(q) ||
            a.text.contains(q) ||
            '${s.name.toLowerCase()}:${a.number}' == q ||
            '${s.number}:${a.number}' == q) {
          results.add(AyahSearchMatch(surah: s, ayah: a, snippet: a.translationFor(activeLang) ?? trId));
          if (results.length >= 80) break;
        }
      }
      if (results.length >= 80) break;
    }
    if (mounted && _query == q) {
      setState(() {
        _matches = results;
        _searching = false;
      });
    }
  }

  Future<void> _openTafsirForRef(int surahNumber, int ayahNumber) async {
    final s = surahs[surahNumber - 1];
    final ayat = await ref.read(quranSourceProvider).load(surahNumber);
    final ayah = (ayat != null && ayahNumber <= ayat.length)
        ? ayat[ayahNumber - 1]
        : Ayah(
            surahNumber,
            ayahNumber,
            '',
            translation: curatedConciseTafsir[(surahNumber, ayahNumber)],
            translationEn: _curatedConciseTafsirEn[(surahNumber, ayahNumber)],
          );
    if (!mounted) return;
    await showAyahTafsirSheet(context, ref, surah: s, ayah: ayah);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Tafsir & Pencarian Ayat', 'Tafsir & Verse Search')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: [
                context.tr('Cari Ayat', 'Search Verses'),
                context.tr('Indeks Tema', 'Topic Index'),
                context.tr('Catatan Saya', 'My Notes'),
              ],
              index: _tab,
              onChanged: (i) {
                setState(() => _tab = i);
                if (i == 2) _loadNotes();
              },
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _buildSearchTab(context),
              1 => _buildThematicTab(context),
              _ => _buildNotesTab(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            key: const Key('tafsir-search-field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(MoeslimIcons.pencarian),
              hintText: context.tr(
                'Cari kata di terjemahan Al-Qur\'an (mis. sabar, rezeki, takwa)',
                'Search Qur\'an translations (e.g., patience, mercy, gratitude)',
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      key: const Key('tafsir-search-clear'),
                      tooltip: context.tr('Hapus pencarian', 'Clear search'),
                      onPressed: () {
                        _searchController.clear();
                        _runSearch('');
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
            onChanged: _runSearch,
          ),
        ),
        Expanded(
          child: _searching
              ? const Center(child: CircularProgressIndicator())
              : _query.length < 2
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          context.tr('Ayat Pilihan & Tafsir Ringkas', 'Selected Verses & Concise Tafsir'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'Ketik minimal 2 huruf untuk mencari lintas 114 surah, atau ketuk ayat pilihan di bawah untuk membaca Tafsir Ringkas.',
                            'Type at least 2 characters to search across all 114 surahs, or tap a selected verse below to read its Concise Tafsir.',
                          ),
                          style: t.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        for (final entry in curatedConciseTafsir.entries.take(12))
                          Card(
                            child: ListTile(
                              leading: OctagonNumber(entry.key.$2),
                              title: Text(
                                context.tr(
                                  'QS. ${surahs[entry.key.$1 - 1].name}: ${entry.key.$2}',
                                  '${surahs[entry.key.$1 - 1].name} (${entry.key.$1}:${entry.key.$2})',
                                ),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                context.isEn ? (_curatedConciseTafsirEn[entry.key] ?? entry.value) : entry.value,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openTafsirForRef(entry.key.$1, entry.key.$2),
                            ),
                          ),
                      ],
                    )
                  : _matches.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(MoeslimIcons.pencarian, size: 32, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr('Ayat tidak ditemukan', 'No verses found'),
                                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr(
                                    'Tidak ada ayat yang cocok dengan "${_searchController.text.trim()}".',
                                    'No verses matched "${_searchController.text.trim()}".',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: t.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  key: const Key('tafsir-reset-search'),
                                  onPressed: () {
                                    _searchController.clear();
                                    _runSearch('');
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(context.tr('Hapus pencarian', 'Clear search')),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _matches.length,
                          itemBuilder: (context, index) {
                            final m = _matches[index];
                            final snippet = m.ayah.translationFor(context.lang) ?? m.snippet;
                            return Card(
                              child: ListTile(
                                leading: OctagonNumber(m.ayah.number),
                                title: Text(
                                  context.tr(
                                    'QS. ${m.surah.name}: ${m.ayah.number}',
                                    '${m.surah.name} (${m.surah.number}:${m.ayah.number})',
                                  ),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(snippet, maxLines: 3, overflow: TextOverflow.ellipsis),
                                trailing: PopupMenuButton<String>(
                                  tooltip: context.tr('Tindakan ayat', 'Verse actions'),
                                  onSelected: (v) {
                                    if (v == 'tafsir') {
                                      showAyahTafsirSheet(context, ref, surah: m.surah, ayah: m.ayah).then((_) => _loadNotes());
                                    } else if (v == 'mushaf') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => SurahPage(surah: m.surah, initialAyah: m.ayah.number)),
                                      );
                                    }
                                  },
                                  itemBuilder: (menuContext) => [
                                    PopupMenuItem(
                                      value: 'tafsir',
                                      child: Text(menuContext.tr('Baca Tafsir & Catatan', 'Read Tafsir & Notes')),
                                    ),
                                    PopupMenuItem(
                                      value: 'mushaf',
                                      child: Text(menuContext.tr('Buka di Mushaf', 'Open in Mushaf')),
                                    ),
                                  ],
                                ),
                                onTap: () => showAyahTafsirSheet(context, ref, surah: m.surah, ayah: m.ayah).then((_) => _loadNotes()),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildThematicTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: quranThematicIndex.length,
      itemBuilder: (context, index) {
        final topic = quranThematicIndex[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_topicTitle(context, topic), style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(_topicDescription(context, topic), style: t.bodySmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in topic.verses)
                      ActionChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(
                          context.tr(
                            'QS. ${surahs[v.surah - 1].name}: ${v.ayah}',
                            '${surahs[v.surah - 1].name} ${v.surah}:${v.ayah}',
                          ),
                        ),
                        onPressed: () => _openTafsirForRef(v.surah, v.ayah),
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

  Widget _buildNotesTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (_notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MoeslimIcons.buku, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                context.tr('Belum ada catatan ayat', 'No verse notes yet'),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  'Ketuk salah satu ayat di tab Cari Ayat, Indeks Tema, atau langsung dari halaman Surah untuk menulis catatan tadabbur pribadi.',
                  'Tap any verse in Search Verses, Topic Index, or directly from a Surah page to write personal reflection notes.',
                ),
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _tab = 1),
                icon: const Icon(MoeslimIcons.daftar),
                label: Text(context.tr('Lihat Indeks Tema', 'Browse Topic Index')),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final n = _notes[index];
        final s = surahs[n.surah - 1];
        return Card(
          child: ListTile(
            leading: OctagonNumber(n.ayah),
            title: Text(
              context.tr('QS. ${s.name}: ${n.ayah}', '${s.name} (${s.number}:${n.ayah})'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(n.note),
            trailing: IconButton(
              tooltip: context.tr('Hapus catatan', 'Delete note'),
              onPressed: () async {
                await ref.read(ayahNoteRepoProvider).deleteNote(n.surah, n.ayah);
                await _loadNotes();
              },
              icon: const Icon(MoeslimIcons.hapus),
            ),
            onTap: () => _openTafsirForRef(n.surah, n.ayah),
          ),
        );
      },
    );
  }
}
