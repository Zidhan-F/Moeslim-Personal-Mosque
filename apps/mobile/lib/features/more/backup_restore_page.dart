import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({super.key});

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  final _jsonCtrl = TextEditingController();
  String? _statusMessage;
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
      _statusMessage = 'Berhasil membuat cadangan (${summary.exportedKeysCount} kategori data lokal).';
      _isError = false;
    });
  }

  Future<void> _restoreBackup() async {
    final raw = _jsonCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _statusMessage = 'Tempelkan isi JSON cadangan terlebih dahulu sebelum memulihkan.';
        _isError = true;
      });
      return;
    }
    try {
      final count = await ref.read(backupRestoreServiceProvider).restoreFromJson(raw);
      ref.invalidate(settingsProvider);
      setState(() {
        _statusMessage = 'Berhasil memulihkan $count kategori data ke perangkat ini.';
        _isError = false;
      });
    } on FormatException catch (e) {
      setState(() {
        _statusMessage = 'Gagal memulihkan data: ${e.message}';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadangkan & Pulihkan Data Lokal'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PatternBanner(
            child: Text(
              'Moeslim Personal tidak menyimpan data Anda di server cloud. Gunakan fitur ini untuk mengekspor dan memulihkan penanda Al-Qur\'an, riwayat ibadah, tasbih, hafalan, dan pengaturan saat berganti ponsel.',
              style: TextStyle(color: Colors.white, fontSize: 14),
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
                label: const Text('Buat Cadangan Data Sekarang'),
              ),
              OutlinedButton.icon(
                key: const Key('backup-copy-btn'),
                onPressed: _jsonCtrl.text.trim().isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: _jsonCtrl.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('JSON cadangan disalin ke papan klip.')),
                        );
                      },
                icon: const Icon(MoeslimIcons.bagikan),
                label: const Text('Salin JSON'),
              ),
              OutlinedButton.icon(
                key: const Key('backup-restore-btn'),
                onPressed: _restoreBackup,
                icon: const Icon(MoeslimIcons.impor),
                label: const Text('Pulihkan dari JSON di Bawah'),
              ),
            ],
          ),
          if (_statusMessage != null) ...[
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
                        _statusMessage!,
                        key: const Key('backup-status-msg'),
                        style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SectionHeader('Isi Berkas Cadangan (JSON)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                key: const Key('backup-json-field'),
                controller: _jsonCtrl,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Ketuk "Buat Cadangan Data Sekarang" atau tempelkan JSON cadangan Anda di sini...',
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
