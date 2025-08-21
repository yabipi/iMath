import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:imath/models/question.dart'; // 新增：导入Question类
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/pages/common/knowledge_tree.dart';
import 'package:imath/state/global_state.dart';
import 'package:imath/state/questions_provider.dart';
import 'package:imath/state/settings_provider.dart';

import 'question_listview.dart';

class QuestionsMain extends ConsumerStatefulWidget {
  const QuestionsMain({super.key});

  @override
  ConsumerState<QuestionsMain> createState() => _QuestionsMainState();
}

class _QuestionsMainState extends ConsumerState<QuestionsMain> {
  int? _categoryId = ALL_CATEGORY;
  // Question? _currentQuestion; // 新增：当前题目

  @override
  void initState() {
    super.initState();
  }

  // 显示当前题目答案
  void _showCurrentQuestionAnswer() {
    Question? _currentQuestion = ref.watch(currentQuestionProvider);
    // 跳转到答案页面
    context.push('/admin/viewAnswer', extra: _currentQuestion);
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (_categoryId == ALL_CATEGORY) {
      title = ref.watch(mathLevelProvider).value;
    } else {
      title = GlobalState.get(CATEGORIES_KEY)[_categoryId.toString()];
    }
    final total = ref.watch(questionsTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // 答案图标
          IconButton(
            icon: const Icon(Icons.question_answer_rounded),
            onPressed: _showCurrentQuestionAnswer, // 修改：连接到答案查看方法
            tooltip: '查看答案',
          ),
          // 考试图标
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              // TODO: 实现考试功能
            },
            tooltip: '开始考试',
          ),
          // 编辑图标
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Question? _currentQuestion = ref.watch(currentQuestionProvider);
              context.push('/admin/editQuestion?questionId=${_currentQuestion?.id!}');
            },
            tooltip: '添加题目',
          ),
        ],
      ),
      body: Column(
        children: [
          // 页面指示器行
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final currentQuestion = ref.watch(currentQuestionProvider);
                final questions = ref.watch(questionsProvider).value ?? [];
                int currentIndex = 0;

                if (currentQuestion != null && questions.isNotEmpty) {
                  currentIndex =
                      questions.indexWhere((q) => q.id == currentQuestion.id);
                  if (currentIndex == -1) currentIndex = 0;
                }

                return Text(
                  "第${currentIndex + 1}题/共${total}题",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                );
              },
            ),
          ),
          // 题目内容
          Expanded(
            child: QuestionListview(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      // 新增：侧边栏 Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '知识树',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            KnowledgeTree(onChangeCategory: (categoryId) {
              setState(() {
                this._categoryId = categoryId;
                ref
                    .read(questionsProvider.notifier)
                    .onChangeCategory(categoryId);
                Navigator.pop(context); // 关闭drawer
              });
            })
          ],
        ),
      ),
    );
  }
}
