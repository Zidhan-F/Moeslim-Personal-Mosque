import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';
import '../ibadah/share_card_page.dart';
import 'audio/audio_providers.dart';
import 'audio/quran_player_bar.dart';
import 'murottal_page.dart';
import 'quran_source.dart';
import 'tafsir_search_page.dart';
import 'tajweed_view.dart';

/// Pembaca mushaf per surah (desain "Mushaf"): ornamen judul, ayat ber-nomor oktagon, terjemahan,
/// lompat ke ayat tertentu, dan bar pemutar murottal ringkas.
class SurahPage extends ConsumerStatefulWidget {
  final Surah surah;
  final int? initialAyah;
  const SurahPage({super.key, required this.surah, this.initialAyah});

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
    Future.microtask(() => ref.read(quranPlayerProvider.notifier).prepare(surah.number));
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
    ref.listen<int?>(
      quranPlayerProvider.select((p) => p.surah == surah.number && p.playing ? p.current?.ayah : null),
      (prev, next) {
        if (next != null && next != prev && _items.isAttached) {
          _items.scrollTo(
            index: next,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: 0.15,
          );
        }
      },
    );

    final text = ref.watch(surahTextProvider(surah.number));
    final settings = ref.watch(settingsProvider).value;
    final scale = settings?.fontScale ?? 1.0;
    final tajweedOn = settings?.tajweedColors ?? true;
    final player = ref.watch(
      quranPlayerProvider.select(
        (p) => (recitation: p.recitation, surah: p.surah, ayah: p.current?.ayah, playing: p.playing),
      ),
    );
    final canPlay = player.recitation != null && player.surah == surah.number;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget playButton(int ayah) {
      final isPlayingThis = player.ayah == ayah && player.playing;
      return IconButton(
        key: Key('play-ayah-$ayah'),
        tooltip: isPlayingThis
            ? context.tr('Jeda ayat $ayah', 'Pause verse $ayah')
            : context.tr('Putar mulai ayat $ayah', 'Play from verse $ayah'),
        icon: Icon(isPlayingThis ? MoeslimIcons.suara : MoeslimIcons.play),
        onPressed: canPlay ? () => ref.read(quranPlayerProvider.notifier).playOrToggleFromAyah(ayah) : null,
      );
    }

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
          Text(
            context.tr(
              '${surah.revelation} • ${surah.ayahCount} Ayat • Juz ${juzOf(surah.number, 1)}',
              '${context.surahRev(surah)} • ${surah.ayahCount} Verses • Juz ${juzOf(surah.number, 1)}',
            ),
            style: t.bodySmall,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: BrandElementArt(BrandElement.ayahDivider, width: 150, height: 26),
          ),
          if (showsBasmalaHeader(surah.number))
            Padding(
              key: const Key('basmala-header'),
              padding: const EdgeInsets.only(top: 14),
              child: TajweedText(
                ayah: Ayah(surah.number, 0, basmala, tajweed: classifyTajweed(basmala)),
                colored: tajweedOn,
                textAlign: TextAlign.center,
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
            tooltip: tajweedOn
                ? context.tr('Matikan warna tajwid', 'Disable tajweed colors')
                : context.tr('Nyalakan warna tajwid', 'Enable tajweed colors'),
            isSelected: tajweedOn,
            icon: const Icon(Icons.format_color_text),
            onPressed: () {
              if (settings != null) {
                ref.read(settingsProvider.notifier).save(settings.copyWith(tajweedColors: !tajweedOn));
              }
            },
          ),
          PopupMenuButton<String>(
            tooltip: context.tr('Lainnya', 'More'),
            onSelected: (v) {
              if (v == 'legend') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TajweedLegendPage()));
              }
              if (v == 'murottal') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => MurottalPage(initialSurah: surah.number)));
              }
            },
            itemBuilder: (menuContext) => [
              PopupMenuItem(
                value: 'murottal',
                child: ListTile(
                  leading: const Icon(MoeslimIcons.audio),
                  title: Text(menuContext.tr('Buka Murottal', 'Open Recitation')),
                ),
              ),
              PopupMenuItem(
                key: const Key('tajweed-legend'),
                value: 'legend',
                child: ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(menuContext.tr('Panduan warna tajwid', 'Tajweed color guide')),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: QuranPlayerBar(surah: surah),
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
                    Expanded(
                      child: Text(
                        context.tr(
                          'Surah ke-${surah.number} • ${surah.ayahCount} Ayat',
                          'Surah ${surah.number} • ${surah.ayahCount} Verses',
                        ),
                        style: t.bodySmall,
                      ),
                    ),
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
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr(
                            'Teks Al-Qur\'an belum tersedia di perangkat.',
                            'Qur\'an text is not yet available on this device.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      for (var a = 1; a <= surah.ayahCount; a++)
                        ListTile(
                          dense: true,
                          title: Text(context.tr('Ayat $a', 'Verse $a')),
                          trailing: playButton(a),
                        ),
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
                    final active = player.ayah == a.number && player.surah == surah.number;
                    final translation = a.translationFor(context.lang);
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
                              IconButton(
                                key: Key('share-ayah-${a.number}'),
                                tooltip: context.tr(
                                  'Buat kartu ayat ${a.number}',
                                  'Create card for verse ${a.number}',
                                ),
                                icon: const Icon(MoeslimIcons.bagikan),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ShareCardPage(
                                      initialArabic: a.text,
                                      initialTranslation: translation ?? '',
                                      initialSource: context.tr(
                                        'QS. ${surah.name}: ${a.number}',
                                        'Quran ${surah.name} (${surah.number}): ${a.number}',
                                      ),
                                      initialBadge: context.tr('Al-Qur\'an', 'Al-Quran'),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                key: Key('tafsir-ayah-${a.number}'),
                                tooltip: context.tr(
                                  'Tafsir & catatan ayat ${a.number}',
                                  'Tafsir & notes for verse ${a.number}',
                                ),
                                icon: const Icon(MoeslimIcons.buku),
                                onPressed: () => showAyahTafsirSheet(context, ref, surah: surah, ayah: a),
                              ),
                              playButton(a.number),
                              IconButton(
                                tooltip: marked
                                    ? context.tr('Hapus penanda', 'Remove bookmark')
                                    : context.tr('Tandai ayat', 'Bookmark verse'),
                                icon: Icon(
                                  marked ? MoeslimIcons.bookmark : MoeslimIcons.penanda,
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
                          if (translation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(translation, style: TextStyle(fontSize: 14.5 * scale, height: 1.5)),
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
