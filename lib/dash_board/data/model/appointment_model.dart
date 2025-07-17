class Appointment {
  final String title;
  final String? description;
  final DateTime dateTime;
  final String recipientEmail;

  Appointment({
    required this.title,
    this.description,
    required this.dateTime,
    required this.recipientEmail,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'recipientEmail': recipientEmail,
      };
}

class JobAppointment {
  final int id;
  final String title;
  final String description;
  final List<String> applicantsEmails;

  JobAppointment({
    required this.id,
    required this.title,
    this.description = '',
    this.applicantsEmails = const [],
  });

  factory JobAppointment.fromJson(Map<String, dynamic> json) {
    final opportunity = json['opportunity'] ?? {};

    final applicants = json['applicants'] as List<dynamic>? ?? [];
    final applicantEmails = applicants
        .map<String>((applicant) {
          final user = applicant['user'];
          return user != null ? user['username']?.toString() ?? '' : '';
        })
        .where((email) => email.isNotEmpty)
        .toList();

    return JobAppointment(
      id: opportunity['id'] ?? '',
      title: opportunity['opportunity_name']?.toString() ?? '',
      description: opportunity['description']?.toString() ?? '',
      applicantsEmails: applicantEmails,
    );
  }

  factory JobAppointment.fromJsonJob(Map<String, dynamic> json) {
    return JobAppointment(
      id: json['id'],
      title: json['opportunity_name'] ?? '',
    );
  }
}
