import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import 'naghom_pages.dart';
import 'surah_page.dart';

final _bookmarksProvider = FutureProvider.autoDispose((ref) => ref.watch(quranProgressProvider).bookmarks());
final _lastReadProvider = FutureProvider.autoDispose((ref) => ref.watch(quranProgressProvider).lastRead());

class QuranPage extends ConsumerStatefulWidget {
  const QuranPage({super.key});

  @override
  ConsumerState<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends ConsumerState<QuranPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lastRead = ref.watch(_lastReadProvider).value;
    final bookmarks = ref.watch(_bookmarksProvider).value ?? const [];
    final q = _query.toLowerCase().replaceAll(RegExp(r"[\s'\-]"), '');
    final list = surahs
        .where(
          (s) => q.isEmpty || s.name.toLowerCase().replaceAll(RegExp(r"[\s'\-]"), '').contains(q) || '${s.number}' == q,
        )
        .toList();

    void open(int surah, [int? ayah]) async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SurahPage(surah: surahs[surah - 1], initialAyah: ayah),
        ),
      );
      ref.invalidate(_bookmarksProvider);
      ref.invalidate(_lastReadProvider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Al-Qur'an")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                key: const Key('naghom-entry'),
                leading: const Icon(Icons.graphic_eq),
                title: const Text('Belajar 7 Irama (Naghom)'),
                subtitle: const Text('Pengenalan irama tilawah — tidak menggantikan tajwid & guru'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NaghomCatalogPage())),
              ),
            ),
          ),
          if (lastRead != null)
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Lanjut baca'),
              subtitle: Text('${surahs[lastRead.surah - 1].name}, ayat ${lastRead.ayah}'),
              onTap: () => open(lastRead.surah, lastRead.ayah),
            ),
          if (bookmarks.isNotEmpty)
            ExpansionTile(
              leading: const Icon(Icons.bookmark),
              title: Text('Bookmark (${bookmarks.length})'),
              children: [
                for (final b in bookmarks)
                  ListTile(title: Text('${surahs[b.surah - 1].name} : ${b.ayah}'), onTap: () => open(b.surah, b.ayah)),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari surah (nama atau nomor)',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          for (final s in list)
            ListTile(
              leading: CircleAvatar(child: Text('${s.number}')),
              title: Text(s.name),
              subtitle: Text('${s.revelation} • ${s.ayahCount} ayat'),
              onTap: () => open(s.number),
            ),
        ],
      ),
    );
  }
}
