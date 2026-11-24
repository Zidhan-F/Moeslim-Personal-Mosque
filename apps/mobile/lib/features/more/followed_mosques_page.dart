import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../learning/learning_path_page.dart';
import '../masjid/session.dart';
import '../services/personal_services_page.dart';
import 'ramadan_local_page.dart';

final _followedProvider = FutureProvider.autoDispose((ref) => ref.watch(favoriteMosqueRepoProvider).all());

class FollowedMosquesPage extends ConsumerWidget {
  /// true bila ditampilkan sebagai tab utama "Masjid" (tanpa tombol kembali).
  final bool asTab;
  const FollowedMosquesPage({super.key, this.asTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followed = ref.watch(_followedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Masjid Diikuti', 'Followed Mosques')),
        centerTitle: true,
        automaticallyImplyLeading: !asTab,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: context.tr('Cari masjid', 'Search mosques'),
        child: const Icon(MoeslimIcons.pencarian),
        onPressed: () async {
          await showSearch(
            context: context,
            delegate: _MosqueSearch(ref, searchFieldLabel: context.tr('Nama masjid', 'Mosque name')),
          );
          ref.invalidate(_followedProvider);
        },
      ),
      body: followed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    context.tr(
                      'Ikuti masjid di sekitar Anda untuk melihat agenda kajian dan pengumuman publiknya, gratis tanpa akun. Ketuk ikon cari.',
                      'Follow mosques near you to view public events and announcements, free with no account. Tap the search icon.',
                    ),
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
                      onTap: () => Navigator.of(context)
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
  _MosqueSearch(this.ref, {required String searchFieldLabel}) : super(searchFieldLabel: searchFieldLabel);

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
            tooltip: context.tr('Berhenti mengikuti', 'Unfollow'),
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
                context.tr(
                  '${_offline ? 'Offline: ' : ''}terakhir sinkron ${context.shortDateText(c.fetchedAt.toLocal())} ${hhmm(c.fetchedAt.toLocal())}',
                  '${_offline ? 'Offline: ' : ''}last synced ${context.shortDateText(c.fetchedAt.toLocal())} ${hhmm(c.fetchedAt.toLocal())}',
                ),
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const SoftArt(SoftAsset.ramadanMosque, width: 18, height: 18, thumbnail: true),
                  label: Text(context.tr('Ramadan Masjid', 'Mosque Ramadan')),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RamadanLocalPage(
                        initialMosqueSlug: widget.mosque.slug,
                        initialMosqueName: widget.mosque.name,
                      ),
                    ),
                  ),
                ),
                ActionChip(
                  avatar: const SoftArt(SoftAsset.learningPath, width: 18, height: 18, thumbnail: true),
                  label: Text(context.tr('Kelas Masjid', 'Mosque Classes')),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LearningPathPage(
                        initialTab: 2,
                        initialMosqueSlug: widget.mosque.slug,
                        initialMosqueName: widget.mosque.name,
                      ),
                    ),
                  ),
                ),
                ActionChip(
                  avatar: const SoftArt(SoftAsset.mosqueServices, width: 18, height: 18, thumbnail: true),
                  label: Text(context.tr('Layanan Masjid', 'Mosque Services')),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PersonalServicesPage(
                        initialMosqueSlug: widget.mosque.slug,
                        initialMosqueName: widget.mosque.name,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (c == null && !_offline) const Center(child: CircularProgressIndicator()),
            if (c == null && _offline)
              Text(
                context.tr(
                  'Belum ada data tersimpan dan perangkat sedang offline.',
                  'No cached data yet and your device is offline.',
                ),
              ),
            if (c != null) ...[
              ListTile(title: Text(context.tr('Pengumuman', 'Announcements'))),
              for (final a in (c.data['announcements'] as List).cast<Map>())
                Card(
                  child: ListTile(title: Text('${a['title']}'), subtitle: Text('${a['body']}')),
                ),
              ListTile(title: Text(context.tr('Agenda', 'Events'))),
              for (final e in (c.data['events'] as List).cast<Map>())
                Card(
                  child: ListTile(
                    title: Text('${e['title']}'),
                    subtitle: Text(
                      '${context.shortDateText(DateTime.parse(e['starts_at'] as String).toLocal())}'
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
