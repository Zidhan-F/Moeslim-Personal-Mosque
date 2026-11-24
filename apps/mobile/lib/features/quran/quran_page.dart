import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import 'khatam_planner_page.dart';
import 'murottal_page.dart';
import 'quran_study_suite_page.dart';
import 'surah_page.dart';
import 'tafsir_search_page.dart';
import 'tahfidz_page.dart';
import 'tajweed_learning_page.dart';

final _bookmarksProvider = FutureProvider.autoDispose((ref) => ref.watch(quranProgressProvider).bookmarks());
final _lastReadProvider = FutureProvider.autoDispose((ref) => ref.watch(quranProgressProvider).lastRead());

/// Al-Qur'an: tab Mushaf (lanjut baca, penanda, murottal), Surah (114 surah), Juz (30 juz).
class QuranPage extends ConsumerStatefulWidget {
  const QuranPage({super.key});

  @override
  ConsumerState<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends ConsumerState<QuranPage> {
  int _tab = 1;
  bool _searching = false;
  String _query = '';

  Future<void> _open(int surah, [int? ayah]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahPage(surah: surahs[surah - 1], initialAyah: ayah),
      ),
    );
    ref.invalidate(_bookmarksProvider);
    ref.invalidate(_lastReadProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _searching
            ? TextField(
                key: const Key('surah-search'),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.tr('Cari surah (nama atau nomor)', 'Search surah (name or number)'),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : Text(context.tr("Al-Qur'an", "Qur'an")),
        actions: [
          IconButton(
            tooltip: _searching
                ? context.tr('Tutup pencarian', 'Close search')
                : context.tr('Cari surah', 'Search surah'),
            icon: Icon(_searching ? MoeslimIcons.tutup : MoeslimIcons.pencarian),
            onPressed: () => setState(() {
              _searching = !_searching;
              _query = '';
              if (_searching) _tab = 1;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: PillTabs(
              labels: const ['Mushaf', 'Surah', 'Juz'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _MushafTab(onOpen: _open),
              2 => _JuzTab(onOpen: _open),
              _ => _SurahTab(query: _query, onOpen: _open),
            },
          ),
        ],
      ),
    );
  }
}

class _SurahTab extends StatelessWidget {
  final String query;
  final void Function(int surah, [int? ayah]) onOpen;
  const _SurahTab({required this.query, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase().replaceAll(RegExp(r"[\s'\-]"), '');
    final list = surahs
        .where(
          (s) => q.isEmpty || s.name.toLowerCase().replaceAll(RegExp(r"[\s'\-]"), '').contains(q) || '${s.number}' == q,
        )
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: list.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(
            children: [
              OrnamentCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('Daftar Surah\nAl-Qur\'an', 'Surahs of\nthe Qur\'an'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: BrandColors.emerald),
                          ),
                          const SizedBox(height: 4),
                          Text(context.tr('114 Surah • 6.236 Ayat', '114 Surahs • 6,236 Verses')),
                        ],
                      ),
                    ),
                    const BrandArt(BrandIllustration.heroQuran, height: 104),
                  ],
                ),
              ),
            ],
          );
        }
        final s = list[i - 1];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: OctagonNumber(s.number),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              context.tr(
                '${s.revelation} • ${s.ayahCount} Ayat',
                '${context.surahRev(s)} • ${s.ayahCount} Verses',
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.arabicName, style: quranTextStyle(fontSize: 22, color: Theme.of(context).colorScheme.primary)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => onOpen(s.number),
          ),
        );
      },
    );
  }
}

class _JuzTab extends StatelessWidget {
  final void Function(int surah, [int? ayah]) onOpen;
  const _JuzTab({required this.onOpen});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    itemCount: juzStarts.length,
    itemBuilder: (_, i) {
      final (s, a) = juzStarts[i];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          key: Key('juz-${i + 1}'),
          leading: OctagonNumber(i + 1),
          title: Text('Juz ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            context.tr(
              'Mulai ${surahs[s - 1].name} ayat $a',
              'Starts at ${surahs[s - 1].name}, verse $a',
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(s, a),
        ),
      );
    },
  );
}

