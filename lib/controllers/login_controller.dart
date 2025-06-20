import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_api_service.dart';
import '../models/user.dart';
import 'auth_controller.dart';

class LoginController extends AuthController {
  final GlobalKey<FormState> loginFormKey =
      GlobalKey<FormState>(debugLabel: '__loginFormKey__');

  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();


  LoginController(AuthApiService authenticationService)
      : super(authenticationService);

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    codeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validator(String? value) {
    log('validatoooor');

    if (value != null && value.isEmpty) {
      return 'Please this field must be filled';
    }
    return null;
  }

  Future<void> login() async {
    log('${emailController.text}, ${passwordController.text}');
    try {
      final response = await signIn(emailController.text, passwordController.text);
      // debugPrint('response: $response');
      String username = response.data['exdata']['username'];
      Get.toNamed('/profile', arguments: {'user': User(id: "0", name: username)}, preventDuplicates:  true);
      // print("切换到个人中心");

    } catch (err, _) {
      passwordController.clear();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      signOut();
      Get.offAllNamed('/login');
    } catch (err, _) {
      rethrow;
    }
  }

  Future<void> loginWithBrowser() async {
    try {
      log('Login with browser');
      log('is authenticated: ${isAuthenticated()}');
      // await OAuthClient().createClient();
      // await signIn(emailController.text, passwordController.text);
    } catch (err, _) {
      rethrow;
    }
  }

  Future<void> sendCode() async {
    // if (!_formKey.currentState!.validate()) return;
    //
    // _isLoading = true;

    try {
      await sendVerificationCode(phoneController.text, codeController.text);
      // _showCodeInput = true;
      // _startCountdown();
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('验证码已发送')),
      //   );
      // }
    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('发送失败: $e')),
      //   );
      // }
    } finally {
      // if (mounted) {
      //   _isLoading = false;
      // }
    }
  }

  Future<void> loginWithPhoneCode() async {
    try {
      final user = await loginWithPhone(
        phoneController.text,
        codeController.text,
      );

    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('登录失败: $e')),
      //   );
      // }
    } finally {

    }
  }

  // Future<void> _loginWithUsernameAndPassword() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   _isLoading = true;
  //
  //   try {
  //     final response = await _authService.loginWithUsernameAndPassword(
  //       _usernameController.text,
  //       _passwordController.text,
  //     );
  //
  //     if (response != null && mounted) {
  //       debugPrint("response token : ${response['data']}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(response['message'])),
  //       );
  //       Get.toNamed('/profile',
  //           arguments: {'user': User(id: "0", name: response['exdata']['username'])}
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('登录失败: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       _isLoading = false;
  //     }
  //   }
  // }

  Future<void> _loginWithWechat() async {
    try {
      final user = await loginWithWechat();

    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('登录失败: $e')),
      //   );
      // }
    } finally {
      // if (mounted) {
      //   _isLoading = false;
      // }
    }
  }
}
