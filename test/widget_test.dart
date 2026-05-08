import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:trialwear_app_v1/src/core/network/dio_client.dart';
import 'package:trialwear_app_v1/src/services/patient_service.dart';
import 'package:trialwear_app_v1/src/repositories/patient_repository.dart';
import 'package:trialwear_app_v1/src/controllers/patient_controller.dart';

import 'package:trialwear_app_v1/src/services/bluetooth_service.dart';
import 'package:trialwear_app_v1/src/controllers/bluetooth_controller.dart';

import 'package:trialwear_app_v1/main.dart';

void main() {
  testWidgets('TrialWear app smoke test', (WidgetTester tester) async {
    final dio = DioClient.create();
    final patientService = PatientService(dio);
    final patientRepository = PatientRepository(patientService);
    final bluetoothService = BluetoothService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PatientController>(
            create: (_) => PatientController(patientRepository),
          ),
          ChangeNotifierProvider<BluetoothController>(
            create: (_) => BluetoothController(bluetoothService),
          ),
        ],
        child: const TrialWearApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
