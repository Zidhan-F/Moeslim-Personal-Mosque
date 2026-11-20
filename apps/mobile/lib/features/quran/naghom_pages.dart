import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('7 Irama Naghom')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Padding(padding: EdgeInsets.all(12), child: Text(naghomDisclaimer)),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: done.length / naghomStyles.length),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text('${done.length} dari ${naghomStyles.length} irama dipelajari'),
          ),
          for (final (i, s) in naghomStyles.indexed)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(s.name),
                subtitle: Text(s.character, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (fav.contains(s.slug)) const Icon(Icons.star, size: 18),
                    if (done.contains(s.slug)) const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NaghomDetailPage(style: s)));
                  ref.invalidate(_naghomStateProvider);
                },
              ),
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
    final repo = ref.read(naghomProgressProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
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
          _Info('Karakter', s.character),
          _Info(
            'Tingkat nada',
            s.toneLevels != null ? '${s.toneLevels} tingkat (menurut materi awal)' : 'Menunggu kurikulum final',
          ),
          _Info('Penggunaan', s.usage),
          const _Info('Contoh audio', 'Contoh audio berlisensi akan tersedia setelah ditelaah qari/guru tilawah.'),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Catatan latihan pribadi', border: OutlineInputBorder()),
            onChanged: (v) => repo.saveNote(s.slug, v),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
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
