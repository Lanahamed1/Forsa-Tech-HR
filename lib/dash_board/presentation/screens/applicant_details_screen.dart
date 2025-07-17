// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/data/model/applicant_model.dart';
import 'package:forsatech/dash_board/data/repository/applicant_repository.dart';
import 'package:forsatech/dash_board/data/web_services/applicant_web_service.dart';
import 'package:forsatech/dash_board/presentation/screens/scheduling_appointments_secreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';

class ApplicantScreen extends StatelessWidget {
  final String username;
  final int id;
  final int? opportunityId;

  const ApplicantScreen({
    super.key,
    required this.username,
    required this.id,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit =
            ApplicantCubit(ApplicantRepository(ApplicantWebService()));
        cubit.loadApplicantAndStatus(username, opportunityId);
        return cubit;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
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
              'Applicant Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: BlocBuilder<ApplicantCubit, ApplicantState>(
          builder: (context, state) {
            if (state is ApplicantLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ApplicantError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ApplicantLoaded) {
              final applicant = state.applicant;
              final applicantStatus = state.applicantStatus ?? "pending";
              // ignore: unnecessary_null_comparison
              if (applicant.personalDetails == null) {
                return const Center(
                    child: Text('Applicant data is incomplete.'));
              }

              final showActionButtons =
                  applicantStatus.toLowerCase() == "pending";
              // ignore: unused_local_variable
              final email = applicant.personalDetails.username;

              // final email = applicant.personalDetails.email;

              return Column(
                children: [
                  _buildHeader(context, applicant.personalDetails,
                      applicant.summary, id, showActionButtons, email),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSection(
                          icon: Icons.contact_mail_outlined,
                          title: 'Contact Info',
                          child: _buildContactInfo(applicant.personalDetails),
                        ),
                        _buildSection(
                          icon: Icons.school_outlined,
                          title: 'Education',
                          child: _buildIconList(applicant.education.map((e) =>
                              '${e.degree} - ${e.institution} (${e.startDate} - ${e.endDate})')),
                        ),
                        _buildSection(
                          icon: Icons.work_outline,
                          title: 'Experience',
                          child: Column(
                            children: applicant.experiences.map((e) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.jobTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    _infoRow(Icons.business, e.company),
                                    _infoRow(Icons.date_range,
                                        '${e.startDate} - ${e.endDate}'),
                                    const SizedBox(height: 6),
                                    Text(e.description ?? '',
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        _buildSection(
                          icon: Icons.code_outlined,
                          title: 'Skills',
                          child: _buildIconList(applicant.skills
                              .map((s) => '${s.skill} - ${s.level}')),
                        ),
                        _buildSection(
                          icon: Icons.apps_outlined,
                          title: 'Projects',
                          child: Column(
                            children: applicant.projects.map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(p.description,
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                    if (p.githubLink != null &&
                                        p.githubLink!.isNotEmpty)
                                      _infoRow(Icons.link, p.githubLink!,
                                          isLink: true),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        _buildSection(
                          icon: Icons.school_outlined,
                          title: 'Trainings',
                          child: _buildIconList(applicant.trainingsCourses
                              .map((t) => '${t.title} - ${t.institution}')),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////
  ///                       widget

  Widget _buildHeader(BuildContext context, PersonalDetails info,
      String summary, int id, bool showActionButtons, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF6366F1),
            child: Icon(
              Icons.person,
              size: 55,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              info.username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              summary,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          if (showActionButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    try {
                      await context
                          .read<ApplicantCubit>()
                          .updateApplicantStatus(id, 'accept');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Applicant accepted successfully.'),
                          backgroundColor: Colors.green,
                        ),
                      ); Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppointmentScreen(prefilledEmail: email,id:id),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Accept',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    try {
                      await context
                          .read<ApplicantCubit>()
                          .updateApplicantStatus(id, 'reject');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Applicant rejected successfully.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                     
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.close, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Reject',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////////

Widget _buildSection({
  required IconData icon,
  required String title,
  required Widget child,
}) {
  return Card(
    elevation: 1,
    margin: const EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7C4DFF), size: 22),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1.2),
          child,
        ],
      ),
    ),
  );
}
/////////////////////////////////////////////////////////////////////////////

Widget _buildContactInfo(PersonalDetails info) {
  return Column(
    children: [
      _infoRow(Icons.email_outlined, info.email),
      _infoRow(Icons.phone_android, info.phone ?? ''),
      _infoRow(Icons.location_on_outlined, info.location ?? ''),
      if (info.linkedinLink != null && info.linkedinLink!.isNotEmpty)
        _infoRow(Icons.link, info.linkedinLink!, isLink: true),
      if (info.githubLink != null && info.githubLink!.isNotEmpty)
        _infoRow(Icons.link, info.githubLink!, isLink: true),
    ],
  );
}

///////////////////////////////////////////////////////////////////////////////////
Widget _infoRow(IconData icon, String value, {bool isLink = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isLink
              ? GestureDetector(
                  onTap: () => _launchURL(value),
                  child: Text(
                    value,
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                )
              : Text(value,
                  style: const TextStyle(color: Colors.black, fontSize: 14)),
        ),
      ],
    ),
  );
}
////////////////////////////////////////////////////////////////////////////////////////////

Widget _buildIconList(Iterable<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items.map((e) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(Icons.check_circle_outline,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(e, style: const TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ignore: unused_element
Future<void> _launchEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=Regarding Your Application',
  );
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch email';
  }
}

Future<void> _launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    debugPrint('Could not launch $url');
  }
}
