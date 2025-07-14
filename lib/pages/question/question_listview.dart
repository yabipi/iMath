import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/pages/common/category_panel.dart';

import 'package:imath/components/math_cell.dart';
import 'package:imath/http/question.dart';

import '../../config/constants.dart';
import '../../core/context.dart';
import '../../models/quiz.dart';


class QuestionListview extends StatefulWidget {
  int? categoryId = ALL_CATEGORY;
  QuestionListview({super.key, this.categoryId});

  @override
  State<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends State<QuestionListview> {
  List<Question> questions = <Question>[];
  final Map<int, bool> _expandedStates = {};

  late PageController _pageController; // 新增：用于监听 PageView 滑动事件
  int? _categoryId;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
    _pageController = PageController(); // 初始化 PageController

    // 监听 PageView 滑动事件
    _pageController.addListener(() {
      if (_pageController.position.pixels == _pageController.position.maxScrollExtent) {
        // 滑动到最底部，加载更多题目
        _loadMoreQuestions();
      }
    });
  }

  // 新增：加载更多题目的方法
  Future<void> _loadMoreQuestions() async {
    await loadMoreQuestions();
  }

  Future? loadMoreQuestions({int? categoryId, int? pageNo, int? pageSize}) async {
    // 更新
    if(categoryId != _categoryId) {
      questions.clear();
      _categoryId = categoryId;
      // setState(() {
      //   _categoryId = categoryId;
      // });
    }
    if(pageNo != null && pageNo > 0) {
      _currentPage = pageNo;
    }

    final response = await QuestionHttp.loadQuestions(categoryId: categoryId?? ALL_CATEGORY, pageNo: _currentPage, pageSize:  pageSize??10);
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

    questions.addAll(_questions);
    _currentPage ++;
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

    return SingleChildScrollView(
      // margin: const EdgeInsets.only(bottom: 16.0),
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
                  child: Text(isExpanded ? '收起解答' : '查看解答'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.go('/admin/editQuestion?questionId=${question.id}');
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
              '第${questions.indexOf(question) + 1}题',
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
                      _expandedStates[questions.indexOf(question)] =
                          !(_expandedStates[questions.indexOf(question)] ?? false);
                    });
                  },
                  child: Text(
                    _expandedStates[questions.indexOf(question)] ?? false
                        ? '收起解答'
                        : '查看解答',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                      context.go('/admin/editQuestion?questionId=${question.id}');
                  }
                  ),

              ],
            ),
            if (_expandedStates[questions.indexOf(question)] ?? false) ...[
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

  Widget _buildQuestionsPageView() {
    return PageView.builder(
          controller: _pageController, // 使用自定义的 PageController
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return _buildQuestionCard(questions[index], index);
          },
      );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder(
          future: loadMoreQuestions(categoryId: widget.categoryId, pageNo: 1, pageSize: 10),
          builder: (context, snapshot){
            // List list = questions;
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  context.go('/admin/addQuestion');
                },
                child: const Icon(Icons.add),
              ),
              body: Stack(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: CategoryPanel(onItemTap: (int categoryId) {onChangeCategory(categoryId);}),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ],
                  ),
                  _buildQuestionsPageView()
                  // Expanded(
                  //   child:
                  // )
                  // _isSlidingMode
                  //     ? PageView.builder(
                  //         scrollDirection: Axis.vertical, // 修改：将滑动方向改为垂直
                  //         itemCount: list.length,
                  //         itemBuilder: (context, index) {
                  //           return _buildSlidingQuestionCard(list[index]);
                  //         },
                  //     )
                  //     :
                  //       ListView.builder(
                  //         padding: const EdgeInsets.all(16.0),
                  //         itemCount: list.length + 1,
                  //         itemBuilder: (context, index) {
                  //           if (index == list.length) {
                  //             if (_isLoading) {
                  //               return const Center(
                  //                 child: Padding(
                  //                   padding: EdgeInsets.all(16.0),
                  //                   child: CircularProgressIndicator(),
                  //                 ),
                  //               );
                  //             }
                  //             if (_hasMore) {
                  //               return Center(
                  //                 child: TextButton(
                  //                   onPressed: () => controller.loadMoreQuestions(),
                  //                   child: const Text('加载更多'),
                  //                 ),
                  //               );
                  //             }
                  //             return const Center(
                  //               child: Padding(
                  //                 padding: EdgeInsets.all(16.0),
                  //                 child: Text('没有更多题目了'),
                  //               ),
                  //             );
                  //   }
                  //   return _buildQuestionCard(list[index], index);
                  // },
                  // )),

                ],
              ),
            );
          })
    );
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      print('refresh');
      setState(() {});
    });
  }


  Future? onChangeCategory(int? _categoryId) async {
    _currentPage = 1;
    questions.clear();
    await loadMoreQuestions(categoryId: _categoryId);
  }
}