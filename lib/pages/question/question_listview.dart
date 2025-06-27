import 'package:flutter/material.dart';

import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/components/category_panel.dart';

import 'package:imath/components/math_cell.dart';
import 'package:imath/pages/question/controller.dart';

import '../../config/constants.dart';
import '../../core/context.dart';
import '../../models/quiz.dart';


class QuestionListview extends StatefulWidget {
  const QuestionListview({super.key});

  @override
  State<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends State<QuestionListview> {
  // final List<Question> controller.questions = [];
  final Map<int, bool> _expandedStates = {};
  late final QuestionController controller;
  bool _isLoading = false;

  bool _hasMore = true;
  // int? _selectedCategoryId = -1;
  bool _isSlidingMode = true; // 新增：滑动模式开关

  @override
  void initState() {
    super.initState();

    // _loadMoreQuestions(categoryId: -1);
  }


  Widget _buildQuestionCard(Question question, int index) {
    if (question.title == null) {
      return const Card(
        child: ListTile(
          title: Text('无效的题目数据'),
        ),
      );
    }

    bool isExpanded = _expandedStates[index] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${index + 1}题',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            MathCell(
              content: question.content ?? '',
            ),
            const SizedBox(height: 4),
            MathCell(
              content: question.options ?? '',
            ),
            // GptMarkdown(
            //   question.options??'',
            //   style: const TextStyle(color: Colors.black),
            // ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedStates[index] = !isExpanded;
                    });
                  },
                  child: Text(isExpanded ? '收起详情' : '查看详情'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // 跳转到问题编辑页面
                    // Get.toNamed('/editquestion', arguments: {'questionId': question.id});
                  },
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(),
              const Text(
                '解析和答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              MathCell(title:  '', content: question.answer ??''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlidingQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${controller.questions.indexOf(question) + 1}题',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
            MathCell(
              content: question.content ?? '',
            ),
            // GptMarkdown(
            //   question.content ?? '',
            //   style: const TextStyle(color: Colors.black),
            // ),
            const SizedBox(height: 4),
            MathCell(
              content: question.options ?? '',
            ),
            // GptMarkdown(
            //   question.options ?? '',
            //   style: const TextStyle(color: Colors.black),
            // ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedStates[controller.questions.indexOf(question)] =
                          !(_expandedStates[controller.questions.indexOf(question)] ?? false);
                    });
                  },
                  child: Text(
                    _expandedStates[controller.questions.indexOf(question)] ?? false
                        ? '收起详情'
                        : '查看详情',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Get.toNamed('/editquestion', arguments: {'questionId': question.id});
                  },
                ),
              ],
            ),
            if (_expandedStates[controller.questions.indexOf(question)] ?? false) ...[
              const Divider(),
              const Text(
                '解析和答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // const SizedBox(height: 4),
              // MathCell(title: question.title ?? '', content: question.content ?? ''),
              // const SizedBox(height: 8),
              // const Text(
              //   '答案:',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              const SizedBox(height: 4),
              MathCell(title: '', content: question.answer ??''),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller = QuestionController(context);
    return FutureBuilder(
        future: controller.loadMoreQuestions(),
        builder: (context, snapshot){
          List list = controller.questions;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CategoryPanel(onItemTap: (int categoryId) {onChangeCategory(categoryId);}),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                ],
              ),
              Expanded(
                child: _isSlidingMode
                    ? PageView.builder(
                        scrollDirection: Axis.vertical, // 修改：将滑动方向改为垂直
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return _buildSlidingQuestionCard(list[index]);
                        },
                    )
                    :
                      ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: list.length + 1,
                        itemBuilder: (context, index) {
                          if (index == list.length) {
                            if (_isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (_hasMore) {
                              return Center(
                                child: TextButton(
                                  onPressed: () => controller.loadMoreQuestions(),
                                  child: const Text('加载更多'),
                                ),
                              );
                            }
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('没有更多题目了'),
                              ),
                            );
                  }
                  return _buildQuestionCard(list[index], index);
                },
                )),

            ],
          );
        });

  }

  void onChangeCategory(int categoryId) {
    controller.onChangeCategory(categoryId as int);
  }
}
