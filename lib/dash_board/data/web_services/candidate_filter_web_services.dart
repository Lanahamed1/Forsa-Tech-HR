import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/token_manager.dart';

class CandidateFilterWebService {
  late Dio dio;

  CandidateFilterWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }

  Future<JobModel> fetchJobDetails(int jobId) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'recommend/applicants/$jobId/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      if (response.statusCode == 200) {
        return JobModel.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load job details, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job details: $e');
    }
  }

  Future<List<JobModel>> fetchJobOpportunitiesWithApplicants() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'opportunities/my-company/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['opportunities'] != null) {
          List<dynamic> data = response.data['opportunities'];
          return data.map((e) => JobModel.fromJson(e)).toList();
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception(
            'Failed to load job opportunities, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job opportunities: $e');
    }
  }
}
