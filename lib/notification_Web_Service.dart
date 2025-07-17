import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/token_manager.dart';

class FcmWebService {
  late Dio dio;

  FcmWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl, // تأكد من تعريف baseUrl في strings.dart
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }

  Future<bool> sendFcmToken(String fcmToken) async {
    try {
      String? token = await TokenManager.getAccessToken();
      if (token == null) {
        print('❌ No access token available');
        return false;
      }

      Response response = await dio.post(
        'update-device-token/', 
        data: jsonEncode({'fcm_token': fcmToken}),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ FCM token sent successfully');
        return true;
      } else {
        print('❌ Failed to send FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending FCM token: $e');
      return false;
    }
  }
}
