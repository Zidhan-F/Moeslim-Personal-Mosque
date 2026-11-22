import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';

import '../../ui/components.dart';
import 'session.dart';

String isoDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Rentang satu bulan kalender (tanggal ISO) untuk ringkasan/laporan.
(String, String) monthRange(DateTime month) =>
    (isoDate(DateTime(month.year, month.month, 1)), isoDate(DateTime(month.year, month.month + 1, 0)));

final dashboardProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(masjidApiProvider).dashboard(id),
);
final eventsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).events(id),
);
final transactionsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, (String, String?, String?)>(
  (ref, k) => ref.watch(masjidApiProvider).transactions(k.$1, flow: k.$2, q: k.$3),
);
final financeSummaryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, String, String)>(
  (ref, k) => ref.watch(masjidApiProvider).financeSummary(k.$1, from: k.$2, to: k.$3),
);
final monthlyReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, int)>(
  (ref, k) => ref.watch(masjidApiProvider).monthlyReport(k.$1, k.$2),
);
final fridayReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, String?)>(
  (ref, k) => ref.watch(masjidApiProvider).fridayReport(k.$1, date: k.$2),
);
final donationBoxCountsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).donationBoxCounts(id),
);
final membersProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(masjidApiProvider).members(id),
);
final staffProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, (String, String, String)>(
  (ref, k) => ref.watch(masjidApiProvider).staffAssignments(k.$1, from: k.$2, to: k.$3),
);
final inventoryProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).inventory(id),
);
final displaysProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(masjidApiProvider).displays(id),
);
final announcementsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).announcements(id),
);
final subscriptionProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(masjidApiProvider).subscription(id),
);
final auditLogsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, id) => ref.watch(masjidApiProvider).auditLogs(id),
);
final zakatProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, int)>(
  (ref, k) => ref.watch(masjidApiProvider).zakat(k.$1, hijriYear: k.$2),
);
final qurbanProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, int)>(
  (ref, k) => ref.watch(masjidApiProvider).qurbanAnimals(k.$1, hijriYear: k.$2),
);
final couponsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, String, int)>(
  (ref, k) => ref.watch(masjidApiProvider).coupons(k.$1, program: k.$2, hijriYear: k.$3),
);

/// Konteks masjid aktif untuk halaman-halaman Mosque: id, nama, kota, slug, dan izin peran.
class MosqueCtx {
  final String id;
  final String name;
  final String? city;
  final String? slug;
  final String role;
  final Set<String> permissions;
  const MosqueCtx({
    required this.id,
    required this.name,
    this.city,
    this.slug,
    required this.role,
    required this.permissions,
  });

  bool can(String p) => permissions.contains('*') || permissions.contains(p);
}

const roleLabels = {'admin': 'Admin', 'bendahara': 'Bendahara', 'pengurus': 'Pengurus', 'operator': 'Operator TV'};
const roleDescriptions = {
  'admin': 'Semua fitur, termasuk pengurus & langganan',
  'bendahara': 'Keuangan & laporan',
  'pengurus': 'Kegiatan, petugas, inventaris',
  'operator': 'Konten & layar TV masjid',
};
const roleIcons = {
  'admin': MoeslimIcons.admin,
  'bendahara': MoeslimIcons.keuangan,
  'pengurus': MoeslimIcons.pengurus,
  'operator': MoeslimIcons.layarTv,
};

/// Lencana kecil berwarna (peran, kondisi, kategori). Teks selalu ≥ 4.5:1 di atas latar lembutnya.
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  const StatusBadge(this.label, {super.key, this.icon, this.color = BrandColors.emerald});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Color.lerp(color, Colors.white, .55)! : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? .22 : .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Warna semantik yang lolos kontras teks di atas latar terang (dipakai di lencana/angka).
abstract final class MosqueColors {
  static const income = Color(0xFF0A6B4F);
  static const expense = Color(0xFFB3261E);
  static const warning = Color(0xFF8A5A00);
  static const info = Color(0xFF1F5C99);
}

/// Kartu statistik ringkas (dashboard): ikon, label, nilai.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color? captionColor;
  final VoidCallback? onTap;
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.captionColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12.5)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    ),
                    if (caption != null)
                      Text(
                        caption!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: captionColor ?? scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner halaman Mosque (judul + deskripsi di atas pola hijau, ikon masjid di kanan).
class MosqueBanner extends StatelessWidget {
  final String? overline;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const MosqueBanner({super.key, this.overline, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => PatternBanner(
    padding: const EdgeInsets.fromLTRB(18, 16, 6, 16),
    child: Row(
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null) Text(overline!, style: const TextStyle(color: BrandColors.cream, fontSize: 13)),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: const TextStyle(color: BrandColors.cream, fontSize: 13)),
              ],
            ],
          ),
        ),
        ?trailing,
        const Expanded(
          flex: 9,
          child: BrandArt(BrandIllustration.mosqueBanner, height: 104, alignment: Alignment.bottomRight),
        ),
      ],
    ),
  );
}

/// Muat data dengan tampilan loading/error yang konsisten (error dapat dicoba ulang).
class AsyncBody<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback onRetry;
  const AsyncBody({super.key, required this.value, required this.data, required this.onRetry});

  @override
  Widget build(BuildContext context) => value.when(
    skipLoadingOnRefresh: true,
    loading: () => const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    ),
    error: (e, _) => BrandEmptyState(
      art: BrandEmptyArt.tanpaInternet,
      title: 'Data belum dapat dimuat',
      message: '$e',
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(MoeslimIcons.refresh),
        label: const Text('Coba lagi'),
      ),
    ),
    data: data,
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  /// Gambar empty state asset kit; bila null, tampil ikon.
  final BrandEmptyArt? art;
  final String? message;
  const EmptyState(this.icon, this.text, {super.key, this.art, this.message});

  @override
  Widget build(BuildContext context) => art != null
      ? BrandEmptyState(art: art!, title: text, message: message, artSize: 120)
      : Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 8),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        );
}

void showSnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
