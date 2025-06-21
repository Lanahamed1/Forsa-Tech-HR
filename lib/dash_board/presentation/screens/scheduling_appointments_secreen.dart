import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '836989400409-gr9u5p3dpprh4d07i9tsp46fpe7mahv0.apps.googleusercontent.com',
    scopes: ['email'],
  );

  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;
  final TextEditingController _recipientEmailController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() => _currentUser = account);
    });
    _googleSignIn.signInSilently();
    context.read<JobApponitCubit>().fetchJobs();
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
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
              cubit.emit(state.copyWith(errorMessage: null));
            }
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Appointment created successfully')),
              );
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
                width: 550, // Fixed width for consistent layout
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
                              color: Color(0xFF6366F1)),
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

                    // Title
                    TextField(
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

                    // Description
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description_outlined,
                            color: Color(0xFF6366F1)),
                        labelText: 'Description',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: cubit.updateDescription,
                    ),

                    const SizedBox(height: 15),

                    // Date Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Color(0xFF6366F1),
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

                        // Time Picker
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Color(0xFF6366F1),
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

                    // Buttons
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
                            padding:
                                EdgeInsets.zero, // مهم لعرض التدرج بشكل صحيح
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: state.isSubmitting
                              ? null
                              : () {
                                  if (_currentUser != null) {
                                    cubit.submitAppointment(_currentUser!);
                                    Navigator.pop(context);
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
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF6366F1)),
        title: Text(
          'Create Interview Appointment',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(const Rect.fromLTWH(0, 0, 300, 0)),
          ),
        ),
      ),
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
                DropdownButtonFormField<JobAppont>(
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

                // Show job details and applicants
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
                          color: Color(0xFF6366F1))),
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
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please sign in first")),
              );
              return;
            }
            _showCreateAppointmentDialog();
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
