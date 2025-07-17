class CandidateFilterModel {
  final int userId;
  final String username;
  final String email;
  final double similarityScore;
  final List<String> skills;

  CandidateFilterModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.similarityScore,
    required this.skills,
  });

  factory CandidateFilterModel.fromJson(Map<String, dynamic> json) {
    return CandidateFilterModel(
      // application_id
      userId: json['application_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      similarityScore: (json['similarity_score'] ?? 0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class JobModel {
  final int id;
  final String title;
  final List<CandidateFilterModel> topApplicants;

  JobModel({
    required this.id,
    required this.title,
    required this.topApplicants,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    List<CandidateFilterModel> applicants = [];

    if (json.containsKey('top_applicants') && json['top_applicants'] is List) {
      applicants = (json['top_applicants'] as List)
          .map((e) => CandidateFilterModel.fromJson(e))
          .toList();
    }

    return JobModel(
      id: json['opportunity_id'] ?? json['id'] as int,
      title: json['opportunity_name'] ?? '',
      topApplicants: applicants,
    );
  }
}
