import 'package:flutter/material.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/dash_board/data/model/applicant_model.dart';
import 'package:forsatech/dash_board/data/model/appointment_model.dart';
import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/dash_board/data/model/interview_model.dart';
import 'package:forsatech/dash_board/data/model/job_recommend_model.dart';
import 'package:forsatech/dash_board/data/model/job_opportunity_details_model.dart';
import 'package:forsatech/dash_board/data/model/opportunity_model.dart';
import 'package:equatable/equatable.dart';
import 'package:forsatech/dash_board/data/model/policy_model.dart';
import 'package:forsatech/dash_board/data/model/profile_model.dart';
// ==========================================================
///             Opportunity State
///

abstract class OpportunityState {}

class OpportunityInitial extends OpportunityState {}

class OpportunityLoading extends OpportunityState {}

class OpportunityLoaded extends OpportunityState {
  final List<Opportunity> opportunities;
  OpportunityLoaded(this.opportunities);
}

class OpportunityError extends OpportunityState {
  final String message;
  OpportunityError(this.message);
}

//===================================================================
///                     Appointment State
///

class AppointmentState {
  final String title;
  final String? description;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String recipientEmail;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final bool hasSubmitted;

  const AppointmentState({
    this.title = '',
    this.description,
    this.selectedDate,
    this.selectedTime,
    this.recipientEmail = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.hasSubmitted = false,
  });

  AppointmentState copyWith({
    String? title,
    String? description,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? recipientEmail,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? hasSubmitted,
  }) {
    return AppointmentState(
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }
}

// ===================================================
///                   JobAppoint State
///

class JobAppointState {
  final List<JobAppointment> jobs;
  final JobAppointment? selectedJob;
  final bool isLoading;
  final String? errorMessage;

  JobAppointState({
    this.jobs = const [],
    this.selectedJob,
    this.isLoading = false,
    this.errorMessage,
  });

  JobAppointState copyWith({
    List<JobAppointment>? jobs,
    JobAppointment? selectedJob,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JobAppointState(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

///===================================================================================
///            Job Opportunity Details State
///

abstract class JobOpportunityDetailsState extends Equatable {
  const JobOpportunityDetailsState();

  @override
  List<Object> get props => [];
}

class JobOpportunityDetailsInitial extends JobOpportunityDetailsState {}

class JobOpportunityDetailsLoading extends JobOpportunityDetailsState {}

class JobOpportunityDetailsLoaded extends JobOpportunityDetailsState {
  final JobOpportunityDetailsModel opportunity;

  const JobOpportunityDetailsLoaded(this.opportunity);

  @override
  List<Object> get props => [opportunity];
}

class JobOpportunityDetailsError extends JobOpportunityDetailsState {
  final String message;

  const JobOpportunityDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

// =====================================================
///                Applicant State
///

class ApplicantState {
  final String? applicantStatus;

  ApplicantState({this.applicantStatus});
}

class ApplicantInitial extends ApplicantState {}

class ApplicantLoading extends ApplicantState {}

class ApplicantLoaded extends ApplicantState {
  final ApplicantModel applicant;
  @override
  // ignore: overridden_fields
  final String? applicantStatus;

  ApplicantLoaded(this.applicant, {this.applicantStatus})
      : super(applicantStatus: applicantStatus);
}

class ApplicantError extends ApplicantState {
  final String message;

  ApplicantError(this.message);
}

// =========================================
///
///          Candidate Filter State
///

abstract class CandidateFilterState {}

class CandidateInitial extends CandidateFilterState {}

class CandidateLoading extends CandidateFilterState {}

class CandidateLoaded extends CandidateFilterState {
  final List<CandidateFilterModel> candidates;
  final JobModel job;

  CandidateLoaded(this.candidates, this.job);
}

class JobOpportunitiesLoaded extends CandidateFilterState {
  final List<JobModel> jobOpportunities;
  JobOpportunitiesLoaded(this.jobOpportunities);
}

class CandidateError extends CandidateFilterState {
  final String message;
  CandidateError(this.message);
}

///===================================================================
///        Announcement State
///

abstract class AnnouncementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> announcements;

  AnnouncementLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

class AnnouncementError extends AnnouncementState {
  final String message;

  AnnouncementError(this.message);

  @override
  List<Object?> get props => [message];
}
//======================================================================
///               Policies State
///

abstract class PoliciesState {}

class PoliciesInitial extends PoliciesState {}

class PoliciesLoading extends PoliciesState {}

class PoliciesLoaded extends PoliciesState {
  final List<PolicyDetail> policies;

  PoliciesLoaded(this.policies);
}

class PoliciesPending extends PoliciesState {}

class PoliciesSubscribed extends PoliciesState {}

class PoliciesError extends PoliciesState {
  final String message;

  PoliciesError(this.message);
}

class PoliciesLoadError extends PoliciesError {
  PoliciesLoadError(String message) : super(message);
}

///========================================================
///
///                 Jobs Recommend State

abstract class JobsRecommendState {}

class JobsInitial extends JobsRecommendState {}

class JobsLoading extends JobsRecommendState {}

class JobsLoaded extends JobsRecommendState {
  final List<JobRecommendModel> jobs;
  JobsLoaded(this.jobs);
}

class JobsError extends JobsRecommendState {
  final String message;
  JobsError(this.message);
}

///======================================
///
///            Interview

abstract class InterviewState {}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

class InterviewLoaded extends InterviewState {
  final List<Interview> interviews;

  InterviewLoaded(this.interviews);
}

class InterviewError extends InterviewState {
  final String message;

  InterviewError(this.message);
}

///=====================================================
///
///
///               Company Profile State
///
abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final CompanyProfile profile;
  CompanyLoaded(this.profile);
}

class CompanyError extends CompanyState {
  final String message;
  CompanyError(this.message);
}
