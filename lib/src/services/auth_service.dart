import 'package:flutter_appauth/flutter_appauth.dart';

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  static const String clientId = "18968bdb-aff0-44e7-90ab-9e3110b9a4c9";
  static const String tenantId = "trialwear891.onmicrosoft.com";

  Future<String?> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          "com.example.trialwear://login-callback",
          issuer: "https://login.microsoftonline.com/$tenantId/v2.0",
          scopes: [
            "openid",
            "profile",
            "offline_access",
            "https://trialweartest.crm.dynamics.com/.default",
          ],
        ),
      );

      return result?.accessToken;
    } catch (e) {
      print("Auth error: $e");
      return null;
    }
  }
}
