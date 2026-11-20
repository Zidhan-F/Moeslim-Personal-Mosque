import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import 'audio/audio_providers.dart';
import 'audio/naghom_player_bar.dart';
import 'murottal_page.dart';
import 'quran_source.dart';
import 'tajweed_view.dart';

/// Pembaca mushaf per surah (desain "Mushaf"): ornamen judul, ayat ber-nomor oktagon, terjemahan,
/// lompat ke ayat tertentu, dan bar pemutar ringkas dengan pilihan 7 irama.
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
  final _items = ItemScrollController();

  Surah get surah => widget.surah;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    ref.read(quranProgressProvider).setLastRead(AyahRef(surah.number, widget.initialAyah ?? 1));
    Future.microtask(
      () => ref.read(quranPlayerProvider.notifier).prepare(surah.number, prefer: widget.preferredOption),
    );
  }

  Future<void> _loadBookmarks() async {
    final b = await ref.read(quranProgressProvider).bookmarks();
    if (mounted) {
      setState(
        () => _bookmarked = {
          for (final r in b)
            if (r.surah == surah.number) r.ayah,
        },
      );
    }
  }

  void _pickSurah() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      builder: (context, scroll) => ListView.builder(
        controller: scroll,
        itemCount: surahs.length,
        itemBuilder: (_, i) => ListTile(
          leading: OctagonNumber(surahs[i].number, size: 32),
          title: Text(surahs[i].name),
          trailing: Text(surahs[i].arabicName, style: quranTextStyle(fontSize: 20)),
          selected: surahs[i].number == surah.number,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(this.context).pushReplacement(MaterialPageRoute(builder: (_) => SurahPage(surah: surahs[i])));
          },
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(surahTextProvider(surah.number));
    final settings = ref.watch(settingsProvider).value;
    final scale = settings?.fontScale ?? 1.0;
    final tajweedOn = settings?.tajweedColors ?? true;
    final player = ref.watch(quranPlayerProvider);
    final canPlay = player.recitation != null && player.surah == surah.number;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget playButton(int ayah) => IconButton(
      key: Key('play-ayah-$ayah'),
      tooltip: 'Putar ayat $ayah',
      icon: Icon(player.current?.ayah == ayah && player.playing ? Icons.graphic_eq : Icons.play_circle_outline),
      onPressed: canPlay ? () => ref.read(quranPlayerProvider.notifier).playAyah(ayah) : null,
    );

    final header = ArchHeader(
      key: const Key('surah-header'),
      child: Column(
        children: [
          Text(
            'سُورَةُ ${surah.arabicName}',
            textDirection: TextDirection.rtl,
            style: quranTextStyle(fontSize: 34, color: scheme.primary),
          ),
          Text('Surah ${surah.name}', style: t.titleMedium),
          Text('${surah.revelation} • ${surah.ayahCount} Ayat • Juz ${juzOf(surah.number, 1)}', style: t.bodySmall),
          if (showsBasmalaHeader(surah.number))
            Padding(
              key: const Key('basmala-header'),
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                basmala,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: quranTextStyle(fontSize: 26 * scale, color: scheme.primary),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mushaf'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('toggle-tajweed'),
            tooltip: tajweedOn ? 'Matikan warna tajwid' : 'Nyalakan warna tajwid',
            isSelected: tajweedOn,
            icon: const Icon(Icons.format_color_text),
            onPressed: () {
              if (settings != null) {
                ref.read(settingsProvider.notifier).save(settings.copyWith(tajweedColors: !tajweedOn));
              }
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Lainnya',
            onSelected: (v) {
              if (v == 'legend') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TajweedLegendPage()));
              }
              if (v == 'murottal') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => MurottalPage(initialSurah: surah.number)));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'murottal',
                child: ListTile(leading: Icon(Icons.headphones), title: Text('Buka Murottal')),
              ),
              PopupMenuItem(
                key: Key('tajweed-legend'),
                value: 'legend',
                child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('Panduan warna tajwid')),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NaghomPlayerBar(surah: surah),
      body: Column(
        children: [
          Material(
            color: scheme.primary.withValues(alpha: .08),
            child: InkWell(
              key: const Key('surah-picker'),
              onTap: _pickSurah,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text(surah.name, style: t.titleMedium?.copyWith(color: scheme.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Surah ke-${surah.number} • ${surah.ayahCount} Ayat', style: t.bodySmall)),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: text.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (ayat) {
                if (ayat == null) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      header,
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Teks Al-Qur\'an belum tersedia di perangkat.\n\nDataset mushaf dan terjemahan harus diimpor dari sumber '
                          'resmi yang telah ditashih (Lajnah Pentashihan Mushaf Al-Qur\'an Kemenag) beserta izin distribusinya.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      for (var a = 1; a <= surah.ayahCount; a++)
                        ListTile(dense: true, title: Text('Ayat $a'), trailing: playButton(a)),
                    ],
                  );
                }
                final initial = (widget.initialAyah ?? 1).clamp(1, ayat.length);
                return ScrollablePositionedList.separated(
                  itemScrollController: _items,
                  initialScrollIndex: widget.initialAyah == null ? 0 : initial,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: ayat.length + 1,
                  separatorBuilder: (_, i) => i == 0 ? const SizedBox(height: 8) : const Divider(height: 24),
                  itemBuilder: (_, index) {
                    if (index == 0) return header;
                    final a = ayat[index - 1];
                    final marked = _bookmarked.contains(a.number);
                    final active = player.current?.ayah == a.number && player.surah == surah.number;
                    return Container(
                      decoration: active
                          ? BoxDecoration(
                              color: scheme.primary.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              OctagonNumber(a.number),
                              const Spacer(),
                              playButton(a.number),
                              IconButton(
                                tooltip: marked ? 'Hapus penanda' : 'Tandai ayat',
                                icon: Icon(
                                  marked ? Icons.bookmark : Icons.bookmark_border,
                                  color: marked ? BrandColors.goldText : null,
                                ),
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
                            style: TextStyle(fontSize: 26 * scale, height: 2.0),
                          ),
                          if (a.translation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(a.translation!, style: TextStyle(fontSize: 14.5 * scale, height: 1.5)),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
