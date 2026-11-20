import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import 'murottal_page.dart';
import 'naghom_pages.dart';
import 'surah_page.dart';

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
                decoration: const InputDecoration(hintText: 'Cari surah (nama atau nomor)', border: InputBorder.none),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text("Al-Qur'an"),
        actions: [
          IconButton(
            tooltip: _searching ? 'Tutup pencarian' : 'Cari surah',
            icon: Icon(_searching ? Icons.close : Icons.search),
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
                            'Daftar Surah\nAl-Qur\'an',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: BrandColors.emerald),
                          ),
                          const SizedBox(height: 4),
                          const Text('114 Surah • 6.236 Ayat'),
                        ],
                      ),
                    ),
                    const BrandArt(BrandIllustration.heroQuran, height: 104),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  key: const Key('naghom-entry'),
                  leading: const Icon(Icons.graphic_eq),
                  title: const Text('Belajar 7 Irama (Naghom)'),
                  subtitle: const Text('Fitur andalan — dengarkan surah dengan irama pilihan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NaghomCatalogPage())),
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
            subtitle: Text('${s.revelation} • ${s.ayahCount} Ayat'),
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
          subtitle: Text('Mulai ${surahs[s - 1].name} ayat $a'),
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
                    const Text('Lanjut baca', style: TextStyle(color: BrandColors.cream)),
                    Text(
                      lastRead == null ? 'Al-Fatihah' : surahs[lastRead.surah - 1].name,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      lastRead == null
                          ? 'Mulai membaca'
                          : 'Ayat ${lastRead.ayah} • Juz ${juzOf(lastRead.surah, lastRead.ayah)}',
                      style: const TextStyle(color: BrandColors.cream),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                key: const Key('continue-reading'),
                onPressed: () => onOpen(lastRead?.surah ?? 1, lastRead?.ayah),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Buka'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            key: const Key('open-murottal'),
            leading: const Icon(Icons.headphones, color: BrandColors.emerald),
            title: const Text('Murottal Al-Qur\'an', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Dengarkan dengan qari & 7 irama pilihan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => MurottalPage(initialSurah: lastRead?.surah ?? 1))),
          ),
        ),
        SectionHeader('Penanda (${bookmarks.length})'),
        if (bookmarks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Belum ada penanda. Ketuk ikon penanda pada ayat saat membaca.'),
          ),
        for (final b in bookmarks)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.bookmark, color: BrandColors.goldText),
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
