import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/core/context.dart';
import 'package:imath/widgets/timer_button.dart';

class PhoneCodeVerifyView extends StatefulWidget {
  @override
  _PhoneCodeVerifyViewState createState() => _PhoneCodeVerifyViewState();
}

class _PhoneCodeVerifyViewState extends State<PhoneCodeVerifyView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isWaiting = false; // 是否正在等待验证码

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1) {
          if (i < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          } else {
            // 输入完成，提交验证码
            String code = _controllers.map((c) => c.text).join();
            _submitVerificationCode(code);
          }
        }
      });
    }
  }

  void _submitVerificationCode(String code) {
    // 提交验证码到后台
    print('Submitted verification code: $code');
    // 在这里调用 API 提交验证码
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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
          title: Text("验证码"),
        ),
        body: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Spacer(),
                      ...List.generate(6, (index) {
                        return
                          Padding(
                              padding: const EdgeInsets.all(4),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    print("value 长度: ${value.length}");
                                    // 处理输入
                                    if (value.length == 1) {
                                      if (index < 5) {
                                        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                      } else {
                                        // 输入完成，提交验证码
                                        String code = _controllers.map((c) => c.text).join();
                                        _submitVerificationCode(code);
                                      }
                                    } else if (value.isEmpty) {
                                      // 处理删除操作
                                      if (index > 0) {
                                        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                                      }
                                    }
                                  },
                                  onTap: () {
                                    // 点击时，如果当前输入框为空，找到最后一个有内容的输入框
                                    if (_controllers[index].text.isEmpty) {
                                      for (int i = index - 1; i >= 0; i--) {
                                        if (_controllers[i].text.isNotEmpty) {
                                          FocusScope.of(context).requestFocus(_focusNodes[i]);
                                          break;
                                        }
                                      }
                                    }
                                  },
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 12.0,
                                      ),
                                      constraints: BoxConstraints(minHeight: 48.0),
                                      counterText:''
                                  ),
                                  style: TextStyle(fontSize: 16.0),

                                ),
                              )
                          );
                      }),
                      Spacer()
                    ],

                  )

              ),
              Row(
                children: [
                  Spacer(),
                  OtpTimerButton(
                    // controller: OtpTimerButtonController(),
                    onPressed: () {
                      context.showMsg('OK');
                      },
                    text: Text('重新发送验证码'),
                    duration: 6,
                  ),
                  Spacer(),
                ],
              )
            ])
    );

  }
}