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
import '../paper/paper_listview.dart';
import 'question_listview.dart';

class QuestionsMain extends ConsumerStatefulWidget {
  const QuestionsMain({super.key});

  @override
  ConsumerState<QuestionsMain> createState() => _QuestionsMainState();
}

class _QuestionsMainState extends ConsumerState<QuestionsMain> {
  int? _categoryId = ALL_CATEGORY;
  Question? _currentQuestion; // 新增：当前题目

  @override
  void initState() {
    super.initState();
  }

  // 显示当前题目答案
  void _showCurrentQuestionAnswer() {
    if (_currentQuestion == null) {
      final questions = ref.watch(questionsProvider).value ?? [];
      _currentQuestion = questions[0];
    }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
              context.push('/admin/addQuestion');
            },
            tooltip: '添加题目',
          ),
        ],
      ),
      body: QuestionListview(
        onCurrentQuestionChanged: (Question? question) {
          setState(() {
            _currentQuestion = question;
          });
        },
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
