import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/constant/errors.dart';
import 'package:imath/core/context.dart';
import 'package:imath/http/auth.dart';
import 'package:imath/http/payload.dart';
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
  final usernameFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  bool _isLoading = false;
  bool _agreedToTerms = false; // 是否同意协议

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usernameFocusNode.addListener(() async {
      if (!usernameFocusNode.hasFocus) {
        // 输入框失去焦点时，检查用户名是否为空
        if (_usernameController.text.isEmpty) {
          SmartDialog.showToast('请输入用户名');
          return;
        }
        ResponseData response = await AuthHttp.checkUsername(_usernameController.text);
        print(response.msg);
        SmartDialog.showToast(response.msg);
      }
    });
    phoneFocusNode.addListener(() async {
      if (!phoneFocusNode.hasFocus) {
        // 输入框失去焦点时，检查手机号是否为空
        if (_phoneController.text.isEmpty) {
          SmartDialog.showToast('请输入手机号');
          return;
        }
        ResponseData response = await AuthHttp.checkPhone(_phoneController.text);
        SmartDialog.showToast(response.msg);
      }
    });
  }

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
              const SizedBox(height: 10),
              // 标题
              // 用户名输入框
              TextField(
                controller: _usernameController,
                focusNode: usernameFocusNode,
                decoration: InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名, 长度不少于3个字符',
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
                focusNode: phoneFocusNode,
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

              const SizedBox(height: 20),

              // 用户协议勾选选项
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreedToTerms = !_agreedToTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        children: [
                          const TextSpan(text: '我已阅读并同意'),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showUserAgreementDialog(context),
                              child: Text(
                                '《用户协议》',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade400,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: '和'),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showPrivacyPolicyDialog(context),
                              child: Text(
                                '《隐私政策》',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade400,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    } else {
      final ResponseData result = await AuthHttp.checkUsername(_usernameController.text.trim());
      if (result.code != SUCCESS) {
        SmartDialog.showToast(result.msg);
        return;
      }
    }

    if (_phoneController.text.trim().isEmpty) {
      SmartDialog.showToast('请输入手机号');
      return;
    } else {
      final ResponseData result = await AuthHttp.checkPhone(_phoneController.text.trim());
      if (result.code != SUCCESS) {
        SmartDialog.showToast(result.msg);
        return;
      }
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

    if (!_agreedToTerms) {
      SmartDialog.showToast('请阅读并同意用户协议和隐私政策');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用后台发送验证码
      final ResponseData result = await AuthHttp.sendCaptcha(_phoneController.text.trim());

      if (result.code == SUCCESS) {
        SmartDialog.showToast('验证码已发送');
        // 跳转到验证码输入界面，传递注册信息
        context.go(
            '/verifycode?phone=${_phoneController.text.trim()}&password=${_passwordController.text}&username=${_usernameController.text.trim()}&isRegister=true');
      } else if (result.code == Errors.PHONE_REGISTERED) {
        // PHONE_REGISTERED_API_CODE
        SmartDialog.showToast('该手机号已被注册');
      } else {
        SmartDialog.showToast('发送验证码失败');
      }
    } catch (e) {
      SmartDialog.showToast('网络错误，请重试');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUserAgreementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('用户协议'),
          content: SingleChildScrollView(
            child: Text(
              '欢迎使用iMath数学学习应用！\n\n'
              '1. 服务说明\n'
              'iMath是一款专为数学学习设计的移动应用，提供数学题目、知识点讲解、文化科普等服务。\n\n'
              '2. 用户责任\n'
              '用户应遵守相关法律法规，不得利用本应用进行任何违法活动。\n\n'
              '3. 知识产权\n'
              '本应用的所有内容均受知识产权保护，用户不得擅自复制、传播。\n\n'
              '4. 隐私保护\n'
              '我们重视用户隐私，具体保护措施请参考《隐私政策》。\n\n'
              '5. 服务变更\n'
              '我们保留随时修改或终止服务的权利。\n\n'
              '6. 免责声明\n'
              '在法律允许的范围内，我们不承担因使用本应用而产生的任何损失。\n\n'
              '7. 协议更新\n'
              '本协议可能会不定期更新，更新后的协议将在应用内公布。\n\n'
              '8. 联系方式\n'
              '如有疑问，请联系我们的客服团队。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('隐私政策'),
          content: SingleChildScrollView(
            child: Text(
              '隐私政策\n\n'
              '1. 信息收集\n'
              '我们可能收集以下信息：\n'
              '• 设备信息（设备型号、操作系统版本等）\n'
              '• 使用数据（学习记录、答题情况等）\n'
              '• 账户信息（用户名、手机号等）\n\n'
              '2. 信息使用\n'
              '收集的信息将用于：\n'
              '• 提供个性化学习服务\n'
              '• 改进应用功能和用户体验\n'
              '• 发送重要通知和更新\n\n'
              '3. 信息保护\n'
              '我们采用行业标准的安全措施保护您的信息：\n'
              '• 数据加密传输和存储\n'
              '• 访问权限控制\n'
              '• 定期安全审计\n\n'
              '4. 信息共享\n'
              '我们不会向第三方出售、出租或共享您的个人信息，除非：\n'
              '• 获得您的明确同意\n'
              '• 法律要求或政府要求\n'
              '• 保护我们的合法权益\n\n'
              '5. 您的权利\n'
              '您有权：\n'
              '• 访问和更正您的个人信息\n'
              '• 删除您的账户\n'
              '• 撤回同意\n'
              '• 投诉举报\n\n'
              '6. 儿童隐私\n'
              '我们不会故意收集13岁以下儿童的个人信息。\n\n'
              '7. 政策更新\n'
              '本政策可能会更新，更新后将在应用内通知。\n\n'
              '8. 联系我们\n'
              '如有隐私相关问题，请联系我们的隐私保护团队。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
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
