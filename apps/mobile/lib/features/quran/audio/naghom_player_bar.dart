import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../../core/providers.dart';
import 'audio_providers.dart';

/// Bar pemutar ringkas di bawah mushaf (sesuai desain): ukuran huruf, ayat sebelumnya, putar/jeda,
/// ayat berikutnya, dan chip irama yang membuka lembar pilihan 7 irama + Murattal.
class NaghomPlayerBar extends ConsumerWidget {
  final Surah surah;
  const NaghomPlayerBar({super.key, required this.surah});

  Future<void> _fontSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final s = ref.watch(settingsProvider).value;
          if (s == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ukuran huruf ${(s.fontScale * 100).round()}%', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  key: const Key('font-slider'),
                  min: 0.85,
                  max: 1.6,
                  divisions: 15,
                  value: s.fontScale,
                  onChanged: (v) => ref.read(settingsProvider.notifier).save(s.copyWith(fontScale: v)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(quranPlayerProvider);
    final ctl = ref.read(quranPlayerProvider.notifier);
    final manifest = ref.watch(audioManifestProvider).value ?? AudioManifest.empty;
    final selected = manifest.optionsFor(surah.number).where((o) => o.key == player.naghom).firstOrNull;
    final scheme = Theme.of(context).colorScheme;
    final hasAudio = selected != null && player.recitation != null;

    return Material(
      key: const Key('player-bar'),
      elevation: 8,
      color: Theme.of(context).cardTheme.color,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              IconButton(
                key: const Key('font-size'),
                tooltip: 'Ukuran huruf',
                icon: const Icon(Icons.text_fields),
                onPressed: () => _fontSheet(context, ref),
              ),
              IconButton(
                key: const Key('prev-ayah'),
                tooltip: 'Ayat sebelumnya',
                icon: const Icon(Icons.skip_previous),
                onPressed: hasAudio ? () => ctl.skip(-1) : null,
              ),
              IconButton.filled(
                key: const Key('play-surah'),
                iconSize: 30,
                style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                tooltip: player.playing ? 'Jeda' : 'Putar surah',
                icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                onPressed: hasAudio
                    ? () => player.queue.isEmpty ? ctl.playFrom(1) : ctl.togglePause()
                    : () => showIramaSheet(context, surah),
              ),
              IconButton(
                key: const Key('next-ayah'),
                tooltip: 'Ayat berikutnya',
                icon: const Icon(Icons.skip_next),
                onPressed: hasAudio ? () => ctl.skip(1) : null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ActionChip(
                  key: const Key('irama-picker'),
                  avatar: Icon(Icons.graphic_eq, size: 18, color: scheme.primary),
                  label: Text(
                    selected == null
                        ? 'Pilih irama'
                        : (player.current != null
                              ? '${selected.label} • ayat ${player.current!.ayah}'
                              : selected.label),
                    key: const Key('now-playing'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => showIramaSheet(context, surah),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showIramaSheet(BuildContext context, Surah surah) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => IramaSheet(surah: surah),
);

/// Lembar pilihan bacaan: 7 irama (fitur andalan) lalu Murattal, qari, ulang ayat, unduh offline, atribusi.
class IramaSheet extends ConsumerStatefulWidget {
  final Surah surah;
  const IramaSheet({super.key, required this.surah});

  @override
  ConsumerState<IramaSheet> createState() => _IramaSheetState();
}

class _IramaSheetState extends ConsumerState<IramaSheet> {
  double? _download;
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final r = ref.read(quranPlayerProvider).recitation;
    if (r == null) return;
    final ok = await ref.read(offlineAudioProvider).isSurahDownloaded(r, widget.surah.number);
    if (mounted) setState(() => _downloaded = ok);
  }

  @override
  Widget build(BuildContext context) {
    final manifest = ref.watch(audioManifestProvider).value ?? AudioManifest.empty;
    final player = ref.watch(quranPlayerProvider);
    final ctl = ref.read(quranPlayerProvider.notifier);
    final options = manifest.optionsFor(widget.surah.number);
    final selected = options.where((o) => o.key == player.naghom).firstOrNull;
    final rec = player.recitation;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pilih irama (naghom)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              key: const Key('naghom-options'),
              spacing: 6,
              children: [
                for (final o in options)
                  Tooltip(
                    message: o.available ? o.description : 'Rekaman ${o.label} untuk surah ini belum tersedia',
                    child: ChoiceChip(
                      key: Key('naghom-${o.key}'),
                      label: Text(o.label),
                      selected: o.key == player.naghom,
                      onSelected: o.available
                          ? (_) async {
                              await ctl.selectNaghom(o.key);
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  ),
              ],
            ),
            if (selected == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Belum ada rekaman berlisensi untuk surah ini. Murattal & 7 irama ditambahkan setelah izin dan telaah qari.',
                  key: Key('no-audio'),
                ),
              )
            else ...[
              if (selected.recitations.length > 1)
                DropdownButtonFormField<String>(
                  initialValue: rec?.id,
                  decoration: const InputDecoration(labelText: 'Qari'),
                  items: [for (final r in selected.recitations) DropdownMenuItem(value: r.id, child: Text(r.qari))],
                  onChanged: (id) => ctl.selectNaghom(selected.key, recitationId: id),
                ),
              SwitchListTile(
                key: const Key('repeat-ayah'),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.repeat_one),
                title: const Text('Ulang ayat'),
                value: player.repeatAyah,
                onChanged: (_) => ctl.toggleRepeat(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_downloaded ? Icons.download_done : Icons.download, color: scheme.primary),
                title: Text(_downloaded ? 'Tersimpan offline' : 'Unduh surah untuk offline'),
                trailing: _download != null
                    ? SizedBox.square(dimension: 24, child: CircularProgressIndicator(value: _download, strokeWidth: 3))
                    : null,
                onTap: _downloaded || rec == null || _download != null
                    ? null
                    : () async {
                        setState(() => _download = 0);
                        try {
                          await ref
                              .read(offlineAudioProvider)
                              .downloadSurah(
                                rec,
                                widget.surah.number,
                                onProgress: (d, t) => mounted ? setState(() => _download = d / t) : null,
                              );
                          if (mounted) setState(() => _downloaded = true);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Unduhan gagal. Coba lagi saat online.')));
                          }
                        } finally {
                          if (mounted) setState(() => _download = null);
                        }
                      },
              ),
              if (rec != null)
                Text(
                  '${rec.attribution} • Lisensi: ${rec.license}',
                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
            ],
            if (player.error != null) Text(player.error!, style: TextStyle(color: scheme.error, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
