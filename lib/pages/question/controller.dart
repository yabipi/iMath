import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:imath/http/question.dart';
import 'package:imath/models/quiz.dart';

class QuestionController extends GetxController {

  late int questionId;

  //分页查询
  int? categoryId;
  int _currentPage = 1;
  final Question question  = Question(id: -1);

  RxList<Question> questions = <Question>[].obs;
  Rx<TextEditingController> contentController = TextEditingController().obs;
  Rx<TextEditingController> optionsController = TextEditingController().obs;
  Rx<TextEditingController> answerController = TextEditingController().obs;

  RxInt selectedBranch = 0.obs;
  RxString selectedType = QuestionTypes[0].obs;
  List<String> selectedImages = [];

  // 获取全局 Context 实例
  late final categories;

  Future<dynamic>? loadQuestionFuture;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    categories = Context.get(CATEGORIES_KEY);
  }

  // 加载题目数据
  Future loadQuestion() async {
    try {
      final question = await QuestionHttp.getQuestion(questionId);
      contentController.value.text = question.content ?? '';
      optionsController.value.text = question.options ?? '';
      answerController.value.text = question.answer ?? '';
      if (question.category == '') {
        selectedBranch.value = (categories?.keys.first)!;
      } else {
        selectedBranch.value = categories?.keys.firstWhere((key) => categories![key] == question.category) ;
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
      print("selected branch is ${selectedBranch.value}");
      // 构建选项数据
      // List<Map<String, String>> options = [];

      QuestionHttp.updateQuestion(questionId, {
        'category': categories[selectedBranch.value],
        'content': contentController.value.text,
        'options': optionsController.value.text,
        'answer': answerController.value.text,
      });
      questions.value.clear();
      _currentPage--;
      // loadMoreQuestions(pageNo: 1, pageSize: 10);
      Get.offAllNamed('/questions');

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
