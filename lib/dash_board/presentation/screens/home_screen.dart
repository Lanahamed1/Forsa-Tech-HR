import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/repository/job_repository.dart';
import 'package:forsatech/dash_board/data/web_services/job_web_services.dart';
import 'package:forsatech/dash_board/presentation/screens/job_opportunity_details_secreen.dart';
import 'package:table_calendar/table_calendar.dart';

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
              child: Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
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
      create: (_) => JobsCubit(
        JobsRepository(
          JobsWebService(),
        ),
      )..getJobs(),
      child: BlocBuilder<JobsCubit, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobsLoaded) {
            final jobs = state.jobs;
            return Column(
              children: jobs.map((job) {
                return JobCard(
                  opportunityId: job.id,
                  title: job.title,
                  description: job.description,
                  location: job.location,
                  salary: job.salary,
                  experience: job.experience,
                  status: job.status, // ✅ تمرير الحالة هنا
                  topApplicants: job.topApplicants
                      .map((applicant) => {
                            'name': applicant.name,
                            'skills': applicant.skills.join(', '),
                          })
                      .toList(),
                );
              }).toList(),
            );
          } else if (state is JobsError) {
            return Center(
              child: Text(
                'Error ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          // الحالة الافتراضية (يمكن تكون JobsInitial أو غيرها)
          return const SizedBox.shrink();
        },
      ),
    );
  }
} // تأكد من تعديل الاستيراد حسب موقع الملف

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
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: skillsList.map((skill) {
                                  return Text(
                                    skill,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'close':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class StatCardImproved extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<Color> gradientColors;

  const StatCardImproved({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradientColors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gradientColors.first,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////
///
///
///
///
///
///
///
class DashboardStatsAndCalendar extends StatefulWidget {
  const DashboardStatsAndCalendar({super.key});

  @override
  _DashboardStatsAndCalendarState createState() =>
      _DashboardStatsAndCalendarState();
}

class _DashboardStatsAndCalendarState extends State<DashboardStatsAndCalendar> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const Flexible(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: StatCardImproved(
                    icon: Icons.work_outline,
                    title: 'Jobs',
                    value: '24',
                    gradientColors: [Colors.blueAccent, Colors.lightBlue],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCardImproved(
                    icon: Icons.people_outline,
                    title: 'Applicants',
                    value: '120',
                    gradientColors: [Colors.orange, Colors.deepOrange],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCardImproved(
                    icon: Icons.new_releases_outlined,
                    title: 'New Today',
                    value: '5',
                    gradientColors: [Colors.green, Colors.lightGreen],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 6,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Job Calendar',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1)),
                    ),
                    const SizedBox(height: 12),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(fontSize: 16),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        outsideDecoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(fontSize: 14),
                        todayTextStyle: const TextStyle(fontSize: 14),
                      ),
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, events) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          );
                        },
                      ),
                      availableGestures: AvailableGestures.none,
                      daysOfWeekHeight: 28,
                      rowHeight: 28,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
