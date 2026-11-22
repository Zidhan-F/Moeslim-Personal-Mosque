import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';

class ManasikPage extends ConsumerStatefulWidget {
  const ManasikPage({super.key});

  @override
  ConsumerState<ManasikPage> createState() => _ManasikPageState();
}

class _ManasikPageState extends ConsumerState<ManasikPage> {
  int _tab = 0;
  ManasikCounterState _state = const ManasikCounterState();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ref.read(manasikRepoProvider).load();
    if (mounted) {
      setState(() {
        _state = s;
        _loading = false;
      });
    }
  }

  Future<void> _save(ManasikCounterState next) async {
    await ref.read(manasikRepoProvider).save(next);
    if (mounted) setState(() => _state = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manasik Haji & Umrah'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PillTabs(
              labels: const ['Urutan Manasik', 'Counter Thawaf & Sa\'i', 'Checklist Safar'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : switch (_tab) {
                    0 => _buildStepsTab(context),
                    1 => _buildCountersTab(context),
                    _ => _buildChecklistTab(context),
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: manasikUmrahHajiSteps.length,
      itemBuilder: (context, index) {
        final s = manasikUmrahHajiSteps[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    OctagonNumber(s.order),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text('${s.ruling} · ${s.location}', style: t.bodySmall?.copyWith(color: scheme.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(s.description, style: t.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  s.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: quranTextStyle(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(s.latin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text('Artinya: "${s.translation}"', style: t.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountersTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '1. Penghitung Thawaf (7 Putaran)',
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reset putaran Thawaf',
                      onPressed: () => _save(_state.copyWith(thawafLap: 0)),
                      icon: const Icon(MoeslimIcons.ulang),
                    ),
                  ],
                ),
                Text(
                  'Putaran Selesai: ${_state.thawafLap} / 7',
                  key: const Key('manasik-thawaf-count'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _state.thawafLap / 7.0, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 10),
                Text(
                  'Doa Antara Rukun Yamani & Hajar Aswad:\n'
                  'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n'
                  '"Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adzaban-nar."',
                  style: t.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('manasik-thawaf-tap'),
                  onPressed: _state.thawafLap >= 7
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _save(_state.copyWith(thawafLap: _state.thawafLap + 1));
                        },
                  icon: Icon(_state.thawafLap >= 7 ? MoeslimIcons.berhasil : MoeslimIcons.tasbih),
                  label: Text(_state.thawafLap >= 7 ? 'Thawaf 7 Putaran Selesai' : 'Tambah 1 Putaran Thawaf'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '2. Penghitung Sa\'i Shafa–Marwah (7 Lintasan)',
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reset lintasan Sa\'i',
                      onPressed: () => _save(_state.copyWith(saiLap: 0)),
                      icon: const Icon(MoeslimIcons.ulang),
                    ),
                  ],
                ),
                Text(
                  'Lintasan Selesai: ${_state.saiLap} / 7',
                  key: const Key('manasik-sai-count'),
                  style: t.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(_state.saiRouteDirection, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _state.saiLap / 7.0, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('manasik-sai-tap'),
                  onPressed: _state.saiLap >= 7
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _save(_state.copyWith(saiLap: _state.saiLap + 1));
                        },
                  icon: Icon(_state.saiLap >= 7 ? MoeslimIcons.berhasil : MoeslimIcons.tasbih),
                  label: Text(_state.saiLap >= 7 ? 'Sa\'i 7 Lintasan Selesai' : 'Tambah 1 Lintasan Sa\'i'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistTab(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const SectionHeader('Checklist Persiapan Safar Haji & Umrah'),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < manasikPackingChecklist.length; i++)
                CheckboxListTile(
                  key: Key('manasik-pack-$i'),
                  title: Text(manasikPackingChecklist[i]),
                  value: _state.checkedPackingIndexes.contains(i),
                  onChanged: (v) {
                    final next = Set<int>.from(_state.checkedPackingIndexes);
                    if (v == true) {
                      next.add(i);
                    } else {
                      next.remove(i);
                    }
                    _save(_state.copyWith(checkedPackingIndexes: next));
                  },
                ),
            ],
          ),
        ),
        const SectionHeader('Larangan Selama Berihram'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in ihramProhibitions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $item', style: t.bodyMedium),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
