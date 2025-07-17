class PolicyModel {
  final List<PolicyDetail> policies;

  PolicyModel({
    required this.policies,
  });

  factory PolicyModel.fromJson(List<dynamic> jsonPolicies) {
    final List<PolicyDetail> policyList = jsonPolicies
        .map((json) => PolicyDetail.fromJson(json as Map<String, dynamic>))
        .toList();

    return PolicyModel(
      policies: policyList,
    );
  }
}

class PolicyDetail {
  final int id;
  final bool isActiveForCompany;
  final String name;
  final int? jobPostLimit;
  final bool canGenerateTests;
  final bool canScheduleInterviews;
  final String candidateSuggestions;
  final double? price;

  PolicyDetail({
    required this.id,
    required this.isActiveForCompany,
    required this.name,
    required this.jobPostLimit,
    required this.canGenerateTests,
    required this.canScheduleInterviews,
    required this.candidateSuggestions,
    this.price,
  });

  factory PolicyDetail.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return PolicyDetail(
      id: json['id'],
      isActiveForCompany: parseBool(json['is_active_for_company']),
      name: json['name'],
      jobPostLimit: json['job_post_limit'],
      canGenerateTests: parseBool(json['can_generate_tests']),
      canScheduleInterviews: parseBool(json['can_schedule_interviews']),
      candidateSuggestions: json['candidate_suggestions'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }
}

class PolicyStatus {
  final String status;
  final String message;

  PolicyStatus({required this.status, required this.message});

  factory PolicyStatus.fromJson(Map<String, dynamic> json) {
    return PolicyStatus(
      status: json['status'],
      message: json['message'],
    );
  }
}
