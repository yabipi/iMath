import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/login_controller.dart';
// 新增：导入通用导航栏组件
import '../../widgets/bottom_navigation_bar.dart';

// extends GetView<LoginController>
class LoginScreen extends StatelessWidget{
  late LoginController controller;
  late TabController tabController;

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller = LoginController(context);
    tabController =  TabController(length: 3, vsync: Navigator.of(context));
    final _formKey = GlobalKey<FormState>();

    bool _isLoading = false;
    bool _showCodeInput = false;
    int _countdown = 60;
    Timer? _timer;
    bool mounted = false;

    void _startCountdown() {
      _countdown = 60;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('用户登录'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 480, // 设置TabBar宽度
              child: TabBar(
                controller: tabController,
                tabs: [
                  Tab(icon: Icon(Icons.wechat), text: '微信'),
                  Tab(icon: Icon(Icons.phone), text: '手机号'),
                  Tab(icon: Icon(Icons.person), text: '用户名'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                        width: 380, // 设置宽度为屏幕宽度的80%
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 280, height: 280,
                                child:QrImageView(
                                  data: 'xxx',
                                  backgroundColor: Colors.white,
                                )
                            )
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: SizedBox(
                            width: 380, // 设置宽度为屏幕宽度的80%
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      controller: controller.phoneController,
                                      decoration: const InputDecoration(
                                        labelText: '手机号',
                                        prefixIcon: Icon(Icons.phone),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '请输入手机号';
                                        }
                                        if (!RegExp(r'^1[3-9]\d{9}$')
                                            .hasMatch(value)) {
                                          return '请输入正确的手机号';
                                        }
                                        return null;
                                      },
                                    )
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                      Spacer(),
                                      SizedBox(
                                          width: 160,
                                          child: TextFormField(
                                            controller: controller.codeController,
                                            decoration: const InputDecoration(
                                              labelText: '验证码',
                                              prefixIcon: Icon(Icons.lock),
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return '请输入验证码';
                                              }
                                              if (value.length != 6) {
                                                return '验证码必须是6位数字';
                                              }
                                              return null;
                                            },
                                          )
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          onPressed:
                                              _countdown > 0 ? null : controller.sendCode,
                                          child: Text(
                                            _countdown > 0
                                                ? '${_countdown}s'
                                                : '获取验证码',
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : controller.loginWithPhoneCode,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('登录'),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => context.go('/verifycode'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('获取验证码'),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: SizedBox(
                          width: 380, // 设置宽度为屏幕宽度的80%
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    controller: controller.emailController,
                                    decoration: const InputDecoration(
                                      labelText: '邮箱',
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '请输入邮箱';
                                      }
                                      return null;
                                    },
                                  )),
                              const SizedBox(height: 16),
                              SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    controller: controller.passwordController,
                                    decoration: const InputDecoration(
                                      labelText: '密码',
                                      prefixIcon: Icon(Icons.lock),
                                      border: OutlineInputBorder(),
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '请输入密码';
                                      }
                                      return null;
                                    },
                                  )),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : controller.login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('登录'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 新增：添加底部导航栏
      // bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}