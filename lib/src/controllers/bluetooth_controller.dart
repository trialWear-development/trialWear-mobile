import 'dart:async';

import 'package:flutter/material.dart';

import '../models/ble_geo_data.dart';
import '../services/bluetooth_service.dart';

class BluetoothController extends ChangeNotifier {
  final BluetoothService _bluetoothService;

  bool isScanning = false;
  bool isConnected = false;
  bool isRequesting = false;

  String statusMessage = 'Bluetooth not connected';
  BleGeoData? latestGeoData;

  StreamSubscription<BleGeoData>? _geoSubscription;
  bool _toggleRequest = true;

  BluetoothController(this._bluetoothService) {
    _listenToGeoData();
  }

  void _listenToGeoData() {
    _geoSubscription = _bluetoothService.geoDataStream.listen((data) {
      latestGeoData = data;
      statusMessage = 'Geo data received';
      notifyListeners();
    });
  }

  Future<void> scanAndConnect() async {
    try {
      isScanning = true;
      statusMessage = 'Scanning for TrialWear_000...';
      notifyListeners();

      final device = await _bluetoothService.scanAndConnect();

      isScanning = false;

      if (device == null) {
        isConnected = false;
        statusMessage = 'TrialWear_000 not found';
      } else {
        isConnected = true;
        statusMessage = 'Connected to ${device.platformName}';
      }

      notifyListeners();
    } catch (e) {
      isScanning = false;
      isConnected = false;
      statusMessage = 'Bluetooth error: $e';
      notifyListeners();
    }
  }

  Future<void> requestGeoData() async {
    try {
      isRequesting = true;
      statusMessage = 'Requesting geo data...';
      notifyListeners();

      await _bluetoothService.requestGeoData(toggleValue: _toggleRequest);

      _toggleRequest = !_toggleRequest;

      isRequesting = false;
      statusMessage = 'Request sent. Waiting for notification...';
      notifyListeners();
    } catch (e) {
      isRequesting = false;
      statusMessage = 'Request failed: $e';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _bluetoothService.disconnect();

    isConnected = false;
    statusMessage = 'Bluetooth disconnected';
    notifyListeners();
  }

  @override
  void dispose() {
    _geoSubscription?.cancel();
    unawaited(_bluetoothService.dispose());
    super.dispose();
  }
}
