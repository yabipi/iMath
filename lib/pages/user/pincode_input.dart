import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/constant/errors.dart';

import 'package:imath/http/auth.dart';
import 'package:imath/http/payload.dart';
import 'package:imath/models/user.dart';
import 'package:imath/services/auth_service.dart';
import 'package:imath/widgets/timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';

class PinputScreen extends StatefulWidget {
  final String phone;
  final String? password;
  final String? username;
  final bool? isRegister;
  final bool? isForgotPassword;

  const PinputScreen({
    Key? key,
    required this.phone,
    this.password,
    this.username,
    this.isRegister,
    this.isForgotPassword,
  }) : super(key: key);

  @override
  State<PinputScreen> createState() => _PinputScreenState();
}

const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
const fillColor = Color.fromRGBO(243, 246, 249, 0);
const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

class _PinputScreenState extends State<PinputScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late OtpTimerButtonController? timerBtnController;
  late OtpTimerButton timerBtn; // 添加控制器声明

  final defaultPinTheme = PinTheme(
    width: 40,
    height: 40,
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      color: const Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: borderColor),
    ),
  );

  @override
  void initState() {
    super.initState();
    timerBtn = OtpTimerButton(
      onPressed: () {
        AuthHttp.sendCaptcha(widget.phone);
        SmartDialog.showToast('验证码已重新发送');
        pinController.clear();
        timerBtnController?.startTimer();
      },
      text: Text('重新发送验证码'),
      duration: 60,
    ); // 初始化控制器
    timerBtnController = timerBtn?.controller;
    timerBtn.controller?.startTimer();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerificationCode(String pin) async {
    try {
      if (widget.isRegister == true) {
        // 注册流程：验证验证码并完成注册
        await _handleRegisterVerification(pin);
      } else if (widget.isForgotPassword == true) {
        // 忘记密码流程：验证验证码后跳转到重置密码页面
        await _handleForgotPasswordVerification(pin);
      } else {
        // 登录流程：验证验证码并登录
        await _handleLoginVerification(pin);
      }
    } catch (e) {
      SmartDialog.showToast('验证失败，请重试');
      pinController.clear();
    }
  }

  Future<void> _handleRegisterVerification(String pin) async {
    try {
      final ResponseData _result = await AuthHttp.verifyCaptcha(
        widget.phone,
        pin,
        'register',
      );
      // 后端按规范返回 { httpState, code, user, token, message }
      if (_result != null && (_result.code == SUCCESS)) {
        // SmartDialog.showToast('注册成功');
        // 可选：保存用户并进入个人中心
        String verification_token = _result.getValue<String>('verification_token') ?? '';
        final ResponseData result = await AuthHttp.register(
            widget.username!,
            widget.phone, // 传递用户名参数
            widget.password!,
            verification_token
        );
        if (result != null && result.code == SUCCESS) {
          // 登录成功
          SmartDialog.showToast('注册成功');
                      // 保存用户信息
            try {
              AuthService.saveUser(result);
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) context.go('/profile');
          } catch (_) {
            // 即使保存失败也允许返回登录
            if (mounted) context.go('/login');
          }
         }

      } else {
        SmartDialog.showToast(_result.msg ?? '验证码验证失败');
        pinController.clear();
      }
    } catch (e) {
      SmartDialog.showToast('网络错误，请重试');
      pinController.clear();
    }
  }

  Future<void> _handleForgotPasswordVerification(String pin) async {
    // 这里应该调用忘记密码验证的API
    // 由于需求中没有明确的后端API，我们先模拟成功
    final ResponseData result = await AuthHttp.verifyCaptcha(
      widget.phone,
      pin,
      'reset_password',
    );
    if (result.code == SUCCESS) {
      // 验证码写死为123456
      SmartDialog.showToast('验证成功');
      // 延迟一下再跳转
      await Future.delayed(Duration(milliseconds: 500));
      context.go('/reset-password?phone=${widget.phone}');
    } else {
      SmartDialog.showToast('验证码错误');
      pinController.clear();
    }
  }

  Future<void> _handleLoginVerification(String pin) async {
    // 原有的登录验证逻辑
    final result =
        await AuthService.signinWithPhone(widget.phone, pin, widget.password);
    if (result) {
      context.go('/profile');
    } else {
      SmartDialog.showToast('验证码错误');
      pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/login'); // 返回上一页
            },
          ),
          title: Text("验证码校验"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildCodeInput(context),
            Row(
              children: [
                Spacer(),
                timerBtn,
                Spacer(),
              ],
            )
          ],
        ));
  }

  Widget _buildCodeInput(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Spacer(),
          Form(
            key: formKey,
            child: Column(
              children: [
                Directionality(
                  // Specify direction if desired
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    controller: pinController,
                    focusNode: focusNode,
                    autofocus: true,
                    defaultPinTheme: defaultPinTheme,
                    validator: (value) {
                      return null;
                      // return '';
                      // return value == '123456' ? null : '验证码不正确';
                    },
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) async {
                      await _handleVerificationCode(pin);
                    },
                    onChanged: (value) {
                      // debugPrint('onChanged: $value');
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: focusedBorderColor,
                        ),
                      ],
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // TextButton(
                //   onPressed: () => formKey.currentState!.validate(),
                //   child: const Text('提交'),
                // ),
              ],
            ),
          ),
          Spacer(),
        ]));
  }
}
