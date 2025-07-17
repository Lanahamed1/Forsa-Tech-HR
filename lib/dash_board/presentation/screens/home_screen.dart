// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/repository/job_recommend_repository.dart';
import 'package:forsatech/dash_board/data/web_services/job_recommend_web_services.dart';
import 'package:forsatech/dash_board/presentation/screens/job_opportunity_details_secreen.dart';
import 'package:forsatech/dash_board/presentation/screens/policy_screen.dart';
import 'package:forsatech/dash_board/presentation/screens/widget_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardStatsAndCalendar(),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Opportunity Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            DashboardJobsSection(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DashboardJobsSection extends StatelessWidget {
  const DashboardJobsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobsRecommendCubit(
        JobsRecommendRepository(
          JobsRecommendWebService.JobsRecommendWebService(),
        ),
      )..getJobs(),
      child: BlocBuilder<JobsRecommendCubit, JobsRecommendState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobsLoaded) {
            final jobs = state.jobs;

            if (jobs.isEmpty) {
              return const Center(
                child: Text('No job opportunities available right now.'),
              );
            }

            // عرض قائمة الوظائف هنا ...
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                // عرض تفاصيل كل وظيفة
                return ListTile(title: Text(job.title));
              },
            );
          } else if (state is JobsError) {
            final isSubscriptionError =
                state.message.contains("Your attempts have been exhausted");

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSubscriptionError
                          ? Icons.lock_outline
                          : Icons.error_outline,
                      size: 64,
                      color: isSubscriptionError ? Colors.orange : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 18,
                        color: isSubscriptionError ? Colors.orange : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSubscriptionError) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PoliciesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text("Show Policies"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////
///
///              Job Card
///

class JobCard extends StatelessWidget {
  final int opportunityId;
  final String title;
  final String description;
  final String location;
  final String salary;
  final String experience;
  final String status;
  final List<Map<String, String>> topApplicants;

  const JobCard({
    super.key,
    required this.opportunityId,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.experience,
    required this.status,
    required this.topApplicants,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.work_outline,
                      color: Color(0xFF6366F1), size: 27),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.location_on,
                        size: 16, color: Colors.white),
                    label: Text(location,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                  ),
                  Chip(
                    avatar: const Icon(Icons.monetization_on,
                        size: 16, color: Colors.white),
                    label: Text(salary,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                  ),
                  Chip(
                    avatar: const Icon(Icons.access_time,
                        size: 16, color: Colors.white),
                    label: Text(experience,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(thickness: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: topApplicants.map((applicant) {
                  final name = applicant['name'] ?? '';
                  final skillsString = applicant['skills'] ?? '';
                  final List<String> skillsList =
                      skillsString.split(',').map((s) => s.trim()).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF6366F1),
                          child:
                              Icon(Icons.person_outline, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skillsList.map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_outline,
                                            size: 16, color: Color(0xFF6366F1)),
                                        const SizedBox(width: 6),
                                        Text(
                                          skill,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobOpportunityDetailsScreen(
                          opportunityId: opportunityId,
                        ),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.arrow_forward, color: Color(0xFF6366F1)),
                  label: const Text(
                    'Show details',
                    style: TextStyle(color: Color(0xFF6366F1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
