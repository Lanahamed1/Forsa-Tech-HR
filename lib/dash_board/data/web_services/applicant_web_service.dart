import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/applicant_model.dart';
import 'package:forsatech/token_manager.dart';

class ApplicantWebService {
  late Dio dio;

  ApplicantWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }

  Future<ApplicantModel> fetchUserProfile(String username) async {
    try {
      final response = await dio.post(
        'user-resume/',
        data: {
          'username': username,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
      return ApplicantModel.fromJson(response.data);
    } else if (response.statusCode == 404) {
      throw ('This user does not have a resume (CV).');
    } else {
      throw (
          'Failed to load resume. Server responded with status code ${response.statusCode}.');
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      throw ('This user does not have a resume (CV).');
    } else {
      throw ('An error occurred while loading the resume: ${e.message}');
    }
  } catch (e) {
    throw ('Unexpected error while fetching resume: $e');
  }

  }

  Future<void> updateApplicantStatus(int requestId, String action) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

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
      // print('*** Request ***');
      // print('URI: ${response.requestOptions.uri}');
      // print('Headers: ${response.requestOptions.headers}');
      // print('Data: ${response.requestOptions.data}');

      // print('*** Response ***');
      // // print('Status code: ${response.statusCode}');
      // // print('Data: ${response.data}');
      if (response.statusCode == 200) {
        debugPrint('Status updated successfully.');
      } else {
        throw Exception(
            'Failed to update status: Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      throw Exception('Failed to update status: $e');
    }
  }

  Future<String> fetchApplicantStatus(
      int opportunityId, String username) async {
    String? token = await TokenManager.getAccessToken();

    if (token == null) {
      throw Exception("Authentication token is missing.");
    }
    try {
      final response = await dio.post(
        'check-status/',
        data: {
          'username': username,
          'opportunity_id': opportunityId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );
      // print('*** Request ***');
      // print('URI: ${response.requestOptions.uri}');
      // print('Headers: ${response.requestOptions.headers}');
      // print('Data: ${response.requestOptions.data}');

      // print('*** Response ***');
      // print('Status code: ${response.statusCode}');
      // print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['status'] as String;
      } else {
        throw Exception('Failed to load applicant status');
      }
    } catch (e) {
      print('Error fetching applicant status: $e');
      throw Exception('Error fetching applicant status: $e');
    }
  }
}
