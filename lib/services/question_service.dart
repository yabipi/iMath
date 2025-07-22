import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:imath/config/api_config.dart';
import 'package:imath/models/question.dart';
import 'package:imath/models/quiz.dart';

class QuestionService {
  static Future<List<Question>?> loadQuestions(int pageNo) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.SERVER_BASE_URL}/api/questions?pageNo=$pageNo&pageSize=100'),
      );

      if (response.statusCode == 200) {
        // final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> data = jsonDecode(
            const Utf8Decoder().convert(response.body.runes.toList()));
        final List<dynamic> content = data['content'] ?? [];

        final questions = content
            .map((json) {
              try {
                return Question.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Question>()
            .toList();
        return questions;
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      return null;
    }
  }
}
