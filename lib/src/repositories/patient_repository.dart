import '../models/patient.dart';
import '../services/patient_service.dart';

class PatientRepository {
  final PatientService patientService;

  PatientRepository(this.patientService);

  Future<Patient> getPatientByDeviceId(String deviceId) async {
    final json = await patientService.getPatientByDeviceId(deviceId);
    return Patient.fromJson(json);
  }
}
