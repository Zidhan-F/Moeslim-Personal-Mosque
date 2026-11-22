import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:shared_prayer/shared_prayer.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'announcements_page.dart';
import 'finance_pages.dart';
import 'inventory_page.dart';
import 'members_page.dart';
import 'microsite_page.dart';
import 'mosque_providers.dart';
import 'session.dart';
import 'tv_config_page.dart';
import 'zakat_qurban_page.dart';

export 'announcements_page.dart';
export 'inventory_page.dart';
export 'members_page.dart';
export 'microsite_page.dart';
export 'tv_config_page.dart';
export 'zakat_qurban_page.dart';

const subscriptionStates = {
  'trialing': ('Uji coba', MosqueColors.info),
  'active': ('Aktif', MosqueColors.income),
  'grace': ('Masa tenggang', MosqueColors.warning),
  'expired': ('Berakhir', MosqueColors.expense),
};

const subscriptionStatesEn = {
  'trialing': ('Trial', MosqueColors.info),
  'active': ('Active', MosqueColors.income),
  'grace': ('Grace period', MosqueColors.warning),
  'expired': ('Expired', MosqueColors.expense),
};

(String, Color)? subscriptionStateFor(String? state, AppLanguage lang) =>
    (lang == AppLanguage.en ? subscriptionStatesEn : subscriptionStates)[state];

/// Tab Akun: profil pengguna & masjid, langganan + pemakaian kuota, menu pengelolaan, keluar.
class MosqueAccountTab extends ConsumerWidget {
  final MosqueCtx ctx;
  const MosqueAccountTab({super.key, required this.ctx});

  void _push(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) => mosqueScoped(context, (context) {
    final lang = context.lang;
    final user = ref.watch(sessionProvider).value?.user ?? const {};
    final dash = ref.watch(dashboardProvider(ctx.id)).value;
    final sub = dash?['subscription'] as Map?;
    final usage = dash?['usage'] as Map?;
    final state = subscriptionStateFor(sub?['state'] as String?, lang);
    final trialing = sub?['state'] == 'trialing';
    final endsRaw = trialing ? sub!['trial_ends_at'] : (sub?['grace_ends_at'] ?? sub?['current_period_ends_at']);
    final ends = endsRaw == null ? null : DateTime.tryParse('$endsRaw')?.toLocal();

    final menu = <(Key, IconData, String, String, Widget)>[
      if (ctx.can('members.view'))
        (
          const Key('menu-members'),
          MoeslimIcons.jamaah,
          context.tr('Pengurus & Role', 'Committee & Roles'),
          context.tr('Maks. 5 akun pengurus', 'Up to 5 committee accounts'),
          MembersPage(ctx: ctx),
        ),
      if (ctx.can('inventory.view'))
        (
          const Key('menu-inventory'),
          MoeslimIcons.inventaris,
          context.tr('Inventaris Masjid', 'Mosque Inventory'),
          context.tr('Barang, kondisi, perawatan', 'Assets, condition, maintenance'),
          InventoryPage(ctx: ctx),
        ),
      if (ctx.can('display.view'))
        (
          const Key('menu-tv'),
          MoeslimIcons.layarTv,
          context.tr('Konfigurasi TV Display', 'TV Display Settings'),
          context.tr('Hingga 5 layar', 'Up to 5 screens'),
          TvConfigPage(ctx: ctx),
        ),
      if (ctx.can('events.view'))
        (
          const Key('menu-announcements'),
          MoeslimIcons.pengumuman,
          context.tr('Konten & Pengumuman', 'Content & Announcements'),
          context.tr('Atur tayangan di TV', 'Manage TV screen content'),
          AnnouncementsPage(ctx: ctx),
        ),
      (
        const Key('menu-microsite'),
        MoeslimIcons.web,
        context.tr('Microsite Profil Masjid', 'Mosque Profile Microsite'),
        context.tr('Tautan web publik & kartu QR', 'Public web link & QR card'),
        MosqueMicrositePage(ctx: ctx),
      ),
      if (ctx.can('zakat.view'))
        (
          const Key('menu-zakat'),
          MoeslimIcons.keuangan,
          'Zakat Fitrah & Maal',
          context.tr('Muzakki, beras/uang & mustahik', 'Donors, rice/cash & recipients'),
          ZakatPage(ctx: ctx),
        ),
      if (ctx.can('qurban.view'))
        (
          const Key('menu-qurban'),
          MoeslimIcons.kegiatan,
          context.tr('Kurban & Kupon QR', 'Qurban & QR Coupons'),
          context.tr('Patungan 1/7, sembelih & scan QR', '1/7 shares, slaughter & QR scan'),
          QurbanPage(ctx: ctx),
        ),
      if (ctx.can('finance.view'))
        (
          const Key('menu-report'),
          MoeslimIcons.grafikBatang,
          context.tr('Laporan Keuangan', 'Financial Reports'),
          context.tr('Grafik & ekspor CSV', 'Charts & CSV export'),
          ReportPage(ctx: ctx),
        ),
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
              child: Icon(MoeslimIcons.profil),
            ),
            title: Text('${user['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${roleLabel(ctx.role, lang: lang)} • ${ctx.name}'),
          ),
        ),
        SectionHeader(context.tr('Langganan Moeslim Mosque', 'Moeslim Mosque Subscription')),
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
                        context.tr(
                          '${rupiah(sub?['price_idr'] as num? ?? 59000)} / bulan per masjid',
                          '${rupiah(sub?['price_idr'] as num? ?? 59000)} / month per mosque',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (state != null) StatusBadge(state.$1, color: state.$2),
                  ],
                ),
                if (ends != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    context.tr(
                      '${trialing ? 'Uji coba berakhir' : 'Berlaku hingga'} ${context.longDateText(ends)}',
                      '${trialing ? 'Trial ends' : 'Valid until'} ${context.longDateText(ends)}',
                    ),
                  ),
                ],
                if (usage != null) ...[
                  const SizedBox(height: 12),
                  _UsageBar(context.tr('Pengurus aktif', 'Active committee'), usage['members'] as Map),
                  _UsageBar('TV Display', usage['displays'] as Map),
                  _UsageBar(context.tr('Penyimpanan lampiran', 'Attachment storage'), usage['storage'] as Map, bytes: true),
                  _UsageBar(
                    context.tr('Agenda & pengumuman aktif', 'Active events & announcements'),
                    usage['active_content'] as Map,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    'Langganan hanya untuk fitur Mosque. Moeslim Personal tetap gratis.',
                    'Subscription applies to Mosque features only. Moeslim Personal remains free.',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(context.tr('Kelola Masjid', 'Manage Mosque')),
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
          icon: const Icon(MoeslimIcons.logout),
          label: Text(context.tr('Keluar dari Moeslim Mosque', 'Sign Out of Moeslim Mosque')),
        ),
      ],
    );
  });
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
