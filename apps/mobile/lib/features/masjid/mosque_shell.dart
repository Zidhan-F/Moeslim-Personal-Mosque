import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'account_page.dart';
import 'agenda_page.dart';
import 'dashboard_page.dart';
import 'finance_pages.dart';
import 'mosque_providers.dart';
import 'session.dart';
import 'staff_page.dart';

/// Shell Moeslim Mosque: pengalih core di AppBar dan navigasi bawah sesuai izin peran.
class MasjidDashboardPage extends ConsumerStatefulWidget {
  const MasjidDashboardPage({super.key});

  @override
  ConsumerState<MasjidDashboardPage> createState() => _MasjidDashboardPageState();
}

class _MasjidDashboardPageState extends ConsumerState<MasjidDashboardPage> {
  int _tab = 0;

  void _goTo(String tabId, List<(String, String, IconData, IconData, Widget)> tabs) {
    final i = tabs.indexWhere((t) => t.$1 == tabId);
    if (i >= 0) setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final session = ref.watch(sessionProvider).value!;
    final mosque = session.activeMosque!;
    final id = mosque['id'] as String;
    final dash = ref.watch(dashboardProvider(id));
    final d = dash.value;
    final ctx = MosqueCtx(
      id: id,
      name: (d?['mosque'] as Map?)?['name'] as String? ?? mosque['name'] as String,
      city: ((d?['mosque'] as Map?)?['city'] ?? mosque['city']) as String?,
      slug: ((d?['mosque'] as Map?)?['slug'] ?? mosque['slug']) as String?,
      role: (d?['role'] ?? mosque['role'] ?? '') as String,
      permissions: {...?(d?['permissions'] as List?)?.cast<String>()},
    );

    late final List<(String, String, IconData, IconData, Widget)> tabs;
    tabs = [
      (
        'Beranda',
        context.tr('Beranda', 'Home'),
        MoeslimIcons.beranda,
        MoeslimIcons.beranda,
        MosqueHomeTab(ctx: ctx, dash: dash, onOpenTab: (l) => _goTo(l, tabs)),
      ),
      if (ctx.can('finance.view'))
        ('Keuangan', context.tr('Keuangan', 'Finance'), MoeslimIcons.keuangan, MoeslimIcons.keuangan, FinanceTab(ctx: ctx)),
      if (ctx.can('events.view'))
        (
          'Kegiatan',
          context.tr('Kegiatan', 'Events'),
          MoeslimIcons.kalender,
          MoeslimIcons.kalender,
          AgendaPage(ctx: ctx, embedded: true),
        ),
      if (ctx.can('staff.view'))
        (
          'Petugas',
          context.tr('Petugas', 'Roster'),
          MoeslimIcons.petugas,
          MoeslimIcons.petugas,
          StaffPage(ctx: ctx, embedded: true),
        ),
      ('Akun', context.tr('Akun', 'Account'), MoeslimIcons.profil, MoeslimIcons.profil, MosqueAccountTab(ctx: ctx)),
    ];
    final index = _tab.clamp(0, tabs.length - 1);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CoreSwitcher(
          current: AppCore.mosque,
          onSelected: (c) {
            if (c == AppCore.personal) Navigator.of(context).popUntil((r) => r.isFirst);
          },
        ),
        actions: [
          if (session.mosques.length > 1)
            PopupMenuButton<String>(
              tooltip: context.tr('Ganti masjid', 'Switch mosque'),
              icon: const Icon(MoeslimIcons.sinkronisasi),
              onSelected: ref.read(sessionProvider.notifier).selectMosque,
              itemBuilder: (_) => [
                for (final m in session.mosques)
                  PopupMenuItem(value: m['id'] as String, child: Text(m['name'] as String)),
              ],
            ),
        ],
      ),
      body: IndexedStack(index: index, children: [for (final t in tabs) t.$5]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          for (final t in tabs) NavigationDestination(icon: Icon(t.$3), selectedIcon: Icon(t.$4), label: t.$2),
        ],
      ),
    );
  });
}
