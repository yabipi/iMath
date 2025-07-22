import 'package:imath/models/question.dart';

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
      questions: [],
      // questions: (json['questions'] as List)
      //     .map((question) => Question.fromJson(question))
      //     .toList(),
      totalScore: json['totalScore'],
      timeLimit: json['timeLimit'],
    );
  }
}


