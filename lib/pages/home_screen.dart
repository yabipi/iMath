import 'package:flutter/material.dart';
import 'package:imath/core/context.dart';
import 'package:imath/pages/questions_screen.dart';
import 'package:imath/widgets/bottom_navigation_bar.dart';
// import 'package:imath/screens/quiz_screen.dart';
import 'admin_screen.dart';
import 'culture_screen.dart';
import 'knowledge_screen.dart';
// import '../screens/culture_screen.dart';
import 'paper_listview.dart';
// import 'quiz_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../models/user.dart';
import 'package:imath/pages/slide_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? _currentUser = null;

  final List<Widget> _screens = [
    const KnowledgeScreen(),
    const CultureScreen(),
    const QuestionsScreen(),
    ProfileScreen(),
    // const AdminScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 获取当前用户
    _currentUser = Context().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text('Home'),
      bottomNavigationBar: CustomBottomNavigationBar(),
      // BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.school),
      //       label: '知识点',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.history),
      //       label: '数学文化',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.quiz),
      //       label: '题库',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: '我的',
      //     ),
      //     // BottomNavigationBarItem(
      //     //   icon: Icon(Icons.edit_sharp),
      //     //   label: '管理',
      //     // ),
      //   ],
      // ),
    );
  }
}
