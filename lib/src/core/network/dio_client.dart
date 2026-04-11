import 'package:dio/dio.dart';

import '../../config/environment.dart';

class DioClient {
  DioClient._();

  // static Dio create() {
  //   final headers = <String, dynamic>{
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //   };

  //   if (Environment.bearerToken.isNotEmpty) {
  //     headers['Authorization'] = 'Bearer ${Environment.bearerToken}';
  //   }

  //   final dio = Dio(
  //     BaseOptions(
  //       baseUrl: Environment.baseUrl,
  //       connectTimeout: const Duration(seconds: 20),
  //       receiveTimeout: const Duration(seconds: 20),
  //       sendTimeout: const Duration(seconds: 20),
  //       headers: headers,
  //     ),
  //   );

  //   return dio;
  // }

  static Dio create({String? token}) {
    final headers = {"Content-Type": "application/json"};

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return Dio(BaseOptions(baseUrl: Environment.baseUrl, headers: headers));
  }
}
