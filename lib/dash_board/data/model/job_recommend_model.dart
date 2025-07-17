class JobRecommendModel {
  final int id;
  final String title;
  final String description;
  final String location;
  final String salary;
  final String experience;
  final String status; 
  final DateTime? applicationDeadline;
  final DateTime? postingDate;

  final List<Applicant> topApplicants;

  JobRecommendModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.experience,
    required this.status,
    this.postingDate,
    this.applicationDeadline,
    required this.topApplicants,
  });

  factory JobRecommendModel.fromJson(Map<String, dynamic> json) {
    return JobRecommendModel(
      id: json['opportunity_id'],
      title: json['opportunity_name'],
      description: json['description'],
      location: json['location'],
      salary: json['salary_range'],
      experience: json['experience_level'],
      status: json['opportunity_status'] ?? '',
      postingDate: json['posting_date'] != null
          ? DateTime.tryParse(json['posting_date'])
          : null,
      applicationDeadline: json['application_deadline'] != null
          ? DateTime.tryParse(json['application_deadline'])
          : null,
      topApplicants: (json['recommendations'] as List)
          .map((a) => Applicant.fromJson(a))
          .toList(),
    );
  }
  String getStatus() {
    final now = DateTime.now();

    if (postingDate != null && now.isBefore(postingDate!)) {
      return 'Pending';
    } else if (applicationDeadline != null &&
        now.isAfter(applicationDeadline!)) {
      return 'Closed';
    } else {
      return 'Open';
    }
  }
}

class Applicant {
  final String name;
  final List<String> skills;

  Applicant({required this.name, required this.skills});

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      name: json['username'] ?? '',
      skills: (json['skills'] as List<dynamic>)
          .map((skill) => skill.toString())
          .toList(),
    );
  }
}
