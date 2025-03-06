import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/quiz.dart';
import 'quiz_detail_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('题库'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '小学'),
              Tab(text: '中学'),
              Tab(text: '大学'),
              Tab(text: '考试'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 小学题库
            _buildQuizList('小学'),
            // 中学题库
            _buildQuizList('中学'),
            // 大学题库
            _buildQuizList('大学'),
            // 考试题库
            _buildExamList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList(String category) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.quiz),
            title: Text('$category数学题 ${index + 1}'),
            subtitle: const Text('题目预览...'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到题目详情页
            },
          ),
        );
      },
    );
  }

  Widget _buildExamList(BuildContext context) {
    return ListView(
      children: [
        _buildExamCard(
          context,
          '奥数',
          Icons.emoji_events,
          () {
            // 生成奥数试卷
          },
        ),
        _buildExamCard(
          context,
          '高考数学',
          Icons.school,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizDetailScreen(quiz: sampleQuiz),
              ),
            );
          },
        ),
        _buildExamCard(
          context,
          '考研数学',
          Icons.school,
          () {
            // 生成考研数学试卷
          },
        ),
      ],
    );
  }

  Widget _buildExamCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: const Text('点击生成试卷'),
        trailing: const Icon(Icons.add),
        onTap: onTap,
      ),
    );
  }
} 