import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';

class TasbihPage extends ConsumerStatefulWidget {
  const TasbihPage({super.key});

  @override
  ConsumerState<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends ConsumerState<TasbihPage> {
  Dzikir _dzikir = dzikirList.first;
  int _count = 0;
  int _target = 33;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(tasbihRepoProvider);
    final c = await repo.count(_dzikir.id), t = await repo.target(_dzikir.id);
    if (mounted) {
      setState(() {
        _count = c;
        _target = t;
      });
    }
  }

  Future<void> _tap() async {
    final c = await ref.read(tasbihRepoProvider).increment(_dzikir.id);
    if (c % _target == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    setState(() => _count = c);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              await ref.read(tasbihRepoProvider).reset(_dzikir.id);
              setState(() => _count = 0);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final d in dzikirList)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d.name),
                      selected: d.id == _dzikir.id,
                      onSelected: (_) {
                        setState(() => _dzikir = d);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Text(_dzikir.arabic, style: const TextStyle(fontSize: 32), textDirection: TextDirection.rtl),
          Text('${_dzikir.latin} — ${_dzikir.meaning}', textAlign: TextAlign.center),
          Expanded(
            child: Center(
              child: GestureDetector(
                key: const Key('tasbih-button'),
                onTap: _tap,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_count',
                        key: const Key('tasbih-count'),
                        style: TextStyle(fontSize: 64, color: scheme.onPrimary),
                      ),
                      Text('putaran ${_count ~/ _target} • target $_target', style: TextStyle(color: scheme.onPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 33, label: Text('33')),
                ButtonSegment(value: 99, label: Text('99')),
                ButtonSegment(value: 100, label: Text('100')),
              ],
              selected: {
                if ([33, 99, 100].contains(_target)) _target,
              },
              emptySelectionAllowed: true,
              onSelectionChanged: (v) async {
                if (v.isEmpty) return;
                await ref.read(tasbihRepoProvider).setTarget(_dzikir.id, v.first);
                setState(() => _target = v.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}
