import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../ui/components.dart';
import '../masjid/masjid_api.dart';
import '../masjid/session.dart';
import 'location_service.dart';

/// Paket wilayah offline (diunduh per sel, tanpa token & tanpa koordinat persis pengguna).
final directoryRepoProvider = Provider<DirectoryRepository>(
  (ref) => DirectoryRepository(ref.watch(storeProvider), (cell) => ref.read(masjidApiProvider).directoryCell(cell)),
);

/// Membuka aplikasi peta untuk rute (di-override di test).
final mapLauncherProvider = Provider<Future<bool> Function(DirectoryPlace)>((ref) {
  return (p) async {
    final geo = Uri.parse('geo:${p.lat},${p.lng}?q=${p.lat},${p.lng}(${Uri.encodeComponent(p.name)})');
    if (await canLaunchUrl(geo)) return launchUrl(geo, mode: LaunchMode.externalApplication);
    return launchUrl(
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}'),
      mode: LaunchMode.externalApplication,
    );
  };
});

const radiusOptions = [1000.0, 3000.0, 5000.0, 10000.0];

/// Masjid & musala di sekitar pengguna dari direktori (OpenStreetMap + masjid terverifikasi + laporan pengguna).
class NearbyMosquesPage extends ConsumerStatefulWidget {
  const NearbyMosquesPage({super.key});

  @override
  ConsumerState<NearbyMosquesPage> createState() => _NearbyMosquesPageState();
}

class _NearbyMosquesPageState extends ConsumerState<NearbyMosquesPage> {
  LocationFix? _fix;
  LocationException? _locError;
  bool _locating = true;
  double _radius = 3000;
  int _view = 0;
  Future<NearbyResult>? _result;

  /// Titik pusat pencarian: GPS bila ada, selain itu pusat kota pilihan (perkiraan).
  (double, double)? _center;
  bool get _usingCity => _fix == null;

