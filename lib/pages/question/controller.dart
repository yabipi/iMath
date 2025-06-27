import 'package:flutter/material.dart';

import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:imath/http/question.dart';
import 'package:imath/models/quiz.dart';

class QuestionController {

  late int questionId;

  //分页查询
  int? categoryId;
  int _currentPage = 1;
  final Question question  = Question(id: -1);

  List<Question> questions = <Question>[];
  TextEditingController contentController = TextEditingController();
  TextEditingController optionsController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  int selectedBranch = 0;
  String selectedType = QuestionTypes[0];
  List<String> selectedImages = [];

  // 获取全局 Context 实例
  late final categories;

  Future<dynamic>? loadQuestionFuture;

  QuestionController(BuildContext context) {
    categories = context.get(CATEGORIES_KEY);
  }

  // 加载题目数据
  Future loadQuestion() async {
    try {
      final question = await QuestionHttp.getQuestion(questionId);
      contentController.text = question.content ?? '';
      optionsController.text = question.options ?? '';
      answerController.text = question.answer ?? '';
      if (question.category == '') {
        selectedBranch = (categories?.keys.first)!;
      } else {
        selectedBranch = categories?.keys.firstWhere((key) => categories![key] == question.category) ;
      }

      selectedType = (question.type??'').isEmpty ? QuestionTypes[0] : question.type!;
      selectedImages = question.images?.split(',') ?? [];

      return question;

    } catch (e) {
      return null;
    }
  }

  Future? loadMoreQuestions({int? categoryId, int? pageNo, int? pageSize}) async {
    final response = await QuestionHttp.loadQuestions(categoryId: categoryId??-1, pageNo: _currentPage, pageSize:  pageSize??10);
    final content = response['data'] ?? [];

    final _questions = content.map<Question?>((json) {
      try {
        return Question.fromJson(json);
      } catch (e) {
        return null;
      }
    })
        .whereType<Question>()
        .toList();
    // 更新
    questions.addAll(_questions);
    _currentPage ++;
  }

  // 提交题目编辑
  Future<void> updateQuestion() async {
    try {
      print("selected branch is ${selectedBranch}");
      // 构建选项数据
      // List<Map<String, String>> options = [];

      QuestionHttp.updateQuestion(questionId, {
        'category': categories[selectedBranch],
        'content': contentController.text,
        'options': optionsController.text,
        'answer': answerController.text,
      });
      questions.clear();
      _currentPage--;
      // loadMoreQuestions(pageNo: 1, pageSize: 10);
      // context.go('/questions');

      //   data: {
      //     'title': _titleController.text,
      //     'content': _contentController.text,
      //     'answer': _answerController.text,
      //     'category': categories?[_selectedBranch],
      //     'type': _selectedType,
      //     'options': options,
      //     'images': _selectedImages.join(','),
      //   },
      // );


    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('更新失败: $e')),
      // );
      rethrow;
    } finally {

    }
  }

  Future? onChangeCategory(int? _categoryId) async {
    categoryId = _categoryId;
    _currentPage = 1;
    questions.clear();
    await loadMoreQuestions(categoryId: _categoryId);
  }
}
