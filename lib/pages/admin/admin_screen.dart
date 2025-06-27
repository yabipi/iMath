import 'package:flutter/material.dart';

import 'package:imath/pages/admin/camera_screen.dart';
import 'package:imath/pages/admin/pdf_uploader.dart';
import '../paper/add_paper_screen.dart';
import '../question/add_question.dart';

import '../knowledge/add_knowledge.dart';
import '../culture/add_mathematician.dart';  // 新增导入

import 'package:imath/demo/draggable_tree_screen.dart';
import 'package:imath/demo/paper_screen.dart';
import 'package:imath/pages/admin/test_functions.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('后台管理'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('添加知识点'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Get.toNamed('/addknow');
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
                  builder: (context) => AddQuestionScreen(paperId: -1),
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
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const LatexTestScreen(),
              //   ),
              // );
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
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('功能测试'),
            subtitle: const Text('各种功能测试'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestFunctionsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('添加数学家'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMathematicianScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF扫描上传'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfUploader(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('拍照识题'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}