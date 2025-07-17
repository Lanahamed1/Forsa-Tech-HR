import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/token_manager.dart';

class RegisterWebServices {
  late Dio dio;

  RegisterWebServices() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }
  Future<Map<String, dynamic>?> logIn(String username, String password) async {
    try {
      Response response = await dio.post(
        'HR/Login',
        data: jsonEncode({'username': username, 'password': password}),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        String token = response.data['access'];
        await TokenManager.saveToken(token);
        return response.data;
      } else {}
      // ignore: empty_catches
    } catch (error) {}
    return null;
  }

  Future<void> sendContactMessage({
    required String subject,
    required String message,
  }) async {
    try {
      String? token = await TokenManager.getAccessToken();
      Response response = await dio.post(
        'auth/complaints/',
        data: jsonEncode({'title': subject, 'description': message}),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        print('✅ Message sent successfully');
      } else {
        print('❌ Failed to send: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
    }
  }
}
