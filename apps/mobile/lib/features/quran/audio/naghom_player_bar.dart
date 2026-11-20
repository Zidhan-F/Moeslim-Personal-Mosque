import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'audio_providers.dart';

/// Panel pemutar: pilih 1 dari 7 irama naghom, qari, putar surah, ulang ayat, unduh offline.
class NaghomPlayerBar extends ConsumerStatefulWidget {
  final Surah surah;
  const NaghomPlayerBar({super.key, required this.surah});

  @override
  ConsumerState<NaghomPlayerBar> createState() => _NaghomPlayerBarState();
}

class _NaghomPlayerBarState extends ConsumerState<NaghomPlayerBar> {
  double? _download; // 0..1 saat mengunduh
  bool _downloaded = false;

  Future<void> _checkDownloaded(Recitation? r) async {
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
    ref.listen(
      quranPlayerProvider.select((s) => s.recitation?.id),
      (_, _) => _checkDownloaded(ref.read(quranPlayerProvider).recitation),
    );

    return Material(
      elevation: 8,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pilih irama (naghom)', style: Theme.of(context).textTheme.labelMedium),
              Wrap(
                key: const Key('naghom-options'),
                spacing: 6,
                runSpacing: 0,
                children: [
                  for (final o in options)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Tooltip(
                        message: o.available ? o.description : 'Rekaman ${o.label} untuk surah ini belum tersedia',
                        child: ChoiceChip(
                          key: Key('naghom-${o.key}'),
                          label: Text(o.label),
                          selected: o.key == player.naghom,
                          onSelected: o.available ? (_) => ctl.selectNaghom(o.key) : null,
                        ),
                      ),
                    ),
                ],
              ),
              if (selected == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Belum ada rekaman berlisensi untuk surah ini. Murattal & 7 irama ditambahkan setelah izin dan telaah qari.',
                    key: Key('no-audio'),
                  ),
                )
              else ...[
                if (selected.recitations.length > 1)
                  DropdownButton<String>(
                    isExpanded: true,
                    value: rec?.id,
                    items: [for (final r in selected.recitations) DropdownMenuItem(value: r.id, child: Text(r.qari))],
                    onChanged: (id) => ctl.selectNaghom(selected.key, recitationId: id),
                  ),
                Row(
                  children: [
                    IconButton.filled(
                      key: const Key('play-surah'),
                      tooltip: player.playing ? 'Jeda' : 'Putar surah',
                      icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                      onPressed: () => player.queue.isEmpty ? ctl.playFrom(1) : ctl.togglePause(),
                    ),
                    IconButton(tooltip: 'Berhenti', icon: const Icon(Icons.stop), onPressed: ctl.stop),
                    IconButton(
                      key: const Key('repeat-ayah'),
                      tooltip: 'Ulang ayat',
                      isSelected: player.repeatAyah,
                      icon: const Icon(Icons.repeat_one),
                      onPressed: ctl.toggleRepeat,
                    ),
                    Expanded(
                      child: Text(
                        player.current != null
                            ? '${selected.label} • ayat ${player.current!.ayah}'
                            : '${selected.label} • ${rec?.qari ?? ''}',
                        key: const Key('now-playing'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_download != null)
                      SizedBox.square(dimension: 24, child: CircularProgressIndicator(value: _download, strokeWidth: 3))
                    else
                      IconButton(
                        tooltip: _downloaded ? 'Tersimpan offline' : 'Unduh surah untuk offline',
                        icon: Icon(_downloaded ? Icons.download_done : Icons.download),
                        onPressed: _downloaded || rec == null
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Unduhan gagal. Coba lagi saat online.')),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _download = null);
                                }
                              },
                      ),
                  ],
                ),
                if (rec != null)
                  Text('${rec.attribution} • Lisensi: ${rec.license}', style: const TextStyle(fontSize: 11)),
              ],
              if (player.error != null) Text(player.error!, style: TextStyle(color: scheme.error, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
