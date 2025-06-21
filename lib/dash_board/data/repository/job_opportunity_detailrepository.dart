import 'package:forsatech/dash_board/data/model/job_opportunity_details_model.dart';
import 'package:forsatech/dash_board/data/web_services/job_opportunity_details_web_service.dart';

class JobOpportunityDetailsRepository {
  final JobOpportunityDetailsWebService webService;

  JobOpportunityDetailsRepository({required this.webService});

  Future<JobOpportunityDetails> getOpportunityDetails(int id) {
    return webService.fetchOpportunityDetails(id);
  }
Future<void> updateApplicantStatus(int applicantId, String status) {
  return webService.updateApplicantStatus(applicantId, status);
}

}




// ====================================================================?=
class ApplicantRepository {
  final ApplicantWebService webService;

  ApplicantRepository(this.webService);

  Future<ApplicantModel> getApplicantProfile(String username) {
    return webService.fetchUserProfile(username);
  }
}


