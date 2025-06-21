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
  Future<JobOpportunityDetails> fetchOpportunityDetails(int id) async {
    try {
      final response = await dio.get(
        'opportunity-details/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            "opportunity-id": id.toString(),
          },
        ),
      );


      print('*** Response ***');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        return JobOpportunityDetails.fromJson(data);
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
        },
      ),
    );

    print('✅ Response status: ${response.statusCode}');
    print('✅ Response data: ${response.data}');
    print('✅ Response headers: ${response.headers}');
  } catch (e, stackTrace) {
    print('❌ Exception caught: $e');
    print('🔍 Stack trace:\n$stackTrace');

    if (e is DioError) {
      final req = e.requestOptions;
      print('📤 Request URL: ${req.baseUrl}${req.path}');
      print('📤 Request Method: ${req.method}');
      print('📤 Request Headers: ${req.headers}');
      print('📤 Request Data: ${req.data}');

      final res = e.response;
      if (res != null) {
        print('📥 Response status: ${res.statusCode}');
        print('📥 Response data: ${res.data}');
        print('📥 Response headers: ${res.headers}');
      } else {
        print('❗ No response received from the server');
      }
    }

    throw Exception('Failed to update status: $e');
  }
}
}

//===============================================================================
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
          'username': username, // هذا هو المكان الذي يتوقعه الخادم
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('*** Request ***');
      print('URI: ${response.requestOptions.uri}');
      print('Headers: ${response.requestOptions.headers}');

      print('*** Response ***');
      print('Status code: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return ApplicantModel.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load user profile, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching user profile: $e');
      throw Exception('Error occurred while fetching user profile: $e');
    }
  }
}
//////////////////////////////
///
///
///
///
// ///

//   Future<void> updateApplicantStatus(int requestId, String action) async {
//     try {
//       String? token = await TokenManager.getAccessToken();

//       if (token == null) {
//         debugPrint("No token found. Cannot proceed with request.");
//         throw Exception("Unauthorized: Token is missing");
//       }
//       final response = await dio.post(
//         'job-applications/update-status/',
//         data: {
//           'request_id': requestId,
//           'action': action, // approve أو reject
//         },
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//             'Accept': 'application/json',
//           },
//         ),
//       );

//       print('Status update response: ${response.data}');
//     } catch (e) {
//       throw Exception('Failed to update status: $e');
//     }
//   }
