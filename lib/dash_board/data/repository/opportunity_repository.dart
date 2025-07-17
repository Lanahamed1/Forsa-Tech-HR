import 'package:forsatech/dash_board/data/model/opportunity_model.dart';
import 'package:forsatech/dash_board/data/web_services/opportunity_web_services.dart';

class OpportunityRepository {
  final OpportunityWebService webService;

  OpportunityRepository({required this.webService});
  Future<List<Opportunity>> fetchOpportunities() =>
      webService.getOpportunities();
  Future<void> createOpportunity(Opportunity opportunity) =>
      webService.addOpportunity(opportunity);
  Future<void> updateOpportunity(Opportunity opportunity) =>
      webService.updateOpportunity(opportunity);
  Future<void> deleteOpportunity(int id) => webService.deleteOpportunity(id);

  fetchOpportunityDetails() {}
}
