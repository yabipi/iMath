import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imath/controllers/login_controller.dart';
import 'package:imath/core/context.dart';
import 'package:imath/widgets/bottom_navigation_bar.dart';
import '../../models/user.dart';
import '../../controllers/user_controller.dart';
import 'login_screen.dart';
import '../admin/camera_screen.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends GetView<LoginController> {
  late User? user;
  // final _authService = const UserController();

  ProfileScreen({
    super.key,
    this.user,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      await controller.logout();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退出登录失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.user == null) {
      this.user = Context().getCurrentUser();
      // this.user = Get.arguments['user'] as User?;
    }
    if(this.user == null)
      return LoginScreen();
    else return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () => _logout(context),
          // ),
        ],
      ),
      body: buildProfilePanel(context),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
  
  Widget buildProfilePanel(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 用户信息卡片
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                // 头像
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  user?.avatar != null ? NetworkImage((user?.avatar)!) : null,
                  child: user?.avatar == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                // 用户名
                Text(
                  (user?.name)!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // 手机号
                if (user?.phone != null)
                  Text(
                    (user?.phone)!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          // 功能列表
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照识别'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('帮助与反馈'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到帮助页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于我们'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 导航到关于页面
              Get.toNamed('/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('退出登录'),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              // 导航到关于页面
              // Get.toNamed('/about');
              _logout(context);
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
