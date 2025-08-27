import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/services/auth_service.dart';
import 'package:imath/utils/phone_validator.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<PhoneLoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户登录'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      // 使用SafeArea包裹内容，避免与刘海屏、状态栏等重叠
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsGeometry.only(top: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 第一行：国家/地区选择
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       '国家/地区',
              //       style: TextStyle(
              //         fontSize: 16,
              //         color: Colors.grey[700],
              //       ),
              //     ),
              //     const SizedBox(width: 8),
              //     GestureDetector(
              //       onTap: () {
              //         // 这里可弹出选择框让用户选择国家/地区代码，示例中简单模拟切换
              //         setState(() {
              //           _countryCode = _countryCode == '+86' ? '+1' : '+86';
              //         });
              //       },
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //         height: 56,
              //         decoration: BoxDecoration(
              //           border: Border.all(color: Colors.grey.shade300),
              //           // borderRadius: BorderRadius.circular(6),
              //         ),
              //         child: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text(
              //               _countryCode == '+86' ? '中国大陆' : '其他',
              //               style: const TextStyle(
              //                 fontSize: 14,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             const SizedBox(width: 4),
              //             const Icon(
              //               Icons.arrow_drop_down,
              //               size: 16,
              //               color: Colors.grey,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 16),

              // 用户名输入框
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _phoneController, // 复用现有的controller，但用于用户名
                  decoration: InputDecoration(
                    hintText: '请输入用户名',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    isDense: true, // 减少内部间距
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 12),
              // 密码输入框
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _passwdController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '请输入密码',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    isDense: true, // 减少内部间距
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
              ),
              // 手机号说明文字
              // const SizedBox(height: 8),
              // Text(
              //   '当前仅支持中国大陆手机号登录，新用户首次验证通过后即自动完成注册',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.grey.shade500,
              //   ),
              // ),
              const SizedBox(height: 24),

              // 登录按钮 - 适配字体宽度
              Container(
                constraints: const BoxConstraints(
                  minWidth: 120,
                  minHeight: 48,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // 这里可处理登录逻辑，比如校验用户名、调用接口等
                    String username = _phoneController.text.trim();
                    String passwd = _passwdController.text.trim();
                    if (username.isNotEmpty) {
                      // 调用登录接口
                      final res =
                          await AuthHttp.signIn(username, passwd) as Map;
                      if (res['code'] == ApiCode.NEW_USER) {
                        // 新用户需要验证手机号是否合法
                        SmartDialog.showToast('用户不存在，请先注册');
                        context.go('/register');
                      } else if (res['code'] == 104) {
                        // USER_NOT_FOUND
                        SmartDialog.showToast('用户名不存在');
                      } else if (res['code'] == 105) {
                        // INVALID_CREDENTIALS
                        SmartDialog.showToast('密码错误');
                      } else if (res['code'] == ApiCode.INTERNAL_SERVER_ERROR) {
                        SmartDialog.showToast(res['message']);
                      } else if (res['code'] == ApiCode.SUCCESS) {
                        AuthService.saveUser(res);
                        // 登录成功，跳转到用户中心
                        context.go('/profile');
                      } else {
                        // 处理其他错误情况
                        SmartDialog.showToast(res['message'] ?? '登录失败，请重试');
                      }
                    } else {
                      SmartDialog.showToast('请输入用户名');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 注册和忘记密码链接
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.go('/register');
                    },
                    child: Text(
                      '注册',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/forgot-password');
                    },
                    child: Text(
                      '忘记密码',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwdController.dispose();
    super.dispose();
  }
}
