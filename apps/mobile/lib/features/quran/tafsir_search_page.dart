import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import 'quran_source.dart';
import 'surah_page.dart';

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
  final tafsirText = buildConciseTafsir(surah: surah, ayah: ayah);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
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
              'QS. ${surah.name} (${surah.number}): ${ayah.number}',
              style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              ayah.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: quranTextStyle(fontSize: 26),
            ),
            if ((ayah.translation ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(ayah.translation!, style: Theme.of(sheetContext).textTheme.bodyMedium),
            ],
            const Divider(height: 24),
            Text(
              'Tafsir Ringkas',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(tafsirText, style: Theme.of(sheetContext).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(
              'Catatan Tadabbur Pribadi',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('ayah-note-input'),
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis renungan atau catatan pribadi untuk ayat ini (tersimpan di perangkat)...',
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
                    child: const Text('Hapus Catatan'),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key('save-ayah-note'),
                  onPressed: () async {
                    await noteRepo.saveNote(surah.number, ayah.number, noteController.text);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: const Icon(MoeslimIcons.berhasil),
                  label: const Text('Simpan Catatan'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
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
    final results = <AyahSearchMatch>[];
    for (final s in surahs) {
      final ayat = await source.load(s.number);
      if (ayat == null) continue;
      for (final a in ayat) {
        final tr = a.translation ?? '';
        if (tr.toLowerCase().contains(q) || a.text.contains(q) || '${s.name.toLowerCase()}:${a.number}' == q) {
          results.add(AyahSearchMatch(surah: s, ayah: a, snippet: tr));
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
        : Ayah(surahNumber, ayahNumber, '', translation: curatedConciseTafsir[(surahNumber, ayahNumber)]);
    if (!mounted) return;
    await showAyahTafsirSheet(context, ref, surah: s, ayah: ayah);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tafsir & Pencarian Ayat'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Cari Ayat', 'Indeks Tema', 'Catatan Saya'],
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
              hintText: 'Cari kata di terjemahan Al-Qur\'an (mis. sabar, rezeki, takwa)',
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      key: const Key('tafsir-search-clear'),
                      tooltip: 'Hapus pencarian',
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
                          'Ayat Pilihan & Tafsir Ringkas',
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketik minimal 2 huruf untuk mencari lintas 114 surah, atau ketuk ayat pilihan di bawah untuk membaca Tafsir Ringkas.',
                          style: t.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        for (final entry in curatedConciseTafsir.entries.take(12))
                          Card(
                            child: ListTile(
                              leading: OctagonNumber(entry.key.$2),
                              title: Text(
                                'QS. ${surahs[entry.key.$1 - 1].name}: ${entry.key.$2}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(entry.value, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                                Text('Ayat tidak ditemukan', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  'Tidak ada ayat yang cocok dengan "${_searchController.text.trim()}".',
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
                                  label: const Text('Hapus pencarian'),
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
                            return Card(
                              child: ListTile(
                                leading: OctagonNumber(m.ayah.number),
                                title: Text(
                                  'QS. ${m.surah.name}: ${m.ayah.number}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(m.snippet, maxLines: 3, overflow: TextOverflow.ellipsis),
                                trailing: PopupMenuButton<String>(
                                  tooltip: 'Tindakan ayat',
                                  onSelected: (v) {
                                    if (v == 'tafsir') {
                                      showAyahTafsirSheet(context, ref, surah: m.surah, ayah: m.ayah).then((_) => _loadNotes());
                                    } else if (v == 'mushaf') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => SurahPage(surah: m.surah, initialAyah: m.ayah.number)),
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'tafsir', child: Text('Baca Tafsir & Catatan')),
                                    PopupMenuItem(value: 'mushaf', child: Text('Buka di Mushaf')),
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
                Text(topic.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(topic.description, style: t.bodySmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in topic.verses)
                      ActionChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text('QS. ${surahs[v.surah - 1].name}: ${v.ayah}'),
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
              Text('Belum ada catatan ayat', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Ketuk salah satu ayat di tab Cari Ayat, Indeks Tema, atau langsung dari halaman Surah untuk menulis catatan tadabbur pribadi.',
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _tab = 1),
                icon: const Icon(MoeslimIcons.daftar),
                label: const Text('Lihat Indeks Tema'),
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
            title: Text('QS. ${s.name}: ${n.ayah}', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(n.note),
            trailing: IconButton(
              tooltip: 'Hapus catatan',
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
