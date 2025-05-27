class Paper {
  final int id;
  final String title;
  final String createTime;

  Paper({
    required this.id,
    required this.title,
    required this.createTime,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'],
      title: json['title'],
      createTime: json['createTime'],
    );
  }
} 