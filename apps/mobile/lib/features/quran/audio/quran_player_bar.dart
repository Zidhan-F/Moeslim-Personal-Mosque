import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../../core/providers.dart';
import 'audio_providers.dart';

/// Bar pemutar ringkas di bawah mushaf: ukuran huruf, ayat sebelumnya, putar/jeda, ayat berikutnya,
/// dan chip qari yang membuka lembar audio (pilih qari, ulang ayat, unduh offline).
class QuranPlayerBar extends ConsumerWidget {
  final Surah surah;
  const QuranPlayerBar({super.key, required this.surah});

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
    final rec = player.recitation;
    final scheme = Theme.of(context).colorScheme;
    final hasAudio = rec != null;

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
                icon: const Icon(MoeslimIcons.sebelumnya),
                onPressed: hasAudio ? () => ctl.skip(-1) : null,
              ),
              IconButton.filled(
                key: const Key('play-surah'),
                iconSize: 30,
                style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
                tooltip: player.playing ? 'Jeda' : 'Putar surah',
                icon: Icon(player.playing ? MoeslimIcons.pause : MoeslimIcons.play),
                onPressed: hasAudio
                    ? () => player.queue.isEmpty ? ctl.playFrom(1) : ctl.togglePause()
                    : () => showAudioSheet(context, surah),
              ),
              IconButton(
                key: const Key('next-ayah'),
                tooltip: 'Ayat berikutnya',
                icon: const Icon(MoeslimIcons.selanjutnya),
                onPressed: hasAudio ? () => ctl.skip(1) : null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ActionChip(
                  key: const Key('audio-picker'),
                  avatar: Icon(MoeslimIcons.audio, size: 18, color: scheme.primary),
                  label: Text(
                    rec == null
                        ? 'Murottal'
                        : (player.current != null ? '${rec.qari} • ayat ${player.current!.ayah}' : rec.qari),
                    key: const Key('now-playing'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => showAudioSheet(context, surah),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAudioSheet(BuildContext context, Surah surah) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => AudioSheet(surah: surah),
);

/// Lembar audio murottal: pilih qari, ulang ayat, unduh offline, atribusi.
class AudioSheet extends ConsumerStatefulWidget {
  final Surah surah;
  const AudioSheet({super.key, required this.surah});

  @override
  ConsumerState<AudioSheet> createState() => _AudioSheetState();
}

class _AudioSheetState extends ConsumerState<AudioSheet> {
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
    final options = manifest.recitationsFor(widget.surah.number);
    final rec = player.recitation;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Murottal: pilih qari', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (options.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Belum ada rekaman berlisensi untuk surah ini.', key: Key('no-audio')),
              )
            else ...[
              Wrap(
                key: const Key('qari-options'),
                spacing: 6,
                children: [
                  for (final r in options)
                    ChoiceChip(
                      key: Key('qari-${r.id}'),
                      label: Text(r.qari),
                      selected: r.id == rec?.id,
                      onSelected: (_) async {
                        await ctl.selectRecitation(r.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
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
                leading: Icon(_downloaded ? MoeslimIcons.berhasil : MoeslimIcons.unduh, color: scheme.primary),
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
