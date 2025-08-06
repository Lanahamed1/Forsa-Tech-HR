import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/job_recommend_model.dart';
import 'package:forsatech/token_manager.dart';

class JobsRecommendWebService {
  late Dio dio;

  // ignore: non_constant_identifier_names
  JobsRecommendWebService.JobsRecommendWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 160),
      receiveTimeout: const Duration(seconds: 70),
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
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      final data = response.data as List;
      return data
          .map((jobJson) => JobRecommendModel.fromJson(jobJson))
          .toList();
    }on DioException catch (e) {
  if (e.response?.statusCode == 403) {
    throw "Your attempts have been exhausted. Please subscribe to one of the policies.";
  } else {
    throw "Failed to load jobs: ${e.message}";
  }
} catch (e) {
  throw "An error occurred: ${e.toString().replaceAll('Exception: ', '')}";
}
  }}
