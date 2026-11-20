import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import 'masjid_api.dart';
import 'session.dart';
import 'transactions_page.dart';

final dashboardProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(masjidApiProvider).dashboard(id),
);
final eventsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).events(id),
);

class MasjidDashboardPage extends ConsumerStatefulWidget {
  const MasjidDashboardPage({super.key});

  @override
  ConsumerState<MasjidDashboardPage> createState() => _MasjidDashboardPageState();
}

class _MasjidDashboardPageState extends ConsumerState<MasjidDashboardPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final mosque = session.activeMosque!;
    final id = mosque['id'] as String;
    final dash = ref.watch(dashboardProvider(id));
    final perms = (dash.value?['permissions'] as List?)?.cast<String>() ?? const [];

    final tabs = <(String, IconData, Widget)>[
      ('Ringkasan', Icons.dashboard, _Summary(dash: dash, id: id)),
      if (perms.contains('finance.view'))
        (
          'Kas',
          Icons.account_balance_wallet,
          TransactionsPage(mosqueId: id, canWrite: perms.contains('finance.write')),
        ),
      ('Agenda', Icons.event, _Events(id: id, canWrite: perms.contains('events.write'))),
    ];
    final index = _tab.clamp(0, tabs.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(mosque['name'] as String),
        actions: [
          if (session.mosques.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz),
              onSelected: ref.read(sessionProvider.notifier).selectMosque,
              itemBuilder: (_) => [
                for (final m in session.mosques)
                  PopupMenuItem(value: m['id'] as String, child: Text(m['name'] as String)),
              ],
            ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
      ),
      body: tabs[index].$3,
      bottomNavigationBar: tabs.length < 2
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: [for (final t in tabs) NavigationDestination(icon: Icon(t.$2), label: t.$1)],
            ),
    );
  }
}

class _Summary extends ConsumerWidget {
  final AsyncValue<Map<String, dynamic>> dash;
  final String id;
  const _Summary({required this.dash, required this.id});

  static const _warningText = {
    'storage_warning': 'Penyimpanan lampiran sudah 80%.',
    'storage_critical': 'Penyimpanan lampiran sudah 95%.',
    'storage_full': 'Penyimpanan penuh: unggah lampiran dihentikan, pencatatan kas tetap berjalan.',
    'transactions_soft_limit': 'Transaksi bulan ini melewati batas wajar 10.000.',
    'content_near_limit': 'Agenda & pengumuman aktif hampir 500. Arsipkan yang sudah selesai.',
    'subscription_grace': 'Masa langganan berakhir — dalam masa tenggang 7 hari.',
    'subscription_expired': 'Langganan berakhir. Data hanya dapat dilihat & diekspor.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider(id).future),
      child: dash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          children: [Padding(padding: const EdgeInsets.all(24), child: Text('$e'))],
        ),
        data: (d) {
          final finance = d['finance'] as Map?;
          final sub = d['subscription'] as Map;
          final warnings = (d['warnings'] as List).cast<String>();
          final displays = d['displays'] as Map;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final w in warnings)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(leading: const Icon(Icons.warning_amber), title: Text(_warningText[w] ?? w)),
                ),
              if (finance != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo kas'),
                        Text(
                          rupiah(finance['balance'] as num),
                          key: const Key('balance'),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bulan ini: masuk ${rupiah(finance['month_in'] as num)} • keluar ${rupiah(finance['month_out'] as num)}',
                        ),
                        const Divider(),
                        for (final f in (finance['funds'] as List).cast<Map>())
                          Row(
                            children: [
                              Expanded(child: Text(f['name'] as String)),
                              Text(rupiah(f['balance'] as num)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.tv),
                  title: Text('TV Display: ${displays['online']}/${displays['active']} online'),
                  subtitle: Text('Langganan: ${sub['state']}'),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    const ListTile(title: Text('Petugas hari ini')),
                    for (final s in (d['staff_today'] as List).cast<Map>())
                      ListTile(
                        dense: true,
                        title: Text('${s['name']}'),
                        subtitle: Text('${s['duty_type']} ${s['prayer'] ?? ''}'),
                      ),
                    if ((d['staff_today'] as List).isEmpty)
                      const ListTile(dense: true, title: Text('Belum ada jadwal')),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    const ListTile(title: Text('Kegiatan mendatang')),
                    for (final e in (d['upcoming_events'] as List).cast<Map>())
                      ListTile(
                        dense: true,
                        title: Text('${e['title']}'),
                        subtitle: Text(shortDate(DateTime.parse(e['starts_at'] as String).toLocal())),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Events extends ConsumerWidget {
  final String id;
  final bool canWrite;
  const _Events({required this.id, required this.canWrite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider(id));
    return Scaffold(
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Agenda'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _NewEventDialog(id: id),
              ),
            )
          : null,
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada agenda aktif'))
            : ListView(
                children: [
                  for (final e in list)
                    ListTile(
                      leading: Icon(e['visibility'] == 'public' ? Icons.public : Icons.lock),
                      title: Text(e['title'] as String),
                      subtitle: Text(
                        '${shortDate(DateTime.parse(e['starts_at'] as String).toLocal())} • ${e['category']}'
                        '${e['speaker'] != null ? ' • ${e['speaker']}' : ''}',
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _NewEventDialog extends ConsumerStatefulWidget {
  final String id;
  const _NewEventDialog({required this.id});

  @override
  ConsumerState<_NewEventDialog> createState() => _NewEventDialogState();
}

class _NewEventDialogState extends ConsumerState<_NewEventDialog> {
  final _title = TextEditingController();
  final _speaker = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _category = 'kajian';
  bool _public = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agenda baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: _speaker,
              decoration: const InputDecoration(labelText: 'Narasumber (opsional)'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: [
                for (final c in const ['kajian', 'jumat', 'ramadan', 'sosial', 'pendidikan', 'lainnya'])
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(shortDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: _date,
                );
                if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Publik (jamaah & TV)'),
              value: _public,
              onChanged: (v) => setState(() => _public = v),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () async {
            try {
              await ref.read(masjidApiProvider).createEvent(widget.id, {
                'title': _title.text.trim(),
                'speaker': _speaker.text.trim().isEmpty ? null : _speaker.text.trim(),
                'category': _category,
                'starts_at': _date.toUtc().toIso8601String(),
                'visibility': _public ? 'public' : 'internal',
              });
              ref.invalidate(eventsProvider(widget.id));
              if (context.mounted) Navigator.pop(context);
            } on ApiException catch (e) {
              setState(() => _error = e.message);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
