import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/policy_model.dart';
import 'package:forsatech/token_manager.dart';

class PoliciesWebService {
  final Dio dio;

  PoliciesWebService()
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          receiveDataWhenStatusError: true,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 30),
        ));
  Future<PolicyModel> fetchPolicies() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'plans/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      // اطبع البيانات الخام القادمة من السيرفر:
      debugPrint('Raw response data: ${response.data}');

      final List<dynamic> jsonList = response.data;
      return PolicyModel.fromJson(jsonList);
    } catch (e) {
      debugPrint('Error fetching policies: $e');
      throw Exception('Failed to load policies: $e');
    }
  }

  Future<String> subscribeToPolicy(int policyId) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.post(
        'request-subscription/',
        data: {
          "requested_plan": policyId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      final status = response.data['status'];
      return status;
    } catch (e) {
      throw Exception("Failed to subscribe to policy: $e");
    }
  }

  Future<PolicyStatus> fetchSubscriptionStatus() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'check-subscription-status/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      return PolicyStatus.fromJson(response.data);
    } catch (e) {
      debugPrint("Error fetching subscription status: $e");
      throw Exception("Failed to fetch subscription status: $e");
    }
  }
}
