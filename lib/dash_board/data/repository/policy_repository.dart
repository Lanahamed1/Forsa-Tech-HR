import 'package:forsatech/dash_board/data/model/policy_model.dart';
import 'package:forsatech/dash_board/data/web_services/policy_web_services.dart';


class PoliciesRepository {
  final PoliciesWebService webService;

  PoliciesRepository(this.webService);

  Future<PolicyModel> fetchPolicies() {
    return webService.fetchPolicies();
  }

 Future<String> subscribeToPolicy(int policyId) {
  return webService.subscribeToPolicy(policyId);
}

}
