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
}

class Question {
  final int id;
  final String? title;
  final String? content;
  final String? answer;

  Question({
    required this.id,
    this.title,
    this.content,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      title: json['title'] as String?,
      content: json['content'] as String?,
      answer: json['answer'] as String?,
    );
  }
}

// 示例试卷数据
// final sampleQuiz = Quiz(
//   title: '2024年高考数学模拟试卷',
//   totalScore: 150, // 增加总分
//   timeLimit: 120,
//   questions: [
//     Question(
//       type: '复数',
//       content: r'2. (5 分) 已知复数 z=\frac{\sqrt{3}+i}{(1-\sqrt{3} i)^{2}}, \bar{z} 是 z 的共轭复数, 则 z\cdot\bar{z}=(\\quad)',
//       options: [
//         r'A. \frac{1}{4}',
//         r'B. \frac{1}{2}',
//         r'C. 1',
//         r'D. 2',
//       ],
//       correctAnswer: 1,
//       score: 10,
//     ),
//     Question(
//       type: '平面几何',
//       content: r'在平面直角坐标系中, 已知点A(1,2), B(3,4), C(5,2). 求三角形ABC的面积.',
//       options: [
//         r'2\sqrt{2}',
//         r'4\sqrt{2}',
//         r'6\sqrt{2}',
//         r'8\sqrt{2}',
//       ],
//       correctAnswer: 1,
//       score: 10,
//     ),
//     Question(
//       type: '立体几何',
//       content: r'已知正方体ABCD-EFGH的棱长为2, 点M是棱AB的中点, 点N是棱CG的中点. 求线段MN的长度.',
//       options: [
//         r'\sqrt{2}',
//         r'\sqrt{3}',
//         r'\sqrt{5}',
//         r'\sqrt{6}',
//       ],
//       correctAnswer: 2,
//       score: 10,
//     ),
//     Question(
//       type: '函数',
//       content: r'已知函数f(x) = \frac{x^2 - 4}{x - 2}, 求\lim_{x \to 2} f(x)的值.',
//       options: [
//         r'0',
//         r'2',
//         r'4',
//         r'不存在',
//       ],
//       correctAnswer: 2,
//       score: 10,
//     ),
//     Question(
//       type: '微积分',
//       content: r'已知函数f(x) = \int_{0}^{x} t^2 dt, 求f(x)的导数.',
//       options: [
//         r'x',
//         r'x^2',
//         r'2x',
//         r'3x^2',
//       ],
//       correctAnswer: 1,
//       score: 10,
//     ),
//     Question(
//       type: '函数',
//       content: r'已知函数f(x) = \sin(x) + \cos(x), 求f(x)的最大值.',
//       options: [
//         r'1',
//         r'\sqrt{2}',
//         r'2',
//         r'\frac{\sqrt{2}}{2}',
//       ],
//       correctAnswer: 1,
//       score: 10,
//     ),
//   ],
// ); 