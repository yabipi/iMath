import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';

import 'package:imath/controllers/login_controller.dart';
import 'package:imath/core/context.dart';
import 'package:imath/db/Storage.dart';
import 'package:imath/pages/common/bottom_navigation_bar.dart';
import 'package:imath/state/global_state.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../models/user.dart';
import '../../controllers/user_controller.dart';
import 'login_screen.dart';
import '../admin/camera_screen.dart';
import '../admin/admin_screen.dart';
import 'login.dart';

class ProfileScreen extends ConsumerWidget {
  late LoginController controller;

  ProfileScreen({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLogged = ref.watch(loggingStateProvider);
    if (!isLogged)
      return LoginPage();
    controller = LoginController(context);
    final user = GlobalState.currentUser;

    return Scaffold(
        appBar: AppBar(
          title: const Text('个人中心'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.logout),
            //   onPressed: () => _logout(context),
            // ),
          ],
        ),
        body: buildProfilePanel(context, ref),
        bottomNavigationBar: CustomBottomNavigationBar(),
      );
  }

  Widget buildProfilePanel(BuildContext context, WidgetRef ref) {
    final user = GlobalState.currentUser;
    return SingleChildScrollView(
      child: Column(
        children: [
          // 用户信息卡片
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                // 头像
                GestureDetector(
                  onTap: () {
                    // 导航到头像编辑页面
                    context.push('/profile/avatarEdit', extra: user);
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            user?.avatar != null && user!.avatar!.length > 0
                                ? MemoryImage(base64Decode(user!.avatar!))
                                : null,
                        child: user?.avatar == null || user!.avatar!.length == 0
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 昵称
                      Text(
                        (user?.username)!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ID号和等级分
                      Row(
                        children: [
                          Text(
                            'ID号: ${user?.id ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '等级分: 1000',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 功能列表
          // ListTile(
          //   leading: const Icon(Icons.camera_alt),
          //   title: const Text('拍照识别'),
          //   trailing: const Icon(Icons.arrow_forward_ios),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const CameraScreen(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('学习历史'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到学习历史页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('我的收藏'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到收藏页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到设置页面
              context.go('/profile/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            // title: const Text('修改密码'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到修改密码页面
              context.push('/profile/change-password');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('意见反馈'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到意见反馈页面
              context.push('/profile/feedback');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('使用帮助'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到关于页面
              context.go('/profile/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于我们'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到关于页面
              context.go('/profile/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('退出登录'),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              _logout(context);
              ref.read(loggingStateProvider.notifier).state = false;
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.add_circle_outline),
          //   title: const Text('添加试卷'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const AddPaperScreen(),
          //       ),
          //     );
          //   },
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('管理员入口'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/admin');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await controller.logout();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退出登录失败：$e')),
        );
      }
    }
  }
}
