import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/core/context.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新用户注册'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '用户名'),
              maxLength: 20,
              // counterText: '', // 隐藏字符计数器
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密码'),
              obscureText: true,
              maxLength: 20,
              // counterText: '', // 隐藏字符计数器
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: '确认密码'),
              obscureText: true,
              maxLength: 20,
              // counterText: '', // 隐藏字符计数器
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 注册逻辑
                String username = _usernameController.text;
                String password = _passwordController.text;
                String confirmPassword = _confirmPasswordController.text;

                if (password == confirmPassword) {
                  // 密码匹配，执行注册操作
                  // 这里可以调用注册API或显示成功提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('注册成功')),
                  );
                } else {
                  // 密码不匹配，显示错误提示
                  context.showMsg('两次输入的密码不一致');
                }
              },
              child: Text('注册'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}