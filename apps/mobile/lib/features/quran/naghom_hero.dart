import 'package:material_ui/material_ui.dart';
import 'package:personal_core/personal_core.dart';

import 'naghom_pages.dart';
import 'naghom_theme.dart';

/// Fitur andalan di Beranda: 7 Jenis Irama (Naghom) Al-Qur'an.
class NaghomHero extends StatelessWidget {
  const NaghomHero({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      key: const Key('naghom-hero'),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.graphic_eq, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('7 Irama Al-Qur\'an', style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NaghomCatalogPage())),
                    child: const Text('Semua'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Dengarkan dan pelajari tilawah dengan Bayyati, Hijaz, Shaba, Rast, Jiharkah, Sika, dan Nahawand.',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              // Tinggi mengikuti skala huruf pengguna agar kartu tidak terpotong.
              height: MediaQuery.textScalerOf(context).scale(150).clamp(150, 240),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: naghomStyles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final s = naghomStyles[i];
                  final c = naghomColor(s.slug);
                  return InkWell(
                    key: Key('hero-${s.slug}'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => NaghomDetailPage(style: s))),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [c, Color.lerp(c, Colors.black, .25)!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                            Text(
                              s.name,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ToneLevels(levels: s.toneLevels, color: Colors.white, height: 28),
                            const SizedBox(height: 6),
                            Text(s.toneLabel, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
