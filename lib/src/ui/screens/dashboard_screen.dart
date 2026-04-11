import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../controllers/patient_controller.dart';

class DashboardScreen extends StatelessWidget {
  final String deviceId;

  const DashboardScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PatientController>();
    final patient = controller.patient;

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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mock connection active. Hardware integration will be added later.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                _sectionCard(
                  context,
                  title: 'Patient Summary',
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.errorMessage != null
                      ? Text(
                          controller.errorMessage!,
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
                            const Text('Geospatial data placeholder'),
                            AppConstants.verticalGap8,
                            OutlinedButton(
                              onPressed: () {},
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
