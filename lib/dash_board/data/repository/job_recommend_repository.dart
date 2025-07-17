import 'package:forsatech/dash_board/data/model/job_recommend_model.dart';
import 'package:forsatech/dash_board/data/web_services/job_recommend_web_services.dart';

class JobsRecommendRepository {
  final JobsRecommendWebService webService;

  JobsRecommendRepository(this.webService);

  Future<List<JobRecommendModel>> fetchJobs() {
    return webService.getJobs();
  }
}
