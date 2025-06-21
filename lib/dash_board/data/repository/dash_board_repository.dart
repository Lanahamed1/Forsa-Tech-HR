import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:forsatech/dash_board/data/web_services/dash_board_web_services.dart';
import 'package:forsatech/dash_board/data/web_services/google_calendar_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

// ==================================================================

class AppointmentRepository {
  final GoogleCalendarService _calendarService = GoogleCalendarService();

  Future<void> createAppointment(
    Appointment appointment,
    GoogleSignInAccount user,
  ) async {
    await _calendarService.createGoogleCalendarEvent(
      title: appointment.title,
      description: appointment.description,
      dateTime: appointment.dateTime,
      recipientEmail: appointment.recipientEmail,
      googleUser: user,
    );
  }
}

class JobAppointRepository {
  final JobAppointWebService webService;

  JobAppointRepository(this.webService);

  Future<List<JobAppont>> getJobs() => webService.fromJsonJob();

  Future<JobAppont> getJobById(int jobId) => webService.fetchJobById(jobId);
}
