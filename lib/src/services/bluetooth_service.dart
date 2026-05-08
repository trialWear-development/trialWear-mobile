import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import '../models/ble_geo_data.dart';

class BluetoothService {
  static const String targetName = 'TrialWear_000';

  static final Guid requestUuid = Guid('0000fe41-8e22-4541-9d4c-21edae82ed19');

  static final Guid geoUuid = Guid('0000fe43-8e22-4541-9d4c-21edae82ed19');

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _requestCharacteristic;
  BluetoothCharacteristic? _geoCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _geoSubscription;

  final StreamController<BleGeoData> _geoDataController =
      StreamController<BleGeoData>.broadcast();

  Stream<BleGeoData> get geoDataStream => _geoDataController.stream;

  Future<void> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      throw Exception('Bluetooth permissions are required.');
    }
  }

  Future<BluetoothDevice?> scanAndConnect({
    Duration scanTimeout = const Duration(seconds: 12),
  }) async {
    await requestPermissions();

    final isSupported = await FlutterBluePlus.isSupported;

    if (!isSupported) {
      throw Exception('Bluetooth is not supported on this device.');
    }

    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      throw Exception('Bluetooth is turned off.');
    }

    await FlutterBluePlus.stopScan();

    BluetoothDevice? foundDevice;
    final completer = Completer<BluetoothDevice?>();

    _scanSubscription?.cancel();

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (final result in results) {
        final deviceName = result.device.platformName;

        debugPrint('Found device: $deviceName');

        if (deviceName == targetName) {
          debugPrint('Target device found: $deviceName');

          foundDevice = result.device;

          if (!completer.isCompleted) {
            completer.complete(foundDevice);
          }

          break;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: scanTimeout);

    foundDevice = await completer.future.timeout(
      scanTimeout,
      onTimeout: () => null,
    );

    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    if (foundDevice == null) {
      return null;
    }

    await _connectToDevice(foundDevice!);
    return foundDevice;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;

    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 12),
      autoConnect: false,
    );

    final services = await device.discoverServices();

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == requestUuid) {
          _requestCharacteristic = characteristic;
        }

        if (characteristic.uuid == geoUuid) {
          _geoCharacteristic = characteristic;
        }
      }
    }

    if (_requestCharacteristic == null) {
      throw Exception('REQUEST_UUID characteristic not found.');
    }

    if (_geoCharacteristic == null) {
      throw Exception('GEO_UUID characteristic not found.');
    }

    await _startGeoNotification();
  }

  Future<void> _startGeoNotification() async {
    final geoChar = _geoCharacteristic;

    if (geoChar == null) {
      throw Exception('Geo characteristic is not available.');
    }

    await geoChar.setNotifyValue(true);

    await _geoSubscription?.cancel();

    _geoSubscription = geoChar.onValueReceived.listen((value) {
      final rawString = utf8.decode(value, allowMalformed: true).trim();

      if (rawString.isEmpty) return;

      try {
        final geoData = BleGeoData.fromRawString(rawString);
        _geoDataController.add(geoData);
      } catch (e) {
        debugPrint('Failed to parse BLE geo data: $rawString');
      }
    });
  }

  Future<void> requestGeoData({bool toggleValue = true}) async {
    final requestChar = _requestCharacteristic;

    if (requestChar == null) {
      throw Exception('Request characteristic is not available.');
    }

    final value = toggleValue ? 0 : 1;

    await requestChar.write([value], withoutResponse: true);
  }

  Future<void> disconnect() async {
    await _geoSubscription?.cancel();
    await _connectedDevice?.disconnect();

    _connectedDevice = null;
    _requestCharacteristic = null;
    _geoCharacteristic = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _geoDataController.close();
  }
}
