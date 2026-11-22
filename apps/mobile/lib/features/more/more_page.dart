import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import '../masjid/masjid_home_page.dart';
import '../prayer/prayer_page.dart';
import 'about_licenses_page.dart';
import 'backup_restore_page.dart';

/// Profil Moeslim Personal: semua data hanya di perangkat, tanpa akun.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref, PersonalSettings s) async {
    final c = TextEditingController(text: s.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nama panggilan'),
        content: TextField(
          key: const Key('name-field'),
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(
            helperText: 'Dipakai untuk sapaan di Beranda. Hanya disimpan di perangkat.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Simpan')),
        ],
      ),
    );
    if (name != null) await ref.read(settingsProvider.notifier).save(s.copyWith(displayName: name));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider).value;
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: true, automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (s != null)
            PatternBanner(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: BrandColors.cream,
                    child: Icon(MoeslimIcons.profil, color: BrandColors.emerald, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.displayName?.isNotEmpty == true ? s.displayName! : 'Sahabat Moeslim',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${s.effectiveLocationName} • ${s.method.label}',
                          style: const TextStyle(color: BrandColors.cream),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('edit-name'),
                    tooltip: 'Ubah nama panggilan',
                    onPressed: () => _editName(context, ref, s),
                    icon: const Icon(MoeslimIcons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
          const SectionHeader('Pengaturan'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(MoeslimIcons.lokasi),
                  title: const Text('Lokasi & metode salat'),
                  subtitle: Text(s == null ? '' : '${s.effectiveLocationSubtitle} • ${s.method.label}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => push(const PrayerSettingsPage()),
                ),
                if (s != null) ...[
                  ListTile(
                    leading: const Icon(MoeslimIcons.bulan),
                    title: const Text('Tampilan'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SegmentedButton<AppThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: AppThemeMode.system, label: Text('Auto')),
                          ButtonSegment(value: AppThemeMode.light, label: Text('Terang')),
                          ButtonSegment(value: AppThemeMode.dark, label: Text('Gelap')),
                        ],
                        selected: {s.themeMode},
                        onSelectionChanged: (v) =>
                            ref.read(settingsProvider.notifier).save(s.copyWith(themeMode: v.first)),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: const Text('Ukuran huruf'),
                    subtitle: Slider(
                      min: 0.85,
                      max: 1.6,
                      divisions: 15,
                      value: s.fontScale,
                      label: '${(s.fontScale * 100).round()}%',
                      onChanged: (v) => ref.read(settingsProvider.notifier).save(s.copyWith(fontScale: v)),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.format_color_text),
                    title: const Text('Warna tajwid'),
                    value: s.tajweedColors,
                    onChanged: (v) => ref.read(settingsProvider.notifier).save(s.copyWith(tajweedColors: v)),
                  ),
                ],
              ],
            ),
          ),
          // Mosque = fitur tambahan opsional untuk pengurus masjid (berbayar bila dipakai).
          // Seluruh fitur Personal tetap gratis, mandiri, dan tidak memerlukan akun (ADR 0005).
          const SectionHeader('Fitur tambahan (opsional)'),
          Card(
            child: ListTile(
              key: const Key('masjid-entry'),
              leading: const Icon(MoeslimIcons.masjid, color: BrandColors.emerald),
              title: const Text('Moeslim Mosque'),
              subtitle: const Text(
                'Untuk pengurus masjid: kas, agenda, petugas & TV Display. Layanan berbayar per masjid, '
                'tidak diperlukan untuk fitur Personal.',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(const MasjidHomePage()),
            ),
          ),
          const SectionHeader('Tentang'),
          Card(
            child: ListTile(
              key: const Key('about-licenses'),
              leading: const Icon(MoeslimIcons.info),
              title: const Text('Tentang'),
              subtitle: const Text('Daftar isi, referensi & lisensi • v$appVersion'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(const AboutLicensesPage()),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('open-backup-restore'),
              leading: const Icon(MoeslimIcons.database),
              title: const Text('Cadangkan & Pulihkan Data Lokal'),
              subtitle: const Text('Ekspor/impor penanda, catatan ibadah, hafalan & pengaturan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(const BackupRestorePage()),
            ),
          ),
        ],
      ),
    );
  }
}
