import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'audio/audio_providers.dart';
import 'audio/quran_player_bar.dart';

/// Halaman Murottal: dengarkan surah utuh dengan qari pilihan, kecepatan, ulang, unduh, daftar putar.
class MurottalPage extends ConsumerStatefulWidget {
  final int initialSurah;
  const MurottalPage({super.key, this.initialSurah = 1});

  @override
  ConsumerState<MurottalPage> createState() => _MurottalPageState();
}

class _MurottalPageState extends ConsumerState<MurottalPage> {
  static const _speeds = [0.75, 1.0, 1.25, 1.5];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = ref.read(quranPlayerProvider);
      if (p.surah == null) ref.read(quranPlayerProvider.notifier).prepare(widget.initialSurah);
    });
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Future<void> _playSurah(int number) async {
    final ctl = ref.read(quranPlayerProvider.notifier);
    await ctl.prepare(number);
    await ctl.playFrom(1);
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(quranPlayerProvider);
    final ctl = ref.read(quranPlayerProvider.notifier);
    final surahNo = player.surah ?? widget.initialSurah;
    final surah = surahs[surahNo - 1];
    final rec = player.recitation;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ayahPos = player.current?.ayah ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Murottal Al-Qur\'an', 'Qur\'an Recitation')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PatternBanner(
            child: Row(
              children: [
                const BrandArt(BrandIllustration.qariBadge, width: 84, height: 84),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Murottal', 'Recitation'), style: const TextStyle(color: BrandColors.cream)),
                      Text(
                        rec?.qari ?? context.tr('Belum ada rekaman', 'No recording available'),
                        key: const Key('murottal-qari'),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('murottal-surah'),
              leading: const Icon(MoeslimIcons.quranTerbuka, color: BrandColors.emerald),
              title: Text(surah.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                context.tr(
                  'Surah ke-${surah.number} • ${surah.ayahCount} Ayat',
                  'Surah ${surah.number} • ${surah.ayahCount} Verses',
                ),
              ),
              trailing: const Icon(MoeslimIcons.audio),
              onTap: () => showAudioSheet(context, surah),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            key: const Key('murottal-progress'),
            value: player.queue.isEmpty ? 0 : ayahPos / surah.ayahCount,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  ayahPos == 0
                      ? context.tr('Ayat –', 'Verse –')
                      : context.tr('Ayat $ayahPos / ${surah.ayahCount}', 'Verse $ayahPos / ${surah.ayahCount}'),
                  style: t.bodySmall,
                ),
                const Spacer(),
                Text('${_fmt(player.position)} / ${_fmt(player.duration ?? Duration.zero)}', style: t.bodySmall),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: context.tr('Ulang ayat', 'Repeat verse'),
                isSelected: player.repeatAyah,
                icon: const Icon(Icons.repeat_one),
                onPressed: ctl.toggleRepeat,
              ),
              IconButton(
                tooltip: context.tr('Ayat sebelumnya', 'Previous verse'),
                icon: const Icon(MoeslimIcons.sebelumnya, size: 32),
                onPressed: rec == null ? null : () => ctl.skip(-1),
              ),
              IconButton.filled(
                key: const Key('murottal-play'),
                iconSize: 40,
                style: IconButton.styleFrom(
                  minimumSize: const Size(72, 72),
                  fixedSize: const Size(72, 72),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                ),
                tooltip: player.playing ? context.tr('Jeda', 'Pause') : context.tr('Putar', 'Play'),
                icon: Transform.translate(
                  offset: Offset(player.playing ? 0 : 2.0, 0),
                  child: Icon(player.playing ? MoeslimIcons.pause : MoeslimIcons.play),
                ),
                onPressed: rec == null ? null : () => ctl.toggleSurahPlayback(surah.number),
              ),
              IconButton(
                tooltip: context.tr('Ayat berikutnya', 'Next verse'),
                icon: const Icon(MoeslimIcons.selanjutnya, size: 32),
                onPressed: rec == null ? null : () => ctl.skip(1),
              ),
              IconButton(
                tooltip: context.tr('Berhenti', 'Stop'),
                icon: const Icon(Icons.stop),
                onPressed: ctl.stop,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  key: const Key('murottal-speed'),
                  top: '${player.speed}x',
                  label: context.tr('Kecepatan', 'Speed'),
                  onTap: () => ctl.setSpeed(_speeds[(_speeds.indexOf(player.speed) + 1) % _speeds.length]),
                ),
              ),
              Expanded(
                child: _Chip(
                  icon: MoeslimIcons.profil,
                  label: context.tr('Qari', 'Reciter'),
                  onTap: () => showAudioSheet(context, surah),
                ),
              ),
              Expanded(
                child: _Chip(
                  icon: MoeslimIcons.unduh,
                  label: context.tr('Unduh Offline', 'Offline Download'),
                  onTap: () => showAudioSheet(context, surah),
                ),
              ),
            ],
          ),
          if (rec == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.tr('Belum ada rekaman untuk surah ini.', 'No recording available for this surah.'),
                key: const Key('no-audio'),
              ),
            ),
          SectionHeader(context.tr('Daftar Putar', 'Playlist')),
          for (final s in surahs.take(20))
            ListTile(
              key: Key('playlist-${s.number}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: OctagonNumber(s.number, size: 32),
              title: Text(
                s.name,
                style: TextStyle(fontWeight: s.number == surahNo ? FontWeight.w700 : FontWeight.w500),
              ),
              subtitle: Text(context.tr('${s.ayahCount} ayat', '${s.ayahCount} verses')),
              trailing: Icon(
                s.number == surahNo && player.playing ? MoeslimIcons.suara : MoeslimIcons.play,
                color: scheme.primary,
              ),
              onTap: () => _playSurah(s.number),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData? icon;
  final String? top;
  final String label;
  final VoidCallback onTap;
  const _Chip({super.key, this.icon, this.top, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(4),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            if (top != null)
              Text(top!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))
            else
              Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}
