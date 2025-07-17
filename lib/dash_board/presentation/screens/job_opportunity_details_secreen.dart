import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/job_opportunity_details_model.dart';
import 'package:forsatech/dash_board/data/repository/job_opportunity_detailrepository.dart';
import 'package:forsatech/dash_board/data/web_services/job_opportunity_details_web_service.dart';
import 'package:forsatech/dash_board/presentation/screens/applicant_details_screen.dart';

enum ApplicantStatus { accept, reject, pending }

String statusToString(ApplicantStatus status) {
  switch (status) {
    case ApplicantStatus.accept:
      return 'accepted';
    case ApplicantStatus.reject:
      return 'rejected';
    case ApplicantStatus.pending:
      return 'pending';
  }
}

class JobOpportunityDetailsScreen extends StatelessWidget {
  final int opportunityId;

  const JobOpportunityDetailsScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobOpportunityDetailsCubit(
        repository: JobOpportunityDetailsRepository(
          webService: JobOpportunityDetailsWebService(),
        ),
      )..fetchOpportunity(opportunityId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Color(0xFF6366F1),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Job Opportunity Details',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: BlocBuilder<JobOpportunityDetailsCubit,
              JobOpportunityDetailsState>(
            builder: (context, state) {
              if (state is JobOpportunityDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is JobOpportunityDetailsLoaded) {
                final jobDetails = state.opportunity;
                final applicants = jobDetails.applicants;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Job Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      JobCard(jobDetails: jobDetails),
                      const SizedBox(height: 30),
                      const Text(
                        'Applicants',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...applicants.map(
                        (applicant) => ApplicantCard(
                          applicant: applicant,
                          jobDetail: jobDetails,
                          onDecision: (status) async {
                            final cubit =
                                context.read<JobOpportunityDetailsCubit>();
                            try {
                              await cubit.updateApplicantStatus(
                                  applicant.id, statusToString(status));
                              await cubit.fetchOpportunity(opportunityId);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    status == ApplicantStatus.accept
                                        ? 'Applicant has been accepted'
                                        : 'Applicant has been rejected',
                                  ),
                                  backgroundColor:
                                      status == ApplicantStatus.accept
                                          ? Colors.green
                                          : Colors.redAccent,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to update applicant status: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is JobOpportunityDetailsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////
///
///
///         Job Card
///

class JobCard extends StatelessWidget {
  final JobOpportunityDetailsModel jobDetails;

  const JobCard({super.key, required this.jobDetails});

  Shader _iconGradient() {
    return const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0, 0, 24, 24));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (_) => _iconGradient(),
                child: const Icon(Icons.work, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  jobDetails.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InfoTile(
            icon: Icons.description,
            title: 'Description',
            value: jobDetails.description,
            gradient: _iconGradient(),
          ),
          InfoTile(
            icon: Icons.location_on,
            title: 'Location',
            value: jobDetails.location,
            gradient: _iconGradient(),
          ),
          InfoTile(
            icon: Icons.monetization_on,
            title: 'Salary',
            value: jobDetails.salary,
            gradient: _iconGradient(),
          ),
          InfoTile(
            icon: Icons.school,
            title: 'Experience',
            value: jobDetails.experience,
            gradient: _iconGradient(),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Shader? gradient;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = gradient != null
        ? ShaderMask(
            shaderCallback: (_) => gradient!,
            child: Icon(icon, size: 24, color: Colors.white),
          )
        : Icon(icon, color: Colors.grey[700]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////
///
///          Applicant Card
///

class ApplicantCard extends StatefulWidget {
  final JobApplicant applicant;
  final void Function(ApplicantStatus status)? onDecision;
  final JobOpportunityDetailsModel? jobDetail;

  const ApplicantCard({
    super.key,
    this.jobDetail,
    required this.applicant,
    this.onDecision,
  });

  @override
  State<ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<ApplicantCard> {
  bool _isLoading = false;
  ApplicantStatus statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return ApplicantStatus.accept;
      case 'rejected':
        return ApplicantStatus.reject;
      case 'pending':
      default:
        return ApplicantStatus.pending;
    }
  }

  Shader _iconGradient() {
    return const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0, 0, 24, 24));
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (_) => _iconGradient(),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDecision(ApplicantStatus status) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      widget.onDecision?.call(status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${status == ApplicantStatus.accept ? 'accept' : 'reject'} applicant',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicant = widget.applicant;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFFFFFFFF),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFF6366F1),
              child: Icon(Icons.person, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        applicant.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ignore: unrelated_type_equality_checks
                    (applicant.status == ApplicantStatus.pending)
                        ? (_isLoading
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                children: [
                                  _actionButton(
                                    label: 'Accept',
                                    icon: Icons.check,
                                    onTap: () =>
                                        _handleDecision(ApplicantStatus.accept),
                                  ),
                                  const SizedBox(width: 8),
                                  _actionButton(
                                    label: 'Reject',
                                    icon: Icons.close,
                                    onTap: () =>
                                        _handleDecision(ApplicantStatus.reject),
                                  ),
                                ],
                              ))
                        : const SizedBox.shrink(),
                  ]),
                  const SizedBox(height: 10),
                  _infoRow(Icons.work_outline, applicant.jobTitle),
                  _infoRow(Icons.school_outlined, applicant.degree),
                  _infoRow(Icons.code, applicant.skills),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        // ignore: unnecessary_null_comparison
                        if (applicant.id != null) {
                          debugPrint('Navigating to ApplicantScreen with:');
                          debugPrint('username: ${applicant.username}');
                          debugPrint('id: ${applicant.id}');
                          debugPrint('opportunityId: ${widget.jobDetail!.id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApplicantScreen(
                                username: applicant.username,
                                id: applicant.id,
                                opportunityId: widget.jobDetail!.id,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'No information available for this user'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_forward,
                          color: Color(0xFF6366F1)),
                      label: const Text(
                        'Show details',
                        style: TextStyle(color: Color(0xFF6366F1)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 14),
        backgroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
