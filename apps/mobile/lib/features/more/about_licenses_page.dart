import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../quran/audio/audio_providers.dart';

/// Pernyataan non-komersial Moeslim Personal dan atribusi seluruh sumber konten.
/// Atribusi sumber konten bawaan (lihat juga apps/mobile/assets/quran/SOURCE.md & docs/licensing/).
const contentSources = <(String, String)>[
  (
    'Teks Al-Qur\'an: Tanzil Quran Text (Uthmani)',
    'Hak cipta © Tanzil Project (tanzil.net). Disalin apa adanya (verbatim); basmalah ditampilkan sebagai '
        'pembuka surah, bukan bagian ayat 1.',
  ),
  (
    'Terjemahan: Al-Qur\'an dan Terjemahannya (Kementerian Agama RI)',
    'Teks terjemahan id.indonesian melalui Tanzil.net (pembaruan 4 Juni 2010).',
  ),
  (
    'Anotasi tajwid: pengklasifikasi Moeslim PM',
    'Ditandai otomatis atas teks Tanzil untuk 6.236 ayat; aturan disamakan dengan cpfair/quran-tajweed. '
        'Perlu telaah guru tajwid.',
  ),
  ('Font mushaf: Amiri Quran', '© The Amiri Project Authors (SIL Open Font License 1.1).'),
  ('Font antarmuka: Inter', '© The Inter Project Authors (SIL Open Font License 1.1).'),
  (
    'Ikon antarmuka: Font Awesome 4',
    '© Dave Gandy (fontawesome.com), SIL Open Font License 1.1. Dikemas ulang sebagai font MoeslimIcons.',
  ),
  ('Ilustrasi, ikon Islami & aset visual', 'Moeslim PM Asset Kit, dibuat khusus untuk Moeslim PM.'),
  (
    'Doa harian & aktivitas (229 doa)',
    'Kumpulan doa harian dan aktivitas merujuk kitab Hisnul Muslim (Syaikh Sa\'id bin Ali Al-Qahthani) & '
        'EQuran.id Doa & Dzikir API (penggunaan non-komersial dengan atribusi).',
  ),
];

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
          const Center(child: BrandLogo(variant: BrandLogoVariant.stacked, height: 140)),
          const SizedBox(height: 16),
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
              leading: const Icon(MoeslimIcons.audio),
              title: Text(r.attribution.isNotEmpty ? r.attribution : r.qari),
              subtitle: Text('Murattal • ${r.qari}\nLisensi: ${r.license}'),
              isThreeLine: true,
            ),
          const SizedBox(height: 16),
          Text('Teks Al-Qur\'an, terjemahan & anotasi tajwid', style: t.titleMedium),
          for (final (title, detail) in contentSources)
            ListTile(contentPadding: EdgeInsets.zero, title: Text(title), subtitle: Text(detail)),
          const SizedBox(height: 8),
          const Text(
            'Moeslim Mosque adalah fitur tambahan opsional untuk pengurus masjid yang berbayar per masjid. '
            'Fitur ini terpisah dari fitur Personal, tidak memakai konten berlisensi non-komersial, dan '
            'tidak diperlukan untuk memakai Moeslim Personal.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
