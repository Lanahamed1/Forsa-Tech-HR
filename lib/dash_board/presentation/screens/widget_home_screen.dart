// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/web_services/dash_board_stats_web_service.dart';
import 'package:table_calendar/table_calendar.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              )),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: gradientColors.first,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardStatsAndCalendar extends StatefulWidget {
  const DashboardStatsAndCalendar({super.key});

  @override
  _DashboardStatsAndCalendarState createState() =>
      _DashboardStatsAndCalendarState();
}

class _DashboardStatsAndCalendarState extends State<DashboardStatsAndCalendar> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadStats();
    context.read<InterviewCubit>().fetchInterviews();
  }

  void _loadStats() async {
    try {
      final stats = await fetchDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load stats $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2, // مقابلات أعرض
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 6,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: isMobile ? 350 : 450,
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
                    child: BlocBuilder<InterviewCubit, InterviewState>(
                      builder: (context, state) {
                        if (state is InterviewLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is InterviewLoaded) {
                          final now = DateTime.now();

                          final interviews =
                              state.interviews.where((interview) {
                            try {
                              final dateFormat = DateFormat('yyyy-MM-dd');

                              final date = dateFormat.parse(interview.date);

                              final today = DateTime.now();

                              final interviewDate =
                                  DateTime(date.year, date.month, date.day);
                              final currentDate =
                                  DateTime(today.year, today.month, today.day);

                              return interviewDate
                                      .isAtSameMomentAs(currentDate) ||
                                  interviewDate.isAfter(currentDate);
                            } catch (e) {
                              return false;
                            }
                          }).toList();

                          if (interviews.isEmpty) {
                            return Stack(
                              children: [
                                Center(
                                  child: Opacity(
                                    opacity: 0.08,
                                    child: Icon(
                                      Icons.calendar_today,
                                      size: isMobile ? 100 : 180,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'No upcoming interviews available.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: interviews.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.event_note,
                                          color: Color(0xFF6366F1), size: 22),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Interview Information',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6366F1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final interview = interviews[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.work_outline,
                                              size: 16, color: Colors.blue),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              interview.opportunity,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 16, color: Colors.teal),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              interview.username,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16,
                                              color: Colors.deepPurple),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Date: ${interview.date}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.access_time,
                                              size: 16, color: Colors.indigo),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Time: ${interview.time}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is InterviewError) {
                          return Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          );
                        } else {
                          return const Text(
                            'No data loaded.',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            flex: 2, // إحصائيات وتقويم أصغر
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _isLoading || _stats == null
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: StatCardImproved(
                                icon: Icons.work_outline,
                                title: 'Applications this week',
                                value: _stats!.jobs.toString(),
                                gradientColors: const [
                                  Colors.blueAccent,
                                  Colors.lightBlue
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatCardImproved(
                                icon: Icons.people_outline,
                                title: 'Pending applications',
                                value: _stats!.applicants.toString(),
                                gradientColors: const [
                                  Colors.orange,
                                  Colors.deepOrange
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatCardImproved(
                                icon: Icons.new_releases_outlined,
                                title: 'Active jobs',
                                value: _stats!.newToday.toString(),
                                gradientColors: const [
                                  Colors.green,
                                  Colors.lightGreen
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 290,
                  width: 160,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text(
                            'Job Calendar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: TableCalendar(
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
                                titleTextStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                leftChevronIcon:
                                    Icon(Icons.chevron_left, size: 18),
                                rightChevronIcon:
                                    Icon(Icons.chevron_right, size: 18),
                                headerPadding:
                                    EdgeInsets.symmetric(vertical: 6),
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
                                defaultTextStyle: const TextStyle(fontSize: 12),
                                weekendTextStyle: const TextStyle(fontSize: 12),
                                selectedTextStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                todayTextStyle: const TextStyle(fontSize: 12),
                              ),
                              calendarBuilders: CalendarBuilders(
                                selectedBuilder: (context, date, _) {
                                  return Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6366F1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        date.day.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              availableGestures:
                                  AvailableGestures.horizontalSwipe,
                              daysOfWeekHeight: 20,
                              rowHeight: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
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
