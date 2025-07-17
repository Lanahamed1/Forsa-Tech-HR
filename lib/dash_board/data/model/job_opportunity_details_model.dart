enum ApplicantStatus { pending, accept, reject }

class JobOpportunityDetailsModel {
  final int? id;
  final String title;
  final String description;
  final String location;
  final String salary;
  final String experience;
  final List<JobApplicant> applicants;

  JobOpportunityDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.experience,
    required this.applicants,
  });

  factory JobOpportunityDetailsModel.fromJson(Map<String, dynamic> json) {
    final opportunity = json['opportunity'] ?? {};

    return JobOpportunityDetailsModel(
      id: opportunity['id'],
      title: opportunity['opportunity_name'] ?? '',
      description: opportunity['description'] ?? '',
      location: opportunity['location'] ?? '',
      salary:
          opportunity['salary_range'] != null && opportunity['currency'] != null
              ? '${opportunity['salary_range']} ${opportunity['currency']}'
              : '',
      experience: opportunity['experience_level'] ?? '',
      applicants: (json['applicants'] as List<dynamic>? ?? [])
          .map((a) => JobApplicant.fromJson(a))
          .toList(),
    );
  }
}

class JobApplicant {
  final int id;
  final String username;
  final String jobTitle;
  final String degree;
  final String skills;
  ApplicantStatus status;

  JobApplicant({
    required this.id,
    required this.username,
    required this.jobTitle,
    required this.degree,
    required this.skills,
    required this.status,
  });
  factory JobApplicant.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final resume = user['resume'] ?? {};

    final skillsListRaw = resume['skills'];
    final List<dynamic> skillsList =
        (skillsListRaw is List) ? skillsListRaw : [];

    final skillsStr = skillsList
        .map((skill) =>
            skill is Map<String, dynamic> ? (skill['skill'] ?? '') : '')
        .where((s) => s is String && s.isNotEmpty)
        .join(', ');

    String jobTitle = '';
    final experiencesRaw = resume['experiences'];
    if (experiencesRaw is List && experiencesRaw.isNotEmpty) {
      final firstExperience = experiencesRaw[0];
      if (firstExperience is Map<String, dynamic>) {
        jobTitle = firstExperience['job_title'] ?? '';
      }
    }

    String degree = '';
    final educationRaw = resume['education'];
    if (educationRaw is List && educationRaw.isNotEmpty) {
      final firstEducation = educationRaw[0];
      if (firstEducation is Map<String, dynamic>) {
        degree = firstEducation['degree'] ?? '';
      }
    }

    return JobApplicant(
      id: json['id'],
      username: user['username'] ?? '',
      jobTitle: jobTitle,
      degree: degree,
      skills: skillsStr,
      status: _statusFromString(json['status']),
    );
  }

  static ApplicantStatus _statusFromString(String status) {
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

  String get statusAsString {
    return status.name;
  }
}
