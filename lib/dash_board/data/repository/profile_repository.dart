

import 'package:forsatech/dash_board/data/model/profile_model.dart';
import 'package:forsatech/dash_board/data/web_services/profile_web_servoces.dart';


class CompanyRepository {
  final CompanyWebService webService;

  CompanyRepository(this.webService);

  Future<CompanyProfile> getCompanyProfile() => webService.fetchCompanyProfile();

  Future<CompanyProfile> updateCompanyProfile({
    required String logoUrl,
    required String description,
  }) {
    return webService.updateCompanyProfile(
      logoUrl: logoUrl,
      description: description,
    );
  }
}
