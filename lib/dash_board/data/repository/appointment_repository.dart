import 'package:forsatech/dash_board/data/model/appointment_model.dart';
import 'package:forsatech/dash_board/data/web_services/google_calendar_web_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<List<JobAppointment>> getJobs() => webService.fromJsonJob();

  Future<JobAppointment> getJobById(int jobId) =>
      webService.fetchJobById(jobId);
}
