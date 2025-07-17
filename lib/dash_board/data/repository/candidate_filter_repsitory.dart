import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/dash_board/data/web_services/candidate_filter_web_services.dart';

class CandidateFilterRepository {
  final CandidateFilterWebService _webServerService;

  CandidateFilterRepository(this._webServerService);

  Future<List<JobModel>> getJobOpportunitiesWithApplicants() async {
    return await _webServerService.fetchJobOpportunitiesWithApplicants();
  }

  Future<JobModel> getJobDetails(int jobId) async {
    return await _webServerService.fetchJobDetails(jobId);
  }
}
