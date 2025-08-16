class Question {
  final int id;
  final String? category;
  final int? categoryId;
  final String? type;
  final String? title;
  final String? content;
  final String? options;
  final String? answer;
  final String? qImages;
  final String? aImages;

  Question({
    required this.id,
    this.category,
    this.categoryId,
    this.type,
    this.title,
    this.content,
    this.options,
    this.answer,
    this.qImages,
    this.aImages,
  });

  factory Question.empty() {
    return Question(
      id: 0,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      category: json['category'] as String?,
      categoryId: json['categoryId'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      options: json['options'] as String?,
      answer: json['answer'] as String?,
      qImages: json['qImages'] as String?,
      aImages: json['aImages'] as String?,
    );
  }
}