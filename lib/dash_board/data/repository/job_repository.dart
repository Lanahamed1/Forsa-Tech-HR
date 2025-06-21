import 'package:forsatech/dash_board/data/model/job_model.dart';
import 'package:forsatech/dash_board/data/web_services/job_web_services.dart';

class JobsRepository {
  final JobsWebService webService;

  JobsRepository(this.webService);

  Future<List<JobRecommendModel>> fetchJobs() {
    return webService.getJobs();
  }
}
