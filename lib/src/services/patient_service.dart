import 'package:dio/dio.dart';

import '../config/exceptions/api_exception.dart';

class PatientService {
  final Dio dio;

  PatientService(this.dio);

  Future<Map<String, dynamic>> getPatientByDeviceId(String deviceId) async {
    try {
      // For now, return mock payload so the app is runnable.
      // Later this method will call Dataverse tables.
      await Future<void>.delayed(const Duration(milliseconds: 800));

      return {
        'id': deviceId,
        'name': 'Demo Patient',
        'dateOfBirth': '2012-06-15',
        'trialId': 'TRIAL-001',
        'status': 'Active',
      };

      // Real example later:
      // final response = await dio.get('your_table_name?\$filter=deviceId eq \'$deviceId\'');
      // return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?.toString() ?? e.message ?? 'API error';
      throw ApiException(message, statusCode: statusCode);
    } catch (e) {
      throw ApiException('Failed to fetch patient: $e');
    }
  }
}
