import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'dart:html' as html;
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/token_manager.dart';
import 'package:forsatech/dash_board/data/model/profile_model.dart';

class CompanyWebService {
  late Dio dio;

  CompanyWebService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl, // عدل حسب API الخاص بك
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<CompanyProfile> fetchCompanyProfile() async {
    final token = await TokenManager.getAccessToken();
    if (token == null) throw Exception('Unauthorized: Token missing');

    final response = await dio.get(
      'company-profile/',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true'
      }),
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return CompanyProfile.fromJson(response.data);
    } else {
      throw Exception('Failed to load company profile');
    }
  }

  Future<Uint8List> _readFileBytes(html.File file) {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoad.listen((event) {
      final result = reader.result;
      if (result is Uint8List) {
        completer.complete(result);
      } else if (result is ByteBuffer) {
        completer.complete(result.asUint8List());
      } else {
        completer.completeError('Failed to read file bytes');
      }
    });

    reader.onError.listen((error) {
      completer.completeError(error);
    });

    reader.readAsArrayBuffer(file);

    return completer.future;
  }

  Future<String> uploadImage(dynamic file) async {
    late MultipartFile multipartFile;

    const cloudName = 'doerwhivd';
    const uploadPreset = 'forsa-_unsigned_upload';
    const uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    if (kIsWeb) {
      final htmlFile = file as html.File;
      final bytes = await _readFileBytes(htmlFile);
      multipartFile = MultipartFile.fromBytes(bytes, filename: htmlFile.name);
    } else {
      final ioFile = file as File;
      multipartFile = await MultipartFile.fromFile(
        ioFile.path,
        filename: ioFile.path.split('/').last,
      );
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
      'upload_preset': uploadPreset,
    });

    final response = await dio.post(uploadUrl, data: formData);

    if (response.statusCode == 200 && response.data['secure_url'] != null) {
      return response.data['secure_url']; // رابط الصورة
    } else {
      throw Exception('فشل رفع الصورة إلى Cloudinary');
    }
  }

  Future<CompanyProfile> updateCompanyProfile({
    required String logoUrl,
    required String description,
  }) async {
    final token = await TokenManager.getAccessToken();
    if (token == null) throw Exception('Unauthorized: Token missing');

    final response = await dio.put(
      'company/update/',
      data: {
        "logo": logoUrl,
        "description": description,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
      ),
    );

    print(response.data); // للتأكد

    if (response.statusCode == 200) {
      // بدل استخدام الاستجابة مباشرة:
      return await fetchCompanyProfile();
    } else {
      throw Exception('Failed to update company profile');
    }
  }

  Future<void> requestPasswordResetOTP(String email) async {
    final response = await dio.post(
      'auth/request-reset/',
      data: {'email': email},
      options: Options(headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true'
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await dio.post(
      'auth/confirm-reset/',
      data: {
        'email': email,
        'code': otp,
        'new_password': newPassword,
      },
      options: Options(headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true'
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to reset password');
    }
  }
}
