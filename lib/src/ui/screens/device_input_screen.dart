import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';
import '../../controllers/patient_controller.dart';
import 'dashboard_screen.dart';
import 'qr_scanner_screen.dart';

class DeviceInputScreen extends StatefulWidget {
  const DeviceInputScreen({super.key});

  @override
  State<DeviceInputScreen> createState() => _DeviceInputScreenState();
}

class _DeviceInputScreenState extends State<DeviceInputScreen> {
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDob;

  @override
  void dispose() {
    _deviceIdController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final deviceId = _deviceIdController.text.trim();

    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or scan the Device ID.'),
        ),
      );
      return;
    }

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Date of Birth.'),
        ),
      );
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

  String _extractDeviceIdFromScan(String rawValue) {
    final value = rawValue.trim();

    final uri = Uri.tryParse(value);

    if (uri != null && uri.hasScheme) {
      final queryDeviceId =
          uri.queryParameters['deviceId'] ??
          uri.queryParameters['device_id'] ??
          uri.queryParameters['id'];

      if (queryDeviceId != null && queryDeviceId.trim().isNotEmpty) {
        return queryDeviceId.trim();
      }

      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
    }

    return value;
  }

  Future<void> _scanQrCode() async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (!mounted) return;

    if (scannedValue == null || scannedValue.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanner failed. Please enter the Device ID manually.'),
        ),
      );
      return;
    }

    final extractedDeviceId = _extractDeviceIdFromScan(scannedValue);

    setState(() {
      _deviceIdController.text = extractedDeviceId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device ID scanned: $extractedDeviceId'),
      ),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2012, 6, 15),
      firstDate: DateTime(1990),
      lastDate: now,
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDob = pickedDate;
      _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientController = context.watch<PatientController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Device ID'),
      ),
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
                    'Enter the TrialWear device identifier and patient date of birth to continue.',
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

                  const SizedBox(height: 16),

                  TextField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _pickDob,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: patientController.isLoading ? null : _scanQrCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
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