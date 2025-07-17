class CompanyProfile {
  final int id;
  final String name;
  final String email;
  final String logoUrl;
  final String description;
  final String website;
  final String address;
  final int employees;
  final int opportunityCount;

  CompanyProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.logoUrl,
    required this.description,
    required this.website,
    required this.address,
    required this.employees,
    required this.opportunityCount,
  });
  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    final data = json['company'] ?? json;
    return CompanyProfile(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      logoUrl: data['logo'] ?? '',
      description: data['description'] ?? '',
      website: data['website'] ?? '',
      address: data['address'] ?? '',
      employees: int.tryParse('${data['employees'] ?? 0}') ?? 0,
      opportunityCount: int.tryParse('${data['opportunity_count'] ?? 0}') ?? 0,
    );
  }
}
