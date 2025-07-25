import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
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

  @override
  void initState() {
    super.initState();
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
      ),
      body: QuestionListview(),
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
            KnowledgeTree(level: MATH_LEVEL.Primary, onChangeCategory: (categoryId){
              setState(() {
                this._categoryId = categoryId;
                ref.read(questionsProvider.notifier).onChangeCategory(categoryId);
                Navigator.pop(context); // 关闭drawer
              });
            })
          ],
        ),
      ),
    );
  }
}