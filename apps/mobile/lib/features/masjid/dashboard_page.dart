import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/format.dart';
import '../../ui/components.dart';
import 'account_page.dart';
import 'agenda_page.dart';
import 'finance_pages.dart';
import 'mosque_providers.dart';
import 'staff_page.dart';

/// Beranda Moeslim Mosque: banner masjid, ringkasan 2×2, akses cepat, peringatan, aktivitas terkini.
class MosqueHomeTab extends ConsumerWidget {
  final MosqueCtx ctx;
  final AsyncValue<Map<String, dynamic>> dash;
  final ValueChanged<String> onOpenTab;
  const MosqueHomeTab({super.key, required this.ctx, required this.dash, required this.onOpenTab});

  static const warningText = {
    'storage_warning': 'Penyimpanan lampiran sudah 80%.',
    'storage_critical': 'Penyimpanan lampiran sudah 95%.',
    'storage_full': 'Penyimpanan penuh: unggah lampiran dihentikan, pencatatan kas tetap berjalan.',
    'transactions_soft_limit': 'Transaksi bulan ini melewati batas wajar 10.000.',
    'content_near_limit': 'Agenda & pengumuman aktif hampir 500. Arsipkan yang sudah selesai.',
    'subscription_grace': 'Masa langganan berakhir — dalam masa tenggang 7 hari.',
    'subscription_expired': 'Langganan berakhir. Data hanya dapat dilihat & diekspor.',
  };

  void _push(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider(ctx.id).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          MosqueBanner(
            key: const Key('mosque-banner'),
            overline: 'Masjid',
            title: ctx.name,
            subtitle: [
              if (ctx.city != null) ctx.city!,
              if (ctx.role.isNotEmpty) 'Peran: ${roleLabels[ctx.role] ?? ctx.role}',
            ].join(' • '),
          ),
          AsyncBody(
            value: dash,
            onRetry: () => ref.invalidate(dashboardProvider(ctx.id)),
            data: (d) => _content(context, ref, d),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, Map<String, dynamic> d) {
    final finance = d['finance'] as Map?;
    final warnings = (d['warnings'] as List? ?? const []).cast<String>();
    final displays = d['displays'] as Map? ?? const {};
    final usage = d['usage'] as Map?;
    final members = usage?['members'] as Map?;
    final upcoming = (d['upcoming_events'] as List? ?? const []).cast<Map>();
    final staff = (d['staff_today'] as List? ?? const []).cast<Map>();
    final net = finance == null ? 0 : (finance['month_in'] as num) - (finance['month_out'] as num);

    final quick = <(IconData, String, VoidCallback)>[
      if (ctx.can('finance.write'))
        (Icons.add_card_outlined, 'Catat Kas', () => _push(context, TransactionFormPage(mosqueId: ctx.id))),
      if (ctx.can('events.write'))
        (Icons.event_available_outlined, 'Buat Kegiatan', () => _push(context, EventFormPage(ctx: ctx))),
      if (ctx.can('members.view'))
        (Icons.groups_outlined, 'Kelola Pengurus', () => _push(context, MembersPage(ctx: ctx))),
      if (ctx.can('staff.view')) (Icons.badge_outlined, 'Kelola Petugas', () => onOpenTab('Petugas')),
      if (ctx.can('inventory.view'))
        (Icons.inventory_2_outlined, 'Inventaris', () => _push(context, InventoryPage(ctx: ctx))),
      if (ctx.can('display.view')) (Icons.tv_outlined, 'TV Display', () => _push(context, TvConfigPage(ctx: ctx))),
      if (ctx.can('events.view'))
        (Icons.campaign_outlined, 'Konten TV', () => _push(context, AnnouncementsPage(ctx: ctx))),
      if (ctx.can('finance.view')) (Icons.bar_chart, 'Laporan', () => _push(context, ReportPage(ctx: ctx))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        for (final w in warnings)
          Card(
            key: Key('warning-$w'),
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.onErrorContainer),
              title: Text(warningText[w] ?? w, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
            ),
          ),
        const SectionHeader('Ringkasan Masjid'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.75,
          children: [
            if (finance != null)
              StatTile(
                key: const Key('stat-kas'),
                icon: Icons.account_balance_wallet_outlined,
                label: 'Kas Masjid',
                value: rupiah(finance['balance'] as num),
                caption: '${net >= 0 ? '+' : '−'}${rupiah(net.abs())} bln ini',
                captionColor: net >= 0 ? MosqueColors.income : MosqueColors.expense,
                onTap: () => onOpenTab('Keuangan'),
              ),
            StatTile(
              key: const Key('stat-kegiatan'),
              icon: Icons.event_note_outlined,
              label: 'Kegiatan',
              value: '${upcoming.length}',
              caption: 'akan datang',
              onTap: ctx.can('events.view') ? () => onOpenTab('Kegiatan') : null,
            ),
            StatTile(
              key: const Key('stat-pengurus'),
              icon: Icons.groups_outlined,
              label: 'Pengurus',
              value: members == null ? '-' : '${members['used']}/${members['limit']}',
              caption: 'akun aktif',
              onTap: ctx.can('members.view') ? () => _push(context, MembersPage(ctx: ctx)) : null,
            ),
            StatTile(
              key: const Key('stat-tv'),
              icon: Icons.tv_outlined,
              label: 'TV Display',
              value: '${displays['online'] ?? 0}/${displays['active'] ?? 0}',
              caption: 'online',
              onTap: ctx.can('display.view') ? () => _push(context, TvConfigPage(ctx: ctx)) : null,
            ),
          ],
        ),
        if (quick.isNotEmpty) ...[
          const SectionHeader('Akses Cepat'),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: .9,
            children: [for (final q in quick) MenuTile(icon: q.$1, label: q.$2, onTap: q.$3)],
          ),
        ],
        const SectionHeader('Petugas Hari Ini'),
        Card(
          margin: EdgeInsets.zero,
          child: staff.isEmpty
              ? const ListTile(
                  leading: Icon(Icons.event_busy_outlined),
                  title: Text('Belum ada jadwal petugas hari ini'),
                )
              : Column(
                  children: [
                    for (final s in staff)
                      ListTile(
                        dense: true,
                        leading: Icon(dutyIcon(s['duty_type'] as String?), color: BrandColors.emerald),
                        title: Text('${s['name']}'),
                        subtitle: Text(dutyLabel(s['duty_type'] as String?, s['prayer'] as String?)),
                      ),
                  ],
                ),
        ),
        SectionHeader(
          'Agenda Terdekat',
          actionLabel: ctx.can('events.view') ? 'Lihat Semua' : null,
          onAction: () => onOpenTab('Kegiatan'),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: upcoming.isEmpty
              ? const ListTile(leading: Icon(Icons.event_outlined), title: Text('Belum ada agenda mendatang'))
              : Column(
                  children: [
                    for (final e in upcoming)
                      ListTile(
                        leading: DateBadge(DateTime.parse(e['starts_at'] as String).toLocal()),
                        title: Text('${e['title']}'),
                        subtitle: Text(
                          '${hhmm(DateTime.parse(e['starts_at'] as String).toLocal())} • ${categoryLabel(e['category'] as String?)}',
                        ),
                      ),
                  ],
                ),
        ),
        if (ctx.can('audit.view')) _RecentActivity(ctx: ctx),
      ],
    );
  }
}

