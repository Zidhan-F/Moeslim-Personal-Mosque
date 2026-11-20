import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';

class TasbihPage extends ConsumerStatefulWidget {
  const TasbihPage({super.key});

  @override
  ConsumerState<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends ConsumerState<TasbihPage> {
  int _tab = 0;
  Dzikir _dzikir = dzikirList.first;
  int _count = 0;
  int _target = 33;
  Map<String, int> _all = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(tasbihRepoProvider);
    final c = await repo.count(_dzikir.id), t = await repo.target(_dzikir.id);
    final all = {for (final d in dzikirList) d.id: await repo.count(d.id)};
    if (mounted) {
      setState(() {
        _count = c;
        _target = t;
        _all = all;
      });
    }
  }

  Future<void> _tap() async {
    final c = await ref.read(tasbihRepoProvider).increment(_dzikir.id);
    c % _target == 0 ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
    setState(() {
      _count = c;
      _all[_dzikir.id] = c;
    });
  }

  Future<void> _minus() async {
    final c = await ref.read(tasbihRepoProvider).decrement(_dzikir.id);
    setState(() {
      _count = c;
      _all[_dzikir.id] = c;
    });
  }

  Future<void> _reset() async {
    await ref.read(tasbihRepoProvider).reset(_dzikir.id);
    setState(() {
      _count = 0;
      _all[_dzikir.id] = 0;
    });
  }

  Future<void> _editTarget() async {
    final v = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Target dzikir', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (final t in [33, 99, 100, 1000])
              ListTile(
                title: Text('$t kali'),
                trailing: t == _target ? const Icon(Icons.check_circle, color: BrandColors.emerald) : null,
                onTap: () => Navigator.pop(context, t),
              ),
          ],
        ),
      ),
    );
    if (v == null) return;
    await ref.read(tasbihRepoProvider).setTarget(_dzikir.id, v);
    setState(() => _target = v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final inRound = _count % _target;
    final shown = _count != 0 && inRound == 0 ? _target : inRound;

    return Scaffold(
      appBar: AppBar(title: const Text('Dzikir & Tasbih'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: PillTabs(
              labels: const ['Tasbih', 'Dzikir Harian'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _tab == 0
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Center(
                        child: SizedBox.square(
                          dimension: 230,
                          child: CustomPaint(
                            painter: _RingPainter(
                              progress: shown / _target,
                              track: scheme.primary.withValues(alpha: .12),
                              color: scheme.primary,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Target Dzikir', style: t.bodySmall),
                                  Text('$_target kali', style: t.labelLarge),
                                  Text(
                                    '$shown',
                                    key: const Key('tasbih-count'),
                                    style: t.displayMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text('/ $_target • putaran ${_count ~/ _target}', style: t.bodySmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _dzikir.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: quranTextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 8),
                      for (final d in dzikirList)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: d.id == _dzikir.id ? scheme.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.radio_button_checked,
                              color: scheme.primary.withValues(alpha: d.id == _dzikir.id ? 1 : .3),
                            ),
                            title: Text(d.latin, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(d.meaning),
                            trailing: d.id == _dzikir.id
                                ? Icon(Icons.check_circle, color: scheme.primary)
                                : const Icon(Icons.circle_outlined),
                            onTap: () {
                              setState(() => _dzikir = d);
                              _load();
                            },
                          ),
                        ),
                      TextButton.icon(
                        key: const Key('edit-target'),
                        onPressed: _editTarget,
                        icon: const Icon(Icons.add),
                        label: const Text('Ubah Target Dzikir'),
                      ),
                      const SizedBox(height: 80),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final d in dzikirList)
                        Card(
                          child: ListTile(
                            title: Text('${d.name} — ${d.latin}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.arabic, textDirection: TextDirection.rtl, style: quranTextStyle(fontSize: 22)),
                                LinearProgressIndicator(
                                  value: ((_all[d.id] ?? 0) / d.defaultTarget).clamp(0, 1).toDouble(),
                                ),
                              ],
                            ),
                            trailing: Text('${_all[d.id] ?? 0}', style: t.titleMedium),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _tab != 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.outlined(
                      tooltip: 'Reset',
                      iconSize: 28,
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt),
                    ),
                    GestureDetector(
                      key: const Key('tasbih-button'),
                      onTap: _tap,
                      child: Semantics(
                        button: true,
                        label: 'Tambah satu',
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: .35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+1',
                            style: TextStyle(color: scheme.onPrimary, fontSize: 30, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      key: const Key('tasbih-minus'),
                      tooltip: 'Kurangi',
                      iconSize: 28,
                      onPressed: _minus,
                      icon: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color color;
  _RingPainter({required this.progress, required this.track, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(10), 0, math.pi * 2, false, stroke..color = track);
    canvas.drawArc(rect.deflate(10), -math.pi / 2, math.pi * 2 * progress.clamp(0, 1), false, stroke..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
