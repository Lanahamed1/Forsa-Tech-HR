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
    } catch (error) {}
    return null;
  }
}