  @override
  void initState() {
    super.initState();
    Future.microtask(_locate);
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locError = null;
    });
    try {
      final fix = await ref.read(locationServiceProvider).current();
      _fix = fix;
      _center = (fix.latitude, fix.longitude);
    } on LocationException catch (e) {
      _locError = e;
      _fix = null;
      final PersonalSettings s = ref.read(settingsProvider).value ?? await ref.read(settingsProvider.future);
      _center = (s.location.latitude, s.location.longitude);
    }
    if (!mounted) return;
    setState(() => _locating = false);
    _load();
  }

  void _load() {
    final c = _center;
    if (c == null) return;
    final future = ref.read(directoryRepoProvider).nearby(c.$1, c.$2, _radius);
    setState(() {
      _result = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(settingsProvider).value?.location.name ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Terdekat'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('nearby-refresh'),
            tooltip: 'Perbarui lokasi',
            icon: const Icon(Icons.my_location),
            onPressed: _locating ? null : _locate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-place'),
        heroTag: null,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Tambah Masjid'),
        onPressed: _addPlace,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          _locationCard(city),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final r in radiusOptions)
                ChoiceChip(
                  key: Key('radius-${r.toInt()}'),
                  label: Text(formatDistanceId(r)),
                  selected: _radius == r,
                  onSelected: (_) {
                    setState(() => _radius = r);
                    _load();
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          PillTabs(labels: const ['Daftar', 'Radar'], index: _view, onChanged: (i) => setState(() => _view = i)),
          const SizedBox(height: 10),
          if (_locating)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Menentukan lokasi Anda…')],
              ),
            )
          else
            FutureBuilder<NearbyResult>(
              future: _result,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) return Padding(padding: const EdgeInsets.all(24), child: Text('${snap.error}'));
                return _results(snap.data!);
              },
            ),
        ],
      ),
    );
  }

  Widget _locationCard(String city) {
    final scheme = Theme.of(context).colorScheme;
    final err = _locError;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_usingCity ? Icons.location_city : Icons.gps_fixed, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locating
                            ? 'Mencari lokasi…'
                            : _usingCity
                            ? 'Perkiraan dari pusat kota $city'
                            : 'Lokasi Anda saat ini',
                        key: const Key('location-status'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (_fix != null)
                        Text(
                          'Akurasi ±${_fix!.accuracyM.round()} m',
                          key: const Key('location-accuracy'),
                          style: TextStyle(color: _fix!.precise ? null : MosqueTextColors.warning),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_fix != null && !_fix!.precise)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Akurasi rendah (mungkin di dalam gedung). Jarak bisa meleset; coba perbarui di tempat terbuka.',
                  style: TextStyle(fontSize: 12.5),
                ),
              ),
            if (err != null) ...[
              const SizedBox(height: 6),
              Text(err.message, key: const Key('location-error'), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              FilledButton.tonalIcon(
                key: const Key('location-fix'),
                onPressed: err.problem == LocationProblem.deniedForever
                    ? () => ref.read(locationServiceProvider).openSettings()
                    : _locate,
                icon: Icon(err.problem == LocationProblem.deniedForever ? Icons.settings : Icons.my_location),
                label: Text(err.problem == LocationProblem.deniedForever ? 'Buka Pengaturan' : 'Izinkan / coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _results(NearbyResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (r.stale)
          const _Notice(
            key: Key('nearby-stale'),
            icon: Icons.cloud_off,
            text: 'Offline — menampilkan data wilayah yang tersimpan di perangkat.',
          ),
        if (r.missingCells > 0)
          const _Notice(
            key: Key('nearby-missing'),
            icon: Icons.wifi_off,
            text: 'Sebagian data wilayah belum terunduh. Sambungkan internet sekali agar tersimpan untuk dipakai offline.',
          ),
        if (r.places.isEmpty)
          Padding(
            key: const Key('nearby-empty'),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const BrandArt(BrandIllustration.mosqueCircle, height: 140),
                const SizedBox(height: 8),
                Text(
                  'Belum ada masjid tercatat dalam radius ${formatDistanceId(_radius)}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Perbesar radius, atau bantu jamaah lain dengan menambahkan masjid di sekitar Anda.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else if (_view == 0)
          for (final n in r.places) _PlaceTile(n: n, onTap: () => _openPlace(n))
        else
          _Radar(places: r.places, radius: _radius, onTap: _openPlace),
        if (r.places.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${r.places.length} tempat dalam radius ${formatDistanceId(_radius)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        if (r.attribution.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Data peta ${r.attribution.join(' • ')}',
              key: const Key('osm-attribution'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5),
            ),
          ),
      ],
    );
  }

  Future<void> _openPlace(NearbyPlace n) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PlaceSheet(n: n, fix: _fix, onReported: _reported),
  );

  void _reported() =>
      showSnack(context, 'Terima kasih! Laporan dikirim dan akan ditinjau sebelum tampil untuk jamaah lain.');

  Future<void> _addPlace() async {
    final fix = _fix;
    if (fix == null) {
      showSnack(context, 'Aktifkan lokasi (GPS) dan berdirilah di masjid yang ingin ditambahkan.');
      return;
    }
    final name = TextEditingController();
    var kind = 'masjid';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Tambah Masjid / Musala'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pastikan Anda sedang berada di lokasinya. Posisi GPS Anda saat ini dipakai sebagai lokasi.'),
              const SizedBox(height: 12),
              TextField(
                key: const Key('new-place-name'),
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama', hintText: 'Contoh: Masjid Nurul Huda'),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'masjid', label: Text('Masjid')),
                  ButtonSegment(value: 'musala', label: Text('Musala')),
                ],
                selected: {kind},
                onSelectionChanged: (v) => setLocal(() => kind = v.first),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(
              key: const Key('send-new-place'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().length < 3) return;
    try {
      await ref.read(masjidApiProvider).reportDirectory({
        'type': 'new_mosque',
        'name': name.text.trim(),
        'kind': kind,
        'latitude': fix.latitude,
        'longitude': fix.longitude,
      });
      if (mounted) _reported();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }
}

void showSnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

abstract final class MosqueTextColors {
  static const warning = Color(0xFF8A5A00);
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Notice({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Card(
    color: BrandColors.gold.withValues(alpha: .14),
    child: ListTile(
      dense: true,
      leading: Icon(icon, color: BrandColors.goldText),
      title: Text(text, style: const TextStyle(fontSize: 13)),
    ),
  );
}

class _PlaceTile extends StatelessWidget {
  final NearbyPlace n;
  final VoidCallback onTap;
  const _PlaceTile({required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = n.place;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('place-${p.id}'),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withValues(alpha: .1),
          child: Icon(p.isMusala ? Icons.house_outlined : Icons.mosque, color: scheme.primary),
        ),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          [
            '${formatDistanceId(n.distanceM)} • ${compassPointId(n.bearing)}',
            if (p.address != null || p.city != null) [p.address, p.city].whereType<String>().join(', '),
          ].join('\n'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (p.verified) const _VerifiedBadge() else Text(p.isMusala ? 'Musala' : 'Masjid'),
            const SizedBox(height: 2),
            Transform.rotate(
              angle: n.bearing * math.pi / 180,
              child: Icon(Icons.navigation, size: 18, color: scheme.primary, semanticLabel: compassPointId(n.bearing)),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: BrandColors.gold.withValues(alpha: .18), borderRadius: BorderRadius.circular(12)),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified, size: 14, color: BrandColors.goldText),
        SizedBox(width: 3),
        Text(
          'Terverifikasi',
          style: TextStyle(fontSize: 11.5, color: BrandColors.goldText, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

/// Radar sederhana: pengguna di tengah, utara di atas, titik masjid sesuai arah & jarak (tanpa peta daring).
class _Radar extends StatelessWidget {
  final List<NearbyPlace> places;
  final double radius;
  final void Function(NearbyPlace) onTap;
  const _Radar({required this.places, required this.radius, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final size = math.min(box.maxWidth, 340.0);
            final r = size / 2 - 18;
            return SizedBox.square(
              key: const Key('nearby-radar'),
              dimension: size,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Semantics(
                      label: 'Radar ${places.length} masjid dalam radius ${formatDistanceId(radius)}, utara di atas',
                      child: CustomPaint(painter: _RadarPainter(radius: radius)),
                    ),
                  ),
                  for (final n in places.take(40))
                    Builder(
                      builder: (_) {
                        final a = (n.bearing - 90) * math.pi / 180;
                        final d = (n.distanceM / radius).clamp(0.0, 1.0) * r;
                        return Positioned(
                          left: size / 2 + math.cos(a) * d - 12,
                          top: size / 2 + math.sin(a) * d - 12,
                          child: GestureDetector(
                            key: Key('radar-${n.place.id}'),
                            onTap: () => onTap(n),
                            child: Tooltip(
                              message: '${n.place.name} • ${formatDistanceId(n.distanceM)}',
                              child: Icon(
                                n.place.verified ? Icons.verified : Icons.location_on,
                                size: 24,
                                color: n.place.verified ? BrandColors.gold : BrandColors.emerald,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        const Text('Ketuk titik untuk detail. Utara (U) di atas.', style: TextStyle(fontSize: 12.5)),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double radius;
  _RadarPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 18;
    canvas.drawCircle(c, r, Paint()..color = BrandColors.emerald.withValues(alpha: .06));
    final ring = Paint()
      ..color = BrandColors.emerald.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(c, r * i / 3, ring);
      final tp = TextPainter(
        text: TextSpan(
          text: formatDistanceId(radius * i / 3),
          style: const TextStyle(
            fontFamily: 'Inter',
            package: 'moeslim_brand',
            fontSize: 10.5,
            color: BrandColors.deep,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c + Offset(4, -r * i / 3 + 2));
    }
    canvas.drawLine(c - Offset(0, r), c + Offset(0, r), ring);
    canvas.drawLine(c - Offset(r, 0), c + Offset(r, 0), ring);
    final north = TextPainter(
      text: const TextSpan(
        text: 'U',
        style: TextStyle(
          fontFamily: 'Inter',
          package: 'moeslim_brand',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: BrandColors.deep,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    north.paint(canvas, c - Offset(north.width / 2, r + 17));
    canvas.drawCircle(c, 8, Paint()..color = const Color(0xFF1F5C99));
    canvas.drawCircle(
      c,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.radius != radius;
}

class _PlaceSheet extends ConsumerStatefulWidget {
  final NearbyPlace n;
  final LocationFix? fix;
  final VoidCallback onReported;
  const _PlaceSheet({required this.n, required this.fix, required this.onReported});

  @override
  ConsumerState<_PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends ConsumerState<_PlaceSheet> {
  bool? _followed;

  @override
  void initState() {
    super.initState();
    final slug = widget.n.place.mosqueSlug;
    if (slug != null) {
      ref.read(favoriteMosqueRepoProvider).all().then((l) {
        if (mounted) setState(() => _followed = l.any((m) => m.slug == slug));
      });
    }
  }

  Future<void> _report(Map<String, dynamic> data) async {
    try {
      await ref.read(masjidApiProvider).reportDirectory({'directory_id': widget.n.place.id, ...data});
      if (!mounted) return;
      Navigator.pop(context);
      widget.onReported();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  Future<void> _wrongName() async {
    final c = TextEditingController(text: widget.n.place.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nama yang benar'),
        content: TextField(key: const Key('correct-name'), controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Kirim')),
        ],
      ),
    );
    if (name != null && name.length >= 3) await _report({'type': 'wrong_name', 'name': name});
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.n;
    final p = n.place;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(p.name, style: Theme.of(context).textTheme.titleLarge)),
              if (p.verified) const _VerifiedBadge(),
            ],
          ),
          Text(
            '${p.isMusala ? 'Musala' : 'Masjid'} • ${formatDistanceId(n.distanceM)} ke arah ${compassPointId(n.bearing)}',
          ),
          if (p.address != null || p.city != null) Text([p.address, p.city].whereType<String>().join(', ')),
          if (p.verified)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Lokasi & nama dikonfirmasi pengurus masjid. Agenda kajian dan pengumumannya dapat diikuti.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const Key('place-route'),
                  onPressed: () => ref.read(mapLauncherProvider)(p),
                  icon: const Icon(Icons.directions),
                  label: const Text('Rute'),
                ),
              ),
              if (p.mosqueSlug != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('place-follow'),
                    onPressed: _followed == true
                        ? null
                        : () async {
                            await ref
                                .read(favoriteMosqueRepoProvider)
                                .follow(FollowedMosque(slug: p.mosqueSlug!, name: p.name));
                            setState(() => _followed = true);
                          },
                    icon: Icon(_followed == true ? Icons.check : Icons.add),
                    label: Text(_followed == true ? 'Diikuti' : 'Ikuti'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Text('Ada yang keliru?', style: TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 6,
            children: [
              ActionChip(
                key: const Key('report-location'),
                avatar: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: const Text('Lokasi salah'),
                onPressed: widget.fix == null
                    ? () => showSnack(context, 'Aktifkan GPS dan berdirilah di masjid ini untuk mengoreksi lokasinya.')
                    : () => _report({
                        'type': 'wrong_location',
                        'latitude': widget.fix!.latitude,
                        'longitude': widget.fix!.longitude,
                        'note': 'Pelapor berada di lokasi (±${widget.fix!.accuracyM.round()} m)',
                      }),
              ),
              ActionChip(
                key: const Key('report-name'),
                avatar: const Icon(Icons.drive_file_rename_outline, size: 18),
                label: const Text('Nama salah'),
                onPressed: _wrongName,
              ),
              ActionChip(
                key: const Key('report-missing'),
                avatar: const Icon(Icons.wrong_location_outlined, size: 18),
                label: const Text('Tidak ada'),
                onPressed: () => _report({'type': 'not_exists'}),
              ),
            ],
          ),
          if (widget.fix != null)
            const Text(
              'Koreksi lokasi memakai posisi GPS Anda saat ini, jadi kirim saat Anda berada di masjid.',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
