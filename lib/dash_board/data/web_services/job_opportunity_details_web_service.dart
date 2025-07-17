import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/job_opportunity_details_model.dart';
import 'package:forsatech/token_manager.dart';

class JobOpportunityDetailsWebService {
  late Dio dio;

  JobOpportunityDetailsWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }
  Future<JobOpportunityDetailsModel> fetchOpportunityDetails(int id) async {
    try {
      final response = await dio.get(
        'opportunity-details/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            "opportunity-id": id.toString(),
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      // print('*** Response ***');
      // print('Status code: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return JobOpportunityDetailsModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load opportunity, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching opportunity: $e');
      throw Exception('Error occurred while fetching opportunity: $e');
    }
  }

  Future<void> updateApplicantStatus(int requestId, String action) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }

      // ignore: unused_local_variable
      final response = await dio.post(
        'job-applications/update-status/',
        data: {
          'application_id': requestId,
          'action': action,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }
}
