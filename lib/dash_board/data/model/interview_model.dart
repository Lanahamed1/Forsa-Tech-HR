class Interview {
  final int id;
  final String username;
  final String opportunity;
  final String date;
  final String time;

  Interview({
    required this.id,
    required this.username,
    required this.opportunity,
    required this.date,
    required this.time,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'],
      username: json['username'],
      opportunity: json['opportunity'],
      date: json['date'],
      time: json['time'],
    );
  }
}
