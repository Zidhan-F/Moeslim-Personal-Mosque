import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import '../quran/audio/audio_providers.dart';

/// Pernyataan non-komersial Moeslim Personal dan atribusi seluruh sumber konten.
class AboutLicensesPage extends ConsumerWidget {
  const AboutLicensesPage({super.key});

  static const statement =
      'Moeslim Personal adalah aplikasi non-komersial: gratis selamanya, tanpa iklan, tanpa pembelian '
      'dalam aplikasi, tanpa fitur berbayar, dan tidak menjual atau melacak data pengguna. '
      'Data ibadah pribadi hanya tersimpan di perangkat Anda.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifest = ref.watch(audioManifestProvider).value ?? AudioManifest.empty;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang & Lisensi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(padding: EdgeInsets.all(16), child: Text(statement)),
          ),
          const SizedBox(height: 16),
          Text('Rekaman tilawah', style: t.titleMedium),
          if (manifest.recitations.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Belum ada rekaman terpasang.')),
          for (final r in manifest.recitations)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(r.isMurattal ? Icons.record_voice_over : Icons.graphic_eq),
              title: Text(r.attribution.isNotEmpty ? r.attribution : r.qari),
              subtitle: Text(
                '${r.isMurattal ? 'Murattal' : naghomStyles.firstWhere((s) => s.slug == r.naghom).name}'
                ' • ${r.qari}\nLisensi: ${r.license}',
              ),
              isThreeLine: true,
            ),
          const SizedBox(height: 16),
          Text('Teks Al-Qur\'an, terjemahan & anotasi tajwid', style: t.titleMedium),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Sumber dan atribusi dataset dicantumkan sesuai ketentuan lisensinya saat dataset dipasang '
              '(lihat berkas SOURCE.md pada aset Al-Qur\'an).',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Moeslim Masjid (layanan manajemen masjid berbayar) adalah produk terpisah dan tidak memakai '
            'konten berlisensi non-komersial dari aplikasi ini.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
