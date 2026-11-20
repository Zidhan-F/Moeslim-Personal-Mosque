import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import 'audio/audio_providers.dart';
import 'audio/naghom_player_bar.dart';
import 'quran_source.dart';
import 'tajweed_view.dart';

class SurahPage extends ConsumerStatefulWidget {
  final Surah surah;
  final int? initialAyah;

  /// Pilihan bacaan yang diutamakan saat dibuka (mis. dari halaman irama).
  final String? preferredOption;
  const SurahPage({super.key, required this.surah, this.initialAyah, this.preferredOption});

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
    Future.microtask(
      () => ref.read(quranPlayerProvider.notifier).prepare(widget.surah.number, prefer: widget.preferredOption),
    );
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
    final tajweedOn = ref.watch(settingsProvider).value?.tajweedColors ?? true;

    final player = ref.watch(quranPlayerProvider);
    final canPlay = player.recitation != null && player.surah == widget.surah.number;
    Widget playButton(int ayah) => IconButton(
      key: Key('play-ayah-$ayah'),
      tooltip: 'Putar ayat $ayah',
      icon: Icon(player.current?.ayah == ayah && player.playing ? Icons.graphic_eq : Icons.play_circle_outline),
      onPressed: canPlay ? () => ref.read(quranPlayerProvider.notifier).playAyah(ayah) : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.surah.number}. ${widget.surah.name}'),
        actions: [
          IconButton(
            key: const Key('toggle-tajweed'),
            tooltip: tajweedOn ? 'Matikan warna tajwid' : 'Nyalakan warna tajwid',
            isSelected: tajweedOn,
            icon: const Icon(Icons.format_color_text),
            onPressed: () {
              final s = ref.read(settingsProvider).value;
              if (s != null) ref.read(settingsProvider.notifier).save(s.copyWith(tajweedColors: !tajweedOn));
            },
          ),
          IconButton(
            key: const Key('tajweed-legend'),
            tooltip: 'Panduan warna tajwid',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TajweedLegendPage())),
          ),
        ],
      ),
      bottomNavigationBar: NaghomPlayerBar(surah: widget.surah),
      body: text.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (ayat) {
          if (ayat == null) {
            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Teks Al-Qur\'an belum tersedia di perangkat.\n\nDataset mushaf dan terjemahan harus diimpor dari sumber '
                    'resmi yang telah ditashih (Lajnah Pentashihan Mushaf Al-Qur\'an Kemenag) beserta izin distribusinya.',
                    textAlign: TextAlign.center,
                  ),
                ),
                for (var a = 1; a <= widget.surah.ayahCount; a++)
                  ListTile(dense: true, title: Text('Ayat $a'), trailing: playButton(a)),
              ],
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
                      playButton(a.number),
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
                  TajweedText(
                    key: Key('ayah-${a.number}'),
                    ayah: a,
                    colored: tajweedOn,
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
