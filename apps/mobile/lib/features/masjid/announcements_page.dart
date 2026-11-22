import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'agenda_page.dart' show categoryLabel;
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'poster_share_sheet.dart';
import 'session.dart';

/// Kelola Konten & Pengumuman: pengumuman dan agenda dengan sakelar "tayang di TV".
class AnnouncementsPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const AnnouncementsPage({super.key, required this.ctx});

  @override
  ConsumerState<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends ConsumerState<AnnouncementsPage> {
  int _tab = 0;

  bool get _canToggle => widget.ctx.can('events.display');
  bool get _canWrite => widget.ctx.can('events.write');

  Future<void> _run(Future<void> Function() f) async {
    try {
      await f();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final anns = ref.watch(announcementsProvider(ctx.id));
    final events = ref.watch(eventsProvider(ctx.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Konten & Pengumuman'), centerTitle: true),
      floatingActionButton: _canWrite && _tab == 0
          ? FloatingActionButton.extended(
              heroTag: null,
              key: const Key('add-announcement'),
              icon: const Icon(MoeslimIcons.tambah),
              label: const Text('Tambah Pengumuman'),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _AnnouncementForm(ctx: ctx),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(announcementsProvider(ctx.id));
          ref.invalidate(eventsProvider(ctx.id));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            PillTabs(
              labels: const ['Pengumuman', 'Jadwal Tayang'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            if (_tab == 0)
              AsyncBody(
                value: anns,
                onRetry: () => ref.invalidate(announcementsProvider(ctx.id)),
                data: (list) => list.isEmpty
                    ? const EmptyState(MoeslimIcons.pengumuman, 'Belum ada pengumuman aktif')
                    : Column(
                        children: [
                          for (final a in list)
                            Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(MoeslimIcons.pengumuman, color: BrandColors.emerald),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${a['title']}',
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        IconButton(
                                          key: Key('share-ann-${a['id']}'),
                                          tooltip: 'Bagikan Poster & WA',
                                          icon: const Icon(Icons.share_outlined, size: 20),
                                          onPressed: () => showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            showDragHandle: true,
                                            builder: (_) => PosterShareSheet(data: WaTextBuilder.forAnnouncement(ctx.name, a)),
                                          ),
                                        ),
                                        if (_canWrite)
                                          IconButton(
                                            tooltip: 'Arsipkan',
                                            icon: const Icon(MoeslimIcons.arsip),
                                            onPressed: () => _run(() async {
                                              await ref
                                                  .read(masjidApiProvider)
                                                  .archiveAnnouncement(ctx.id, a['id'] as int);
                                              ref.invalidate(announcementsProvider(ctx.id));
                                            }),
                                          ),
                                      ],
                                    ),
                                    Text('${a['body']}', maxLines: 3, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        StatusBadge(
                                          a['visibility'] == 'public' ? 'Publik' : 'Internal',
                                          icon: a['visibility'] == 'public' ? MoeslimIcons.web : MoeslimIcons.kunci,
                                        ),
                                        const Spacer(),
                                        const Text('Tayang di TV', style: TextStyle(fontSize: 12.5)),
                                        Switch(
                                          key: Key('ann-display-${a['id']}'),
                                          value: a['show_on_display'] == true,
                                          onChanged: _canToggle && a['visibility'] == 'public'
                                              ? (v) => _run(() async {
                                                  await ref
                                                      .read(masjidApiProvider)
                                                      .toggleAnnouncementDisplay(ctx.id, a['id'] as int, v);
                                                  ref.invalidate(announcementsProvider(ctx.id));
                                                })
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              )
            else
              AsyncBody(
                value: events,
                onRetry: () => ref.invalidate(eventsProvider(ctx.id)),
                data: (list) => list.isEmpty
                    ? const EmptyState(MoeslimIcons.kegiatan, 'Belum ada agenda aktif', art: BrandEmptyArt.agenda)
                    : Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final e in list)
                              SwitchListTile(
                                key: Key('event-display-${e['id']}'),
                                secondary: const Icon(MoeslimIcons.kegiatan, color: BrandColors.emerald),
                                title: Text('${e['title']}'),
                                subtitle: Text(
                                  '${shortDate(DateTime.parse(e['starts_at'] as String).toLocal())} • ${categoryLabel(e['category'] as String?)}',
                                ),
                                value: e['show_on_display'] == true,
                                onChanged: _canToggle && e['visibility'] == 'public'
                                    ? (v) => _run(() async {
                                        await ref.read(masjidApiProvider).toggleEventDisplay(ctx.id, e['id'] as int, v);
                                        ref.invalidate(eventsProvider(ctx.id));
                                      })
                                    : null,
                              ),
                          ],
                        ),
                      ),
              ),
            const SizedBox(height: 8),
            const Text('Hanya konten publik yang dapat ditayangkan di TV Display.', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementForm extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const _AnnouncementForm({required this.ctx});

  @override
  ConsumerState<_AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends ConsumerState<_AnnouncementForm> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _public = true;
  bool _display = true;
  String? _error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pengumuman Baru', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          key: const Key('ann-title'),
          controller: _title,
          decoration: const InputDecoration(labelText: 'Judul'),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('ann-body'),
          controller: _body,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Isi pengumuman', alignLabelWithHint: true),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Publik'),
          value: _public,
          onChanged: (v) => setState(() => _public = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tayangkan di TV Display'),
          value: _public && _display,
          onChanged: _public ? (v) => setState(() => _display = v) : null,
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('save-announcement'),
          onPressed: () async {
            try {
              await ref.read(masjidApiProvider).createAnnouncement(widget.ctx.id, {
                'title': _title.text.trim(),
                'body': _body.text.trim(),
                'visibility': _public ? 'public' : 'internal',
                'show_on_display': _public && _display,
              });
              ref.invalidate(announcementsProvider(widget.ctx.id));
              if (context.mounted) Navigator.pop(context);
            } on ApiException catch (e) {
              setState(
                () => _error = e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message,
              );
            }
          },
          child: const Text('Terbitkan'),
        ),
      ],
    ),
  );
}
