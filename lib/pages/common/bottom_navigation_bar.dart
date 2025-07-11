import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  // 使用 GetX 的控制器来管理状态
  CustomBottomNavigationBar({super.key}) {
    // 根据当前路由设置初始索引
  }

  int _calculateSelectedIndex(BuildContext context) {
    // final GoRouter route = GoRouter.of(context);
    final currentRoute = GoRouterState.of(context);
    String? path = currentRoute.path;
    int _currentIndex = 0;
    if (path == '/culture') {
      _currentIndex = 0;
    } else if (path == '/knowledge') {
      _currentIndex = 1;
    } else if (path == '/questions') {
      _currentIndex = 2;
    } else if (path == '/profile') {
      _currentIndex = 3;
    }

    return _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 明确设置为 fixed 类型
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: '数学世界',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: '知识树',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: '题库',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
      currentIndex: _calculateSelectedIndex(context), // 动态绑定当前选中的索引
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue, // 选中项的颜色
      unselectedItemColor: Colors.grey, // 未选中项的颜色
      showSelectedLabels: true, // 确保显示选中项的标签
      showUnselectedLabels: true, // 确保显示未选中项的标签
      onTap: (int index) {
        // 根据索引跳转到不同的页面
        switch (index) {
          case 0:
            context.go('/culture'); // 使用 offAllNamed 替换 toNamed
            break;
          case 1:
            context.go('/knowledge');
            break;
          case 2:
            context.go('/questions');
            break;
          case 3:
            context.go('/profile');
            break;

        }
      },
    );
  }
}
