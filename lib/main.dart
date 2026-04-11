import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/core/network/dio_client.dart';
import 'src/services/patient_service.dart';
import 'src/repositories/patient_repository.dart';
import 'src/controllers/patient_controller.dart';
import 'src/ui/screens/login_screen.dart';

void main() {
  final dio = DioClient.create();
  final patientService = PatientService(dio);
  final patientRepository = PatientRepository(patientService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PatientController>(
          create: (_) => PatientController(patientRepository),
        ),
      ],
      child: const TrialWearApp(),
    ),
  );
}

class TrialWearApp extends StatelessWidget {
  const TrialWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrialWear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}