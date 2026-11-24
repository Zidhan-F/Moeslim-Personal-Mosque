import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../core/adzan_service.dart';
import '../../core/l10n.dart';
import '../../core/location_service.dart';
import '../../core/profile_photo_service.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../ui/components.dart';
import '../masjid/masjid_home_page.dart';
import '../prayer/prayer_page.dart';
import 'about_licenses_page.dart';
import 'backup_restore_page.dart';
import 'theme_picker.dart';

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
    final adzanState = ref.watch(adzanControllerProvider);
    final lang = context.lang;
    final scheme = Theme.of(context).colorScheme;
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
            Builder(
              builder: (context) {
                final visual = AppThemeVisual.of(context);
                return HomeHeroBanner(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ProfileAvatarButton(
                        key: const Key('profile-page-avatar'),
                        photoPath: s.profilePhotoPath,
                        displayName: s.displayName,
                        size: 58,
                        onTap: () => showProfilePhotoSheet(context, ref, s),
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
                              style: TextStyle(color: visual.heroTextColor, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${localizeLocationLabel(s.effectiveLocationName, lang)} • ${context.methodLabel(s.method)}',
                              style: TextStyle(color: visual.heroSubtextColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        key: const Key('edit-name'),
                        tooltip: context.tr('Ubah nama panggilan', 'Edit display name'),
                        onPressed: () => _editName(context, ref, s),
                        icon: Icon(MoeslimIcons.edit, color: visual.heroTextColor),
                      ),
                    ],
                  ),
                );
              },
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
                    key: const Key('theme-selector'),
                    leading: Icon(s.themeMode.visual.icon, color: Theme.of(context).colorScheme.primary),
                    title: Text(context.tr('Tampilan', 'Appearance')),
                    subtitle: Text(
                      '${context.tr(s.themeMode.labelId, s.themeMode.labelEn)} · '
                      '${context.tr(s.themeMode.subtitleId, s.themeMode.subtitleEn)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final mode = await showThemePicker(context, s.themeMode);
                      if (mode != null && context.mounted) {
                        final latest = ref.read(settingsProvider).value ?? s;
                        await ref.read(settingsProvider.notifier).save(latest.copyWith(themeMode: mode));
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            key: const Key('quick-theme-light'),
                            avatar: const Icon(Icons.wb_sunny_rounded, size: 16),
                            label: Text(context.tr('Terang', 'Light')),
                            selected: s.themeMode == AppThemeMode.light,
                            onSelected: (_) => ref
                                .read(settingsProvider.notifier)
                                .save(s.copyWith(themeMode: AppThemeMode.light)),
                          ),
                          ChoiceChip(
                            key: const Key('quick-theme-dark'),
                            avatar: const Icon(Icons.dark_mode_rounded, size: 16),
                            label: Text(context.tr('Gelap', 'Dark')),
                            selected: s.themeMode == AppThemeMode.dark,
                            onSelected: (_) => ref
                                .read(settingsProvider.notifier)
                                .save(s.copyWith(themeMode: AppThemeMode.dark)),
                          ),
                          ActionChip(
                            key: const Key('quick-theme-more'),
                            avatar: Icon(
                              s.themeMode != AppThemeMode.light && s.themeMode != AppThemeMode.dark
                                  ? s.themeMode.visual.icon
                                  : Icons.palette_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            backgroundColor: s.themeMode != AppThemeMode.light && s.themeMode != AppThemeMode.dark
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: .14)
                                : null,
                            label: Text(
                              s.themeMode != AppThemeMode.light && s.themeMode != AppThemeMode.dark
                                  ? context.tr(
                                      '${s.themeMode.labelId} (8 Tema)',
                                      '${s.themeMode.labelEn} (8 Themes)',
                                    )
                                  : context.tr('8 Tema Lainnya', '8 More Themes'),
                            ),
                            onPressed: () async {
                              final mode = await showThemePicker(context, s.themeMode);
                              if (mode != null && context.mounted) {
                                final latest = ref.read(settingsProvider).value ?? s;
                                await ref.read(settingsProvider.notifier).save(latest.copyWith(themeMode: mode));
                              }
                            },
                          ),
                        ],
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
          // Pengaturan langsung suara adzan di Profil: master switch, volume mandiri, pratinjau & pilih muadzin.
          if (s != null) ...[
            SectionHeader(context.tr('Suara Adzan', 'Adhan Sound')),
            Card(
              key: const Key('profile-adzan-card'),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      key: const Key('profile-adzan-switch'),
                      secondary: Icon(
                        s.notificationsEnabled ? MoeslimIcons.adzan : MoeslimIcons.bisukan,
                        color: s.notificationsEnabled ? scheme.primary : scheme.outline,
                      ),
                      title: Text(
                        context.tr('Alarm Suara Adzan', 'Adhan Sound Alert'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        s.notificationsEnabled
                            ? context.tr(
                                'Aktif (${s.activeAdzanCount}/5 waktu) · ${s.muadzin.name}',
                                'Active (${s.activeAdzanCount}/5 prayers) · ${s.muadzin.name}',
                              )
                            : context.tr(
                                'Nonaktif. Nyalakan agar adzan berkumandang saat masuk waktu salat.',
                                'Off. Enable to play the adhan at each prayer time.',
                              ),
                      ),
                      value: s.notificationsEnabled,
                      onChanged: (enabled) async {
                        await ref.read(settingsProvider.notifier).save(s.copyWith(notificationsEnabled: enabled));
                        if (enabled) {
                          await ref.read(adzanControllerProvider.notifier).requestNotificationPermission();
                        } else {
                          await ref.read(adzanControllerProvider.notifier).stopAdzan();
                        }
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      key: const Key('profile-adzan-override-switch'),
                      secondary: Icon(
                        s.adzanOverrideDeviceVolume ? Icons.volume_up_rounded : Icons.phone_android_rounded,
                        color: s.adzanOverrideDeviceVolume ? scheme.primary : scheme.outline,
                      ),
                      title: Text(
                        context.tr('Suara Adzan Mandiri', 'Independent Adhan Volume'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        s.adzanOverrideDeviceVolume
                            ? context.tr(
                                'Memakai volume aplikasi sendiri walau HP hening, lalu mengembalikan volume HP setelah adzan.',
                                'Uses the app volume below even if your phone is muted, then restores phone volume after adhan.',
                              )
                            : context.tr(
                                'Mengikuti volume notifikasi dan mode hening perangkat HP Anda.',
                                'Follows your phone notification volume and silent mode.',
                              ),
                      ),
                      value: s.adzanOverrideDeviceVolume,
                      onChanged: (override) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .save(s.copyWith(adzanOverrideDeviceVolume: override));
                        await ref
                            .read(adzanControllerProvider.notifier)
                            .updateLiveVolume(s.adzanVolume, overrideDeviceVolume: override);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.tr(
                                'Volume Suara Adzan (${(s.adzanVolume * 100).round()}%)',
                                'Adhan Sound Volume (${(s.adzanVolume * 100).round()}%)',
                              ),
                              key: const Key('profile-adzan-volume-label'),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          if (s.adzanVolume <= 0.001)
                            Text(
                              context.tr('Hening', 'Muted'),
                              style: TextStyle(color: scheme.outline, fontWeight: FontWeight.w600, fontSize: 12.5),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            key: const Key('profile-adzan-volume-mute'),
                            tooltip: context.tr('Bisukan suara adzan (0%)', 'Mute adhan sound (0%)'),
                            icon: Icon(
                              s.adzanVolume <= 0.001 ? Icons.volume_off_rounded : Icons.volume_mute_rounded,
                              color: s.adzanVolume <= 0.001 ? scheme.primary : scheme.outline,
                            ),
                            onPressed: () async {
                              await ref.read(settingsProvider.notifier).save(s.copyWith(adzanVolume: 0.0));
                              await ref
                                  .read(adzanControllerProvider.notifier)
                                  .updateLiveVolume(0.0, overrideDeviceVolume: s.adzanOverrideDeviceVolume);
                            },
                          ),
                          Expanded(
                            child: Slider(
                              key: const Key('profile-adzan-volume-slider'),
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              value: s.adzanVolume,
                              label: '${(s.adzanVolume * 100).round()}%',
                              onChanged: (v) async {
                                await ref.read(settingsProvider.notifier).save(s.copyWith(adzanVolume: v));
                                await ref
                                    .read(adzanControllerProvider.notifier)
                                    .updateLiveVolume(v, overrideDeviceVolume: s.adzanOverrideDeviceVolume);
                              },
                            ),
                          ),
                          IconButton(
                            key: const Key('profile-adzan-volume-max'),
                            tooltip: context.tr('Volume maksimal (100%)', 'Maximum volume (100%)'),
                            icon: Icon(
                              Icons.volume_up_rounded,
                              color: s.adzanVolume >= 0.99 ? scheme.primary : scheme.outline,
                            ),
                            onPressed: () async {
                              await ref.read(settingsProvider.notifier).save(s.copyWith(adzanVolume: 1.0));
                              await ref
                                  .read(adzanControllerProvider.notifier)
                                  .updateLiveVolume(1.0, overrideDeviceVolume: s.adzanOverrideDeviceVolume);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      key: const Key('profile-adzan-muadzin'),
                      leading: Icon(MoeslimIcons.audio, color: scheme.primary),
                      title: Text(context.tr('Pilih Muadzin & Jadwal Adzan', 'Choose Muadzin & Adhan Schedule')),
                      subtitle: Text('${s.muadzin.name} · ${s.muadzin.originFor(lang)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: const Key('profile-adzan-preview'),
                            tooltip: adzanState.previewingMuadzinId == s.muadzin.id
                                ? context.tr('Hentikan pratinjau adzan', 'Stop adhan preview')
                                : context.tr('Putar pratinjau adzan', 'Preview adhan sound'),
                            icon: Icon(
                              adzanState.previewingMuadzinId == s.muadzin.id
                                  ? MoeslimIcons.pause
                                  : MoeslimIcons.play,
                              color: scheme.primary,
                            ),
                            onPressed: () =>
                                ref.read(adzanControllerProvider.notifier).togglePreviewMuadzin(s.muadzin),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => push(const PrayerSettingsPage(focusAdzan: true)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Mosque = fitur tambahan opsional untuk pengurus masjid (berbayar bila dipakai).
          // Seluruh fitur Personal tetap gratis, mandiri, dan tidak memerlukan akun (ADR 0005).
          SectionHeader(context.tr('Fitur tambahan (opsional)', 'Optional add-on')),
          Card(
            child: ListTile(
              key: const Key('masjid-entry'),
              leading: Icon(MoeslimIcons.masjid, color: Theme.of(context).colorScheme.primary),
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
          const DeveloperWatermark(
            key: Key('profile-developer-watermark'),
            padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
          ),
        ],
      ),
    );
  }
}
