import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:slider_captcha/slider_captcha.dart';

class SliderCaptchaClientVerify extends StatefulWidget {
  const SliderCaptchaClientVerify({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<SliderCaptchaClientVerify> createState() =>
      _SliderCaptchaClientVerifyState();
}

class _SliderCaptchaClientVerifyState extends State<SliderCaptchaClientVerify> {
  final SliderController controller = SliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SliderCaptcha(
            controller: controller,
            title: '拖动滑块进行验证',
            image: Image.asset(
              'assets/images/back1.png',
              fit: BoxFit.contain,
            ),
            colorBar: Colors.blue,
            colorCaptChar: Colors.blue,
            onConfirm: (value) async {
              debugPrint(value.toString());
              if (value) {
                SmartDialog.showToast('验证通过');
                context.go('/profile');
              } else {
                SmartDialog.showToast('验证失败');
                return await Future.delayed(const Duration(seconds: 5)).then(
                      (value) {
                    controller.create.call();
                  },
                );
              }

            },
          ),
        ),
      ),
    );
  }
}
