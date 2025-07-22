class Knowledge {
  final int id;
  final String? category;
  final int? categoryId;
  final String? type;
  final String title;
  final String? subtitle;
  final String content;


  Knowledge({
    required this.id,
    required this.title,
    required this.content,
    this.subtitle,
    this.category,
    this.categoryId,
    this.type,


  });

  factory Knowledge.fromJson(Map<String, dynamic> json) {
    return Knowledge(
      id: json['id'] ?? 0,
      category: json['category'] as String?,
      categoryId: json['categoryId'] as int?,
      type: json['type'] as String?,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? '',
    );
  }
}