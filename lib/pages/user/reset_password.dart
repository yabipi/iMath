import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/http/auth.dart';
import 'package:imath/http/payload.dart';
import 'package:imath/constant/errors.dart';

class ResetPasswordPage extends StatefulWidget {
  final String phone;
  final String verificationToken;

  const ResetPasswordPage(
      {Key? key, required this.phone, required this.verificationToken})
      : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('重置密码'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/forgot-password');
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

              // 图标
              Icon(
                Icons.lock_open,
                size: 80,
                color: Colors.green.shade400,
              ),

              const SizedBox(height: 24),

              // 标题
              const Text(
                '设置新密码',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 说明文字
              Text(
                '请设置您的新密码，密码长度不能少于6位',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 新密码输入框
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '新密码',
                  hintText: '请输入新密码',
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

              // 确认新密码输入框
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  hintText: '请再次输入新密码',
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

              // 确认按钮
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
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
                          '确认',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    // 验证输入
    if (_passwordController.text.isEmpty) {
      SmartDialog.showToast('请输入新密码');
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

    // 验证verification_token是否存在
    if (widget.verificationToken.isEmpty) {
      SmartDialog.showToast('验证令牌无效，请重新验证');
      context.go('/forgot-password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用重置密码的API
      final ResponseData result = await AuthHttp.resetPassword(
        widget.phone,
        _passwordController.text,
        widget.verificationToken,
      );

      if (result.code == SUCCESS) {
        SmartDialog.showToast('密码重置成功');

        // 延迟一下再跳转，让用户看到成功提示
        await Future.delayed(Duration(milliseconds: 500));

        // 跳转到登录页面
        context.go('/login');
      } else {
        SmartDialog.showToast(result.msg);
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
