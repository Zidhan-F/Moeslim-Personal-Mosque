import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/l10n.dart';
import '../../core/location_service.dart';
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
      builder: (dialogCtx) => AlertDialog(
        title: Text(dialogCtx.tr('Nama panggilan', 'Display name')),
        content: TextField(
          key: const Key('name-field'),
          controller: c,
          autofocus: true,
          decoration: InputDecoration(
            helperText: dialogCtx.tr(
              'Dipakai untuk sapaan di Beranda. Hanya disimpan di perangkat.',
              'Used for the greeting on Home. Stored only on your device.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(dialogCtx.tr('Batal', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, c.text.trim()),
            child: Text(dialogCtx.tr('Simpan', 'Save')),
          ),
        ],
      ),
    );
    if (name != null) await ref.read(settingsProvider.notifier).save(s.copyWith(displayName: name));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider).value;
    final lang = context.lang;
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Profil', 'Profile')),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (s != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SegmentedButton<AppLanguage>(
                key: const Key('language-selector'),
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                segments: const [
                  ButtonSegment(value: AppLanguage.id, label: Text('ID')),
                  ButtonSegment(value: AppLanguage.en, label: Text('EN')),
                ],
                selected: {s.language},
                onSelectionChanged: (v) =>
                    ref.read(settingsProvider.notifier).save(s.copyWith(language: v.first)),
              ),
            ),
        ],
      ),
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
                          s.displayName?.isNotEmpty == true
                              ? s.displayName!
                              : context.tr('Sahabat Moeslim', 'Fellow Muslim'),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${localizeLocationLabel(s.effectiveLocationName, lang)} • ${context.methodLabel(s.method)}',
                          style: const TextStyle(color: BrandColors.cream),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('edit-name'),
                    tooltip: context.tr('Ubah nama panggilan', 'Edit display name'),
                    onPressed: () => _editName(context, ref, s),
                    icon: const Icon(MoeslimIcons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
          SectionHeader(context.tr('Pengaturan', 'Settings')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(MoeslimIcons.lokasi),
                  title: Text(context.tr('Lokasi & metode salat', 'Location & prayer method')),
                  subtitle: Text(
                    s == null ? '' : '${localizeLocationSubtitle(s, lang)} • ${context.methodLabel(s.method)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => push(const PrayerSettingsPage()),
                ),
                if (s != null) ...[
                  ListTile(
                    leading: const Icon(MoeslimIcons.bulan),
                    title: Text(context.tr('Tampilan', 'Appearance')),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SegmentedButton<AppThemeMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(value: AppThemeMode.system, label: Text(context.tr('Auto', 'Auto'))),
                          ButtonSegment(value: AppThemeMode.light, label: Text(context.tr('Terang', 'Light'))),
                          ButtonSegment(value: AppThemeMode.dark, label: Text(context.tr('Gelap', 'Dark'))),
                        ],
                        selected: {s.themeMode},
                        onSelectionChanged: (v) =>
                            ref.read(settingsProvider.notifier).save(s.copyWith(themeMode: v.first)),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: Text(context.tr('Ukuran huruf', 'Text size')),
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
                    title: Text(context.tr('Warna tajwid', 'Tajweed colors')),
                    value: s.tajweedColors,
                    onChanged: (v) => ref.read(settingsProvider.notifier).save(s.copyWith(tajweedColors: v)),
                  ),
                ],
              ],
            ),
          ),
          // Mosque = fitur tambahan opsional untuk pengurus masjid (berbayar bila dipakai).
          // Seluruh fitur Personal tetap gratis, mandiri, dan tidak memerlukan akun (ADR 0005).
          SectionHeader(context.tr('Fitur tambahan (opsional)', 'Optional add-on')),
          Card(
            child: ListTile(
              key: const Key('masjid-entry'),
              leading: const Icon(MoeslimIcons.masjid, color: BrandColors.emerald),
              title: const Text('Moeslim Mosque'),
              subtitle: Text(
                context.tr(
                  'Untuk pengurus masjid: kas, agenda, petugas & TV Display. Layanan berbayar per masjid, '
                      'tidak diperlukan untuk fitur Personal.',
                  'For mosque managers: treasury, events, staff schedules & TV Display. Paid per mosque, '
                      'not required for Personal features.',
                ),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(const MasjidHomePage()),
            ),
          ),
          SectionHeader(context.tr('Tentang', 'About')),
          Card(
            child: ListTile(
              key: const Key('about-licenses'),
              leading: const Icon(MoeslimIcons.info),
              title: Text(context.tr('Tentang', 'About')),
              subtitle: Text(
                context.tr(
                  'Daftar isi, referensi & lisensi • v$appVersion',
                  'Contents, sources & licenses • v$appVersion',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(const AboutLicensesPage()),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('open-backup-restore'),
              leading: const Icon(MoeslimIcons.database),
              title: Text(context.tr('Cadangkan & Pulihkan Data Lokal', 'Backup & Restore Local Data')),
              subtitle: Text(
                context.tr(
                  'Ekspor/impor penanda, catatan ibadah, hafalan & pengaturan',
                  'Export or import bookmarks, worship logs, memorization & settings',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(const BackupRestorePage()),
            ),
          ),
        ],
      ),
    );
  }
}
