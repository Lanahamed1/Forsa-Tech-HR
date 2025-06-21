import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/job_model.dart';
import 'package:forsatech/token_manager.dart';

class JobsWebService {
  late Dio dio;

  JobsWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }

  Future<List<JobRecommendModel>> getJobs() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'recommend/recommend-user/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((jobJson) => JobRecommendModel.fromJson(jobJson)).toList();
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }
}
