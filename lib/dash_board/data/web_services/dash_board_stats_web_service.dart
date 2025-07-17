import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/token_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DashboardStats {
  final int jobs;
  final int applicants;
  final int newToday;

  DashboardStats({
    required this.jobs,
    required this.applicants,
    required this.newToday,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      jobs: json['active_jobs'],
      applicants: json['applications_this_week'],
      newToday: json['pending_applications'],
    );
  }
}

Future<DashboardStats> fetchDashboardStats() async {
  BaseOptions options = BaseOptions(
    baseUrl: baseUrl,
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 30),
  );

  final dio = Dio(options);

  String? token = await TokenManager.getAccessToken();

  if (token == null) {
    debugPrint("No token found. Cannot proceed with request.");
    throw Exception("Unauthorized: Token is missing");
  }

  try {
    final response = await dio.get(
      'dashboard-status/',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true'
        },
      ),
    );

    return DashboardStats.fromJson(response.data);
  } on DioError catch (e) {
    if (e.response != null) {
      debugPrint(
          "❌ Dio error: ${e.response?.statusCode} => ${e.response?.data}");
      throw Exception("Failed to load stats: ${e.response?.statusMessage}");
    } else {
      debugPrint("❌ Dio error without response: ${e.message}");
      throw Exception("Network error: ${e.message}");
    }
  }
}
