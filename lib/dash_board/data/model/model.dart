class Opportunity {
  final int? id;
  final String? title; // This should be the ID (int) of the ForeignKey
  final String? description;
  final String? employmentType;
  final String? location;
  final String? salaryRange;
  final String? currency;
  final String? experienceLevel;
  final String? requiredSkills;
  final String? preferredSkills;
  final String? educationLevel;
  final String? certifications;
  final String? languagesRequired;
  final String? yearsOfExperience;
  final DateTime? postingDate;
  final DateTime? applicationDeadline;
  final String? status;
  final String? benefits;

  Opportunity({
    this.id,
    this.title,
    this.description,
    this.employmentType,
    this.location,
    this.salaryRange,
    this.currency,
    this.experienceLevel,
    this.requiredSkills,
    this.preferredSkills,
    this.educationLevel,
    this.certifications,
    this.languagesRequired,
    this.yearsOfExperience,
    this.postingDate,
    this.applicationDeadline,
    this.status,
    this.benefits,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'],
      title: json['opportunity_name'],
      description: json['description'],
      employmentType: json['employment_type'],
      location: json['location'],
      salaryRange: json['salary_range'],
      currency: json['currency'],
      experienceLevel: json['experience_level'],
      requiredSkills: json['required_skills'],
      preferredSkills: json['preferred_skills'],
      educationLevel: json['education_level'] ?? '',
      certifications: json['certifications'],
      languagesRequired: json['languages_required'],
      yearsOfExperience: json['years_of_experience'],
      postingDate: json['posting_date'] != null
          ? DateTime.tryParse(json['posting_date'])
          : null,
      applicationDeadline: json['application_deadline'] != null
          ? DateTime.tryParse(json['application_deadline'])
          : null,
      status: json['status'] ?? 'Open',
      benefits: json['benefits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'opportunity_name': title,
      'description': description,
      'employment_type': employmentType,
      'location': location,
      'salary_range': salaryRange,
      'currency': currency,
      'experience_level': experienceLevel,
      'required_skills': requiredSkills,
      'preferred_skills': preferredSkills,
      'education_level': educationLevel,
      'certifications': certifications,
      'languages_required': languagesRequired,
      'years_of_experience': yearsOfExperience,
      'posting_date': postingDate?.toIso8601String(),
      'application_deadline': applicationDeadline?.toIso8601String(),
      'status': status ?? 'Pending',
      'benefits': benefits,
    };
  }
}

///////////////////////////////////////////////////////////////////////////////////////
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

class JobAppont {
  final int id;
  final String title;
  final String description;
  final List<String> applicantsEmails;

  JobAppont({
    required this.id,
    required this.title,
    this.description = '',
    this.applicantsEmails = const [],
  });

  factory JobAppont.fromJson(Map<String, dynamic> json) {
    final opportunity = json['opportunity'] ?? {};

    final applicants = json['applicants'] as List<dynamic>? ?? [];
    final applicantEmails = applicants
        .map<String>((applicant) {
          final user = applicant['user'];
          return user != null ? user['email']?.toString() ?? '' : '';
        })
        .where((email) => email.isNotEmpty)
        .toList();

    return JobAppont(
      id: opportunity['id'] ?? '',
      title: opportunity['opportunity_name']?.toString() ?? '',
      description: opportunity['description']?.toString() ?? '',
      applicantsEmails: applicantEmails,
    );
  }








  factory JobAppont.fromJsonJob(Map<String, dynamic> json) {
    return JobAppont(
      id: json['id'],
      title: json['opportunity_name'] ?? '',
    );
  }
}
