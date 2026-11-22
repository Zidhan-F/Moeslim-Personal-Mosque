import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/l10n.dart';
import '../../ui/components.dart';
import 'masjid_api.dart';
import 'mosque_providers.dart';
import 'session.dart';

const _roleColors = {
  'admin': MosqueColors.warning,
  'bendahara': Color(0xFF7A5C00),
  'pengurus': MosqueColors.income,
  'operator': MosqueColors.info,
};

String _initials(String? name) {
  final parts = (name ?? '?').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty && !p.endsWith('.')).toList();
  if (parts.isEmpty) return '?';
  return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
}

/// Pengurus & Role: maks. 5 akun aktif, undang, ubah peran, nonaktifkan/aktifkan; ringkasan hak akses.
class MembersPage extends ConsumerStatefulWidget {
  final MosqueCtx ctx;
  const MembersPage({super.key, required this.ctx});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  int _tab = 0;

  bool get _canManage => widget.ctx.can('members.manage');

  Future<void> _run(Future<void> Function() action, [String? ok]) async {
    try {
      await action();
      ref.invalidate(membersProvider(widget.ctx.id));
      ref.invalidate(dashboardProvider(widget.ctx.id));
      if (ok != null && mounted) showSnack(context, ok);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) => mosqueScoped(context, (context) {
    final data = ref.watch(membersProvider(widget.ctx.id));
    final d = data.value;
    final count = d == null ? '' : ' (${d['active_count']}/${d['limit']})';
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Pengurus & Role', 'Committee & Roles')),
        centerTitle: true,
        actions: [
          if (_canManage)
            IconButton(
              key: const Key('invite-member'),
              tooltip: context.tr('Undang pengurus', 'Invite member'),
              icon: const Icon(MoeslimIcons.daftarAkun),
              onPressed: () => _invite(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(membersProvider(widget.ctx.id).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PillTabs(
              labels: [
                '${context.tr('Pengurus', 'Committee')}$count',
                context.tr('Pengaturan Role', 'Role Settings'),
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            if (_tab == 0) ...[
              MosqueBanner(
                title: context.tr('Manajemen Pengurus', 'Committee Management'),
                subtitle: context.tr(
                  'Atur daftar pengurus, peran, dan hak akses aplikasi operasional masjid.',
                  'Manage committee members, roles, and access permissions for mosque operations.',
                ),
              ),
              AsyncBody(
                value: data,
                onRetry: () => ref.invalidate(membersProvider(widget.ctx.id)),
                data: (d) => _members(context, d),
              ),
            ] else
              _roles(context),
          ],
        ),
      ),
    );
  });

  Widget _members(BuildContext context, Map<String, dynamic> d) {
    final lang = context.lang;
    final members = (d['data'] as List).cast<Map>();
    final invites = (d['invitations'] as List? ?? const []).cast<Map>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          context.tr(
            'Daftar Pengurus (${d['active_count']}/${d['limit']})',
            'Committee List (${d['active_count']}/${d['limit']})',
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final m in members)
                ListTile(
                  key: Key('member-${m['id']}'),
                  leading: CircleAvatar(
                    backgroundColor: BrandColors.emerald.withValues(alpha: .12),
                    foregroundColor: BrandColors.emerald,
                    child: Text(_initials(m['name'] as String?), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  title: Text(
                    '${m['name']}',
                    style: TextStyle(decoration: m['status'] == 'active' ? null : TextDecoration.lineThrough),
                  ),
                  subtitle: Text(
                    [
                      if (m['is_owner'] == true) context.tr('Pemilik', 'Owner'),
                      if (m['status'] != 'active') context.tr('Nonaktif', 'Inactive'),
                      ?m['email'] as String?,
                    ].join(' • '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                        roleLabel(m['role'] as String?, lang: lang),
                        icon: roleIcons[m['role']],
                        color: _roleColors[m['role']] ?? BrandColors.emerald,
                      ),
                      if (_canManage)
                        PopupMenuButton<String>(
                          key: Key('member-menu-${m['id']}'),
                          tooltip: context.tr('Kelola', 'Manage'),
                          onSelected: (v) => switch (v) {
                            'deactivate' => _run(
                              () => ref.read(masjidApiProvider).deactivateMember(widget.ctx.id, m['id'] as int),
                              context.tr('Pengurus dinonaktifkan', 'Member deactivated'),
                            ),
                            'reactivate' => _run(
                              () => ref.read(masjidApiProvider).reactivateMember(widget.ctx.id, m['id'] as int),
                              context.tr('Pengurus diaktifkan', 'Member reactivated'),
                            ),
                            _ => _run(
                              () => ref.read(masjidApiProvider).updateMemberRole(widget.ctx.id, m['id'] as int, v),
                              context.tr('Peran diperbarui', 'Role updated'),
                            ),
                          },
                          itemBuilder: (_) => [
                            for (final r in roleLabels.entries)
                              if (r.key != m['role'])
                                PopupMenuItem(
                                  value: r.key,
                                  child: Text(
                                    context.tr(
                                      'Jadikan ${roleLabel(r.key, lang: lang)}',
                                      'Make ${roleLabel(r.key, lang: lang)}',
                                    ),
                                  ),
                                ),
                            const PopupMenuDivider(),
                            if (m['status'] == 'active')
                              PopupMenuItem(value: 'deactivate', child: Text(context.tr('Nonaktifkan', 'Deactivate')))
                            else
                              PopupMenuItem(
                                value: 'reactivate',
                                child: Text(context.tr('Aktifkan kembali', 'Reactivate')),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (invites.isNotEmpty) ...[
          SectionHeader(context.tr('Undangan Menunggu', 'Pending Invitations')),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final i in invites)
                  ListTile(
                    leading: const Icon(MoeslimIcons.surat),
                    title: Text('${i['email']}'),
                    trailing: StatusBadge(roleLabel(i['role'] as String?, lang: lang), color: MosqueColors.info),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          context.tr(
            'Maksimal 5 akun pengurus aktif per masjid. Mengganti pengurus dibatasi 3 kali per 30 hari.',
            'Maximum 5 active committee accounts per mosque. Member swaps are limited to 3 times per 30 days.',
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _roles(BuildContext context) {
    final lang = context.lang;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.tr('Ringkasan Hak Akses (Permission)', 'Role Permissions Overview')),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            for (final r in roleLabels.keys)
              Card(
                key: Key('role-$r'),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(roleIcons[r], color: r == 'admin' ? BrandColors.gold : BrandColors.emerald, size: 32),
                      const SizedBox(height: 6),
                      Text(roleLabel(r, lang: lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        roleDescription(r, lang: lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.tr(
            'Akses keuangan untuk peran Pengurus dapat diaktifkan admin di pengaturan masjid. '
            'Semua izin diperiksa di server.',
            'Finance access for the Committee role can be enabled by an admin in mosque settings. '
            'All permissions are enforced on the server.',
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _invite(BuildContext context) async {
    final lang = context.lang;
    final email = TextEditingController();
    var role = 'pengurus';
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setLocal) => AlertDialog(
          title: Text(context.tr('Undang Pengurus', 'Invite Committee Member')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('invite-email'),
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(labelText: context.tr('Peran', 'Role')),
                items: [
                  for (final r in roleLabels.entries)
                    DropdownMenuItem(value: r.key, child: Text(roleLabel(r.key, lang: lang))),
                ],
                onChanged: (v) => setLocal(() => role = v ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(context.tr('Batal', 'Cancel'))),
            FilledButton(
              key: const Key('send-invite'),
              onPressed: () => Navigator.pop(dialogCtx, (email.text.trim(), role)),
              child: Text(context.tr('Undang', 'Invite')),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    try {
      final inv = await ref.read(masjidApiProvider).inviteMember(widget.ctx.id, result.$1, result.$2);
      ref.invalidate(membersProvider(widget.ctx.id));
      if (!context.mounted) return;
      final token = '${inv['token']}';
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text(context.tr('Kode Undangan', 'Invite Code')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(
                  'Bagikan kode ini ke calon pengurus. Mereka memasukkannya saat Aktivasi Akun.',
                  'Share this code with the invited member. They will enter it during Account Activation.',
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                token,
                key: const Key('invite-token'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: token)),
              child: Text(context.tr('Salin', 'Copy')),
            ),
            FilledButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(context.tr('Selesai', 'Done'))),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (context.mounted) {
        showSnack(context, e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message);
      }
    }
  }
}
