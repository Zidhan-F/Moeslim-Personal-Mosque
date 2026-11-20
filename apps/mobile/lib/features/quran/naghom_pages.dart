import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import 'audio/audio_providers.dart';
import 'naghom_theme.dart';
import 'surah_page.dart';

final _naghomStateProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(naghomProgressProvider);
  return (completed: await repo.completed(), favorites: await repo.favorites());
});

class NaghomCatalogPage extends ConsumerWidget {
  const NaghomCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_naghomStateProvider).value;
    final done = state?.completed ?? const <String>{};
    final fav = state?.favorites ?? const <String>{};
    final manifest = ref.watch(audioManifestProvider).value ?? AudioManifest.empty;

    return Scaffold(
      appBar: AppBar(title: const Text('7 Jenis Irama (Naghom)'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PatternBanner(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7 Jenis Irama\n(Naghom) Al-Qur\'an',
                        style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pengenalan tujuh irama bacaan Al-Qur\'an yang populer dan banyak digunakan qari\'.',
                        style: TextStyle(color: BrandColors.cream),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.graphic_eq, size: 56, color: BrandColors.gold.withValues(alpha: .95)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: done.length / naghomStyles.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text('${done.length} dari ${naghomStyles.length} irama dipelajari', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          for (final s in naghomStyles)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NaghomDetailPage(style: s)));
                  ref.invalidate(_naghomStateProvider);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: naghomColor(s.slug).withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          child: ToneLevels(levels: s.toneLevels, color: naghomColor(s.slug), height: 26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(width: 6),
                                if (fav.contains(s.slug)) const Icon(Icons.star, size: 16, color: BrandColors.goldText),
                                if (done.contains(s.slug))
                                  Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
                              ],
                            ),
                            Text(s.summary, style: const TextStyle(fontSize: 13)),
                            Text(
                              '${s.toneLabel} • Audio: ${manifest.surahsWithNaghom(s.slug).length}/114 surah',
                              key: Key('coverage-${s.slug}'),
                              style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(naghomDisclaimer, style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class NaghomDetailPage extends ConsumerStatefulWidget {
  final NaghomStyle style;
  const NaghomDetailPage({super.key, required this.style});

  @override
  ConsumerState<NaghomDetailPage> createState() => _NaghomDetailPageState();
}

class _NaghomDetailPageState extends ConsumerState<NaghomDetailPage> {
  final _note = TextEditingController();
  bool _done = false;
  bool _fav = false;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(naghomProgressProvider);
    Future.wait([repo.completed(), repo.favorites(), repo.note(widget.style.slug)]).then((r) {
      if (!mounted) return;
      setState(() {
        _done = (r[0] as Set<String>).contains(widget.style.slug);
        _fav = (r[1] as Set<String>).contains(widget.style.slug);
        _note.text = (r[2] as String?) ?? '';
      });
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final c = naghomColor(s.slug);
    final repo = ref.read(naghomProgressProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Irama ${s.name}'),
        actions: [
          IconButton(
            tooltip: 'Favorit',
            icon: Icon(_fav ? Icons.star : Icons.star_border),
            onPressed: () async {
              final v = await repo.toggleFavorite(s.slug);
              setState(() => _fav = v);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [c, Color.lerp(c, Colors.black, .3)!]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  s.summary,
                  key: const Key('naghom-summary'),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ToneLevels(levels: s.toneLevels, color: Colors.white, height: 48),
                const SizedBox(height: 6),
                Text(
                  s.toneLabel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Info('Karakter', s.character),
          _Info('Penggunaan', s.usage),
          _SampleAudio(style: s),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('listen-with-naghom'),
            style: FilledButton.styleFrom(backgroundColor: c, padding: const EdgeInsets.all(16)),
            icon: const Icon(Icons.headphones),
            label: Text('Dengarkan Al-Qur\'an dengan irama ${s.name}'),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NaghomSurahListPage(style: s))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Catatan latihan pribadi', border: OutlineInputBorder()),
            onChanged: (v) => repo.saveNote(s.slug, v),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: Icon(_done ? Icons.check_circle : Icons.circle_outlined),
            label: Text(_done ? 'Sudah dipelajari' : 'Tandai sudah dipelajari'),
            onPressed: () async {
              await repo.markCompleted(s.slug, done: !_done);
              setState(() => _done = !_done);
            },
          ),
          const SizedBox(height: 12),
          const Text(naghomDisclaimer, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Daftar surah yang dapat didengarkan dengan satu irama; membuka surah dengan irama itu terpilih.
class NaghomSurahListPage extends ConsumerWidget {
  final NaghomStyle style;
  const NaghomSurahListPage({super.key, required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifest = ref.watch(audioManifestProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Surah dengan irama ${style.name}')),
      body: manifest.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (m) {
          final list = m.surahsWithNaghom(style.slug);
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Rekaman irama ${style.name} sedang disiapkan bersama qari dan akan bertambah bertahap.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Text('${list.length} surah tersedia')),
              for (final n in list)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: naghomColor(style.slug),
                    foregroundColor: Colors.white,
                    child: Text('$n'),
                  ),
                  title: Text(surahs[n - 1].name),
                  subtitle: Text('${surahs[n - 1].ayahCount} ayat'),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SurahPage(surah: surahs[n - 1], preferredOption: style.slug),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String title;
  final String body;
  const _Info(this.title, this.body);

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(body),
    ),
  );
}

/// Contoh audio irama: tersedia bila katalog memiliki rekaman irama ini untuk Al-Fatihah.
class _SampleAudio extends ConsumerWidget {
  final NaghomStyle style;
  const _SampleAudio({required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifest = ref.watch(audioManifestProvider).value ?? AudioManifest.empty;
    final option = manifest.naghomOptionsFor(1).firstWhere((o) => o.style.slug == style.slug);
    final player = ref.watch(quranPlayerProvider);
    final playingThis = player.playing && player.naghom == style.slug;
    return Card(
      child: ListTile(
        title: Text('Contoh audio', style: Theme.of(context).textTheme.labelLarge),
        subtitle: Text(
          option.available
              ? '${option.recitations.first.qari} — Al-Fatihah ayat 1'
              : 'Rekaman berlisensi irama ${style.name} akan tersedia setelah ditelaah qari/guru tilawah.',
        ),
        trailing: option.available
            ? IconButton.filled(
                key: const Key('naghom-sample'),
                icon: Icon(playingThis ? Icons.stop : Icons.play_arrow),
                onPressed: () => playingThis
                    ? ref.read(quranPlayerProvider.notifier).stop()
                    : ref.read(quranPlayerProvider.notifier).playSample(style.slug),
              )
            : null,
      ),
    );
  }
}
