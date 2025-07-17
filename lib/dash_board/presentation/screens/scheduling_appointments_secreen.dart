// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/appointment_model.dart';
import 'package:forsatech/dash_board/data/web_services/google_calendar_web_service.dart';
import 'package:forsatech/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentScreen extends StatefulWidget {
  final String? prefilledEmail;
  final int? id;
  const AppointmentScreen({super.key, this.prefilledEmail, this.id});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: googleApiKey,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;

  final TextEditingController _recipientEmailController =
      TextEditingController();

  final TextEditingController _descController = TextEditingController(
    text:
        'Dear Applicant,\n\nWe would like to invite you to an interview to discuss your application for the job opportunity. Please confirm your availability for the scheduled date and time.\n\nBest regards.',
  );
  final TextEditingController _TitleController =
      TextEditingController(text: "Forsa-Tech");

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() => _currentUser = account);
    });
    _googleSignIn.signInSilently();
    context.read<JobApponitCubit>().fetchJobs();
    if (widget.prefilledEmail != null) {
      _recipientEmailController.text = widget.prefilledEmail!;
      context
          .read<AppointmentCubit>()
          .updateRecipientEmail(widget.prefilledEmail!);
    }
  }

  void _onApplicantEmailTapped(String email) {
    _recipientEmailController.text = email;
    context.read<AppointmentCubit>().updateRecipientEmail(email);
    _showCreateAppointmentDialog();
  }

  void _showCreateAppointmentDialog() {
    final cubit = context.read<AppointmentCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return BlocConsumer<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
              cubit.emit(state.copyWith(errorMessage: null));
            }

            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Appointment created successfully')),
              );
              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
              cubit.emit(state.copyWith(isSuccess: false));
            }
          },
          builder: (context, state) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Container(
                width: 550,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined,
                            color: Color(0xFF6366F1)),
                        const SizedBox(width: 10),
                        Text(
                          'Create Appointment',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6366F1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Recipient Email
                    TextField(
                      controller: _recipientEmailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF6366F1)),
                        labelText: 'Recipient Email *',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: cubit.updateRecipientEmail,
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: _TitleController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.title_outlined,
                            color: Color(0xFF6366F1)),
                        labelText: 'Title *',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: cubit.updateTitle,
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description_outlined,
                            color: Color(0xFF6366F1)),
                        labelText: 'Description',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: cubit.updateDescription,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) cubit.selectDate(date);
                          },
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            state.selectedDate == null
                                ? 'Choose Date'
                                : DateFormat.yMMMd()
                                    .format(state.selectedDate!),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) cubit.selectTime(time);
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            state.selectedTime == null
                                ? 'Choose Time'
                                : state.selectedTime!.format(context),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: GoogleFonts.poppins()),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: state.isSubmitting
                              ? null
                              : () async {
                                  final selectedJob = widget.id != null
                                      ? null
                                      : context
                                          .read<JobApponitCubit>()
                                          .state
                                          .selectedJob;

                                  final userEmail =
                                      widget.prefilledEmail?.trim() ??
                                          _recipientEmailController.text.trim();
                                  final jobId = widget.id ?? selectedJob?.id;

                                  debugPrint(' userEmail: $userEmail');
                                  debugPrint(' jobId: $jobId');
                                  debugPrint(
                                      ' selectedDate: ${state.selectedDate}');
                                  debugPrint(
                                      ' selectedTime: ${state.selectedTime}');

                                  if (state.selectedDate != null &&
                                      state.selectedTime != null &&
                                      userEmail.isNotEmpty &&
                                      jobId != null) {
                                    final interviewDateTime = DateTime(
                                      state.selectedDate!.year,
                                      state.selectedDate!.month,
                                      state.selectedDate!.day,
                                      state.selectedTime!.hour,
                                      state.selectedTime!.minute,
                                    );

                                    final interviewService = InterviewService();

                                    try {
                                      await interviewService.sendInterviewInfo(
                                        username: userEmail,
                                        jobId: jobId,
                                        interviewDateTime: interviewDateTime,
                                      );

                                      context
                                          .read<AppointmentCubit>()
                                          .submitAppointment(_currentUser!);
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to send interview info: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill all required fields (date, time, email, job).',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF9333EA),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              constraints: const BoxConstraints(minHeight: 40),
                              alignment: Alignment.center,
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Create',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

//////////////////////////////////////////////////////////////////////////////////
///////
  ///                        handle Google SignIn

  void _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isSigningIn = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Signed in as ${account.email}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isSigningIn = false);
    }
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Create Interview Appointment',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocBuilder<JobApponitCubit, JobAppointState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }

            return ListView(
              children: [
                if (_currentUser == null)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                          ),
                          icon: _isSigningIn
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            _isSigningIn
                                ? 'Signing in...'
                                : 'Sign in with Google',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                          onPressed: _isSigningIn
                              ? null
                              : () => _handleGoogleSignIn(context),
                        ),
                      ),
                    ],
                  )
                else
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (_currentUser!.photoUrl != null &&
                              _currentUser!.photoUrl!.isNotEmpty)
                          ? NetworkImage(_currentUser!.photoUrl!)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(_currentUser!.displayName ?? '',
                        style: GoogleFonts.poppins()),
                    subtitle: Text(_currentUser!.email,
                        style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await _googleSignIn.signOut();
                        setState(() => _currentUser = null);
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Dropdown for job selection
                DropdownButtonFormField<JobAppointment>(
                  decoration: InputDecoration(
                    labelText: "Select Job",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.work_outline,
                        color: Color(0xFF6366F1)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  value: state.selectedJob != null
                      ? state.jobs.firstWhere(
                          (job) => job.id == state.selectedJob!.id,
                          orElse: () => state.jobs.first,
                        )
                      : null,
                  items: state.jobs
                      .map((job) => DropdownMenuItem(
                            value: job,
                            child:
                                Text(job.title, style: GoogleFonts.poppins()),
                          ))
                      .toList(),
                  onChanged: (job) {
                    if (job != null) {
                      context.read<JobApponitCubit>().fetchJobById(job.id);
                      _recipientEmailController.clear();
                      context.read<AppointmentCubit>().updateRecipientEmail('');
                    }
                  },
                ),

                if (state.selectedJob != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description,
                                  color: Color(0xFF6366F1)),
                              const SizedBox(width: 8),
                              Text('Job Description',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(state.selectedJob!.description,
                              style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Applicants:',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1))),
                  const SizedBox(height: 10),
                  ...state.selectedJob!.applicantsEmails.map((email) {
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.account_circle,
                            color: Color(0xFF6366F1)),
                        title: Text(email,
                            style: GoogleFonts.poppins(fontSize: 15)),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Color(0xFF6366F1)),
                          onPressed: () => _onApplicantEmailTapped(email),
                        ),
                      ),
                    );
                    // ignore: unnecessary_to_list_in_spreads
                  }).toList(),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        height: 45,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF9333EA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _showCreateAppointmentDialog();
            if (_currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please sign in first")),
              );
              return;
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: Text(
            "New Appointment",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
