import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/candidate_filter_model.dart';
import 'package:forsatech/dash_board/presentation/screens/applicant_details_screen.dart';

class CandidateFilterScreen extends StatefulWidget {
  const CandidateFilterScreen({super.key});

  @override
  State<CandidateFilterScreen> createState() => _CandidateFilterScreenState();
}
class _CandidateFilterScreenState extends State<CandidateFilterScreen> {
  int? _selectedJobId;
  List<JobModel> _allJobs = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CandidateFilterCubit>();
    cubit.fetchJobOpportunitiesWithApplicants();
  }

  void _onJobChanged(int? jobId) async {
    setState(() => _selectedJobId = jobId);

    final cubit = context.read<CandidateFilterCubit>();
    if (jobId == null) {
      await cubit.fetchJobOpportunitiesWithApplicants();
    } else {
      await cubit.selectJob(jobId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            "Job Applicants",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<CandidateFilterCubit, CandidateFilterState>(
                builder: (context, state) {
                  // عندما نستلم الوظائف، نخزنها في _allJobs
                  if (state is JobOpportunitiesLoaded) {
                    _allJobs = state.jobOpportunities.reversed.toList();
                  }

                  if (_allJobs.isEmpty) {
                    return const LinearProgressIndicator();
                  }

                  return JobDropdown(
                    jobOpportunities: _allJobs,
                    selectedJobId: _selectedJobId,
                    onChanged: _onJobChanged,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<CandidateFilterCubit, CandidateFilterState>(
                builder: (context, state) {
                  if (_selectedJobId == null) {
                    return const Center(
                      child: Text(
                        'Select a Job',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  if (state is CandidateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CandidateError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is CandidateLoaded) {
                    if (state.candidates.isEmpty) {
                      return const Center(child: Text('No applicants for this job'));
                    }
                    return CandidatesList(
                      candidates: state.candidates,
                      jobModel: state.job,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////
/// Dropdown widget to select a job
///////////////////////////////////////////////////////

class JobDropdown extends StatelessWidget {
  final List<JobModel> jobOpportunities;
  final int? selectedJobId;
  final ValueChanged<int?> onChanged;

  const JobDropdown({
    super.key,
    required this.jobOpportunities,
    required this.selectedJobId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      value: selectedJobId,
      isExpanded: true,
      items: jobOpportunities.map(
        (job) => DropdownMenuItem<int?>(
          value: job.id,
          child: Text(job.title),
        ),
      ).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Jobs',
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

///////////////////////////////////////////////////////
/// Candidates List widget
///////////////////////////////////////////////////////

class CandidatesList extends StatelessWidget {
  final List<CandidateFilterModel> candidates;
  final JobModel jobModel;

  const CandidatesList({
    super.key,
    required this.candidates,
    required this.jobModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: candidates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return CandidateCard(
          candidate: candidate,
          jobModel: jobModel,
        );
      },
    );
  }
}

///////////////////////////////////////////////////////
/// Candidate Card widget
///////////////////////////////////////////////////////

class CandidateCard extends StatelessWidget {
  final CandidateFilterModel candidate;
  final JobModel? jobModel;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.jobModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    size: 20, color: Color(0xFF6366F1)),
                const SizedBox(width: 6),
                Text(
                  'Similarity: ${(candidate.similarityScore * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF6366F1),
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              candidate.email,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Skills',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: candidate.skills.map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
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
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  if (candidate.username != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicantScreen(
                          id: candidate.userId,
                          username: candidate.username,
                          opportunityId: jobModel?.id,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No information available for this user'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF6366F1)),
                label: const Text(
                  'Show details',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
