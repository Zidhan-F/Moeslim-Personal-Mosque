import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';

import '../../ui/components.dart';
import '../quran/quran_source.dart';

/// Satu doa dalam Al-Qur'an: rentang ayat beserta teks & terjemahan dari dataset terpasang.
class QuranicDua {
  final int surah;
  final int from;
  final int to;
  final List<Ayah> ayat;
  const QuranicDua(this.surah, this.from, this.to, this.ayat);

  String get reference => 'QS. ${surahs[surah - 1].name}: ${from == to ? '$from' : '$from–$to'}';
  String get translation => ayat.map((a) => a.translation ?? '').join(' ');
}

final quranicDuasProvider = FutureProvider<List<QuranicDua>>((ref) async {
  final source = ref.watch(quranSourceProvider);
  final cache = <int, List<Ayah>?>{};
  final out = <QuranicDua>[];
  for (final (s, a, b) in quranicDuaRanges) {
    final ayat = cache[s] ??= await source.load(s);
    if (ayat == null) continue;
    out.add(QuranicDua(s, a, b, ayat.sublist(a - 1, b)));
  }
  return out;
});

class DoaListPage extends ConsumerStatefulWidget {
  const DoaListPage({super.key});

  @override
  ConsumerState<DoaListPage> createState() => _DoaListPageState();
}

class _DoaListPageState extends ConsumerState<DoaListPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final duas = ref.watch(quranicDuasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Doa dalam Al-Qur\'an'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BrandArt(BrandIllustration.heroQuran, height: 190),
          const SizedBox(height: 8),
          Text('Kumpulan Doa', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          const Text('Doa-doa yang diabadikan dalam Al-Qur\'an, lengkap dengan teks Arab dan terjemahan Kemenag.'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('doa-search'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari doa (mis. ampunan, ilmu, orang tua)',
            ),
            onChanged: (v) => setState(() => _q = v.toLowerCase()),
          ),
          const SizedBox(height: 8),
          ...duas.when(
            loading: () => [
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) => [Text('$e')],
            data: (list) {
              final filtered = list.where(
                (d) => _q.isEmpty || d.translation.toLowerCase().contains(_q) || d.reference.toLowerCase().contains(_q),
              );
              if (list.isEmpty) {
                return [const Padding(padding: EdgeInsets.all(24), child: Text('Teks Al-Qur\'an belum tersedia.'))];
              }
              return [
                for (final d in filtered.take(200))
                  Card(
                    child: ListTile(
                      title: Text(d.reference, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(d.translation, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DoaDetailPage(dua: d))),
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class DoaDetailPage extends StatelessWidget {
  final QuranicDua dua;
  const DoaDetailPage({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Doa'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArchHeader(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: BrandColors.emerald, borderRadius: BorderRadius.circular(20)),
                  child: const Text(
                    'Doa dalam Al-Qur\'an',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(dua.reference, style: t.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                for (final a in dua.ayat)
                  Text(
                    a.text,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: quranTextStyle(fontSize: 26),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.translate, color: BrandColors.emerald),
              title: const Text('Artinya (Terjemahan Kemenag)', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(dua.translation)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(dua.reference),
              subtitle: const Text('Teks: Tanzil (Uthmani) • Terjemahan: Kementerian Agama RI'),
            ),
          ),
        ],
      ),
    );
  }
}
