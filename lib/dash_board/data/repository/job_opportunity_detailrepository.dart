import 'package:forsatech/dash_board/data/model/job_opportunity_details_model.dart';
import 'package:forsatech/dash_board/data/web_services/job_opportunity_details_web_service.dart';

class JobOpportunityDetailsRepository {
  final JobOpportunityDetailsWebService webService;

  JobOpportunityDetailsRepository({required this.webService});

  Future<JobOpportunityDetailsModel> getOpportunityDetails(int id) {
    return webService.fetchOpportunityDetails(id);
  }

  Future<void> updateApplicantStatus(int applicantId, String status) {
    return webService.updateApplicantStatus(applicantId, status);
  }
}
