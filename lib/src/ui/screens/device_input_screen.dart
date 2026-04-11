import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../controllers/patient_controller.dart';
import 'dashboard_screen.dart';

class DeviceInputScreen extends StatefulWidget {
  const DeviceInputScreen({super.key});

  @override
  State<DeviceInputScreen> createState() => _DeviceInputScreenState();
}

class _DeviceInputScreenState extends State<DeviceInputScreen> {
  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final deviceId = _deviceIdController.text.trim();

    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a device ID')));
      return;
    }

    final controller = context.read<PatientController>();
    await controller.fetchPatientByDeviceId(deviceId);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DashboardScreen(deviceId: deviceId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientController = context.watch<PatientController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Device ID')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Provider Access',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  AppConstants.verticalGap12,
                  Text(
                    'Enter the TrialWear device identifier to continue.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppConstants.verticalGap24,
                  TextField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(
                      labelText: 'Device ID',
                      hintText: 'Example: TW-1001',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  AppConstants.verticalGap16,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: patientController.isLoading ? null : _continue,
                      child: patientController.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('CONTINUE'),
                    ),
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
