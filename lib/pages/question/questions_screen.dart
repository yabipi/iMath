import 'package:flutter/material.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/pages/common/knowledge_tree.dart';
import '../paper/paper_listview.dart';
import 'question_listview.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '分类'),
              Tab(text: '试卷'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 分类Tab：显示数学分支和题目列表
            QuestionListview(),
            // 试卷Tab：显示试卷列表
            PaperListView()
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
              KnowledgeTree(level: MATH_LEVEL.Primary)
            ],
          ),
        ),
      ),
    );
  }
}