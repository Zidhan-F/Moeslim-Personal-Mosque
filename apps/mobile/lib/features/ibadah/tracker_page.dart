import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/format.dart';
import '../../core/providers.dart';

class TrackerPage extends ConsumerStatefulWidget {
  const TrackerPage({super.key});

  @override
  ConsumerState<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends ConsumerState<TrackerPage> {
  late DateTime _day;
  Set<TrackerItem> _items = {};
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _day = DateTime(n.year, n.month, n.day);
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(trackerRepoProvider);
    final items = await repo.day(_day);
    final streak = await repo.prayerStreak(_day);
    if (mounted) {
      setState(() {
        _items = items;
        _streak = streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracker Ibadah')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() => _day = _day.subtract(const Duration(days: 1)));
                  _load();
                },
              ),
              Expanded(child: Text(longDate(_day), textAlign: TextAlign.center)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() => _day = _day.add(const Duration(days: 1)));
                  _load();
                },
              ),
            ],
          ),
          LinearProgressIndicator(value: _items.length / TrackerItem.values.length, minHeight: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Sholat lengkap beruntun: $_streak hari', key: const Key('streak')),
          ),
          for (final item in TrackerItem.values)
            CheckboxListTile(
              title: Text(item.label),
              value: _items.contains(item),
              onChanged: (_) async {
                await ref.read(trackerRepoProvider).toggle(_day, item);
                _load();
              },
            ),
        ],
      ),
    );
  }
}
