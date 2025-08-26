import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/core/context.dart';
import 'package:imath/http/auth.dart';
import 'package:imath/utils/phone_validator.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新用户注册'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // 标题
              const Text(
                '创建新账户',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 用户名输入框
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名',
                  prefixIcon: Icon(Icons.person, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 20,
              ),

              const SizedBox(height: 20),

              // 手机号输入框
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 11,
              ),

              const SizedBox(height: 20),

              // 密码输入框
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 20,
              ),

              const SizedBox(height: 20),

              // 确认密码输入框
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  hintText: '请再次输入密码',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 20,
              ),

              const SizedBox(height: 40),

              // 提交按钮
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '注册',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 返回登录链接
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '已有账户？',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: Text(
                      '立即登录',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.w600,
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

  Future<void> _handleRegister() async {
    // 验证输入
    if (_usernameController.text.trim().isEmpty) {
      SmartDialog.showToast('请输入用户名');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      SmartDialog.showToast('请输入手机号');
      return;
    }

    if (!PhoneValidator.isValid(_phoneController.text.trim())) {
      SmartDialog.showToast('请输入合法的手机号码');
      return;
    }

    if (_passwordController.text.isEmpty) {
      SmartDialog.showToast('请输入密码');
      return;
    }

    if (_passwordController.text.length < 6) {
      SmartDialog.showToast('密码长度不能少于6位');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      SmartDialog.showToast('两次输入的密码不一致');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用后台发送验证码
      final result = await AuthHttp.sendCaptcha(_phoneController.text.trim());

      if (result['code'] == 200) {
        SmartDialog.showToast('验证码已发送');
        // 跳转到验证码输入界面，传递注册信息
        context.go(
            '/verifycode?phone=${_phoneController.text.trim()}&password=${_passwordController.text}&username=${_usernameController.text.trim()}&isRegister=true');
      } else if (result['code'] == 102) {
        // PHONE_REGISTERED_API_CODE
        SmartDialog.showToast('该手机号已被注册');
      } else {
        SmartDialog.showToast(result['message'] ?? '发送验证码失败');
      }
    } catch (e) {
      SmartDialog.showToast('网络错误，请重试');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
