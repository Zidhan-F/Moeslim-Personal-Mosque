import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

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
  Widget build(BuildContext context) {
    final data = ref.watch(membersProvider(widget.ctx.id));
    final d = data.value;
    final count = d == null ? '' : ' (${d['active_count']}/${d['limit']})';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengurus & Role'),
        centerTitle: true,
        actions: [
          if (_canManage)
            IconButton(
              key: const Key('invite-member'),
              tooltip: 'Undang pengurus',
              icon: const Icon(Icons.person_add_alt),
              onPressed: _invite,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(membersProvider(widget.ctx.id).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PillTabs(
              labels: ['Pengurus$count', 'Pengaturan Role'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            if (_tab == 0) ...[
              const MosqueBanner(
                title: 'Manajemen Pengurus',
                subtitle: 'Atur daftar pengurus, peran, dan hak akses aplikasi operasional masjid.',
                icon: Icons.groups,
              ),
              AsyncBody(value: data, onRetry: () => ref.invalidate(membersProvider(widget.ctx.id)), data: _members),
            ] else
              _roles(),
          ],
        ),
      ),
    );
  }

  Widget _members(Map<String, dynamic> d) {
    final members = (d['data'] as List).cast<Map>();
    final invites = (d['invitations'] as List? ?? const []).cast<Map>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Daftar Pengurus (${d['active_count']}/${d['limit']})'),
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
                      if (m['is_owner'] == true) 'Pemilik',
                      if (m['status'] != 'active') 'Nonaktif',
                      ?m['email'] as String?,
                    ].join(' • '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                        roleLabels[m['role']] ?? '${m['role']}',
                        icon: roleIcons[m['role']],
                        color: _roleColors[m['role']] ?? BrandColors.emerald,
                      ),
                      if (_canManage)
                        PopupMenuButton<String>(
                          key: Key('member-menu-${m['id']}'),
                          tooltip: 'Kelola',
                          onSelected: (v) => switch (v) {
                            'deactivate' => _run(
                              () => ref.read(masjidApiProvider).deactivateMember(widget.ctx.id, m['id'] as int),
                              'Pengurus dinonaktifkan',
                            ),
                            'reactivate' => _run(
                              () => ref.read(masjidApiProvider).reactivateMember(widget.ctx.id, m['id'] as int),
                              'Pengurus diaktifkan',
                            ),
                            _ => _run(
                              () => ref.read(masjidApiProvider).updateMemberRole(widget.ctx.id, m['id'] as int, v),
                              'Peran diperbarui',
                            ),
                          },
                          itemBuilder: (_) => [
                            for (final r in roleLabels.entries)
                              if (r.key != m['role']) PopupMenuItem(value: r.key, child: Text('Jadikan ${r.value}')),
                            const PopupMenuDivider(),
                            if (m['status'] == 'active')
                              const PopupMenuItem(value: 'deactivate', child: Text('Nonaktifkan'))
                            else
                              const PopupMenuItem(value: 'reactivate', child: Text('Aktifkan kembali')),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (invites.isNotEmpty) ...[
          const SectionHeader('Undangan Menunggu'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final i in invites)
                  ListTile(
                    leading: const Icon(Icons.mark_email_unread_outlined),
                    title: Text('${i['email']}'),
                    trailing: StatusBadge(roleLabels[i['role']] ?? '${i['role']}', color: MosqueColors.info),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Maksimal 5 akun pengurus aktif per masjid. Mengganti pengurus dibatasi 3 kali per 30 hari.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _roles() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionHeader('Ringkasan Hak Akses (Permission)'),
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
                    Text(roleLabels[r]!, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(roleDescriptions[r]!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'Akses keuangan untuk peran Pengurus dapat diaktifkan admin di pengaturan masjid. '
        'Semua izin diperiksa di server.',
        style: TextStyle(fontSize: 12),
      ),
    ],
  );

  Future<void> _invite() async {
    final email = TextEditingController();
    var role = 'pengurus';
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Undang Pengurus'),
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
                decoration: const InputDecoration(labelText: 'Peran'),
                items: [for (final r in roleLabels.entries) DropdownMenuItem(value: r.key, child: Text(r.value))],
                onChanged: (v) => setLocal(() => role = v ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              key: const Key('send-invite'),
              onPressed: () => Navigator.pop(context, (email.text.trim(), role)),
              child: const Text('Undang'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    try {
      final inv = await ref.read(masjidApiProvider).inviteMember(widget.ctx.id, result.$1, result.$2);
      ref.invalidate(membersProvider(widget.ctx.id));
      if (!mounted) return;
      final token = '${inv['token']}';
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kode Undangan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bagikan kode ini ke calon pengurus. Mereka memasukkannya saat Aktivasi Akun.'),
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
              child: const Text('Salin'),
            ),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai')),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        showSnack(context, e.errors.values.expand((v) => v is List ? v : [v]).firstOrNull?.toString() ?? e.message);
      }
    }
  }
}
