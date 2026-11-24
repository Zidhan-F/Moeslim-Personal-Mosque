import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moeslim_brand/material_3d.dart';
import 'package:moeslim_brand/moeslim_brand.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../core/location_service.dart';
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

  static String _localizeCardinal(String dir, AppLanguage lang) {
    if (lang != AppLanguage.en) return dir;
    return switch (dir) {
      'Utara' => 'North',
      'Timur Laut' => 'Northeast',
      'Timur' => 'East',
      'Tenggara' => 'Southeast',
      'Selatan' => 'South',
      'Barat Daya' => 'Southwest',
      'Barat' => 'West',
      'Barat Laut' => 'Northwest',
      _ => dir,
    };
  }

  static String _localizeMosqueKind(String kind, AppLanguage lang) {
    if (lang != AppLanguage.en) return kind;
    return switch (kind) {
      'Masjid' => 'Mosque',
      'Musholla' => 'Prayer Room',
      'Masjid Negara' => 'National Mosque',
      'Masjid Agung' => 'Grand Mosque',
      'Masjid Raya' => 'Great Mosque',
      'Masjid Pusat Dakwah' => 'Islamic Center Mosque',
      'Masjid Nasional' => 'National Mosque',
      'Masjid Bersejarah' => 'Historic Mosque',
      'Masjid / Musholla Sekitar' => 'Saved Mosque / Prayer Room',
      _ => kind,
    };
  }

  static String _localizeFacilities(String facilities, AppLanguage lang) {
    if (lang != AppLanguage.en) return facilities;
    const map = <String, String>{
      'Tempat Wudhu Tradisional': 'Traditional Wudu Area',
      'Tempat Wudhu': 'Wudu Area',
      'Ruang Salat Utama': 'Main Prayer Hall',
      'Parkir Luas': 'Spacious Parking',
      'Parkir Basement': 'Basement Parking',
      'Basement Parkir & Wudhu': 'Basement Parking & Wudu',
      'Parkir': 'Parking',
      'Perpustakaan Islam': 'Islamic Library',
      'Perpustakaan': 'Library',
      'Akses Disabilitas': 'Wheelchair Access',
      'Air Wudhu Siap': 'Wudu Facilities',
      'Air Minum': 'Drinking Water',
      'Toilet': 'Restrooms',
      'Kajian Rutin': 'Regular Lectures',
      "Kajian Ba'da Salat": 'Post-Prayer Lectures',
      'Kajian': 'Lectures',
      'Aula': 'Hall',
      'Ruang Ber-AC': 'Air-Conditioned Hall',
      'Alun-Alun': 'City Square',
      'Menara Pandang': 'Observation Tower',
      'Menara': 'Minaret',
      'Poliklinik': 'Clinic',
      'Serambi Kajian': 'Study Veranda',
      'Payung Elektrik': 'Retractable Umbrellas',
      'Belum ada data fasilitas': 'No facility data yet',
      'Dari Google Maps': 'From Google Maps',
    };
    return facilities
        .split(', ')
        .map((part) => map[part.trim()] ?? part.trim())
        .join(', ');
  }

  /// Memuat masjid sekitar titik acuan dari OpenStreetMap; bila gagal, memakai daftar bawaan.
  Future<void> _load({bool forceRefresh = false}) async {
    final origin = (ref.read(settingsProvider).value ?? PersonalSettings.defaults).effectiveCoordinates;
    final lang = ref.read(appLanguageProvider);
    final key = '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}_${lang.code}';
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
        online = await google.search(origin, lang: lang);
        source = 'Google Maps';
      } catch (_) {}
    }
    if (online.isEmpty) {
      try {
        online = await ref.read(onlineMosqueFinderProvider).search(
              origin,
              lang: lang,
              forceRefresh: forceRefresh,
            );
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

  Future<void> _refreshGpsLocation() async {
    final locSvc = ref.read(locationServiceProvider);
    final current = ref.read(settingsProvider).value ?? PersonalSettings.defaults;
    try {
      final enabled = await locSvc.isServiceEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('Aktifkan GPS perangkat terlebih dahulu.', 'Please enable device GPS first.'))),
          );
        }
        return;
      }
      var perm = await locSvc.checkPermission();
      if (perm == LocationPermissionState.denied) {
        perm = await locSvc.requestPermission();
      }
      if (perm != LocationPermissionState.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('Izin lokasi belum diberikan.', 'Location permission not granted.'))),
          );
        }
        return;
      }
      final pos = await locSvc.getCurrentPosition();
      final nearest = nearestIndonesianCity(Coordinates(pos.latitude, pos.longitude));
      await ref.read(settingsProvider.notifier).save(
            current.copyWith(
              useDeviceLocation: true,
              deviceLocation: DeviceLocation(
                latitude: pos.latitude,
                longitude: pos.longitude,
                utcOffset: DateTime.now().timeZoneOffset.inMinutes / 60.0,
                label: nearest != null ? 'Sekitar ${nearest.city.name}' : 'Lokasi GPS',
                accuracyMeters: pos.accuracyMeters,
                updatedAt: pos.timestamp,
              ),
            ),
          );
      await _load(forceRefresh: true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Gagal membaca koordinat GPS saat ini.', 'Failed to read current GPS coordinates.'))),
        );
      }
    }
  }

  Future<void> _openGoogleMaps({NearbyMosqueItem? mosque}) async {
    final o = (ref.read(settingsProvider).value ?? PersonalSettings.defaults).effectiveCoordinates;
    final queryTerm = ref.read(appLanguageProvider) == AppLanguage.en ? 'mosque' : 'masjid';
    final uri = mosque == null
        ? Uri.parse('https://www.google.com/maps/search/$queryTerm/@${o.latitude},${o.longitude},15z')
        : Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Tidak bisa membuka Google Maps.', 'Could not open Google Maps.')),
        ),
      );
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
        title: Text(dialogCtx.tr('Catat Masjid / Musholla Sekitar', 'Save Nearby Mosque / Prayer Room')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('add-nearby-mosque-name'),
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: dialogCtx.tr('Nama Masjid / Musholla', 'Mosque / Prayer Room Name'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addrCtrl,
              decoration: InputDecoration(
                labelText: dialogCtx.tr('Alamat / Patokan Lokasi', 'Address / Landmark'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dialogCtx.tr(
                'Koordinat GPS aktif: ${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}',
                'Active GPS coordinates: ${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}',
              ),
              style: Theme.of(dialogCtx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(dialogCtx.tr('Batal', 'Cancel')),
          ),
          FilledButton(
            key: const Key('save-nearby-mosque-btn'),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(dialogCtx.tr('Simpan', 'Save')),
          ),
        ],
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty) {
      final lang = ref.read(appLanguageProvider);
      await ref.read(nearbyMosqueRepoProvider).addCustomMosque(
            NearbyMosqueItem(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: nameCtrl.text.trim(),
              kind: lang == AppLanguage.en ? 'Saved Mosque / Prayer Room' : 'Masjid / Musholla Sekitar',
              address: addrCtrl.text.trim().isEmpty
                  ? localizeLocationLabel(settings.effectiveLocationName, lang)
                  : addrCtrl.text.trim(),
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
    final lang = context.lang;
    final origin = settings.effectiveCoordinates;
    final originKey = '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}_${lang.code}';
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
          r.mosque.kind.toLowerCase().contains(q) ||
          _localizeMosqueKind(r.mosque.kind, lang).toLowerCase().contains(q);
    }).toList();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locName = localizeLocationLabel(settings.effectiveLocationName, lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Pencari Masjid Terdekat (GPS)', 'Nearby Mosque Finder (GPS)')),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('add-custom-nearby-mosque'),
            tooltip: context.tr(
              'Simpan titik masjid/musholla di posisi GPS saat ini',
              'Save a mosque or prayer room at your current GPS position',
            ),
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
                    title: Text(
                      context.tr('Titik Acuan: $locName', 'Reference Point: $locName'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      context.tr(
                        'Koordinat: ${origin.latitude.toStringAsFixed(4)}, ${origin.longitude.toStringAsFixed(4)} '
                            '(${settings.isUsingGpsLocation ? 'GPS Aktif' : 'Kota Terpilih'})',
                        'Coordinates: ${origin.latitude.toStringAsFixed(4)}, ${origin.longitude.toStringAsFixed(4)} '
                            '(${settings.isUsingGpsLocation ? 'GPS Active' : 'Selected City'})',
                      ),
                    ),
                    trailing: IconButton(
                      key: const Key('nearby-refresh-gps'),
                      tooltip: context.tr('Perbarui titik GPS saat ini', 'Update current GPS location'),
                      onPressed: _loading ? null : _refreshGpsLocation,
                      icon: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('nearby-mosque-search'),
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(MoeslimIcons.pencarian),
                    hintText: context.tr(
                      'Cari masjid atau kota (mis. Istiqlal, Bandung, Al-Azhar)',
                      'Search mosque or city (e.g. Istiqlal, Bandung, Al-Azhar)',
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: context.tr('Hapus pencarian', 'Clear search'),
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
                  label: Text(context.tr('Cari masjid di Google Maps', 'Search mosques in Google Maps')),
                ),
                if (!_loading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _offline
                                ? context.tr(
                                    'Peta online belum terjangkau: menampilkan daftar bawaan. Ketuk Coba lagi atau buka Google Maps.',
                                    'Online map unavailable: showing built-in directory. Tap Retry or open Google Maps.',
                                  )
                                : context.tr(
                                    'Menampilkan ${ranked.length} masjid & musholla terdekat (data $_source).',
                                    'Showing ${ranked.length} nearby mosques & prayer rooms (data from $_source).',
                                  ),
                            key: const Key('nearby-source-note'),
                            style: t.bodySmall,
                          ),
                        ),
                        TextButton(
                          key: const Key('nearby-retry'),
                          onPressed: () => _load(forceRefresh: true),
                          child: Text(
                            _offline ? context.tr('Coba lagi', 'Retry') : context.tr('Muat ulang', 'Refresh'),
                          ),
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
                            Text(
                              context.tr('Masjid tidak ditemukan', 'No mosques found'),
                              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(context.tr('Reset pencarian', 'Reset search')),
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
                                            Text(
                                              _localizeMosqueKind(m.kind, lang),
                                              style: t.bodySmall?.copyWith(color: scheme.primary),
                                            ),
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
                                          '${r.formattedDistance} · ${_localizeCardinal(r.cardinalDirection, lang)}',
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
                                  Text(
                                    context.tr(
                                      'Fasilitas: ${m.facilities}',
                                      'Facilities: ${_localizeFacilities(m.facilities, lang)}',
                                    ),
                                    style: t.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _openGoogleMaps(mosque: m),
                                        icon: const Icon(Icons.directions_outlined, size: 18),
                                        label: Text(context.tr('Rute di Google Maps', 'Directions in Google Maps')),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final mapsUri =
                                              'https://www.google.com/maps/dir/?api=1&destination=${m.latitude},${m.longitude}';
                                          Clipboard.setData(ClipboardData(text: '${m.name} (${m.address}) - $mapsUri'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                context.tr(
                                                  'Tautan koordinat peta ${m.name} disalin.',
                                                  'Map link for ${m.name} copied.',
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(MoeslimIcons.lokasi, size: 16),
                                        label: Text(context.tr('Salin Rute Peta', 'Copy Map Link')),
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
