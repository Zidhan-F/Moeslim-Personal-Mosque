import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import 'quran_source.dart';

class SurahPage extends ConsumerStatefulWidget {
  final Surah surah;
  final int? initialAyah;
  const SurahPage({super.key, required this.surah, this.initialAyah});

  @override
  ConsumerState<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPage> {
  Set<int> _bookmarked = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    ref.read(quranProgressProvider).setLastRead(AyahRef(widget.surah.number, widget.initialAyah ?? 1));
  }

  Future<void> _loadBookmarks() async {
    final b = await ref.read(quranProgressProvider).bookmarks();
    if (mounted) {
      setState(
        () => _bookmarked = {
          for (final r in b)
            if (r.surah == widget.surah.number) r.ayah,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(surahTextProvider(widget.surah.number));
    final scale = ref.watch(settingsProvider).value?.fontScale ?? 1.0;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.surah.number}. ${widget.surah.name}')),
      body: text.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (ayat) {
          if (ayat == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Teks Al-Qur\'an belum tersedia di perangkat.\n\nDataset mushaf dan terjemahan harus diimpor dari sumber '
                  'resmi yang telah ditashih (Lajnah Pentashihan Mushaf Al-Qur\'an Kemenag) beserta izin distribusinya.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ayat.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (_, i) {
              final a = ayat[i];
              final marked = _bookmarked.contains(a.number);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 14, child: Text('${a.number}', style: const TextStyle(fontSize: 11))),
                      const Spacer(),
                      IconButton(
                        icon: Icon(marked ? Icons.bookmark : Icons.bookmark_border),
                        onPressed: () async {
                          await ref.read(quranProgressProvider).toggleBookmark(a.surah, a.number);
                          await ref.read(quranProgressProvider).setLastRead(AyahRef(a.surah, a.number));
                          _loadBookmarks();
                        },
                      ),
                    ],
                  ),
                  Text(
                    a.text,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 26 * scale, height: 1.9),
                  ),
                  if (a.translation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(a.translation!, style: TextStyle(fontSize: 14 * scale)),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
