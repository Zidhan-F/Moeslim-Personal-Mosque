import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import 'l10n.dart';
import 'providers.dart';
import 'theme.dart';

/// Layanan foto profil 100% lokal (offline) memakai Photo Picker bawaan perangkat.
class ProfilePhotoService {
  static const _channel = MethodChannel('id.moeslim.moeslim_mobile/profile_photo');

  const ProfilePhotoService();

  /// Membuka pemilih foto perangkat dan menyimpannya secara lokal di direktori privat aplikasi.
  /// Mengembalikan path berkas lokal atau `null` bila pengguna membatalkan.
  Future<String?> pickFromGallery() async {
    try {
      final path = await _channel.invokeMethod<String>('pickFromGallery');
      if (path == null || path.trim().isEmpty) return null;
      return path;
    } on MissingPluginException {
      return null;
    }
  }

  /// Menghapus berkas foto profil lokal yang sebelumnya disimpan.
  Future<void> deleteLocalPhoto(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      await _channel.invokeMethod<bool>('deletePhoto', {'path': path});
    } on MissingPluginException {
      final f = File(path);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }
  }
}

final profilePhotoServiceProvider = Provider<ProfilePhotoService>((_) => const ProfilePhotoService());

/// Memeriksa apakah path foto profil lokal tersedia di perangkat.
File? resolveLocalProfilePhoto(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  final file = File(path);
  return file.existsSync() ? file : null;
}

/// Avatar foto profil bulat dengan bingkai serasi tema dan lencana kamera kecil.
/// Dapat diketuk untuk mengganti atau menghapus foto profil lokal secara offline.
class ProfileAvatarButton extends StatelessWidget {
  final String? photoPath;
  final String? displayName;
  final double size;
  final bool onHero;
  final VoidCallback onTap;

  const ProfileAvatarButton({
    super.key,
    required this.photoPath,
    required this.displayName,
    required this.onTap,
    this.size = 64,
    this.onHero = true,
  });

  String? _initial() {
    final trimmed = displayName?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final visual = AppThemeVisual.of(context);
    final scheme = Theme.of(context).colorScheme;
    final file = resolveLocalProfilePhoto(photoPath);
    final initial = _initial();
    final ringColor = onHero ? visual.heroAccentColor.withValues(alpha: .85) : scheme.primary.withValues(alpha: .35);
    final bgColor = onHero
        ? (Theme.of(context).cardTheme.color ?? BrandColors.cream).withValues(alpha: .92)
        : scheme.primaryContainer;

    return Tooltip(
      message: context.tr('Ubah foto profil', 'Change profile photo'),
      child: Semantics(
        button: true,
        label: context.tr('Foto profil, ketuk untuk mengganti', 'Profile photo, tap to change'),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .16),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: ColoredBox(
                      color: bgColor,
                      child: file != null
                          ? Image.file(
                              file,
                              key: const Key('profile-avatar-image'),
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _fallbackAvatar(scheme, initial),
                            )
                          : _fallbackAvatar(scheme, initial),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.8),
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 13, color: scheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar(ColorScheme scheme, String? initial) {
    if (initial != null) {
      return Center(
        child: Text(
          initial,
          style: TextStyle(
            color: scheme.primary,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return Center(
      child: Icon(MoeslimIcons.profil, color: scheme.primary, size: size * 0.48),
    );
  }
}

/// Membuka bottom sheet untuk memilih atau menghapus foto profil lokal (100% offline).
Future<void> showProfilePhotoSheet(BuildContext context, WidgetRef ref, PersonalSettings settings) async {
  final currentFile = resolveLocalProfilePhoto(settings.profilePhotoPath);
  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) {
      final t = Theme.of(sheetCtx).textTheme;
      final scheme = Theme.of(sheetCtx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipOval(
                      child: ColoredBox(
                        color: scheme.primaryContainer,
                        child: currentFile != null
                            ? Image.file(currentFile, fit: BoxFit.cover)
                            : Icon(MoeslimIcons.profil, color: scheme.primary, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sheetCtx.tr('Foto Profil', 'Profile Photo'),
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sheetCtx.tr(
                            'Disimpan secara offline di perangkat Anda dan tidak diunggah ke server.',
                            'Stored offline on your device and never uploaded to any server.',
                          ),
                          style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('profile-photo-pick-gallery'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
                onPressed: () => Navigator.pop(sheetCtx, 'pick'),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(sheetCtx.tr('Pilih Foto dari Galeri', 'Choose Photo from Gallery')),
              ),
              if (settings.profilePhotoPath != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('profile-photo-remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    minimumSize: const Size.fromHeight(46),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(sheetCtx, 'remove'),
                  icon: const Icon(MoeslimIcons.hapus),
                  label: Text(sheetCtx.tr('Hapus Foto Profil', 'Remove Profile Photo')),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  if (action == null) return;
  final photoService = ref.read(profilePhotoServiceProvider);
  final latest = ref.read(settingsProvider).value ?? settings;

  if (action == 'pick') {
    try {
      final pickedPath = await photoService.pickFromGallery();
      if (pickedPath == null) return;
      await ref.read(settingsProvider.notifier).save(latest.copyWith(profilePhotoPath: pickedPath));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Foto profil berhasil diperbarui.', 'Profile photo updated.'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Gagal memilih foto: $e', 'Failed to pick photo: $e'))),
        );
      }
    }
  } else if (action == 'remove') {
    await photoService.deleteLocalPhoto(latest.profilePhotoPath);
    await ref.read(settingsProvider.notifier).save(latest.copyWith(clearProfilePhoto: true));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Foto profil dihapus.', 'Profile photo removed.'))),
      );
    }
  }
}
