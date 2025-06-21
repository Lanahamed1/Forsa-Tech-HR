class CandidateModel {
  final int userId;
  final String username;
  final String email;
  final double similarityScore;
  final List<String> skills;

  CandidateModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.similarityScore,
    required this.skills,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      userId: json['user_id'] ?? 0,
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
  final List<CandidateModel> topApplicants;

  JobModel({
    required this.id,
    required this.title,
    required this.topApplicants,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    List<CandidateModel> applicants = [];

    if (json.containsKey('top_applicants') && json['top_applicants'] is List) {
      applicants = (json['top_applicants'] as List)
          .map((e) => CandidateModel.fromJson(e))
          .toList();
    }

    return JobModel(
      id: json['opportunity_id'] ?? json['id'] ?? 0,
      title: json['opportunity_name'] ?? '',
      topApplicants: applicants,
    );
  }
}
