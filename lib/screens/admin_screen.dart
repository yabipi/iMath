import 'package:flutter/material.dart';
import 'add_paper_screen.dart';
import 'add_question_screen.dart';
import 'add_knowledge_screen.dart';
import 'latex_test_screen.dart';
import 'draggable_tree_screen.dart';
import 'package:imath/screens/paper_screen.dart';

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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('LaTeX测试'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LatexTestScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('知识点树'),
            subtitle: const Text('管理知识点树结构'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DraggableTreeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('测试试卷'),
            subtitle: const Text('管理试卷内容'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaperScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
