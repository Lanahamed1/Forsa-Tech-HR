class Announcement {
  final String title;
  final String description;
  final String? imageUrl;

  Announcement({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'],
      description: json['description'],
      imageUrl: json['ad_image'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ad_image': imageUrl,
    };
  }
}