class _RecentActivity extends ConsumerWidget {
  final MosqueCtx ctx;
  const _RecentActivity({required this.ctx});

  static IconData _icon(String action) => switch (action.split('.').first) {
    'finance' => Icons.receipt_long_outlined,
    'event' || 'announcement' => Icons.event_note_outlined,
    'staff' => Icons.badge_outlined,
    'inventory' => Icons.inventory_2_outlined,
    'member' || 'invitation' => Icons.group_add_outlined,
    'display' => Icons.tv_outlined,
    _ => Icons.history,
  };

  static String _label(String action) =>
      const {
        'finance.transaction_created': 'Transaksi kas dicatat',
        'finance.transaction_reversed': 'Transaksi dibatalkan',
        'event.created': 'Kegiatan ditambahkan',
        'event.updated': 'Kegiatan diperbarui',
        'event.archived': 'Kegiatan diarsipkan',
        'announcement.created': 'Pengumuman dibuat',
        'staff.assigned': 'Petugas dijadwalkan',
        'inventory.created': 'Inventaris ditambahkan',
        'inventory.maintained': 'Perawatan inventaris dicatat',
        'member.invited': 'Pengurus diundang',
        'member.joined': 'Pengurus baru bergabung',
        'member.deactivated': 'Pengurus dinonaktifkan',
        'member.reactivated': 'Pengurus diaktifkan kembali',
        'event.display_toggled': 'Tayangan agenda di TV diubah',
        'announcement.display_toggled': 'Tayangan pengumuman di TV diubah',
        'staff.updated': 'Jadwal petugas diperbarui',
        'inventory.updated': 'Inventaris diperbarui',
        'member.role_changed': 'Peran pengurus diubah',
        'display.paired': 'TV Display terhubung',
        'display.revoked': 'TV Display dicabut',
      }[action] ??
      action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(auditLogsProvider(ctx.id));
    final items = logs.value?.take(5).toList() ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Aktivitas Terkini'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final l in items)
                ListTile(
                  dense: true,
                  leading: Icon(_icon(l['action'] as String), color: BrandColors.emerald),
                  title: Text(_label(l['action'] as String)),
                  subtitle: Text(shortDate(DateTime.parse(l['created_at'] as String).toLocal())),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
