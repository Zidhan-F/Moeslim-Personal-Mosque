import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
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
    'subscription_grace': 'Masa langganan berakhir (dalam masa tenggang 7 hari).',
    'subscription_expired': 'Langganan berakhir. Data hanya dapat dilihat & diekspor.',
  };

  static const warningTextEn = {
    'storage_warning': 'Attachment storage has reached 80%.',
    'storage_critical': 'Attachment storage has reached 95%.',
    'storage_full': 'Storage full: attachment uploads are paused, cash recording remains active.',
    'transactions_soft_limit': 'Transactions this month exceeded the usual 10,000 limit.',
    'content_near_limit': 'Active events & announcements are nearing 500. Archive finished items.',
    'subscription_grace': 'Subscription ended (7-day grace period active).',
    'subscription_expired': 'Subscription expired. Data is view-only and exportable.',
  };

  static String warningMessage(String code, AppLanguage lang) =>
      (lang == AppLanguage.en ? warningTextEn[code] : warningText[code]) ?? code;

  void _push(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) => mosqueScoped(context, (context) {
    final lang = context.lang;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider(ctx.id).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          MosqueBanner(
            key: const Key('mosque-banner'),
            overline: context.tr('Masjid', 'Mosque'),
            title: ctx.name,
            subtitle: [
              if (ctx.city != null) ctx.city!,
              if (ctx.role.isNotEmpty)
                context.tr('Peran: ${roleLabel(ctx.role, lang: lang)}', 'Role: ${roleLabel(ctx.role, lang: lang)}'),
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
  });

  Widget _content(BuildContext context, WidgetRef ref, Map<String, dynamic> d) {
    final lang = context.lang;
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
        (
          MoeslimIcons.keuangan,
          context.tr('Catat Kas', 'Record Cash'),
          () => _push(context, TransactionFormPage(mosqueId: ctx.id)),
        ),
      if (ctx.can('events.write'))
        (
          MoeslimIcons.kegiatan,
          context.tr('Buat Kegiatan', 'Add Event'),
          () => _push(context, EventFormPage(ctx: ctx)),
        ),
      if (ctx.can('members.view'))
        (MoeslimIcons.jamaah, context.tr('Kelola Pengurus', 'Committee'), () => _push(context, MembersPage(ctx: ctx))),
      if (ctx.can('staff.view'))
        (MoeslimIcons.petugas, context.tr('Kelola Petugas', 'Duty Roster'), () => onOpenTab('Petugas')),
      if (ctx.can('inventory.view'))
        (MoeslimIcons.inventaris, context.tr('Inventaris', 'Inventory'), () => _push(context, InventoryPage(ctx: ctx))),
      if (ctx.can('display.view')) (MoeslimIcons.layarTv, 'TV Display', () => _push(context, TvConfigPage(ctx: ctx))),
      if (ctx.can('events.view'))
        (
          MoeslimIcons.pengumuman,
          context.tr('Konten TV', 'TV Content'),
          () => _push(context, AnnouncementsPage(ctx: ctx)),
        ),
      if (ctx.can('finance.view'))
        (MoeslimIcons.grafikBatang, context.tr('Laporan', 'Reports'), () => _push(context, ReportPage(ctx: ctx))),
      if (ctx.can('zakat.view')) (MoeslimIcons.saldo, 'Zakat', () => _push(context, ZakatPage(ctx: ctx))),
      if (ctx.can('qurban.view'))
        (Icons.qr_code_2_rounded, context.tr('Kurban & QR', 'Qurban & QR'), () => _push(context, QurbanPage(ctx: ctx))),
      (MoeslimIcons.web, context.tr('Profil Web', 'Web Profile'), () => _push(context, MosqueMicrositePage(ctx: ctx))),
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
              leading: Icon(MoeslimIcons.peringatan, color: Theme.of(context).colorScheme.onErrorContainer),
              title: Text(
                warningMessage(w, lang),
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ),
        SectionHeader(context.tr('Ringkasan Masjid', 'Mosque Summary')),
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
                icon: MoeslimIcons.keuangan,
                label: context.tr('Kas Masjid', 'Mosque Cash'),
                value: rupiah(finance['balance'] as num),
                caption: context.tr(
                  '${net >= 0 ? '+' : '−'}${rupiah(net.abs())} bln ini',
                  '${net >= 0 ? '+' : '−'}${rupiah(net.abs())} this mo',
                ),
                captionColor: net >= 0 ? MosqueColors.income : MosqueColors.expense,
                onTap: () => onOpenTab('Keuangan'),
              ),
            StatTile(
              key: const Key('stat-kegiatan'),
              icon: MoeslimIcons.kegiatan,
              label: context.tr('Kegiatan', 'Events'),
              value: '${upcoming.length}',
              caption: context.tr('akan datang', 'upcoming'),
              onTap: ctx.can('events.view') ? () => onOpenTab('Kegiatan') : null,
            ),
            StatTile(
              key: const Key('stat-pengurus'),
              icon: MoeslimIcons.jamaah,
              label: context.tr('Pengurus', 'Committee'),
              value: members == null ? '-' : '${members['used']}/${members['limit']}',
              caption: context.tr('akun aktif', 'active accounts'),
              onTap: ctx.can('members.view') ? () => _push(context, MembersPage(ctx: ctx)) : null,
            ),
            StatTile(
              key: const Key('stat-tv'),
              icon: MoeslimIcons.layarTv,
              label: 'TV Display',
              value: '${displays['online'] ?? 0}/${displays['active'] ?? 0}',
              caption: 'online',
              onTap: ctx.can('display.view') ? () => _push(context, TvConfigPage(ctx: ctx)) : null,
            ),
          ],
        ),
        if (quick.isNotEmpty) ...[
          SectionHeader(context.tr('Akses Cepat', 'Quick Actions')),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 112 * MediaQuery.textScalerOf(context).scale(1),
            ),
            children: [
              for (final q in quick)
                MenuTile(
                  icon: q.$1,
                  art: q.$1 == MoeslimIcons.saldo
                      ? const SoftArt(SoftAsset.zakat, width: 40, height: 40, thumbnail: true)
                      : q.$1 == Icons.qr_code_2_rounded
                      ? const SoftArt(SoftAsset.qurban, width: 40, height: 40, thumbnail: true)
                      : null,
                  label: q.$2,
                  onTap: q.$3,
                ),
            ],
          ),
        ],
        SectionHeader(context.tr('Petugas Hari Ini', "Today's Duty Roster")),
        Card(
          margin: EdgeInsets.zero,
          child: staff.isEmpty
              ? ListTile(
                  leading: const Icon(MoeslimIcons.kalender),
                  title: Text(context.tr('Belum ada jadwal petugas hari ini', 'No duty roster scheduled for today')),
                )
              : Column(
                  children: [
                    for (final s in staff)
                      ListTile(
                        dense: true,
                        leading: Icon(dutyIcon(s['duty_type'] as String?), color: BrandColors.emerald),
                        title: Text('${s['name']}'),
                        subtitle: Text(dutyLabel(s['duty_type'] as String?, s['prayer'] as String?, lang: lang)),
                      ),
                  ],
                ),
        ),
        SectionHeader(
          context.tr('Agenda Terdekat', 'Upcoming Events'),
          actionLabel: ctx.can('events.view') ? context.tr('Lihat Semua', 'View All') : null,
          onAction: () => onOpenTab('Kegiatan'),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: upcoming.isEmpty
              ? ListTile(
                  leading: const Icon(MoeslimIcons.kalender),
                  title: Text(context.tr('Belum ada agenda mendatang', 'No upcoming events')),
                )
              : Column(
                  children: [
                    for (final e in upcoming)
                      ListTile(
                        leading: DateBadge(DateTime.parse(e['starts_at'] as String).toLocal()),
                        title: Text('${e['title']}'),
                        subtitle: Text(
                          '${hhmm(DateTime.parse(e['starts_at'] as String).toLocal())} • ${categoryLabel(e['category'] as String?, lang: lang)}',
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
    'finance' => MoeslimIcons.laporan,
    'event' || 'announcement' => MoeslimIcons.kegiatan,
    'staff' => MoeslimIcons.petugas,
    'inventory' => MoeslimIcons.inventaris,
    'member' || 'invitation' => MoeslimIcons.daftarAkun,
    'display' => MoeslimIcons.layarTv,
    _ => MoeslimIcons.histori,
  };

  static const _labelsId = {
    'finance.transaction_created': 'Transaksi kas dicatat',
    'finance.transaction_reversed': 'Transaksi dibatalkan',
    'finance.donation_box_counted': 'Kotak amal dihitung',
    'zakat.collection_created': 'Penerimaan zakat dicatat',
    'zakat.mustahik_distributed': 'Zakat disalurkan ke mustahik',
    'qurban.animal_created': 'Hewan kurban didaftarkan',
    'qurban.participant_created': 'Shohibul qurban ditambahkan',
    'coupon.issued': 'Kupon QR diterbitkan',
    'coupon.redeemed': 'Kupon QR ditukarkan',
    'display.override_set': 'Siaran darurat TV diaktifkan',
    'display.qris_uploaded': 'QRIS TV Display diperbarui',
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
  };

  static const _labelsEn = {
    'finance.transaction_created': 'Cash transaction recorded',
    'finance.transaction_reversed': 'Transaction reversed',
    'finance.donation_box_counted': 'Donation box counted',
    'zakat.collection_created': 'Zakat collection recorded',
    'zakat.mustahik_distributed': 'Zakat distributed to recipient',
    'qurban.animal_created': 'Qurban animal registered',
    'qurban.participant_created': 'Qurban participant added',
    'coupon.issued': 'QR coupons issued',
    'coupon.redeemed': 'QR coupon redeemed',
    'display.override_set': 'TV emergency broadcast activated',
    'display.qris_uploaded': 'TV Display QRIS updated',
    'event.created': 'Event added',
    'event.updated': 'Event updated',
    'event.archived': 'Event archived',
    'announcement.created': 'Announcement created',
    'staff.assigned': 'Duty roster assigned',
    'inventory.created': 'Inventory item added',
    'inventory.maintained': 'Inventory maintenance recorded',
    'member.invited': 'Committee member invited',
    'member.joined': 'New committee member joined',
    'member.deactivated': 'Committee member deactivated',
    'member.reactivated': 'Committee member reactivated',
    'event.display_toggled': 'Event TV display toggled',
    'announcement.display_toggled': 'Announcement TV display toggled',
    'staff.updated': 'Duty roster updated',
    'inventory.updated': 'Inventory item updated',
    'member.role_changed': 'Committee role updated',
    'display.paired': 'TV Display paired',
    'display.revoked': 'TV Display revoked',
  };

  static String _label(String action, AppLanguage lang) =>
      (lang == AppLanguage.en ? _labelsEn[action] : _labelsId[action]) ?? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
    final logs = ref.watch(auditLogsProvider(ctx.id));
    final items = logs.value?.take(5).toList() ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.tr('Aktivitas Terkini', 'Recent Activity')),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final l in items)
                ListTile(
                  dense: true,
                  leading: Icon(_icon(l['action'] as String), color: BrandColors.emerald),
                  title: Text(_label(l['action'] as String, lang)),
                  subtitle: Text(context.shortDateText(DateTime.parse(l['created_at'] as String).toLocal())),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
