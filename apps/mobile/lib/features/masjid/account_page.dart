import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'announcements_page.dart';
import 'finance_pages.dart';
import 'inventory_page.dart';
import 'members_page.dart';
import 'mosque_providers.dart';
import 'session.dart';
import 'tv_config_page.dart';

export 'announcements_page.dart';
export 'inventory_page.dart';
export 'members_page.dart';
export 'tv_config_page.dart';

const subscriptionStates = {
  'trialing': ('Uji coba', MosqueColors.info),
  'active': ('Aktif', MosqueColors.income),
  'grace': ('Masa tenggang', MosqueColors.warning),
  'expired': ('Berakhir', MosqueColors.expense),
};

/// Tab Akun: profil pengguna & masjid, langganan + pemakaian kuota, menu pengelolaan, keluar.
class MosqueAccountTab extends ConsumerWidget {
  final MosqueCtx ctx;
  const MosqueAccountTab({super.key, required this.ctx});

  void _push(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value?.user ?? const {};
    final dash = ref.watch(dashboardProvider(ctx.id)).value;
    final sub = dash?['subscription'] as Map?;
    final usage = dash?['usage'] as Map?;
    final state = subscriptionStates[sub?['state']];
    final trialing = sub?['state'] == 'trialing';
    final endsRaw = trialing ? sub!['trial_ends_at'] : (sub?['grace_ends_at'] ?? sub?['current_period_ends_at']);
    final ends = endsRaw == null ? null : DateTime.tryParse('$endsRaw')?.toLocal();

    final menu = <(Key, IconData, String, String, Widget)>[
      if (ctx.can('members.view'))
        (
          const Key('menu-members'),
          Icons.groups_outlined,
          'Pengurus & Role',
          'Maks. 5 akun pengurus',
          MembersPage(ctx: ctx),
        ),
      if (ctx.can('inventory.view'))
        (
          const Key('menu-inventory'),
          Icons.inventory_2_outlined,
          'Inventaris Masjid',
          'Barang, kondisi, perawatan',
          InventoryPage(ctx: ctx),
        ),
      if (ctx.can('display.view'))
        (const Key('menu-tv'), Icons.tv_outlined, 'Konfigurasi TV Display', 'Hingga 5 layar', TvConfigPage(ctx: ctx)),
      if (ctx.can('events.view'))
        (
          const Key('menu-announcements'),
          Icons.campaign_outlined,
          'Konten & Pengumuman',
          'Atur tayangan di TV',
          AnnouncementsPage(ctx: ctx),
        ),
      if (ctx.can('finance.view'))
        (const Key('menu-report'), Icons.bar_chart, 'Laporan Keuangan', 'Grafik & ekspor CSV', ReportPage(ctx: ctx)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: BrandColors.emerald,
              foregroundColor: Colors.white,
              child: Icon(Icons.person),
            ),
            title: Text('${user['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${roleLabels[ctx.role] ?? ctx.role} • ${ctx.name}'),
          ),
        ),
        const SectionHeader('Langganan Moeslim Mosque'),
        Card(
          key: const Key('subscription-card'),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined, color: BrandColors.goldText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${rupiah(sub?['price_idr'] as num? ?? 59000)} / bulan per masjid',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (state != null) StatusBadge(state.$1, color: state.$2),
                  ],
                ),
                if (ends != null) ...[
                  const SizedBox(height: 4),
                  Text('${sub?['state'] == 'trialing' ? 'Uji coba berakhir' : 'Berlaku hingga'} ${longDate(ends)}'),
                ],
                if (usage != null) ...[
                  const SizedBox(height: 12),
                  _UsageBar('Pengurus aktif', usage['members'] as Map),
                  _UsageBar('TV Display', usage['displays'] as Map),
                  _UsageBar('Penyimpanan lampiran', usage['storage'] as Map, bytes: true),
                  _UsageBar('Agenda & pengumuman aktif', usage['active_content'] as Map),
                ],
                const SizedBox(height: 4),
                const Text(
                  'Langganan hanya untuk fitur Mosque. Moeslim Personal tetap gratis.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('Kelola Masjid'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final m in menu)
                ListTile(
                  key: m.$1,
                  leading: Icon(m.$2, color: BrandColors.emerald),
                  title: Text(m.$3),
                  subtitle: Text(m.$4),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _push(context, m.$5),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('mosque-logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: MosqueColors.expense,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () => ref.read(sessionProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Keluar dari Moeslim Mosque'),
        ),
      ],
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final Map usage;
  final bool bytes;
  const _UsageBar(this.label, this.usage, {this.bytes = false});

  static String _size(num b) =>
      b >= 1 << 30 ? '${(b / (1 << 30)).toStringAsFixed(1)} GB' : '${(b / (1 << 20)).toStringAsFixed(0)} MB';

  @override
  Widget build(BuildContext context) {
    final used = usage['used'] as num? ?? 0;
    final limit = usage['limit'] as num? ?? 1;
    final ratio = (used / limit).clamp(0.0, 1.0).toDouble();
    final color = ratio >= .95 ? MosqueColors.expense : (ratio >= .8 ? MosqueColors.warning : BrandColors.emerald);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
              Text(
                bytes ? '${_size(used)} / ${_size(limit)}' : '$used / $limit',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: color,
              backgroundColor: color.withValues(alpha: .15),
            ),
          ),
        ],
      ),
    );
  }
}
