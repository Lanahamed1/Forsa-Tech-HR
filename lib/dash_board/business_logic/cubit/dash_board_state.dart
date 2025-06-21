import 'package:flutter/material.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/dash_board/data/model/job_model.dart';
import 'package:forsatech/dash_board/data/model/job_opportunity_details_model.dart';
import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:equatable/equatable.dart';
import 'package:forsatech/dash_board/data/model/policy_model.dart';

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

// =================================================

abstract class JobOpportunityDetailsState extends Equatable {
  const JobOpportunityDetailsState();

  @override
  List<Object> get props => [];
}

class JobOpportunityDetailsInitial extends JobOpportunityDetailsState {}

class JobOpportunityDetailsLoading extends JobOpportunityDetailsState {}

class JobOpportunityDetailsLoaded extends JobOpportunityDetailsState {
  final JobOpportunityDetails opportunity;

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
// =====================================================4

abstract class ApplicantState {}

class ApplicantInitial extends ApplicantState {}

class ApplicantLoading extends ApplicantState {}

class ApplicantLoaded extends ApplicantState {
  final ApplicantModel applicant;
  ApplicantLoaded(this.applicant);
}

class ApplicantError extends ApplicantState {
  final String message;
  ApplicantError(this.message);
}

// =========================================
abstract class CandidateState {}

class CandidateInitial extends CandidateState {}

class CandidateLoading extends CandidateState {}

class CandidateLoaded extends CandidateState {
  final List<CandidateModel> candidates;
  CandidateLoaded(this.candidates);
}

class JobOpportunitiesLoaded extends CandidateState {
  final List<JobModel> jobOpportunities;
  JobOpportunitiesLoaded(this.jobOpportunities);
}

class CandidateError extends CandidateState {
  final String message;
  CandidateError(this.message);
}

///////////////////////////////////////////////////////////
///import 'package:equatable/equatable.dart';

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

////////////////////////////////////////////////////////////////
///// cubit/policy_state.dart
abstract class PoliciesState {}

class PoliciesPending extends PoliciesState {}

class PoliciesInitial extends PoliciesState {}

class PoliciesLoading extends PoliciesState {}

class PoliciesLoaded extends PoliciesState {
  final PolicyModel policy;
  PoliciesLoaded(this.policy);
}

class PoliciesSubscribed extends PoliciesState {}

class PoliciesError extends PoliciesState {
  final String message;
  PoliciesError(this.message);
}

/////////////////////////////////////////////////////////////////
///
///
///

abstract class JobsState {}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<JobRecommendModel> jobs;
  JobsLoaded(this.jobs);
}

class JobsError extends JobsState {
  final String message;
  JobsError(this.message);
}

/////////////////////////////////////////////////
class JobAppointState {
  final List<JobAppont> jobs;
  final JobAppont? selectedJob;
  final bool isLoading;
  final String? errorMessage;

  JobAppointState({
    this.jobs = const [],
    this.selectedJob,
    this.isLoading = false,
    this.errorMessage,
  });

  JobAppointState copyWith({
    List<JobAppont>? jobs,
    JobAppont? selectedJob,
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
