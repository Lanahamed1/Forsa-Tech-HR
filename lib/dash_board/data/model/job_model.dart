class JobRecommendModel {
  final int id;
  final String title;
  final String description;
  final String location;
  final String salary;
  final String experience;
  final String status; // ✅ أضف الحالة هنا
  final List<Applicant> topApplicants;

  JobRecommendModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.experience,
    required this.status, // ✅ الحالة
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
      status: json['opportunity_status'] ?? '', // ✅ قراءة الحالة من الـ JSON
      topApplicants: (json['recommendations'] as List)
          .map((a) => Applicant.fromJson(a))
          .toList(),
    );
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
