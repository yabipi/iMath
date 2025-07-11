class Quiz {
  final String title;
  final List<Question> questions;
  final int totalScore;
  final int timeLimit; // 考试时间（分钟）

  Quiz({
    required this.title,
    required this.questions,
    required this.totalScore,
    required this.timeLimit,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'],
      questions: (json['questions'] as List)
          .map((question) => Question.fromJson(question))
          .toList(),
      totalScore: json['totalScore'],
      timeLimit: json['timeLimit'],
    );
  }
}

class Question {
  final int id;
  final String? category;
  final int? categoryId;
  final String? type;
  final String? title;
  final String? content;
  final String? options;
  final String? answer;
  final String? images;

  Question({
    required this.id,
    this.category,
    this.categoryId,
    this.type,
    this.title,
    this.content,
    this.options,
    this.answer,
    this.images
  });

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
      images: json['images'] as String?,
    );
  }
}
