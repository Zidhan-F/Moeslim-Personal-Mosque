import '../storage/key_value_store.dart';

enum HomeWidgetStyle {
  compactPrayer('Ringkas (Salat Berikutnya)', 'Menampilkan waktu salat berikutnya, hitung mundur, dan lokasi.'),
  prayerAndQuote('Salat & Doa/Ayat Harian', 'Menampilkan jadwal salat berikutnya beserta kutipan ayat atau doa harian.'),
  fullFiveTimes('5 Waktu Salat Lengkap', 'Menampilkan barisan Subuh, Dzuhur, Ashar, Maghrib, dan Isya hari ini.');

  final String label;
  final String description;
  const HomeWidgetStyle(this.label, this.description);
}

class HomeWidgetConfig {
  final HomeWidgetStyle style;
  final bool showHijriDate;
  final bool showLocation;
  final bool darkSurface;
  final String lastSyncedNextPrayer;
  final String lastSyncedNextTime;
  final String lastSyncedLocation;
  final String lastSyncedHijri;
  final String lastSyncedQuote;

  const HomeWidgetConfig({
    this.style = HomeWidgetStyle.prayerAndQuote,
    this.showHijriDate = true,
    this.showLocation = true,
    this.darkSurface = true,
    this.lastSyncedNextPrayer = 'Subuh',
    this.lastSyncedNextTime = '04:38',
    this.lastSyncedLocation = 'Jakarta',
    this.lastSyncedHijri = '1447 H',
    this.lastSyncedQuote = 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram. (QS. Ar-Ra\'d: 28)',
  });

  HomeWidgetConfig copyWith({
    HomeWidgetStyle? style,
    bool? showHijriDate,
    bool? showLocation,
    bool? darkSurface,
    String? lastSyncedNextPrayer,
    String? lastSyncedNextTime,
    String? lastSyncedLocation,
    String? lastSyncedHijri,
    String? lastSyncedQuote,
  }) =>
      HomeWidgetConfig(
        style: style ?? this.style,
        showHijriDate: showHijriDate ?? this.showHijriDate,
        showLocation: showLocation ?? this.showLocation,
        darkSurface: darkSurface ?? this.darkSurface,
        lastSyncedNextPrayer: lastSyncedNextPrayer ?? this.lastSyncedNextPrayer,
        lastSyncedNextTime: lastSyncedNextTime ?? this.lastSyncedNextTime,
        lastSyncedLocation: lastSyncedLocation ?? this.lastSyncedLocation,
        lastSyncedHijri: lastSyncedHijri ?? this.lastSyncedHijri,
        lastSyncedQuote: lastSyncedQuote ?? this.lastSyncedQuote,
      );

  Map<String, Object> toJson() => {
        'style': style.name,
        'showHijriDate': showHijriDate,
        'showLocation': showLocation,
        'darkSurface': darkSurface,
        'lastSyncedNextPrayer': lastSyncedNextPrayer,
        'lastSyncedNextTime': lastSyncedNextTime,
        'lastSyncedLocation': lastSyncedLocation,
        'lastSyncedHijri': lastSyncedHijri,
        'lastSyncedQuote': lastSyncedQuote,
      };

  factory HomeWidgetConfig.fromJson(Map<String, dynamic> j) {
    final sName = j['style'] as String?;
    final st = HomeWidgetStyle.values.where((e) => e.name == sName).firstOrNull ?? HomeWidgetStyle.prayerAndQuote;
    return HomeWidgetConfig(
      style: st,
      showHijriDate: j['showHijriDate'] as bool? ?? true,
      showLocation: j['showLocation'] as bool? ?? true,
      darkSurface: j['darkSurface'] as bool? ?? true,
      lastSyncedNextPrayer: j['lastSyncedNextPrayer'] as String? ?? 'Subuh',
      lastSyncedNextTime: j['lastSyncedNextTime'] as String? ?? '04:38',
      lastSyncedLocation: j['lastSyncedLocation'] as String? ?? 'Jakarta',
      lastSyncedHijri: j['lastSyncedHijri'] as String? ?? '1447 H',
      lastSyncedQuote: j['lastSyncedQuote'] as String? ??
          'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram. (QS. Ar-Ra\'d: 28)',
    );
  }
}

class HomeWidgetRepository {
  static const storageKey = 'home_widget_payload';
  final KeyValueStore _store;

  const HomeWidgetRepository(this._store);

  Future<HomeWidgetConfig> load() async {
    final raw = await _store.readJson(storageKey);
    if (raw is! Map) return const HomeWidgetConfig();
    return HomeWidgetConfig.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<HomeWidgetConfig> save(HomeWidgetConfig config) async {
    await _store.writeJson(storageKey, config.toJson());
    return config;
  }
}
