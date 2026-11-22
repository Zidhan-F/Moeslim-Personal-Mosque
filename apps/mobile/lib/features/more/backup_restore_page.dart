import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/l10n.dart';
import '../../core/providers.dart';
import '../../ui/components.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({super.key});

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  final _jsonCtrl = TextEditingController();
  ({String id, String en})? _status;
  bool _isError = false;

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportBackup() async {
    final summary = await ref.read(backupRestoreServiceProvider).createBackup();
    setState(() {
      _jsonCtrl.text = summary.jsonPayload;
      _status = (
        id: 'Berhasil membuat cadangan (${summary.exportedKeysCount} kategori data lokal).',
        en: 'Backup created (${summary.exportedKeysCount} local data categories).',
      );
      _isError = false;
    });
  }

  Future<void> _restoreBackup() async {
    final raw = _jsonCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _status = (
          id: 'Tempelkan isi JSON cadangan terlebih dahulu sebelum memulihkan.',
          en: 'Paste your backup JSON first before restoring.',
        );
        _isError = true;
      });
      return;
    }
    try {
      final count = await ref.read(backupRestoreServiceProvider).restoreFromJson(raw);
      ref.invalidate(settingsProvider);
      setState(() {
        _status = (
          id: 'Berhasil memulihkan $count kategori data ke perangkat ini.',
          en: 'Restored $count data categories to this device.',
        );
        _isError = false;
      });
    } on FormatException catch (e) {
      setState(() {
        _status = (
          id: 'Gagal memulihkan data: ${e.message}',
          en: 'Failed to restore data: ${e.message}',
        );
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final statusMessage = _status == null ? null : context.tr(_status!.id, _status!.en);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Cadangkan & Pulihkan Data Lokal', 'Backup & Restore Local Data')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PatternBanner(
            child: Text(
              context.tr(
                "Moeslim Personal tidak menyimpan data Anda di server cloud. Gunakan fitur ini untuk mengekspor dan memulihkan penanda Al-Qur'an, riwayat ibadah, tasbih, hafalan, dan pengaturan saat berganti ponsel.",
                "Moeslim Personal does not store your data on cloud servers. Use this tool to export and restore your Qur'an bookmarks, worship logs, tasbih, memorization, and settings when switching devices.",
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('backup-generate-btn'),
                onPressed: _exportBackup,
                icon: const Icon(MoeslimIcons.ekspor),
                label: Text(context.tr('Buat Cadangan Data Sekarang', 'Create Backup Now')),
              ),
              OutlinedButton.icon(
                key: const Key('backup-copy-btn'),
                onPressed: _jsonCtrl.text.trim().isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: _jsonCtrl.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.tr(
                                'JSON cadangan disalin ke papan klip.',
                                'Backup JSON copied to clipboard.',
                              ),
                            ),
                          ),
                        );
                      },
                icon: const Icon(MoeslimIcons.bagikan),
                label: Text(context.tr('Salin JSON', 'Copy JSON')),
              ),
              OutlinedButton.icon(
                key: const Key('backup-restore-btn'),
                onPressed: _restoreBackup,
                icon: const Icon(MoeslimIcons.impor),
                label: Text(context.tr('Pulihkan dari JSON di Bawah', 'Restore from JSON Below')),
              ),
            ],
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      _isError ? MoeslimIcons.peringatan : MoeslimIcons.berhasil,
                      color: _isError ? scheme.error : scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusMessage,
                        key: const Key('backup-status-msg'),
                        style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SectionHeader(context.tr('Isi Berkas Cadangan (JSON)', 'Backup Payload (JSON)')),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                key: const Key('backup-json-field'),
                controller: _jsonCtrl,
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: context.tr(
                    'Ketuk "Buat Cadangan Data Sekarang" atau tempelkan JSON cadangan Anda di sini...',
                    'Tap "Create Backup Now" or paste your backup JSON here...',
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
