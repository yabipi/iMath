
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/models/question.dart';
import 'package:imath/models/quiz.dart';

import 'init.dart';

class QuestionHttp {
  static Future getQuestions() async {

  }

  static Future loadQuestions({int? categoryId=ALL_CATEGORY, int? pageNo=1, int? pageSize=10, String? level}) async {
    final url = '${ApiConfig.SERVER_BASE_URL}/api/question/list?categoryId=${categoryId}&pageNo=$pageNo&pageSize=$pageSize&level=${level}';
    final response = await Request().get(url);
    return response.data;
  }

  static FutureOr<Question?> getQuestion(int questionId) async {
    try {
      final response = await Request().get(
          '${ApiConfig.SERVER_BASE_URL}/api/question/${questionId}'
      );

      if (response.statusCode == 200) {
        final question = Question.fromJson(response.data);
        return question;
      }
    } catch  (e) {
      return null;
    }
  }

  static Future<void> updateQuestion(int questionId, Map<String, dynamic> question) async {
    try {
      final response = await Request().put(
        '${ApiConfig.SERVER_BASE_URL}/api/question/${questionId}',
        options: Options(contentType: Headers.jsonContentType),
        data: question,
      );

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('题目更新成功')),
        // );
        // Navigator.pop(context, true);

        // 调用回调函数刷新题目列表
        // widget.onQuestionUpdated?.call();
      } else {
        throw Exception('Failed to update question');
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('更新失败: $e')),
      // );
    } finally {
      // setState(() {
      //   _isSubmitting = false;
      // });
    }
  }
}