import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../repositories/patient_repository.dart';

class PatientController extends ChangeNotifier {
  final PatientRepository patientRepository;

  PatientController(this.patientRepository);

  Patient? _patient;
  bool _isLoading = false;
  String? _errorMessage;

  Patient? get patient => _patient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPatientByDeviceId(String deviceId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _patient = await patientRepository.getPatientByDeviceId(deviceId);
    } catch (e) {
      _errorMessage = e.toString();
      _patient = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearPatient() {
    _patient = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
