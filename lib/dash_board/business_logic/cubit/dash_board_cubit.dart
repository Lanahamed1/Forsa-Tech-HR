import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:forsatech/dash_board/data/repository/announcement_repository.dart';
import 'package:forsatech/dash_board/data/repository/candidate_filter_repsitory.dart';
import 'package:forsatech/dash_board/data/repository/dash_board_repository.dart';
import 'package:forsatech/dash_board/data/repository/job_repository.dart';
import 'package:forsatech/dash_board/data/repository/job_opportunity_detailrepository.dart';
import 'package:forsatech/dash_board/data/repository/policy_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository repository;
  List<Opportunity> _allOpportunities = [];

  OpportunityCubit(this.repository) : super(OpportunityInitial());

  Future<void> loadOpportunities() async {
    emit(OpportunityLoading());
    try {
      final ops = await repository.fetchOpportunities();
      emit(OpportunityLoaded(ops));
    } catch (_) {
      emit(OpportunityError('Failed to load opportunities'));
    }
  }

  void filterOpportunities(String query) {
    final filtered = _allOpportunities.where((op) {
      return op.title != null &&
          op.title!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(OpportunityLoaded(filtered));
  }

  Future<void> addOpportunity(Opportunity opportunity) async {
    try {
      await repository.createOpportunity(opportunity);
      await loadOpportunities();
    } catch (_) {
      emit(OpportunityError('Failed to add opportunity'));
    }
  }

  Future<void> updateOpportunity(Opportunity opportunity) async {
    try {
      await repository.updateOpportunity(opportunity);
      await loadOpportunities();
    } catch (_) {
      emit(OpportunityError('Failed to update opportunity'));
    }
  }

  Future<void> deleteOpportunity(int id) async {
    try {
      await repository.deleteOpportunity(id);
      await loadOpportunities();
    } catch (_) {
      emit(OpportunityError('Failed to delete opportunity'));
    }
  }
}

///////////////////////////////////////////////////
class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository repository;

  AppointmentCubit(this.repository) : super(const AppointmentState());

  void updateTitle(String title) => emit(state.copyWith(title: title));

  void updateDescription(String description) =>
      emit(state.copyWith(description: description));

  void selectDate(DateTime date) => emit(state.copyWith(selectedDate: date));

  void selectTime(TimeOfDay time) => emit(state.copyWith(selectedTime: time));

  void updateRecipientEmail(String email) =>
      emit(state.copyWith(recipientEmail: email));

  void setHasSubmitted(bool value) => emit(state.copyWith(hasSubmitted: value));

  Future<void> submitAppointment(GoogleSignInAccount user) async {
    emit(state.copyWith(hasSubmitted: true));

    if (state.title.isEmpty ||
        state.selectedDate == null ||
        state.selectedTime == null ||
        state.recipientEmail.isEmpty) {
      emit(state.copyWith(errorMessage: 'All required fields must be filled'));
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    try {
      final dateTime = DateTime(
        state.selectedDate!.year,
        state.selectedDate!.month,
        state.selectedDate!.day,
        state.selectedTime!.hour,
        state.selectedTime!.minute,
      );

      final appointment = Appointment(
        title: state.title,
        description: state.description,
        dateTime: dateTime,
        recipientEmail: state.recipientEmail,
      );

      await repository.createAppointment(appointment, user);

      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e, stackTrace) {
      print('❌ Error during appointment submission: $e');
      print('📌 StackTrace: $stackTrace');
      emit(state.copyWith(
          isSubmitting: false, errorMessage: 'Failed to create appointment'));
    }
  }
}

// ====================================================================================
class JobOpportunityDetailsCubit extends Cubit<JobOpportunityDetailsState> {
  final JobOpportunityDetailsRepository repository;

  JobOpportunityDetailsCubit({required this.repository})
      : super(JobOpportunityDetailsInitial());

  Future<void> fetchOpportunity(int id) async {
    emit(JobOpportunityDetailsLoading());
    try {
      final opportunity = await repository.getOpportunityDetails(id);
      emit(JobOpportunityDetailsLoaded(opportunity));
    } catch (e) {
      emit(JobOpportunityDetailsError(
          'Failed to load opportunities:${e.toString()}'));
    }
  }

  Future<void> updateApplicantStatus(int applicantId, String status) async {
    try {
      await repository.updateApplicantStatus(applicantId, status);
    } catch (e) {
      throw Exception("Failed to update status: $e");
    }
  }
}

// ======================

class ApplicantCubit extends Cubit<ApplicantState> {
  final ApplicantRepository repository;

  ApplicantCubit(this.repository) : super(ApplicantInitial());

  Future<void> fetchApplicant(String username) async {
    emit(ApplicantLoading());
    try {
      final applicant = await repository.getApplicantProfile(username);
      emit(ApplicantLoaded(applicant));
    } catch (e) {
      emit(ApplicantError(e.toString()));
    }
  }
}

// ================================================.
class CandidateCubit extends Cubit<CandidateState> {
  final CandidateRepository repository;

  List<JobModel> _jobs = [];
  int? selectedJobId;

  CandidateCubit(this.repository) : super(CandidateInitial());

  Future<void> fetchJobOpportunitiesWithApplicants() async {
    try {
      emit(CandidateLoading());
      _jobs = await repository.getJobOpportunitiesWithApplicants();
      emit(JobOpportunitiesLoaded(_jobs));
    } catch (e) {
      emit(CandidateError(e.toString()));
    }
  }

  Future<void> selectJob(int? jobId) async {
    selectedJobId = jobId;

    if (jobId == null) {
      emit(JobOpportunitiesLoaded(_jobs));
      return;
    }

    emit(CandidateLoading());

    try {
      final jobDetails = await repository.getJobDetails(jobId);
      emit(CandidateLoaded(jobDetails.topApplicants));
    } catch (e) {
      emit(CandidateError('الوظيفة غير موجودة أو حدث خطأ: $e'));
    }
  }

  void reset() {
    selectedJobId = null;
    emit(JobOpportunitiesLoaded(_jobs));
  }
}
/////////////////////////////////////////////////////////////////////
///import 'package:flutter_bloc/flutter_bloc.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepository repository;

  AnnouncementCubit(this.repository) : super(AnnouncementInitial());

  Future<void> fetchAnnouncements() async {
    emit(AnnouncementLoading());
    try {
      final announcements = await repository.getAllAnnouncements();
      emit(AnnouncementLoaded(announcements));
    } catch (e) {
      emit(AnnouncementError("Failed to load announcements: $e"));
    }
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    emit(AnnouncementLoading());
    try {
      final success = await repository.addAnnouncement(announcement);
      if (success) {
        await fetchAnnouncements(); // reload after success
      } else {
        emit(AnnouncementError("Failed to create announcement"));
      }
    } catch (e) {
      emit(AnnouncementError("Error: ${e.toString()}"));
    }
  }
}

