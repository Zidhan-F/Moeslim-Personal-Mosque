import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../masjid/session.dart';

final _followedProvider = FutureProvider.autoDispose((ref) => ref.watch(favoriteMosqueRepoProvider).all());

class FollowedMosquesPage extends ConsumerWidget {
  /// true bila ditampilkan sebagai tab utama "Masjid" (tanpa tombol kembali).
  final bool asTab;
  const FollowedMosquesPage({super.key, this.asTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followed = ref.watch(_followedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Diikuti'), centerTitle: true, automaticallyImplyLeading: !asTab),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Cari masjid',
        child: const Icon(MoeslimIcons.pencarian),
        onPressed: () async {
          await showSearch(context: context, delegate: _MosqueSearch(ref));
          ref.invalidate(_followedProvider);
        },
      ),
      body: followed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Ikuti masjid di sekitar Anda untuk melihat agenda kajian dan pengumuman publiknya, gratis tanpa akun. Ketuk ikon cari.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                children: [
                  for (final m in list)
                    ListTile(
                      leading: const Icon(MoeslimIcons.masjid),
                      title: Text(m.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => FollowedMosqueDetailPage(mosque: m))),
                    ),
                ],
              ),
      ),
    );
  }
}

class _MosqueSearch extends SearchDelegate<void> {
  final WidgetRef ref;
  _MosqueSearch(this.ref) : super(searchFieldLabel: 'Nama masjid');

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(MoeslimIcons.tutup), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => BackButton(onPressed: () => close(context, null));

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: ref.read(masjidApiProvider).searchPublicMosques(query),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(
          children: [
            for (final m in snap.data!)
              ListTile(
                title: Text(m['name'] as String),
                subtitle: Text('${m['city']}'),
                trailing: const Icon(MoeslimIcons.tambah),
                onTap: () async {
                  await ref
                      .read(favoriteMosqueRepoProvider)
                      .follow(FollowedMosque(slug: m['slug'] as String, name: m['name'] as String));
                  if (context.mounted) close(context, null);
                },
              ),
          ],
        );
      },
    );
  }
}

/// Konten publik masjid dengan cache lokal: tetap tampil saat offline beserta waktu sinkron terakhir.
class FollowedMosqueDetailPage extends ConsumerStatefulWidget {
  final FollowedMosque mosque;
  const FollowedMosqueDetailPage({super.key, required this.mosque});

  @override
  ConsumerState<FollowedMosqueDetailPage> createState() => _FollowedMosqueDetailPageState();
}

class _FollowedMosqueDetailPageState extends ConsumerState<FollowedMosqueDetailPage> {
  CachedMosqueContent? _content;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(favoriteMosqueRepoProvider);
    final cached = await repo.cache(widget.mosque.slug);
    if (mounted) setState(() => _content = cached);
    try {
      final api = ref.read(masjidApiProvider);
      final data = {
        'events': await api.publicEvents(widget.mosque.slug),
        'announcements': await api.publicAnnouncements(widget.mosque.slug),
      };
      final now = DateTime.now();
      await repo.saveCache(widget.mosque.slug, data, now);
      if (mounted) {
        setState(() {
          _content = CachedMosqueContent(data, now);
          _offline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _offline = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _content;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mosque.name),
        actions: [
          IconButton(
            tooltip: 'Berhenti mengikuti',
            icon: const Icon(Icons.heart_broken),
            onPressed: () async {
              await ref.read(favoriteMosqueRepoProvider).unfollow(widget.mosque.slug);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (c != null)
              Text(
                '${_offline ? 'Offline: ' : ''}terakhir sinkron ${shortDate(c.fetchedAt.toLocal())} ${hhmm(c.fetchedAt.toLocal())}',
                style: const TextStyle(fontSize: 12),
              ),
            if (c == null && !_offline) const Center(child: CircularProgressIndicator()),
            if (c == null && _offline) const Text('Belum ada data tersimpan dan perangkat sedang offline.'),
            if (c != null) ...[
              const ListTile(title: Text('Pengumuman')),
              for (final a in (c.data['announcements'] as List).cast<Map>())
                Card(
                  child: ListTile(title: Text('${a['title']}'), subtitle: Text('${a['body']}')),
                ),
              const ListTile(title: Text('Agenda')),
              for (final e in (c.data['events'] as List).cast<Map>())
                Card(
                  child: ListTile(
                    title: Text('${e['title']}'),
                    subtitle: Text(
                      '${shortDate(DateTime.parse(e['starts_at'] as String).toLocal())}'
                      '${e['speaker'] != null ? ' • ${e['speaker']}' : ''}',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
