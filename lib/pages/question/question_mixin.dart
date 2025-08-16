
import 'package:imath/models/question.dart';

mixin QuestionMixin {
  // 判断是否为选择题
  bool isChoiceQuestion(Question question) {
    // 根据题目类型或选项内容判断是否为选择题
    if (question.type != null) {
      final type = question.type!.toLowerCase();
      return type.contains('选择') ||
          type.contains('choice') ||
          type.contains('select');
    }

    // 如果类型字段为空，根据选项内容判断
    if (question.options != null && question.options!.isNotEmpty) {
      final options = question.options!;
      // 检查是否包含选项标识符（A、B、C、D等）
      return RegExp(r'[A-D][\s\.、]').hasMatch(options);
    }

    return false;
  }
}