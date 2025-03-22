class Paper {
  final int quizId;
  final String title;

  Paper({
    required this.quizId,
    required this.title
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      quizId: json['quizId'],
      title: json['title']      
    );
  }
} 