//////////////////////////////////////////////////////
///// cubit/policy_cubit.dart

class PoliciesCubit extends Cubit<PoliciesState> {
  final PoliciesRepository repository;

  PoliciesCubit(this.repository) : super(PoliciesInitial());

  Future<void> loadPolicies() async {
    emit(PoliciesLoading());
    try {
      final policies = await repository.fetchPolicies();
      emit(PoliciesLoaded(policies));
    } catch (e) {
      emit(PoliciesError("Failed to load policies"));
    }
  }

  Future<void> subscribe(int policyId) async {
    emit(PoliciesLoading());
    try {
      final status = await repository.subscribeToPolicy(policyId);

      if (status == 'pending') {
        emit(PoliciesPending());
      } else if (status == 'approved') {
        emit(PoliciesSubscribed());
      } else {
        emit(PoliciesError('Unknown subscription status: $status'));
      }
    } catch (e) {
      emit(PoliciesError("Failed to subscribe to policy"));
    }
  }
}

/////////////////////////////////////////////////////////
///
///
///
///

class JobsCubit extends Cubit<JobsState> {
  final JobsRepository repository;

  JobsCubit(this.repository) : super(JobsInitial());

  Future<void> getJobs() async {
    try {
      emit(JobsLoading());
      final jobs = await repository.fetchJobs();
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }
}
////////////////////////////////////////////////////////

class JobApponitCubit extends Cubit<JobAppointState> {
  final JobAppointRepository repository;

  JobApponitCubit(this.repository) : super(JobAppointState());

  Future<void> fetchJobs() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final jobs = await repository.getJobs();
      emit(state.copyWith(jobs: jobs, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load opportunity $e'));
    }
  }

  Future<void> fetchJobById(int jobId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final job = await repository.getJobById(jobId);
      emit(state.copyWith(selectedJob: job, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load opportunity : $e'));
    }
  }
}
