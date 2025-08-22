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
  bool _agreedToTerms = false; // 是否同意协议

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

              // 手机号输入框
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: '请输入手机号',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    isDense: true, // 减少内部间距
                  ),
                  keyboardType: TextInputType.phone,
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
                      borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    isDense: true, // 减少内部间距
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              // 手机号说明文字
              const SizedBox(height: 8),
              Text(
                '当前仅支持中国大陆手机号登录，新用户首次验证通过后即自动完成注册',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),

              // 协议勾选选项
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
                  const SizedBox(width: 2), // 减少间距，让勾选框离文字更近
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
                                  fontSize: 14, // 统一字体大小为14
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
                                  fontSize: 14, // 统一字体大小为14
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
              const SizedBox(height: 32),

              // 登录按钮 - 适配字体宽度
              Container(
                constraints: const BoxConstraints(
                  minWidth: 120,
                  minHeight: 48,
                ),
                child: ElevatedButton(
                  onPressed: _agreedToTerms ? () async {
                    // 这里可处理登录逻辑，比如校验手机号、调用接口等
                    String phoneNumber = _phoneController.text.trim();
                    String passwd = _passwdController.text.trim();
                    if (phoneNumber.isNotEmpty) {
                      if(!PhoneValidator.isValid(phoneNumber)) {
                        SmartDialog.showToast('请输入合法的手机号码!');
                        return;
                      }
                      // 手动添加+86前缀
                      // String fullPhoneNumber = '+86$phoneNumber';
                      // debugPrint('点击了立即登录，手机号：$fullPhoneNumber');
                      final res = await AuthHttp.signIn(phoneNumber, passwd) as Map;
                      if (res['code'] == ApiCode.NEW_USER) {
                        // 新用户需要验证手机号是否合法
                        await AuthHttp.sendCaptcha(phoneNumber);
                        SmartDialog.showToast('验证码已发送');
                        context.go('/verifycode?phone=${phoneNumber}&password=${passwd}');
                      } else if (res['code'] == ApiCode.INTERNAL_SERVER_ERROR) {
                        SmartDialog.showToast(res['message']);
                      } else if (res['code'] == ApiCode.SUCCESS){
                        AuthService.saveUser(res);
                        // 登录成功，跳转到用户中心
                        context.go('/profile');
                      }
                    } else {
                      SmartDialog.showToast('请输入手机号');
                    }
                  } : null, // 如果未同意协议，按钮禁用
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
            ],
          ),
        ),
      ),
    );
  }

  // 显示用户协议对话框
  void _showUserAgreementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height - 
                   MediaQuery.of(context).padding.top - 
                   MediaQuery.of(context).padding.bottom - 100, // 减去状态栏和底部导航栏高度
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 标题栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '用户协议',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '欢迎使用iMath数学学习应用！',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
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
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 显示隐私政策对话框
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height - 
                   MediaQuery.of(context).padding.top - 
                   MediaQuery.of(context).padding.bottom - 100, // 减去状态栏和底部导航栏高度
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 标题栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '隐私政策',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '隐私政策',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
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
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}