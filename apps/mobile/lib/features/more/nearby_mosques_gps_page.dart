import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';

class NearbyMosquesGpsPage extends ConsumerStatefulWidget {
  const NearbyMosquesGpsPage({super.key});

  @override
  ConsumerState<NearbyMosquesGpsPage> createState() => _NearbyMosquesGpsPageState();
}

class _NearbyMosquesGpsPageState extends ConsumerState<NearbyMosquesGpsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  List<NearbyMosqueItem> _allMosques = const [];
  bool _loading = true;
  bool _offline = false;
  String _source = 'OpenStreetMap';
  String? _loadedKey;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Memuat masjid sekitar titik acuan dari OpenStreetMap; bila gagal, memakai daftar bawaan.
  Future<void> _load() async {
    final origin = (ref.read(settingsProvider).value ?? PersonalSettings.defaults).effectiveCoordinates;
    final key = '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}';
    _loadedKey = key;
    setState(() => _loading = true);
    final repo = ref.read(nearbyMosqueRepoProvider);
    final custom = await repo.savedCustomMosques();
    List<NearbyMosqueItem> online = const [];
    var offline = false;
    var source = 'OpenStreetMap';
    final google = ref.read(googleMosqueFinderProvider);
    if (google.enabled) {
      try {
        online = await google.search(origin);
        source = 'Google Maps';
      } catch (_) {}
    }
    if (online.isEmpty) {
      try {
        online = await ref.read(onlineMosqueFinderProvider).search(origin);
        source = 'OpenStreetMap';
      } catch (_) {
        offline = true;
      }
    }
    if (!mounted || _loadedKey != key) return;
    setState(() {
      _allMosques = [...custom, ...(offline || online.isEmpty ? defaultIndonesianMosqueDirectory : online)];
      _offline = offline;
      _source = source;
      _loading = false;
    });
  }

  Future<void> _openGoogleMaps({NearbyMosqueItem? mosque}) async {
    final o = (ref.read(settingsProvider).value ?? PersonalSettings.defaults).effectiveCoordinates;
    final uri = mosque == null
        ? Uri.parse('https://www.google.com/maps/search/masjid/@${o.latitude},${o.longitude},15z')
        : Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka Google Maps.')));
    }
  }

  Future<void> _reloadCustom() => _load();

  Future<void> _showAddMosqueDialog(BuildContext context, PersonalSettings settings) async {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final coords = settings.effectiveCoordinates;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Catat Masjid / Musholla Sekitar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('add-nearby-mosque-name'),
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Masjid / Musholla'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(labelText: 'Alamat / Patokan Lokasi'),
            ),
            const SizedBox(height: 8),
            Text(
              'Koordinat GPS aktif: ${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}',
              style: Theme.of(dialogCtx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Batal')),
          FilledButton(
            key: const Key('save-nearby-mosque-btn'),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty) {
      await ref.read(nearbyMosqueRepoProvider).addCustomMosque(
            NearbyMosqueItem(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: nameCtrl.text.trim(),
              kind: 'Masjid / Musholla Sekitar',
              address: addrCtrl.text.trim().isEmpty ? settings.effectiveLocationName : addrCtrl.text.trim(),
              latitude: coords.latitude,
              longitude: coords.longitude,
            ),
          );
      await _reloadCustom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? PersonalSettings.defaults;
    final origin = settings.effectiveCoordinates;
    final originKey = '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}';
    if (_loadedKey != originKey) {
      _loadedKey = originKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
    final ranked = rankMosquesByDistance(origin, _allMosques).where((r) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return r.mosque.name.toLowerCase().contains(q) ||
          r.mosque.address.toLowerCase().contains(q) ||
          r.mosque.kind.toLowerCase().contains(q);
    }).toList();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencari Masjid Terdekat (GPS)'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('add-custom-nearby-mosque'),
            tooltip: 'Simpan titik masjid/musholla di posisi GPS saat ini',
            onPressed: () => _showAddMosqueDialog(context, settings),
            icon: const Icon(MoeslimIcons.tambahLingkar),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(MoeslimIcons.lokasi, color: scheme.primary),
                    title: Text('Titik Acuan: ${settings.effectiveLocationName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      'Koordinat: ${origin.latitude.toStringAsFixed(4)}, ${origin.longitude.toStringAsFixed(4)} '
                      '(${settings.isUsingGpsLocation ? 'GPS Aktif' : 'Kota Terpilih'})',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('nearby-mosque-search'),
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(MoeslimIcons.pencarian),
                    hintText: 'Cari masjid atau kota (mis. Istiqlal, Bandung, Al-Azhar)',
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('open-google-maps'),
                  onPressed: _openGoogleMaps,
                  icon: const Icon(MoeslimIcons.lokasi, size: 18),
                  label: const Text('Cari masjid di Google Maps'),
                ),
                if (!_loading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _offline
                                ? 'Tidak ada internet: menampilkan daftar bawaan, bukan masjid di sekitar Anda.'
                                : 'Masjid & musholla dalam radius 5 km (data $_source).',
                            key: const Key('nearby-source-note'),
                            style: t.bodySmall,
                          ),
                        ),
                        if (_offline)
                          TextButton(
                            key: const Key('nearby-retry'),
                            onPressed: _load,
                            child: const Text('Coba lagi'),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ranked.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(MoeslimIcons.masjid, size: 32, color: scheme.primary),
                            const SizedBox(height: 8),
                            Text('Masjid tidak ditemukan', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset pencarian'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: ranked.length,
                        itemBuilder: (context, index) {
                          final r = ranked[index];
                          final m = r.mosque;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(MoeslimIcons.masjid, color: scheme.primary),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.name, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                            Text(m.kind, style: t.bodySmall?.copyWith(color: scheme.primary)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withValues(alpha: .1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${r.formattedDistance} · ${r.cardinalDirection}',
                                          style: TextStyle(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(m.address, style: t.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text('Fasilitas: ${m.facilities}', style: t.bodySmall),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _openGoogleMaps(mosque: m),
                                        icon: const Icon(Icons.directions_outlined, size: 18),
                                        label: const Text('Rute di Google Maps'),
                                      ),
                                      OutlinedButton.icon(
                                      onPressed: () {
                                        final mapsUri = 'https://www.google.com/maps/dir/?api=1&destination=${m.latitude},${m.longitude}';
                                        Clipboard.setData(ClipboardData(text: '${m.name} (${m.address}) - $mapsUri'));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Tautan koordinat peta ${m.name} disalin.')),
                                        );
                                      },
                                      icon: const Icon(MoeslimIcons.lokasi, size: 16),
                                      label: const Text('Salin Rute Peta'),
                                    ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
