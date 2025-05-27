import 'package:flutter/material.dart';
import 'package:imath/screens/questions_screen.dart';
// import 'package:imath/screens/quiz_screen.dart';
import 'admin_screen.dart';
import 'knowledge_screen.dart';
import 'history_screen.dart';
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
    const HistoryScreen(),
    const QuestionsScreen(),
    const ProfileScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 3
          ? (_currentUser != null
              ? ProfileScreen(user: _currentUser!)
              : const LoginScreen())
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '知识点',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '数学文化',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '题库',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_sharp),
            label: '管理',
          ),
        ],
      ),
    );
  }
}
