import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:imath/http/auth.dart';
import 'package:go_router/go_router.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<PhoneLoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+86'; // 默认国家/地区代码，这里以中国为例

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 国家/地区选择相关，这里简单做个文本展示和点击可更换的示例，实际可换成下拉选择等复杂逻辑
              GestureDetector(
                onTap: () {
                  // 这里可弹出选择框让用户选择国家/地区代码，示例中简单模拟切换
                  setState(() {
                    _countryCode = _countryCode == '+86' ? '+1' : '+86';
                  });
                },
                child: Row(
                  children: [
                    Text(
                      '国家/地区',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _countryCode == '+86' ? '中国大陆' : '其他',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 手机号输入行，包含国家代码和手机号输入框
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_countryCode),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: '请输入手机号',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 立即登录按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 这里可处理登录逻辑，比如校验手机号、调用接口等
                    String phoneNumber = _phoneController.text.trim();
                    if (phoneNumber.isNotEmpty) {
                      // debugPrint('点击了立即登录，手机号：$_countryCode$phoneNumber');
                      AuthHttp.sendCaptcha(phoneNumber);
                      context.go('/verifycode?phone=${phoneNumber}');
                      SmartDialog.showToast('验证码已发送');
                    } else {
                      debugPrint('请输入手机号');
                    }
                  },
                  child: const Text('确定'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}