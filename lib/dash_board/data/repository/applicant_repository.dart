import 'package:forsatech/dash_board/data/model/applicant_model.dart';
import 'package:forsatech/dash_board/data/web_services/applicant_web_service.dart';

class ApplicantRepository {
  final ApplicantWebService webService;

  ApplicantRepository(this.webService);

  Future<ApplicantModel> getApplicantProfile(String username) {
    return webService.fetchUserProfile(username);
  }
  Future<void> updateApplicantStatus(int applicantId, String status) {
  return webService.updateApplicantStatus(applicantId, status);
}
Future<String> getApplicantStatus(int opportunityId, String username) {
    return webService.fetchApplicantStatus(opportunityId, username);
  }
}