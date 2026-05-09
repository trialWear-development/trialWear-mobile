import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BleGeoMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const BleGeoMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<BleGeoMapScreen> createState() => _BleGeoMapScreenState();
}

class _BleGeoMapScreenState extends State<BleGeoMapScreen> {
  bool _locationPermissionGranted = false;

  bool get _isGoogleMapSupported {
    if (kIsWeb) return true;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();

    if (_isGoogleMapSupported) {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) return;

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _locationPermissionGranted = true;
      });
    }
  }

  Future<void> _openMapInBrowser() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final bleLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('GIS Activity Map')),
      body: _isGoogleMapSupported
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: bleLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('trialwear_ble_location'),
                  position: bleLocation,
                  infoWindow: const InfoWindow(
                    title: 'Latest TrialWear Location',
                  ),
                ),
              },
              myLocationEnabled: _locationPermissionGranted,
              myLocationButtonEnabled: _locationPermissionGranted,
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Map preview is not supported on Linux desktop.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _openMapInBrowser,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open in Google Maps'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
