import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/bluetooth_controller.dart';
import 'ble_geo_map_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String deviceId;

  const DashboardScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final patientController = context.watch<PatientController>();
    final bluetoothController = context.watch<BluetoothController>();

    final patient = patientController.patient;
    final geoData = bluetoothController.latestGeoData;

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - $deviceId')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _sectionCard(
                  context,
                  title: 'Device Connection Status',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            bluetoothController.isConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: bluetoothController.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bluetoothController.statusMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      AppConstants.verticalGap12,
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: bluetoothController.isScanning
                                  ? null
                                  : bluetoothController.scanAndConnect,
                              child: bluetoothController.isScanning
                                  ? const Text('Scanning...')
                                  : const Text('Scan & Connect'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: bluetoothController.isConnected
                                  ? bluetoothController.disconnect
                                  : null,
                              child: const Text('Disconnect'),
                            ),
                          ),
                        ],
                      ),
                      AppConstants.verticalGap12,
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed:
                              bluetoothController.mockConnectAndReceiveData,
                          child: const Text('Use Mock BLE Data'),
                        ),
                      ),
                      AppConstants.verticalGap12,
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              bluetoothController.isConnected &&
                                  !bluetoothController.isRequesting
                              ? bluetoothController.requestGeoData
                              : null,
                          child: bluetoothController.isRequesting
                              ? const Text('Requesting...')
                              : const Text('Request Geo Data'),
                        ),
                      ),
                    ],
                  ),
                ),

                _sectionCard(
                  context,
                  title: 'Latest BLE Geo Data',
                  child: geoData == null
                      ? const Text('No geo data received yet.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(
                              'Latitude',
                              geoData.latitude.toStringAsFixed(5),
                            ),
                            _infoRow(
                              'Longitude',
                              geoData.longitude.toStringAsFixed(5),
                            ),
                            _infoRow('Speed', geoData.speed.toStringAsFixed(3)),
                            _infoRow('Zone', geoData.zone),
                            _infoRow(
                              'Received At',
                              geoData.receivedAt.toString(),
                            ),
                          ],
                        ),
                ),

                _sectionCard(
                  context,
                  title: 'Patient Summary',
                  child: patientController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : patientController.errorMessage != null
                      ? Text(
                          patientController.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : patient == null
                      ? const Text('No patient loaded.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Patient Name', patient.name),
                            _infoRow('Patient ID', patient.id),
                            _infoRow('Date of Birth', patient.dateOfBirth),
                            _infoRow('Trial ID', patient.trialId),
                            _infoRow('Status', patient.status),
                          ],
                        ),
                ),

                _sectionCard(
                  context,
                  title: 'Communication & Permissions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• Research team contact trigger'),
                      const Text('• Provider input logging'),
                      const Text('• Audit trail support'),
                      AppConstants.verticalGap12,
                      FilledButton.tonal(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contact workflow will be connected later.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Notify Research Team'),
                      ),
                    ],
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _sectionCard(
                        context,
                        title: 'Wear Time',
                        child: Column(
                          children: [
                            const Icon(Icons.access_time, size: 36),
                            AppConstants.verticalGap8,
                            const Text('12h 36m'),
                            AppConstants.verticalGap8,
                            LinearProgressIndicator(
                              value: 0.72,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _sectionCard(
                        context,
                        title: 'GIS / Activity',
                        child: Column(
                          children: [
                            const Icon(Icons.map, size: 36),
                            AppConstants.verticalGap8,

                            geoData == null
                                ? const Text('No location received yet.')
                                : Text(
                                    '${geoData.latitude.toStringAsFixed(3)}, ${geoData.longitude.toStringAsFixed(3)}',
                                    textAlign: TextAlign.center,
                                  ),

                            AppConstants.verticalGap8,

                            OutlinedButton(
                              onPressed: geoData == null
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BleGeoMapScreen(
                                              latitude: geoData.latitude,
                                            longitude: geoData.longitude,
                                          ),
                                        ),
                                      );
                                    },
                              child: const Text('View Map'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          AppConstants.verticalGap12,
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
