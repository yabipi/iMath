import 'package:flutter/material.dart';
import 'package:imath/widgets/bottom_navigation_bar.dart';
import 'paper_listview.dart';
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
          title: const Text('题目管理'),
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
            // _isPapersLoading
            //     ? const Center(child: CircularProgressIndicator())
            //     : PaperListView()

          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }
}
