class PolicyModel {
  final PolicyDetail freePolicy;
  final PolicyDetail premiumPolicy;
  final String? currentStatus;

  PolicyModel({
    required this.freePolicy,
    required this.premiumPolicy,
    this.currentStatus,
  });

  factory PolicyModel.fromJson(dynamic json) {
    if (json is List) {
      final freeJson = json.firstWhere(
        (item) => item['name'] == 'free',
        orElse: () => throw Exception('Free policy not found'),
      );

      final premiumJson = json.firstWhere(
        (item) => item['name'] == 'paid',
        orElse: () => throw Exception('Premium policy not found'),
      );

      return PolicyModel(
        freePolicy: PolicyDetail.fromJson(freeJson),
        premiumPolicy: PolicyDetail.fromJson(premiumJson),
        currentStatus: null, 
      );
    } else {
      throw Exception('Invalid JSON format: expected a List');
    }
  }
}

class PolicyDetail {
  final int id;
  final String name;
  final int? jobPostLimit;
  final bool canGenerateTests;
  final bool canScheduleInterviews;
  final String candidateSuggestions;
  final double? price;

  PolicyDetail({
    required this.id,
    required this.name,
    required this.jobPostLimit,
    required this.canGenerateTests,
    required this.canScheduleInterviews,
    required this.candidateSuggestions,
    this.price,
  });

  factory PolicyDetail.fromJson(Map<String, dynamic> json) {
    return PolicyDetail(
      id: json['id'],
      name: json['name'],
      jobPostLimit: json['job_post_limit'],
      canGenerateTests: json['can_generate_tests'],
      canScheduleInterviews: json['can_schedule_interviews'],
      candidateSuggestions: json['candidate_suggestions'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }
}
