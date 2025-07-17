import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/dash_board/data/model/applicant_model.dart';
import 'package:forsatech/dash_board/data/model/appointment_model.dart';
import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/dash_board/data/model/opportunity_model.dart';
import 'package:forsatech/dash_board/data/repository/announcement_repository.dart';
import 'package:forsatech/dash_board/data/repository/applicant_repository.dart';
import 'package:forsatech/dash_board/data/repository/appointment_repository.dart';
import 'package:forsatech/dash_board/data/repository/candidate_filter_repsitory.dart';
import 'package:forsatech/dash_board/data/repository/interview_repository.dart';
import 'package:forsatech/dash_board/data/repository/opportunity_repository.dart';
import 'package:forsatech/dash_board/data/repository/job_recommend_repository.dart';
import 'package:forsatech/dash_board/data/repository/job_opportunity_detailrepository.dart';
import 'package:forsatech/dash_board/data/repository/policy_repository.dart';
import 'package:forsatech/dash_board/data/repository/profile_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';







// ====================================================================
///                   Opportunity Cubit
///

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository repository;

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

// ====================================================================
///
///               Appointment Cubit
///

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

///=====================================================================================
///
///                      JobApponit Cubit
///

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

// ====================================================================================
///                 Job Opportunity Details Cubit
///

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

// ========================================================
///                   Applicant Cubit
///

class ApplicantCubit extends Cubit<ApplicantState> {
  final ApplicantRepository repository;

  ApplicantCubit(this.repository) : super(ApplicantInitial());

  Future<void> loadApplicantAndStatus(
      String username, int? opportunityId) async {
    emit(ApplicantLoading());

    try {
      final applicantFuture = repository.getApplicantProfile(username);
      final statusFuture = opportunityId != null
          ? repository.getApplicantStatus(opportunityId, username)
          : Future.value(null); // fallback safe

      final results = await Future.wait([applicantFuture, statusFuture]);

      final applicant = results[0] as ApplicantModel;
      final status = results[1] as String?;

      emit(ApplicantLoaded(applicant, applicantStatus: status));
    } catch (e) {
      emit(ApplicantError('Failed to load applicant or status: $e'));
    }
  }

  Future<void> updateApplicantStatus(int applicantId, String status) async {
    try {
      await repository.updateApplicantStatus(applicantId, status);

      if (state is ApplicantLoaded) {
        final currentState = state as ApplicantLoaded;
        emit(ApplicantLoaded(
          currentState.applicant,
          applicantStatus: status,
        ));
      }
    } catch (e) {
      throw Exception("Failed to update status: $e");
    }
  }
}

// ======================================================
///               Candidate Filter Cubit
///

class CandidateFilterCubit extends Cubit<CandidateFilterState> {
  final CandidateFilterRepository repository;

  List<JobModel> _jobs = [];
  int? selectedJobId;

  CandidateFilterCubit(this.repository) : super(CandidateInitial());

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
      emit(CandidateLoaded(
          jobDetails.topApplicants, jobDetails)); // ✅ أرسل jobDetails أيضًا
    } catch (e) {
      emit(CandidateError('Failed to load: $e'));
    }
  }

 
}

///===================================================================
///                    Announcement Cubit
///

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

  Future<void> addAnnouncement(Announcement announcement, File? imageFile,
      [Uint8List? imageBytes]) async {
    emit(AnnouncementLoading());
    try {
      print("🎯 addAnnouncement called in Cubit");
      final success = await repository.addAnnouncement(announcement, imageFile,
          imageBytes: imageBytes);

      if (success) {
        await fetchAnnouncements();
      } else {
        emit(AnnouncementError("Failed to create announcement"));
      }
    } catch (e) {
      emit(AnnouncementError("Error: ${e.toString()}"));
    }
  }
}

///================================================================
///                          Policies Cubit
///
class PoliciesCubit extends Cubit<PoliciesState> {
  final PoliciesRepository repository;

  PoliciesCubit(this.repository) : super(PoliciesInitial());

  Future<void> loadPolicies() async {
    emit(PoliciesLoading());
    try {
      final policyModel = await repository.fetchPolicies();
      emit(PoliciesLoaded(policyModel.policies)); 
    } catch (e) {
      emit(PoliciesLoadError("Failed to load policies"));
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
        // تجاهل حالة الخطأ المحتملة وأعتبرها مشترك
        emit(PoliciesSubscribed());
      }
    } catch (e) {
      // تجاهل الأخطاء وعدم إصدار حالة خطأ
      emit(PoliciesSubscribed());
    }
  }
}


///================================================================
///
///                   Jobs Recommend Cubit
///

class JobsRecommendCubit extends Cubit<JobsRecommendState> {
  final JobsRecommendRepository repository;

  JobsRecommendCubit(this.repository) : super(JobsInitial());

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

///===================================================
///
///             Interview

class InterviewCubit extends Cubit<InterviewState> {
  final InterviewRepository repository;

  InterviewCubit(this.repository) : super(InterviewInitial());

  void fetchInterviews() async {
    try {
      emit(InterviewLoading());
      final interviews = await repository.getInterviews();
      emit(InterviewLoaded(interviews));
    } catch (e) {
      emit(InterviewError(e.toString()));
    }
  }
}

///====================================
///
///            Company Profile Cubit
class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository repository;

  CompanyCubit(this.repository) : super(CompanyInitial());

  Future<void> loadCompanyProfile() async {
    emit(CompanyLoading());
    try {
      final profile = await repository.getCompanyProfile();
      emit(CompanyLoaded(profile));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> updateCompanyProfile({
    required String newLogoUrl,
    required String newDescription,
  }) async {
    emit(CompanyLoading());
    try {
      final updatedProfile = await repository.updateCompanyProfile(
        logoUrl: newLogoUrl,
        description: newDescription,
      );
      emit(CompanyLoaded(updatedProfile));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }
}
