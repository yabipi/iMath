import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import 'package:imath/http/auth.dart';
import 'package:imath/widgets/timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';

class PinputScreen extends StatefulWidget {
  const PinputScreen({Key? key}) : super(key: key);

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
  late OtpTimerButton timerBtn;// 添加控制器声明

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
        AuthHttp.sendCaptcha();
        SmartDialog.showToast('验证码已重新发送');
        timerBtnController?.startTimer();
      },
      text: Text('重新发送验证码'),
      duration: 6,
    );// 初始化控制器
    timerBtnController = timerBtn?.controller;
    AuthHttp.sendCaptcha();
    SmartDialog.showToast('验证码已发送');

    timerBtn.controller?.startTimer();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/login'); // 返回上一页
              },
            ),
            title: Text("验证码"),
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
          )

      );
  }

  Widget _buildCodeInput(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Form(
                key: formKey,
                child:
                Column(
                  children: [
                    Directionality(
                      // Specify direction if desired
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 6,
                        controller: pinController,
                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,
                        validator: (value) {
                          return null;
                          // return '';
                          // return value == '123456' ? null : '验证码不正确';
                        },
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) async {
                          final response = await AuthHttp.verifyCaptcha(pin);
                          if (response['code'] == 1) {
                            // SmartDialog.showToast('验证码正确');
                            context.go('/profile');
                          } else {
                            SmartDialog.showToast('验证码错误');
                            timerBtnController?.enableButton();
                          }
                          // debugPrint('onCompleted: $pin');
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
            ])
    );
  }
}