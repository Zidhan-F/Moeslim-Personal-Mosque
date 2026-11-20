import 'package:shared_prayer/shared_prayer.dart';

/// Lokasi untuk perhitungan jadwal (dipilih manual bila izin lokasi ditolak).
class City {
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final double utcOffset;

  const City(this.name, this.province, this.latitude, this.longitude, this.utcOffset);

  Coordinates get coordinates => Coordinates(latitude, longitude);

  String get zone => switch (utcOffset) { 7.0 => 'WIB', 8.0 => 'WITA', 9.0 => 'WIT', _ => 'UTC+$utcOffset' };

  Map<String, Object> toJson() =>
      {'name': name, 'province': province, 'lat': latitude, 'lng': longitude, 'tz': utcOffset};

  factory City.fromJson(Map<String, dynamic> j) => City(j['name'] as String, j['province'] as String,
      (j['lat'] as num).toDouble(), (j['lng'] as num).toDouble(), (j['tz'] as num).toDouble());
}

const List<City> indonesianCities = [
  City('Banda Aceh', 'Aceh', 5.5483, 95.3238, 7),
  City('Medan', 'Sumatera Utara', 3.5952, 98.6722, 7),
  City('Padang', 'Sumatera Barat', -0.9471, 100.4172, 7),
  City('Pekanbaru', 'Riau', 0.5071, 101.4478, 7),
  City('Batam', 'Kepulauan Riau', 1.0456, 104.0305, 7),
  City('Jambi', 'Jambi', -1.6101, 103.6131, 7),
  City('Palembang', 'Sumatera Selatan', -2.9761, 104.7754, 7),
  City('Bengkulu', 'Bengkulu', -3.7928, 102.2608, 7),
  City('Bandar Lampung', 'Lampung', -5.3971, 105.2668, 7),
  City('Pangkalpinang', 'Kepulauan Bangka Belitung', -2.1316, 106.1169, 7),
  City('Serang', 'Banten', -6.1200, 106.1503, 7),
  City('Tangerang', 'Banten', -6.1783, 106.6319, 7),
  City('Jakarta', 'DKI Jakarta', -6.1754, 106.8272, 7),
  City('Bogor', 'Jawa Barat', -6.5971, 106.8060, 7),
  City('Bekasi', 'Jawa Barat', -6.2383, 106.9756, 7),
  City('Bandung', 'Jawa Barat', -6.9175, 107.6191, 7),
  City('Cirebon', 'Jawa Barat', -6.7320, 108.5523, 7),
  City('Semarang', 'Jawa Tengah', -6.9667, 110.4167, 7),
  City('Surakarta', 'Jawa Tengah', -7.5755, 110.8243, 7),
  City('Yogyakarta', 'DI Yogyakarta', -7.7956, 110.3695, 7),
  City('Surabaya', 'Jawa Timur', -7.2575, 112.7521, 7),
  City('Malang', 'Jawa Timur', -7.9666, 112.6326, 7),
  City('Pontianak', 'Kalimantan Barat', -0.0263, 109.3425, 7),
  City('Palangka Raya', 'Kalimantan Tengah', -2.2161, 113.9135, 7),
  City('Denpasar', 'Bali', -8.6705, 115.2126, 8),
  City('Mataram', 'Nusa Tenggara Barat', -8.5833, 116.1167, 8),
  City('Kupang', 'Nusa Tenggara Timur', -10.1772, 123.6070, 8),
  City('Banjarmasin', 'Kalimantan Selatan', -3.3186, 114.5944, 8),
  City('Samarinda', 'Kalimantan Timur', -0.5022, 117.1536, 8),
  City('Balikpapan', 'Kalimantan Timur', -1.2379, 116.8529, 8),
  City('Tanjung Selor', 'Kalimantan Utara', 2.8375, 117.3653, 8),
  City('Makassar', 'Sulawesi Selatan', -5.1477, 119.4327, 8),
  City('Palu', 'Sulawesi Tengah', -0.8917, 119.8707, 8),
  City('Kendari', 'Sulawesi Tenggara', -3.9985, 122.5129, 8),
  City('Gorontalo', 'Gorontalo', 0.5435, 123.0568, 8),
  City('Manado', 'Sulawesi Utara', 1.4748, 124.8421, 8),
  City('Mamuju', 'Sulawesi Barat', -2.6748, 118.8885, 8),
  City('Ambon', 'Maluku', -3.6954, 128.1814, 9),
  City('Ternate', 'Maluku Utara', 0.7893, 127.3842, 9),
  City('Sorong', 'Papua Barat Daya', -0.8762, 131.2558, 9),
  City('Manokwari', 'Papua Barat', -0.8615, 134.0620, 9),
  City('Jayapura', 'Papua', -2.5337, 140.7181, 9),
  City('Merauke', 'Papua Selatan', -8.4932, 140.4018, 9),
];
