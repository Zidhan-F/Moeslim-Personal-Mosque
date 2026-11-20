import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../ui/components.dart';
import 'audio/audio_providers.dart';
import 'audio/naghom_player_bar.dart';

/// Halaman Murottal: dengarkan surah utuh dengan qari & irama pilihan, kecepatan, ulang, unduh, daftar putar.
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
      if (p.surah == null) ref.read(quranPlayerProvider.notifier).prepare(widget.initialSurah, prefer: murattalKey);
    });
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Future<void> _playSurah(int number) async {
    final ctl = ref.read(quranPlayerProvider.notifier);
    final current = ref.read(quranPlayerProvider).naghom;
    await ctl.prepare(number, prefer: current);
    await ctl.playFrom(1);
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(quranPlayerProvider);
    final ctl = ref.read(quranPlayerProvider.notifier);
    final manifest = ref.watch(audioManifestProvider).value ?? AudioManifest.empty;
    final surahNo = player.surah ?? widget.initialSurah;
    final surah = surahs[surahNo - 1];
    final option = manifest.optionsFor(surahNo).where((o) => o.key == player.naghom).firstOrNull;
    final rec = player.recitation;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ayahPos = player.current?.ayah ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Murottal Al-Qur\'an'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PatternBanner(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: BrandColors.cream,
                  child: Icon(Icons.record_voice_over, color: BrandColors.emerald, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option?.label ?? 'Qari\' / Murottal', style: const TextStyle(color: BrandColors.cream)),
                      Text(
                        rec?.qari ?? 'Belum ada rekaman',
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
              leading: const Icon(Icons.menu_book, color: BrandColors.emerald),
              title: Text(surah.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Surah ke-${surah.number} • ${surah.ayahCount} Ayat'),
              trailing: const Icon(Icons.graphic_eq),
              onTap: () => showIramaSheet(context, surah),
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
                Text(ayahPos == 0 ? 'Ayat –' : 'Ayat $ayahPos / ${surah.ayahCount}', style: t.bodySmall),
                const Spacer(),
                Text('${_fmt(player.position)} / ${_fmt(player.duration ?? Duration.zero)}', style: t.bodySmall),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Ulang ayat',
                isSelected: player.repeatAyah,
                icon: const Icon(Icons.repeat_one),
                onPressed: ctl.toggleRepeat,
              ),
              IconButton(
                tooltip: 'Ayat sebelumnya',
                icon: const Icon(Icons.skip_previous, size: 32),
                onPressed: rec == null ? null : () => ctl.skip(-1),
              ),
              IconButton.filled(
                key: const Key('murottal-play'),
                iconSize: 40,
                style: IconButton.styleFrom(minimumSize: const Size(72, 72)),
                tooltip: player.playing ? 'Jeda' : 'Putar',
                icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                onPressed: rec == null ? null : () => player.queue.isEmpty ? ctl.playFrom(1) : ctl.togglePause(),
              ),
              IconButton(
                tooltip: 'Ayat berikutnya',
                icon: const Icon(Icons.skip_next, size: 32),
                onPressed: rec == null ? null : () => ctl.skip(1),
              ),
              IconButton(tooltip: 'Berhenti', icon: const Icon(Icons.stop), onPressed: ctl.stop),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  key: const Key('murottal-speed'),
                  top: '${player.speed}x',
                  label: 'Kecepatan',
                  onTap: () => ctl.setSpeed(_speeds[(_speeds.indexOf(player.speed) + 1) % _speeds.length]),
                ),
              ),
              Expanded(
                child: _Chip(icon: Icons.graphic_eq, label: 'Irama', onTap: () => showIramaSheet(context, surah)),
              ),
              Expanded(
                child: _Chip(icon: Icons.download, label: 'Unduh Offline', onTap: () => showIramaSheet(context, surah)),
              ),
            ],
          ),
          if (rec != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${rec.attribution} • Lisensi: ${rec.license}',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ),
          if (rec == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Belum ada rekaman berlisensi untuk surah ini.', key: Key('no-audio')),
            ),
          const SectionHeader('Daftar Putar'),
          for (final s in surahs.take(20))
            ListTile(
              key: Key('playlist-${s.number}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: OctagonNumber(s.number, size: 32),
              title: Text(
                s.name,
                style: TextStyle(fontWeight: s.number == surahNo ? FontWeight.w700 : FontWeight.w500),
              ),
              subtitle: Text('${s.ayahCount} ayat'),
              trailing: Icon(
                s.number == surahNo && player.playing ? Icons.graphic_eq : Icons.play_circle_outline,
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
