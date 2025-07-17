import 'package:forsatech/dash_board/data/model/interview_model.dart';
import 'package:forsatech/dash_board/data/web_services/interview_web_services.dart';

class InterviewRepository {
  final InterviewWebServies webService;
  InterviewRepository(this.webService);

  Future<List<Interview>> getInterviews() async {
    return await webService.fetchInterviews();
  }
}
