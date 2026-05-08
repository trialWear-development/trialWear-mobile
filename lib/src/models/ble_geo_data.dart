class BleGeoData {
  final double latitude;
  final double longitude;
  final double speed;
  final String zone;
  final String raw;
  final DateTime receivedAt;

  BleGeoData({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.zone,
    required this.raw,
    required this.receivedAt,
  });

  factory BleGeoData.fromRawString(String raw) {
    final cleaned = raw.trim();

    // Supports both:
    // "45.12345 -111.12345 0.35000 INSIDE"
    // "45.12345,-111.12345,0.35000,INSIDE"
    final parts = cleaned.split(RegExp(r'[\s,]+'));

    if (parts.length < 4) {
      throw FormatException('Invalid BLE geo data format: $raw');
    }

    return BleGeoData(
      latitude: double.parse(parts[0]),
      longitude: double.parse(parts[1]),
      speed: double.parse(parts[2]),
      zone: parts.sublist(3).join(' '),
      raw: raw,
      receivedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Lat: $latitude, Lon: $longitude, Speed: $speed, Zone: $zone';
  }
}
