import 'package:flutter/material.dart';
import 'add_paper_screen.dart';
import 'add_question_screen.dart';
import 'add_knowledge_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理员入口'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('添加知识点'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddKnowledgeScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('添加试卷'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPaperScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('添加题目'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddQuestionScreen(paperId: -1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 