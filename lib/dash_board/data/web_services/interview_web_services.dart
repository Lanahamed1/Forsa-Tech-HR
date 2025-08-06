import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/interview_model.dart';
import 'package:forsatech/token_manager.dart';

class InterviewWebServies {
  late Dio dio;

  InterviewWebServies() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 150),
      receiveTimeout: const Duration(seconds: 70),
    );
    dio = Dio(options);
  }

  Future<List<Interview>> fetchInterviews() async {
    String? token = await TokenManager.getAccessToken();

    if (token == null) {
      debugPrint("No token found. Cannot proceed with request.");
      throw Exception("Unauthorized: Token is missing");
    }

    final response = await dio.get(
      'get-interviews/',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;

      return jsonList.map((json) => Interview.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load interviews');
    }
  }
}