class _MushafTab extends ConsumerWidget {
  final void Function(int surah, [int? ayah]) onOpen;
  const _MushafTab({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastRead = ref.watch(_lastReadProvider).value;
    final bookmarks = ref.watch(_bookmarksProvider).value ?? const [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        PatternBanner(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Lanjut baca', 'Continue reading'), style: const TextStyle(color: BrandColors.cream)),
                    Text(
                      lastRead == null ? 'Al-Fatihah' : surahs[lastRead.surah - 1].name,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      lastRead == null
                          ? context.tr('Mulai membaca', 'Start reading')
                          : context.tr(
                              'Ayat ${lastRead.ayah} • Juz ${juzOf(lastRead.surah, lastRead.ayah)}',
                              'Verse ${lastRead.ayah} • Juz ${juzOf(lastRead.surah, lastRead.ayah)}',
                            ),
                      style: const TextStyle(color: BrandColors.cream),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                key: const Key('continue-reading'),
                onPressed: () => onOpen(lastRead?.surah ?? 1, lastRead?.ayah),
                icon: const Icon(MoeslimIcons.play),
                label: Text(context.tr('Buka', 'Open')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            key: const Key('open-murottal'),
            leading: const SoftArt(SoftAsset.headphones, width: 36, height: 36, thumbnail: true),
            title: Text(
              context.tr('Murottal Al-Qur\'an', 'Qur\'an Audio Recitation'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              context.tr(
                'Dengarkan per ayat atau per surah dengan qari pilihan',
                'Listen verse by verse or by surah with selected reciters',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MurottalPage(initialSurah: lastRead?.surah ?? 1)),
            ),
          ),
        ),
        Card(
          child: ListTile(
            key: const Key('open-tafsir-search'),
            leading: const SoftArt(SoftAsset.search, width: 36, height: 36, thumbnail: true),
            title: Text(
              context.tr('Tafsir Ringkas & Pencarian Ayat', 'Concise Tafsir & Verse Search'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              context.tr(
                'Cari kata di 6.236 ayat, indeks tematik & catatan tadabbur pribadi',
                'Search 6,236 verses, thematic index & personal reflection notes',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TafsirSearchPage())),
          ),
        ),
        Card(
          child: ListTile(
            key: const Key('open-tahfidz'),
            leading: const SoftArt(SoftAsset.target, width: 36, height: 36, thumbnail: true),
            title: Text(
              context.tr('Mode Hafalan (Tahfidz & Muraja\'ah)', 'Memorization Mode (Tahfidz & Review)'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              context.tr(
                'Uji sambung ayat, tutup teks Arab, progres surah & jadwal muraja\'ah',
                'Verse continuation drills, hidden Arabic mode, surah progress & review schedule',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TahfidzPage(initialSurah: lastRead?.surah ?? 112)),
            ),
          ),
        ),
        Card(
          child: ListTile(
            key: const Key('open-khatam-planner'),
            leading: const SoftArt(SoftAsset.khatam, width: 36, height: 36, thumbnail: true),
            title: Text(
              context.tr('Perencana Khatam Al-Qur\'an', 'Qur\'an Khatam Planner'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              context.tr(
                'Target 30/60/90 hari dengan pembagian halaman per waktu salat',
                '30/60/90-day goals with pages split across daily prayers',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KhatamPlannerPage())),
          ),
        ),
        Card(
          child: ListTile(
            key: const Key('open-tajweed-learning'),
            leading: const SoftArt(SoftAsset.tajweed, width: 36, height: 36, thumbnail: true),
            title: Text(
              context.tr('Belajar Tajwid & Makharijul Huruf', 'Learn Tajweed & Articulation Points'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              context.tr(
                'Materi hukum tajwid, 5 area makhraj huruf & kuis interaktif',
                'Tajweed rules, 5 letter articulation areas & interactive quiz',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TajweedLearningPage())),
          ),
        ),
        Card(
          child: ListTile(
            key: const Key('open-quran-study-suite'),
            leading: const SoftArt(SoftAsset.quranStudy, width: 36, height: 36, thumbnail: true),
            title: Text(
              context.tr(
                'Pendalaman Al-Qur\'an, Kata per Kata & Fokus Tilawah',
                'Qur\'an Study, Word by Word & Focus Reading',
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              context.tr(
                'Terjemah per kata, Asbabun Nuzul, Flashcard Arab, Sajdah & Fokus Tilawah',
                'Word-by-word meanings, Asbabun Nuzul, Arabic flashcards, Sajdah & Focus Reading',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranStudySuitePage())),
          ),
        ),
        SectionHeader(context.tr('Penanda (${bookmarks.length})', 'Bookmarks (${bookmarks.length})')),
        if (bookmarks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              context.tr(
                'Belum ada penanda. Ketuk ikon penanda pada ayat saat membaca.',
                'No bookmarks yet. Tap the bookmark icon on any verse while reading.',
              ),
            ),
          ),
        for (final b in bookmarks)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(MoeslimIcons.bookmark, color: BrandColors.goldText),
              title: Text('${surahs[b.surah - 1].name} : ${b.ayah}'),
              subtitle: Text('Juz ${juzOf(b.surah, b.ayah)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpen(b.surah, b.ayah),
            ),
          ),
      ],
    );
  }
}
