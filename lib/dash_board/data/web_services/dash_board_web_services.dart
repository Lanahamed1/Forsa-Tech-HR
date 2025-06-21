import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:forsatech/token_manager.dart';

class OpportunityWebService {
  late Dio dio;

  OpportunityWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }
  Future<List<Opportunity>> getOpportunities() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'opportunities/my-company/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final opportunities = data['opportunities'] as List<dynamic>;
        return opportunities.map((json) => Opportunity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load opportunities');
      }
    } catch (e) {
      debugPrint('Error in getOpportunities: $e');
      rethrow;
    }
  }

///////////////////////////////////////////////////////////////////////
  Future<void> addOpportunity(Opportunity opportunity) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }

      final data = opportunity.toJson();

      final response = await dio.post(
        'HR/createOpportunity',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response data: ${response.data}");
    } on DioException catch (e) {
      debugPrint("DioException: ${e.message}");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Response: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint('Error in addOpportunity: $e');
      rethrow;
    }
  }

  Future<void> updateOpportunity(Opportunity opportunity) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      if (opportunity.id == null) {
        throw Exception("Opportunity ID is null");
      }

      final response = await dio.put(
        'HR/updateOpportunity/${opportunity.id}',
        data: opportunity.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint("Update response status: ${response.statusCode}");
    } catch (e) {
      debugPrint('Error in updateOpportunity: $e');
      rethrow;
    }
  }

  Future<void> deleteOpportunity(int id) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.delete(
        'HR/deleteOpportunity/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint("Delete response status: ${response.statusCode}");
    } catch (e) {
      debugPrint('Error in deleteOpportunity: $e');
      rethrow;
    }
  }

  Future<List<String>> getJobTitles() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }
      final response = await dio.get(
        'getopportunitynames/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      ); // عدل المسار حسب API الخاص بك
      if (response.statusCode == 200 && response.data is List) {
        return List<String>.from(response.data);
      } else {
        throw Exception('Failed to load job titles');
      }
    } catch (e) {
      debugPrint('Error in getJobTitles: $e');
      rethrow;
    }
  }
}
