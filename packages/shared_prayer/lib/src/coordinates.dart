/// Koordinat geografis dalam derajat desimal.
class Coordinates {
  final double latitude;
  final double longitude;

  const Coordinates(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90),
        assert(longitude >= -180 && longitude <= 180);

  @override
  String toString() => 'Coordinates($latitude, $longitude)';
}
