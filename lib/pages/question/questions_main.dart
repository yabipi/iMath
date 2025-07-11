import 'package:flutter/material.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/pages/common/knowledge_tree.dart';
import '../paper/paper_listview.dart';
import 'question_listview.dart';

class QuestionsMain extends StatefulWidget {
  const QuestionsMain({super.key});

  @override
  State<QuestionsMain> createState() => _QuestionsMainState();
}

class _QuestionsMainState extends State<QuestionsMain> {
  int? categoryId = ALL_CATEGORY;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (categoryId == ALL_CATEGORY) {
      title = MATH_LEVEL.Primary.value;
    } else {
      title = context.get(CATEGORIES_KEY)[categoryId.toString()];
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
      body: QuestionListview(categoryId: categoryId),
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
                this.categoryId = categoryId;
                Navigator.pop(context); // 关闭drawer
              });
            })
          ],
        ),
      ),
    );
  }
}